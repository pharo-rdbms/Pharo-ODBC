"
ODBCErrorDetails instances hold information about a particular ODBC sub-error.

Instance Variables:
	msg		<String>. Error message text.
	nativeErr		<String>. Database's native error code.
	sqlState		<String>. ODBC error code.
	origin		<String>. Layer from which the error originated.

Based on DBErrorDetails from Dolphin Smalltalk Database Connection package.
"
Class {
	#name : #ODBCErrorDetails,
	#superclass : #Object,
	#instVars : [
		'msg',
		'nativeErr',
		'sqlState',
		'origin'
	],
	#category : #'ODBC-Core-Base'
}

{ #category : #'instance creation' }
ODBCErrorDetails class >> fromSQLError: errorString [
	"Answer a new instance of the receiver built from the information in the
	<readableString>, errorString."

	| lastBrkt |
	lastBrkt := errorString lastIndexOf: $].
	^ self new
		msg: errorString;
		origin: (errorString copyFrom: 1 to: lastBrkt);
		yourself
]

{ #category : #accessing }
ODBCErrorDetails >> messageText [
	"Answer a text representation of the error of the form:
		STATE: MSG"

	^ (sqlState
			ifNil: [ '' ]
			ifNotNil: [ sqlState , ': ' ]) , msg
]

{ #category : #accessing }
ODBCErrorDetails >> msg [
	"Answer the msg instance variable."

	^ msg
]

{ #category : #accessing }
ODBCErrorDetails >> msg: aString [
	"Private - Set the msg instance variable to aString."

	msg := aString
]

{ #category : #accessing }
ODBCErrorDetails >> nativeErr: aString [
	"Private - Set the nativeErr instance variable to aString."

	nativeErr := aString
]

{ #category : #accessing }
ODBCErrorDetails >> origin: aString [
	"Private - Set the origin instance variable to aString."

	origin := aString
]

{ #category : #accessing }
ODBCErrorDetails >> sqlState [
	"Answer the sqlState instance variable."

	^ sqlState
]

{ #category : #accessing }
ODBCErrorDetails >> sqlState: aString [
	"Private - Set the sqlState instance variable to aString."

	sqlState := aString
]
