"
Instances of ODBCError hold exception information for Database Connection errors.

Based on DBError from Dolphin Smalltalk Database Connection package.
"
Class {
	#name : #ODBCError,
	#superclass : #Error,
	#pools : [
		'ODBCConstants',
		'ODBCRetCodes'
	],
	#category : #'ODBC-Core-Base'
}

{ #category : #signalling }
ODBCError class >> signalWith: anODBCExceptionDetails [

	anODBCExceptionDetails buildErrorInfo.
	self signal: anODBCExceptionDetails displayString withTag: anODBCExceptionDetails
]

{ #category : #signaling }
ODBCError >> signal [
	"Signal this exception."

	self tag buildErrorInfo.
	super signal
]
