examples
exampleMethodWaitingOnSemaphoreInMethodWithOuterBlockStoreInVariableBefore

	| a block |
	a := 2.
	block := [
	         | b block2 |
	         a := 2 + 3.
	         block2 := [
	                   b := 2 + 3.
	                   b := 4 + 2.
	                   b := 7 + 5 ].
	         a := 4 + 2.
	         block2 value ].
	semaphore wait.
	^ a + block value