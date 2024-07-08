tests
testExecuteWithWaitingWithLinkInstalledInOuterMethodAfterExecutionOfMethodAfterExecutionOfEmbeddedBlockChangeMethodManually

	| instance messageNode process |
	instance := ReflectivityExampleOnStack new.
	ReflectivityExampleOnStack
	>> #exampleMethodWaitingOnSemaphoreInEmbeddedBlock
		propertyAt: #bcToASTCache
		put: (ReflectivityExampleOnStack
			 >> #exampleMethodWaitingOnSemaphoreInEmbeddedBlock) ast bcToASTCache .
	1 halt.

	process := [ instance exampleMethodWaitingOnSemaphoreInEmbeddedBlock ]
		           fork.
	0.1 seconds wait.
	"If we install a link after we execute, we expect it to not matter for this test, as the new code will not be executed"
	messageNode := (ReflectivityExampleOnStack
	                >> #exampleMethodWaitingOnSemaphoreInEmbeddedBlock)
		               ast sendNodes last.
	link := MetaLink new
		        metaObject: self;
		        selector: #tagExec.
	messageNode link: link.

	self assert: messageNode hasMetalink.
	self
		assert: (ReflectivityExampleOnStack
			 >> #exampleMethodWaitingOnSemaphoreInEmbeddedBlock) class
		equals: ReflectiveMethod.
	self assert: tag isNil.



	"make sure to create the compiledMethod"
	1 halt.
	(ReflectivityExampleOnStack
	 >> #exampleMethodWaitingOnSemaphoreInEmbeddedBlock)
		compileAndInstallCompiledMethod.

	(process findContextsForMethod: process suspendedContext method) do: [
		:ctx |
		ctx method: ReflectivityExampleOnStack
			>> #exampleMethodWaitingOnSemaphoreInEmbeddedBlock ].

	"here check that the method is on the stack"

	self
		assert: process suspendedContext sender sender method selector
		equals: #exampleMethodWaitingOnSemaphoreInEmbeddedBlock.
	"process should be running"
	self deny: process isTerminated.

	instance continue.
	0.1 seconds wait.
	self assert: process isTerminated.

	"It got executed!!"
	self assert: tag notNil