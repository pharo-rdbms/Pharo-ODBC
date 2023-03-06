"
Dolphin Smalltalk ODBC Database Connection Base (run time).
Copyright (c) Object Arts Ltd, 1997-2003. Portions copyright CGI Group (Europe) Ltd, 1997.

This package provides an interface to ODBC databases.

For documentation evaluate:
	SmalltalkSystem help: 'databaseconnectivity'
"
Class {
	#name : #ManifestDatabaseConnectionBase,
	#superclass : #PackageManifest,
	#category : #'ODBC-Core-Manifest'
}

{ #category : #'code-critics' }
ManifestDatabaseConnectionBase class >> ruleBadMessageRule2V1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGMethodDefinition #(#ODBCField #shouldTranslate:class: #false)) #'2023-03-07T00:15:07.698506+01:00') )
]

{ #category : #'code-critics' }
ManifestDatabaseConnectionBase class >> ruleEquivalentSuperclassMethodsRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGMethodDefinition #(#ODBCSchemaStatement #executeStatement #false)) #'2023-03-06T23:43:50.369152+01:00') )
]
