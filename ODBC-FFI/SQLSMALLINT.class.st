Class {
	#name : #SQLSMALLINT,
	#superclass : #SQLIntegerType,
	#category : #'ODBC-FFI'
}

{ #category : #converting }
SQLSMALLINT class >> asExternalTypeOn: generator [ 

	^FFIInt16 asExternalTypeOn: generator 
]

{ #category : #converting }
SQLSMALLINT class >> fields [
	" 
	SQLSMALLINT defineFields 
	"
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
