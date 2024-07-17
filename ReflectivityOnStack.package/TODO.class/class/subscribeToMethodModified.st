system subscription
subscribeToMethodModified

	  <script>
	  self codeChangeAnnouncer weak
		  when: MethodModified
		  send: #handleMethodModified:
		  to: self