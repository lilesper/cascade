tag confirm-modal
	show? = no
	message = ""
	callback = ""
	
	def trigger e
		message = e.detail.message
		callback = e.detail.callback or ""

		$confirm.open = yes

	<self[pos:fixed b:0 l:0 r:0 d:vcc pb:12 zi:10000]>
		<global @mustConfirm=trigger>

		<modal-tag$confirm>
			<.card[p:8 maw:320px d:vts]>
				<h2[c:pink9 fw:800]> "You sure about that?"
				<p[c:cooler6]> message

				<button[bg:pink6 c:white px:6 py:2 mt:8 mx:-4 mb:-4] @click=(emit callback) @click=($confirm.open = no)> "Confirm"