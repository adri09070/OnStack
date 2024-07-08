tests
testExecuteWithWaitingWithLinkInstalledInEmbeddedBlockAfterExecutionOfMethodAfterExecutionOfEmbeddedBlockChangeMethodManually

	| instance process messageNode2 |
	instance := ReflectivityExampleOnStack new.

	process := [ instance exampleMethodWaitingOnSemaphoreInEmbeddedBlock ]
		           fork.
	0.1 seconds wait.
	"If we install a link after we execute, we expect it to not matter for this test, as the new code will not be executed"
	messageNode2 := (ReflectivityExampleOnStack
	                 >> #exampleMethodWaitingOnSemaphoreInEmbeddedBlock)
		                ast blockNodes second assignmentNodes second.
	link2 := MetaLink new
		         metaObject: self;
		         selector: #tag2Exec.
	messageNode2 link: link2.

	self assert: messageNode2 hasMetalink.
	self
		assert: (ReflectivityExampleOnStack
			 >> #exampleMethodWaitingOnSemaphoreInEmbeddedBlock) class
		equals: ReflectiveMethod.
	self assert: tag2 isNil.

	"make sure to create the compiledMethod"
	(ReflectivityExampleOnStack
	 >> #exampleMethodWaitingOnSemaphoreInEmbeddedBlock)
		compileAndInstallCompiledMethod.

	1 halt.
	process suspendedContext method: ReflectivityExampleOnStack
		>> #exampleMethodWaitingOnSemaphoreInEmbeddedBlock.

	"here check that the method is on the stack"

	self
		assert: process suspendedContext method selector
		equals: #exampleMethodWaitingOnSemaphoreInEmbeddedBlock.
	"process should be running"
	self deny: process isTerminated.

	instance continue.
	0.1 seconds wait.
	self assert: process isTerminated.

	"It got executed!!"
	self assert: tag2 notNil