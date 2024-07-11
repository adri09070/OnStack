*ReflectivityOnStack
saveBcToASTCacheWithAST: aMethodAST

	self propertyAt: #bcToASTCache put: aMethodAST bcToASTCache.
	self allBlocksDo: [ :compiledBlock |
		self
			propertyAt: compiledBlock asString
			put: compiledBlock ast bcToASTCache ]