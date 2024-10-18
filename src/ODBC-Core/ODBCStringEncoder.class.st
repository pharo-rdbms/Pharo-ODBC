"
Provides encoding/decoding of Unicode strings.
"
Class {
	#name : 'ODBCStringEncoder',
	#superclass : 'Object',
	#instVars : [
		'characterEncoder'
	],
	#category : 'ODBC-Core-Base',
	#package : 'ODBC-Core',
	#tag : 'Base'
}

{ #category : 'testing' }
ODBCStringEncoder class >> isAbstract [

	^ self == ODBCStringEncoder
]

{ #category : 'encoding' }
ODBCStringEncoder >> byteSizeForCharacters: anInteger [

	^anInteger * self bytesPerCharacter
]

{ #category : 'encoding' }
ODBCStringEncoder >> byteSizeForString: aString [

	^ self byteSizeForCharacters: aString size
]

{ #category : 'constants' }
ODBCStringEncoder >> bytesPerCharacter [

	^ self subclassResponsibility
]

{ #category : 'accessing' }
ODBCStringEncoder >> characterEncoder [
	"Appears to lose endian-ness (at image start?) so always reset"

	^ characterEncoder beLittleEndian
]

{ #category : 'constants' }
ODBCStringEncoder >> characterEncoderClass [

	"Return the appropriate ZnCharacterEncoder subclass for the receiver"

	^self subclassResponsibility
]

{ #category : 'decoding' }
ODBCStringEncoder >> decodeNullTerminatedStringFrom: aByteArray [

	^ (self characterEncoder decodeBytes: aByteArray) readStream upTo: Character null
]

{ #category : 'decoding' }
ODBCStringEncoder >> decodeStringFrom: aByteArray byteCount: anInteger [

	^ self characterEncoder decodeBytes: (aByteArray first: anInteger)
]

{ #category : 'decoding' }
ODBCStringEncoder >> decodeStringFrom: aByteArray characterCount: anInteger [

	^ self decodeStringFrom: aByteArray byteCount: (self byteSizeForCharacters: anInteger)
]

{ #category : 'encoding' }
ODBCStringEncoder >> encodeString: aString [

	^ aString ifNotNil: [self characterEncoder encodeString: aString]
]

{ #category : 'encoding' }
ODBCStringEncoder >> encodeStringWithNullTerminator: aString [

	^ aString ifNotNil: [(self encodeString: aString), self nullTerminatorBytes]
]

{ #category : 'initialization' }
ODBCStringEncoder >> initialize [

	characterEncoder := self characterEncoderClass new beLittleEndian
]

{ #category : 'constants' }
ODBCStringEncoder >> nullTerminatorBytes [
	"Should be size == self bytesPerCharacter"

	^ self subclassResponsibility
]

{ #category : 'encoding' }
ODBCStringEncoder >> stringBufferFor: anInteger [
	"Create, allocate and return a buffer (ExternalAddress) to hold anInteger characters in the receiver's encoding"

	"For convenience always add 1 for a null terminator - allows this method to be used for all String API calls"
	^ ExternalAddress gcallocate: (self byteSizeForCharacters: (anInteger + 1))
]
