import "./key-tag.imba"

tag discord-setup
	checking?
	interval

	def checkConnection
		interval = setInterval(&,1000) do
			if discordServer
				clearInterval interval
				
				adding? = no
				
				imba.commit!
				
				checking? = no
			else
				discordServer = try (await S.query "discordServer", {creatorId: S.user.discordId})[0]
				catch e
	
	removing?

	def removeBot
		removing? = yes
		try
			await window.fetch "/discord-remove/{discordServer.id}"
			discordServer = null
		catch e E e

		removing? = no
	
	adding?

	def addBot
		adding? = yes
		checkConnection!
		window.open "https://discord.com/api/oauth2/authorize?client_id={import.meta.env.VITE_DISCORD_CLIENT}&permissions=268435584&scope=bot", "_blank"
	
	def copyLink
		await window.navigator.clipboard.writeText "{window.location.host}/discord/{discordServer.id}"
		
		$copyLink.innerHTML = "Copied!"
		
		setTimeout(&,3000) do
			if $copyLink
				$copyLink.innerHTML = "Copy Link"
	
	def updateServer e\Event
		discordServer = e.detail.server
		imba.commit!

	def unmount
		clearInterval interval if interval
		editing? = no

	def mount
		checking? = yes
		
		discordServer = try (await S.query "discordServer", 
			creatorId: S.user.discordId
			isConnected: yes
		)[0]
		catch e E e
		
		checking? = no

	<self>
		<global @editedKey=updateServer>
		<div.card[bg:white p:6 d:vflex a:start pos:relative zi:3]>
			if !discordServer
				<div>
					<h2[fs:lg]> "Discord Setup"
					<p[c:cooler5 max-width:220px]> "Add the frenpass bot to your discord server"
				
				<button[bg:sky7 c:white pl:1 pr:3 mt:4 ml:-1 mb:-1] [c:cooler7 bg:cooler1 bg@hover:cooler1]=checking? @click=addBot!>
					if checking? then <icon-tag[c:cooler4 mr:2] name="loading-03" .spin> else <icon-tag[c:sky4 mr:2] name="plus-circle">
					if checking? then "Checking..." else "Add to Discord"
			else
				<div>
					<h2[fs:lg]> "Bot Added"
					<p[c:cooler5 max-width:220px]> "The frenpass bot is in your discord server"
				
				<div[d:flex a:center mt:4 ml:-1 mb:-1 mr:-1 j:space-between min-width:100%]>
					<div[bg:sky1 c:sky9 pl:1 pr:3 rd:full d:flex a:center py:1 fw:600]>
						<icon-tag[c:sky4 mr:1] name="check-circle">
						"Connected"
				
					<button[bg:transparent shadow:none c:sky9 bg@hover:sky1] .disabled=removing? @click=removeBot!> if removing? then "Removing..." else "Remove"
		
		if discordServer
			<.card[bg:sky9 mt:-8 rdt:0 p:6 pt:12 pos:relative zi:2 d:vts] >
				<h2[fs:md c:white]> "Key Addresses"
				<p[mb:4 c:sky2 max-width:220px]> 
					"What keys do members need to hold?"
				
				if discordServer.ftAddress.empty?
					<key-tag discordServer=discordServer>
				else
					for ftAddress in discordServer.ftAddresses
						<key-tag ftAddress=ftAddress discordServer=discordServer>
					
					<key-tag last=yes discordServer=discordServer>

			
		if discordServer and discordServer.ftAddresses.length
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