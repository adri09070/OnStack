*ReflectivityOnStack
method: aCompiledMethod

	| compiledCode |
	compiledCode := method ast == aCompiledMethod ast
		                ifTrue: [ aCompiledMethod ]
		                ifFalse: [
			                aCompiledMethod allBlocks detect: [ :compiledBlock |
				                compiledBlock ast == method ast ] ].

	1 to: self stackPtr do: [ :index |
		| obj |
		obj := self at: index.
		obj isClosure ifTrue: [
			obj compiledBlock:
				(aCompiledMethod allBlocks detect: [ :compiledBlock |
					 compiledBlock ast == obj compiledBlock ast ]) ] ].

	pc := self computePCForNewMethod: compiledCode.
	method := compiledCode.
	closureOrNil ifNotNil: [
		self assert: compiledCode isCompiledBlock.
		closureOrNil compiledBlock: compiledCode ]