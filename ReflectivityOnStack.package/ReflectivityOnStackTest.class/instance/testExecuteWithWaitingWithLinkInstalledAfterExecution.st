tests
testExecuteWithWaitingWithLinkInstalledAfterExecution
	| instance messageNode process |
	instance := ReflectivityExampleOnStack new.
	
	
	
	process := [ instance exampleMethodWaitingOnSemaphore  ] fork.
	0.1 seconds wait.
	"If we install a link after we execute, we expect it to not matter for this test, as the new code will not be executed"
	messageNode := (ReflectivityExampleOnStack >> #exampleMethodWaitingOnSemaphore) ast sendNodes third.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec.
	messageNode link: link.
	self assert: messageNode hasMetalink.
	self assert: (ReflectivityExampleOnStack >> #exampleMethodWaitingOnSemaphore) class equals: ReflectiveMethod.
	self assert: tag isNil.

	"here check that the method is on the stack"	
	
	self assert: process suspendedContext sender sender method selector equals: #exampleMethodWaitingOnSemaphore.
	"process should be running"
	self deny: process isTerminated.
	instance continue.
	0.1 seconds wait.
	self assert: process isTerminated.
	
	
	"here the tag should not be nil, the metalink should have been executed."
	self deny: tag notNil.
	
	"but if we execute again, it workd"

	process := [ instance exampleMethodWaitingOnSemaphore ] fork.
	instance continue.
	0.1 seconds wait.
	self assert: tag notNil.
