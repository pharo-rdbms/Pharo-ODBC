"
An ODBCBoundRow represnts a database row buffer that is directly bound to allocated memory for its columns. 

This is the normal type of buffer used by the Database Connection as it is more efficient when multiple rows are fetched.
			
Based on DBBoundRow from Dolphin Smalltalk Database Connection package.


"
Class {
	#name : #ODBCBoundBuffer,
	#superclass : #ODBCRowBuffer,
	#pools : [
		'ODBCCTypes',
		'ODBCConstants'
	],
	#category : #'ODBC-Core-Base'
}

{ #category : #operations }
ODBCBoundBuffer >> bind: aDBStatement [
	"Private - Bind the receiver's field buffers to columns in the result table."

	| hStmt odbc |
	hStmt := super bind: aDBStatement.
	odbc := ODBCLibrary default.
	self contents do:
			[:eachField |
			| dataBuffer column |
			column := eachField column.
			dataBuffer := eachField fieldBuf.
			aDBStatement dbCheckException: (odbc
						sqlBindCol: hStmt
						columnNumber: column columnNumber
						targetType: column cType
						targetValuePtr: dataBuffer
						bufferLength: eachField bufferSize
						strLenOrInd: eachField lengthBuf)].
	^ hStmt
]

{ #category : #'data retrieval' }
ODBCBoundBuffer >> getData: aDBStatement [
	"Private - Not currently relevant to a bound row, though it might be if
	we wanted to use SQLGetData for long values."
]
