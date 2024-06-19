*ReflectivityOnStack
computePCForNewMethod: aCompiledMethod

	^ aCompiledMethod initialPC + (self pc - self startpc)