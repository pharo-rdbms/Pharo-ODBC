Class {
	#name : #SQLHANDLE,
	#superclass : #FFIConstantHandle,
	#category : #'ODBC-FFI-SQL-Types'
}

{ #category : #converting }
SQLHANDLE class >> asExternalTypeOn: generator [
	^ SQLHANDLEType objectClass: self
]

{ #category : #'system startup' }
SQLHANDLE class >> byteSize [

	^4
]

{ #category : #'class initialization' }
SQLHANDLE class >> initialize [

	"
	self initialize
	"

	Smalltalk addToStartUpList: self
]

{ #category : #'instance creation' }
SQLHANDLE class >> null [

	^self fromInteger: 0
]

{ #category : #'system startup' }
SQLHANDLE class >> startUp: isImageStarting [
	"Private - Ensure that old external resources are cleared so that they will be re-created."

	isImageStarting ifTrue: [self allInstancesDo: [ :each | each invalidateHandle]]
]

{ #category : #initialization }
SQLHANDLE >> invalidateHandle [

	handle := 0
]

{ #category : #testing }
SQLHANDLE >> isNull [ 

	^handle = 0
]
