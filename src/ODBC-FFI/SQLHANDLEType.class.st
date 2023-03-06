Class {
	#name : #SQLHANDLEType,
	#superclass : #FFIConstantHandleType,
	#category : #'ODBC-FFI-SQL-Types'
}

{ #category : #'emitting code' }
SQLHANDLEType >> basicEmitArgument: aBuilder context: aContext inCallout: aCallout [

	"Pharo 9: differing semantics needed for TFFIBackend"

	^(self class environment at: #FFIBackend ifPresent: [ :ffiBackend | ffiBackend current class name = #TFFIBackend] ifAbsent: [ false ])
		ifTrue: [ self loader emitArgument: aBuilder context: aContext ]
		ifFalse: [ super basicEmitArgument: aBuilder context: aContext inCallout: aCallout ]
]

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
