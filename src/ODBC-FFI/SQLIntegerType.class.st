"
Abstract superclass for different SQL integer types
"
Class {
	#name : 'SQLIntegerType',
	#superclass : 'ExternalStructure',
	#category : 'ODBC-FFI-SQL-Types',
	#package : 'ODBC-FFI',
	#tag : 'SQL-Types'
}

{ #category : 'instance creation' }
SQLIntegerType class >> fromInteger: anInteger [
	"Answer a new instance of the receiver with contents copied from anInteger"

	^ self new value: anInteger
]

{ #category : 'testing' }
SQLIntegerType class >> isAbstract [

	^ self == SQLIntegerType
]

{ #category : 'instance creation' }
SQLIntegerType class >> new [

	^ self externalNew
]

{ #category : 'converting' }
SQLIntegerType >> asInteger [

	^self value
]

{ #category : 'accessing structure variables' }
SQLIntegerType >> asSQLPOINTER [

	^self getHandle
]

{ #category : 'accessing structure variables' }
SQLIntegerType >> pointer [

	^self getHandle
]
