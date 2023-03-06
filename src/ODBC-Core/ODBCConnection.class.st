"
An ODBCConnection represents a connection to an ODBC data source.

One can use a ODBCConnection to query the capabilities of the underlying driver and the structure of the database. One can then interact with the database by submitting SQL queries using #exec: or #query:[cursorType:]. One can also prepare a ODBCStatement for later parameterization and execution with #prepare:[cursorType:].

Instance Variables:
	handle		<ExternalHandle>. ODBC connection handle.
	dsn		<String>. Data source name.
	uid		<String>. User id.
	pwd		<String>. Password.
	statements	<WeakSet>. Extant statements on this connection.
	transaction	<ODBCTxn>. Current transaction, if any.

Class Variables:
	HEnv		<ExternalHandle>. ODBC environment handle.
	Connections	<WeakSet>. All extant instances with at least an allocated handle.
	TxnIsolationLevels	<IdentityDictionary>. Map between SQL_TXN_XXX values and symbolic names.
	ScrollTypes	<IdentityDictionary>. Map between SQL_SO_XXX values and symbolic names.

Based on DBConnection from Dolphin Smalltalk Database Connection package.
"
Class {
	#name : #ODBCConnection,
	#superclass : #Object,
	#instVars : [
		'handle',
		'dsn',
		'uid',
		'pwd',
		'statements',
		'transaction',
		'connectString',
		'flags',
		'columnFieldIdentifier'
	],
	#classVars : [
		'Connections',
		'DriverCompleteMask',
		'HEnv',
		'ScrollTypes',
		'StringEncoder',
		'TxnIsolationLevels'
	],
	#pools : [
		'ODBCConstants',
		'ODBCRetCodes'
	],
	#category : #'ODBC-Core-Base'
}

{ #category : #helpers }
ODBCConnection class >> allocHandle [
	"Private - Answer a new connection handle."

	| hDBC ret |
	hDBC := SQLHANDLE new.
	ret := ODBCLibrary default
			sqlAllocHandle: SQL_HANDLE_DBC
			inputHandle: self environmentHandle
			outputHandlePtr: hDBC.
	self dbCheckException: ret.
	^hDBC
]

{ #category : #operations }
ODBCConnection class >> connectString: aString do: aTwoArgBlock [
	"Private - Interpret the connection string and pass the parameter name and value from each
	$; separated substring to aTwoArgBlock."

	"Implementation Note: We really need a mini-parser here to catch errors in the connection
	string, but for the sake of simplicity we use a less sophisticated approach that may yield
	incorrect results for some malformed connection strings (e.g. those missing the + separator
	between key and value pairs). This is considered less important than parsing well formed
	connection strings correctly."

	| stream |
	stream := aString readStream.

	[[stream peek == $;] whileTrue: [stream next].
	stream atEnd] whileFalse:
				[| paramName paramValue |
				paramName := stream upTo: $=.
				"Note that the value can be empty"
				paramValue := (stream peekFor: ${) ifTrue: [stream upTo: $}] ifFalse: [stream upTo: $;].
				aTwoArgBlock value: paramName value: paramValue]
]

{ #category : #accessing }
ODBCConnection class >> connections [
	"Answer the <collection> of active connections."

	^ Connections
]

{ #category : #exceptions }
ODBCConnection class >> dbCheckException: anIntegerRetCode [
	"Private - Checks anIntegerRetCode to see if a ODBCError or ODBCWarning should be signalled"

	^ anIntegerRetCode = SQL_SUCCESS
		ifFalse:
			["Signal an error or warning - decide which"

			((anIntegerRetCode = SQL_SUCCESS_WITH_INFO or: [ anIntegerRetCode = SQL_NO_DATA ])
				ifTrue: [ ODBCWarning ]
				ifFalse: [ ODBCError ]) signalWith: (self exceptionDetails: anIntegerRetCode)]
]

{ #category : #'class initialization' }
ODBCConnection class >> determineStringEncoder [
	"The String encoding can vary depending on the ODBC driver manager:
	Windows - always UTF16
	Mac/Linux - can be UTF16 (default for unixodbc manager) or UTF32 (default for iodbc)
	There is no readily apparent way to determine the manager or encoding, so we try UTF16 and examine the Strings resulting from an API call"

	| drivers |
	StringEncoder := ODBCUTF16Encoder new.
	OSPlatform current isWindows ifTrue: [ ^self ].

	drivers := self enumerateDrivers.
	drivers isEmpty ifTrue: [ ^self "no ODBC drivers found" ].

	"If UTF32 the second 'character' will be null"
	(drivers first key at: 2) = Character null ifTrue: [ StringEncoder := ODBCUTF32Encoder new ]
]

{ #category : #accessing }
ODBCConnection class >> enumerateDataSources [
	"Answers an array of associations of all the data sources and
	 their descriptions"

	| bufferLength dsn descriptionBufferLength description dsnLength descriptionLength hEnv odbc ret sources |
	bufferLength := self stringEncoder byteSizeForCharacters: SQL_MAX_DSN_LENGTH + 1.
	dsn := ExternalAddress gcallocate: bufferLength.
	descriptionBufferLength := bufferLength.
	description := ExternalAddress gcallocate: descriptionBufferLength.
	dsnLength := SQLSMALLINT new.
	descriptionLength := SQLSMALLINT new.
	hEnv := self environmentHandle.
	odbc := ODBCLibrary default.

	[ret := odbc
				sqlDataSources: hEnv
				direction: SQL_FETCH_FIRST
				serverName: dsn
				bufferLength1: bufferLength
				nameLength1Ptr: dsnLength
				description: description
				bufferLength2: descriptionBufferLength
				nameLength2Ptr: descriptionLength.
	ret == SQL_SUCCESS_WITH_INFO]
			whileTrue: [description := ExternalAddress gcallocate: (descriptionBufferLength := self stringEncoder byteSizeForCharacters: descriptionLength value + 1)].
	sources := WriteStream on: Array new.
	[ret == SQL_SUCCESS] whileTrue:
			[sources nextPut: (Association key: (self stringEncoder decodeStringFrom: dsn characterCount: dsnLength value)
						value: (self stringEncoder decodeStringFrom: description characterCount: descriptionLength value)).

			[ret := odbc
						sqlDataSources: hEnv
						direction: SQL_FETCH_NEXT
						serverName: dsn
						bufferLength1: bufferLength
						nameLength1Ptr: dsnLength
						description: description
						bufferLength2: descriptionBufferLength
						nameLength2Ptr: descriptionLength.
			ret == SQL_SUCCESS_WITH_INFO]
					whileTrue: [description := ExternalAddress gcallocate: (descriptionBufferLength := self stringEncoder byteSizeForCharacters: descriptionLength value + 1)]].
	ret ~= SQL_NO_DATA ifTrue: [self dbCheckException: ret].
	^ sources contents
]

{ #category : #accessing }
ODBCConnection class >> enumerateDrivers [
	"Answers an array of associations of all the drivers and their attributes"

	| bufferLength driver attributesBufferLength attributes driverLength attributesLength hEnv odbc ret drivers |
	bufferLength := self stringEncoder byteSizeForCharacters: SQL_MAX_MESSAGE_LENGTH + 1.
	driver := ExternalAddress gcallocate: bufferLength.
	attributesBufferLength := bufferLength.
	attributes := ExternalAddress gcallocate: attributesBufferLength.
	driverLength := SQLSMALLINT new.
	attributesLength := SQLSMALLINT new.
	hEnv := self environmentHandle.
	odbc := ODBCLibrary default.

	[ret := odbc
				sqlDrivers: hEnv
				direction: SQL_FETCH_FIRST
				driverDescription: driver
				bufferLength1: bufferLength
				descriptionLengthPtr: driverLength
				attributes: attributes
				bufferLength2: attributesBufferLength
				attributesLengthPtr: attributesLength.
	ret == SQL_SUCCESS_WITH_INFO]
			whileTrue: [attributes := ExternalAddress gcallocate: (attributesBufferLength := self stringEncoder byteSizeForCharacters: attributesLength value + 1)].
	drivers := WriteStream on: Array new.
	[ret == SQL_SUCCESS] whileTrue:
			[drivers nextPut: (Association key: (self stringEncoder decodeStringFrom: driver characterCount: driverLength value)
						value: (self stringEncoder decodeStringFrom: attributes characterCount: attributesLength value)).

			[ret := odbc
				sqlDrivers: hEnv
				direction: SQL_FETCH_NEXT
				driverDescription: driver
				bufferLength1: bufferLength
				descriptionLengthPtr: driverLength
				attributes: attributes
				bufferLength2: attributesBufferLength
				attributesLengthPtr: attributesLength.
			ret == SQL_SUCCESS_WITH_INFO]
					whileTrue: [attributes := ExternalAddress gcallocate: (attributesBufferLength := self stringEncoder byteSizeForCharacters: attributesLength value)]].
	ret ~= SQL_NO_DATA ifTrue: [self dbCheckException: ret].
	^ drivers contents
]

{ #category : #accessing }
ODBCConnection class >> environmentHandle [
	"Private - Answer the environment handle.
	Create it if we haven't done so already."

	(HEnv isNil or: [ HEnv isNull ])
		ifTrue:
			[| ret |
			HEnv := SQLHANDLE new.
			ret := ODBCLibrary default
						sqlAllocHandle: SQL_HANDLE_ENV
						inputHandle: SQLHANDLE null
						outputHandlePtr: HEnv.
			ret = SQL_SUCCESS
				ifFalse:
					[HEnv := nil.
					^self dbCheckException: ret].
			self setDefaultEnvAttrs].
	^ HEnv
]

{ #category : #exceptions }
ODBCConnection class >> exceptionDetails: retCode [
	"Private - Answer a <ODBCExceptionDetails> instance that describes the state of the
	receiver following an exception with the specified <integer> return code. This will
	be available as the tag of a subsequent signalled DBError or DBWarning."

	^ (ODBCExceptionDetails new)
			code: retCode;
			hEnv: HEnv;
			stringEncoder: self stringEncoder;
			yourself
]

{ #category : #'realizing/unrealizing' }
ODBCConnection class >> freeAll [
	"Private - Free all of my instances which are recorded
	in the handle table.
	Use with care, only for getting out of nasty scrapes, as all
	connections will be closed, etc.!"

	self connections do: [:each | each free].
	self
		newConnections;
		freeEnvironment
]

{ #category : #'realizing/unrealizing' }
ODBCConnection class >> freeEnvironment [

	| ret |
	HEnv isNull ifTrue: [ ^ self ].
	ret := ODBCLibrary default sqlFreeHandle: SQL_HANDLE_ENV handle: HEnv.
	self dbCheckException: ret.
	HEnv := nil
]

{ #category : #'class initialization' }
ODBCConnection class >> initialize [
	"Private - Initialize the receiver's class variables"

	DriverCompleteMask := 1.
	TxnIsolationLevels := (IdentityDictionary new)
				at: SQL_TXN_READ_UNCOMMITTED put: #readUncommitted;
				at: SQL_TXN_READ_COMMITTED put: #readCommitted;
				at: SQL_TXN_REPEATABLE_READ put: #repeatableRead;
				at: SQL_TXN_SERIALIZABLE put: #serializable;
				yourself.
	ScrollTypes := (IdentityDictionary new)
				at: SQL_SO_FORWARD_ONLY put: #forwardOnly;
				at: SQL_SO_DYNAMIC put: #dynamic;
				at: SQL_SO_KEYSET_DRIVEN put: #keysetDriven;
				at: SQL_SO_STATIC put: #static;
				at: SQL_SO_MIXED put: #mixed;
				yourself.
	self newConnections
]

{ #category : #'class initialization' }
ODBCConnection class >> initializeStringEncoder [

	self determineStringEncoder.

	"ODBCColAttr.CTypesExtraBytes must be reset for the current string encoder"
	ODBCColAttr initializeExtraBytes
]

{ #category : #'realizing/unrealizing' }
ODBCConnection class >> invalidateHandle: anExternalHandle [
	"Private - Disconnect and free the specified connection handle.
	This is used by ODBCConnection class to free a connection handle
	when it only knows the handle"

	| ret odbc |
	odbc := ODBCLibrary default.
	ret := odbc sqlDisconnect: anExternalHandle.
	ret ~= SQL_SUCCESS ifTrue: [ODBCError signalWith: (self exceptionDetails: ret)].
	ret := odbc sqlFreeHandle: SQL_HANDLE_DBC handle: anExternalHandle.
	ret ~= SQL_SUCCESS ifTrue: [ODBCError signalWith: (self exceptionDetails: ret)]
]

{ #category : #accessing }
ODBCConnection class >> newConnections [
	"Use a WeakRegistry so this can take care of finalization for us"

	Connections := WeakRegistry new
]

{ #category : #accessing }
ODBCConnection class >> odbcVersion [
	<script: 'self odbcVersion inspect'>
	
	| version |
	version := SQLSMALLINT new.
	self dbCheckException: (ODBCLibrary default
			 sqlGetEnvAttr: HEnv
			 infoType: SQL_ATTR_ODBC_VERSION
			 infoValuePtr: version asSQLPOINTER
			 bufferLength: 0
			 stringLengthPtr: nil).
	^ version value
]

{ #category : #accessing }
ODBCConnection class >> reset [

	HEnv := nil.
	StringEncoder := nil
]

{ #category : #accessing }
ODBCConnection class >> setDefaultEnvAttrs [
	| ret |
	ret := ODBCLibrary default
				sqlSetEnvAttr: HEnv
				attribute: SQL_ATTR_ODBC_VERSION
				valuePtr: SQL_OV_ODBC3 asSQLPOINTER
				stringLength: 0.
	self dbCheckException: ret.
	^ret
]

{ #category : #accessing }
ODBCConnection class >> stringEncoder [

	^ StringEncoder ifNil: [ self initializeStringEncoder. StringEncoder ]
]

{ #category : #operations }
ODBCConnection class >> transact: aDBConnection action: anInteger [
	"Private - Performs the requested transaction action on the specified
	 connection (which if Null implies that ODBC should commit/rollback
	 all connections within the environment."

	| ret |
	ret := ODBCLibrary default
				sqlEndTran: SQL_HANDLE_DBC
				handle: aDBConnection asParameter
				completionType: anInteger.
	ret ~= SQL_SUCCESS ifTrue: [ODBCError signalWith: (aDBConnection exceptionDetails: ret)]
]

{ #category : #helpers }
ODBCConnection >> allocStmtHandle: aODBCStatement [
	"Private - Allocate a new statement handle for the specified object.
	This may cause a connection to be lazily established (via the handle method)."

	| hStmt ret |
	hStmt := SQLHANDLE new.

	ret := ODBCLibrary default
		sqlAllocHandle: SQL_HANDLE_STMT
		inputHandle: self asParameter
		outputHandlePtr: hStmt.
	self dbCheckException: ret.

	"For finalization, must assign handle before adding to statements"
	aODBCStatement assignHandle: hStmt.
	self statements add: aODBCStatement
]

{ #category : #converting }
ODBCConnection >> asParameter [
	"Answer the receiver in a form suitable for passing to an external function
	primitive method (see ExternalLibrary and subclasses)."

	handle isNull ifTrue: [ self basicConnect ].
	^ handle
]

{ #category : #operations }
ODBCConnection >> basicConnect [
	"Private - Connect with the parameters specified earlier.
	Assumes not already connected."

	[| ret |
	ret := ODBCLibrary default
				sqlConnect: self getHandle
				serverName: (self stringEncoder encodeStringWithNullTerminator: dsn)
				nameLength1: SQL_NTS
				userName: (self stringEncoder encodeStringWithNullTerminator: uid)
				nameLength2: SQL_NTS
				authentication: (self stringEncoder encodeStringWithNullTerminator: pwd)
				nameLength3: SQL_NTS.
	self dbCheckException: ret]
			ifCurtailed: [ self free ]
]

{ #category : #transactions }
ODBCConnection >> beginRWTxn [
	"Start a read/write transaction on this connection."

	self transaction: (ODBCTxn newRWOn: self)
]

{ #category : #transactions }
ODBCConnection >> beginTxn [
	"Start a read only transaction on this connection"

	self transaction: (ODBCTxn newOn: self)
]

{ #category : #helpers }
ODBCConnection >> buildConnectString [

	| stream |
	stream := WriteStream on: (String new: 50).
	dsn notNil
		ifTrue:
			[stream
				nextPutAll: 'DSN=';
				nextPutAll: dsn].
	uid notNil
		ifTrue:
			[stream
				nextPutAll: ';UID=';
				nextPutAll: uid].
	pwd notNil
		ifTrue:
			[stream
				nextPutAll: ';PWD=';
				nextPutAll: pwd].
	^stream contents readStream upTo: Character null
]

{ #category : #enquiries }
ODBCConnection >> catalogNameSeparator [
	"Answer the qualifier name separator"

	^ self getStringInfo: SQL_CATALOG_NAME_SEPARATOR
]

{ #category : #enquiries }
ODBCConnection >> catalogTerm [
	"Answer the <readableString> name for a 'catalog' in the parlance of the DBMS to which the
	receiver is connected, e.g. in the case of Access this is 'DATABASE'."

	^ self getStringInfo: SQL_CATALOG_TERM
]

{ #category : #helpers }
ODBCConnection >> checkEmptyEnvironment [
	"Private - If there are no more open connections, free the environment"

	Connections ifNotEmpty: [ ^self ].

	[ self class freeEnvironment] on: ODBCError do: [:se | se trace].
	HEnv := nil
]

{ #category : #operations }
ODBCConnection >> close [
	"Close a database connection - rollback the current transaction, disconnect,
	and free connection handle"

	handle isNull ifTrue: [ ^self ].

	transaction ifNotNil: [ self rollbackTxn ].
	self
		disconnect;
		free;
		checkEmptyEnvironment
]

{ #category : #operations }
ODBCConnection >> closeNoFail [
	"Quietly close connection (frees handle), and if no
	more open connections, free the environment"

	[ self close ]
		on: ODBCError
		do: [ :se |
			se trace.
			handle := SQLHANDLE null.
			self checkEmptyEnvironment ]
]

{ #category : #accessing }
ODBCConnection >> columnFieldIdentifier [

	^columnFieldIdentifier
]

{ #category : #accessing }
ODBCConnection >> columnFieldIdentifier: anInteger [

	columnFieldIdentifier := anInteger
]

{ #category : #enquiries }
ODBCConnection >> columns: aStringTableName [
	"Answer a list of columns in the table aStringTableName"

	^self columns: nil qualifier: nil owner: nil table: aStringTableName
]

{ #category : #enquiries }
ODBCConnection >> columns: aStringColumn qualifier: aStringQualifier owner: aStringOwner table: aStringTable [
	"Answer the list of columns in the table matching the specified search criteria"

	| i stmt colAttrs |
	stmt := ODBCColumnsStatement parent: self.
	stmt
		catalogName: aStringQualifier;
		schemaName: aStringOwner;
		tableName: aStringTable;
		columnName: aStringColumn.
	i := 0.
	colAttrs := stmt results collect:
					[:each |
					i := i + 1.
					"at: 'column_name'"	"at: 'DATA_TYPE'"	"at: 'LENGTH'"	"at: 'PRECISION'"	"at: 'SCALE'"
					(ODBCColAttr new)
						columnNumber: i;
						name: (each atIndex: 4);
						type: (each atIndex: 5);
						length: (each atIndex: 8);
						precision: (each atIndex: 7);
						scale: (each atIndex: 9);
						yourself].
	stmt free.
	^colAttrs
]

{ #category : #transactions }
ODBCConnection >> commitTxn [
	"Commit the receiver's current transaction. Raise an error if there is no outstanding transaction."

	self transaction commit.
	transaction := nil
]

{ #category : #operations }
ODBCConnection >> connect [
	"Connect with the parameters specified earlier. Do nothing if already connected.
	Implementation Note: Connections are normally established lazily when the handle
	is requested."

	handle isNull ifTrue: [self basicConnect]
]

{ #category : #accessing }
ODBCConnection >> connectString [
	"Answer the connect string to use for this connection."

	connectString isNil ifTrue: [connectString := self buildConnectString].
	^connectString
]

{ #category : #accessing }
ODBCConnection >> connectString: aString [
	"Interpret the connection string and grab any parameters from it which we're interested in
	i.e. those for which we have a 'set' method."

	dsn := uid := pwd := nil.
	self class connectString: aString
		do:
			[:paramName :paramValue |
			| selector |
			selector := (paramName asLowercase , ':') asSymbol.
			(self respondsTo: selector) ifTrue: [self perform: selector with: paramValue]].
	connectString := aString
]

{ #category : #enquiries }
ODBCConnection >> convertFunctions [
	"Answers an array of the conversion functions available"

	| mask |
	mask := self getSQLUIntegerInfo: SQL_CONVERT_FUNCTIONS.
	^#('SQL_FN_CVT_CONVERT')
		select: [:maskName | (mask bitAnd: (ODBCConstants classPool at: maskName)) ~= 0]
]

{ #category : #enquiries }
ODBCConnection >> cursorCommitBehaviour [
	"Answer an <integer> from the SQL_CB_XXX enumeration identifying the
	cursor commit behaviour of this connection."

	^self getSQLUSmallIntInfo: SQL_CURSOR_COMMIT_BEHAVIOR
]

{ #category : #enquiries }
ODBCConnection >> cursorRollbackBehaviour [
	"Answer an <integer> from the SQL_CB_XXX enumeration identifying the
	cursor rollback behaviour of this connection."

	^self getSQLUSmallIntInfo: SQL_CURSOR_ROLLBACK_BEHAVIOR
]

{ #category : #enquiries }
ODBCConnection >> dataSourceName [
	"Answer the data source name as a <readableString>."

	^self getStringInfo: SQL_DATA_SOURCE_NAME
]

{ #category : #enquiries }
ODBCConnection >> databaseName [
	"Answer the <readableString> database name, e.g. in the case of an Access database this will
	be the file name, or in the case of an SQL Server database the name of one of the databases hosted
	by the server."

	^self getStringInfo: SQL_DATABASE_NAME
]

{ #category : #exceptions }
ODBCConnection >> dbCheckException: arg1 [

	^ arg1 = SQL_SUCCESS ifFalse: [
		  ((arg1 = SQL_SUCCESS_WITH_INFO or: [ arg1 = SQL_NO_DATA ])
			   ifTrue: [ ODBCWarning ]
			   ifFalse: [ ODBCError ]) signalWith:
			  (self exceptionDetails: arg1) ]
]

{ #category : #enquiries }
ODBCConnection >> dbmsName [
	"Answers the underlying DBMS name as a <readableString>."

	^self getStringInfo: SQL_DBMS_NAME
]

{ #category : #enquiries }
ODBCConnection >> dbmsVersion [
	"Answers the underlying DBMS version as a <readableString>"

	^self getStringInfo: SQL_DBMS_VER
]

{ #category : #helpers }
ODBCConnection >> decodeBitMask: anInteger map: aDictionary [
	| answer |
	answer := OrderedCollection new.
	aDictionary keysAndValuesDo:
			[:eachKey :eachValue |
			(anInteger allMask: eachKey) ifTrue: [answer addLast: eachValue]].
	^answer
]

{ #category : #constants }
ODBCConnection >> defaultCursorType [
	"Answer the <Symbol>ic name of the default cursor type to be used for statements
	(one of #dynamic, #forwardOnly, #keysetDriven, #static).
	Implementation Note: For backwards compatibility use a #keysetDriven cursor
	by default."

	^#keysetDriven
]

{ #category : #constants }
ODBCConnection >> defaultFlags [
	^DriverCompleteMask
]

{ #category : #enquiries }
ODBCConnection >> defaultTransactionIsolation [
	"Answer the default transaction isolation."

	^TxnIsolationLevels at: (self getSQLUIntegerInfo: SQL_DEFAULT_TXN_ISOLATION)
]

{ #category : #operations }
ODBCConnection >> disconnect [
	"Private - disconnect without freeing handle. All oustanding
	statements are free'd (this is necessary because they are
	about to become invalid). Client objects should send close
	instead."

	handle isNull ifFalse: [ | ret |
		self invalidateAllStmts.
		ret := ODBCLibrary default sqlDisconnect: handle.
		self dbCheckException: ret]
]

{ #category : #accessing }
ODBCConnection >> driverHDBC [
	"Private - Answer the handle to the driver connection"

	^self getHandle: SQL_DRIVER_HDBC
]

{ #category : #accessing }
ODBCConnection >> driverHEnv [
	"Private - Answer the handle to the driver environment"

	^self getHandle: SQL_DRIVER_HENV
]

{ #category : #enquiries }
ODBCConnection >> driverName [
	"Answer the driver name"

	^self getStringInfo: SQL_DRIVER_NAME
]

{ #category : #enquiries }
ODBCConnection >> driverVersion [
	"Answer the driver version"

	^self getStringInfo: SQL_DRIVER_VER
]

{ #category : #accessing }
ODBCConnection >> dsn [
	"Answer the data set name for the receiver"

	^dsn
]

{ #category : #accessing }
ODBCConnection >> dsn: aString [
	"Set the data set name to aString."

	connectString := nil.
	dsn := aString
]

{ #category : #exceptions }
ODBCConnection >> exceptionDetails: code [
	"Private - Answer an <ODBCExceptionDetails> instance that describes the state of the
	receiver following an exception with the specified <integer> return code. This will
	be available as the tag of a subsequent signalled ODBCError or ODBCWarning."

	^(self class exceptionDetails: code)
		hDBC: handle;
		yourself
]

{ #category : #executing }
ODBCConnection >> exec: aString [
	"Execute the SQL in aString.
	Answer the <ODBCStatement> used to execute the statement"

	^self exec: aString cursorType: #keysetDriven
]

{ #category : #executing }
ODBCConnection >> exec: aString cursorType: aSymbol [
	"Execute the SQL in aString, answering the type of cursor specified by the
	<Symbol> argument (one of #dynamic, #forwardOnly, #keysetDriven, or
	#static)."

	| statement |
	statement := self newStatement: aSymbol.
	[statement exec: aString] ifCurtailed: [statement free].
	^statement
]

{ #category : #finalizing }
ODBCConnection >> finalize [
	"Private - finalize the affairs of the receiver."

	[
		super finalize.
		self close
	] on: ODBCError do: [:x | x trace]
]

{ #category : #'realizing/unrealizing' }
ODBCConnection >> free [
	"Private - Free the connection handle."

	handle isNull ifFalse: [
		self dbCheckException: self freeNoFail.
		handle invalidateHandle]
]

{ #category : #'realizing/unrealizing' }
ODBCConnection >> freeNoFail [
	"Private - Free the connection handle ignoring any errors."

	^ODBCLibrary default sqlFreeHandle: SQL_HANDLE_DBC handle: handle
]

{ #category : #helpers }
ODBCConnection >> freeStmtHandle: aDBAbstractStatement [
	| ret hstmt |

	handle isNull ifTrue: [^self].
	hstmt := aDBAbstractStatement handle.
	hstmt isNull ifTrue: [ ^self ].
	ret := ODBCLibrary default sqlFreeHandle: SQL_HANDLE_STMT
				handle: hstmt.
	ret ~= SQL_SUCCESS
		ifTrue: [ODBCError signalWith: (aDBAbstractStatement exceptionDetails: ret)].
	hstmt invalidateHandle
]

{ #category : #enquiries }
ODBCConnection >> getBoolInfo: anInteger [
	"Private - Answer a <Boolean> indicating the receiver's info attribute described by anInteger."

	| length value |
	length := self stringEncoder byteSizeForCharacters: 2. "Byte size including implict null char"
	value := ExternalAddress gcallocate: length.
	self dbCheckException: (ODBCLibrary default
				sqlGetInfo: self asParameter
				infoType: anInteger
				infoValuePtr: value
				bufferLength: length
				stringLengthPtr: nil).
	^(value byteAt: 1) = $Y asciiValue
]

{ #category : #accessing }
ODBCConnection >> getHandle [
	"Private - Answer the handle instance variable.
	Allocate it if we haven't done so already."

	(handle isNil or: [ handle isNull ])
		ifTrue:
			[handle := self class allocHandle.
			self setDefaultAttributes.
			self class connections add: self].
	^handle
]

{ #category : #helpers }
ODBCConnection >> getHandle: anInteger [
	| value |
	value := SQLHANDLE new.
	self dbCheckException: (ODBCLibrary default
				sqlGetInfo: self asParameter
				infoType: anInteger
				infoValueHandle: value
				bufferLength: SQLHANDLE byteSize
				stringLengthPtr: nil).
	^value
]

{ #category : #accessing }
ODBCConnection >> getSQLUIntegerAttribute: anInteger [
	"Private - Answer an <Integer> containing the 32-bit unsigned integer value of the
	connection attribute identified by the <integer> argument."

	| buffer ret |
	buffer := SQLUINTEGER new.
	ret := ODBCLibrary default
				sqlGetConnectAttr: self asParameter
				attribute: anInteger
				valuePtr: buffer asSQLPOINTER
				bufferLength: SQL_IS_UINTEGER
				stringLengthPtr: nil.
	self dbCheckException: ret.
	^buffer value
]

{ #category : #enquiries }
ODBCConnection >> getSQLUIntegerInfo: anInteger [
	"Private - Answer an Integer containing the value of the receiver's SQLUINTEGER info attribute described by anInteger."

	| value |
	value := SQLUINTEGER new.
	self dbCheckException: (ODBCLibrary default
				sqlGetInfo: self asParameter
				infoType: anInteger
				infoValuePtr: value asSQLPOINTER
				bufferLength: 4
				stringLengthPtr: nil).
	^value value
]

{ #category : #enquiries }
ODBCConnection >> getSQLUSmallIntInfo: anInteger [
	"Private - Answer an Integer containing the value of the receiver's SQLUSMALLINT info attribute described by infoCode."

	| value |
	value := SQLUSMALLINT new.
	self dbCheckException: (ODBCLibrary default
				sqlGetInfo: self asParameter
				infoType: anInteger
				infoValuePtr: value asSQLPOINTER
				bufferLength: 2
				stringLengthPtr: nil).
	^value value
]

{ #category : #accessing }
ODBCConnection >> getStringAttribute: anInteger [
	"Private - Answer a <String> containing the value of the connection attribute identified by the <integer> argument."

	| bufferLen buffer |
	bufferLen := self stringEncoder byteSizeForCharacters: SQL_MAX_OPTION_STRING_LENGTH + 1.
	buffer := ExternalAddress allocate: bufferLen.
	^[self dbCheckException: (ODBCLibrary default
				sqlGetConnectAttr: self asParameter
				attribute: anInteger
				valuePtr: buffer
				bufferLength: bufferLen
				stringLengthPtr: nil).
	"N.B. The SQL server driver never seems to populate the stringLengthPtr argument, so we are forced to trim up to the nulls."
	self stringEncoder decodeNullTerminatedStringFrom: buffer] ensure: [ buffer free ]
]

{ #category : #enquiries }
ODBCConnection >> getStringInfo: anInteger [
	"Private - Answer a String containing the value of the receiver's info attribute described by infoCode."

	| value len bufferLen |
	len := SQLSMALLINT new.
	bufferLen := self stringEncoder byteSizeForCharacters: SQL_MAX_MESSAGE_LENGTH + 1.
	value := ExternalAddress allocate: bufferLen.
	^[self dbCheckException: (ODBCLibrary default
				sqlGetInfo: self asParameter
				infoType: anInteger
				infoValuePtr: value
				bufferLength: bufferLen
				stringLengthPtr: len).
	self stringEncoder decodeStringFrom: value byteCount: len value] ensure: [ value free ]
]

{ #category : #enquiries }
ODBCConnection >> hasAccessibleTables [
	"Answers whetherthe receiver is connected to a DB which has tables that can be accessed."

	^self getBoolInfo: SQL_ACCESSIBLE_TABLES
]

{ #category : #enquiries }
ODBCConnection >> hasIntegrityEnhancementFacility [
	"Answer whether the DBMS to which the receiver is connected has integrity enhancement facility support."

	^self getBoolInfo: SQL_INTEGRITY
]

{ #category : #enquiries }
ODBCConnection >> identifierCase [
	"Answer an <integer> constant from the SQL_IC_XXXX enumeration that indicates the
	case sensitivity of the DBMS to which the receiver is connected."

	^self getSQLUSmallIntInfo: SQL_IDENTIFIER_CASE
]

{ #category : #enquiries }
ODBCConnection >> identifierQuoteCharacter [
	"Answers the <Character> used to quote identifiers in the DBMS' SQL dialect."

	^(self getStringInfo: SQL_IDENTIFIER_QUOTE_CHAR) first
]

{ #category : #enquiries }
ODBCConnection >> indicesOf: aString [
	"Answer the a <collection> of <DBRows> being details of all the indices for the
	table with the specified <readableString> name."

	^self
		statisticsFor: aString
		type: SQL_INDEX_ALL
		accurate: true
]

{ #category : #initialization }
ODBCConnection >> initialize [
	"Private - Initialize the receiver."

	handle := SQLHANDLE null.
	flags := self defaultFlags.
	columnFieldIdentifier := SQL_DESC_OCTET_LENGTH.
	self initializeStatements
]

{ #category : #'private - initialization' }
ODBCConnection >> initializeStatements [
	"Use WeakRegistry so this can take care of finalization for us"
	statements := WeakRegistry new
]

{ #category : #'realizing/unrealizing' }
ODBCConnection >> invalidateAllStmts [
	"Private - Free all statements under this connection"

	self statements do: [:s | s free].
	self statements finalizeValues
]

{ #category : #accessing }
ODBCConnection >> isReadOnly [
	"Answer whether the receiver's access mode option is set to read-only."

	^(self getSQLUIntegerAttribute: SQL_ATTR_ACCESS_MODE) = SQL_MODE_READ_ONLY
]

{ #category : #accessing }
ODBCConnection >> isReadOnly: aBoolean [
	"Set whether the receiver's access mode option is read-only."

	self
		setAttribute: SQL_ATTR_ACCESS_MODE
		value: (aBoolean ifTrue: [SQL_MODE_READ_ONLY] ifFalse: [SQL_MODE_READ_WRITE])
		size: SQL_IS_UINTEGER
]

{ #category : #enquiries }
ODBCConnection >> isSAGCompliant [
	"Answer whether the DBMS to which the receiver is connected is SAG compliant."

	^(self getSQLUSmallIntInfo: SQL_ODBC_SAG_CLI_CONFORMANCE) = SQL_OSCC_COMPLIANT
]

{ #category : #enquiries }
ODBCConnection >> isSourceReadOnly [
	"Answer whether the data source is read only."

	^self getBoolInfo: SQL_DATA_SOURCE_READ_ONLY
]

{ #category : #testing }
ODBCConnection >> isTracing [
	"Answer whether the receiver's trace option is set."

	^(self getSQLUIntegerAttribute: SQL_ATTR_TRACE) = SQL_OPT_TRACE_ON
]

{ #category : #accessing }
ODBCConnection >> isTracing: aBoolean [
	"Set whether the receiver's trace facility is on or off."

	self
		setAttribute: SQL_ATTR_TRACE
		value: (aBoolean ifTrue: [SQL_OPT_TRACE_ON] ifFalse: [SQL_OPT_TRACE_OFF])
		size: SQL_IS_UINTEGER
]

{ #category : #enquiries }
ODBCConnection >> isTransactionCapable [
	"Answer whether the DBMS to which the receiver is connected supports transactions."

	^self getSQLUSmallIntInfo: SQL_TXN_CAPABLE
]

{ #category : #accessing }
ODBCConnection >> loginTimeout [
	"Answer the Integer value of the receiver's login timeout option."

	^self getSQLUIntegerAttribute: SQL_ATTR_LOGIN_TIMEOUT
]

{ #category : #accessing }
ODBCConnection >> loginTimeout: anInteger [
	"Set the receiver's login timeout to anInteger."

	self
		setAttribute: SQL_ATTR_LOGIN_TIMEOUT
		value: anInteger
		size: SQL_IS_UINTEGER
]

{ #category : #enquiries }
ODBCConnection >> maxCatalogNameLength [
	"Answer the <integer> maximum length of a catalog in the DBMS to which the receiver is connected."

	^self getSQLUSmallIntInfo: SQL_MAX_CATALOG_NAME_LEN
]

{ #category : #enquiries }
ODBCConnection >> maxColumnNameLength [
	"Answer the <integer> maximum length of a column in the DBMS to which the receiver is connected."

	^self getSQLUSmallIntInfo: SQL_MAX_COLUMN_NAME_LEN
]

{ #category : #enquiries }
ODBCConnection >> maxConnections [
	"Answer the <integer> maximum number of concurrent connections supported by the DBMS."

	^self getSQLUSmallIntInfo: SQL_MAX_DRIVER_CONNECTIONS
]

{ #category : #enquiries }
ODBCConnection >> maxCursorNameLength [
	"Answer the <integer> maximum length of a cursor in the DBMS to which the receiver is connected."

	^self getSQLUSmallIntInfo: SQL_MAX_CURSOR_NAME_LEN
]

{ #category : #enquiries }
ODBCConnection >> maxProcedureNameLength [
	"Answer the <integer> maximum length of a procedure in the DBMS to which the receiver is connected."

	^self getSQLUSmallIntInfo: SQL_MAX_PROCEDURE_NAME_LEN
]

{ #category : #enquiries }
ODBCConnection >> maxSchemaNameLength [
	"Answer the <integer> maximum length of a schema name in the DBMS to which the receiver is connected."

	^self getSQLUSmallIntInfo: SQL_MAX_SCHEMA_NAME_LEN
]

{ #category : #enquiries }
ODBCConnection >> maxStatements [
	"Answer the the maximum number of concurrent statements supported."

	^self getSQLUSmallIntInfo: SQL_MAX_CONCURRENT_ACTIVITIES
]

{ #category : #enquiries }
ODBCConnection >> maxTableNameLength [
	"Answer the maximum length of a table name"

	^self getSQLUSmallIntInfo: SQL_MAX_TABLE_NAME_LEN
]

{ #category : #operations }
ODBCConnection >> newParameterizedStatement: aSymbol [
	"Private - Answer an ODBCParameterizedStatement connected to the receiver"

	^ODBCParameterizedStatement parent: self cursorType: aSymbol
]

{ #category : #operations }
ODBCConnection >> newStatement: aSymbol [
	"Private - Answer an ODBCStatement connected to the receiver and with the specified
	cursor type."

	^ ODBCStatement parent: self cursorType: aSymbol
]

{ #category : #enquiries }
ODBCConnection >> numericFunctions [
	"Answers an array of the numeric functions available"

	| mask |
	mask := self getSQLUIntegerInfo: SQL_NUMERIC_FUNCTIONS.
	^#('SQL_FN_NUM_ABS' 'SQL_FN_NUM_ACOS' 'SQL_FN_NUM_ASIN' 'SQL_FN_NUM_ATAN' 'SQL_FN_NUM_ATAN2' 'SQL_FN_NUM_CEILING' 'SQL_FN_NUM_COS' 'SQL_FN_NUM_COT' 'SQL_FN_NUM_EXP' 'SQL_FN_NUM_FLOOR' 'SQL_FN_NUM_LOG' 'SQL_FN_NUM_MOD' 'SQL_FN_NUM_SIGN' 'SQL_FN_NUM_SIN' 'SQL_FN_NUM_SQRT' 'SQL_FN_NUM_TAN' 'SQL_FN_NUM_PI' 'SQL_FN_NUM_RAND')
		select: [:maskName | (mask bitAnd: (ODBCConstants bindingOf: maskName) value) ~= 0]
]

{ #category : #enquiries }
ODBCConnection >> odbcConformance [
	"Answer the level of ODBC conformance:
		0	- none
		1	- Level 1
		2	- Level 2
	Note this info type is deprecated in ODBC 3.0"

	^self getSQLUSmallIntInfo: SQL_ODBC_API_CONFORMANCE
]

{ #category : #enquiries }
ODBCConnection >> odbcSQLConformance [
	"Answer the level of ODBC SQL conformance:
		0 - core
		1 - minimum
		2 - extended.
	Note this info type is deprecated in ODBC 3.0"

	^self getSQLUSmallIntInfo: SQL_ODBC_SQL_CONFORMANCE
]

{ #category : #enquiries }
ODBCConnection >> odbcVersion [
	"Answer the ODBC version"

	^self getStringInfo: SQL_ODBC_VER
]

{ #category : #operations }
ODBCConnection >> open [

	| tmp2 tmp3 tmp4 |
	handle isNull ifFalse: [ ^ self ].
	[
	| tmp5 |
	tmp2 := self stringEncoder byteSizeForCharacters: 1024 + 1.
	tmp3 := ExternalAddress gcallocate: tmp2.
	tmp4 := SQLSMALLINT new.
	tmp5 := ODBCLibrary default
		        sqlDriverConnect: self getHandle
		        windowHandle: SQLHANDLE new
		        inConnectionString:
		        (self stringEncoder encodeStringWithNullTerminator:
			         self connectString)
		        stringLength1: SQL_NTS
		        outConnectionString: tmp3
		        bufferLength: tmp2
		        stringLength2Ptr: tmp4
		        driverCompletion: (self useDriverCompletion
				         ifTrue: [ SQL_DRIVER_COMPLETE ]
				         ifFalse: [ SQL_DRIVER_NOPROMPT ]).
	tmp5 == SQL_NO_DATA ifTrue: [ ^ nil ].
	self dbCheckException: tmp5 ] ifCurtailed: [ self free ].
	self connectString: (self stringEncoder
			 decodeStringFrom: tmp3
			 characterCount: (tmp4 value min: tmp2))
]

{ #category : #copying }
ODBCConnection >> postCopy [
	"Apply any final flourish to the copy that may be required in order to ensure that the copy
	does not share any state with the original, apart from the elements. Answer the receiver. In
	the case of an ODBCConnection we need to ensure we don't try and share the same connection
	handle, and also any other data specific to that handle."

	super postCopy.
	handle := SQLHANDLE null.
	transaction := nil.
	self initializeStatements.
	^self
]

{ #category : #executing }
ODBCConnection >> prepare: aString [
	"Prepare the SQL in aString.
	Answer a new ODBCParameterizedStatement which is used to execute the SQL."

	^self prepare: aString cursorType: self defaultCursorType
]

{ #category : #executing }
ODBCConnection >> prepare: aString cursorType: aSymbol [
	"Prepare the SQL in the <readableString> argument, aString, into a new <ODBCParameterizedStatement>
	with the specified cursor type."

	| statement |
	statement := self newParameterizedStatement: aSymbol.
	statement prepare: aString.
	^statement
]

{ #category : #enquiries }
ODBCConnection >> primaryKeysOf: aString [
	"Answer a list of the primary key column names in the
	table named aString"

	| stmt answer |
	stmt := ODBCPrimaryKeysStatement parent: self.
	stmt tableName: aString.
	answer := stmt results
				collect: [:each | each atIndex: 4	"at: 'column_name'"].
	stmt free.
	^answer
]

{ #category : #printing }
ODBCConnection >> printOn: aStream [
	"Append the ASCII representation of the receiver
	 to aStream."

	super printOn: aStream.
	aStream nextPut: $(.
	self dsn printOn: aStream.
	aStream nextPut: $)
]

{ #category : #enquiries }
ODBCConnection >> procedure: aStringQual owner: aStringOwner name: aStringName [
	"Answer a list of procedures in the table(s) matching
	the specified criteria"

	| stmt answer |
	stmt := ODBCProceduresStatement parent: self.
	stmt
		catalogName: aStringQual;
		schemaName: aStringOwner;
		procedureName: aStringName.
	answer := stmt results collect: [:each | each atIndex: 3].
	stmt free.
	^answer
]

{ #category : #enquiries }
ODBCConnection >> procedureTerm [
	"Answer the <readableString> name for a 'stored-procedure' in the parlance of the DBMS to which the
	receiver is connected, e.g. in the case of Access this is 'QUERY'."

	^self getStringInfo: SQL_PROCEDURE_TERM
]

{ #category : #enquiries }
ODBCConnection >> procedures [
	"Answer a <collection> of the <readableString> names of all the stored procedures in
	the database."

	^self procedure: nil owner: nil name: nil
]

{ #category : #accessing }
ODBCConnection >> pwd [
	"Answer the password for the receiver"

	^pwd
]

{ #category : #accessing }
ODBCConnection >> pwd: aString [
	"Set the password for the receiver to aString"

	connectString := nil.
	pwd := aString
]

{ #category : #executing }
ODBCConnection >> query: aString [
	"Execute the SQL in aString.
	Answer an <ODBCResultSet> representing the resultant result set."

	^self query: aString cursorType: self defaultCursorType
]

{ #category : #executing }
ODBCConnection >> query: aString cursorType: aSymbol [
	^(self exec: aString cursorType: aSymbol) results
]

{ #category : #executing }
ODBCConnection >> query: aString forwardOnly: aBoolean [
	"Execute the SQL in aString.
	Answer an <ODBCResultSet> representing the results.
	If the <boolean> argument is true then the result set will
	support forward-only navigation, but will be substantially
	faster in consequence, however it will tie up the entire
	connection until it is closed."

	^self query: aString
		cursorType: (aBoolean ifTrue: [#forwardOnly] ifFalse: [#keysetDriven])
]

{ #category : #enquiries }
ODBCConnection >> queryForeignKeysOf: aTableNameString [
	"Private - Answer the DBResultSet for the standard query SQLForeignKeys()
	where szFkTableName is set to aTableNameString."

	| stmt answer |
	stmt := ODBCForeignKeysStatement parent: self.
	stmt foreignTableName: aTableNameString.
	answer := stmt results asArray.
	stmt free.
	^answer
]

{ #category : #transactions }
ODBCConnection >> rollbackTxn [
	"Rollback the receiver's transaction. Raise an error if there is no outstanding transaction."

	self transaction rollback.
	transaction := nil
]

{ #category : #enquiries }
ODBCConnection >> rowIdColumns: aString [
	"Answer the names of the columns constituting the 'best row ID' in the
	table named by the <String> argument."

	^self
		specialColumns: SQL_BEST_ROWID
		qualifier: nil
		owner: nil
		name: aString
		scope: SQL_SCOPE_CURROW
		nullable: true	"Transaction"
]

{ #category : #enquiries }
ODBCConnection >> rowVersionColumns: aStringTableName [
	"Answer the names of the columns (if any) in the named table which are updated automatically
	by the datasource when a row is updated by any transaction (e.g. a timestamp)."

	^self
		specialColumns: SQL_ROWVER
		qualifier: nil
		owner: nil
		name: aStringTableName
		scope: SQL_SCOPE_CURROW
		nullable: true	"Transaction"
]

{ #category : #enquiries }
ODBCConnection >> schemaTerm [
	"Answer the <readableString> name for a 'schema' in the parlance of the DBMS to which the
	receiver is connected."

	^self getStringInfo: SQL_SCHEMA_TERM
]

{ #category : #enquiries }
ODBCConnection >> searchPatternEscape [
	"Answer the search pattern escape character"

	^self getStringInfo: SQL_SEARCH_PATTERN_ESCAPE
]

{ #category : #enquiries }
ODBCConnection >> serverName [
	"Answer the server name"

	^self getStringInfo: SQL_SERVER_NAME
]

{ #category : #accessing }
ODBCConnection >> setAttribute: idInteger value: anIntegerOrStringOrBytes size: sizeInteger [
	"Private - Set the an attribute of the receiver's connection."

	| ret |
	ret := ODBCLibrary default
				sqlSetConnectAttr: self asParameter
				attribute: idInteger
				valuePtr: anIntegerOrStringOrBytes asSQLPOINTER
				stringLength: sizeInteger.
	self dbCheckException: ret
]

{ #category : #helpers }
ODBCConnection >> setDefaultAttributes [
	"Private - Set the default connection attributes."

	self
		setAttribute: SQL_ATTR_ODBC_CURSORS
		value: SQL_CUR_USE_IF_NEEDED
		size: SQL_IS_UINTEGER
]

{ #category : #enquiries }
ODBCConnection >> specialColumns: anIntegerType qualifier: aStringQual owner: aStringOwner name: aStringName scope: anIntegerScope nullable: aBoolean [
	"Answer a <collection> of the <readableString> names of special
	columns matching the specified criteria."

	| stmt answer |
	stmt := ODBCSpecialColumnsStatement parent: self.
	stmt
		columnType: anIntegerType;
		catalogName: aStringQual;
		schemaName: aStringOwner;
		tableName: aStringName;
		scope: anIntegerScope;
		nullable: aBoolean.
	answer := Set new.
	stmt results do: [:each | answer add: (each atIndex: 2)].
	stmt free.
	^answer
]

{ #category : #accessing }
ODBCConnection >> statements [
	"Answer a set of active statements"

	^statements
]

{ #category : #enquiries }
ODBCConnection >> statisticsFor: aString type: anInteger accurate: aBoolean [
	"Answer a collection of statistics for the table with aString name and anInteger type"

	| stmt answer |
	stmt := ODBCStatisticsStatement parent: self.
	stmt
		tableName: aString;
		type: anInteger;
		accurate: aBoolean.
	answer := stmt results asOrderedCollection.
	stmt free.
	^answer
]

{ #category : #accessing }
ODBCConnection >> stringEncoder [

	^self class stringEncoder
]

{ #category : #enquiries }
ODBCConnection >> stringFunctions [
	"Answer an array of string functions supported"

	| mask |
	mask := self getSQLUIntegerInfo: SQL_STRING_FUNCTIONS.
	^#('SQL_FN_STR_ASCII' 'SQL_FN_STR_CHAR' 'SQL_FN_STR_CONCAT' 'SQL_FN_STR_INSERT' 'SQL_FN_STR_LCASE' 'SQL_FN_STR_LEFT' 'SQL_FN_STR_LENGTH' 'SQL_FN_STR_LOCATE' 'SQL_FN_STR_LTRIM' 'SQL_FN_STR_REPEAT' 'SQL_FN_STR_REPLACE' 'SQL_FN_STR_RIGHT' 'SQL_FN_STR_RTRIM' 'SQL_FN_STR_SUBSTRING' 'SQL_FN_STR_UCASE')
		select: [:maskName | (mask bitAnd: (ODBCConstants bindingOf: maskName) value) ~= 0]
]

{ #category : #enquiries }
ODBCConnection >> supportedCursorTypes [
	"Answer a <collection> of <Symbol>s, being the cursor types supported by the database to
	which the receiver is connected."

	| mask |
	mask := self getSQLUIntegerInfo: SQL_SCROLL_OPTIONS.
	^self decodeBitMask: mask map: ScrollTypes
]

{ #category : #enquiries }
ODBCConnection >> supportedTransactionIsolationLevels [
	"Answer a <collection> of the <Symbol>ic names of the transaction isolation levels
	supported by this connection."

	| mask answer |
	mask := self getSQLUIntegerInfo: SQL_TXN_ISOLATION_OPTION.
	answer := OrderedCollection new.
	TxnIsolationLevels
		keysAndValuesDo: [:eachKey :eachValue | (mask allMask: eachKey) ifTrue: [answer addLast: eachValue]].
	^answer
]

{ #category : #enquiries }
ODBCConnection >> supportsExpressionsInOrderBy [
	"Answers whether the receiver supports expressions in a ORDER BY list"

	^self getBoolInfo: SQL_EXPRESSIONS_IN_ORDERBY
]

{ #category : #enquiries }
ODBCConnection >> supportsMultipleActiveTransactions [
	"Answer whether multiple active transactions are supported."

	^self getBoolInfo: SQL_MULTIPLE_ACTIVE_TXN
]

{ #category : #enquiries }
ODBCConnection >> supportsMultipleResultSets [
	"Answer whether multiple result sets are supported."

	^self getBoolInfo: SQL_MULT_RESULT_SETS
]

{ #category : #enquiries }
ODBCConnection >> supportsOuterJoins [
	"Answer whether the receiver supports outer joins."

	^self getBoolInfo: SQL_OUTER_JOINS
]

{ #category : #enquiries }
ODBCConnection >> supportsRowUpdates [
	"Answer whether the DBMS to which the receiver is connected supports row updates."

	^self getBoolInfo: SQL_ROW_UPDATES
]

{ #category : #enquiries }
ODBCConnection >> systemFunctions [
	"Answer an array of system functions supported"

	| mask |
	mask := self getSQLUIntegerInfo: SQL_SYSTEM_FUNCTIONS.
	^#('SQL_FN_SYS_DBNAME' 'SQL_FN_SYS_IFNULL' 'SQL_FN_SYS_USERNAME')
		select: [:maskName | (mask bitAnd: (ODBCConstants bindingOf: maskName) value) ~= 0]
]

{ #category : #enquiries }
ODBCConnection >> tableTerm [
	"Answer the underlying vendor name for a table"

	^self getStringInfo: SQL_TABLE_TERM
]

{ #category : #enquiries }
ODBCConnection >> tables [
	"Answer a collection of all user tables on the database"

	^self tables: nil owners: nil tables: nil types: '''TABLE'''
]

{ #category : #enquiries }
ODBCConnection >> tables: aStringQualifier owners: aStringOwners tables: aStringTables types: aStringTypes [
	"Answer a <collection> of the <readableString> names of the tables in
	the connected data source that match the specified criteria."

	| stmt answer |
	stmt := ODBCTablesStatement parent: self.
	stmt
		catalogName: aStringQualifier;
		schemaName: aStringOwners;
		tableName: aStringTables;
		tableType: aStringTypes.
	answer := stmt results collect: [:each | each atIndex: 3	"at: 'TABLE_NAME'"].
	stmt free.
	^answer
]

{ #category : #enquiries }
ODBCConnection >> timeDateFunctions [
	"Answer an array of available date and time functions"

	| mask |
	mask := self getSQLUIntegerInfo: SQL_TIMEDATE_FUNCTIONS.
	^#('SQL_FN_TD_NOW' 'SQL_FN_TD_CURDATE' 'SQL_FN_TD_DAYOFMONTH' 'SQL_FN_TD_DAYOFWEEK' 'SQL_FN_TD_DAYOFYEAR' 'SQL_FN_TD_MONTH' 'SQL_FN_TD_QUARTER' 'SQL_FN_TD_WEEK' 'SQL_FN_TD_YEAR' 'SQL_FN_TD_CURTIME' 'SQL_FN_TD_HOUR' 'SQL_FN_TD_MINUTE' 'SQL_FN_TD_SECOND')
		select: [:maskName | (mask bitAnd: (ODBCConstants bindingOf: maskName) value) ~= 0]
]

{ #category : #accessing }
ODBCConnection >> traceFile [
	"Answer a String containing the value of the receiver's trace file option."

	^self getStringAttribute: SQL_ATTR_TRACEFILE
]

{ #category : #accessing }
ODBCConnection >> traceFile: aString [
	"Set the receiver's trace facility on, outputting to the trace file specified by aString."

	self
		setAttribute: SQL_ATTR_TRACEFILE
		value: (self stringEncoder encodeStringWithNullTerminator: aString)
		size: SQL_NTS.

	self isTracing: true
]

{ #category : #transactions }
ODBCConnection >> transaction [
	"Answer the outstanding ODBCTnn. Throw an exception if there isn't one."

	transaction isNil
		ifTrue: [self error: self printString, ' has no active transaction.'].
	^transaction
]

{ #category : #transactions }
ODBCConnection >> transaction: anODBCTxn [
	"Private - Set the receiver's transaction to anODBCTxn. Throw an exception if one exists already."

	transaction notNil
		ifTrue: [self error: self printString , ' already has an active transaction'].
	transaction := anODBCTxn.
	self willAutoCommit: transaction isNil
]

{ #category : #accessing }
ODBCConnection >> transactionIsolation [
	"Answer the receiver's Transaction Isolation Level."

	^TxnIsolationLevels at: (self getSQLUIntegerAttribute: SQL_ATTR_TXN_ISOLATION)
]

{ #category : #accessing }
ODBCConnection >> transactionIsolation: aSymbol [
	"Set the receiver's transaction isolation level to that named by the <Symbol> argument
	(one of #readUncommitted, #readCommitted, #repeatableRead, or #serializable)."

	self
		setAttribute: SQL_ATTR_TXN_ISOLATION
		value: (TxnIsolationLevels keyAtValue: aSymbol)
		size: SQL_IS_UINTEGER
]

{ #category : #accessing }
ODBCConnection >> translate [
	"Answer an Integer containing the the value of receiver's Translate option."

	^self getSQLUIntegerAttribute: SQL_ATTR_TRANSLATE_OPTION
]

{ #category : #accessing }
ODBCConnection >> translate: anInteger [
	"Set the receiver's translate option to anInteger."

	self
		setAttribute: SQL_ATTR_TRANSLATE_OPTION
		value: anInteger
		size: SQL_IS_UINTEGER
]

{ #category : #accessing }
ODBCConnection >> translationDLL [
	"Answer a String containing the value of the receiver's translate DLL option."

	^self getStringAttribute: SQL_ATTR_TRANSLATE_LIB
]

{ #category : #accessing }
ODBCConnection >> translationDLL: aString [
	"Set the receiver's translate DLL option to aString."

	self
		setAttribute: SQL_ATTR_TRANSLATE_LIB
		value: (self stringEncoder encodeStringWithNullTerminator: aString)
		size: SQL_NTS
]

{ #category : #accessing }
ODBCConnection >> uid [
	"Answer the user identifier for the receiver"

	^uid
]

{ #category : #accessing }
ODBCConnection >> uid: aString [
	"Set the user identifier for the receiver to aString."

	connectString := nil.
	uid := aString
]

{ #category : #enquiries }
ODBCConnection >> uniqueIndicesOf: aString [
	"Answer the a <collection> of <DBRows> being details of the unique indices for the
	table with the specified <readableString> name."

	^self
		statisticsFor: aString
		type: SQL_INDEX_UNIQUE
		accurate: true
]

{ #category : #accessing }
ODBCConnection >> useDriverCompletion [
	^flags allMask: DriverCompleteMask
]

{ #category : #accessing }
ODBCConnection >> useDriverCompletion: aBoolean [
	"Enable/disable the user of the SQL_DRIVER_COMPLETE option when opening this connection."

	flags := (aBoolean ifTrue: [flags bitOr: DriverCompleteMask] ifFalse: [flags bitClear: DriverCompleteMask])
]

{ #category : #enquiries }
ODBCConnection >> userName [
	"Answer the underlying user name for the receiver"

	^self getStringInfo: SQL_USER_NAME
]

{ #category : #enquiries }
ODBCConnection >> views [
	"Answer a collection of all user tables on the database"

	^self tables: nil owners: nil tables: nil types: '''VIEW'''
]

{ #category : #testing }
ODBCConnection >> willAutoCommit [
	"Answer whether the receiver's auto commit option is set."

	^(self getSQLUIntegerAttribute: SQL_ATTR_AUTOCOMMIT) = SQL_AUTOCOMMIT_ON
]

{ #category : #accessing }
ODBCConnection >> willAutoCommit: aBoolean [
	"Set whether the receiver's auto commit option is on or off."

	self
		setAttribute: SQL_ATTR_AUTOCOMMIT
		value: (aBoolean ifTrue: [SQL_AUTOCOMMIT_ON] ifFalse: [SQL_AUTOCOMMIT_OFF])
		size: SQL_IS_UINTEGER
]
