tests
testExecuteWithWaitingWithLinkInstalledAfterExecutionOfMethodBeforeExecutionOfBlockBeforeCreationOfBlockChangeMethodManually

	| instance messageNode process |
	instance := ReflectivityExampleOnStack new.



	process := [ instance exampleMethodWaitingOnSemaphoreWithBlockAfter ]
		           fork.
	0.1 seconds wait.
	"If we install a link after we execute, we expect it to not matter for this test, as the new code will not be executed"
	messageNode := (ReflectivityExampleOnStack
	                >> #exampleMethodWaitingOnSemaphoreWithBlockAfter)
		               ast blockNodes first assignmentNodes second.
	link := MetaLink new
		        metaObject: self;
		        selector: #tagExec.
	messageNode link: link.
	self assert: messageNode hasMetalink.
	self
		assert: (ReflectivityExampleOnStack
			 >> #exampleMethodWaitingOnSemaphoreWithBlockAfter) class
		equals: ReflectiveMethod.
	self assert: tag isNil.


	"Here we could do the on stack replacement manually"

	self
		assert: (ReflectivityExampleOnStack
			 >> #exampleMethodWaitingOnSemaphoreWithBlockAfter) class
		equals: ReflectiveMethod.

	"make sure to create the compiledMethod"
	(ReflectivityExampleOnStack
	 >> #exampleMethodWaitingOnSemaphoreWithBlockAfter)
		compileAndInstallCompiledMethod.

	process suspendedContext method: ReflectivityExampleOnStack
		>> #exampleMethodWaitingOnSemaphoreWithBlockAfter.

	"here check that the method is on the stack"

	self
		assert: process suspendedContext method selector
		equals: #exampleMethodWaitingOnSemaphoreWithBlockAfter.
	"process should be running"
	self deny: process isTerminated.

	instance continue.
	0.1 seconds wait.
	self assert: process isTerminated.


	"It got executed!!"
	self assert: tag notNil