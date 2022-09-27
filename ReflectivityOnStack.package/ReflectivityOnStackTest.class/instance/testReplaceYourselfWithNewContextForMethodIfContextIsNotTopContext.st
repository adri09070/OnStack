tests - finding
testReplaceYourselfWithNewContextForMethodIfContextIsNotTopContext

	| instance process context method calleeContext senderContext |
	instance := ReflectivityExampleOnStack new.


	process := [ instance exampleMethodWaitingOnSemaphore ] fork.
	0.1 seconds wait.


	calleeContext := process suspendedContext.
	context := calleeContext sender.
	senderContext := context sender.
	method := context method.

	context
		replaceYourselfWithNewContextForMethod:
		ReflectivityExampleOnStack >> #exampleMethodWaitingOnSemaphore
		withCalledContext: calleeContext.

	self
		assert: calleeContext sender method
		identicalTo:
		ReflectivityExampleOnStack >> #exampleMethodWaitingOnSemaphore.
	self deny: calleeContext sender == context.

	instance continue.
	0.1 seconds wait.

	self assert: process isTerminated