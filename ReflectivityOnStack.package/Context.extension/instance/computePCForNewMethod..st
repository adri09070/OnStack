*ReflectivityOnStack
computePCForNewMethod: aCompiledMethod

	| offset currentSymbolicBytecodes newSymbolicBytecodes currentSymbolicBytecodeIndex newSymbolicBytecodeIndex currentBytecode newBytecode |
	"This method makes the assumption that the new method only adds bytecodes to the old one, and does not remove any bytecode of the old method"
	offset := self pc - self startpc.
	newSymbolicBytecodes := aCompiledMethod symbolicBytecodes.
	currentSymbolicBytecodes := self compiledCode symbolicBytecodes
		                            select: [ :bytecode |
		                            bytecode offset <= self pc ].
	currentSymbolicBytecodeIndex := 1.
	currentBytecode := currentSymbolicBytecodes at:
		                   currentSymbolicBytecodeIndex.
	newSymbolicBytecodeIndex := 1.
	newBytecode := newSymbolicBytecodes at: newSymbolicBytecodeIndex.
	[ "While all bytecodes from current method have not been found in new method:"
	currentSymbolicBytecodeIndex < currentSymbolicBytecodes size "=" ]
		whileTrue: [ "If the two bytecodes are the same, then no offset need to be added, else it means a bytecode has been added in the new method and the offset should be increased by the size of this bytecode:"
			currentBytecode := currentSymbolicBytecodes at:
				                   currentSymbolicBytecodeIndex.
			newBytecode := newSymbolicBytecodes at: newSymbolicBytecodeIndex.
			(self
				 currentBytecode: currentBytecode
				 equalsToNewBytecode: newBytecode
				 withCurrents: self compiledCode symbolicBytecodes
				 withNews: aCompiledMethod symbolicBytecodes)
				ifTrue: [
				currentSymbolicBytecodeIndex := currentSymbolicBytecodeIndex + 1 ]
				ifFalse: [ offset := offset + newBytecode bytes size ].
			newSymbolicBytecodeIndex := newSymbolicBytecodeIndex + 1 ].
	^ aCompiledMethod initialPC + offset