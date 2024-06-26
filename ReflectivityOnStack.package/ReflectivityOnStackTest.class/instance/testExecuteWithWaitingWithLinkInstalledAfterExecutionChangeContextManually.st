tests
testExecuteWithWaitingWithLinkInstalledAfterExecutionChangeContextManually

	| instance messageNode process |
	instance := ReflectivityExampleOnStack new.



	process := [ instance exampleMethodWaitingOnSemaphore  ] fork.
	0.1 seconds wait.
	"If we install a link after we execute, we expect it to not matter for this test, as the new code will not be executed"
	messageNode := (ReflectivityExampleOnStack
	                >> #exampleMethodWaitingOnSemaphore) ast sendNodes
		               third.
	link := MetaLink new
		        metaObject: self;
		        selector: #tagExec.
	messageNode link: link.
	self assert: messageNode hasMetalink.
	self
		assert:
		(ReflectivityExampleOnStack >> #exampleMethodWaitingOnSemaphore)
			class
		equals: ReflectiveMethod.
	self assert: tag isNil.


	"Here we could do the on stack replacement manually"

	self
		assert:
		(ReflectivityExampleOnStack >> #exampleMethodWaitingOnSemaphore)
			class
		equals: ReflectiveMethod.

	"make sure to create the compiledMethod"
	(ReflectivityExampleOnStack >> #exampleMethodWaitingOnSemaphore)
		compileAndInstallCompiledMethod.

	process suspendedContext sender
		replaceYourselfWithNewContextForMethod:
		ReflectivityExampleOnStack >> #exampleMethodWaitingOnSemaphore
		withCalledContext: process suspendedContext.

	"here check that the method is on the stack"

	self
		assert: process suspendedContext sender method selector
		equals: #exampleMethodWaitingOnSemaphore.
	"process should be running"
	self deny: process isTerminated.

	"why do we need to call it twice?"

	process resume.
	instance continue.
	0.1 seconds wait.

	self assert: process isTerminated.


	"It got executed!!"
	self assert: tag notNil