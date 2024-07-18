examples
exampleMethodWaitingOnSemaphoreWithBlockAfter

	| a |
	a := 2.
	semaphore wait.

	^ a + [
	  a := 2 + 3.
	  a := 4 + 2.
	  a := 7 + 5 ] value