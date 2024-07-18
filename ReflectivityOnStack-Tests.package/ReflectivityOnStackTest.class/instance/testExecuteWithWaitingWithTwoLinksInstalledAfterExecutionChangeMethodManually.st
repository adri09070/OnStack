tests
testExecuteWithWaitingWithTwoLinksInstalledAfterExecutionChangeMethodManually

	| instance messageNode variableNode process |
	instance := ReflectivityExampleOnStack new.

	process := [ instance exampleMethodWaitingOnSemaphore ] fork.
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
	self assert: tag2 isNil.

	"make sure to create the compiledMethod"
	(ReflectivityExampleOnStack >> #exampleMethodWaitingOnSemaphore)
		compileAndInstallCompiledMethod.

	process suspendedContext sender method:
		ReflectivityExampleOnStack >> #exampleMethodWaitingOnSemaphore.
		
	"we install second link"
	variableNode := messageNode receiver.
	link2 := MetaLink new
		         metaObject: self;
		         selector: #tag2Exec.
	variableNode link: link2.

	self assert: messageNode hasMetalink.
	self assert: variableNode hasMetalink.
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


	"Both metalinks got executed!!"
	self assert: tag notNil.
	self assert: tag2 notNil