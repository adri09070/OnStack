*ReflectivityOnStack-Debugger
breakOnStack

	self debuggerActionModel
		breakOnStackAtSelection: self code selectionInterval
		inContext: self currentContext