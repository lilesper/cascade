import { isAddress } from "viem"

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

	editing?
	ftAddress
	settingFtAddress?

	def setFtAddress confirmed? = no
		settingFtAddress? = yes

		if isAddress ftAddress
			if !discordServer.ftAddress or confirmed?
				S.ftData = await S.getTwitterData ftAddress

				if S.ftData
					discordServer = try await S.update "discordServer", {id: discordServer.id}, {ftAddress: ftAddress}
					catch e E e

					emit "notify"
						message: "Friend Tech Key set!"
				else
					emit "notify"
						message: "Not a Friend Tech Account"
						type: "error"
			else 
				emit "mustConfirm",
					message: "If you have members holding this key already, changing it will remove their roles from your server"
					callback: "confirmSetFtAddress"
		else 
			emit "notify",
				message: "Not a valid address"
				type: "error"
	
		settingFtAddress? = no
		editing? = no

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
		<global @confirmSetFtAddress=(setFtAddress yes)>

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
			<form.card[bg:sky9 mt:-8 rdt:0 p:6 pt:12 pos:relative zi:2 d:vts] @submit.prevent=setFtAddress!>
				<h2[fs:md c:white]> "Gating settings"
				<p[mb:4 c:sky2 max-width:220px]> 
					"What key"
					" do members need to hold?"
				
				if discordServer.ftAddress and !editing?
					<h3[fs:md c:sky2]> "Selected Key Address"
					<p[c:white d:hcl fw:700]> 
						"{discordServer.ftAddress.slice 0, 6}...{discordServer.ftAddress.slice -4}"
						<icon-tag[ml:2 c:sky2 cursor:pointer] size=16 name="edit-02" @click=(editing? = yes)>
				
				if !discordServer.ftAddress or editing?
					<label[mx:-3 mb:-3]>
						<input[bg:cooler9/20 c:white c@placeholder:sky6 w:100%] placeholder="0x..." bind=ftAddress>
						<span.label[c:cooler2]> "Friend Tech Key Address"
						
						<button[w:7 h:7 shadow:md rd:100px bg:sky5 pos:absolute b:2 r:2 d:flex a:center j:center] [bg:sky9]=settingFtAddress?>
							if settingFtAddress?
								<icon-tag.spin[c:sky3] name="loading-03" size=18>
							else	
								<icon-tag[c:white] name="arrow-right" size=18>
			
		if discordServer and discordServer.ftAddress
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