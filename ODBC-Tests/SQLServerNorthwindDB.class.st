Class {
	#name : #SQLServerNorthwindDB,
	#superclass : #ODBCConnectionTestResource,
	#category : #'ODBC-Tests'
}

{ #category : #private }
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
	^super newConnection
		ifNotNil: 
			[:cnxn |
			cnxn
				exec: 'USE [Northwind]';
				yourself]
]

{ #category : #private }
SQLServerNorthwindDB >> pwd [
	^'Password12!'
]

{ #category : #private }
SQLServerNorthwindDB >> serverName [
	^'(local)\SQL2019'
]

{ #category : #private }
SQLServerNorthwindDB >> uid [
	^'sa'
]
