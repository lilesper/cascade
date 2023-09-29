tag discord-tag
	prop adding?
	prop interval
	prop connected
	prop checking
	
	def checkConnection
		try window.fetch "/discord-on"
		catch e E e
		
		checking = yes
		
		interval = setInterval(&,1000) do
			if w3.user.discordServer
				try window.fetch "/discord-off"
				catch e E e
				
				clearInterval interval
				
				if adding?
					adding? = no
				
				imba.commit!
				
				checking = no
			else
				w3.user = try await store.get "keyHolder", {address: w3.addy}
				catch e
				
				imba.commit!
	
	prop removing
	def removeBot
		removing = yes
		try
			await Promise.all [
				store.update "keyHolder", {address: w3.addy}, {discordServer: ""}
				window.fetch "/discord-remove",
					method: "POST"
					mode: "same-origin"
					headers: {"Content-Type": "application/json"}
					body: JSON.stringify {guildId: w3.user.discordServer}
			]
		catch e E e

		removing = no
		checkConnection!
	
	def addBot
		adding? = yes
		checkConnection!
		window.open "https://discord.com/api/oauth2/authorize?client_id=1153405181296386202&permissions=268435456&scope=bot", "_blank"
	
	def unmount
		window.fetch "/discord-off"
		clearInterval interval if interval

	def copyLink
		await window.navigator.clipboard.writeText "{window.location.host}/discord/{w3.addy}"
		
		$copyLink.innerHTML = "Copied!"
		
		setTimeout(&,3000) do
			if $copyLink
				$copyLink.innerHTML = "Copy Link" 

	def mount
		checking = yes
		
		imba.commit!
		
		w3.user = try await store.get "keyHolder", {address: w3.addy}
		catch e E e
		
		checking = no
		
		imba.commit!

	<self>
		<div.card[bg:white p:6 d:vflex a:start pos:relative zi:2]>
			<div[d:flex a:start]>
				<div>
					<h2[fs:lg]> "Discord Setup"
					<p[c:cooler5 max-width:220px]> "Add the frenpass bot to your discord server"
			
			if !w3.user..discordServer
				<button[bg:sky7 c:white pl:1 pr:3 mt:4 ml:-1 mb:-1] [c:cooler7 bg:cooler1 bg@hover:cooler1]=checking @click=addBot!>
					if checking then <icon-tag[c:cooler4 mr:2] name="loading-03" .spin> else <icon-tag[c:sky5 mr:2] name="plus-circle">
					if checking then "Checking" else "Add to Discord"
			else
				<div[d:flex a:center mt:4 ml:-1 mb:-1 mr:-1 j:space-between min-width:100%]>
					<div[bg:sky1 c:sky9 pl:1 pr:3 rd:full d:flex a:center py:1 fw:600]>
						<icon-tag[c:sky4 mr:1] name="check-circle">
						"Connected"
				
					<button[bg:transparent shadow:none c:sky9 bg@hover:sky1] .disabled=removing @click=removeBot!> if removing then "Removing" else "Remove"
		
		if w3.user..discordServer
			<div.card[bg:cooler9 mt:-8 rdt:0 p:6 pt:12 pos:relative zi:1]>
				<h2[fs:md c:cooler2]> "Setup instructions"
				<p[mb:4 c:cooler4 max-width:220px]> 
					"The "
					<span.tag[fs:sm bg:cooler7 c:white fw:700]> 
						<span[fs:xs]> "🔑"
						" Key Holder"
					" role will be automatically assigned to all members with keys."
				
				<p[mb:4 c:cooler4 max-width:220px]> "Next, choose what permissions key holders have in your server."

				<p[mb:4 c:cooler4 max-width:220px]> "Finally, just copy and paste the link below into the welcome channel in your server. Frenpass will do the rest!"
				
				<button[c:white bg:sky6 @hover:sky7 pr:4] @click=copyLink!> 
					<icon-tag[c:sky4 mr:2] name="copy-03">
					<span$copyLink> "Copy link"