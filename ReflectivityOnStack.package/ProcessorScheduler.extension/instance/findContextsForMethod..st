*ReflectivityOnStack
findContextsForMethod: aMethod
	 self flag: #TODO.
	"valueUnpreemptively shoudld not be done here, but every user should use it while doing whatever they want to do. maybe we should have withContextsForMethodDo: as an api that enforces this"
	
	^ [self allProcesses flatCollect: [ : process |
		process findContextsForMethod: aMethod.
		 ]] valueUnpreemptively 