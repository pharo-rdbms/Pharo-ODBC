Extension { #name : 'Integer' }

{ #category : '*ODBC-FFI' }
Integer >> asSQLPOINTER [

	^ExternalAddress new fromInteger: self
]
