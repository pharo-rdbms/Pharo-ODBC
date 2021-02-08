"
Provides encoding/decoding of UTF16 strings.
"
Class {
	#name : #ODBCUTF16Encoder,
	#superclass : #ODBCStringEncoder,
	#category : #'ODBC-Core-Base'
}

{ #category : #constants }
ODBCUTF16Encoder >> bytesPerCharacter [

	^2
]

{ #category : #constants }
ODBCUTF16Encoder >> characterEncoderClass [

	^ZnUTF16Encoder
]

{ #category : #decoding }
ODBCUTF16Encoder >> decodeNullTerminatedStringFrom: aByteArray [

	"Optimised (~25% faster) equivalent of superclass implementation"

	| stream offset |

	stream := WriteStream on: (String new: 32).
	offset := 1.

	[ | codePoint leadSurrogate trailSurrogate |
	codePoint := aByteArray unsignedShortAt: offset.
	offset := offset + 2.
	(codePoint < 16rD800 or: [codePoint > 16rDFF]) ifFalse: 
		[leadSurrogate :=  codePoint.
		trailSurrogate := aByteArray unsignedShortAt: offset.
		offset := offset + 2.
		codePoint := 16r10000 + ((leadSurrogate - 16rD800) * 16r400 + (trailSurrogate - 16rDC00))].

	(codePoint > 255 and: [ stream originalContents isWideString not ]) ifTrue: 
		[ | wideString position |
		position := stream position.
		wideString := WideString from: stream originalContents.
		stream on: wideString; setFrom: position + 1 to: position ].

	codePoint = 0 or: [ stream nextPut: (Character value: codePoint). false] ] whileFalse.
	
	^stream contents
]

{ #category : #decoding }
ODBCUTF16Encoder >> decodeStringFrom: aByteArray byteCount: anInteger [

	"Optimised (~25% faster) equivalent of superclass implementation"

	| stream offset |

	stream := WriteStream on: (String new: anInteger).
	offset := 1.

	[ offset <= anInteger ] whileTrue: 
		[ | codePoint leadSurrogate trailSurrogate |
		codePoint := aByteArray unsignedShortAt: offset.
		offset := offset + 2.
		(codePoint < 16rD800 or: [codePoint > 16rDFF]) ifFalse: 
			[leadSurrogate :=  codePoint.
			trailSurrogate := aByteArray unsignedShortAt: offset.
			offset := offset + 2.
			codePoint := 16r10000 + ((leadSurrogate - 16rD800) * 16r400 + (trailSurrogate - 16rDC00))].

		(codePoint > 255 and: [ stream originalContents isWideString not ]) ifTrue: 
			[ | wideString position |
			position := stream position.
			wideString := WideString from: stream originalContents.
			stream on: wideString; setFrom: position + 1 to: position ].

		stream nextPut: (Character value: codePoint) ].

	^stream contents
]

{ #category : #constants }
ODBCUTF16Encoder >> nullTerminatorBytes [

	^#[0 0]
]
