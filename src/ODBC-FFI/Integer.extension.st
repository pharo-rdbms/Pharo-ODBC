Extension { #name : #Integer }

{ #category : #'*ODBC-FFI' }
Integer >> asSQLPOINTER [

	^ExternalAddress new fromInteger: self
]

{ #category : #'*ODBC-FFI' }
Integer >> tfPointerAddress [

	"For headless VM FFI handling of SQLHANDLE handle"

    ^ExternalAddress new fromInteger: self
]
