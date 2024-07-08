examples
exampleMethodWaitingOnSemaphoreInEmbeddedBlock

	| a block |
	a := 2.
	block := [
	         | b block2 |
	         a := 2 + 3.
	         block2 := [
	                   b := 2 + 3.
	                   semaphore wait.
	                   b := 7 + 5 ].
	         a := 4 + 2.
	         block2 value ].
	^ a + block value