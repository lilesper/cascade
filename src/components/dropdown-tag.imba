css .card button ta:left j:start

tag dropdown-tag
	show? = no
	onlySelf = no

	timer = null

	def mount
		#parent.addEventListener "click" do
			let goodToGo = if onlySelf then no else yes
			if onlySelf
				goodToGo = $1.target is parent
			show? = !show? if goodToGo
			imba.commit!

		#parent.addEventListener "mouseenter" do
			show? = yes
			clearTimeout timer
			imba.commit!
		
		self.addEventListener "mouseenter" do clearTimeout timer

		#parent.addEventListener "mouseleave" do
			timer = setTimeout(&, 150) do 
				show? = no
				imba.commit!
	
	def unmount
		try
			#parent.removeEventListener "click"
			#parent.removeEventListener "mouseenter"
			#parent.removeEventListener "mouseleave"

	<self[d:flex zi:10]>
		if show?
			<div.card[pos:absolute y:4px t:100% bg:cooler9 fw:500 c:cooler0 p:3 rd:8 d:vflex a:flex-start y@off:-12px opacity@off:0 ease:.5s back-out] ease>
				<slot>