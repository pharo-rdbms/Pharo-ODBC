"
ODBCProceduresStatement is a specialized <ODBCSchemaStatement> for querying about the stored procedures in a database.

Based on DBProceduresStatement from Dolphin Smalltalk Database Connection package.
"
Class {
	#name : #ODBCProceduresStatement,
	#superclass : #ODBCSchemaStatement,
	#instVars : [
		'procedureName'
	],
	#category : #'ODBC-Core-Base'
}

{ #category : #operations }
ODBCProceduresStatement >> executeStatement [
	"Private - Execute the database command that the receiver represents.
	Answer the <integer> return code."

	^ ODBCLibrary default
		sqlProcedures: self allocatedHandle
		catalogName: (self stringEncoder encodeStringWithNullTerminator: self catalogName)
		nameLength1: SQL_NTS
		schemaName: (self stringEncoder encodeStringWithNullTerminator: self schemaName)
		nameLength1: SQL_NTS
		procName: (self stringEncoder encodeStringWithNullTerminator: self procedureName)
		nameLength3: SQL_NTS
]

{ #category : #accessing }
ODBCProceduresStatement >> procedureName [

	^ procedureName
]

{ #category : #accessing }
ODBCProceduresStatement >> procedureName: aString [

	procedureName := aString
]
