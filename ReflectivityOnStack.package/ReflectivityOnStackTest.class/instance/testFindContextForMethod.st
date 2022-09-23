tests - finding
testFindContextForMethod

	"look for the context that calls this method when running the test"

	| contexts |
	[ 
	contexts := Processor findContextsForMethod:
		            DelayBasicScheduler >> #runBackendLoopAtTimingPriority.

	self
		assert: contexts first sender method selector
		equals: #runBackendLoopAtTimingPriority 
		
		
	] valueUnpreemptively