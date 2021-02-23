"
Instances of ODBCWarning hold exception information for Database Connection non-fatal warnings (essentially those resulting from SQLSuccessWithInfo return codes).

Based on DBWarning from Dolphin Smalltalk Database Connection package.
"
Class {
	#name : #ODBCWarning,
	#superclass : #Notification,
	#category : #'ODBC-Core-Base'
}

{ #category : #signalling }
ODBCWarning class >> signalWith: anODBCExceptionDetails [

	anODBCExceptionDetails buildErrorInfo.
	self signal: anODBCExceptionDetails displayString withTag: anODBCExceptionDetails
]

{ #category : #signalling }
ODBCWarning >> signal [
	"Signal this exception."

	self tag buildErrorInfo.
	super signal
]
