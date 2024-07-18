examples
exampleMethodWaitingOnSemaphoreInBlock

	| a block |
	a := 2.
	block := [
	         a := 2 + 3.
	         semaphore wait.
	         a := 7 + 5 ].
	^ a + block value