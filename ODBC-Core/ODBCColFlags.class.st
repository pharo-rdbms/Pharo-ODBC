"
Based on DBColFlags pool dictionary from Dolphin Smalltalk Database Connection package.
"
Class {
	#name : #ODBCColFlags,
	#superclass : #SharedPool,
	#classVars : [
		'DeleteCascade',
		'DeleteRestrict',
		'DeleteRules',
		'DeleteSetNull',
		'ForeignKey',
		'ParameterTypeMask',
		'ParameterTypeShift',
		'PrimaryKey',
		'UpdateCascade',
		'UpdateRestrict',
		'UpdateRules',
		'UpdateSetNull'
	],
	#category : #'ODBC-Core-Base'
}

{ #category : #'private - pool initialization' }
ODBCColFlags class >> initialize [

	self
		initializeDeleteCascade;
		initializeDeleteRestrict;
		initializeDeleteRules;
		initializeDeleteSetNull;
		initializeForeignKey;
		initializeParameterTypeMask;
		initializeParameterTypeShift;
		initializePrimaryKey;
		initializeUpdateCascade;
		initializeUpdateRestrict;
		initializeUpdateRules;
		initializeUpdateSetNull 
]

{ #category : #'private - pool initialization' }
ODBCColFlags class >> initializeDeleteCascade [

	DeleteCascade := 16
]

{ #category : #'private - pool initialization' }
ODBCColFlags class >> initializeDeleteRestrict [

	DeleteRestrict := 32
]

{ #category : #'private - pool initialization' }
ODBCColFlags class >> initializeDeleteRules [

	DeleteRules := 112
]

{ #category : #'private - pool initialization' }
ODBCColFlags class >> initializeDeleteSetNull [

	DeleteSetNull := 64
]

{ #category : #'private - pool initialization' }
ODBCColFlags class >> initializeForeignKey [

	ForeignKey := 2
]

{ #category : #'private - pool initialization' }
ODBCColFlags class >> initializeParameterTypeMask [

	ParameterTypeMask := 14336
]

{ #category : #'private - pool initialization' }
ODBCColFlags class >> initializeParameterTypeShift [

	ParameterTypeShift := 11
]

{ #category : #'private - pool initialization' }
ODBCColFlags class >> initializePrimaryKey [

	PrimaryKey := 1
]

{ #category : #'private - pool initialization' }
ODBCColFlags class >> initializeUpdateCascade [

	UpdateCascade := 256
]

{ #category : #'private - pool initialization' }
ODBCColFlags class >> initializeUpdateRestrict [

	UpdateRestrict := 512
]

{ #category : #'private - pool initialization' }
ODBCColFlags class >> initializeUpdateRules [

	UpdateRules := 1792
]

{ #category : #'private - pool initialization' }
ODBCColFlags class >> initializeUpdateSetNull [

	UpdateSetNull := 1024
]
