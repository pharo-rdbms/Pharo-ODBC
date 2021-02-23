"
ODBCSchemaStatement is the class of Database Connection statements for querying metadata about the schema of a particular database. DBSchemaStatement itself is abstract, with subclasses implementing the commands for querying tables, columns, indices, procedures, primary and foreign key information, etc.
			
Based on DBSchemaStatement from Dolphin Smalltalk Database Connection package.
"
Class {
	#name : #ODBCSchemaStatement,
	#superclass : #ODBCAbstractStatement,
	#instVars : [
		'catalogName',
		'schemaName',
		'tableName'
	],
	#category : #'ODBC-Core-Base'
}

{ #category : #testing }
ODBCSchemaStatement class >> isAbstract [

	^ self == ODBCSchemaStatement
]

{ #category : #accessing }
ODBCSchemaStatement >> catalogName [
	^catalogName
]

{ #category : #accessing }
ODBCSchemaStatement >> catalogName: aString [
	catalogName := aString
]

{ #category : #constants }
ODBCSchemaStatement >> defaultCursorType [
	"Answer the <Symbol>ic name of the default cursor type to be used for statements
	(one of #dynamic, #forwardOnly, #keysetDriven, #static)."

	^#forwardOnly

]

{ #category : #operations }
ODBCSchemaStatement >> executeStatement [
	"Private - Execute the database command that the receiver represents.
	Answer the <integer> return code."

	^self subclassResponsibility
]

{ #category : #accessing }
ODBCSchemaStatement >> schemaName [
	^schemaName
]

{ #category : #accessing }
ODBCSchemaStatement >> schemaName: aStringPattern [
	schemaName := aStringPattern
]

{ #category : #accessing }
ODBCSchemaStatement >> tableName [
	^tableName
]

{ #category : #accessing }
ODBCSchemaStatement >> tableName: aStringPattern [
	tableName := aStringPattern
]
