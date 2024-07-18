tests
testExecuteWithWaitingWithTwoLinksInstalledAfterExecutionChangeInterruptedMethodManually

	| instance messageNode variableNode process |
	instance := ReflectivityExampleOnStack new.

	process := [ instance exampleMethodWaitingOnSemaphoreDirectly ] fork.
	0.1 seconds wait.
	"If we install a link after we execute, we expect it to not matter for this test, as the new code will not be executed"
	messageNode := (ReflectivityExampleOnStack
	                >> #exampleMethodWaitingOnSemaphoreDirectly) ast sendNodes
		               third.

	link := MetaLink new
		        metaObject: self;
		        selector: #tagExec.

	messageNode link: link.

	self assert: messageNode hasMetalink.
	self
		assert:
		(ReflectivityExampleOnStack >> #exampleMethodWaitingOnSemaphoreDirectly)
			class
		equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: tag2 isNil.

	"make sure to create the compiledMethod"
	(ReflectivityExampleOnStack >> #exampleMethodWaitingOnSemaphoreDirectly)
		compileAndInstallCompiledMethod.

	process suspendedContext method:
		ReflectivityExampleOnStack >> #exampleMethodWaitingOnSemaphoreDirectly.
		
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
		(ReflectivityExampleOnStack >> #exampleMethodWaitingOnSemaphoreDirectly)
			class
		equals: ReflectiveMethod.
	self assert: tag isNil.
	self assert: tag2 isNil.
	
	"make sure to create the compiledMethod"
	(ReflectivityExampleOnStack >> #exampleMethodWaitingOnSemaphoreDirectly)
		compileAndInstallCompiledMethod.

	process suspendedContext method:
		ReflectivityExampleOnStack >> #exampleMethodWaitingOnSemaphoreDirectly.

	"here check that the method is on the stack"

	self
		assert: process suspendedContext method selector
		equals: #exampleMethodWaitingOnSemaphoreDirectly.
	"process should be running"
	self deny: process isTerminated.

	instance continue.
	0.1 seconds wait.
	self assert: process isTerminated.


	"Both metalinks got executed!!"
	self assert: tag notNil.
	self assert: tag2 notNil