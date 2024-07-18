*ReflectivityOnStack
saveBcToASTCacheWithAST: aMethodAST

	self propertyAt: #bcToASTCache put: aMethodAST bcToASTCache.
	self allBlocksDo: [ :compiledBlock |
		self
			propertyAt: compiledBlock printString
			put: compiledBlock ast bcToASTCache ]