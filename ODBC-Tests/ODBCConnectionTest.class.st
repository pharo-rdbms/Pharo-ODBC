"
SUnitBrowser openOnTestCase: self.

If these tests fail make sure that Tests\NWind.mdb is available and NOT write protected.
"
Class {
	#name : #ODBCConnectionTest,
	#superclass : #ODBCTest,
	#pools : [
		'ODBCConstants',
		'ODBCTypes'
	],
	#category : #'ODBC-Tests'
}

{ #category : #testing }
ODBCConnectionTest class >> isAbstract [

	^self = ODBCConnectionTest
]

{ #category : #public }
ODBCConnectionTest >> databaseResource [
	self subclassResponsibility
]

{ #category : #constants }
ODBCConnectionTest >> dbmsFeaturesMap [
	"Private - Override in subclasses"

	^Dictionary new
]

{ #category : #private }
ODBCConnectionTest >> queryColumns [
	self subclassResponsibility
]

{ #category : #helpers }
ODBCConnectionTest >> shouldRaiseNotSupported: block [ 
	self 
		should: block
		raise: ODBCError
		withExceptionDo: [:e | e tag errors anySatisfy: [:x | x sqlState = 'IM001']]
]

{ #category : #'unit tests' }
ODBCConnectionTest >> testAsArray [
	| results array |
	results := connection query: 'SELECT* FROM Categories'.
	array := results asArray.
	results with: array do: [:row1 :row2 | self assert: row1 equals: row2].
	"Enumerate again"
	array := results asArray.
	results with: array do: [:row1 :row2 | self assert: row1 equals: row2].
	"Force with:do: to raise an error"
	self should: [results with: (array copyWith: array first) do: [:a :b | ]] raise: Error.
	self should: 
			[results with: ((array asOrderedCollection)
						removeLast;
						yourself)
				do: [:a :b | ]]
		raise: Error.

	results free.

	"Test a forward only cursor"
	results := connection query: 'SELECT* FROM Categories' cursorType: #forwardOnly.
	array := results asArray.
	results with: array do: [:row1 :row2 | self assert: row1 equals: row2].
	"Enumerate again"
	array := results asArray.
	results with: array do: [:row1 :row2 | self assert: row1 equals: row2].
	results free.

	results := connection query: 'SELECT* FROM Orders WHERE OrderID=-1'.
	array := results asArray.
	self assert: array isEmpty.
	array := results asArray.
	self assert: array isEmpty.
	results free.

	results := connection query: 'SELECT* FROM Orders WHERE OrderID=-1'
				cursorType: #forwardOnly.
	array := results asArray.
	self assert: array isEmpty.
	array := results asArray.
	self assert: array isEmpty.
	results free.

	results := connection query: 'SELECT* FROM Orders WHERE OrderID=10248'
				cursorType: #forwardOnly.
	array := results asArray.
	self assert: array size equals: 1.
	self assert: (array first at: 'OrderID') equals: 10248.
	"Repeat - causing requery"
	array := results asArray.
	self assert: array size equals: 1.
	self assert: (array first at: 'OrderID') equals: 10248
]

{ #category : #'unit tests' }
ODBCConnectionTest >> testColumnsQuery [
	| columns |
	columns := connection columns: 'Orders'.
	columns
		with: self queryColumns
		do: 
			[:eachCol :eachArray |
			| type |
			self assert: eachCol name equals: eachArray first.
			type := (ODBCTypes bindingOf: eachArray second) value.
			self assert: eachCol type equals: type.
			self assert: eachCol length equals: eachArray third]
]

{ #category : #'unit tests' }
ODBCConnectionTest >> testConnectStringDo [
	| pairs block |
	pairs := OrderedCollection new.
	block := 
			[:paramName :paramValue | 
			pairs
				add: paramName;
				add: paramValue].
	ODBCConnection 
		connectString: 'DRIVER={Microsoft Access Driver (*.mdb)};DBQ=c:\program files\microsoft office\office\samples\Northwind.mdb'
		do: block.
	self assert: pairs asArray 
				equals: #('DRIVER' 'Microsoft Access Driver (*.mdb)' 'DBQ' 'c:\program files\microsoft office\office\samples\Northwind.mdb').
	pairs := OrderedCollection new.
	ODBCConnection connectString: ';;DRIVER={Microsoft Text Driver (*.txt; *.csv)};;DefaultDir=.;Dummy=;'
		do: block.
	self assert: pairs asArray 
				equals: #('DRIVER' 'Microsoft Text Driver (*.txt; *.csv)' 'DefaultDir' '.' 'Dummy' '').
	pairs := OrderedCollection new.
	ODBCConnection 
		connectString: ';DSN=PostgreSQL30;DATABASE=money;SERVER=192.168.168.2;PORT=5432;UID=akira;PWD=;A6=;A7=100;A8=4096;B0=254;B1=8190;BI=0;C2=dd_;;CX=1a503ab;EMPTY='
		do: block.
	self assert: pairs asArray 
				equals: #('DSN' 'PostgreSQL30' 'DATABASE' 'money' 'SERVER' '192.168.168.2' 'PORT' '5432' 'UID' 'akira' 'PWD' '' 'A6' '' 'A7' '100' 'A8' '4096' 'B0' '254' 'B1' '8190' 'BI' '0' 'C2' 'dd_' 'CX' '1a503ab' 'EMPTY' '')
]

{ #category : #'unit tests' }
ODBCConnectionTest >> testConnectionAttributes [
	self assert: connection driverHDBC isNull not.
	self assert: connection driverHEnv isNull not.
	self assert: connection willAutoCommit.
	connection willAutoCommit: false.
	self assert: connection willAutoCommit not.
	connection willAutoCommit: true.
	self assert: connection willAutoCommit.
	self assert: connection isReadOnly not.
	connection isReadOnly: true.
	self assert: connection isReadOnly.
	connection isReadOnly: false.
	self assert: connection isReadOnly not.
	self assert: connection transactionIsolation equals: #readCommitted.
	self 
		should: [connection transactionIsolation: #hash]
		raise: Error
		withExceptionDo: [:ex | ex messageText = 'value not found: #hash'].
]

{ #category : #'unit tests' }
ODBCConnectionTest >> testConnectionEnquiries [
	self assert: (connection databaseName asLowercase indexOfSubCollection: 'northwind') ~~ 0.
	self assert: (connection dataSourceName = connection dsn
				or: [connection dataSourceName isEmpty and: [connection dsn isNil]]).
	self dbmsFeaturesMap keysAndValuesDo: 
			[:eachKey :eachValue |
			| value |
			value := connection perform: eachKey.
			(#(#sameAs: #= #==) identityIncludes: eachValue first)
				ifTrue: 
					[self
						assert: (value = eachValue second)
						description: 'Test ' , eachKey displayString]
				ifFalse: [self perform: eachValue first withArguments: {value. eachValue last}]].
	self assert: connection cursorCommitBehaviour equals: SQL_CB_CLOSE.
	self assert: connection cursorRollbackBehaviour equals: SQL_CB_CLOSE.
	self assertCollection: ((connection columns: 'Orders') collect: [:each | each name])
				hasSameElements: #('OrderID' 'CustomerID' 'EmployeeID' 'OrderDate' 'RequiredDate' 'ShippedDate' 'ShipVia' 'Freight' 'ShipName' 'ShipAddress' 'ShipCity' 'ShipRegion' 'ShipPostalCode' 'ShipCountry').
	self assert: (connection rowVersionColumns: 'Orders') isEmpty.
	self assert: (Number readFrom: connection odbcVersion readStream) >= 3.0.
	self assert: connection dbmsVersion notEmpty.
	self assert: connection driverVersion notEmpty.
	self assert: (connection numericFunctions allSatisfy: [:each | each beginsWith: 'SQL_FN_NUM_']).
	self assert: (connection stringFunctions allSatisfy: [:each | each beginsWith: 'SQL_FN_STR_']).
	self assert: (connection systemFunctions allSatisfy: [:each | each beginsWith: 'SQL_FN_SYS_']).
	self assert: (connection timeDateFunctions allSatisfy: [:each | each beginsWith: 'SQL_FN_TD_'])
	"#uniqueIndicesOf: has separate test method"
]

{ #category : #'unit tests' }
ODBCConnectionTest >> testConnectionString [
	"#1284"

	| db |
	db := ODBCConnection new.
	db 
		connectString: ';DSN=PostgreSQL30;DATABASE=money;SERVER=192.168.168.2;PORT=5432;UID=akira;PWD=;A6=;A7=100;A8=4096;B0=254;B1=8190;BI=0;C2=dd_;;CX=1a503ab;EMPTY='.
	self assert: db dsn equals: 'PostgreSQL30'.
	self assert: db pwd isEmpty.
	self assert: db uid equals: 'akira'.

	"Attributes must be either empty, or contain a key=value pair"
	"self should: [db connectString: ';DSN;'] raise: Error"
]

{ #category : #'unit tests' }
ODBCConnectionTest >> testDSNlessConnection [
	"See MSDN help 'SQLGetInfo Returned Values for Access"

	| c connStr |

	c := ODBCConnection new.
	connStr := AccessNorthwindDB connectStringPattern expandMacrosWith: 'Northwind.mdb' asFileReference pathString.
	c connectString: connStr.
	c open.
	self assert: (c tables includes: 'Customers').
	c close.
	c := ODBCConnection new.
	c connectString: connStr.
	c useDriverCompletion: false.
	c open.
	self assert: (c tables includes: 'Customers').
	c close.
	"#1473 - failure to parse connect string containing embedded semi-colons"
	c := ODBCConnection new.
	c connectString: 'DRIVER={Microsoft Text Driver (*.txt; *.csv)}'
]

{ #category : #'unit tests' }
ODBCConnectionTest >> testPreparedQuery [
	| statement results |
	statement := connection prepare: 'select * from Suppliers where SupplierID=?'.
	statement paramCols: (Array with: ((connection columns: 'Suppliers') at: 1)).
	statement values: #(3).
	statement exec.
	results := statement results.
	self assert: results size equals: 1.
	self assert: (results first at: 'ContactName') equals: 'Regina Murphy'.
	results free
]

{ #category : #'unit tests' }
ODBCConnectionTest >> testSpecialColumnsQuery [
	| rowIds |
	rowIds := connection rowIdColumns: 'Orders'.
	self assert: rowIds asArray equals: #('OrderID').

]

{ #category : #'unit tests' }
ODBCConnectionTest >> testStatisticsQuery [
	| stats pk |
	stats := connection uniqueIndicesOf: 'Orders'.
	self assert: (stats allSatisfy: [:each | (each at: 'TABLE_NAME') = 'Orders']).
	pk := stats detect: [:each | (each at: 'COLUMN_NAME') = 'OrderID'].
	stats := connection indicesOf: 'Orders'.
	self assert: (stats allSatisfy: [:each | (each at: 'TABLE_NAME') = 'Orders']).
	self assertCollection: (stats collect: [:e | e at: 'INDEX_NAME']) 
				hasSameElements: (#(nil 'CustomerID' 'CustomersOrders' 'EmployeeID' 'EmployeesOrders' 'OrderDate' 'ShippedDate' 'ShippersOrders' 'ShipPostalCode') 
						copyWith: (pk at: 'INDEX_NAME'))
]

{ #category : #'unit tests' }
ODBCConnectionTest >> testTracing [
	| traceFile |

	traceFile := FileLocator temp asFileReference resolvePath: 'BLAH.LOG'.
	connection traceFile: traceFile pathString.
	self assert: connection traceFile equals: traceFile pathString.
	self assert: connection isTracing.
	connection isTracing: false.
	self assert: connection isTracing not.
	traceFile delete

]
