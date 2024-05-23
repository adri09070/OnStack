# On Stack Replacement

This repository contains an experimenal feature that would allow to dynamically replace a method in a context in a context stack, while we debug a program, to replace it by another method, without needing to restart the programm completely for the method change to apply.
For example, this would allow to replace a method called once or several times in the context stack by an instrumented version of this method (e.g: to add breakpoints for example), without needing to restartall the involved contexts.

## How does it work

The project defines extension methods on `Context`, `Process`  and `ProcessorScheduler` to:
- search for all contexts that call the method we need to replace on the stack
- ask a context to replace itself by another context with another method

### How To Search For Contexts

To search for all contexts that call the method we need to replace on the stack, it **collects all processes** and for each of this process, **it escalates the sender chain of their suspended context and compare the method of each context** with the method we want to replace on stack.

### How To Replace a Context On Stack

When a context to replace itself on the stack by a context with another compiled method, it basically create a new context with:

- the **same sender**,
- the **same receiver**,
- the **new compiled method**,
- the **same stack pointer**, the same stack with the **same values above the values of the arguments**,
- the **same program counter**

Then the sender of the called context of the old context is now set to the new context.

## Tests that have been done

To test the project, we use the method below that uses semaphores to suspend the program and simple additions and we try to replace it with an instrumented version of this method in the unit tests, with metalinks that sends a tag (a selector, initially `nil`) to the object.

```Smalltalk
ReflectivityExampleOnStack>>#exampleMethodWaitingOnSemaphore

	2 + 3.
	self wait.
	7 + 5.
```

Each time we do the same thing: we create an instance of our test class and we call our test  method by making a fork.
Then we wait 0.1s such that the process calling our method waits on the semaphore, and we instrument the method differently to have variants of this unit test.

Here we will list the cases that should be tested and for each if this test has been written and if it is green or not.

1. Test that the **method is on the context stack after starting it** and that the **process terminates after resuming the semaphore: DONE**
2. 
