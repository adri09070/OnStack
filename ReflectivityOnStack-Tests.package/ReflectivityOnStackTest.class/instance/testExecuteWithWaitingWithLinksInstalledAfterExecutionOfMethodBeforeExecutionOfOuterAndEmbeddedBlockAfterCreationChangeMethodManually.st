tests
testExecuteWithWaitingWithLinksInstalledAfterExecutionOfMethodBeforeExecutionOfOuterAndEmbeddedBlockAfterCreationChangeMethodManually

	| instance messageNode process messageNode2 |
	instance := ReflectivityExampleOnStack new.

	process := [
	           instance
		           exampleMethodWaitingOnSemaphoreInMethodWithOuterBlockStoreInVariableBefore ]
		           fork.
	0.1 seconds wait.
	"If we install a link after we execute, we expect it to not matter for this test, as the new code will not be executed"
	messageNode := (ReflectivityExampleOnStack
	                >>
	                #exampleMethodWaitingOnSemaphoreInMethodWithOuterBlockStoreInVariableBefore)
		               ast blockNodes first assignmentNodes second.
	link := MetaLink new
		        metaObject: self;
		        selector: #tagExec.
	messageNode link: link.

	messageNode2 := (ReflectivityExampleOnStack
	                 >>
	                 #exampleMethodWaitingOnSemaphoreInMethodWithOuterBlockStoreInVariableBefore)
		                ast blockNodes second assignmentNodes second.
	link2 := MetaLink new
		         metaObject: self;
		         selector: #tag2Exec.
	messageNode2 link: link2.

	self assert: messageNode hasMetalink.
	self assert: messageNode2 hasMetalink.
	self
		assert: (ReflectivityExampleOnStack
			 >>
			 #exampleMethodWaitingOnSemaphoreInMethodWithOuterBlockStoreInVariableBefore)
				class
		equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: tag2 isNil.

	"make sure to create the compiledMethod"
	(ReflectivityExampleOnStack
	 >>
	 #exampleMethodWaitingOnSemaphoreInMethodWithOuterBlockStoreInVariableBefore)
		compileAndInstallCompiledMethod.

	process suspendedContext method: ReflectivityExampleOnStack
		>>
		#exampleMethodWaitingOnSemaphoreInMethodWithOuterBlockStoreInVariableBefore.

	"here check that the method is on the stack"

	self
		assert: process suspendedContext method selector
		equals:
		#exampleMethodWaitingOnSemaphoreInMethodWithOuterBlockStoreInVariableBefore.
	"process should be running"
	self deny: process isTerminated.

	instance continue.
	0.1 seconds wait.
	self assert: process isTerminated.

	"It got executed!!"
	self assert: tag notNil.
	self assert: tag2 notNil