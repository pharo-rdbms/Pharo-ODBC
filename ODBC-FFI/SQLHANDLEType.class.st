Class {
	#name : #SQLHANDLEType,
	#superclass : #FFIConstantHandleType,
	#category : #'ODBC-FFI'
}

{ #category : #'emitting code' }
SQLHANDLEType >> emitReturnArgument: builder context: aContext [
	self loader 
		emitPluggableHandleArityUnpack: builder
		type: self
		context: aContext
		objectClass: self objectClass
		instVarName: self instanceVariableName
]

{ #category : #accessing }
SQLHANDLEType >> externalType [

	^self is32BitHandle
		ifTrue: [ super externalType ]
	 	ifFalse: [ ExternalType unsignedLongLong ]
]

{ #category : #testing }
SQLHANDLEType >> is32BitHandle [

	"Always on Windows; by VM type on others"

	^Smalltalk os isWindows or: [ Smalltalk vm is32bit ]
]

{ #category : #constants }
SQLHANDLEType >> unpackHandleFromAritySelector [

	^self is32BitHandle
		ifTrue: [ #unpackHandleFromArity: ]
		ifFalse: [ #unpackULongLongHandleFromArity: ]
]
