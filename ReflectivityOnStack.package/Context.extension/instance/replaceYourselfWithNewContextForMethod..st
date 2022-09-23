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