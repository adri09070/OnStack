tests
testExecuteWithWaitingWithBeforeLinkInstalledAfterExecutionAtInstructionChangeInterruptedMethodManually

	| instance messageNode process |
	instance := ReflectivityExampleOnStack new.

	process := [ instance exampleMethodWaitingOnSemaphoreDirectly ] fork.
	0.1 seconds wait.

	"If we install the link before the instruction the program stopped to, it should not be executed"
	messageNode := (ReflectivityExampleOnStack
	                >> #exampleMethodWaitingOnSemaphoreDirectly) ast
		               sendNodes second.
	link := MetaLink new
		        metaObject: self;
		        control: #before;
		        selector: #tagExec.
	messageNode link: link.
	self assert: messageNode hasMetalink.
	self
		assert: (ReflectivityExampleOnStack
			 >> #exampleMethodWaitingOnSemaphoreDirectly) class
		equals: ReflectiveMethod.
	self assert: tag isNil.

	self
		assert: (ReflectivityExampleOnStack
			 >> #exampleMethodWaitingOnSemaphoreDirectly) class
		equals: ReflectiveMethod.

	"make sure to create the compiledMethod"
	(ReflectivityExampleOnStack
	 >> #exampleMethodWaitingOnSemaphoreDirectly)
		compileAndInstallCompiledMethod.

	process suspendedContext method:
		ReflectivityExampleOnStack
		>> #exampleMethodWaitingOnSemaphoreDirectly.

	"here check that the method is on the stack"

	self
		assert: process suspendedContext method selector
		equals: #exampleMethodWaitingOnSemaphoreDirectly.
	"process should be running"
	self deny: process isTerminated.

	instance continue.
	0.1 seconds wait.
	self assert: process isTerminated.


	"It has not been executed!!"
	self assert: tag isNil