"
Define ODBC return codes
"
Class {
	#name : #ODBCRetCodes,
	#superclass : #SharedPool,
	#classVars : [
		'SQL_ERROR',
		'SQL_INVALID_HANDLE',
		'SQL_NEED_DATA',
		'SQL_NO_DATA',
		'SQL_SUCCESS',
		'SQL_SUCCESS_WITH_INFO'
	],
	#category : #'ODBC-FFI-Base'
}

{ #category : #'class initialization' }
ODBCRetCodes class >> initialize [

	self
		initialize_SQL_ERROR;
		initialize_SQL_INVALID_HANDLE;
		initialize_SQL_NEED_DATA;
		initialize_SQL_NO_DATA;
		initialize_SQL_SUCCESS;
		initialize_SQL_SUCCESS_WITH_INFO
]

{ #category : #'private - initialization' }
ODBCRetCodes class >> initialize_SQL_ERROR [

	SQL_ERROR := -1
]

{ #category : #'private - initialization' }
ODBCRetCodes class >> initialize_SQL_INVALID_HANDLE [

	SQL_INVALID_HANDLE := -2
]

{ #category : #'private - initialization' }
ODBCRetCodes class >> initialize_SQL_NEED_DATA [

	SQL_NEED_DATA := 99
]

{ #category : #'private - initialization' }
ODBCRetCodes class >> initialize_SQL_NO_DATA [

	SQL_NO_DATA := 100
]

{ #category : #'private - initialization' }
ODBCRetCodes class >> initialize_SQL_SUCCESS [

	SQL_SUCCESS := 0
]

{ #category : #'private - initialization' }
ODBCRetCodes class >> initialize_SQL_SUCCESS_WITH_INFO [

	SQL_SUCCESS_WITH_INFO := 1
]
