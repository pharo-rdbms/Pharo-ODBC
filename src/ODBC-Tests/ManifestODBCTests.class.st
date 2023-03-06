"
Please describe the package using the class comment of the included manifest class. The manifest class also includes other additional metadata for the package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestODBCTests,
	#superclass : #PackageManifest,
	#category : #'ODBC-Tests-Manifest'
}

{ #category : #'code-critics' }
ManifestODBCTests class >> ruleInconsistentMethodClassificationRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGMethodDefinition #(#AccessODBCTest #dbmsFeaturesMap #false)) #'2023-03-06T23:33:43.516679+01:00') #(#(#RGMethodDefinition #(#AccessODBCTest #databaseResource #false)) #'2023-03-06T23:33:50.589953+01:00') )
]

{ #category : #'code-critics' }
ManifestODBCTests class >> ruleLiteralArrayContainsSuspiciousTrueFalseOrNilRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGMetaclassDefinition #(#'ManifestODBCTests class' #ManifestODBCTests)) #'2023-03-06T23:34:05.965847+01:00') )
]
