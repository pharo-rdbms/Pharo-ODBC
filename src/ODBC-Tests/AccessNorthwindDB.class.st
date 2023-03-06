"
Provides access to Northwind Test database using Microsoft Access for tests as a reusable test resource
"
Class {
	#name : #AccessNorthwindDB,
	#superclass : #ODBCConnectionTestResource,
	#instVars : [
		'filename'
	],
	#category : #'ODBC-Tests-Resources'
}

{ #category : #'accessing - constants' }
AccessNorthwindDB class >> accessDriverName [

	ODBCConnection enumerateDrivers do: [ :arg1 |
		(arg1 key beginsWith: 'Microsoft Access Driver (*.mdb') ifTrue: [
			^ arg1 key ] ].
	self error: 'no access driver found'
]

{ #category : #'accessing - constants' }
AccessNorthwindDB class >> connectStringPattern [

	^ 'DRIVER={' , self accessDriverName , '};DBQ=<1s>'
]

{ #category : #private }
AccessNorthwindDB >> connectString [

	^ self class connectStringPattern expandMacrosWith:
		  filename pathString
]

{ #category : #private }
AccessNorthwindDB >> createDatabase [

	| tmp1 |
	tmp1 := 'Northwind.mdb' asFileReference.
	filename := FileLocator temp asFileReference resolvePath:
		            'Northwind.mdb'.
	tmp1 copyTo: filename.
	filename isWritable ifFalse: [ filename fileSystem isWritable: true ].
	^ true
]

{ #category : #private }
AccessNorthwindDB >> dropDatabase [
	super dropDatabase.
	filename delete
]
