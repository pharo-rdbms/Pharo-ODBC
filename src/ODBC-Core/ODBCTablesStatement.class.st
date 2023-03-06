"
ODBCTablesStatement is a specialized <ODBCSchemaStatement> for querying about tables in a database.

Based on DBTablesStatement from Dolphin Smalltalk Database Connection package.
"
Class {
	#name : #ODBCTablesStatement,
	#superclass : #ODBCSchemaStatement,
	#instVars : [
		'tableType'
	],
	#category : #'ODBC-Core-Base'
}

{ #category : #operations }
ODBCTablesStatement >> executeStatement [
	"Private - Execute the database command that the receiver represents.
	Answer the <integer> return code."

	^ODBCLibrary default
		sqlTables: self allocatedHandle
		szTableQualifier: (self stringEncoder encodeStringWithNullTerminator: catalogName)
		cbTableQualifier: SQL_NTS
		szTableOwner: (self stringEncoder encodeStringWithNullTerminator: schemaName)
		cbTableOwner: SQL_NTS
		szTableName: (self stringEncoder encodeStringWithNullTerminator: tableName)
		cbTableName: SQL_NTS
		szTableType: (self stringEncoder encodeStringWithNullTerminator: tableType)
		cbTableType: SQL_NTS
]

{ #category : #initializing }
ODBCTablesStatement >> initialize: anODBCConnection [
	"Private - Initialize the receiver as a new statement of the
	<ODBCConnection>, anODBCConnection."

	super initialize: anODBCConnection.
	tableType := '''TABLE'''
]

{ #category : #accessing }
ODBCTablesStatement >> tableType [
	^tableType
]

{ #category : #accessing }
ODBCTablesStatement >> tableType: aString [
	tableType := aString
]
