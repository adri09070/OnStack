examples
exampleMethodWaitingOnSemaphoreInInlineBlock

	2 + 3.
	true ifTrue: [
		1 + 1.
		semaphore wait. 
		3 + 3 ].
	7 + 5