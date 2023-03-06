# Pharo-ODBC
ODBC framework for [Pharo](https://pharo.org/) based on [Dolphin Smalltalk](https://github.com/dolphinsmalltalk/Dolphin)'s Database Connection package.<BR>
Thanks to [InfOil](http://www.infoil.com.ar) for supporting this project.

### Installation
```Smalltalk
Metacello new
	repository: 'github://pharo-rdbms/Pharo-ODBC/src';
	baseline: 'ODBC';
	load
```
#### Windows

- hit WINDOWS-KEY + R for "Run" command panel
- Type, in the run command, the following depending on your system: 
-- For 32-bit operating systems: ODBCAD32. 
-- For 64-bit operating systems: 

32 bit panel
```
%windir%\syswow64\odbcad32.exe
```
64 bit panel
```
%windir%\system32\odbcad32.exe
```
- Click OK.


On non-Windows platforms you will also need to install an appropriate ODBC Driver Manager:

#### MacOS
- see [iODBC](http://www.iodbc.org/)

#### Linux

- see [unixODBC](http://www.unixodbc.org/)

```
sudo apt-get install unixodbc unixodbc-dev
```

### Getting Started
 - See the [Database Connection section](http://www.object-arts.com/downloads/docs/index.html?databaseconnectivity.htm) in the Dolphin Smalltalk Education Center
 - Note that in Pharo-ODBC, Dolphin classes prefixed `DB` are now prefixed `ODBC`. For example `DBConnection`becomes `ODBCConnection`. Method names remain the same. 
 - [Another source of Database Connection documentation](http://duch.mimuw.edu.pl/~sl/teaching/00_01/Delfin_EC/DatabaseConnection/DatabaseConnection.htm)

### Unit Tests
The folder test-resources contains compressed files required by the unit tests - northwind.mdb (Access) and northwind.sql (SQL Server). Unpack these to the root image directory to run the tests (see test classes for further info).

### Licence
[MIT Licence](LICENSE).<BR>
[Dolphin Smalltalk](https://github.com/dolphinsmalltalk/Dolphin/blob/master/LICENSE) Copyright (c) 2015 Object Arts<BR>
Dolphin Smalltalk ODBC Database Connection Package Copyright (c) Object Arts Ltd, 1997-2003. Portions copyright CGI Group (Europe) Ltd, 1997.
