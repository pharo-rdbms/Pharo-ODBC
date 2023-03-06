"
Provided encoding/decoding of UTF32 strings.
"
Class {
	#name : #ODBCUTF32Encoder,
	#superclass : #ODBCStringEncoder,
	#category : #'ODBC-Core-Base'
}

{ #category : #constants }
ODBCUTF32Encoder >> bytesPerCharacter [

	^4
]

{ #category : #constants }
ODBCUTF32Encoder >> characterEncoderClass [

	^ZnUTF32Encoder
]

{ #category : #constants }
ODBCUTF32Encoder >> nullTerminatorBytes [

	^#[ 0 0 0 0 ]
]
