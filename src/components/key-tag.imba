import { isAddress } from "viem"

tag key-tag
	last = no
	discordServer
	awaitingConfirmation

	ftAddress = ""
	newFtAddress = ""
	
	editing?
	settingFtAddress?

	def setFtAddress confirmed? = no
		return if confirmed? and !awaitingConfirmation
		settingFtAddress? = yes

		if !isAddress newFtAddress
			settingFtAddress? = no
			return emit "notify",
				message: "Not a valid address"
				type: "error"
		
		if discordServer.ftAddresses.includes newFtAddress
			settingFtAddress? = no
			return emit "notify"
				message: "This Key Address is already added"
				type: "error"

		S.ftData = await S.getTwitterData newFtAddress
		if !S.ftData
			settingFtAddress? = no
			return emit "notify"
				message: "Not a Friend Tech Account"
				type: "error"

		if !confirmed? and editing? and !last
			awaitingConfirmation = yes
			return emit "mustConfirm",
				message: "If you have members holding this key already, changing it will remove their roles from your server"
				callback: "confirmSetFtAddress"
		else
			awaitingConfirmation = no
			
			let ftAddresses = [...discordServer.ftAddresses]

			if editing? and !last
				ftAddresses = ftAddresses.map do if $1 isnt ftAddress then $1 else newFtAddress
			else
				ftAddresses.push newFtAddress

			const server = try await S.update "discordServer", {id: discordServer.id}, {ftAddresses}
			catch e 
				settingFtAddress? = no
				
				E e
				
				return emit "notify", 
					message: "Unable to remove Key Address, check connection"
					type: "error"

			emit "editedKey", {server}

			settingFtAddress? = no
			newFtAddress = ""
			editing? = no

	removing?
	def removeFtAddress confirmed? = no
		return if confirmed? and !awaitingConfirmation

		if confirmed?
			awaitingConfirmation = no
			removing? = yes
			
			let ftAddresses = [...discordServer.ftAddresses].filter do $1 isnt ftAddress
			
			const server = try await S.update "discordServer", {id: discordServer.id}, {ftAddresses}
			catch e
				removing? = no
				
				E e

				return emit "notify", 
					message: "Unable to remove Key Address, check connection"
					type: "error"

			
			removing? = no

			emit "editedKey", {server}
		else
			awaitingConfirmation = yes
			emit "mustConfirm"
				message: "If you have members holding this key already, deleting it will remove their roles from your server"
				callback: "confirmRemoveFtAddress"
	
	def reset
		editing? = no
		newFtAddress = ""

	<self>
		<global @click.outside=(reset! if editing? and !awaitingConfirmation) @confirmSetFtAddress=(setFtAddress yes) @confirmRemoveFtAddress=(removeFtAddress yes)>

		if last and !editing?
			<p[c:white d:hcl fw:700 mt:4 cursor:pointer] @click=(editing? = yes)> 
				<icon-tag[mr:1 c:sky2 cursor:pointer] size=16 name="plus-circle">
				"Add a Key Address"
				
		else if ftAddress and !editing?
			<p[c:white d:hcl fw:700 my:2]>
				<span[flg:1 d:hcl w:75%]>
					<span[ws:nowrap of:hidden tof:ellipsis]> ftAddress
					"{ftAddress.slice -4}"
				if removing?
					<icon-tag.spin[ml:2 c:sky2 cursor:pointer] size=16 name="loading-03">
				else	
					<icon-tag[ml:2 c:sky2 cursor:pointer] size=16 name="edit-02" @click=(editing? = yes)>
					<icon-tag[ml:2 c:sky2 cursor:pointer] size=16 name="delete" @click=removeFtAddress!>
		else	
			<form @submit.prevent=setFtAddress!>
				<label[mx:-3 mb:-3]>
					<input[bg:cooler9/20 c:white c@placeholder:sky6 w:100%] placeholder="{ftAddress or '0x...'}" bind=newFtAddress autofocus>
					<span.label[c:cooler2]> "Friend Tech Key Address"
					
					<button[w:7 h:7 shadow:md rd:100px bg:sky5 pos:absolute b:2 r:2 d:flex a:center j:center] [bg:sky9]=settingFtAddress?>
						if settingFtAddress?
							<icon-tag.spin[c:sky3] name="loading-03" size=18>
						else	
							<icon-tag[c:white] name="arrow-right" size=18>