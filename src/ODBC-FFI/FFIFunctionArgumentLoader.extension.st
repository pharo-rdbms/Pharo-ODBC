Extension { #name : 'FFIFunctionArgumentLoader' }

{ #category : '*ODBC-FFI' }
FFIFunctionArgumentLoader >> emitPluggableHandleArityUnpack: aBuilder type: aType context: aContext objectClass: objectClass instVarName: aName [
	"This a special kind of arity-unpacking, that works with FFIConstantHandleType
	Compared to emithHandleArityUnpack:... this method queries aType for the unpack selector to use"

	aType needsArityUnpacking ifFalse: [ ^ self ].

	"Push accessing variable (this change depending on the argument type)"
	self
		emitArgumentVariableAccesingPart: aBuilder
		context: aContext
		objectClass: objectClass
		instVarName: aName.
	"Unpack argument"
	aBuilder
		pushTemp: self rolledPointerTempName;
		pushLiteral: aType pointerArity;
		send: aType unpackHandleFromAritySelector.
	"Send assignment"
	aBuilder send: #instVarAt:put:.
	"... and return top"
	aBuilder popTop
]
