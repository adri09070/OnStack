*ReflectivityOnStack
currentBytecode: currentBytecode equalsToNewBytecode: newBytecode withCurrents: currentSymbolicBytecodes withNews: newSymbolicBytecodes

	| result |
	result := currentBytecode description = newBytecode description.
	^ result
		  ifTrue: [ true ]
		  ifFalse: [
			  ((currentBytecode description beginsWith: 'jump') and: [
				   newBytecode description beginsWith: 'jump' ])
				  ifFalse: [ false ]
				  ifTrue: [
					  | currentSplitDescription newSplitDescription |
					  currentSplitDescription := $: split:
						                             currentBytecode description.
					  newSplitDescription := $: split: newBytecode description.
					  (currentSplitDescription size = 2 and: [
						   newSplitDescription size = 2 and: [
							   (currentSplitDescription at: 1)
							   = (newSplitDescription at: 1) ] ])
						  ifFalse: [ false ]
						  ifTrue: [
							  | currentJumpPc newJumpPc currentJumpBytecode newJumpBytecode |
							  currentJumpPc := (currentSplitDescription at: 2) asInteger.
							  newJumpPc := (newSplitDescription at: 2) asInteger.
							  currentJumpBytecode := currentSymbolicBytecodes
								                         detect: [ :csb |
								                         csb offset = currentJumpPc ]
								                         ifNone: [ ^ false ].
							  newJumpBytecode := newSymbolicBytecodes
								                     detect: [ :nsb | nsb offset = newJumpPc ]
								                     ifNone: [ ^ false ].
							  self
								  currentBytecode: currentJumpBytecode
								  equalsToNewBytecode: newJumpBytecode
								  withCurrents: currentSymbolicBytecodes
								  withNews: newSymbolicBytecodes ] ] ]