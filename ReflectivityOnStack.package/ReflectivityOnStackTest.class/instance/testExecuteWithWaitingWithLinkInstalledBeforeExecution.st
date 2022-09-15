tests
testExecuteWithWaitingWithLinkInstalledBeforeExecution
	| instance messageNode process |
	instance := ReflectivityExampleOnStack new.
	
	"If we install a link before we execute, we just see its effects. This test is just to make sure we have the stuff working
	like we expect"
	messageNode := (ReflectivityExampleOnStack >> #exampleMethodWaitingOnSemaphore) ast sendNodes first.
	link := MetaLink new
		metaObject: self;
		selector: #tagExec.
	messageNode link: link.
	self assert: messageNode hasMetalink.
	self assert: (ReflectivityExampleOnStack >> #exampleMethodWaitingOnSemaphore) class equals: ReflectiveMethod.
	self assert: tag isNil.
	
	process := [ instance exampleMethodWaitingOnSemaphore ] fork.

	"here check that the method is on the stack"	
	0.1 seconds wait.
	self assert: process suspendedContext sender method equals: ReflectivityExampleOnStack>>#exampleMethodWaitingOnSemaphore.
	"process should be running"
	self deny: process isTerminated.
	instance continue.
	0.1 seconds wait.
	self assert: process isTerminated.
	
	
	"here the tag should not be nil, the metalink should have been executed."
	self assert: tag notNil
