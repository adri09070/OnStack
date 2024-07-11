*ReflectivityOnStack
generateMethod

	| method ir |
	self callPlugins.
	ast scope registerVariables.

	ast bcToASTCache: nil.
	ir := self generateIR.
	method := ir compiledMethod.

	ast compiledMethod: method.
	ast propertyAt: #Undeclareds ifPresent: [ :undeclareds |
		undeclareds do: [ :var | var registerMethod: method ] ].
	method propertyAt: #source put: source.
	self isScripting ifTrue: [ method propertyAt: #ast put: ast ]. "Keep AST for scripts (for the moment)"

	"If the prior method was not set explicitly, we set it because we will need it if we are not in the first compilation"
	self priorMethod ifNil: [
		self methodClass ifNotNil: [ :class | "In case the method comes from a trait, we ignore it because it means we are overriding the trait method in the class"
			class compiledMethodAt: method selector ifPresent: [ :aMethod |
				aMethod isFromTrait ifFalse: [ self priorMethod: aMethod ] ] ] ].

	"In case we are not compiling the method for the first time, we want to ensure that some properties are kept."
	self priorMethod ifNotNil: [
		priorMethod migratePersistingPropertiesIn: method ].
	method saveBcToASTCacheWithAST: ast.
	^ method