# On Stack Replacement

This repository contains an experimenal feature that would allow to dynamically replace a method in a context in a context stack, while we debug a program, to replace it by another method, without needing to restart the programm completely for the method change to apply.
For example, this would allow to replace a method called once or several times in the context stack by an instrumented version of this method (e.g: to add breakpoints for example), without needing to restartall the involved contexts.

## How does it work

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

#### Problems

##### Different Start PCs for Compiled Methods and Their Reflective Versions

**When replacing a method by another one, even if it is a reflective version of the old one, the pc needs to be changed because the start pc of the compiled version and of the reflective version are NOT the same**

##### The New Method Content Is Different

1. **In the case of a reflective method, it can add and/or remove some code at several locations in the code. Even the instruction of the old method the execution stopped to could have been deleted. How to know the pc in the reflective method corresponding to that instruction, if it may or may not exist anymore in the reflective method?**
2. **In the case of a completely different method than the old method, does it make sense? If it makes sense, what should the execution do (which pc should be set for the new context of the new method?)**

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
2. Test that **installing a metalink after starting to execute the method has not effect: DONE**
3. Test that **installing a metalink before starting to execute the method is executed: DONE**
4. Test that the method `ProcessorScheduler>>#findContextsForMethod:` returns an ordered collection with a unique context that call the method `DelayBasicScheduler >> #runBackendLoopAtTimingPriority`: **DONE**
5. Test that **`ProcessorScheduler>>#findContextsForMethod:` can return several contexts from different processes: TODO**
6. Test that **`ProcessorScheduler>>#findContextsForMethod:` can return several contexts from the same process: TODO**
7. Test that when replacing a context calling the method, **when it is not the top context, by the same method, the sender of the callee becomes the new context: DONE**
8. Test that **when installing a metalink** on a method after starting to execute it **after the code location the execution stopped to** and **when replacing this compiled method by its reflective version, resuming the execution executes the metalink: TEST YELLOW**
	The test fails because of [the start pc problem](#different-start-pcs-for-compiled-methods-and-their-reflective-versions)
9. Test that when installing 

