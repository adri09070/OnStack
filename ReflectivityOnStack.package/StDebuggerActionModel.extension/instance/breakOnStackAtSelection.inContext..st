*ReflectivityOnStack
breakOnStackAtSelection: anInterval inContext: aContext

	| currentMethod astNode allContextsForCurrentMethod newMethod |
	currentMethod := aContext compiledCode.
	astNode := aContext compiledCode ast bestNodeFor: anInterval.
	DebugPointManager installNew: BreakDebugPoint on: astNode.
	newMethod := aContext methodClass >> aContext selector.
	self assert: currentMethod ~= newMethod.
	allContextsForCurrentMethod := self interruptedProcess
		                               findContextsForMethod: currentMethod.
	allContextsForCurrentMethod do: [ :ctx | ctx method: newMethod ].

	self updateContextChanged