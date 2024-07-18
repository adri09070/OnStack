tests
testExecuteWithWaitingWithTwoLinksInstalledAfterExecutionBeforeAndAfterInstructionChangeMethodManually

	| instance thirdMessageNode secondMessageNode process |
	instance := ReflectivityExampleOnStack new.

	process := [ instance exampleMethodWaitingOnSemaphore ] fork.
	0.1 seconds wait.
	"If we install a link after we execute, we expect it to not matter for this test, as the new code will not be executed"
	thirdMessageNode := (ReflectivityExampleOnStack
	                     >> #exampleMethodWaitingOnSemaphore) ast
		                    sendNodes third.

	link := MetaLink new
		        metaObject: self;
		        selector: #tagExec.

	thirdMessageNode link: link.

	self assert: thirdMessageNode hasMetalink.
	self
		assert:
		(ReflectivityExampleOnStack >> #exampleMethodWaitingOnSemaphore)
			class
		equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: tag2 isNil.

	"we install second link"
	secondMessageNode := (ReflectivityExampleOnStack
	                      >> #exampleMethodWaitingOnSemaphore) ast
		                     sendNodes second.
	link2 := MetaLink new
		         metaObject: self;
		         selector: #tag2Exec.
	secondMessageNode link: link2.

	self assert: thirdMessageNode hasMetalink.
	self assert: secondMessageNode hasMetalink.
	self
		assert:
		(ReflectivityExampleOnStack >> #exampleMethodWaitingOnSemaphore)
			class
		equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: tag2 isNil.

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


	"only the metalink on the third message node got executed, because the second message node had already been executed"
	self assert: tag notNil.
	self assert: tag2 isNil