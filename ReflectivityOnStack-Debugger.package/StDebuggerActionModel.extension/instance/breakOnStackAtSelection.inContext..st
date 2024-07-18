*ReflectivityOnStack-Debugger
breakOnStackAtSelection: anInterval inContext: aContext

	| currentMethod astNode allContextsForCurrentMethod newMethod |
	currentMethod := aContext homeMethod.
	astNode := currentMethod ast bestNodeFor: anInterval.
	DebugPointManager installNew: BreakDebugPoint on: astNode.
	newMethod := aContext methodClass >> aContext selector.
	self assert: currentMethod ~= newMethod.
	allContextsForCurrentMethod := self interruptedProcess
		                               findContextsForMethod: currentMethod.
	allContextsForCurrentMethod do: [ :ctx | ctx method: newMethod ].

	self updateContextChanged