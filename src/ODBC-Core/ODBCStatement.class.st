"
An ODBCStatement is used to represent an SQL statement to be executed by a <ODBCConnection>.

In general one does not ODBCStatements explicitly but rather by the use of ODBCConnection>>exec: and ODBCConnection>>query:. For pre-prepared statements ODBCConnection>>prepare: can be used to answer an instance of <ODBCParameterizedStatement> which can later be parameterized and executed.

Instance Variables:
	sqlString		<String>. The SQL statement.

Based on DBStatement from Dolphin Smalltalk Database Connection package.
"
Class {
	#name : #ODBCStatement,
	#superclass : #ODBCAbstractStatement,
	#instVars : [
		'sqlString'
	],
	#category : #'ODBC-Core-Base'
}

{ #category : #constants }
ODBCStatement >> defaultCursorType [
	"Answer the <Symbol>ic name of the default cursor type to be used for statements
	(one of #dynamic, #forwardOnly, #keysetDriven, #static).
	Implementation Note: For backwards compatibility use a #keysetDriven cursor
	by default."

	^#keysetDriven
]

{ #category : #operations }
ODBCStatement >> exec: aString [
	"Execute the SQL statement aString using the receiver"

	self sqlString: aString; exec
]

{ #category : #operations }
ODBCStatement >> executeStatement [
	^ODBCLibrary default
		sqlExecDirect: self allocatedHandle
		statementText: (self stringEncoder encodeStringWithNullTerminator: self sqlString)
		textLength: SQL_NTS
]

{ #category : #printing }
ODBCStatement >> printOn: aStream [
	"Print a string representation of self onto aStream"

	aStream
		nextPutAll: 'a ';
		print: self class; space;
		nextPut: $(;
		print: self sqlString;
		nextPut: $)
]

{ #category : #accessing }
ODBCStatement >> sqlString [
	"Answer the sqlString instance variable."

	^sqlString
]

{ #category : #accessing }
ODBCStatement >> sqlString: aString [
	"Private - Set the sqlString instance variable to aString.
	N.B. Changing the SQL string after executing the statement (either directly
	or lazily by examing the result set) has no effect."

	sqlString := aString
]
