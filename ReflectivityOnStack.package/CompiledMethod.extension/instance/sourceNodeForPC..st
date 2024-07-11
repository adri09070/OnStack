*ReflectivityOnStack
sourceNodeForPC: aPC

	| sourceNode |
	sourceNode := self sourceNode.

	self propertyAt: #bcToASTCache ifPresent: [ :bcToASTCache |
		^ sourceNode sourceNodeForPC: aPC usingBcToASTCache: bcToASTCache ].
	^ sourceNode sourceNodeForPC: aPC