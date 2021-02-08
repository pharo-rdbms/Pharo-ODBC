Class {
	#name : #ODBCConnectionTestResource,
	#superclass : #TestResource,
	#instVars : [
		'connection',
		'isAvailable'
	],
	#category : #'ODBC-Tests'
}

{ #category : #private }
ODBCConnectionTestResource >> connect [
	connection := self newConnection
]

{ #category : #private }
ODBCConnectionTestResource >> connectString [
	self subclassResponsibility
]

{ #category : #private }
ODBCConnectionTestResource >> connection [
	^connection
]

{ #category : #private }
ODBCConnectionTestResource >> createDatabase [
	"Private - Override in subclasses"

	^self subclassResponsibility
]

{ #category : #private }
ODBCConnectionTestResource >> dropDatabase [
	connection
		ifNotNil: 
			[connection close.
			connection := nil]
]

{ #category : #public }
ODBCConnectionTestResource >> newConnection [
	^isAvailable
		ifTrue: 
			[(ODBCConnection new connectString: self connectString)
				open;
				yourself]
]

{ #category : #public }
ODBCConnectionTestResource >> setUp [
	(isAvailable := self createDatabase) ifTrue: [self connect]
]

{ #category : #public }
ODBCConnectionTestResource >> tearDown [
	self dropDatabase
]
