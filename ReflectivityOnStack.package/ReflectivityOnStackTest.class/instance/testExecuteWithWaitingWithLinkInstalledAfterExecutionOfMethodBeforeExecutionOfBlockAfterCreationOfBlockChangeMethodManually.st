tests
testExecuteWithWaitingWithLinkInstalledAfterExecutionOfMethodBeforeExecutionOfBlockAfterCreationOfBlockChangeMethodManually

	| instance messageNode process |
	instance := ReflectivityExampleOnStack new.



	process := [
	           instance
		           exampleMethodWaitingOnSemaphoreWithBlockStoreInVariableBefore ]
		           fork.
	0.1 seconds wait.
	"If we install a link after we execute, we expect it to not matter for this test, as the new code will not be executed"
	messageNode := (ReflectivityExampleOnStack
	                >>
	                #exampleMethodWaitingOnSemaphoreWithBlockStoreInVariableBefore)
		               ast blockNodes first assignmentNodes second.
	link := MetaLink new
		        metaObject: self;
		        selector: #tagExec.
	messageNode link: link.
	self assert: messageNode hasMetalink.
	self
		assert: (ReflectivityExampleOnStack
			 >> #exampleMethodWaitingOnSemaphoreWithBlockStoreInVariableBefore)
				class
		equals: ReflectiveMethod.
	self assert: tag isNil.


	"Here we could do the on stack replacement manually"

	self
		assert: (ReflectivityExampleOnStack
			 >> #exampleMethodWaitingOnSemaphoreWithBlockStoreInVariableBefore)
				class
		equals: ReflectiveMethod.

	"make sure to create the compiledMethod"
	(ReflectivityExampleOnStack
	 >> #exampleMethodWaitingOnSemaphoreWithBlockStoreInVariableBefore)
		compileAndInstallCompiledMethod.

	process suspendedContext method: ReflectivityExampleOnStack
		>> #exampleMethodWaitingOnSemaphoreWithBlockStoreInVariableBefore.

	"here check that the method is on the stack"

	self
		assert: process suspendedContext method selector
		equals:
		#exampleMethodWaitingOnSemaphoreWithBlockStoreInVariableBefore.
	"process should be running"
	self deny: process isTerminated.

	instance continue.
	0.1 seconds wait.
	self assert: process isTerminated.


	"It got executed!!"
	self assert: tag notNil