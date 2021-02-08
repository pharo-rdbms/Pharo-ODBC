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

{ #category : #'pool initialization' }
ODBCColFlags class >> initialize [
	self
		initialize_DeleteCascade;
		initialize_DeleteRestrict;
		initialize_DeleteRules;
		initialize_DeleteSetNull;
		initialize_ForeignKey;
		initialize_ParameterTypeMask;
		initialize_ParameterTypeShift;
		initialize_PrimaryKey;
		initialize_UpdateCascade;
		initialize_UpdateRestrict;
		initialize_UpdateRules;
		initialize_UpdateSetNull;
		yourself
]

{ #category : #'pool initialization' }
ODBCColFlags class >> initialize_DeleteCascade [
	DeleteCascade := 16
]

{ #category : #'pool initialization' }
ODBCColFlags class >> initialize_DeleteRestrict [
	DeleteRestrict := 32
]

{ #category : #'pool initialization' }
ODBCColFlags class >> initialize_DeleteRules [
	DeleteRules := 112
]

{ #category : #'pool initialization' }
ODBCColFlags class >> initialize_DeleteSetNull [
	DeleteSetNull := 64
]

{ #category : #'pool initialization' }
ODBCColFlags class >> initialize_ForeignKey [
	ForeignKey := 2
]

{ #category : #'pool initialization' }
ODBCColFlags class >> initialize_ParameterTypeMask [
	ParameterTypeMask := 14336
]

{ #category : #'pool initialization' }
ODBCColFlags class >> initialize_ParameterTypeShift [
	ParameterTypeShift := 11
]

{ #category : #'pool initialization' }
ODBCColFlags class >> initialize_PrimaryKey [
	PrimaryKey := 1
]

{ #category : #'pool initialization' }
ODBCColFlags class >> initialize_UpdateCascade [
	UpdateCascade := 256
]

{ #category : #'pool initialization' }
ODBCColFlags class >> initialize_UpdateRestrict [
	UpdateRestrict := 512
]

{ #category : #'pool initialization' }
ODBCColFlags class >> initialize_UpdateRules [
	UpdateRules := 1792
]

{ #category : #'pool initialization' }
ODBCColFlags class >> initialize_UpdateSetNull [
	UpdateSetNull := 1024
]
