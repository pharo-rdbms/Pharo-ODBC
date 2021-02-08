# Pharo-ODBC
ODBC framework for [Pharo](https://pharo.org/) based on [Dolphin Smalltalk](https://github.com/dolphinsmalltalk/Dolphin)'s Database Connection package.<BR>
Thanks to [InfOil](http://www.infoil.com.ar) for supporting this project.

### Installation
```Smalltalk
Metacello new
	repository: 'github://rko281/Pharo-ODBC';
	baseline: 'Pharo-ODBC';
	load
```

On non-Windows platforms you will also need to install an appropriate ODBC Driver Manager:
- [iODBC](http://www.iodbc.org/)
- [unixODBC](http://www.unixodbc.org/)

### Getting Started
 - See the [Database Connection section](http://www.object-arts.com/downloads/docs/index.html?databaseconnectivity.htm) in the Dolphin Smalltalk Education Center
 - Note that in Pharo-ODBC, Dolphin classes prefixed `DB` are now prefixed `ODBC`. For example `DBConnection`becomes `ODBCConnection`. Method names remain the same. 
 - [Another source of Database Connection documentation](http://duch.mimuw.edu.pl/~sl/teaching/00_01/Delfin_EC/DatabaseConnection/DatabaseConnection.htm)

### Unit Tests
The folder test-resources contains files used by the unit tests - northwind.mdb (Access) and northwind.sql (SQL Server). Copy these to the root image directory to run the tests (see test classes for further info).

### Licence
[MIT Licence](https://github.com/rko281/Pharo-ODBC/blob/main/LICENSE) as per [Dolphin Smalltalk](https://github.com/dolphinsmalltalk/Dolphin/blob/master/LICENSE).<BR>
Dolphin Smalltalk Copyright (c) 2015 Object Arts<BR>
