"
An ODBCTxn instance represents a Database Connection transaction in progress.

Generally one does not explicitly instantiate ODBCTxn instances, but rather one uses the methods ODBCConnection>>beginRWTxn, and ODBCConnection>>beginTxn to create an appropriate type of transaction on a specific connection. 

Instance Variables:
	connection		<ODBCConnection> on which the transaction is active.
	readOnly		<Boolean> flag indicating whether the transaction is read only or not.
	creator		<Object>

Based on DBTxn from Dolphin Smalltalk Database Connection package.
"
Class {
	#name : 'ODBCTxn',
	#superclass : 'Object',
	#instVars : [
		'connection',
		'readOnly',
		'creator'
	],
	#pools : [
		'ODBCConstants'
	],
	#category : 'ODBC-Core-Base',
	#package : 'ODBC-Core',
	#tag : 'Base'
}

{ #category : 'instance creation' }
ODBCTxn class >> newOn: anODBCConnection [
	"Answer an instance of the receiver with commits disabled."

	^ self new
			connection: anODBCConnection;
			beReadOnly;
			yourself
]

{ #category : 'instance creation' }
ODBCTxn class >> newRWOn: anODBCConnection [
	"Answer an instance of the receiver with commits enabled."

	^self new
			connection: anODBCConnection;
			beReadWrite;
			yourself
]

{ #category : 'accessing' }
ODBCTxn >> beReadOnly [
	"Set the receiver's readOnly inst var to true."

	readOnly := true
]

{ #category : 'accessing' }
ODBCTxn >> beReadWrite [
	"Set the receiver's readOnly inst var to false."

	readOnly := false
]

{ #category : 'operations' }
ODBCTxn >> commit [
	"Commit the transaction."

	readOnly ifTrue: [^self rollback].
	self transcriptMessage: 'committing...'.
	ODBCConnection transact: connection action: SQL_COMMIT
]

{ #category : 'accessing' }
ODBCTxn >> connection [
	"Answer the connection instance variable."

	^ connection
]

{ #category : 'initializing' }
ODBCTxn >> connection: anODBCConnection [
	"Private - Set the connection instance variable to anODBCConnection."

	connection := anODBCConnection
]

{ #category : 'development' }
ODBCTxn >> creator: anObject [
	"Private - Set the creator instance variable to anObject."

	creator := anObject.
	self transcriptMessage: 'New transaction...'
]

{ #category : 'printing' }
ODBCTxn >> printOn: aStream [
	"Print a text representation of the receiver on aStream."

	super printOn: aStream.
	aStream
		nextPutAll: '(commits ';
		nextPutAll: (readOnly
			ifTrue: ['disabled']
			ifFalse: ['enabled']);
		nextPutAll: connection dsn;
		nextPutAll: ', belonging to: '.
	creator printOn: aStream.
	aStream
		nextPut: $)
]

{ #category : 'operations' }
ODBCTxn >> rollback [
	"Free up all resources held by the tuples opened during this
	transaction"

	self transcriptMessage: 'rolling back...'.
	ODBCConnection transact: connection action: SQL_ROLLBACK
]

{ #category : 'operations-logging' }
ODBCTxn >> transcriptMessage: aString [
	"Private - Output an appropriately annotated message to the current
	session's trace device. In a development session this is the Transcript"

	creator ifNotNil: [
		Transcript
			print: self;
			space;
			nextPutAll: aString;
			cr ]
]
