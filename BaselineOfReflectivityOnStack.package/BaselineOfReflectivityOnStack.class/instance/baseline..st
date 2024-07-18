baselines
baseline: spec

	  <baseline>
	  spec for: #common do: [
		  spec postLoadDoIt: #postload:package:.

		  spec package: 'ReflectivityOnStack-Core'.
		  spec
			  package: 'ReflectivityOnStack'
			  with: [ spec requires: #( 'ReflectivityOnStack-Core' ) ].
		  spec
			  package: 'ReflectivityOnStack-Tests'
			  with: [ spec requires: #( 'ReflectivityOnStack' ) ].
		  spec
			  package: 'ReflectivityOnStack-Debugger'
			  with: [ spec requires: #( 'ReflectivityOnStack' ) ] ].

	  spec
		  group: 'default'
		  with: #( 'ReflectivityOnStack-Core' 'ReflectivityOnStack'
			     'ReflectivityOnStack-Tests' 'ReflectivityOnStack-Debugger' )