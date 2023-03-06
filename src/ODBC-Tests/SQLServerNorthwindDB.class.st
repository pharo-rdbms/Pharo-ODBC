"
Access to Northwind Test database using Microsoft SQL Server for tests as a reusable test resource
"
Class {
	#name : #SQLServerNorthwindDB,
	#superclass : #ODBCConnectionTestResource,
	#category : #'ODBC-Tests-Resources'
}

{ #category : #'private - accessing' }
SQLServerNorthwindDB >> connectString [
	"Private - APPVEYOR config is 'DRIVER=SQL Server;Server=(local)\SQL2017;Database=master;User ID=sa;Password=Password12!'"

	^'DRIVER=SQL Server;Server=<1s>;Database=master;uid=<2s>;pwd=<3s>;Language=us_english'
		expandMacrosWith: self serverName
		with: self uid
		with: self pwd
]

{ #category : #private }
SQLServerNorthwindDB >> createDatabase [
	| sql cmd |

	sql := 'Northwind.sql' asFileReference pathString.
	cmd := 'sqlcmd -S <1s> -U <2s> -P <3s> -i "<4s>"'
				expandMacrosWith: self serverName
				with: self uid
				with: self pwd
				with: sql.
	LibC uniqueInstance system: cmd.
	^true
]

{ #category : #private }
SQLServerNorthwindDB >> dropDatabase [
	self connection
		ifNotNil:
			[:cnxn |
			cnxn
				exec: 'USE [master]';
				exec: 'DROP DATABASE [Northwind]'].
	super dropDatabase
]

{ #category : #public }
SQLServerNorthwindDB >> newConnection [

	| tmp1 tmp3 |
	tmp3 := tmp1 := super newConnection.
	^ tmp3 ifNotNil: [
		  tmp1
			  exec: 'USE [Northwind]';
			  yourself ]
]

{ #category : #'private - credentials' }
SQLServerNorthwindDB >> pwd [
	^'Password12!'
]

{ #category : #'private - accessing' }
SQLServerNorthwindDB >> serverName [
	^'(local)\SQL2019'
]

{ #category : #'private - credentials' }
SQLServerNorthwindDB >> uid [
	^'sa'
]
