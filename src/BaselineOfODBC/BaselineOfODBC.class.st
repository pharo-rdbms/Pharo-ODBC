Class {
	#name : #BaselineOfODBC,
	#superclass : #BaselineOf,
	#category : #BaselineOfODBC
}

{ #category : #baselines }
BaselineOfODBC >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [
				spec
					package: 'ODBC-FFI';
					package: 'ODBC-Core' with: [ spec requires: #('ODBC-FFI') ];  
					package: 'ODBC-Tests' with: [ spec requires: #('ODBC-Core') ].
			
				spec
					group: 'ffi' with: #('ODBC-FFI');
					group: 'core' with: #('ODBC-Core');
					group: 'tests' with: #('ODBC-Tests');
					group: 'default' with: #('ODBC-Tests')]
]
