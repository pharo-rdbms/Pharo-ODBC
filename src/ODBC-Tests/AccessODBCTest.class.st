Class {
	#name : #AccessODBCTest,
	#superclass : #ODBCConnectionTest,
	#category : #'ODBC-Tests-Base'
}

{ #category : #public }
AccessODBCTest class >> resources [
	^{AccessNorthwindDB}
]

{ #category : #private }
AccessODBCTest >> databaseResource [
	^AccessNorthwindDB current
]

{ #category : #private }
AccessODBCTest >> dbmsFeaturesMap [
	"Private - See MSDN help 'SQLGetInfo Returned Values for Access"

	| featuresMap |

	featuresMap := Dictionary new.
	featuresMap
		at: #dbmsName put: #(#sameAs: 'ACCESS');
		at: #defaultTransactionIsolation put: #(#== #readCommitted);
		at: #driverName put: {#sameAs:. ('*accdb*' match: AccessNorthwindDB accessDriverName) ifTrue: ['ACEODBC.DLL'] ifFalse: ['odbcjt32.dll']};
		at: #hasAccessibleTables put: #(#== true);
		at: #hasIntegrityEnhancementFacility put: #(#== false);
		at: #identifierCase put: {#=. SQL_IC_SENSITIVE};
		at: #identifierQuoteCharacter put: {#=. $`};
		at: #isSAGCompliant put: #(#== false);
		at: #isSourceReadOnly put: #(#== false).
	featuresMap at: #maxCatalogNameLength put: #(#= 260).	"docs say 66?"
	featuresMap
		at: #maxColumnNameLength put: #(#= 64);
		at: #maxConnections put: #(#= 64);
		at: #maxCursorNameLength put: #(#= 64);
		at: #maxProcedureNameLength put: #(#= 64);
		at: #maxSchemaNameLength put: #(#= 0);
		at: #maxStatements put: #(#= 0);
		at: #maxTableNameLength put: #(#= 64);
		at: #odbcConformance put: #(#= 1);
		at: #odbcSQLConformance put: #(#= 0).	"?"
	^featuresMap
		at: #procedureTerm put: #(#sameAs: 'QUERY');
		at: #schemaTerm put: #(#sameAs: '');
		at: #tableTerm put: #(#sameAs: 'TABLE');
		at: #serverName put: #(#sameAs: 'ACCESS');
		at: #catalogTerm put: #(#sameAs: 'DATABASE');
		at: #supportedCursorTypes put: #(#assertCollection:hasSameElements: #(#forwardOnly #keysetDriven #static));
		at: #supportedTransactionIsolationLevels put: #(#assertCollection:hasSameElements: #(#readCommitted));
		at: #supportsExpressionsInOrderBy put: #(#== true);
		at: #supportsMultipleActiveTransactions put: #(#== true);
		at: #supportsMultipleResultSets put: #(#== false);
		at: #supportsOuterJoins put: #(#== true);
		at: #supportsRowUpdates put: #(#== false);
		at: #userName put: #(#= 'admin');
		at: #convertFunctions put: #(#assertCollection:hasSameElements: #('SQL_FN_CVT_CONVERT'));
		at: #searchPatternEscape put: #(#= '\');
		yourself
]

{ #category : #private }
AccessODBCTest >> queryColumns [
	^#(#('OrderID' SQL_INTEGER 4) #('CustomerID' SQL_WVARCHAR 10) #('EmployeeID' SQL_INTEGER 4) #('OrderDate' SQL_TYPE_TIMESTAMP 16) #('RequiredDate' SQL_TYPE_TIMESTAMP 16) #('ShippedDate' SQL_TYPE_TIMESTAMP 16) #('ShipVia' SQL_INTEGER 4) #('Freight' SQL_NUMERIC 21) #('ShipName' SQL_WVARCHAR 80) #('ShipAddress' SQL_WVARCHAR 120) #('ShipCity' SQL_WVARCHAR 30) #('ShipRegion' SQL_WVARCHAR 30) #('ShipPostalCode' SQL_WVARCHAR 20) #('ShipCountry' SQL_WVARCHAR 30))
]

{ #category : #'unit tests' }
AccessODBCTest >> testAccessConnectionAttributes [
	self should: [connection transactionIsolation: #readUncommitted] raise: ODBCError.
	self should: [connection loginTimeout: 30] raise: ODBCError.
	self should: [self assert: connection loginTimeout equals: 30] raise: ODBCError.
	self should: [connection translate] raise: ODBCError.
	self should: [connection translate: 0] raise: ODBCError.
	self should: [connection translationDLL] raise: ODBCError.
	self should: [connection translationDLL: 'blah.dll'] raise: ODBCError.
	self assert: connection uid isNil.
	self assert: connection pwd isNil
]

{ #category : #'unit tests' }
AccessODBCTest >> testForeignKeysQuery [
	"The order DB is an Access DB and it doesn't support the foreign key querying stuff"

	self shouldRaiseNotSupported: [connection queryForeignKeysOf: 'Orders']
]

{ #category : #'unit tests' }
AccessODBCTest >> testPrimaryKeysQuery [
	"The order DB is an Access DB and it doesn't support the key querying stuff"

	self shouldRaiseNotSupported: [connection primaryKeysOf: 'Orders']
]

{ #category : #'unit tests' }
AccessODBCTest >> testProceduresQuery [
	| procs |
	procs := connection procedures.
	self assert: (procs includes: 'Employee Sales by Country')
]

{ #category : #'unit tests' }
AccessODBCTest >> testTablesQuery [
	| tables |
	tables := connection tables.
	self assertCollection: tables
				hasSameElements: #('Categories' 'Customers' 'Employees' 'Order Details' 'Orders' 'Products' 'Shippers' 'Suppliers')
]

{ #category : #'unit tests' }
AccessODBCTest >> testViewsQuery [
	| views |
	views := connection views.
	self assertCollection: views
				hasSameElements: #('Alphabetical List of Products' 'Category Sales for 1997' 'Current Product List' 'Customers and Suppliers by City' 'Employee Sales by Country' 'Invoices' 'Invoices Filter' 'Order Details Extended' 'Order Subtotals' 'Orders Qry' 'Product Sales for 1997' 'Products Above Average Price' 'Products by Category' 'Quarterly Orders' 'Quarterly Orders by Product' 'Sales by Category' 'Sales by Year' 'Ten Most Expensive Products')
]
