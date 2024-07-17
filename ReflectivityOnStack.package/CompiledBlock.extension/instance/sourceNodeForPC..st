*ReflectivityOnStack
sourceNodeForPC: aPC

	  | blockNode |
	  blockNode := self outerCode sourceNodeForPC: self pcInOuter.
	  "Bug in the cache? The mapping is returning Return node instead of Block"
	  blockNode isReturn ifTrue: [ blockNode := blockNode value ].
	  self method
		  propertyAt: self printString asSymbol
		  ifPresent: [ :bcToASTCache |
			  blockNode sourceNodeForPC: aPC usingBcToASTCache: bcToASTCache ].
	  ^ blockNode sourceNodeForPC: aPC