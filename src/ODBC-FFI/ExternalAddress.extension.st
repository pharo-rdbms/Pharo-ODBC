Extension { #name : 'ExternalAddress' }

{ #category : '*ODBC-FFI' }
ExternalAddress >> unpackULongLongHandleFromArity: arity [
	^ (self unpackFromArity: arity) unsignedLongLongAt: 1
]
