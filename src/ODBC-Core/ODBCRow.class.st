"
An ODBCRow respresents a snapshot of a row in a <ODBCResultSet>, the contents of which are appropriate types of Smalltalk object to represent the column values of the row.
			
Based on DBRow from Dolphin Smalltalk Database Connection package.
"
Class {
	#name : 'ODBCRow',
	#superclass : 'ODBCAbstractRow',
	#category : 'ODBC-Core-Base',
	#package : 'ODBC-Core',
	#tag : 'Base'
}

{ #category : 'instance creation' }
ODBCRow class >> fromBuffer: anODBCRow [
	^self new
		initializeFromBuffer: anODBCRow
]

{ #category : 'converting' }
ODBCRow >> asObject [
	"Private - Answer the receiver as an instance of ODBCRow containing the receiver's values."

	^ self
]

{ #category : 'instance creation' }
ODBCRow >> initializeFromBuffer: anODBCRow [

	columns := anODBCRow columns.
	selectors := anODBCRow selectors.
	contents := anODBCRow objects.
	status := anODBCRow status.
	^ self
]
