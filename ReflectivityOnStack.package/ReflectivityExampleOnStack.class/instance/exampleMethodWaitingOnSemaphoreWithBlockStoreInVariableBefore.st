examples
exampleMethodWaitingOnSemaphoreWithBlockStoreInVariableBefore

	| a block |
	a := 2.
	block := [
	         a := 2 + 3.
	         a := 4 + 2.
	         a := 7 + 5 ].
	semaphore wait.
	^ a + block value