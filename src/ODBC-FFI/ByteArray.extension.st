Extension { #name : #ByteArray }

{ #category : #'*ODBC-FFI' }
ByteArray >> asSQLPOINTER [

	^self
]

{ #category : #'*ODBC-FFI' }
ByteArray >> unpackULongLongHandleFromArity: arity [
	"This will 'unpack' a long long (handle) from a certain arity. See #packToArity: for a better explanation."

	arity > 1 ifTrue: [ ^ self error: 'Use ExternalAddress instead!' ].
	^ self unsignedLongLongAt: 1

]
