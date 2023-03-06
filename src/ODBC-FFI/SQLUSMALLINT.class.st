"
I represent the SQL USMALLINT type
"
Class {
	#name : #SQLUSMALLINT,
	#superclass : #SQLIntegerType,
	#category : #'ODBC-FFI-SQL-Types'
}

{ #category : #converting }
SQLUSMALLINT class >> asExternalTypeOn: generator [

	^ FFIUInt16 asExternalTypeOn: generator
]

{ #category : #'field definition' }
SQLUSMALLINT class >> fields [
	<script: 'SQLUSMALLINT defineFields'>

	^ #(#(#value 'ushort') )
]

{ #category : #accessing }
SQLUSMALLINT >> value [
	"This method was automatically generated. See SQLUSMALLINT class>>fields."
	<generated>
	^handle unsignedShortAt: 1
]

{ #category : #accessing }
SQLUSMALLINT >> value: anObject [
	"This method was automatically generated. See SQLUSMALLINT class>>fields."
	<generated>
	handle unsignedShortAt: 1 put: anObject
]
