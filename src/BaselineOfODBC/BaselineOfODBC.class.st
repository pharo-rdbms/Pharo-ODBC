"
Baseline for [https://github.com/pharo-rdbms/Pharo-ODBC](https://github.com/pharo-rdbms/Pharo-ODBC)
"
Class {
	#name : #BaselineOfODBC,
	#superclass : #BaselineOf,
	#category : #'BaselineOfODBC-Base'
}

{ #category : #baselines }
BaselineOfODBC >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [
				"Packages"
				spec
					package: 'ODBC-FFI';
					package: 'ODBC-Core' with: [ spec requires: #('ODBC-FFI') ];
					package: 'ODBC-Tests' with: [ spec requires: #('ODBC-Core') ].

				"Groups"
				spec
					group: 'FFI' with: #('ODBC-FFI');
					group: 'Core' with: #('ODBC-Core');
					group: 'Tests' with: #('ODBC-Tests');
					group: 'CI' with: #('Tests');
					group: 'all' with: #('ODBC-Tests');
					group: 'default' with: #('all') ]
]
