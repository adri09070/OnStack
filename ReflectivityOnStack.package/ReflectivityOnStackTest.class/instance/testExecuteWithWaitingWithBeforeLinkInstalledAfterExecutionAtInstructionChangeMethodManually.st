tests
testExecuteWithWaitingWithBeforeLinkInstalledAfterExecutionAtInstructionChangeMethodManually

	| instance messageNode process |
	instance := ReflectivityExampleOnStack new.

	process := [ instance exampleMethodWaitingOnSemaphore ] fork.
	0.1 seconds wait.

	"If we install the link before the instruction the program stopped to, it should not be executed"
	messageNode := (ReflectivityExampleOnStack
	                >> #exampleMethodWaitingOnSemaphore) ast sendNodes
		               second.
	link := MetaLink new
		        metaObject: self;
		        control: #before;
		        selector: #tagExec.
	messageNode link: link.
	self assert: messageNode hasMetalink.
	self
		assert:
		(ReflectivityExampleOnStack >> #exampleMethodWaitingOnSemaphore)
			class
		equals: ReflectiveMethod.
	self assert: tag isNil.

	self
		assert:
		(ReflectivityExampleOnStack >> #exampleMethodWaitingOnSemaphore)
			class
		equals: ReflectiveMethod.

	"make sure to create the compiledMethod"
	(ReflectivityExampleOnStack >> #exampleMethodWaitingOnSemaphore)
		compileAndInstallCompiledMethod.

	process suspendedContext sender method:
		ReflectivityExampleOnStack >> #exampleMethodWaitingOnSemaphore.

	"here check that the method is on the stack"

	self
		assert: process suspendedContext sender method selector
		equals: #exampleMethodWaitingOnSemaphore.
	"process should be running"
	self deny: process isTerminated.

	instance continue.
	0.1 seconds wait.
	self assert: process isTerminated.


	"It has not been executed!!"
	self assert: tag isNil