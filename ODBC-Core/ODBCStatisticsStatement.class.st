"
ODBCStatisticsStatement is a specialized <ODBCSchemaStatement> for querying about the indices of tables in a database.

Based on DBStatisticsStatement from Dolphin Smalltalk Database Connection package.
"
Class {
	#name : #ODBCStatisticsStatement,
	#superclass : #ODBCSchemaStatement,
	#instVars : [
		'type',
		'accurate'
	],
	#category : #'ODBC-Core-Base'
}

{ #category : #accessing }
ODBCStatisticsStatement >> accurate [
	^accurate
]

{ #category : #accessing }
ODBCStatisticsStatement >> accurate: aBoolean [
	accurate := aBoolean
]

{ #category : #operations }
ODBCStatisticsStatement >> executeStatement [
	"Private - Execute the database command that the receiver represents.
	Answer the <integer> return code."

	^ODBCLibrary default 
		sqlStatistics: self allocatedHandle
		catalogName: (self stringEncoder encodeStringWithNullTerminator: self catalogName)
		nameLength1: SQL_NTS
		schemaName: (self stringEncoder encodeStringWithNullTerminator: self schemaName)
		nameLength2: SQL_NTS
		tableName: (self stringEncoder encodeStringWithNullTerminator: self tableName)
		nameLength3: SQL_NTS
		unique: self type
		reserved: (accurate ifTrue: [SQL_ENSURE] ifFalse: [SQL_QUICK])
]

{ #category : #initializing }
ODBCStatisticsStatement >> initialize: anODBCConnection [ 
	"Private - Initialize the receiver as a new statement of the
	<ODBCConnection>, anODBCConnection."

	super initialize: anODBCConnection.
	type := SQL_INDEX_ALL.
	accurate := false
]

{ #category : #accessing }
ODBCStatisticsStatement >> type [
	^type
]

{ #category : #accessing }
ODBCStatisticsStatement >> type: statisticsTypeInteger [
	type := statisticsTypeInteger
]

{ #category : #accessing }
ODBCStatisticsStatement >> unique: aBoolean [ 
	self type: (aBoolean ifTrue: [SQL_INDEX_UNIQUE] ifFalse: [SQL_INDEX_ALL])
]
