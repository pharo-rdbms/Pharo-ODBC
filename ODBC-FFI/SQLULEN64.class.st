"
I represent the SQLULEN type on 64 bit platforms.
"
Class {
	#name : #SQLULEN64,
	#superclass : #SQLIntegerType,
	#category : #'ODBC-FFI'
}

{ #category : #converting }
SQLULEN64 class >> asExternalTypeOn: generator [ 

	^FFIUInt64 asExternalTypeOn: generator 
]

{ #category : #converting }
SQLULEN64 class >> fields [
	" 
	SQLULEN64 defineFields 
	"
	^ #(#(#value 'ulonglong') )
]

{ #category : #accessing }
SQLULEN64 >> value [
	"This method was automatically generated. See SQLULEN64 class>>fields."
	<generated>
	^handle unsignedLongLongAt: 1
]

{ #category : #accessing }
SQLULEN64 >> value: anObject [
	"This method was automatically generated. See SQLULEN64 class>>fields."
	<generated>
	handle unsignedLongLongAt: 1 put: anObject
]
