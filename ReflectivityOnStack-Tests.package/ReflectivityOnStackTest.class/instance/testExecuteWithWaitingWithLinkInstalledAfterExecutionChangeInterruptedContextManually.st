tests
testExecuteWithWaitingWithLinkInstalledAfterExecutionChangeInterruptedContextManually

	| instance messageNode process |
	self skip.
	instance := ReflectivityExampleOnStack new.



	process := [ instance exampleMethodWaitingOnSemaphoreDirectly ] fork.
	0.1 seconds wait.
	"If we install a link after we execute, we expect it to not matter for this test, as the new code will not be executed"
	messageNode := (ReflectivityExampleOnStack
	                >> #exampleMethodWaitingOnSemaphoreDirectly) ast
		               sendNodes third.
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

	process suspendedContext
		replaceYourselfWithNewContextForMethod:
		ReflectivityExampleOnStack
		>> #exampleMethodWaitingOnSemaphoreDirectly
		withCalledContext: process suspendedContext.

	"here check that the method is on the stack"

	self
		assert: process suspendedContext method selector
		equals: #exampleMethodWaitingOnSemaphoreDirectly.
	"process should be running"
	self deny: process isTerminated.

	"why do we need to call it twice?"

	process resume.
	instance continue.
	0.1 seconds wait.

	self assert: process isTerminated.


	"It got executed!!"
	self assert: tag notNil