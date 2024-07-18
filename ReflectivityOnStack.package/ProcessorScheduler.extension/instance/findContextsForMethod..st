*ReflectivityOnStack
findContextsForMethod: aMethod
	"Take care: users should call within #valueUnpreemptively"

	^ self allProcesses flatCollect: [ :process |
		  process findContextsForMethod: aMethod ]