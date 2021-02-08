Class {
	#name : #SQLServerODBCTest,
	#superclass : #ODBCConnectionTest,
	#category : #'ODBC-Tests'
}

{ #category : #public }
SQLServerODBCTest class >> resources [
	^{SQLServerNorthwindDB}
]

{ #category : #private }
SQLServerODBCTest >> databaseResource [
	^SQLServerNorthwindDB current
]

{ #category : #private }
SQLServerODBCTest >> dbmsFeaturesMap [
	"Private - Deliberately leave outer #serverName as this will vary by configuration"

	^(Dictionary new)
		at: #dbmsName put: #(#sameAs: 'Microsoft SQL Server');
		at: #defaultTransactionIsolation put: #(#== #readCommitted);
		at: #driverName put: #(#sameAs: 'SQLSRV32.DLL');
		at: #hasAccessibleTables put: #(#== true);
		at: #hasIntegrityEnhancementFacility put: #(#== true);
		at: #identifierCase put: {#=. SQL_IC_MIXED};
		at: #identifierQuoteCharacter put: {#=. $"};
		at: #isSAGCompliant put: #(#== false);
		at: #isSourceReadOnly put: #(#== false);
		at: #maxCatalogNameLength put: #(#= 128);
		at: #maxColumnNameLength put: #(#= 128);
		at: #maxConnections put: #(#= 0);
		at: #maxCursorNameLength put: #(#= 128);
		at: #maxProcedureNameLength put: #(#= 134);
		at: #maxSchemaNameLength put: #(#= 128);
		at: #maxStatements put: #(#= 1);
		at: #maxTableNameLength put: #(#= 128);
		at: #odbcConformance put: #(#= 2);
		at: #odbcSQLConformance put: #(#= 1);
		at: #procedureTerm put: #(#sameAs: 'stored procedure');
		at: #schemaTerm put: #(#sameAs: 'owner');
		at: #catalogTerm put: #(#sameAs: 'database');
		at: #tableTerm put: #(#sameAs: 'table');
		at: #supportedCursorTypes
			put: #(#assertCollection:hasSameElements: #(#forwardOnly #keysetDriven #static #dynamic));
		at: #supportedTransactionIsolationLevels
			put: #(#assertCollection:hasSameElements: #(#readUncommitted #readCommitted #serializable #repeatableRead));
		at: #supportsExpressionsInOrderBy put: #(#== true);
		at: #supportsMultipleActiveTransactions put: #(#== true);
		at: #supportsMultipleResultSets put: #(#== true);
		at: #supportsOuterJoins put: #(#== false);
		at: #supportsRowUpdates put: #(#== false);
		at: #userName put: #(#= 'dbo');
		at: #convertFunctions put: #(#assertCollection:hasSameElements: #('SQL_FN_CVT_CONVERT'));
		at: #searchPatternEscape put: #(#= '\');
		yourself
]

{ #category : #'unit tests' }
SQLServerODBCTest >> queryColumns [
	^#(#('OrderID' SQL_INTEGER 4) #('CustomerID' SQL_WCHAR 10) #('EmployeeID' SQL_INTEGER 4) #('OrderDate' SQL_TYPE_TIMESTAMP 16) #('RequiredDate' SQL_TYPE_TIMESTAMP 16) #('ShippedDate' SQL_TYPE_TIMESTAMP 16) #('ShipVia' SQL_INTEGER 4) #('Freight' SQL_DECIMAL 21) #('ShipName' SQL_WVARCHAR 80) #('ShipAddress' SQL_WVARCHAR 120) #('ShipCity' SQL_WVARCHAR 30) #('ShipRegion' SQL_WVARCHAR 30) #('ShipPostalCode' SQL_WVARCHAR 20) #('ShipCountry' SQL_WVARCHAR 30))
]

{ #category : #'unit tests' }
SQLServerODBCTest >> testForeignKeysQuery [
	| keys map |
	keys := connection queryForeignKeysOf: 'Orders'.
	self assert: keys size equals: 3.
	map := Dictionary new.
	keys do: [:each | map at: (each at: 'PKTABLE_NAME') put: each].
	#(#('Customers' 'CustomerID') #('Employees' 'EmployeeID') #('Shippers' 'ShipperID' 'ShipVia')) do: 
			[:each |
			| key |
			key := map at: each first.
			self assert: (key at: 'PKCOLUMN_NAME') equals: each second.
			self assert: (key at: 'FKCOLUMN_NAME') equals: each last]
]

{ #category : #'unit tests' }
SQLServerODBCTest >> testPrimaryKeysQuery [
	| pkeys |
	pkeys := connection primaryKeysOf: 'Orders'.
	self assert: pkeys size equals: 1.
	self assert: pkeys first equals: 'OrderID'
]

{ #category : #'unit tests' }
SQLServerODBCTest >> testProceduresQuery [
	| procs |
	procs := connection procedures.
	self assert: (procs includes: 'Employee Sales by Country;1')
]

{ #category : #'unit tests' }
SQLServerODBCTest >> testSQLServerConnectionAttributes [
	connection transactionIsolation: #readUncommitted.
	self assert: connection transactionIsolation equals: #readUncommitted.
	connection loginTimeout: 30.
	self assert: connection loginTimeout equals: 30.
	connection translate: 1.
	self assert: connection translate equals: 1.
	self assert: connection translationDLL isEmpty.
	"SQL server seems to ignore this"
	connection translationDLL: 'sqlsort.dll'.
	self assert: connection translationDLL equals: 'sqlsort.dll'.
	self assert: connection uid notNil.
	self assert: connection pwd notNil
]

{ #category : #public }
SQLServerODBCTest >> testTablesQuery [
	| tables |
	tables := connection
				tables: nil
				owners: 'dbo'
				tables: nil
				types: '''TABLE'''.
	self assertCollection: tables
				hasSameElements: #('Categories' 'CustomerCustomerDemo' 'CustomerDemographics' 'Customers' 'Employees' 'EmployeeTerritories' 'Order Details' 'Orders' 'Products' 'Region' 'Shippers' 'Suppliers' 'Territories')
]

{ #category : #public }
SQLServerODBCTest >> testViewsQuery [
	| views |
	views := connection
				tables: nil
				owners: 'dbo'
				tables: nil
				types: '''VIEW'''.
	self assertCollection: views
				hasSameElements: #('Alphabetical list of products' 'Category Sales for 1997' 'Current Product List' 'Customer and Suppliers by City' 'Invoices' 'Order Details Extended' 'Order Subtotals' 'Orders Qry' 'Product Sales for 1997' 'Products Above Average Price' 'Products by Category' 'Quarterly Orders' 'Sales by Category' 'Sales Totals by Amount' 'Summary of Sales by Quarter' 'Summary of Sales by Year')
]
