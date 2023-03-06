"
An instance of ODBCExceptionDetails holds information about the state of a DB connection object when a ODBCError or ODBCWarning is signalled. It is available by sending #tag to the exception object. 

Instance Variables:
	errors		<Array> of <ODBCErrorDetails>. List of errors
	hEnv		<ExternalHandle>. ODBC environment handle.
	hDBC		<ExternalHandle>. ODBC database connection handle.
	hStmt		<ExternalHandle>. ODBC statement handl.
	code		<integer>. The SQL function error or warning code

Depending on the activity in progress at the time of the exception, one or more of these may contain nil.

Based on DBExceptionDetails from Dolphin Smalltalk Database Connection package.
"
Class {
	#name : #ODBCExceptionDetails,
	#superclass : #Object,
	#instVars : [
		'errors',
		'hEnv',
		'hDBC',
		'hStmt',
		'code',
		'stringEncoder'
	],
	#pools : [
		'ODBCConstants',
		'ODBCRetCodes'
	],
	#category : #'ODBC-Core-Base'
}

{ #category : #operations }
ODBCExceptionDetails >> addErrorDetails: newErrorDetails [
	"Private - Add a new error details object to my collection."

	errors ifNil: [ self errors: OrderedCollection new ].
	errors addLast: newErrorDetails
]

{ #category : #operations }
ODBCExceptionDetails >> buildErrorInfo [
	"Private - Retrieve all error information available from the ODBC Driver
	 for my handles, unless none is found in which case
	 a 'reduced' error is created using the return code from function
	 which caused the error"

	(code ~~ SQL_SUCCESS and: [code ~~ SQL_INVALID_HANDLE]) ifTrue:
			[hEnv isNull ifFalse: [self buildErrorInfoFrom: hEnv type: SQL_HANDLE_ENV].
			hDBC isNull ifFalse: [self buildErrorInfoFrom: hDBC type: SQL_HANDLE_DBC].
			hStmt isNull ifFalse: [self buildErrorInfoFrom: hStmt type: SQL_HANDLE_STMT]].
	errors ifNil: [self retCodeError: code]
]

{ #category : #operations }
ODBCExceptionDetails >> buildErrorInfoFrom: anExternalHandle type: anIntegerHandleType [
	"Private - Retrieve all error information available from the ODBC Driver for <anExternalHandle>, which is of type <anIntegerHandleType>"

	| szSqlState fNativeError szErrorMsgSize szErrorMsg cbErrorMsg recNumber odbc |
	szSqlState := ExternalAddress gcallocate: (self stringEncoder byteSizeForCharacters: SQL_SQLSTATE_SIZE).
	szErrorMsgSize := 128.
	szErrorMsg := ExternalAddress gcallocate: (self stringEncoder byteSizeForCharacters: szErrorMsgSize).
	cbErrorMsg := SQLSMALLINT new.
	fNativeError := SQLINTEGER new.
	recNumber := 1.
	odbc := ODBCLibrary default.

	[| ret |

	[ret := odbc
				sqlGetDiagRec: anIntegerHandleType
				handle: anExternalHandle
				recNumber: recNumber
				szSqlState: szSqlState
				pfNativeError: fNativeError
				szErrorMsg: szErrorMsg
				cbErrorMsgMax: szErrorMsgSize + 1
				pcbErrorMsg: cbErrorMsg.
	ret == SQL_SUCCESS_WITH_INFO]
			whileTrue:
				["Try again with a larger buffer"
				szErrorMsg := ExternalAddress gcallocate: (szErrorMsgSize := self stringEncoder byteSizeForCharacters: cbErrorMsg value)].
	ret == SQL_SUCCESS]
			whileTrue:
				[| newErr |
				newErr := ODBCErrorDetails fromSQLError: (self stringEncoder decodeStringFrom: szErrorMsg characterCount: cbErrorMsg asInteger).
				newErr
					nativeErr: fNativeError asInteger;
					sqlState: (self stringEncoder decodeStringFrom: szSqlState characterCount: 5).
				self addErrorDetails: newErr.
				recNumber := recNumber + 1]
]

{ #category : #accessing }
ODBCExceptionDetails >> code [
	"Answer the code instance variable."

	^code
]

{ #category : #accessing }
ODBCExceptionDetails >> code: anInteger [
	"Private - Set the instance variable code to anInteger."

	code := anInteger
]

{ #category : #accessing }
ODBCExceptionDetails >> errors [
	"Answer the errors instance variable."

	^errors
]

{ #category : #accessing }
ODBCExceptionDetails >> errors: anOrderedCollection [
	"Private - Set the errors instance variable to anOrderedCollection."

	errors := anOrderedCollection
]

{ #category : #accessing }
ODBCExceptionDetails >> hDBC [
	"Answer the hDBC instance variable."

	^hDBC
]

{ #category : #accessing }
ODBCExceptionDetails >> hDBC: anExternalHandle [
	"Private - Set the instance variable hDBC to anExternalHandle."

	hDBC := anExternalHandle
]

{ #category : #accessing }
ODBCExceptionDetails >> hEnv [
	"Answer the hEnv instance variable."

	^hEnv
]

{ #category : #accessing }
ODBCExceptionDetails >> hEnv: anExternalHandle [
	"Private - Set the instance variable hEnv to anExternalHandle."

	hEnv := anExternalHandle
]

{ #category : #accessing }
ODBCExceptionDetails >> hStmt [
	"Answer the hStmt instance variable."

	^hStmt
]

{ #category : #accessing }
ODBCExceptionDetails >> hStmt: anExternalHandle [
	"Private - Set the instance variable hStmt to anExternalHandle."

	hStmt := anExternalHandle
]

{ #category : #initialization }
ODBCExceptionDetails >> initialize [

	hEnv := hDBC := hStmt := SQLHANDLE null
]

{ #category : #printing }
ODBCExceptionDetails >> printOn: aStream [
	"Print an textual representation of the receiver to aStream"

	self errors
		do: [ :e | aStream print: e messageText ]
		separatedBy: [ aStream space ]
]

{ #category : #accessing }
ODBCExceptionDetails >> retCodeError: anInteger [
	"Private - Add to our collection, a new error whose code is anIteger."

	self addErrorDetails: (
	        ODBCErrorDetails new
			msg: ('SQL Error: ',
					(ODBCRetCodes classPool keyAtValue: code
				                ifAbsent: ['Unknown']));
			yourself)
]

{ #category : #accessing }
ODBCExceptionDetails >> stringEncoder [

	^ stringEncoder
]

{ #category : #accessing }
ODBCExceptionDetails >> stringEncoder: anObject [

	stringEncoder := anObject
]
