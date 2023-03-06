"
An ODBCField instance represents a column buffer for holding data as part of a ODBCRow.

A field's value may be converted to a Smalltalk object by sending #value, and conversely may be assigned with #value:.

Instance Variables:
	column		<ODBCColAttr>. Metadata about the column
	buffer		<ByteArray>. Buffer to hold column data.
	lengthBuf		<SDWORD>. 32-bit integer buffer to hold column data length.

Class Variables:
	GetSelectors	<Array> of <Symbol>. Maps integer type codes to accessor for that type.
	SetSelectors	<Array> of <Symbol>. Maps integer type codes to mutator for that type.

Based on DBField from Dolphin Smalltalk Database Connection package.
"
Class {
	#name : #ODBCField,
	#superclass : #Object,
	#instVars : [
		'column',
		'buffer',
		'bufferSize',
		'lengthBuf'
	],
	#classVars : [
		'GetSelectors',
		'SetSelectors'
	],
	#pools : [
		'ODBCCTypes',
		'ODBCConstants',
		'ODBCRetCodes',
		'ODBCTypes'
	],
	#category : #'ODBC-Core-Base'
}

{ #category : #'class initialization' }
ODBCField class >> initialize [
	"Initialize the dictionaries of to/from
	C Type/Smalltalk object converters.
		DBField initialize
	Note that the maps rely on the sequential numbering of the type enumerations.
	"

	"Note that the mappings here must match those defined for the mappings between SQL and 'C' buffer types in the DBColAttr class>>#initialize.
	Ideally these maps would just be from the SQL_C_xxx types, avoiding the need to keep in sync with the DBColAttr map, but at present the need
	to convert SQL_NUMERIC via SQL_C_CHAR prevents that."

	self assert: [TypeOffset = (SQL_GUID abs + 1)].
	self assert: [SQL_NUM_TYPES = (TypeOffset + SQL_TYPE_TIMESTAMP)].
	GetSelectors :=
		((Array new: SQL_NUM_TYPES)
				at: SQL_CHAR + TypeOffset put: #getAnsiString;
				at: SQL_VARCHAR + TypeOffset put: #getAnsiString;
				at: SQL_LONGVARCHAR + TypeOffset put: #getAnsiString;
				at: SQL_WCHAR + TypeOffset put: #getUtf16String;
				at: SQL_WVARCHAR + TypeOffset put: #getUtf16String;
				at: SQL_WLONGVARCHAR + TypeOffset put: #getUtf16String;
				at: SQL_BINARY + TypeOffset put: #getByteArray;
				at: SQL_VARBINARY + TypeOffset put: #getByteArray;
				at: SQL_LONGVARBINARY + TypeOffset put: #getByteArray;
				at: SQL_BIT + TypeOffset put: #getBoolean;
				at: SQL_TINYINT + TypeOffset put: #getByte;
				at: SQL_SMALLINT + TypeOffset put: #getShort;
				at: SQL_INTEGER + TypeOffset put: #getLong;
				at: SQL_BIGINT + TypeOffset put: #getInt64;
				at: SQL_NUMERIC + TypeOffset put: #numberFromNumeric;
				at: SQL_DECIMAL + TypeOffset put: #numberFromNumeric;
				at: SQL_FLOAT + TypeOffset put: #getDouble;
				at: SQL_REAL + TypeOffset put: #getFloat;
				at: SQL_DOUBLE + TypeOffset put: #getDouble;
				at: SQL_TYPE_DATE + TypeOffset put: #getDate;
				at: SQL_TYPE_TIME + TypeOffset put: #getTime;
				at: SQL_TYPE_TIMESTAMP + TypeOffset put: #getDateAndTime;
				at: SQL_GUID + TypeOffset put: #getGuid;
				yourself).
	SetSelectors :=
		((Array new: SQL_NUM_TYPES)
				at: SQL_CHAR + TypeOffset put: #setAnsiString:;
				at: SQL_VARCHAR + TypeOffset put: #setAnsiString:;
				at: SQL_LONGVARCHAR + TypeOffset put: #setAnsiString:;
				at: SQL_WCHAR + TypeOffset put: #setUtf16String:;
				at: SQL_WVARCHAR + TypeOffset put: #setUtf16String:;
				at: SQL_WLONGVARCHAR + TypeOffset put: #setUtf16String:;
				at: SQL_BINARY + TypeOffset put: #setByteArray:;
				at: SQL_VARBINARY + TypeOffset put: #setByteArray:;
				at: SQL_LONGVARBINARY + TypeOffset put: #setByteArray:;
				at: SQL_TINYINT + TypeOffset put: #setByte:;
				at: SQL_BIT + TypeOffset put: #setBoolean:;
				at: SQL_SMALLINT + TypeOffset put: #setShort:;
				at: SQL_INTEGER + TypeOffset put: #setLong:;
				at: SQL_BIGINT + TypeOffset put: #setInt64:;
				at: SQL_NUMERIC + TypeOffset put: #numberToNumeric:;
				at: SQL_DECIMAL + TypeOffset put: #numberToNumeric:;
				at: SQL_FLOAT + TypeOffset put: #setDouble:;
				at: SQL_REAL + TypeOffset put: #setFloat:;
				at: SQL_DOUBLE + TypeOffset put: #setDouble:;
				at: SQL_TYPE_DATE + TypeOffset put: #setDate:;
				at: SQL_TYPE_TIME + TypeOffset put: #setTime:;
				at: SQL_TYPE_TIMESTAMP + TypeOffset put: #setDateAndTime:;
				at: SQL_GUID + TypeOffset put: #setGuid:;
				yourself)
]

{ #category : #'instance creation' }
ODBCField class >> new [
	"Use #newForCol:"

	^ self shouldNotImplement
]

{ #category : #'instance creation' }
ODBCField class >> newForCol: aDBColAttr [
	"Answer a new instance of the receiver for the column described by aColAttr."

	^ super new
		initializeForColumn: aDBColAttr
]

{ #category : #comparing }
ODBCField >> = comparand [
	"Answer whether the receiver and the <Object>, comparand,
	are considered equivalent."

	^ comparand species == self species and: [
		column = comparand column and: [self value = comparand value]]
]

{ #category : #accessing }
ODBCField >> beNull [
	"Set the receiver to be a null valued field."

	lengthBuf value: SQL_NULL_DATA
]

{ #category : #accessing }
ODBCField >> bufferSize [
	"Private - Answer the size of the receiver's buffer."

	^ bufferSize
]

{ #category : #accessing }
ODBCField >> column [

	^ column
]

{ #category : #accessing }
ODBCField >> fieldBuf [
	"Private - Answer the address of the buffer for passing to the ODBC DLL."

	^ buffer
]

{ #category : #accessing }
ODBCField >> fieldSize [
	"Private - Answer the 'C' length of the receiver's associated column (the C length includes space for the null
	terminator if the column is a string)"

	^ column lengthC
]

{ #category : #converting }
ODBCField >> getAnsiString [
	"Private - Answer a <ByteString> read from the receiver's buffer, i.e. to read from a SQL_C_CHAR, SQL_C_VARCHAR, or SQL_C_LONGVARCHAR buffer."

	| length result  |

	length := lengthBuf value.
	result := ByteString new: length.
	LibC memCopy: buffer to: result size: length.
	^ result
]

{ #category : #converting }
ODBCField >> getBoolean [
	"Private - Answer a <Boolean> read from the receiver's buffer."

	^ self getByte allMask: 1
]

{ #category : #converting }
ODBCField >> getByte [
	"Private - Answer the receiver's buffer as an unsigned byte."

	^ buffer unsignedByteAt: 1
]

{ #category : #converting }
ODBCField >> getByteArray [
	"Private - Answer a <ByteArray> copied from the receiver's buffer."

	^ buffer copyFrom: 1 to: lengthBuf value
]

{ #category : #accessing }
ODBCField >> getData: aDBStatement [
	"Private - Retrieve the receiver's associated column data from the ODBC result set
	following a fetch (into the receiver's buffer)."

	| ret |
	ret := ODBCLibrary default
				sqlGetData: aDBStatement executedHandle
				columnNumber: column columnNumber
				targetType: column cType
				targetValuePtr: buffer
				bufferLength: bufferSize
				strLenOrIndPtr: lengthBuf.
	aDBStatement dbCheckException: ret
]

{ #category : #converting }
ODBCField >> getDate [
	"Private - Answer an instance of <Date> representing the contents of the receiver.
	Use the services of the ODBCDATE structure to split the buffer."

	^ (ODBCDATE fromHandle: buffer) asDate
]

{ #category : #converting }
ODBCField >> getDateAndTime [
	"Private - Answer an instance of <DateAndTime> representing the same DateAndTime as that stored in the buffer as an ODBCDATE and ODBCTIME."

	^ (ODBCTIMESTAMP fromHandle: buffer) asDateAndTime
]

{ #category : #converting }
ODBCField >> getDouble [
	"Private - Answer a <Float> read from the IEEE 64-bit double precision floating point number in the receiver's buffer."

	^ buffer doubleAt: 1
]

{ #category : #converting }
ODBCField >> getFloat [
	"Private - Answer a <Float> representing the 32-bit IEEE single precision floating point number in the receiver's buffer."

	^ buffer floatAt: 1
]

{ #category : #converting }
ODBCField >> getGuid [
	"Private - Answer a <UUID> read from the receiver's buffer."

	| result  |
	result := UUID new.
	LibC memCopy: buffer to: result size: result size.
	^ result
]

{ #category : #converting }
ODBCField >> getInt64 [
	"Private - Answer an <integer> read from the 64-bit signed integer in the receiver's buffer."

	^ buffer signedLongLongAt: 1
]

{ #category : #converting }
ODBCField >> getLong [
	"Private - Answer an <integer> read from the 32-bit signed integer in the receiver's buffer."

	^ buffer signedLongAt: 1
]

{ #category : #converting }
ODBCField >> getShort [
	"Private - Answer an <integer> read from the signed 16-bit value in the receiver's buffer."

	^ buffer signedShortAt: 1
]

{ #category : #converting }
ODBCField >> getTime [
	"Private - Answer an instance of <Time> representing the buffer of the receiver.
	Use the services of the <ODBCTIME> structure to split the buffer."

	^ (ODBCTIME fromHandle: buffer) asTime
]

{ #category : #converting }
ODBCField >> getUtf16String [
	"Private - Answer the receiver's buffer as an appropriate String (ByteString, WideString), i.e. to read from a SQL_C_WCHAR, SQL_C_WVARCHAR, or SQL_C_WLONGVARCHAR buffer."

	^ self stringEncoder decodeStringFrom: buffer byteCount: lengthBuf value
]

{ #category : #comparing }
ODBCField >> hash [
	"Answer the <integer> hash value for the receiver. Must be the same for any two DBField's that compare equal."

	^ column hash bitXor: self value hash
]

{ #category : #accessing }
ODBCField >> initializeForColumn: aDBColAttr [
	"Private - Initialize the receiver to represent a value from
	the database column described by the <DBColAttr> argument.
	Answer the receiver."

	lengthBuf := SQLLEN fromInteger: SQL_NULL_DATA.
	column := aDBColAttr.
	bufferSize := ("2 raisedTo: 16" 65536) min: aDBColAttr lengthC.
	buffer := ExternalAddress gcallocate: bufferSize.
	^self
]

{ #category : #testing }
ODBCField >> isNull [
	"Answer whether the receiver represents a null field."

	^ lengthBuf value == SQL_NULL_DATA
]

{ #category : #accessing }
ODBCField >> lengthBuf [
	"Private - Answer the address of the length buffer for passing to ODBC"

	^ lengthBuf
]

{ #category : #converting }
ODBCField >> numberFromNumeric [
	"Private - Answer the receiver's contents converted from a
	string NUMERIC to a <ScaledDecimal> (ODBC converts NUMERIC
	fields to strings by default, but NUMERIC is a decimal type)."

	| integerPart number fractionPart scale char isNegative stream |

	stream := ReadStream on: self getByteArray.
	integerPart := 0.
	scale := 0.
	isNegative := stream peekFor: ($- codePoint).
	[stream atEnd or: [(char := stream next) == ($. codePoint)]]
		whileFalse: [integerPart := integerPart * 10 + (char - ($0 codePoint))].
	fractionPart := 0.
	[stream atEnd] whileFalse:
			[char := stream next.
			fractionPart := fractionPart * 10 + (char - ($0 codePoint)).
			scale := scale + 1].
	number := fractionPart / (10 raisedToInteger: scale) + integerPart.
	isNegative ifTrue: [number := number negated].
	^ ScaledDecimal newFromNumber: number scale: scale
]

{ #category : #converting }
ODBCField >> numberToNumeric: aNumber [
	"Private - Convert the argument to a 'C' string stored in the receiver for passing to ODBC (probably as a
	bound parameter) where a NUMERIC is expected."

	#todo. "Define and use the SQL_NUMERIC_STRUCT instead of converting to a string"
	(self shouldTranslate: aNumber class: Number) 	ifTrue: [
		self setAnsiString: ((aNumber asScaledDecimal: column scale) displayString allButLast: 2)]
]

{ #category : #printing }
ODBCField >> printOn: aStream [
	"Append the ASCII representation of the receiver to aStream."

	super printOn: aStream.
	aStream
		nextPut: $(;
		nextPutAll: column name;
		nextPut: $=;
		print: self value;
		nextPut: $)
]

{ #category : #converting }
ODBCField >> setAnsiString: aString [
	"Private - Set the receiver's buffer from aString."

	| ansi byteCount |
	(self shouldTranslate: aString class: String) ifFalse: [ ^ self ].
	ansi := aString asByteString.
	byteCount := ansi size.
	buffer
		replaceFrom: 1
		to: byteCount
		with: ansi
		startingAt: 1.
	lengthBuf value: byteCount
]

{ #category : #converting }
ODBCField >> setBoolean: aBoolean [
	"Private - Load the receiver's contents buffer with the <Boolean> argument."
	
	(self shouldTranslate: aBoolean class: Boolean) ifFalse: [ ^ self ].
	buffer byteAt: 1 put: aBoolean asBit.
	lengthBuf value: 1
]

{ #category : #converting }
ODBCField >> setByte: aNumber [
	"Private - Set the receiver's buffer to an unsigned byte representation of the
	<Number> argument."
	
	(self shouldTranslate: aNumber class: Number) ifFalse: [ ^ self ].
	buffer byteAt: 1 put: aNumber asInteger.
	lengthBuf value: 1
]

{ #category : #converting }
ODBCField >> setByteArray: aByteArray [
	"Private - Set the receiver's buffer from the <ByteArray> argument."

	| byteCount |
	(self shouldTranslate: aByteArray class: ByteArray) ifFalse: [ ^ self ].
	byteCount := aByteArray size min: bufferSize.
	buffer
		replaceFrom: 1
		to: byteCount
		with: aByteArray
		startingAt: 1.
	lengthBuf value: byteCount
]

{ #category : #converting }
ODBCField >> setDate: aDate [
	"Private - Set the receiver's buffer with an <ODBCDATE> object instantiated from
	the <Date> argument."

	(self shouldTranslate: aDate class: Date) ifFalse: [ ^ self ].
	(ODBCDATE fromHandle: buffer) date: aDate.
	lengthBuf value: ODBCDATE byteSize
]

{ #category : #converting }
ODBCField >> setDateAndTime: aDateAndTime [
	"Private - Set the receiver's buffer with an ODBCTIMESTAMP object instantiated from aDateAndTime."

	(self shouldTranslate: aDateAndTime class: DateAndTime) ifFalse: [
		^ self ].
	(ODBCTIMESTAMP fromHandle: buffer) dateAndTime: aDateAndTime.
	lengthBuf value: ODBCTIMESTAMP byteSize
]

{ #category : #converting }
ODBCField >> setDouble: aNumber [
	"Private - Set the receiver's double buffer with <Float> value of the
	<Number> argument."

	(self shouldTranslate: aNumber class: Number) ifFalse: [ ^ self ].
	buffer doubleAt: 1 put: aNumber asFloat.
	lengthBuf value: 8
]

{ #category : #converting }
ODBCField >> setFloat: aNumber [
	"Private - Set the receiver's float buffer with the <Float> value of the
	<Number> argument, aNumber."

	(self shouldTranslate: aNumber class: Number) ifFalse: [ ^ self ].
	buffer floatAt: 1 put: aNumber asFloat.
	lengthBuf value: 4
]

{ #category : #converting }
ODBCField >> setGuid: aUUID [
	"Private - Set the receiver's buffer with an <GUID> value."

	(self shouldTranslate: aUUID class: UUID) ifFalse: [ ^ self ].
	buffer
		replaceFrom: 1
		to: 16
		with: aUUID
		startingAt: 1.
	lengthBuf value: 16
]

{ #category : #converting }
ODBCField >> setInt64: aNumber [
	"Private - Set the receiver's buffer to the 64-bit signed integer value of the argument."

	(self shouldTranslate: aNumber class: Number) ifFalse: [ ^ self ].
	buffer signedLongLongAt: 1 put: aNumber asInteger.
	lengthBuf value: 8
]

{ #category : #converting }
ODBCField >> setLong: aNumber [
	"Private - Set the receiver's buffer to a 32-bit signed integer representation of the <Integer> argument."
	
	(self shouldTranslate: aNumber class: Number) ifFalse: [ ^ self ].
	buffer signedLongAt: 1 put: aNumber asInteger.
	lengthBuf value: 4
]

{ #category : #converting }
ODBCField >> setShort: aNumber [
	"Private - Set the receiver's buffer to the 16-bit signed integer value of the argument."
	
	(self shouldTranslate: aNumber class: Number) ifFalse: [ ^ self ].
	buffer signedShortAt: 1 put: aNumber asInteger.
	lengthBuf value: 2
]

{ #category : #converting }
ODBCField >> setTime: aTime [
	"Private - Set the receiver's buffer with an ODBCTIME object instantiated from aTime."

	(self shouldTranslate: aTime class: Time) ifFalse: [ ^ self ].
	(ODBCTIME fromHandle: buffer) time: aTime.
	lengthBuf value: ODBCTIME byteSize
]

{ #category : #converting }
ODBCField >> setUtf16String: aString [
	"Private - Set the receiver's buffer from aString."

	| utf16 byteCount |
	(self shouldTranslate: aString class: String) ifFalse: [ ^ self ].
	utf16 := self stringEncoder encodeString: aString.
	byteCount := utf16 size.
	buffer
		replaceFrom: 1
		to: byteCount
		with: utf16
		startingAt: 1.
	lengthBuf value: byteCount
]

{ #category : #accessing }
ODBCField >> shouldTranslate: anObject class: aClass [
	"Private - Answer whether the receiver should attempt to translate anObject into its buffer.
	If anObject isNil then we can set the receiver to be null and answer false.
	If anObject does not descend from aClass then issue an error and answer false."

	(anObject isKindOf: aClass)
		ifFalse: [
			self error: anObject class displayString, '(', anObject displayString,') invalid: ', aClass displayString,' expected'.
			^ false].
	^ true
]

{ #category : #accessing }
ODBCField >> size [
	"Private - Answer the size of the receiver's buffer."

	self error: 'do not use this'
]

{ #category : #accessing }
ODBCField >> stringEncoder [

	^ ODBCConnection stringEncoder
]

{ #category : #accessing }
ODBCField >> value [
	"Answer the contents of the receiver as a suitable
	Smalltalk object."

	^ self isNull ifFalse: [
		  self perform: (GetSelectors at: column type + TypeOffset) ]
]

{ #category : #accessing }
ODBCField >> value: anObject [
	"Set the contents of the receiver's buffer from anObject."

	^ anObject ifNil: [ self beNull ] ifNotNil: [
		  self
			  perform: (SetSelectors at: column type + TypeOffset)
			  with: anObject ]
]
