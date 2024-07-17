*ReflectivityOnStack
compileAST

	  | method |
	  compiledMethod saveBcToASTCacheWithAST: ast.
	  OCASTSemanticCleaner clean: ast.
	  ast compilationContext
		  semanticAnalyzerClass: RFSemanticAnalyzer;
		  astTranslatorClass: RFASTTranslator.
	  ast doSemanticAnalysis. "force semantic analysis"
	  method := ast generateMethod.
	  "#generateMethod sets the generated method as a property, put back the old"
	  ast compiledMethod: compiledMethod.
	  method sourcePointer: compiledMethod sourcePointer.
	  ^ method