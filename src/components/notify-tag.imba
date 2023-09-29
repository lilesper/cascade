tag notify-tag
	type = "info"
	timer = 3s
	show? = no
	message = ""
	
	def trigger e
		message = e.detail.message
		type = e.detail.type or "info"

		if show?
			show? = no
			await new Promise do(resolve) setTimeout(&, 0.5s) do resolve!

		show? = yes


		setTimeout(&, timer) do 
			show? = no
			imba.commit!		
	
	<self[pos:fixed b:0 l:0 r:0 d:vcc pb:12 zi:10000]>
		<global @notify=trigger>

		if show?
			<div[d:hcc p:2 rd:4 pr:4 bg:cooler9 bxs:xl o:1 y:0px o@off:0 y@off:16px]  ease>
				
				if type is "info"
					<icon-tag[c:cooler5 mr:2] name="info-square">
				else if type is "error"
					<icon-tag[c:pink5 mr:2] name="alert-square">
				
				<p[c:white]> message