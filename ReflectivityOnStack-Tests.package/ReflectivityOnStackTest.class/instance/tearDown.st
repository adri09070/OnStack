running
tearDown

	link ifNotNil: [ link uninstall ].
	link2 ifNotNil: [ link2 uninstall ].
	super tearDown