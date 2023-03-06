"
ODBCTIME is a representation of the same named Win32 ODBC structure.
"
Class {
	#name : #ODBCTIME,
	#superclass : #FFIStructure,
	#classVars : [
		'OFFSET_HOUR',
		'OFFSET_MINUTE',
		'OFFSET_SECOND',
		'_OffsetOf_hour',
		'_OffsetOf_minute',
		'_OffsetOf_second'
	],
	#category : #'ODBC-FFI-Base'
}

{ #category : #'template definition' }
ODBCTIME class >> fieldsDesc [
	"Define the fields of the ODBC TIME structure

	self rebuildFieldAccessors

	typedef struct tagTIME_STRUCT
	{
		SQLUSMALLINT   hour;
		SQLUSMALLINT   minute;
		SQLUSMALLINT   second;
	} TIME_STRUCT;"

	^#(
		ushort 	hour
		ushort 	minute
		ushort 	second
		)
]

{ #category : #'instance creation' }
ODBCTIME class >> fromTime: aTime [
	"Answer an instance of the receiver with the details of aTime."

	^self new
		time: aTime;
		yourself
]

{ #category : #converting }
ODBCTIME >> asTime [
	"Answers a Time which represents the receiver."

	^Time fromSeconds: ((self hour * 60 + self minute) * 60 + self second)
]

{ #category : #'accessing structure variables' }
ODBCTIME >> hour [
	"This method was automatically generated"
	^handle unsignedShortAt: OFFSET_HOUR
]

{ #category : #'accessing structure variables' }
ODBCTIME >> hour: anObject [
	"This method was automatically generated"
	handle unsignedShortAt: OFFSET_HOUR put: anObject
]

{ #category : #'accessing structure variables' }
ODBCTIME >> minute [
	"This method was automatically generated"
	^handle unsignedShortAt: OFFSET_MINUTE
]

{ #category : #'accessing structure variables' }
ODBCTIME >> minute: anObject [
	"This method was automatically generated"
	handle unsignedShortAt: OFFSET_MINUTE put: anObject
]

{ #category : #'accessing structure variables' }
ODBCTIME >> second [
	"This method was automatically generated"
	^handle unsignedShortAt: OFFSET_SECOND
]

{ #category : #'accessing structure variables' }
ODBCTIME >> second: anObject [
	"This method was automatically generated"
	handle unsignedShortAt: OFFSET_SECOND put: anObject
]

{ #category : #accessing }
ODBCTIME >> time: aTime [
	"Set the receiver's fields from the <Time> argument."

	self
		hour: aTime hour;
		minute: aTime minute;
		second: aTime second
]
