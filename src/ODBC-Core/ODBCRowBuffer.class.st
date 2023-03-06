"
ODBCRowBuffers are used to describe and buffer the columns of the current row in a <ODBCResultSet>.
			
Based on DBRowBuffer from Dolphin Smalltalk Database Connection package.
"
Class {
	#name : #ODBCRowBuffer,
	#superclass : #ODBCAbstractRow,
	#category : #'ODBC-Core-Base'
}

{ #category : #converting }
ODBCRowBuffer >> asObject [
	"Private - Answer the receiver as an instance of ODBCRow containing the receiver's values."

	^ ODBCRow fromBuffer: self
]

{ #category : #operations }
ODBCRowBuffer >> bind: aDBStatement [
	"Private - Bind the receiver's field buffers to columns in the result table."

	| hStmt |
	hStmt := aDBStatement executedHandle.
	self flag: #TODO. "Will need an array of status values if to fetch a block of rows at a time".
	status := SQLUSMALLINT new.
	aDBStatement statusArray: status.
	^ hStmt
]

{ #category : #accessing }
ODBCRowBuffer >> contents [
	"Answer the contents instance variable."

	contents ifNil: [ contents := columns collect: [:colAttr | ODBCField newForCol: colAttr ]].
	^ contents
]

{ #category : #accessing }
ODBCRowBuffer >> objects [
	"Private - Answer the receivers contents as an <Array> of <Object>s
	representing the value of each column."

	^ self contents collect: [:c | c value ]
]

{ #category : #accessing }
ODBCRowBuffer >> sizeInBytes [
	"Answer the size of the receiver structure in bytes."

	 ^ self contents inject: 0 into: [:size :f | size + f size ]
]

{ #category : #accessing }
ODBCRowBuffer >> status [

	^ status value
]
