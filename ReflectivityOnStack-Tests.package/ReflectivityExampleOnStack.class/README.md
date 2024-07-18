Examples that wait on a semaphore

Two cases:

- we add the metalink before the pc that the waiting method is executing
- ae add it *after*.

The after case is simpler to implement as we do not need to change the PC of the method on the stack

PLAN:

solve second case first.