"
Common superclass for ODBC test resources
"
Class {
	#name : #ODBCConnectionTestResource,
	#superclass : #TestResource,
	#instVars : [
		'connection',
		'isAvailable'
	],
	#category : #'ODBC-Tests-Resources'
}

{ #category : #testing }
ODBCConnectionTestResource class >> isAbstract [

	^ self == ODBCConnectionTestResource
]

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

	connection ifNotNil: [
		connection close.
		connection := nil ]
]

{ #category : #public }
ODBCConnectionTestResource >> newConnection [

	^ isAvailable ifTrue: [
		  | tmp2 |
		  tmp2 := ODBCConnection new connectString: self connectString.
		  tmp2
			  open;
			  yourself ]
]

{ #category : #running }
ODBCConnectionTestResource >> setUp [

	super setUp.
	(isAvailable := self createDatabase) ifTrue: [ self connect ]
]

{ #category : #running }
ODBCConnectionTestResource >> tearDown [

	self dropDatabase.
	super tearDown
]
