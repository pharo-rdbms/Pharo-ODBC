"
An ODBCUnboundRow represents a row buffer that is not statically bound to allocated memory for its columns, but where instead the data is explicitly and individually read into a buffer for each field after the row has been fetched.
			
Based on ODBCUnboundBuffer from Dolphin Smalltalk Database Connection package.
"
Class {
	#name : #ODBCUnboundBuffer,
	#superclass : #ODBCRowBuffer,
	#category : #'ODBC-Core-Base'
}

{ #category : #'data retrieval' }
ODBCUnboundBuffer >> getData: anODBCStatement [
	"Private - Copy data from the result table into fields of the receiver."

	self contents do: [:f | f getData: anODBCStatement]
]
