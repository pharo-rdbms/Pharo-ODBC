"
An ODBCAbstractRow respresents a row in a <ODBCResultSet>, either as a buffer containing a collection of field buffers used to receive data from ODBC (subclasses of ODBCRowBuffer), or as a reified row containing the column values as appropriate types of Smalltalk object (ODBCRow).

From a ODBCAbstractRows one can access the column attributes and the actual field data for the columns. The columns can be accessed by name using #at: and by index using #atIndex:. The type of object returned depends on whether the receiver is a buffer (in which case one gets <ODBCField>s, or a reified <ODBCRow>, in which case one gets the field values). ODBCAbstractRows also provide implicit accessor methods for each column by overriding #doesNotUnderstand.

Instance Variables:
	columns		<Array> of <ODBCColAttr>
	contents		<Array> of <ODBCField>|<Object>
	selectors		<Dictionary> mapping <Symbol>s to <integer> column indices.
	status		<WORD>|<integer> ODBC row status
			
Based on DBAbstractRow from Dolphin Smalltalk Database Connection package.
"
Class {
	#name : #ODBCAbstractRow,
	#superclass : #Object,
	#instVars : [
		'columns',
		'contents',
		'selectors',
		'status'
	],
	#pools : [
		'ODBCConstants'
	],
	#category : #'ODBC-Core-Base'
}

{ #category : #comparing }
ODBCAbstractRow >> = comparand [
	"Answer whether the receiver and the <Object>, comparand, 
	are considered equivalent."

	^comparand species == self species and: [
		self contents = comparand contents]
]

{ #category : #converting }
ODBCAbstractRow >> asObject [
	"Private - Answer the receiver as an instance of DBRow containing the receiver's values."

	^self subclassResponsibility
]

{ #category : #accessing }
ODBCAbstractRow >> at: aString [
	"Answer the field named aSymbol from the receiver."

	^self atIndex: (self selectors at: aString)
]

{ #category : #accessing }
ODBCAbstractRow >> at: aString ifAbsent: exceptionHandler [
	"Answer the field named aString from the receiver.  If the field is not present,
	answer the result of evaluating the niladic valuable, exceptionHandler."

	^self 
		atIndex: (self selectors at: aString ifAbsent: [^exceptionHandler value])
]

{ #category : #accessing }
ODBCAbstractRow >> at: key ifPresent: operation [
	"Answer the result of evaluating the monadic valuable, operation, if
	the argument, key, is the key of an element in the receiver, with that
	element as its argument. If the key is not present, then answer nil."

	^operation value: (self at: key ifAbsent: [^nil])
]

{ #category : #accessing }
ODBCAbstractRow >> at: aString put: anObject [
	"Set the field named aSymbol to anObject.
	Answer the argument."

	^self atIndex: (self selectors at: aString) put: anObject
]

{ #category : #accessing }
ODBCAbstractRow >> atIndex: anInteger [
	"Answer the field whose column index is anInteger."

	^self contents at: anInteger
]

{ #category : #accessing }
ODBCAbstractRow >> atIndex: anInteger put: anObject [
	"Set the field whose column index is anInteger to anObject.	
	Answer the argument."

	^self contents at: anInteger put: anObject
]

{ #category : #accessing }
ODBCAbstractRow >> buildSelectors [
	| cols |
	cols := self columns.
	selectors := Dictionary new: cols size.	"* 2"
	cols keysAndValuesDo: 
			[:i :col | 
			| instName |
			instName := col name.
			selectors at: instName put: i
			"selectors at: (instName, ':') put: i"]
]

{ #category : #accessing }
ODBCAbstractRow >> columns [
	"Answer an <Array> of <ODBCColAttr>s describing the columns in this row."

	^columns
]

{ #category : #accessing }
ODBCAbstractRow >> columns: anArrayOfODBCColAttr [
	columns := anArrayOfODBCColAttr

]

{ #category : #accessing }
ODBCAbstractRow >> contents [
	^contents
]

{ #category : #exceptions }
ODBCAbstractRow >> doesNotUnderstand: aMessage [
	"Private - See if the message selector is one of the field names of the receiver.
	If so, access that field."

	| selector |
	selector := aMessage selector.
	^selector last == $: 
		ifTrue: 
			[self atIndex: (self selectors at: selector allButLast
						ifAbsent: [^super doesNotUnderstand: aMessage])
				put: aMessage arguments first]
		ifFalse: [self at: selector ifAbsent: [super doesNotUnderstand: aMessage]]
]

{ #category : #comparing }
ODBCAbstractRow >> hash [
	"Answer the <integer> hash value for the receiver." 

	^self contents hash

]

{ #category : #testing }
ODBCAbstractRow >> isDeletedRow [
	"Answer whether the receiver represents a row in a result set which has been 
	deleted in the time since the result set was originally queried."

	^self status = SQL_ROW_DELETED
]

{ #category : #printing }
ODBCAbstractRow >> printOn: aStream [
	"Append the ASCII representation of the receiver
	 to aStream."

	aStream
		nextPutAll: 'a ';
		print: self class; space;
		nextPut: $(.
	self contents do: [:f | aStream print: f] separatedBy: [aStream space].
	aStream nextPut: $)
]

{ #category : #accessing }
ODBCAbstractRow >> selectors [
	"Private - Answer a <LookupTable> mapping the names of fields in the receiver to
	column indices."

	selectors isNil ifTrue: [self buildSelectors].
	^selectors
]

{ #category : #accessing }
ODBCAbstractRow >> status [
	^status
]
