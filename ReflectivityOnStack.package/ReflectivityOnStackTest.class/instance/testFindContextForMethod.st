tests - finding
testFindContextForMethod
	"look for the context that calls this method when running the test"

	| contexts |
	[
	contexts := Processor findContextsForMethod:
		            DelayBasicScheduler >> #runBackendLoopAtTimingPriority.
		
	"The assertion depends on what we want to do: if we want to replace the context by another one, then we should use the first assertion as we need to return the callee to modify its sender. If we want to simply change the method of the context, then we should use the second assert because there is no need to return the callee if we do not change its sender"

	"	self
		assert: contexts first sender method selector
		equals: #runBackendLoopAtTimingPriority "
	self
		assert: contexts first method selector
		equals: #runBackendLoopAtTimingPriority ] valueUnpreemptively