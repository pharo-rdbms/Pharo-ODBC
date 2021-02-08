"
ODBCDATE is a representation of the same named Win32 ODBC structure.
"
Class {
	#name : #ODBCDATE,
	#superclass : #FFIStructure,
	#classVars : [
		'OFFSET_DAY',
		'OFFSET_MONTH',
		'OFFSET_YEAR',
		'_OffsetOf_day',
		'_OffsetOf_month',
		'_OffsetOf_year'
	],
	#category : #'ODBC-FFI'
}

{ #category : #'template definition' }
ODBCDATE class >> fieldsDesc [
	"Define the fields of the ODBC DATE structure

	self rebuildFieldAccessors

	typedef struct tagDATE_STRUCT
	{
		SQLSMALLINT    year;
		SQLUSMALLINT   month;
		SQLUSMALLINT   day;
	} DATE_STRUCT;"

	^#(
		short 		year 
		ushort 	month
		ushort 	day
		)
]

{ #category : #'instance creation' }
ODBCDATE class >> fromDate: aDate [
	"Answer an instance of the receiver with the details of aDate."

	^self new
		date: aDate;
		yourself
]

{ #category : #converting }
ODBCDATE >> asDate [
	"Answers a Date which represents the receiver."

	^Date
		newDay: self day
		month: self month
		year: self year
]

{ #category : #accessing }
ODBCDATE >> date: aDate [
	"Set the receiver's fields from the <Date> argument."

	^aDate dayMonthYearDo: 
			[:d :m :y |
			self
				day: d;
				month: m;
				year: y]
]

{ #category : #'accessing structure variables' }
ODBCDATE >> day [
	"This method was automatically generated"
	^handle unsignedShortAt: OFFSET_DAY
]

{ #category : #'accessing structure variables' }
ODBCDATE >> day: anObject [
	"This method was automatically generated"
	handle unsignedShortAt: OFFSET_DAY put: anObject
]

{ #category : #'accessing structure variables' }
ODBCDATE >> month [
	"This method was automatically generated"
	^handle unsignedShortAt: OFFSET_MONTH
]

{ #category : #'accessing structure variables' }
ODBCDATE >> month: anObject [
	"This method was automatically generated"
	handle unsignedShortAt: OFFSET_MONTH put: anObject
]

{ #category : #'accessing structure variables' }
ODBCDATE >> year [
	"This method was automatically generated"
	^handle signedShortAt: OFFSET_YEAR
]

{ #category : #'accessing structure variables' }
ODBCDATE >> year: anObject [
	"This method was automatically generated"
	handle signedShortAt: OFFSET_YEAR put: anObject
]
