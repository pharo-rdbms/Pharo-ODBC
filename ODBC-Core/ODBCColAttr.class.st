"
An ODBCColAttr instance describes an SQL column in a table or in a ODBCRow within a ODBCResultSet. 

Instance Variables:
	columnNumber	<Integer>. Index of column in the result set.
	name		<String>. Name of column.
	length		<Integer>. Length (bytes) of the column.
	sqlType		<Integer>. Type code.
	precision		<Integer>. Number of characters/digits. 
	scale		<Integer>. Digits after decimal point.
	special		<Integer>. Flags.

Based on DBColAttr from Dolphin Smalltalk Database Connection package.

"
Class {
	#name : #ODBCColAttr,
	#superclass : #Object,
	#instVars : [
		'columnNumber',
		'name',
		'length',
		'sqlType',
		'precision',
		'scale',
		'special'
	],
	#classVars : [
		'CTypesExtraBytes',
		'SQLToCTypes'
	],
	#pools : [
		'ODBCCTypes',
		'ODBCColFlags',
		'ODBCConstants',
		'ODBCTypes'
	],
	#category : #'ODBC-Core-Base'
}

{ #category : #'class initialization' }
ODBCColAttr class >> initialize [
	"Private - Initialize the receiver's class variables.
		self initialize
	"

	"The types to convert the result data to on loading into our buffers - normally these are the default conversions
	 because they are sensible for most things except GUIDs (where the default string conversion doesn't match 
	 the reported column length, which makes allocating an appropriately sized buffer tricky)."

	"The 'C' buffer types specified here must match up with the 'get' conversions defined for the SQL column type in the DBField class (see DBField>>#initialize)"

	SQLToCTypes := 
		((Array new: SQL_NUM_TYPES)
				at: SQL_CHAR + TypeOffset put: SQL_C_CHAR;
				at: SQL_VARCHAR + TypeOffset put: SQL_C_CHAR;
				at: SQL_LONGVARCHAR + TypeOffset put: SQL_C_CHAR;
				at: SQL_WCHAR + TypeOffset put: SQL_C_WCHAR;
				at: SQL_WVARCHAR + TypeOffset put: SQL_C_WCHAR;
				at: SQL_WLONGVARCHAR + TypeOffset put: SQL_C_WCHAR;
				at: SQL_BINARY + TypeOffset put: SQL_C_BINARY;
				at: SQL_VARBINARY + TypeOffset put: SQL_C_BINARY;
				at: SQL_LONGVARBINARY + TypeOffset put: SQL_C_BINARY;
				at: SQL_BIT + TypeOffset put: SQL_C_BIT;
				at: SQL_TINYINT + TypeOffset put: SQL_C_TINYINT;
				at: SQL_SMALLINT + TypeOffset put: SQL_C_SHORT;
				at: SQL_INTEGER + TypeOffset put: SQL_C_LONG;
				at: SQL_BIGINT + TypeOffset put: SQL_C_SBIGINT;
				at: SQL_NUMERIC + TypeOffset put: SQL_C_CHAR;
				at: SQL_DECIMAL + TypeOffset put: SQL_C_CHAR;
				at: SQL_FLOAT + TypeOffset put: SQL_C_DOUBLE;
				at: SQL_REAL + TypeOffset put: SQL_C_FLOAT;
				at: SQL_DOUBLE + TypeOffset put: SQL_C_DOUBLE;
				at: SQL_TYPE_DATE + TypeOffset put: SQL_C_TYPE_DATE;
				at: SQL_TYPE_TIME + TypeOffset put: SQL_C_TYPE_TIME;
				at: SQL_TYPE_TIMESTAMP + TypeOffset put: SQL_C_TYPE_TIMESTAMP;
				at: SQL_GUID + TypeOffset put: SQL_C_GUID;
				at: SQL_TYPE_NULL + TypeOffset put: SQL_C_DEFAULT;
				yourself).
	
	self initializeExtraBytes 
]

{ #category : #'private - initialization' }
ODBCColAttr class >> initializeExtraBytes [

	| extraBytes |
	
	extraBytes := Array new: SQL_NUM_TYPES withAll: 0.
	SQLToCTypes keysAndValuesDo: 
			[:eachKey :eachValue |
			eachValue == SQL_C_CHAR ifTrue: [extraBytes at: eachKey put: 1].
			eachValue == SQL_C_WCHAR ifTrue: [extraBytes at: eachKey put: ODBCConnection stringEncoder bytesPerCharacter]].
	CTypesExtraBytes := extraBytes
]

{ #category : #accessing }
ODBCColAttr >> byteSizeForCharacters: anInteger [

	^ODBCConnection stringEncoder byteSizeForCharacters: anInteger
]

{ #category : #accessing }
ODBCColAttr >> cType [
	"Private - Answer the 'C' type to which the described column's values should be converted when loaded
	into Dolphin buffers (ODBCFields)."

	^SQLToCTypes at: sqlType+TypeOffset
]

{ #category : #accessing }
ODBCColAttr >> columnNumber [
	"Answer the instance variable columnNumber"

	^columnNumber
]

{ #category : #accessing }
ODBCColAttr >> columnNumber: anInteger [
	"Private - Set the instance variable columnNumber to anInteger."

	columnNumber := anInteger
]

{ #category : #accessing }
ODBCColAttr >> deleteRuleMask [
	"Answer the delete rule mask for the receiver"

	| answer |
	answer := (special bitAnd: DeleteRules) bitShift: -4.
	^answer == 0 ifFalse: [ answer bitShift: -1 ]
]

{ #category : #accessing }
ODBCColAttr >> deleteRuleMask: anInteger [
	"Private - Set the delete rule mask for the receiver to anInteger"

	special := special bitAnd: DeleteRules bitInvert.
	anInteger isNil ifFalse: [
		self specialFlagAt:
			(1 bitShift: (anInteger+4))
			put: true ]
]

{ #category : #testing }
ODBCColAttr >> hasVariableTransferOctetLength [

	^(self isCharType or: [self isBinaryType]) and: [self isFixedPointType not]
]

{ #category : #initializing }
ODBCColAttr >> initialize [
	"Private - Initialize the receiver"

	special := (SQL_PARAM_INPUT bitShift: ParameterTypeShift)
]

{ #category : #testing }
ODBCColAttr >> isBinaryType [
	"Private - Answers true if the receiver represents a character based column"

	^self cType == SQL_C_BINARY
]

{ #category : #testing }
ODBCColAttr >> isCharType [
	"Private - Answers true if the receiver represents a character based column"

	| cType |

	^(cType := self cType) == SQL_C_CHAR or: [cType == SQL_C_WCHAR]
]

{ #category : #testing }
ODBCColAttr >> isFixedPointType [

	^sqlType == SQL_DECIMAL or: [sqlType == SQL_NUMERIC]
]

{ #category : #testing }
ODBCColAttr >> isForeignKey [
	"Answer true if the receiver represents a foreign key"

	^self specialFlagAt: ForeignKey
]

{ #category : #accessing }
ODBCColAttr >> isForeignKey: aBoolean [
	"Private - Mark the receiver as representing a foreign key according to aBoolean"

	self specialFlagAt: ForeignKey put: aBoolean
]

{ #category : #testing }
ODBCColAttr >> isKey [
	"Answer true if the receiver is a key"

	^special anyMask: (PrimaryKey bitOr: ForeignKey)
]

{ #category : #testing }
ODBCColAttr >> isPrimaryKey [
	"Answer true if the receiver is a primary key"

	^self specialFlagAt: PrimaryKey
]

{ #category : #accessing }
ODBCColAttr >> isPrimaryKey: aBoolean [
	"Private - Sets the receiver to be a primary key according to aBoolean"

	self specialFlagAt: PrimaryKey put: aBoolean
]

{ #category : #accessing }
ODBCColAttr >> length [
	"Answer the length instance variable."

	^length
]

{ #category : #accessing }
ODBCColAttr >> length: anInteger [
	"Private - Set the length instance variable to anInteger."

	length := anInteger
]

{ #category : #accessing }
ODBCColAttr >> lengthC [
	"Private - Answer the length of ByteArray sufficient to hold an entry for this column when converted to 'C' data. This needs to include any extra space for null-terminators if the 'C' target type is some kind of string."

	^length + (CTypesExtraBytes at: sqlType+TypeOffset)
]

{ #category : #accessing }
ODBCColAttr >> name [
	"Answer the name instance variable."

	^name
]

{ #category : #accessing }
ODBCColAttr >> name: aString [
	"Private - Set the name instance variable to aString."

	name := aString
]

{ #category : #accessing }
ODBCColAttr >> parameterType [
	"Answer the SQL_PARAM_XXXX value that defines the type of parameter
	the receiver represents when used in a parameterized statement. The default
	is SQL_PARAM_INPUT, which is appropriate for most cases except some
	stored procedures."

	^(special bitAnd: ParameterTypeMask) >> ParameterTypeShift
]

{ #category : #accessing }
ODBCColAttr >> parameterType: anInteger [ 
	"Set the type of parameter the receiver represents when used in a parameterized 
	statement to the SQL_PARAM_XXXX value specified as the integer argument.
	This must be one of:
		SQL_PARAM_TYPE_UNKNOWN 	- direction unspecified
		SQL_PARAM_INPUT			- input only parameter
		SQL_PARAM_INPUT_OUTPUT         - bidirectional parameter
		SQL_RESULT_COL                   		- result set column
		SQL_PARAM_OUTPUT                 	- output only parameter
		SQL_RETURN_VALUE                 	- stored procedure return value
	The parameterType should not be changed from the default (SQL_PARAM_INPUT),
	unless describing an output or input/output parameter to a stored procedure."

	special := (special bitClear: ParameterTypeMask) 
				bitOr: (anInteger bitShift: ParameterTypeShift)
]

{ #category : #accessing }
ODBCColAttr >> precision [
	"Answer the precision instance variable."

	^precision
]

{ #category : #accessing }
ODBCColAttr >> precision: anInteger [
	"Private - Set the precision instance variable to anInteger."

	precision := anInteger
]

{ #category : #printing }
ODBCColAttr >> printOn: aStream [ 
	"Append the ASCII representation of
	 the receiver to aStream."

	aStream
		nextPutAll: 'a ';
		print: self class; space;
		nextPut: $(;
		print: self columnNumber;
		nextPutAll: ', ';
		nextPutAll: self name;
		nextPutAll: ', ';
		nextPutAll: (ODBCTypes classPool keyAtValue: self type ifAbsent: ['SQL_TYPE_NULL']);
		nextPutAll: ', ';
		print: self length;
		nextPut: $)
]

{ #category : #accessing }
ODBCColAttr >> scale [
	"Answer the scale instance variable."

	^scale
]

{ #category : #accessing }
ODBCColAttr >> scale: anInteger [
	"Private - Set the scale instance variable to anInteger."

	scale := anInteger
]

{ #category : #accessing }
ODBCColAttr >> specialFlagAt: flagMask [
	"Private - Answer the special flag identified by flagMask"

	^special allMask: flagMask
]

{ #category : #accessing }
ODBCColAttr >> specialFlagAt: flagMask put: aBoolean [
	"Private - Set the special flag identified by flagMask to aBoolean"

	aBoolean 
		ifTrue: [ special bitOr: flagMask ] 
		ifFalse: [ special bitClear: flagMask ]
]

{ #category : #accessing }
ODBCColAttr >> transferOctetLength [

	"Private - Return the transfer octet length (size in bytes of the buffer necessary to receive data for this column) based on the column type.
	https://docs.microsoft.com/en-us/sql/odbc/reference/appendixes/transfer-octet-length"

	(sqlType = SQL_BIT or: [sqlType = SQL_TINYINT]) ifTrue: [^1].
	sqlType = SQL_SMALLINT ifTrue: [^2].
	(sqlType = SQL_INTEGER or: [sqlType = SQL_REAL]) ifTrue: [^4].
	(sqlType = SQL_TYPE_DATE or: [sqlType = SQL_TYPE_TIME]) ifTrue: [^6].
	(sqlType = SQL_FLOAT or: [sqlType = SQL_DOUBLE]) ifTrue: [^8].
	(sqlType = SQL_TYPE_TIMESTAMP or: [sqlType = SQL_GUID]) ifTrue: [^16].

	"SQL_BIGINT
	The number of bytes required to hold the character representation of this data if the character set is ANSI, and twice this number if the character set is UNICODE, because this data type is returned as a character string by default. The character representation consists of 20 characters: 19 for digits and a sign, if signed, or 20 digits, if unsigned. Therefore, the length is 20."
	sqlType = SQL_BIGINT ifTrue: [^self byteSizeForCharacters: 20].

	"SQL_DECIMAL, SQL_NUMERIC
	The number of bytes required to hold the character representation of this data if the character set is ANSI, and twice this number if the character set is UNICODE. This is the maximum number of digits plus two, because the data is returned as a character string and characters are needed for the digits, a sign, and a decimal point. For example, the transfer length of a column defined as NUMERIC(10,3) is 12."
	(sqlType = SQL_DECIMAL or: [sqlType = SQL_NUMERIC]) ifTrue: [^self byteSizeForCharacters: (self precision + 2)].

	self hasVariableTransferOctetLength
		ifTrue: [self error: 'column has variable transfer octet length']
		ifFalse: [self error: 'unknown type']
]

{ #category : #accessing }
ODBCColAttr >> type [
	"Answer the sqlType instance variable."

	^sqlType
]

{ #category : #accessing }
ODBCColAttr >> type: anInteger [
	"Private - Set the sqlType instance variable to anInteger."

	sqlType := anInteger
]

{ #category : #accessing }
ODBCColAttr >> updateRuleMask [
	"Answer the update rule mask for the receiver"

	| answer |
	answer := (special bitAnd: DeleteRules) bitShift: -8.
	^answer == 0 ifFalse: [ answer bitShift: -1 ]
]

{ #category : #accessing }
ODBCColAttr >> updateRuleMask: anInteger [
	"Private - Set the update rule mask for the receiver to anInteger"

	special := special bitAnd: UpdateRules bitInvert.
	anInteger isNil ifFalse: [
		self specialFlagAt:
			(1 bitShift: (anInteger+8)) 
			put: true ]
]
