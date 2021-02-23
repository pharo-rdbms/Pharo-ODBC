Class {
	#name : #ODBCCTypes,
	#superclass : #SharedPool,
	#classVars : [
		'SQL_C_BINARY',
		'SQL_C_BIT',
		'SQL_C_BOOKMARK',
		'SQL_C_CHAR',
		'SQL_C_DATE',
		'SQL_C_DEFAULT',
		'SQL_C_DOUBLE',
		'SQL_C_FLOAT',
		'SQL_C_GUID',
		'SQL_C_INTERVAL_DAY',
		'SQL_C_INTERVAL_DAY_TO_HOUR',
		'SQL_C_INTERVAL_DAY_TO_MINUTE',
		'SQL_C_INTERVAL_DAY_TO_SECOND',
		'SQL_C_INTERVAL_HOUR',
		'SQL_C_INTERVAL_HOUR_TO_MINUTE',
		'SQL_C_INTERVAL_HOUR_TO_SECOND',
		'SQL_C_INTERVAL_MINUTE',
		'SQL_C_INTERVAL_MINUTE_TO_SECOND',
		'SQL_C_INTERVAL_MONTH',
		'SQL_C_INTERVAL_SECOND',
		'SQL_C_INTERVAL_YEAR',
		'SQL_C_INTERVAL_YEAR_TO_MONTH',
		'SQL_C_LONG',
		'SQL_C_NUMERIC',
		'SQL_C_SBIGINT',
		'SQL_C_SHORT',
		'SQL_C_SLONG',
		'SQL_C_SSHORT',
		'SQL_C_STINYINT',
		'SQL_C_TIME',
		'SQL_C_TIMESTAMP',
		'SQL_C_TINYINT',
		'SQL_C_TYPE_DATE',
		'SQL_C_TYPE_TIME',
		'SQL_C_TYPE_TIMESTAMP',
		'SQL_C_UBIGINT',
		'SQL_C_ULONG',
		'SQL_C_USHORT',
		'SQL_C_UTINYINT',
		'SQL_C_VARBOOKMARK',
		'SQL_C_WCHAR'
	],
	#category : #'ODBC-FFI-Base'
}

{ #category : #'class initialization' }
ODBCCTypes class >> initialize [
	self
		initialize_SQL_C_BINARY;
		initialize_SQL_C_BIT;
		initialize_SQL_C_BOOKMARK;
		initialize_SQL_C_CHAR;
		initialize_SQL_C_DATE;
		initialize_SQL_C_DEFAULT;
		initialize_SQL_C_DOUBLE;
		initialize_SQL_C_FLOAT;
		initialize_SQL_C_GUID;
		initialize_SQL_C_INTERVAL_DAY;
		initialize_SQL_C_INTERVAL_DAY_TO_HOUR;
		initialize_SQL_C_INTERVAL_DAY_TO_MINUTE;
		initialize_SQL_C_INTERVAL_DAY_TO_SECOND;
		initialize_SQL_C_INTERVAL_HOUR;
		initialize_SQL_C_INTERVAL_HOUR_TO_MINUTE;
		initialize_SQL_C_INTERVAL_HOUR_TO_SECOND;
		initialize_SQL_C_INTERVAL_MINUTE;
		initialize_SQL_C_INTERVAL_MINUTE_TO_SECOND;
		initialize_SQL_C_INTERVAL_MONTH;
		initialize_SQL_C_INTERVAL_SECOND;
		initialize_SQL_C_INTERVAL_YEAR;
		initialize_SQL_C_INTERVAL_YEAR_TO_MONTH;
		initialize_SQL_C_LONG;
		initialize_SQL_C_NUMERIC;
		initialize_SQL_C_SBIGINT;
		initialize_SQL_C_SHORT;
		initialize_SQL_C_SLONG;
		initialize_SQL_C_SSHORT;
		initialize_SQL_C_STINYINT;
		initialize_SQL_C_TIME;
		initialize_SQL_C_TIMESTAMP;
		initialize_SQL_C_TINYINT;
		initialize_SQL_C_TYPE_DATE;
		initialize_SQL_C_TYPE_TIME;
		initialize_SQL_C_TYPE_TIMESTAMP;
		initialize_SQL_C_UBIGINT;
		initialize_SQL_C_ULONG;
		initialize_SQL_C_USHORT;
		initialize_SQL_C_UTINYINT;
		initialize_SQL_C_VARBOOKMARK;
		initialize_SQL_C_WCHAR;
		yourself
]

{ #category : #'private - pool initialization' }
ODBCCTypes class >> initialize_SQL_C_BINARY [

	SQL_C_BINARY := -2
]

{ #category : #'private - pool initialization' }
ODBCCTypes class >> initialize_SQL_C_BIT [

	SQL_C_BIT := -7
]

{ #category : #'private - pool initialization' }
ODBCCTypes class >> initialize_SQL_C_BOOKMARK [

	SQL_C_BOOKMARK := -18
]

{ #category : #'private - pool initialization' }
ODBCCTypes class >> initialize_SQL_C_CHAR [

	SQL_C_CHAR := 1
]

{ #category : #'private - pool initialization' }
ODBCCTypes class >> initialize_SQL_C_DATE [

	SQL_C_DATE := 9
]

{ #category : #'private - pool initialization' }
ODBCCTypes class >> initialize_SQL_C_DEFAULT [

	SQL_C_DEFAULT := 99
]

{ #category : #'private - pool initialization' }
ODBCCTypes class >> initialize_SQL_C_DOUBLE [

	SQL_C_DOUBLE := 8
]

{ #category : #'private - pool initialization' }
ODBCCTypes class >> initialize_SQL_C_FLOAT [

	SQL_C_FLOAT := 7
]

{ #category : #'private - pool initialization' }
ODBCCTypes class >> initialize_SQL_C_GUID [

	SQL_C_GUID := -11
]

{ #category : #'private - pool initialization' }
ODBCCTypes class >> initialize_SQL_C_INTERVAL_DAY [

	SQL_C_INTERVAL_DAY := 103
]

{ #category : #'private - pool initialization' }
ODBCCTypes class >> initialize_SQL_C_INTERVAL_DAY_TO_HOUR [

	SQL_C_INTERVAL_DAY_TO_HOUR := 108
]

{ #category : #'private - pool initialization' }
ODBCCTypes class >> initialize_SQL_C_INTERVAL_DAY_TO_MINUTE [

	SQL_C_INTERVAL_DAY_TO_MINUTE := 109
]

{ #category : #'private - pool initialization' }
ODBCCTypes class >> initialize_SQL_C_INTERVAL_DAY_TO_SECOND [

	SQL_C_INTERVAL_DAY_TO_SECOND := 110
]

{ #category : #'private - pool initialization' }
ODBCCTypes class >> initialize_SQL_C_INTERVAL_HOUR [

	SQL_C_INTERVAL_HOUR := 104
]

{ #category : #'private - pool initialization' }
ODBCCTypes class >> initialize_SQL_C_INTERVAL_HOUR_TO_MINUTE [

	SQL_C_INTERVAL_HOUR_TO_MINUTE := 111
]

{ #category : #'private - pool initialization' }
ODBCCTypes class >> initialize_SQL_C_INTERVAL_HOUR_TO_SECOND [

	SQL_C_INTERVAL_HOUR_TO_SECOND := 112
]

{ #category : #'private - pool initialization' }
ODBCCTypes class >> initialize_SQL_C_INTERVAL_MINUTE [

	SQL_C_INTERVAL_MINUTE := 105
]

{ #category : #'private - pool initialization' }
ODBCCTypes class >> initialize_SQL_C_INTERVAL_MINUTE_TO_SECOND [

	SQL_C_INTERVAL_MINUTE_TO_SECOND := 113
]

{ #category : #'private - pool initialization' }
ODBCCTypes class >> initialize_SQL_C_INTERVAL_MONTH [

	SQL_C_INTERVAL_MONTH := 102
]

{ #category : #'private - pool initialization' }
ODBCCTypes class >> initialize_SQL_C_INTERVAL_SECOND [

	SQL_C_INTERVAL_SECOND := 106
]

{ #category : #'private - pool initialization' }
ODBCCTypes class >> initialize_SQL_C_INTERVAL_YEAR [

	SQL_C_INTERVAL_YEAR := 101
]

{ #category : #'private - pool initialization' }
ODBCCTypes class >> initialize_SQL_C_INTERVAL_YEAR_TO_MONTH [

	SQL_C_INTERVAL_YEAR_TO_MONTH := 107
]

{ #category : #'private - pool initialization' }
ODBCCTypes class >> initialize_SQL_C_LONG [

	SQL_C_LONG := 4
]

{ #category : #'private - pool initialization' }
ODBCCTypes class >> initialize_SQL_C_NUMERIC [

	SQL_C_NUMERIC := 2
]

{ #category : #'private - pool initialization' }
ODBCCTypes class >> initialize_SQL_C_SBIGINT [

	SQL_C_SBIGINT := -25
]

{ #category : #'private - pool initialization' }
ODBCCTypes class >> initialize_SQL_C_SHORT [

	SQL_C_SHORT := 5
]

{ #category : #'private - pool initialization' }
ODBCCTypes class >> initialize_SQL_C_SLONG [

	SQL_C_SLONG := -16
]

{ #category : #'private - pool initialization' }
ODBCCTypes class >> initialize_SQL_C_SSHORT [

	SQL_C_SSHORT := -15
]

{ #category : #'private - pool initialization' }
ODBCCTypes class >> initialize_SQL_C_STINYINT [

	SQL_C_STINYINT := -26
]

{ #category : #'private - pool initialization' }
ODBCCTypes class >> initialize_SQL_C_TIME [

	SQL_C_TIME := 10
]

{ #category : #'private - pool initialization' }
ODBCCTypes class >> initialize_SQL_C_TIMESTAMP [

	SQL_C_TIMESTAMP := 11
]

{ #category : #'private - pool initialization' }
ODBCCTypes class >> initialize_SQL_C_TINYINT [

	SQL_C_TINYINT := -6
]

{ #category : #'private - pool initialization' }
ODBCCTypes class >> initialize_SQL_C_TYPE_DATE [

	SQL_C_TYPE_DATE := 91
]

{ #category : #'private - pool initialization' }
ODBCCTypes class >> initialize_SQL_C_TYPE_TIME [

	SQL_C_TYPE_TIME := 92
]

{ #category : #'private - pool initialization' }
ODBCCTypes class >> initialize_SQL_C_TYPE_TIMESTAMP [

	SQL_C_TYPE_TIMESTAMP := 93
]

{ #category : #'private - pool initialization' }
ODBCCTypes class >> initialize_SQL_C_UBIGINT [

	SQL_C_UBIGINT := -27
]

{ #category : #'private - pool initialization' }
ODBCCTypes class >> initialize_SQL_C_ULONG [

	SQL_C_ULONG := -18
]

{ #category : #'private - pool initialization' }
ODBCCTypes class >> initialize_SQL_C_USHORT [

	SQL_C_USHORT := -17
]

{ #category : #'private - pool initialization' }
ODBCCTypes class >> initialize_SQL_C_UTINYINT [

	SQL_C_UTINYINT := -28
]

{ #category : #'private - pool initialization' }
ODBCCTypes class >> initialize_SQL_C_VARBOOKMARK [

	SQL_C_VARBOOKMARK := -2
]

{ #category : #'private - pool initialization' }
ODBCCTypes class >> initialize_SQL_C_WCHAR [

	SQL_C_WCHAR := -8
]
