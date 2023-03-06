"
I represent the SQL SMALLINT type
"
Class {
	#name : #SQLSMALLINT,
	#superclass : #SQLIntegerType,
	#category : #'ODBC-FFI-SQL-Types'
}

{ #category : #converting }
SQLSMALLINT class >> asExternalTypeOn: generator [

	^ FFIInt16 asExternalTypeOn: generator
]

{ #category : #'field definition' }
SQLSMALLINT class >> fields [
	<script: 'SQLSMALLINT defineFields'>

	^ #(#(#value 'short') )
]

{ #category : #accessing }
SQLSMALLINT >> value [
	"This method was automatically generated. See SQLSMALLINT class>>fields."
	<generated>
	^handle signedShortAt: 1
]

{ #category : #accessing }
SQLSMALLINT >> value: anObject [
	"This method was automatically generated. See SQLSMALLINT class>>fields."
	<generated>
	handle signedShortAt: 1 put: anObject
]
