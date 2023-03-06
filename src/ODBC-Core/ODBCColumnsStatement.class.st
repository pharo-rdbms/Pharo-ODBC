"
ODBCPrimaryKeysStatement is a specialized <ODBCSchemaStatement> for querying metadata about the columns of tables in a database.

Based on DBColumnsStatement from Dolphin Smalltalk Database Connection package.
"
Class {
	#name : #ODBCColumnsStatement,
	#superclass : #ODBCSchemaStatement,
	#instVars : [
		'columnName'
	],
	#category : #'ODBC-Core-Base'
}

{ #category : #accessing }
ODBCColumnsStatement >> columnName [
	^columnName
]

{ #category : #accessing }
ODBCColumnsStatement >> columnName: aString [
	columnName := aString
]

{ #category : #operations }
ODBCColumnsStatement >> executeStatement [
	"Private - Execute the database command that the receiver represents.
	Answer the <integer> return code."

	^ODBCLibrary default
		sqlColumns: self allocatedHandle
		catalogName: (self stringEncoder encodeStringWithNullTerminator: self catalogName)
		nameLength1: SQL_NTS
		schemaName: (self stringEncoder encodeStringWithNullTerminator: self schemaName)
		nameLength2: SQL_NTS
		tableName: (self stringEncoder encodeStringWithNullTerminator: self tableName)
		nameLength3: SQL_NTS
		columnName: (self stringEncoder encodeStringWithNullTerminator: self columnName)
		nameLength4: SQL_NTS
]
