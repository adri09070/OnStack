# On Stack Replacement

This repository contains an experimenal feature that would allow to dynamically replace a method in a context in a context stack, while we debug a program, to replace it by another method, without needing to restart the programm completely for the method change to apply.
For example, this would allow to replace a method called once or several times in the context stack by an instrumented version of this method (e.g: to add breakpoints for example), without needing to restartall the involved contexts.

## How does it work

The project defines extension methods on `Context`, `Process`  and `ProcessorScheduler` to:
- search for all contexts that call the method we need to replace on the stack
- for each context, change the method that should be executed. This can be done via two ways:
	1. ask the context to by another context with another method
	2. directly change the compiled method in the context, without creating a new context

### How To Search For Contexts

To search for all contexts that call the method we need to replace on the stack, it **collects all processes** and for each of this process, **it escalates the sender chain of their suspended context and compare the method of each context** with the method we want to replace on stack.

### Ways to change the method of a context by another method

#### How To Replace a Context On Stack 

When a context to replace itself on the stack by a context with another compiled method, it basically create a new context with:

- the **same sender**,
- the **same receiver**,
- the **new compiled method**,
- the **same stack pointer**, the same stack with the **same values above the values of the arguments**,
- the **same program counter**

Then the sender of the called context of the old context is now set to the new context.

#### How to Change the Method Without Replacing Context

The current implementation just replaces the old method with the new one, without modifying anything else within the context.
This implementation exists because, at first glance, it appears there is no real reason to create a new context.

#### Problems

These problems appear in both implementations (when creating a new context and when replacing the method in the current context).

##### Different Start PCs for Compiled Methods and Their Reflective Versions

**When replacing a method by another one, even if it is a reflective version of the old one, the pc needs to be changed because the start pc of the compiled version and of the reflective version are NOT the same**

##### The New Method Content Is Different

1. **In the case of a reflective method, it can add and/or remove some code at several locations in the code. Even the instruction of the old method the execution stopped to could have been deleted. How to know the pc in the reflective method corresponding to that instruction, if it may or may not exist anymore in the reflective method?**
2. **In the case of a completely different method than the old method, does it make sense? If it makes sense, what should the execution do (which pc should be set for the new context of the new method?)**

###### Partial solution for reflective methods

The hypothetical pc for the new context if we suppose that the new method does not add bytecode before the instruction the program stopped to, is: `start_pc_of_new_method + difference_between_old_context_pc_and_old_start_pc`.
There can be a greater PC shift if the new method added some bytecodes before the instruction the program stopped to, or a lower PC shift if the new method removed some bytecodes before the instruction stopped to.

If we suppose that the new method only added bytecodes and did not remove any from the old method (`before`  and `after` metalinks do that):
We could try to detect in the new method all bytecodes prior to the bytecode the program stopped to in the old method, index by index.
If we find that the bytecode at the current index for the new method is not identical to the bytecode at the current index for the old method, then it means that the new method has added some bytecodes, and we can add to the shift the number of bytes of this new bytecode.

**How to compare bytecodes though?**
Of course, we cannot compare the pcs because they have changed. We cannot compare the bytes neither because they may have changed too (for a reason I don't know, the same bytecodes in do not have the same bytes in both methods).
We cannot use the AST equivalence because, by recompiling the reflective method, we have lost the AST of the old method.
We cannot use the intermediate representation because we have lost the IR of the old method by recompiling the reflective method too.
What does work is ... **comparing the description of the symbolic bytecodes of both methods** because we still have the symbolic bytecodes of the old method.
I do not think it is efficient to compare strings but this is the only solution that I could find and that works.

If we suppose that the new method only removed some bytecodes and did not add any to the old method:
We could still try to detect in the new method all bytecodes prior to the bytecode the program stopped to in the old method, index by index.
But this time, if we find that the bytecode at the current index for the new method is not identical to the bytecode at the current index for the old method, then it means that the new method has removed some bytecodes, and we can subtract to the shift the number of bytes of the old bytecode.
If the bytecode the program stopped to in the old method has been removed in the new method, we can compute the shift so that the new pc is the pc of the bytecode that follows the last bytecode that has been executed from the old method.

**However, what if new bytecodes have been added AND old bytecodes have been removed in the new method? (`instead` metalinks do that)**
I have literally no idea.
We could still try to detect in the new method all bytecodes prior to the bytecode the program stopped to in the old method, index by index.
However, if we find that the bytecode at the current index for the new method is not identical to the bytecode at the current index for the old method, then how do we know if it is a bytecode added in the new method or if it is a bytecode removed from the old method?

##### On Stack Replacement of blocks

-> do we need to replace the compiledBlock of all Closures that are in the system somewhere?
-> Update the method (or outer block). The compiledBlock is in the literals
-> This could simplify the problem, as if we install a link in anothher closure, we do not have to change that CompiledBlock, nor the method.

**Solution:**
When replacing a method that creates and evaluates closures, these compiled blocks should be replaced too.
Searching in the stack for block contexts whose home is the replaced method is necessary but not sufficient, as some closures may be in the stack and the compiled block of these closures should be changed too.
So, the value stack of these contexts should be explored to replace the old compiled blocks by the new one.
This is possible to know which block should be replaced by which block, because the old blocks and the new blocks share the same AST (in the case of reflective methods!)
For block contexts, we compare the bytecodes of the old block to the bytecodes of the new block (not the bytecodes from their home method)

**Other problems, partially resolved:**
The old blocks and the new blocks share the same AST "in theory".
However, to recover the AST of the old blocks, it searches for the pc of th creation of the new block in the new outer code.
As pcs may have changed, the recovered AST may be incorrect.
To fix that, I changed the compilation of methods in `OpalCompiler>>#generateMethod` to save the bcToAST cache of its AST as a property of the method, as well as the bcToAST cache of all its compiled blocks.
Then I changed the method `sourceNodeForPC:` of `CompiledMethod` and `CompiledBlock` so that they use by default the AST in method properties to recover AST nodes, if this method property exist.

This works, in my image.
But this cannot be loaded in another image for reflection reasons:
- The method `OpalCompiler>>#generateMethod` does not find the method `CompiledMethod>>#saveBcToASTCacheWithAST:` as it has not been loaded yet
- Even if it would have been loaded, all the other methods would have been compiled already, without its bcToAST cache as method property.

I think that to solve these problems:
- these methods that modify methods of classes: `OpalCompiler`, `CompiledNode`, `RBMethodNode` and `RBBlockNode`, should be integrated directly in the packages of these classes (not as extension methods in the package of this repository)
- Also, before installing a reflective method, we could also save the bcToAST cache of all compiled methods with the same AST. An advantage of this solution is that it could be slow to systematically save the bcToAST cache of a new compiled method as method property, when this will be useful in only very specific cases (for methods that will get metalinkgs installed). However, a drawback of this would be that the bcToAST cache of such methods would be saved several times if several metalinks are installed on its AST.

##### On Stack Replacement of inlined blocks

When comparing the bytecodes of the old method to the bytecodes of the new method, when there are inlined blocks, there may be jump bytecodes (in `ifXXX:` and `whileXXX:` messages for instance).
However, in the description of the corresponding symbolic bytecode, it actually contains the pc to which the execution should jump.
As this pc changes between the old and the new method, we cannot use string equality to detect the equivalence of symbolic bytecodes between the old and the new method ([see this problem](#partial-solution-for-reflective-methods).

**Solution (ugly but it works):**
I parse the description of the bytecode, and if both bytecodes in the old and new method are jump bytecode (else I just compare the equality of their descriptions), I parse their descriptions to recover the pc these bytecodes jump to.
Then, I recover the corresponding bytecodes for these PCs, and compare them using the same technique

#### Potential Problems

##### Left Operand On Stack Instead Metalinks 

When installing an `#instead` metalink at the exact code location the execution stopped to, there is a risk that some operands on the stack stay uncleaned (e.g: the receiver of the message that has been replaced)

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
8. Test that **when installing a metalink** on a method after starting to execute it **after the code location the execution stopped to**, **when replacing the compiled method** of the context **that is not the interrupted context** by its reflective version **while creating a new context**, **resuming the execution executes the metalink: DONE**
	Problem encountered: [the start pc problem](#different-start-pcs-for-compiled-methods-and-their-reflective-versions)
9. Test that **when installing a metalink** on a method after starting to execute it **after the code location the execution stopped to**, **when replacing the compiled method** of the context **that is not the interrupted context** by its reflective version **without creating a new context**, **resuming the execution executes the metalink: DONE** 
    	Problem encountered: [the start pc problem](#different-start-pcs-for-compiled-methods-and-their-reflective-versions)
11. Test that **when installing a metalink** on a method after starting to execute it **after the code location the execution stopped to**, **when replacing the compiled method** of the context **that is the interrupted context** by its reflective version **without creating a new context**, **resuming the execution executes the metalink: DONE**
14. Test that **when installing a metalink `#instead`** on a method after starting to execute it **at the exact code location the execution stopped to**, **when replacing the compiled method** of the context **that is not the interrupted context** by its reflective version **without creating a new context**, **resuming the execution executes the metalink: TODO**
15. Test that **when installing a metalink `#instead`** on a method after starting to execute it **at the exact code location the execution stopped to**, **when replacing the compiled method** of the context **that is the interrupted context** by its reflective version **without creating a new context**, **resuming the execution executes the metalink: TODO**
18. Test that **when installing a metalink `#after`** on a method after starting to execute it **at the exact code location the execution stopped to**, **when replacing the compiled method** of the context **that is not the interrupted context** by its reflective version **without creating a new context**, **resuming the execution executes the metalink: DONE**
19. Test that **when installing a metalink `#after`** on a method after starting to execute it **at the exact code location the execution stopped to**, **when replacing the compiled method** of the context **that is the interrupted context** by its reflective version **without creating a new context**, **resuming the execution executes the metalink: DONE**
22. Test that **when installing a metalink `#before`** on a method after starting to execute it **at the exact code location the execution stopped to**, **when replacing the compiled method** of the context **that is not the interrupted context** by its reflective version **without creating a new context**, **resuming the execution does not execute the metalink: DONE**
23. Test that **when installing a metalink `#before`** on a method after starting to execute it **at the exact code location the execution stopped to**, **when replacing the compiled method** of the context **that is the interrupted context** by its reflective version **without creating a new context**, **resuming the execution does not execute the metalink: DONE**
26. Test that **when installing a metalink** on a method after starting to execute it **before the code location the execution stopped to**, **when replacing the compiled method** of the context **that is not the interrupted context** by its reflective version **without creating a new context**, **resuming the execution does not execute the metalink: DONE**
27. Test that **when installing a metalink** on a method after starting to execute it **before the code location the execution stopped to**, **when replacing the compiled method** of the context **that is the interrupted context** by its reflective version **without creating a new context**, **resuming the execution does not execute the metalink: DONE**
28. Test that **when installing two metalinks** on a method after starting to execute it **after the code location the execution stopped to**, **when replacing the compiled method** of the context by its reflective version, **resuming the execution execute both metalink: DONE**
29. Test that **when installing two metalinks** on a method after starting to execute it **just before and after the code location the execution stopped to**, **when replacing the compiled method** of the context by its reflective version, **resuming the execution execute only one of the two metalink: DONE**
30. Test: **when replacing a method of a context by a completely different method**, **what should be the specifications? Does it make sense? Should we forebid that?: TODO**
32. Test: **when installing an `#instead` metalink on a message send** after starting to execute it **at the exact code location the execution stopped to**, **when replacing the compiled method** by its reflective version, **resuming the execution execute the metalink with no extra stack operand left: TODO**
	[See potential problem here](left-operand-on-stack-instead-metalinks)
33. Test: **when installing a metalink that introduces temps** after starting to execute it **after the code location the execution stopped to**, **when replacing the compiled method** by its reflective version, **resuming the execution execute the metalink and the rest of the code correctly with no extra stack operand left: TODO**
34. Test: **when installing a metalink in a block** **after starting to execute it** **after the code location the execution stopped to**, **when replacing the compiled method in each corresponding block and method context** by its reflective version, **resuming the execution execute the metalink: DONE**
	[See potential problem here](#on-stack-replacement-of-blocks)
35. Test: **when installing a metalink in an embedded block** **after starting to execute it** **after the code location the execution stopped to**, **when replacing the compiled method in each corresponding block and method context** by its reflective version, **resuming the execution execute the metalink: DONE**
	[See potential problem here](#on-stack-replacement-of-blocks)
37. Test: **when installing a metalink in a block** **after starting to execute it** **after the code location the execution stopped to** **in the outer method**, **when replacing the compiled method in each corresponding block and method context** by its reflective version, **resuming the execution execute the metalink: DONE**
    	[See potential problem here](#on-stack-replacement-of-blocks)
38. Test: **when installing a metalink in an inlined block** **after starting to execute it** **after the code location the execution stopped to**, **when replacing the compiled method in each corresponding block and method context** by its reflective version, **resuming the execution execute the metalink: DONE**
    	[See potential problem here](#on-stack-replacement-of-inlined-blocks)
39. Test: **when installing a metalink in a block** **before starting to execute it** **after its creation**, **when replacing the compiled method in each corresponding block and method context** by its reflective version, **resuming the execution execute the metalink: DONE**
	[See potential problem here](#on-stack-replacement-of-blocks)
40. Test: **when installing a metalink in a block** **before starting to execute it** **before its creation**, **when replacing the compiled method in each corresponding block and method context** by its reflective version, **resuming the execution execute the metalink: DONE**
	[See potential problem here](#on-stack-replacement-of-blocks)
41. Test: **when installing a metalink in an embedded block** **before starting to execute it** **after its creation**, **when replacing the compiled method in each corresponding block and method context** by its reflective version, **resuming the execution execute the metalink: DONE**
	[See potential problem here](#on-stack-replacement-of-blocks)
