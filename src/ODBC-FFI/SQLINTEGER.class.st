Class {
	#name : #SQLINTEGER,
	#superclass : #SQLIntegerType,
	#category : #'ODBC-FFI-SQL-Types'
}

{ #category : #converting }
SQLINTEGER class >> asExternalTypeOn: generator [

	^FFIInt32 asExternalTypeOn: generator
]

{ #category : #converting }
SQLINTEGER class >> fields [
	"
	SQLINTEGER defineFields
	"
	^ #(#(#value 'long') )
]

{ #category : #accessing }
SQLINTEGER >> value [
	"This method was automatically generated. See SQLINTEGER class>>fields."
	<generated>
	^handle signedLongAt: 1
]

{ #category : #accessing }
SQLINTEGER >> value: anObject [
	"This method was automatically generated. See SQLINTEGER class>>fields."
	<generated>
	handle signedLongAt: 1 put: anObject
]
