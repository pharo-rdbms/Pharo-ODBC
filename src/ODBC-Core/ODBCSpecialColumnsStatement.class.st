"
Based on DBSpecialColumnsStatement from Dolphin Smalltalk Database Connection package.
"
Class {
	#name : 'ODBCSpecialColumnsStatement',
	#superclass : 'ODBCSchemaStatement',
	#instVars : [
		'columnType',
		'scope',
		'nullable'
	],
	#category : 'ODBC-Core-Base',
	#package : 'ODBC-Core',
	#tag : 'Base'
}

{ #category : 'accessing' }
ODBCSpecialColumnsStatement >> columnType [

	^ columnType
]

{ #category : 'accessing' }
ODBCSpecialColumnsStatement >> columnType: anInteger [

	columnType := anInteger
]

{ #category : 'operations' }
ODBCSpecialColumnsStatement >> executeStatement [
	"Private - Execute the database command that the receiver represents.
	Answer the <integer> return code."

	^ ODBCLibrary default
		sqlSpecialColumns: self allocatedHandle
		identifierType: self columnType
		catalogName: (self stringEncoder encodeStringWithNullTerminator: self catalogName)
		nameLength1: SQL_NTS
		schemaName: (self stringEncoder encodeStringWithNullTerminator: self schemaName)
		nameLength2: SQL_NTS
		tableName: (self stringEncoder encodeStringWithNullTerminator: self tableName)
		nameLength3: SQL_NTS
		scope: self scope
		nullable: (self nullable ifTrue: [SQL_NULLABLE] ifFalse: [SQL_NO_NULLS])
]

{ #category : 'accessing' }
ODBCSpecialColumnsStatement >> nullable [

	^ nullable
]

{ #category : 'accessing' }
ODBCSpecialColumnsStatement >> nullable: aBoolean [

	nullable := aBoolean
]

{ #category : 'accessing' }
ODBCSpecialColumnsStatement >> scope [

	^ scope
]

{ #category : 'accessing' }
ODBCSpecialColumnsStatement >> scope: anInteger [

	scope := anInteger
]
