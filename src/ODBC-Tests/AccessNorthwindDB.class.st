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
	
	ODBCConnection enumerateDrivers do: [ :assoc | (assoc key beginsWith: 'Microsoft Access Driver (*.mdb') ifTrue: [ ^assoc key ]].
	
	self error: 'no access driver found'

]

{ #category : #'accessing - constants' }
AccessNorthwindDB class >> connectStringPattern [

	^'DRIVER={', self accessDriverName, '};DBQ=<1s>'

]

{ #category : #private }
AccessNorthwindDB >> connectString [
	^self class connectStringPattern expandMacrosWith: filename pathString


]

{ #category : #private }
AccessNorthwindDB >> createDatabase [
	| source |
	source := 'Northwind.mdb' asFileReference.
	filename := FileLocator temp asFileReference resolvePath: 'Northwind.mdb'.
	source copyTo: filename.
	filename isWritable ifFalse: [filename fileSystem isWritable: true].
	^true
]

{ #category : #private }
AccessNorthwindDB >> dropDatabase [
	super dropDatabase.
	filename delete
]
