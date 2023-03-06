"
I represent the SQL INTEGER type
"
Class {
	#name : #SQLINTEGER,
	#superclass : #SQLIntegerType,
	#category : #'ODBC-FFI-SQL-Types'
}

{ #category : #converting }
SQLINTEGER class >> asExternalTypeOn: generator [

	^ FFIInt32 asExternalTypeOn: generator
]

{ #category : #'field definition' }
SQLINTEGER class >> fields [
	<script: 'SQLINTEGER defineFields'>

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
