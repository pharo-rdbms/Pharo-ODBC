Class {
	#name : #ODBCTest,
	#superclass : #TestCase,
	#instVars : [
		'connection'
	],
	#category : #'ODBC-Tests-Base'
}

{ #category : #testing }
ODBCTest class >> isAbstract [

	^self == ODBCTest
]

{ #category : #helpers }
ODBCTest >> databaseResource [
	^AccessNorthwindDB current
]

{ #category : #helpers }
ODBCTest >> employeeNames [
	^#('Davolio' 'Fuller' 'Leverling' 'Peacock' 'Buchanan' 'Suyama' 'King' 'Callahan' 'Dodsworth')
]

{ #category : #helpers }
ODBCTest >> field: aString fromRow: anODBCRow [
	^anODBCRow at: aString
]

{ #category : #running }
ODBCTest >> setUp [
	super setUp.
	connection := self databaseResource newConnection.
	self skipUnless: [connection notNil]
]

{ #category : #helpers }
ODBCTest >> skipUnless: aNiladicValuable [
	"If the assumption in the <niladicValuable> argument evaluates to false, abandon the running test and mark it as skipped."

	aNiladicValuable value ifFalse: [ self skip: 'Assumption in #skipUnless: failed' ]
]

{ #category : #running }
ODBCTest >> tearDown [
	connection ifNotNil: [:cnxn | cnxn close].
	super tearDown
]

{ #category : #'unit tests' }
ODBCTest >> testCollect [
	| names rs |
	rs := connection query: 'select LastName from employees'.
	2 timesRepeat:
			[names := rs collect: [:each | self field: 'LastName' fromRow: each].
			self assertCollection: names hasSameElements: self employeeNames].
	rs := connection query: 'select LastName from employees where LastName = ''Bower'''.
	2 timesRepeat:
			[names := rs collect: [:each | (each at: 1) value].
			self assert: names isEmpty]
]

{ #category : #'unit tests' }
ODBCTest >> testIsEmpty [
	| results |
	results := connection query: 'select count(*) from categories'.
	self deny: results isEmpty.
	results := connection
				query: 'select CategoryID, CategoryName from categories where CategoryID is Null'.
	self assert: results isEmpty.
	results := connection query: 'select CategoryID, CategoryName from categories where CategoryID = 1'.
	self deny: results isEmpty
]
