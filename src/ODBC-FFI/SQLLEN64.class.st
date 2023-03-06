"
I represent the SQLLEN type on 64 bit platforms.
"
Class {
	#name : #SQLLEN64,
	#superclass : #SQLIntegerType,
	#category : #'ODBC-FFI-SQL-Types'
}

{ #category : #converting }
SQLLEN64 class >> asExternalTypeOn: generator [

	^FFIInt64 asExternalTypeOn: generator
]

{ #category : #converting }
SQLLEN64 class >> fields [
	"
	SQLLEN64 defineFields
	"
	^ #(#(#value 'longlong') )
]

{ #category : #accessing }
SQLLEN64 >> value [
	"This method was automatically generated. See SQLLEN64 class>>fields."
	<generated>
	^handle signedLongLongAt: 1
]

{ #category : #accessing }
SQLLEN64 >> value: anObject [
	"This method was automatically generated. See SQLLEN64 class>>fields."
	<generated>
	handle signedLongLongAt: 1 put: anObject
]
