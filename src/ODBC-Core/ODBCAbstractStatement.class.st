"
An ODBCAbstractStatements represent commands that can be executed by against a <ODBCConnection>. ODBCAbstractStatement is itself abstract. Its most commonly used concrete subclass is <ODBCStatement>, which can be used to execute SQL statements. Other subclasses represent individual queries that can be performed against the metadata in the database schema using the specific functions provided for this purpose in ODBC. Whatever the form of the command the subclass of statement represents, all yield a <ODBCResultSet>.

Instance Variables:
	handle		<ExternalHandle>. ODBC statement handle.
	parent		<ODBCConnection>. The connection on which the statement was (or will be) executed
	executed		<Boolean>. Indicates if the command has been executed yet.
	cursorType	<Symbol>. The symbolic name of the cursor type, e.g. #forwardOnly
			
Based on DBAbstractStatement from Dolphin Smalltalk Database Connection package.
"
Class {
	#name : #ODBCAbstractStatement,
	#superclass : #Object,
	#instVars : [
		'handle',
		'parent',
		'executed',
		'cursorType'
	],
	#classVars : [
		'CursorTypes'
	],
	#pools : [
		'ODBCConstants',
		'ODBCRetCodes'
	],
	#category : #'ODBC-Core-Base'
}

{ #category : #'class initialization' }
ODBCAbstractStatement class >> initialize [
	"
		self initialize
	"

	CursorTypes := IdentityDictionary new.
	CursorTypes
		at: #static put: SQL_CURSOR_STATIC;
		at: #forwardOnly put: SQL_CURSOR_FORWARD_ONLY;
		at: #keysetDriven put: SQL_CURSOR_KEYSET_DRIVEN;
		at: #dynamic put: SQL_CURSOR_DYNAMIC
]

{ #category : #testing }
ODBCAbstractStatement class >> isAbstract [

	^self == ODBCAbstractStatement
]

{ #category : #'instance creation' }
ODBCAbstractStatement class >> new [
	"Private - Should not implement. Use #parent:"

	^self shouldNotImplement
]

{ #category : #'instance creation' }
ODBCAbstractStatement class >> parent: anODBCConnection [
	"Answer an initialized instance of the receiver."

	^super new
		initialize: anODBCConnection;
		yourself
]

{ #category : #'instance creation' }
ODBCAbstractStatement class >> parent: anODBCConnection cursorType: aSymbol [
	"Answer an initialized instance of the receiver."

	^(self parent: anODBCConnection)
		cursorType: aSymbol;
		yourself
]

{ #category : #accessing }
ODBCAbstractStatement >> allocatedHandle [
	"Private - Answer the receiver's ODBC statement handle, which is lazily
	allocated if necessary."

	handle isNull
		ifTrue:
			[executed := false.
			parent allocStmtHandle: self.
			self setDefaultAttributes].
	^handle
]

{ #category : #accessing }
ODBCAbstractStatement >> asParameter [
	"Answer the receiver in a form suitable for passing to an external function
	primitive method (see ExternalLibrary and subclasses)."

	^self executedHandle
]

{ #category : #accessing }
ODBCAbstractStatement >> assignHandle: aSQLHANDLE [

	handle := aSQLHANDLE
]

{ #category : #'realizing/unrealizing' }
ODBCAbstractStatement >> basicFree [
	"Private - Free up all ODBC resources."

	parent freeStmtHandle: self
]

{ #category : #operations }
ODBCAbstractStatement >> cancel [
	"Cancel any outstanding asynchronous request."

	executed
		ifTrue:
			[handle isNull
				ifTrue: [executed := false]
				ifFalse: [self dbCheckException: (ODBCLibrary default sqlCancel: handle)]]
]

{ #category : #operations }
ODBCAbstractStatement >> close [
	"Private - Close the cursor, but keep the handle.
	Implementation Note: Use SQLFreeStmt(,SQL_CLOSE), rather than SQLCloseCursor, since the latter
	treats the cursor not actually being open as an error condition, and we don't care about that."

	executed
		ifTrue:
			[executed := false.
			handle isNull
				ifFalse:
					[self
						dbCheckException: (ODBCLibrary default sqlFreeStmt: handle option: SQL_CLOSE)]]
]

{ #category : #accessing }
ODBCAbstractStatement >> columnLength: anInteger [
	"Answer the length (bytes) of column number anInteger in the Result Set."

	| ret len |

	len := SQLLEN new.
	ret := ODBCLibrary default
				sqlColAttribute: self executedHandle
				columnNumber: anInteger
				fieldIdentifier: SQL_COLUMN_LENGTH	"Note using ODBC 2.x definition of column length"
				characterAttributePtr: nil
				bufferLength: 0
				stringLengthPtr: nil
				numericAttributePtr: len.
	self dbCheckException: ret.
	^len value
]

{ #category : #accessing }
ODBCAbstractStatement >> cursorType [
	"Answer the symbolic cursor type name (one of #dynamic, #forwardOnly, #keysetDriven or #static)."

	^cursorType
]

{ #category : #accessing }
ODBCAbstractStatement >> cursorType: aSymbol [

	(CursorTypes includesKey: aSymbol)
		ifFalse: [self error: 'Invalid cursor type ' , aSymbol].
	cursorType := aSymbol.
	"Attempting to change the cursorType once the statement has been executed will raise an error"
	handle isNull ifFalse: [self setCursorType]
]

{ #category : #exceptions }
ODBCAbstractStatement >> dbCheckException: anIntegerRetCode [
	"Private - Checks anIntegerRetCode to see if an ODBCError or ODBCWarning should be 	signalled"

	^anIntegerRetCode = SQL_SUCCESS
		ifFalse:
			["Signal an error or warning - decide which"

			((anIntegerRetCode = SQL_SUCCESS_WITH_INFO or: [anIntegerRetCode = SQL_NO_DATA])
				ifTrue: [ODBCWarning]
				ifFalse: [ODBCError]) signalWith: (self exceptionDetails: anIntegerRetCode)]
]

{ #category : #constants }
ODBCAbstractStatement >> defaultCursorType [
	"Answer the <Symbol>ic name of the default cursor type to be used for statements
	(one of #dynamic, #forwardOnly, #keysetDriven, #static)."

	^self subclassResponsibility
]

{ #category : #accessing }
ODBCAbstractStatement >> describeCol: anInteger [
	"Answer an ODBCColAttr object which describes the column with the specified
	<integer> index in the receiver's result set."

	^(self describeCols: (Array with: anInteger)) first
]

{ #category : #accessing }
ODBCAbstractStatement >> describeCols: columnNumbers [
	"Answer an array of <ODBCColAttr>s describing each of the columns of the receiver's results with indices in the <sequencedReadableCollection> argument."

	| answer i name columnSize colNameLen dataType decimalDigits nullable nameBufSize hStmt colLen lib |
	"Allocate a buffer sufficient to hold any column name, that we will re-use for all the columns"
	nameBufSize := self parent maxColumnNameLength + 1.
	name := ExternalAddress gcallocate: (self stringEncoder byteSizeForCharacters: nameBufSize).
	"Similarly, re-usable buffers for all the other output parameters"
	colNameLen := SQLSMALLINT new.
	dataType := SQLSMALLINT new.
	columnSize := SQLULEN new.
	decimalDigits := SQLSMALLINT new.
	nullable := SQLSMALLINT new.
	colLen := SQLUINTEGER new.
	hStmt := self executedHandle.
	lib := ODBCLibrary default.
	answer := Array new: columnNumbers size.
	i := 1.
	columnNumbers do:
			[:each |
			| ret col |
			ret := lib
						sqlDescribeCol: hStmt
						columnNumber: each
						columnName: name
						bufferLength: nameBufSize
						nameLengthPtr: colNameLen
						dataTypePtr: dataType
						columnSizePtr: columnSize
						decimalDigitsPtr: decimalDigits
						nullablePtr: nullable.
			self dbCheckException: ret.

			col := ODBCColAttr new
					columnNumber: each;
					name: (self stringEncoder decodeStringFrom: name characterCount: colNameLen value);
					type: dataType value;
					precision: columnSize value;
					scale: decimalDigits value;
					yourself.

			col hasVariableTransferOctetLength
				ifTrue:
					["Error handling for iODBC/Mac - SQL_DESC_OCTET_LENGTH gives invalid identifier (HY091) error;
					retry with SQL_DESC_LENGTH which appears to be equivalent for this manager/platform"
					[ret := lib
							sqlColAttribute: hStmt
							columnNumber: each
							fieldIdentifier: parent columnFieldIdentifier
							characterAttributePtr: nil
							bufferLength: 0
							stringLengthPtr: nil
							numericAttributePtr: colLen.
					self dbCheckException: ret] on: ODBCError do:
						[ :exc |
						(parent columnFieldIdentifier = SQL_DESC_OCTET_LENGTH and: [ exc tag errors anySatisfy: [ :err | err sqlState = 'HY091'] ])
							ifTrue: [parent columnFieldIdentifier: SQL_DESC_LENGTH. exc retry]
							ifFalse: [exc pass]].
					col length: colLen value]
				ifFalse:
					[col length: col transferOctetLength].
			answer at: i put: col.
			i := i + 1].
	^answer
]

{ #category : #accessing }
ODBCAbstractStatement >> driverHStmt [
	"Private - Answer the handle to the driver statement"

	| value |
	value := SQLHANDLE new.
	self dbCheckException: (ODBCLibrary default
				sqlGetInfo: self asParameter
				infoType: SQL_DRIVER_HSTMT
				infoValueHandle: value
				bufferLength: SQLHANDLE byteSize
				stringLengthPtr: nil).
	^value
]

{ #category : #exceptions }
ODBCAbstractStatement >> exceptionDetails: anIntegerRetCode [
	"Private - Answer an ODBCExceptionDetails instance that describes the state of the
	receiver following an exception. This will be available as the tag of a subsequent
	signalled ODBCError or ODBCWarning."

	^(self parent exceptionDetails: anIntegerRetCode)
		hStmt: handle;
		yourself
]

{ #category : #operations }
ODBCAbstractStatement >> exec [
	"Private - Execute the tables query the receiver represents."

	self dbCheckException: self executeStatement.
	executed := true
]

{ #category : #operations }
ODBCAbstractStatement >> executeStatement [
	"Private - Execute the database command that the receiver represents.
	Answer the <integer> return code."

	^self subclassResponsibility
]

{ #category : #accessing }
ODBCAbstractStatement >> executedHandle [
	"Private - Answer the receiver's ODBC statement handle having lazily
	executed the SQL statement associated with the receiver."

	| answer |
	answer := self allocatedHandle.
	executed ifFalse: [self exec].
	^answer
]

{ #category : #accessing }
ODBCAbstractStatement >> finalizationRegistry [
	"Use the parent's statements WeakRegistry"

	^parent statements
]

{ #category : #finalizing }
ODBCAbstractStatement >> finalize [
	"Private - Free any external resources held by the receiver.
	Should any error occur we print it to trace but otherwise ignore it."

	[self free] on: ODBCError do: [ :e | e trace]
]

{ #category : #'realizing/unrealizing' }
ODBCAbstractStatement >> free [
	"Free up all resources leaving the receiver in a re-usable state."

	handle isNull ifFalse: [[self basicFree] ensure: [self reset]]
]

{ #category : #accessing }
ODBCAbstractStatement >> getStringAttribute: anInteger [
	"Private - Answer a <String> containing the value of the statement attribute identified by the <integer> argument."

	| bufferLen buffer |
	bufferLen := self stringEncoder byteSizeForCharacters: SQL_MAX_OPTION_STRING_LENGTH + 1.
	buffer := ExternalAddress allocate: bufferLen.
	^[self dbCheckException: (ODBCLibrary default
				sqlGetStmtAttr: self allocatedHandle
				attribute: anInteger
				valuePtr: buffer
				bufferLength: bufferLen "Byte size including implicit null terminator"
				stringLengthPtr: nil).
	"N.B. We assume that as with SqlGetConnectAttr that the SQL server driver will not populate the stringLengthPtr argument. There do not seem to be any string options to test this against currently."
	self stringEncoder decodeNullTerminatedStringFrom: buffer] ensure: [ buffer free ]
]

{ #category : #accessing }
ODBCAbstractStatement >> handle [

	^handle
]

{ #category : #initializing }
ODBCAbstractStatement >> initialize [
	"Private - Initialize a new instance of the receiver."

	self reset.
	cursorType := self defaultCursorType
]

{ #category : #initializing }
ODBCAbstractStatement >> initialize: anODBCConnection [
	"Private - Initialize the receiver as a new statement of the
	<ODBCConnection>, anODBCConnection."

	parent := anODBCConnection.
	self initialize
]

{ #category : #accessing }
ODBCAbstractStatement >> moveTo: anIntegerRow [
	"Private - Position the cursor at the specified
	row so that it is read on a subsequent Fetch (requires
	extended fetch)"

	self dbCheckException: (ODBCLibrary default
				sqlSetPos: self executedHandle
				rowNumber: anIntegerRow
				operation: SQL_POSITION
				lockType: SQL_LOCK_NO_CHANGE)
]

{ #category : #accessing }
ODBCAbstractStatement >> numColumns [
	"Answer the number of columns in the receiver's result set."

	| ccol ret |
	ccol := SQLSMALLINT new.
	ret := ODBCLibrary default
		sqlNumResultCols: self executedHandle
		pccol: ccol.
	self dbCheckException: ret.
	^ccol value
]

{ #category : #accessing }
ODBCAbstractStatement >> numRows [
	"Answer the number of rows affected by an UPDATE, DELETE or INSERT command exec'd on
	the receiver. May also work for some SELECTs, although often the answer will be -1
	indicating that the driver does not know."

	| rowCount ret |
	rowCount := SQLLEN new.
	ret := ODBCLibrary default sqlRowCount: self executedHandle
				rowCountPtr: rowCount.
	self dbCheckException: ret.
	^rowCount value
]

{ #category : #accessing }
ODBCAbstractStatement >> parent [
	"Answer the statement's parent <ODBCConnection> object."

	^parent
]

{ #category : #initializing }
ODBCAbstractStatement >> reset [
	handle := SQLHANDLE null.
	executed := false
]

{ #category : #accessing }
ODBCAbstractStatement >> results [
	"Answer an <ODBCResultSet> that manages the results for the receiver.
	The result set will cause the receiver to be lazily executed when
	any attempt is made to access its contents."

	^(self cursorType == #forwardOnly
		ifTrue: [ODBCForwardOnlyResultSet]
		ifFalse: [ODBCResultSet]) statement: self
]

{ #category : #accessing }
ODBCAbstractStatement >> setAttribute: attributeInteger value: anIntegerOrStringOrBytes size: sizeInteger [
	| ret |
	ret := ODBCLibrary default
				sqlSetStmtAttr: self allocatedHandle
				attribute: attributeInteger
				valuePtr: anIntegerOrStringOrBytes asSQLPOINTER
				stringLength: sizeInteger.
	self dbCheckException: ret
]

{ #category : #helpers }
ODBCAbstractStatement >> setCursorType [
	"Private - Set the cursor type of the statement to one of: #static, #dynamic, #keysetDriven or #forwardOnly.
	See the ODBC documentation for details of the different cursor types."

	^self
		setAttribute: SQL_ATTR_CURSOR_TYPE
		value: (CursorTypes at: self cursorType)
		size: SQL_IS_UINTEGER
]

{ #category : #initializing }
ODBCAbstractStatement >> setDefaultAttributes [
	"Private - Set the default attributes of the statement that need to be set before the statement is prepared."

	self suppressErrorsDo: [self setCursorType]
]

{ #category : #accessing }
ODBCAbstractStatement >> statusArray: anArrayOfWORDs [
	"Private - Set the argument to be the receiver's status array attribute."

	self
		setAttribute: SQL_ATTR_ROW_STATUS_PTR
		value: anArrayOfWORDs
		size: SQL_IS_POINTER
]

{ #category : #accessing }
ODBCAbstractStatement >> stringEncoder [

	^ODBCConnection stringEncoder
]

{ #category : #accessing }
ODBCAbstractStatement >> suppressErrorsDo: aNiladicBlock [
	aNiladicBlock on: ODBCError do: [:e | e trace]
]
