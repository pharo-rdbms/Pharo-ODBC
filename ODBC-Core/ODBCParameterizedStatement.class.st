"
A ODBCParameterizedStatement is used to represent a parameterized (prepared) SQL statement to be executed by a <ODBCConnection>.

In general one does not create ODBCParameterizedStatements directly but rather by the use of ODBCConnection>>prepare:. The statement can later be parameterized with the appropriate column attributes using #paramCols: and the parameter values using #values:. The statement must then executed using #exec to perform the actual database query. If any results are expected then a <ODBCResultSet> can be retrieved by sending it a #results message.

Instance Variables:
	values		<Array> of <Object>. The current parameter values.
	parameters	<Array> of <ODBCField>. Buffers to hold the parameter values for the query.
	paramCols		<Array> of ODBCColAttr>. Metadata about the parameters.
	isPrepared		<Boolean>. Flag to indicate whether the statement has been prepared.

Based on DBParameterizedStatement from Dolphin Smalltalk Database Connection package.
"
Class {
	#name : #ODBCParameterizedStatement,
	#superclass : #ODBCStatement,
	#instVars : [
		'values',
		'parameters',
		'paramCols',
		'isPrepared'
	],
	#pools : [
		'ODBCCTypes'
	],
	#category : #'ODBC-Core-Base'
}

{ #category : #operations }
ODBCParameterizedStatement >> bindParams [
	"Private - Bind parameter columns for a prepared SQL statement so that when we 
	subsequently fill the buffer fields the statement is ready to exec. Normally only done 
	just before first exec (from #parameters)."

	| odbc hstmt |
	odbc := ODBCLibrary default.
	hstmt := self allocatedHandle.
	parameters keysAndValuesDo: 
			[:i :eachField |
			| buf column |
			buf := eachField fieldBuf.
			column := eachField column.
			self dbCheckException: (odbc
						sqlBindParameter: hstmt
						parameterNumber: i
						inputOutputType: column parameterType
						valueType: column cType
						parameterType: column type
						columnSize: column precision
						decimalDigits: column scale
						parameterValuePtr: buf
						bufferLength: eachField bufferSize
						strLenOrIndPtr: eachField lengthBuf)]
]

{ #category : #operations }
ODBCParameterizedStatement >> exec [
	"(Re)Execute a prepared statement."

	| ret |
	self close.
	isPrepared
		ifFalse: [self prepare].
	paramCols notNil
		ifTrue: [self setValues].
	ret := ODBCLibrary default sqlExecute: self allocatedHandle.
	self dbCheckException: ret.
	executed := true.

]

{ #category : #'realizing/unrealizing' }
ODBCParameterizedStatement >> free [
	"Release external resources held by the receiver,
	remaining in a consistent state in order that
	the result set could be regenerated."

	isPrepared := false.
	super free.
	parameters := nil
]

{ #category : #accessing }
ODBCParameterizedStatement >> paramCols [
	"Answer the receiver's parameter columns"

	^paramCols
]

{ #category : #accessing }
ODBCParameterizedStatement >> paramCols: anArrayOfColAttrs [
	"Set the receiver's parameter columns to anArrayOfColAttrs"

	paramCols := anArrayOfColAttrs asArray
]

{ #category : #accessing }
ODBCParameterizedStatement >> parameters [
	"Private - Answer the receivers bound parameter fields. On first receipt (usually from 
	#exec) completes lazy evaluation by causing allocation of a statement handle, preparing 
	the statement, creating the array of parameter fields and binding them."

	^parameters
		ifNil: 
			[parameters := paramCols collect: [:col | ODBCField newForCol: col].
			self bindParams.
			parameters]
]

{ #category : #operations }
ODBCParameterizedStatement >> prepare [
	"Private - Prepare the receiver for later execution when the parameter values have 
	been set. N.B. This should only be sent once unless closed in the interm."

	| ret |
	isPrepared := false.
	parameters := nil.
	ret := ODBCLibrary default 
				sqlPrepare: self allocatedHandle
				statementText: (self stringEncoder encodeStringWithNullTerminator: self sqlString)
				textLength: SQL_NTS.
	self dbCheckException: ret.
	isPrepared := true
]

{ #category : #operations }
ODBCParameterizedStatement >> prepare: aString [
	"Private - Prepare the receiver for later execution when the parameter values have 
	been set."

	self sqlString: aString; prepare
]

{ #category : #initializing }
ODBCParameterizedStatement >> reset [
	"Private - Initialize the receiver."

	super reset.
	isPrepared := false.
	parameters := nil.
]

{ #category : #operations }
ODBCParameterizedStatement >> setValues [
	"Private - Copy object values to the bound fields for the parameters of the prepared SQL
	statement. On first receipt this will cause the parameter fields to be created and bound 	(via #parameters)."

	1 to: self parameters size do: [:i |
		(parameters at: i) value: (values at: i)]

]

{ #category : #accessing }
ODBCParameterizedStatement >> values [
	"Answer the array of parameter values."

	^values
]

{ #category : #accessing }
ODBCParameterizedStatement >> values: anArrayOfValues [
	"Set the receiver's parameter values prior to a future #exec."

	self close.
	values := anArrayOfValues
]
