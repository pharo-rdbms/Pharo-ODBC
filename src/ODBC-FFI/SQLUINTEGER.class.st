"
I represent the SQL UINTEGER type
"
Class {
	#name : #SQLUINTEGER,
	#superclass : #SQLIntegerType,
	#category : #'ODBC-FFI-SQL-Types'
}

{ #category : #converting }
SQLUINTEGER class >> asExternalTypeOn: generator [

	^ FFIUInt32 asExternalTypeOn: generator
]

{ #category : #'field definition' }
SQLUINTEGER class >> fields [
	<script: 'SQLUINTEGER defineFields'>

	^ #(#(#value 'ulong') )
]

{ #category : #accessing }
SQLUINTEGER >> value [
	"This method was automatically generated. See SQLUINTEGER class>>fields."
	<generated>
	^handle unsignedLongAt: 1
]

{ #category : #accessing }
SQLUINTEGER >> value: anObject [
	"This method was automatically generated. See SQLUINTEGER class>>fields."
	<generated>
	handle unsignedLongAt: 1 put: anObject
]
