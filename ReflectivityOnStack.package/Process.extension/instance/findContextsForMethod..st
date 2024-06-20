*ReflectivityOnStack
findContextsForMethod: aMethod
	| context priorContext found |
	found := OrderedCollection new.
	
	context := suspendedContext.
	priorContext := nil.
	[ context isNil ] whileFalse: [
		context method = aMethod
			ifTrue: [found add: context ].
		priorContext := context.
		context := context sender ].
	^ found