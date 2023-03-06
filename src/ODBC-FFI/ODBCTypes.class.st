"
Defines ODBC SQL Types
"
Class {
	#name : #ODBCTypes,
	#superclass : #SharedPool,
	#classVars : [
		'SQL_BIGINT',
		'SQL_BINARY',
		'SQL_BIT',
		'SQL_CHAR',
		'SQL_DATE',
		'SQL_DATETIME',
		'SQL_DECIMAL',
		'SQL_DOUBLE',
		'SQL_FLOAT',
		'SQL_GUID',
		'SQL_INTEGER',
		'SQL_INTERVAL',
		'SQL_INTERVAL_DAY',
		'SQL_INTERVAL_DAY_TO_HOUR',
		'SQL_INTERVAL_DAY_TO_MINUTE',
		'SQL_INTERVAL_DAY_TO_SECOND',
		'SQL_INTERVAL_HOUR',
		'SQL_INTERVAL_HOUR_TO_MINUTE',
		'SQL_INTERVAL_HOUR_TO_SECOND',
		'SQL_INTERVAL_MINUTE',
		'SQL_INTERVAL_MINUTE_TO_SECOND',
		'SQL_INTERVAL_MONTH',
		'SQL_INTERVAL_SECOND',
		'SQL_INTERVAL_YEAR',
		'SQL_INTERVAL_YEAR_TO_MONTH',
		'SQL_LONGVARBINARY',
		'SQL_LONGVARCHAR',
		'SQL_NUMERIC',
		'SQL_REAL',
		'SQL_SMALLINT',
		'SQL_TIME',
		'SQL_TIMESTAMP',
		'SQL_TINYINT',
		'SQL_TYPE_DATE',
		'SQL_TYPE_NULL',
		'SQL_TYPE_TIME',
		'SQL_TYPE_TIMESTAMP',
		'SQL_UNKNOWN_TYPE',
		'SQL_VARBINARY',
		'SQL_VARCHAR',
		'SQL_WCHAR',
		'SQL_WLONGVARCHAR',
		'SQL_WVARCHAR'
	],
	#category : #'ODBC-FFI-Base'
}

{ #category : #'class initialization' }
ODBCTypes class >> initialize [

	self
		initialize_SQL_BIGINT;
		initialize_SQL_BINARY;
		initialize_SQL_BIT;
		initialize_SQL_CHAR;
		initialize_SQL_DATE;
		initialize_SQL_DATETIME;
		initialize_SQL_DECIMAL;
		initialize_SQL_DOUBLE;
		initialize_SQL_FLOAT;
		initialize_SQL_GUID;
		initialize_SQL_INTEGER;
		initialize_SQL_INTERVAL;
		initialize_SQL_INTERVAL_DAY;
		initialize_SQL_INTERVAL_DAY_TO_HOUR;
		initialize_SQL_INTERVAL_DAY_TO_MINUTE;
		initialize_SQL_INTERVAL_DAY_TO_SECOND;
		initialize_SQL_INTERVAL_HOUR;
		initialize_SQL_INTERVAL_HOUR_TO_MINUTE;
		initialize_SQL_INTERVAL_HOUR_TO_SECOND;
		initialize_SQL_INTERVAL_MINUTE;
		initialize_SQL_INTERVAL_MINUTE_TO_SECOND;
		initialize_SQL_INTERVAL_MONTH;
		initialize_SQL_INTERVAL_SECOND;
		initialize_SQL_INTERVAL_YEAR;
		initialize_SQL_INTERVAL_YEAR_TO_MONTH;
		initialize_SQL_LONGVARBINARY;
		initialize_SQL_LONGVARCHAR;
		initialize_SQL_NUMERIC;
		initialize_SQL_REAL;
		initialize_SQL_SMALLINT;
		initialize_SQL_TIME;
		initialize_SQL_TIMESTAMP;
		initialize_SQL_TINYINT;
		initialize_SQL_TYPE_DATE;
		initialize_SQL_TYPE_NULL;
		initialize_SQL_TYPE_TIME;
		initialize_SQL_TYPE_TIMESTAMP;
		initialize_SQL_UNKNOWN_TYPE;
		initialize_SQL_VARBINARY;
		initialize_SQL_VARCHAR;
		initialize_SQL_WCHAR;
		initialize_SQL_WLONGVARCHAR;
		initialize_SQL_WVARCHAR
]

{ #category : #'private - initialization' }
ODBCTypes class >> initialize_SQL_BIGINT [

	SQL_BIGINT := -5
]

{ #category : #'private - initialization' }
ODBCTypes class >> initialize_SQL_BINARY [

	SQL_BINARY := -2
]

{ #category : #'private - initialization' }
ODBCTypes class >> initialize_SQL_BIT [

	SQL_BIT := -7
]

{ #category : #'private - initialization' }
ODBCTypes class >> initialize_SQL_CHAR [

	SQL_CHAR := 1
]

{ #category : #'private - initialization' }
ODBCTypes class >> initialize_SQL_DATE [

	SQL_DATE := 9
]

{ #category : #'private - initialization' }
ODBCTypes class >> initialize_SQL_DATETIME [

	SQL_DATETIME := 9
]

{ #category : #'private - initialization' }
ODBCTypes class >> initialize_SQL_DECIMAL [

	SQL_DECIMAL := 3
]

{ #category : #'private - initialization' }
ODBCTypes class >> initialize_SQL_DOUBLE [

	SQL_DOUBLE := 8
]

{ #category : #'private - initialization' }
ODBCTypes class >> initialize_SQL_FLOAT [

	SQL_FLOAT := 6
]

{ #category : #'private - initialization' }
ODBCTypes class >> initialize_SQL_GUID [

	SQL_GUID := -11
]

{ #category : #'private - initialization' }
ODBCTypes class >> initialize_SQL_INTEGER [

	SQL_INTEGER := 4
]

{ #category : #'private - initialization' }
ODBCTypes class >> initialize_SQL_INTERVAL [

	SQL_INTERVAL := 10
]

{ #category : #'private - initialization' }
ODBCTypes class >> initialize_SQL_INTERVAL_DAY [

	SQL_INTERVAL_DAY := 103
]

{ #category : #'private - initialization' }
ODBCTypes class >> initialize_SQL_INTERVAL_DAY_TO_HOUR [

	SQL_INTERVAL_DAY_TO_HOUR := 108
]

{ #category : #'private - initialization' }
ODBCTypes class >> initialize_SQL_INTERVAL_DAY_TO_MINUTE [

	SQL_INTERVAL_DAY_TO_MINUTE := 109
]

{ #category : #'private - initialization' }
ODBCTypes class >> initialize_SQL_INTERVAL_DAY_TO_SECOND [

	SQL_INTERVAL_DAY_TO_SECOND := 110
]

{ #category : #'private - initialization' }
ODBCTypes class >> initialize_SQL_INTERVAL_HOUR [

	SQL_INTERVAL_HOUR := 104
]

{ #category : #'private - initialization' }
ODBCTypes class >> initialize_SQL_INTERVAL_HOUR_TO_MINUTE [

	SQL_INTERVAL_HOUR_TO_MINUTE := 111
]

{ #category : #'private - initialization' }
ODBCTypes class >> initialize_SQL_INTERVAL_HOUR_TO_SECOND [

	SQL_INTERVAL_HOUR_TO_SECOND := 112
]

{ #category : #'private - initialization' }
ODBCTypes class >> initialize_SQL_INTERVAL_MINUTE [

	SQL_INTERVAL_MINUTE := 105
]

{ #category : #'private - initialization' }
ODBCTypes class >> initialize_SQL_INTERVAL_MINUTE_TO_SECOND [

	SQL_INTERVAL_MINUTE_TO_SECOND := 113
]

{ #category : #'private - initialization' }
ODBCTypes class >> initialize_SQL_INTERVAL_MONTH [

	SQL_INTERVAL_MONTH := 102
]

{ #category : #'private - initialization' }
ODBCTypes class >> initialize_SQL_INTERVAL_SECOND [

	SQL_INTERVAL_SECOND := 106
]

{ #category : #'private - initialization' }
ODBCTypes class >> initialize_SQL_INTERVAL_YEAR [

	SQL_INTERVAL_YEAR := 101
]

{ #category : #'private - initialization' }
ODBCTypes class >> initialize_SQL_INTERVAL_YEAR_TO_MONTH [

	SQL_INTERVAL_YEAR_TO_MONTH := 107
]

{ #category : #'private - initialization' }
ODBCTypes class >> initialize_SQL_LONGVARBINARY [

	SQL_LONGVARBINARY := -4
]

{ #category : #'private - initialization' }
ODBCTypes class >> initialize_SQL_LONGVARCHAR [

	SQL_LONGVARCHAR := -1
]

{ #category : #'private - initialization' }
ODBCTypes class >> initialize_SQL_NUMERIC [

	SQL_NUMERIC := 2
]

{ #category : #'private - initialization' }
ODBCTypes class >> initialize_SQL_REAL [

	SQL_REAL := 7
]

{ #category : #'private - initialization' }
ODBCTypes class >> initialize_SQL_SMALLINT [

	SQL_SMALLINT := 5
]

{ #category : #'private - initialization' }
ODBCTypes class >> initialize_SQL_TIME [

	SQL_TIME := 10
]

{ #category : #'private - initialization' }
ODBCTypes class >> initialize_SQL_TIMESTAMP [

	SQL_TIMESTAMP := 11
]

{ #category : #'private - initialization' }
ODBCTypes class >> initialize_SQL_TINYINT [

	SQL_TINYINT := -6
]

{ #category : #'private - initialization' }
ODBCTypes class >> initialize_SQL_TYPE_DATE [

	SQL_TYPE_DATE := 91
]

{ #category : #'private - initialization' }
ODBCTypes class >> initialize_SQL_TYPE_NULL [

	SQL_TYPE_NULL := 0
]

{ #category : #'private - initialization' }
ODBCTypes class >> initialize_SQL_TYPE_TIME [

	SQL_TYPE_TIME := 92
]

{ #category : #'private - initialization' }
ODBCTypes class >> initialize_SQL_TYPE_TIMESTAMP [

	SQL_TYPE_TIMESTAMP := 93
]

{ #category : #'private - initialization' }
ODBCTypes class >> initialize_SQL_UNKNOWN_TYPE [

	SQL_UNKNOWN_TYPE := 0
]

{ #category : #'private - initialization' }
ODBCTypes class >> initialize_SQL_VARBINARY [

	SQL_VARBINARY := -3
]

{ #category : #'private - initialization' }
ODBCTypes class >> initialize_SQL_VARCHAR [

	SQL_VARCHAR := 12
]

{ #category : #'private - initialization' }
ODBCTypes class >> initialize_SQL_WCHAR [

	SQL_WCHAR := -8
]

{ #category : #'private - initialization' }
ODBCTypes class >> initialize_SQL_WLONGVARCHAR [

	SQL_WLONGVARCHAR := -10
]

{ #category : #'private - initialization' }
ODBCTypes class >> initialize_SQL_WVARCHAR [

	SQL_WVARCHAR := -9
]
