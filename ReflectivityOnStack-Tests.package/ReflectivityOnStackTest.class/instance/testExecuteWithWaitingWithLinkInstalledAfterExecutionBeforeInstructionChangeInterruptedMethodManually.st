tests
testExecuteWithWaitingWithLinkInstalledAfterExecutionBeforeInstructionChangeInterruptedMethodManually

	| instance messageNode process |
	instance := ReflectivityExampleOnStack new.

	process := [ instance exampleMethodWaitingOnSemaphoreDirectly ] fork.
	0.1 seconds wait.
	"If we install a link before the instruction the program stopped to, the link should not be executed"
	messageNode := (ReflectivityExampleOnStack
	                >> #exampleMethodWaitingOnSemaphoreDirectly) ast
		               sendNodes first.
	link := MetaLink new
		        metaObject: self;
		        selector: #tagExec.
	messageNode link: link.
	self assert: messageNode hasMetalink.
	self
		assert: (ReflectivityExampleOnStack
			 >> #exampleMethodWaitingOnSemaphoreDirectly) class
		equals: ReflectiveMethod.
	self assert: tag isNil.


	"Here we could do the on stack replacement manually"

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


	"It was not executed!!"
	self assert: tag isNil