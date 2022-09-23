*ReflectivityOnStack
replaceYourselfWithNewContextForMethod: aCompiledMethod

	"we want this method to
		
	1) create a new context for the method (e.g. for that number of temps)
	2) copy over all state
		including stack 
	   pc 
		temps
		
	3) put the sender of the new to the sender of me
	4) do the same for the one that this context called 
	"

	| newContext numTemps numArgs |
	numTemps := aCompiledMethod numTemps.
	numArgs := aCompiledMethod numArgs.
	newContext := self class
		              sender: self sender
		              receiver: self receiver
		              method: aCompiledMethod
		              arguments: aCompiledMethod arguments.

	newContext stackp: numTemps.
	1 to: numArgs do: [ :i | newContext at: i put: (self at: i) ].
	1 to: self basicSize do: [ :i | 
	newContext at: i + numArgs put: (self at: i) ].

	newContext pc: self pc.

	^ newContext