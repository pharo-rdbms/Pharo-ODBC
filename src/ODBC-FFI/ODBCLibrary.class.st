"
This is the ExternalLibrary class to represent the Win32 System DLL, ODBC32.DLL. 
This library contains functions pertaining to the use of Open Database Connectivity 3.0.

Type mapping:
	SQLSMALLINT	->	sword	(16-bit signed integer)
	SQLUSMALLINT	->	word	(16-bit unsigned integer)
	SQLINTEGER	->	sdword	(32-bit signed integer)
	SQLUINTEGER	->	dword	(32-bit unsigned integer).
	SQLFLOAT	-> 	double	(64-bit float)
	SQLDOUBLE	->	double	(64-bit float)
	
Note that SQLRETURN is an alias for SQLSMALLINT
"
Class {
	#name : 'ODBCLibrary',
	#superclass : 'FFILibrary',
	#classVars : [
		'SQLCHAR',
		'SQLHDBC',
		'SQLHENV',
		'SQLHSTMT',
		'SQLPOINTER',
		'SQLRETURN',
		'SQLSETPOSIROW',
		'SQLWCHAR'
	],
	#pools : [
		'ODBCConstants'
	],
	#category : 'ODBC-FFI-Library',
	#package : 'ODBC-FFI',
	#tag : 'Library'
}

{ #category : 'instance creation' }
ODBCLibrary class >> default [

	^ self uniqueInstance
]

{ #category : 'class initialization' }
ODBCLibrary class >> initialize [

	SQLRETURN := #short.

	SQLHDBC := SQLHENV := SQLHSTMT := #SQLHANDLE.

	SQLCHAR := #char.
	SQLWCHAR := #void.

	SQLPOINTER := #'void *'.

	SQLSETPOSIROW := (ExternalAddress wordSize = 4 ifTrue: [#ushort] ifFalse: [#uint64])
]

{ #category : 'accessing' }
ODBCLibrary class >> moduleName [
	"Return the name of the module for this library"
	| os |
	os := OSPlatform current.
	os isWindows ifTrue: [ ^ 'odbc32' ].
	os isMacOSX ifTrue: [ ^ 'libiodbc.dylib' ].
	^ 'libodbc.so'
]

{ #category : 'accessing - platform' }
ODBCLibrary >> macLibraryName [

	^'libiodbc.dylib'
]

{ #category : 'ffi methods' }
ODBCLibrary >> sqlAllocHandle: handleType inputHandle: inputHandle outputHandlePtr: outputHandlePtr [

	"SQLRETURN SQLAllocHandle(
      SQLSMALLINT   HandleType,
      SQLHANDLE     InputHandle,
      SQLHANDLE *   OutputHandlePtr);"

	self ffiCall: #(SQLRETURN SQLAllocHandle (SQLSMALLINT handleType, SQLHANDLE inputHandle, SQLHANDLE * outputHandlePtr))
]

{ #category : 'ffi methods' }
ODBCLibrary >> sqlBindCol: anExternalHandle columnNumber: anIntegerCol targetType: anIntegerType targetValuePtr: anExternalAddressBuf bufferLength: anIntegerMax strLenOrInd: anExternalAddressLen [
	"SQLRETURN SQLBindCol(
		SQLHSTMT     StatementHandle,
		SQLUSMALLINT     ColumnNumber,
		SQLSMALLINT     TargetType,
		SQLPOINTER     TargetValuePtr,
		SQLLEN     BufferLength,
		SQLLEN *     StrLen_or_Ind);"

	self ffiCall: #(SQLRETURN SQLBindCol (SQLHSTMT anExternalHandle, SQLUSMALLINT anIntegerCol, SQLSMALLINT anIntegerType, SQLPOINTER anExternalAddressBuf, SQLLEN anIntegerMax, SQLLEN * anExternalAddressLen))
]

{ #category : 'ffi methods' }
ODBCLibrary >> sqlBindParameter: anExternalHandle parameterNumber: parmNumInteger inputOutputType: ioInteger valueType: valueInteger parameterType: parmTypeInteger columnSize: sizeInteger decimalDigits: digitsInteger parameterValuePtr: parmBytes bufferLength: bufLenInteger strLenOrIndPtr: strLenOrIndPtr [
	"SQLRETURN SQLBindParameter(
		SQLHSTMT        StatementHandle,
      SQLUSMALLINT    ParameterNumber,
      SQLSMALLINT     InputOutputType,
      SQLSMALLINT     ValueType,
      SQLSMALLINT     ParameterType,
      SQLULEN         ColumnSize,
      SQLSMALLINT     DecimalDigits,
      SQLPOINTER      ParameterValuePtr,
      SQLLEN          BufferLength,
      SQLLEN *        StrLen_or_IndPtr)"

	self ffiCall: #(SQLRETURN SQLBindParameter (SQLHSTMT anExternalHandle, SQLUSMALLINT parmNumInteger, SQLSMALLINT ioInteger, SQLSMALLINT valueInteger, SQLSMALLINT parmTypeInteger, SQLULEN sizeInteger, SQLSMALLINT digitsInteger, SQLPOINTER parmBytes, SQLLEN bufLenInteger, SQLLEN * strLenOrIndPtr))
]

{ #category : 'ffi methods' }
ODBCLibrary >> sqlCancel: anExternalHandle [
	"SQLRETURN SQLCancel(
     SQLHSTMT     StatementHandle);"

	self ffiCall: #(SQLTRETURN SQLCancel (SQLHSTMT connectionHandle))
]

{ #category : 'ffi methods' }
ODBCLibrary >> sqlColAttribute: anExternalHandle columnNumber: columnInteger fieldIdentifier: idInteger characterAttributePtr: bytes bufferLength: sizeInteger stringLengthPtr: anSWORD numericAttributePtr: anExternalAddress [
	"SQLRETURN SQLColAttributeW (
      SQLHSTMT        StatementHandle,
      SQLUSMALLINT    ColumnNumber,
      SQLUSMALLINT    FieldIdentifier,
      SQLPOINTER      CharacterAttributePtr,
      SQLSMALLINT     BufferLength,
      SQLSMALLINT *   StringLengthPtr,
      SQLLEN *        NumericAttributePtr);  "

	self ffiCall: #(SQLRETURN SQLColAttributeW (SQLHSTMT anExternalHandle, SQLUSMALLINT columnInteger, SQLUSMALLINT idInteger, void* bytes, SQLSMALLINT sizeInteger, SQLSMALLINT * anSWORD, SQLLEN * anExternalAddress))
]

{ #category : 'ffi methods' }
ODBCLibrary >> sqlColumns: anExternalHandleSTMT catalogName: aStringParmQual nameLength1: anIntegerQualLen schemaName: aStringParmOwner nameLength2: anIntegerOwnerLen tableName: aStringParmName nameLength3: anIntegerNameLen columnName: aStringParmType nameLength4: anIntegerTypeLen [
	"SQLRETURN SQLColumnsW(
		SQLHSTMT     StatementHandle,
		SQLWCHAR *     CatalogName,
		SQLSMALLINT     NameLength1,
		SQLWCHAR *     SchemaName,
		SQLSMALLINT     NameLength2,
		SQLWCHAR *     TableName,
		SQLSMALLINT     NameLength3,
		SQLWCHAR *     ColumnName,
		SQLSMALLINT     NameLength4);"

	self ffiCall: #(SQLRETURN SQLColumnsW (SQLHSTMT anExternalHandleSTMT, SQLWCHAR * aStringParmQual, SQLSMALLINT anIntegerQualLen, SQLWCHAR * aStringParmOwner, SQLSMALLINT anIntegerOwnerLen, SQLWCHAR * aStringParmName, SQLSMALLINT anIntegerNameLen, SQLWCHAR * aStringParmType, SQLSMALLINT anIntegerTypeLen))
]

{ #category : 'ffi methods' }
ODBCLibrary >> sqlConnect: anExternalHandle serverName: dsnString nameLength1: dsnInteger userName: uidString nameLength2: uidInteger authentication: authString nameLength3: authInteger [
	"Load driver and establish connection to a data source.

	SQLRETURN SQLConnectW(
		SQLHDBC 	ConnectionHandle
		SQLWCHAR * ServerName,
		SQLSMALLINT NameLength1,
		SQLWCHAR * UserName,
		SQLSMALLINT NameLength2,
		SQLWCHAR * Authentication,
		SQLSMALLINT NameLength3);"

	self ffiCall: #(SQLRETURN SQLConnectW (SQLHDBC anExternalHandle, SQLWCHAR * dsnString, SQLSMALLINT dsnInteger, SQLWCHAR * uidString, SQLSMALLINT uidInteger, SQLWCHAR * authString, SQLSMALLINT authInteger))
]

{ #category : 'ffi methods' }
ODBCLibrary >> sqlDataSources: anExternalHandle direction: anIntegerConstant serverName: anExternalBuffer bufferLength1: anIntegerMax nameLength1Ptr: anIntegerParmLen description: anExternalBufferParm bufferLength2: anIntegerParmDMax nameLength2Ptr: anIntegerParmDLen [
	"SQLRETURN SQLDataSources(
     SQLHENV          EnvironmentHandle,
     SQLUSMALLINT     Direction,
     SQLCHAR *        ServerName,
     SQLSMALLINT      BufferLength1,
     SQLSMALLINT *    NameLength1Ptr,
     SQLCHAR *        Description,
     SQLSMALLINT      BufferLength2,
     SQLSMALLINT *    NameLength2Ptr); "

	self ffiCall: #(SQLRETURN SQLDataSourcesW (SQLHENV anExternalHandle, SQLUSMALLINT anIntegerConstant, SQLWCHAR * anExternalBuffer, SQLSMALLINT anIntegerMax, SQLSMALLINT * anIntegerParmLen, SQLWCHAR * anExternalBufferParm, SQLSMALLINT anIntegerParmDMax, SQLSMALLINT * anIntegerParmDLen))
]

{ #category : 'ffi methods' }
ODBCLibrary >> sqlDescribeCol: anExternalHandle columnNumber: columnInteger columnName: aString bufferLength: sizeInteger nameLengthPtr: maxSWORD dataTypePtr: typeSWORD columnSizePtr: precisionDWORD decimalDigitsPtr: scaleSWORD nullablePtr: nullableSWORD [
	"SQLRETURN SQLDescribeColW(
		SQLHSTMT       StatementHandle,
      SQLUSMALLINT   ColumnNumber,
      SQLWCHAR *      ColumnName,
      SQLSMALLINT    BufferLength,
      SQLSMALLINT *  NameLengthPtr,
      SQLSMALLINT *  DataTypePtr,
      SQLULEN *      ColumnSizePtr,
      SQLSMALLINT *  DecimalDigitsPtr,
      SQLSMALLINT *  NullablePtr);  "

	self ffiCall: #(SQLRETURN SQLDescribeColW (SQLHSTMT anExternalHandle, SQLUSMALLINT columnInteger, SQLWCHAR * aString, SQLSMALLINT sizeInteger, SQLSMALLINT * maxSWORD, SQLSMALLINT * typeSWORD, SQLULEN * precisionDWORD, SQLSMALLINT * scaleSWORD, SQLSMALLINT * nullableSWORD))
]

{ #category : 'ffi methods' }
ODBCLibrary >> sqlDisconnect: connectionHandle [
	"SQLRETURN SQLDisconnect(SQLHDBC ConnectionHandle);"

	self ffiCall: #(SQLRETURN SQLDisconnect (SQLHDBC connectionHandle))
]

{ #category : 'ffi methods' }
ODBCLibrary >> sqlDriverConnect: anExternalHandle windowHandle: aWinHandle inConnectionString: aStringConn stringLength1: anIntegerConn outConnectionString: aStringConnOut bufferLength: anIntegerConnOut stringLength2Ptr: anExternalShort driverCompletion: anIntegerOption [

	"SQLRETURN SQLDriverConnectW(
		SQLHDBC     ConnectionHandle,
		SQLHWND     WindowHandle,
		SQLWCHAR *     InConnectionString,
		SQLSMALLINT     StringLength1,
		SQLWCHAR *     OutConnectionString,
		SQLSMALLINT     BufferLength,
		SQLSMALLINT *     StringLength2Ptr,
		SQLUSMALLINT     DriverCompletion);"

	self ffiCall: #(SQLRETURN SQLDriverConnectW (SQLHDBC anExternalHandle, SQLHANDLE aWinHandle, SQLWCHAR * aStringConn, SQLSMALLINT anIntegerConn, SQLWCHAR * aStringConnOut, SQLSMALLINT anIntegerConnOut, SQLSMALLINT * anExternalShort, SQLUSMALLINT anIntegerOption))
]

{ #category : 'ffi methods' }
ODBCLibrary >> sqlDrivers: anExternalHandle direction: anIntegerConstant driverDescription: anExternalBuffer bufferLength1: anIntegerMax descriptionLengthPtr: anIntegerParmLen attributes: anExternalBufferParm bufferLength2: anIntegerParmDMax attributesLengthPtr: anIntegerParmDLen [

	"SQLRETURN SQLDriversW(
     SQLHENV         EnvironmentHandle,
     SQLUSMALLINT    Direction,
     SQLWCHAR *       DriverDescription,
     SQLSMALLINT     BufferLength1,
     SQLSMALLINT *   DescriptionLengthPtr,
     SQLWCHAR *       DriverAttributes,
     SQLSMALLINT     BufferLength2,
     SQLSMALLINT *   AttributesLengthPtr);  "

	self ffiCall: #(SQLRETURN SQLDriversW (SQLHENV anExternalHandle, SQLUSMALLINT anIntegerConstant, SQLWCHAR * anExternalBuffer, SQLSMALLINT anIntegerMax, SQLSMALLINT * anIntegerParmLen, SQLWCHAR * anExternalBufferParm, SQLSMALLINT anIntegerParmDMax, SQLSMALLINT * anIntegerParmDLen))
]

{ #category : 'ffi methods' }
ODBCLibrary >> sqlEndTran: type handle: aHandle completionType: completionType [
	"SQLRETURN
	SQLEndTran(
	SQLSMALLINT HandleType,
	SQLHANDLE Handle,
     SQLSMALLINT CompletionType);"

	self ffiCall: #(SQLRETURN SQLEndTran (SQLSMALLINT type, SQLHANDLE aHandle, SQLSMALLINT completionType))
]

{ #category : 'ffi methods' }
ODBCLibrary >> sqlExecDirect: anExternalHandle statementText: aString textLength: anInteger [
	"SQLRETURN SQLExecDirectW(
		SQLHSTMT StatementHandle,
		SQLWCHAR * StatementText,
		SQLINTEGER TextLength);"

	self ffiCall: #(SQLRETURN SQLExecDirectW (SQLHSTMT anExternalHandle, SQLCHAR * aString, SQLINTEGER anInteger))
]

{ #category : 'ffi methods' }
ODBCLibrary >> sqlExecute: hstmt [
	"SQLRETURN SQL_API SQLExecute(
		SQLHSTMT		hstmt);"

	self ffiCall: #(SQLRETURN SQLExecute (SQLHSTMT hstmt))
]

{ #category : 'ffi methods' }
ODBCLibrary >> sqlFetchScroll: anExternalHandle fetchOrientation: orientationInteger fetchOffset: offsetInteger [
	"SQLRETURN SQLFetchScroll(
      SQLHSTMT      StatementHandle,
      SQLSMALLINT   FetchOrientation,
      SQLLEN        FetchOffset);"

	self ffiCall: #(SQLRETURN SQLFetchScroll (SQLHSTMT anExternalHandle, SQLSMALLINT orientationInteger, SQLLEN offsetInteger))
]

{ #category : 'ffi methods' }
ODBCLibrary >> sqlForeignKeys: anExternalHandle pkCatalogName: aStringPkQual nameLength1: anIntegerPkQual pkSchemaName: aStringPkOwn nameLength2: anIntegerPkOwn pkTableName: aStringPkName nameLength3: anIntegerPkName fkCatalogName: aStringFkQual nameLength4: anIntegerFkQual fkSchemaName: aStringFkOwn nameLength5: anIntegerFkOwn fkTableName: aStringFkName nameLength6: anIntegerFkName [
	"SQLRETURN SQLForeignKeysW(
		SQLHSTMT     StatementHandle,
		SQLWCHAR *     PKCatalogName,
		SQLSMALLINT     NameLength1,
		SQLWCHAR *     PKSchemaName,
		SQLSMALLINT     NameLength2,
		SQLWCHAR *     PKTableName,
		SQLSMALLINT     NameLength3,
		SQLWCHAR *     FKCatalogName,
		SQLSMALLINT     NameLength4,
		SQLWCHAR *     FKSchemaName,
		SQLSMALLINT     NameLength5,
		SQLWCHAR *     FKTableName,
		SQLSMALLINT     NameLength6);"

	self ffiCall: #(SQLRETURN SQLForeignKeysW (SQLHSTMT anExternalHandle, SQLWCHAR * aStringPkQual, SQLSMALLINT anIntegerPkQual, SQLWCHAR * aStringPkOwn, SQLSMALLINT anIntegerPkOwn, SQLWCHAR * aStringPkName, SQLSMALLINT anIntegerPkName, SQLWCHAR * aStringFkQual, SQLSMALLINT anIntegerFkQual, SQLWCHAR * aStringFkOwn, SQLSMALLINT anIntegerFkOwn, SQLWCHAR * aStringFkName, SQLSMALLINT anIntegerFkName))
]

{ #category : 'ffi methods' }
ODBCLibrary >> sqlFreeHandle: anInteger handle: anExternalHandle [
	"SQLRETURN SQLFreeHandle(
     SQLSMALLINT   HandleType,
     SQLHANDLE     Handle);  "

	self ffiCall: #(SQLRETURN SQLFreeHandle (SQLSMALLINT anInteger, SQLHANDLE anExternalHandle))
]

{ #category : 'ffi methods' }
ODBCLibrary >> sqlFreeStmt: statementHandle option: optionInteger [
	"SQLRETURN
	SQLFreeStmt(
	SQLHSTMT StatementHandle,
	SQLUSMALLINT Option); "

	self ffiCall: #(SQLRETURN SQLFreeStmt (SQLHSTMT statementHandle, SQLUSMALLINT  optionInteger))
]

{ #category : 'ffi methods' }
ODBCLibrary >> sqlGetConnectAttr: anExternalHandle attribute: idInteger valuePtr: anIntegerOrStringOrBytes bufferLength: lengthInteger stringLengthPtr: anSDWORD [
	"SQLRETURN SQLGetConnectAttrW(
     SQLHDBC        ConnectionHandle,
     SQLINTEGER     Attribute,
     SQLPOINTER     ValuePtr,
     SQLINTEGER     BufferLength,
     SQLINTEGER *   StringLengthPtr); "

	self ffiCall: #(SQLRETURN SQLGetConnectAttrW (SQLHDBC anExternalHandle, SQLINTEGER idInteger, SQLPOINTER anIntegerOrStringOrBytes, SQLINTEGER lengthInteger, SQLINTEGER * anSDWORD))
]

{ #category : 'ffi methods' }
ODBCLibrary >> sqlGetData: anExternalHandleSTMT columnNumber: anIntegerPar targetType: anIntegerCType targetValuePtr: anExternalBuffer bufferLength: anIntegerMax strLenOrIndPtr: anSDWORD [
	"SQLRETURN SQLGetData(
      SQLHSTMT       StatementHandle,
      SQLUSMALLINT   Col_or_Param_Num,
      SQLSMALLINT    TargetType,
      SQLPOINTER     TargetValuePtr,
      SQLLEN         BufferLength,
      SQLLEN *       StrLen_or_IndPtr);  "

	self ffiCall: #(SQLRETURN SQLGetData (SQLHSTMT anExternalHandleSTMT, SQLUSMALLINT anIntegerPar, SQLSMALLINT anIntegerCType, SQLPOINTER anExternalBuffer, SQLLEN anIntegerMax, SQLLEN * anSDWORD))
]

{ #category : 'ffi methods' }
ODBCLibrary >> sqlGetDiagRec: anIntegerHandleType handle: anExternalHandle recNumber: anIntegerRecordNumber szSqlState: anSQLStateParm pfNativeError: anIntegerParmNErr szErrorMsg: anExternalBufferErrMsg cbErrorMsgMax: anInteger pcbErrorMsg: anIntegerParmLen [
	"SQLRETURN SQLGetDiagRecW(
		SQLSMALLINT     HandleType,
		SQLHANDLE       Handle,
		SQLSMALLINT     RecNumber,
		SQLWCHAR *      SQLState,
		SQLINTEGER *    NativeErrorPtr,
		SQLWCHAR *	   MessageText,
		SQLSMALLINT     BufferLength,
		SQLSMALLINT *   TextLengthPtr);"

	self ffiCall: #(SQLRETURN SQLGetDiagRecW (SQLSMALLINT anIntegerHandleType, SQLHANDLE anExternalHandle, SQLSMALLINT anIntegerRecordNumber, SQLWCHAR* anSQLStateParm, SQLSMALLINT* anIntegerParmNErr, SQLWCHAR* anExternalBufferErrMsg, SQLSMALLINT anInteger, SQLSMALLINT* anIntegerParmLen))
]

{ #category : 'ffi methods' }
ODBCLibrary >> sqlGetEnvAttr: anExternalHandle infoType: anIntegerType infoValuePtr: bytes bufferLength: anIntegerMax stringLengthPtr: anSWORD [
	"SQLRETURN SQLGetEnvAttr(
     SQLHENV        EnvironmentHandle,
     SQLINTEGER     Attribute,
     SQLPOINTER     ValuePtr,
     SQLINTEGER     BufferLength,
     SQLINTEGER *   StringLengthPtr);"

	self ffiCall: #(SQLRETURN SQLGetEnvAttr (SQLHDBC anExternalHandle, SQLINTEGER anIntegerType, SQLPOINTER bytes, SQLINTEGER anIntegerMax, SQLINTEGER * anSWORD))
]

{ #category : 'ffi methods' }
ODBCLibrary >> sqlGetInfo: anExternalHandle infoType: anIntegerType infoValueHandle: aSQLHANDLE bufferLength: anIntegerMax stringLengthPtr: aSQLSMALLINT [

	"	SQLRETURN SQLGetInfoW(
			SQLHDBC     ConnectionHandle,
			SQLUSMALLINT     InfoType,
			SQLHANDLE *     InfoValuePtr,
			SQLSMALLINT     BufferLength,
			SQLSMALLINT *     StringLengthPtr);"

	self ffiCall: #(SQLRETURN SQLGetInfoW (SQLHDBC anExternalHandle, SQLUSMALLINT anIntegerType, SQLHANDLE * aSQLHANDLE, SQLSMALLINT anIntegerMax, SQLSMALLINT * aSQLSMALLINT))
]

{ #category : 'ffi methods' }
ODBCLibrary >> sqlGetInfo: anExternalHandle infoType: anIntegerType infoValuePtr: bytes bufferLength: anIntegerMax stringLengthPtr: aSQLSMALLINT [

	"	SQLRETURN SQLGetInfoW(
			SQLHDBC     ConnectionHandle,
			SQLUSMALLINT     InfoType,
			SQLPOINTER     InfoValuePtr,
			SQLSMALLINT     BufferLength,
			SQLSMALLINT *     StringLengthPtr);"

	self ffiCall: #(SQLRETURN SQLGetInfoW (SQLHDBC anExternalHandle, SQLUSMALLINT anIntegerType, SQLPOINTER bytes, SQLSMALLINT anIntegerMax, SQLSMALLINT * aSQLSMALLINT))
]

{ #category : 'ffi methods' }
ODBCLibrary >> sqlGetStmtAttr: anExternalHandle attribute: optionCode valuePtr: anIntegerOrStringOrBytes bufferLength: lengthInteger stringLengthPtr: anSDWORD [
	"SQLRETURN SQLGetStmtAttr(
     SQLHSTMT        StatementHandle,
     SQLINTEGER      Attribute,
     SQLPOINTER      ValuePtr,
     SQLINTEGER      BufferLength,
     SQLINTEGER *    StringLengthPtr);  "

	self ffiCall: #(SQLRETURN SQLGetStmtAttrW (SQLHSTMT anExternalHandle, SQLINTEGER optionCode, SQLPOINTER anIntegerOrStringOrBytes, SQLINTEGER lengthInteger, SQLINTEGER * anSWORD))
]

{ #category : 'ffi methods' }
ODBCLibrary >> sqlNumResultCols: anExternalHandle pccol: anSWORD [
	"Return the number of columns in the result set for the statement.

		SQLRETURN SQLNumResultCols(
			SQLHSTMT StatementHandle,
			SQLSMALLINT * ColumnCountPtr);"

	self ffiCall: #(SQLRETURN SQLNumResultCols (SQLHSTMT anExternalHandle, SQLSMALLINT * anSWORD))
]

{ #category : 'ffi methods' }
ODBCLibrary >> sqlPrepare: anExternalHandle statementText: aString textLength: anInteger [
	"SQLRETURN SQLPrepareW(
		SQLHSTMT StatementHandle,
		SQLWCHAR * StatementText,
		SQLINTEGER TextLength);"

	self ffiCall: #(SQLRETURN SQLPrepareW (SQLHSTMT anExternalHandle, SQLWCHAR* aString, SQLINTEGER anInteger))
]

{ #category : 'ffi methods' }
ODBCLibrary >> sqlPrimaryKeys: anExternalHandle catalogName: aStringQual nameLength1: anIntegerQual schemaName: aStringOwn nameLength2: anIntegerOwn tableName: aStringName nameLength3: anIntegerName [
	"SQLRETURN SQLPrimaryKeysW(
		SQLHSTMT     StatementHandle,
		SQLWCHAR *     CatalogName,
		SQLSMALLINT     NameLength1,
		SQLWCHAR *     SchemaName,
		SQLSMALLINT     NameLength2,
		SQLWCHAR *     TableName,
		SQLSMALLINT     NameLength3);"

	self ffiCall: #(SQLRETURN SQLPrimaryKeysW (SQLHSTMT anExternalHandle, SQLWCHAR * aStringQual, SQLSMALLINT anIntegerQual, SQLWCHAR * aStringOwn, SQLSMALLINT anIntegerOwn, SQLWCHAR * aStringName, SQLSMALLINT anIntegerName))
]

{ #category : 'ffi methods' }
ODBCLibrary >> sqlProcedures: anExternalHandle catalogName: aStringParmPQ nameLength1: anIntegerPQ schemaName: aStringParmPO nameLength1: anIntegerPO procName: aStringParmPN nameLength3: anIntegerPN [
	"SQLRETURN SQLProceduresW(
		SQLHSTMT     StatementHandle,
		SQLWCHAR *     CatalogName,
		SQLSMALLINT     NameLength1,
		SQLWCHAR *     SchemaName,
		SQLSMALLINT     NameLength2,
		SQLWCHAR *     ProcName,
		SQLSMALLINT     NameLength3);"

	self ffiCall: #(SQLRETURN SQLProceduresW (SQLHSTMT anExternalHandle, SQLWCHAR * aStringParmPQ, SQLSMALLINT anIntegerPQ, SQLWCHAR * aStringParmPO, SQLSMALLINT anIntegerPO, SQLWCHAR * aStringParmPN, SQLSMALLINT anIntegerPN))
]

{ #category : 'ffi methods' }
ODBCLibrary >> sqlRowCount: anExternalHandle rowCountPtr: anSDWORD [
	"Return the number of rows affected by an UPDATE, INSERT or
	DELETE statement associated with the specified hstmt.

	SQLRETURN SQLRowCount(
		SQLHSTMT StatementHandle,
		SQLLEN * RowCountPtr)"

	self ffiCall: #(SQLRETURN SQLRowCount (SQLHSTMT anExternalHandle, SQLLEN * anSDWORD))
]

{ #category : 'ffi methods' }
ODBCLibrary >> sqlSetConnectAttr: connectionHandle attribute: attribute valuePtr: value stringLength: length [
	"SQLRETURN SQLSetConnectAttrW(
		SQLHDBC ConnectionHandle,
		SQLINTEGER Attribute,
		SQLPOINTER ValuePtr,
		SQLINTEGER StringLength);"

	self ffiCall: #(SQLRETURN SQLSetConnectAttrW (SQLHDBC connectionHandle, SQLINTEGER attribute, SQLPOINTER value, SQLINTEGER length))
]

{ #category : 'ffi methods' }
ODBCLibrary >> sqlSetEnvAttr: hEnv attribute: attr valuePtr: value stringLength: length [
	"SQLRETURN SQLSetEnvAttr(
		SQLHENV     EnvironmentHandle,
		SQLINTEGER     Attribute,
		SQLPOINTER     ValuePtr,
		SQLINTEGER     StringLength);"

	self ffiCall: #(SQLRETURN SQLSetEnvAttr (SQLHENV hEnv, SQLINTEGER attr, SQLPOINTER value, SQLINTEGER length))
]

{ #category : 'ffi methods' }
ODBCLibrary >> sqlSetPos: anExternalHandle rowNumber: anIntegerRow operation: anIntegerOption lockType: aBoolLock [
	"SQLRETURN SQLSetPos(
      SQLHSTMT        StatementHandle,
      SQLSETPOSIROW   RowNumber,
      SQLUSMALLINT    Operation,
      SQLUSMALLINT    LockType);  "

	self ffiCall: #(SQLRETURN SQLSetPos (SQLHSTMT anExternalHandle, SQLSETPOSIROW anIntegerRow, SQLUSMALLINT anIntegerOption, SQLUSMALLINT aBoolLock))
]

{ #category : 'ffi methods' }
ODBCLibrary >> sqlSetStmtAttr: anExternalHandle attribute: anInteger valuePtr: anExternalAddress stringLength: lengthInteger [
	"SQLRETURN  SQL_API SQLSetStmtAttrW(
		SQLHSTMT StatementHandle,
		SQLINTEGER Attribute,
		SQLPOINTER Value,
		SQLINTEGER StringLength);"

	self ffiCall: #(SQLRETURN SQLSetStmtAttrW (SQLHSTMT anExternalHandle, SQLINTEGER anInteger, SQLPOINTER anExternalAddress, SQLINTEGER lengthInteger))
]

{ #category : 'ffi methods' }
ODBCLibrary >> sqlSpecialColumns: anExternalHandle identifierType: anInteger catalogName: aStringQual nameLength1: anIntegerQual schemaName: aStringOwn nameLength2: anIntegerOwn tableName: aStringName nameLength3: anIntegerName scope: anIntegerScope nullable: anIntegerNullable [
	"SQLRETURN SQLSpecialColumnsW(
		SQLHSTMT     StatementHandle,
		SQLSMALLINT     IdentifierType,
		SQLWCHAR *     CatalogName,
		SQLSMALLINT     NameLength1,
		SQLWCHAR *     SchemaName,
		SQLSMALLINT     NameLength2,
		SQLWCHAR *     TableName,
		SQLSMALLINT     NameLength3,
		SQLSMALLINT     Scope,
		SQLSMALLINT     Nullable);"

	self ffiCall: #(SQLRETURN SQLSpecialColumnsW (SQLHSTMT anExternalHandle, SQLSMALLINT anInteger, SQLWCHAR * aStringQual, SQLSMALLINT anIntegerQual, SQLWCHAR * aStringOwn, SQLSMALLINT anIntegerOwn, SQLWCHAR * aStringName, SQLSMALLINT anIntegerName, SQLSMALLINT anIntegerScope, SQLSMALLINT anIntegerNullable))
]

{ #category : 'ffi methods' }
ODBCLibrary >> sqlStatistics: anExternalHandle catalogName: aStringQual nameLength1: anIntegerQual schemaName: aStringOwn nameLength2: anIntegerOwn tableName: aStringName nameLength3: anIntegerName unique: anIntegerScope reserved: anIntegerNullable [
	"SQLRETURN SQLStatisticsW(
		SQLHSTMT     StatementHandle,
		SQLWCHAR *     CatalogName,
		SQLSMALLINT     NameLength1,
		SQLWCHAR *     SchemaName,
		SQLSMALLINT     NameLength2,
		SQLWCHAR *     TableName,
		SQLSMALLINT     NameLength3,
		SQLUSMALLINT     Unique,
		SQLUSMALLINT     Reserved);"

	self ffiCall: #(SQLRETURN SQLStatisticsW (SQLHSTMT anExternalHandle, SQLWCHAR * aStringQual, SQLSMALLINT anIntegerQual, SQLWCHAR * aStringOwn, SQLSMALLINT anIntegerOwn, SQLWCHAR * aStringName, SQLSMALLINT anIntegerName, SQLUSMALLINT anIntegerScope, SQLUSMALLINT anIntegerNullable))
]

{ #category : 'ffi methods' }
ODBCLibrary >> sqlTables: anExternalHandleSTMT szTableQualifier: aStringParmQual cbTableQualifier: anIntegerQualLen szTableOwner: aStringParmOwner cbTableOwner: anIntegerOwnerLen szTableName: aStringParmName cbTableName: anIntegerNameLen szTableType: aStringParmType cbTableType: anIntegerTypeLen [
	"SQLRETURN SQLTablesW(
     SQLHSTMT       StatementHandle,
     SQLWCHAR *      CatalogName,
     SQLSMALLINT    NameLength1,
     SQLWCHAR *      SchemaName,
     SQLSMALLINT    NameLength2,
     SQLWCHAR *      TableName,
     SQLSMALLINT    NameLength3,
     SQLWCHAR *      TableType,
     SQLSMALLINT    NameLength4); "

	self ffiCall: #(SQLRETURN SQLTablesW (SQLHSTMT anExternalHandleSTMT, SQLWCHAR * aStringParmQual, SQLSMALLINT anIntegerQualLen, SQLWCHAR * aStringParmOwner, SQLSMALLINT anIntegerOwnerLen, SQLWCHAR * aStringParmName, SQLSMALLINT anIntegerNameLen, SQLWCHAR * aStringParmType, SQLSMALLINT anIntegerTypeLen))
]

{ #category : 'accessing - platform' }
ODBCLibrary >> unixLibraryName [

	^'libodbc.so'
]

{ #category : 'accessing platform' }
ODBCLibrary >> unixModuleName [

	^'libodbc.so'
]

{ #category : 'accessing - platform' }
ODBCLibrary >> win32LibraryName [

	^'ODBC32'
]

{ #category : 'accessing platform' }
ODBCLibrary >> win32ModuleName [

	^'ODBC32'
]
