"
ODBCPrimaryKeysStatement is a specialized <ODBCSchemaStatement> for querying about the primary keys of tables in a database.

Based on DBPrimaryKeysStatement from Dolphin Smalltalk Database Connection package.
"
Class {
	#name : #ODBCPrimaryKeysStatement,
	#superclass : #ODBCSchemaStatement,
	#category : #'ODBC-Core-Base'
}

{ #category : #operations }
ODBCPrimaryKeysStatement >> executeStatement [
	"Private - Execute the database command that the receiver represents.
	Answer the <integer> return code."

	^ ODBCLibrary default
		sqlPrimaryKeys: self allocatedHandle
		catalogName: (self stringEncoder encodeStringWithNullTerminator: catalogName)
		nameLength1: SQL_NTS
		schemaName: (self stringEncoder encodeStringWithNullTerminator: schemaName)
		nameLength2: SQL_NTS
		tableName: (self stringEncoder encodeStringWithNullTerminator: tableName)
		nameLength3: SQL_NTS
]
