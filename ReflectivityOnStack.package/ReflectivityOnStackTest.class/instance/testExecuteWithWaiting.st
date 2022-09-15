tests
testExecuteWithWaiting
	| instance process |
	instance := ReflectivityExampleOnStack new.
	
	process := [ instance exampleMethodWaitingOnSemaphore ] fork.

	"here check that the method is on the stack"	
	0.1 seconds wait.
	self assert: process suspendedContext sender method equals: ReflectivityExampleOnStack>>#exampleMethodWaitingOnSemaphore.
	
	"process should be running"
	self deny: process isTerminated.
	instance continue.
	0.1 seconds wait.
	self assert: process isTerminated.
