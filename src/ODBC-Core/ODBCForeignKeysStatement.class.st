"
Based on DBForeignKeysStatement from Dolphin Smalltalk Database Connection package.
"
Class {
	#name : #ODBCForeignKeysStatement,
	#superclass : #ODBCSchemaStatement,
	#instVars : [
		'foreignCatalogName',
		'foreignSchemaName',
		'foreignTableName'
	],
	#category : #'ODBC-Core-Base'
}

{ #category : #operations }
ODBCForeignKeysStatement >> executeStatement [
	"Private - Execute the database command that the receiver represents.
	Answer the <integer> return code."

	^ ODBCLibrary default
		sqlForeignKeys: self allocatedHandle
		pkCatalogName: (self stringEncoder encodeStringWithNullTerminator: self catalogName)
		nameLength1: SQL_NTS
		pkSchemaName: (self stringEncoder encodeStringWithNullTerminator: self schemaName)
		nameLength2: SQL_NTS
		pkTableName: (self stringEncoder encodeStringWithNullTerminator: self tableName)
		nameLength3: SQL_NTS
		fkCatalogName: (self stringEncoder encodeStringWithNullTerminator: self foreignCatalogName)
		nameLength4: SQL_NTS
		fkSchemaName: (self stringEncoder encodeStringWithNullTerminator: self foreignSchemaName)
		nameLength5: SQL_NTS
		fkTableName: (self stringEncoder encodeStringWithNullTerminator: self foreignTableName)
		nameLength6: SQL_NTS
]

{ #category : #accessing }
ODBCForeignKeysStatement >> foreignCatalogName [

	^ foreignCatalogName
]

{ #category : #accessing }
ODBCForeignKeysStatement >> foreignCatalogName: patternString [

	foreignCatalogName := patternString
]

{ #category : #accessing }
ODBCForeignKeysStatement >> foreignSchemaName [

	^ foreignSchemaName
]

{ #category : #accessing }
ODBCForeignKeysStatement >> foreignSchemaName: patternString [

	foreignSchemaName := patternString
]

{ #category : #accessing }
ODBCForeignKeysStatement >> foreignTableName [

	^ foreignTableName
]

{ #category : #accessing }
ODBCForeignKeysStatement >> foreignTableName: aString [

	foreignTableName := aString
]
