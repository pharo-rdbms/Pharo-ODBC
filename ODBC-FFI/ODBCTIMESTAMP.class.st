"
ODBCTIMESTAMP is a representation of the same named Win32 ODBC structure.

The fraction field is the number of billionths of a second, i.e. a value of 1,000,000 is one millisecond.
"
Class {
	#name : #ODBCTIMESTAMP,
	#superclass : #FFIStructure,
	#classVars : [
		'OFFSET_DAY',
		'OFFSET_FRACTION',
		'OFFSET_HOUR',
		'OFFSET_MINUTE',
		'OFFSET_MONTH',
		'OFFSET_SECOND',
		'OFFSET_YEAR'
	],
	#category : #'ODBC-FFI'
}

{ #category : #'template definition' }
ODBCTIMESTAMP class >> fieldsDesc [
	"Define the fields of the ODBC TIMESTAMP structure

	self rebuildFieldAccessors

	typedef struct tagTIMESTAMP_STRUCT
	{
		SQLSMALLINT    year;
		SQLUSMALLINT   month;
		SQLUSMALLINT   day;
		SQLUSMALLINT   hour;
		SQLUSMALLINT   minute;
		SQLUSMALLINT   second;
		SQLUINTEGER    fraction;
	} TIMESTAMP_STRUCT;"

	^#(
		short 		year 
		ushort 	month
		ushort 	day
		ushort 	hour
		ushort 	minute 
		ushort 	second
		uint32 	fraction
		)
]

{ #category : #'instance creation' }
ODBCTIMESTAMP class >> fromDateAndTime: aDateAndTime [
	"Answer an instance of the receiver representing the same local time as the <DateAndTime> argument."

	^self new
		dateAndTime: aDateAndTime;
		yourself
]

{ #category : #converting }
ODBCTIMESTAMP >> asDateAndTime [
	"Answers a DateAndTime which represents the receiver."

	^DateAndTime year: self year month: self month day: self day hour: self hour minute: self minute second: self second nanoSecond: self fraction offset: 0 seconds
]

{ #category : #accessing }
ODBCTIMESTAMP >> dateAndTime: aDateAndTime [
	"Set the receiver's field values from the <DateAndTime> argument."

	^aDateAndTime dayMonthYearDo: 
			[:d :m :y |
			self
				day: d;
				month: m;
				year: y;
				hour: aDateAndTime hour;
				minute: aDateAndTime minute;
				second: aDateAndTime second truncated;
				fraction: aDateAndTime nanoSecond truncated]
]

{ #category : #'accessing structure variables' }
ODBCTIMESTAMP >> day [
	"This method was automatically generated"
	^handle unsignedShortAt: OFFSET_DAY
]

{ #category : #'accessing structure variables' }
ODBCTIMESTAMP >> day: anObject [
	"This method was automatically generated"
	handle unsignedShortAt: OFFSET_DAY put: anObject
]

{ #category : #'accessing structure variables' }
ODBCTIMESTAMP >> fraction [
	"This method was automatically generated"
	^handle unsignedLongAt: OFFSET_FRACTION
]

{ #category : #'accessing structure variables' }
ODBCTIMESTAMP >> fraction: anObject [
	"This method was automatically generated"
	handle unsignedLongAt: OFFSET_FRACTION put: anObject
]

{ #category : #'accessing structure variables' }
ODBCTIMESTAMP >> hour [
	"This method was automatically generated"
	^handle unsignedShortAt: OFFSET_HOUR
]

{ #category : #'accessing structure variables' }
ODBCTIMESTAMP >> hour: anObject [
	"This method was automatically generated"
	handle unsignedShortAt: OFFSET_HOUR put: anObject
]

{ #category : #accessing }
ODBCTIMESTAMP >> milliseconds [
	"Answer the number of whole milliseconds in the fraction part of
	the receiver."

	^self fraction // 1000000
]

{ #category : #'accessing structure variables' }
ODBCTIMESTAMP >> minute [
	"This method was automatically generated"
	^handle unsignedShortAt: OFFSET_MINUTE
]

{ #category : #'accessing structure variables' }
ODBCTIMESTAMP >> minute: anObject [
	"This method was automatically generated"
	handle unsignedShortAt: OFFSET_MINUTE put: anObject
]

{ #category : #'accessing structure variables' }
ODBCTIMESTAMP >> month [
	"This method was automatically generated"
	^handle unsignedShortAt: OFFSET_MONTH
]

{ #category : #'accessing structure variables' }
ODBCTIMESTAMP >> month: anObject [
	"This method was automatically generated"
	handle unsignedShortAt: OFFSET_MONTH put: anObject
]

{ #category : #'accessing structure variables' }
ODBCTIMESTAMP >> second [
	"This method was automatically generated"
	^handle unsignedShortAt: OFFSET_SECOND
]

{ #category : #'accessing structure variables' }
ODBCTIMESTAMP >> second: anObject [
	"This method was automatically generated"
	handle unsignedShortAt: OFFSET_SECOND put: anObject
]

{ #category : #'accessing structure variables' }
ODBCTIMESTAMP >> year [
	"This method was automatically generated"
	^handle signedShortAt: OFFSET_YEAR
]

{ #category : #'accessing structure variables' }
ODBCTIMESTAMP >> year: anObject [
	"This method was automatically generated"
	handle signedShortAt: OFFSET_YEAR put: anObject
]
