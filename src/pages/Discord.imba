import { getAddress } from "viem"

css 
	p .tag bg:cooler7 c:white
	input[type=number] appearance:none
	input::-webkit-outer-spin-button, input::-webkit-inner-spin-button -webkit-appearance:none margin: 0
	.select-icon pos:absolute t:2 l:2
	.wallet rd:100px w:8 h:8 mr:-2 d:flex a:center j:center shadow:sm of:hidden


export default tag Discord
	context
	clicked? = no
	discordUser
	discordId
	keyHolder?
	
	subscriptions = []
	checkingStatus?
	
	def checkStatus
		return unless S.user.twitterId
		
		checkingStatus? = yes
		
		try
			const res = await (await window.fetch "/discord-assign-role/{discordId}").json!

			keyHolder? = res and !res.error
		catch e E e
	
		checkingStatus? = no
		
		imba.commit!
	
	def mount
		discordId = context.route.params.id
		
		waitFor S, "user", do checkStatus! if S.user.twitterId
	
	<self.splash> if web?
		<div[d:vcc]>
			if S.user then <user-tag[mb:2]>

			if !S.user..discordId
				<div.card[bg:white p:6 w:240px d:flex fld:column]>
					<div[ta:center d:flex fld:column a:center flg:1]>
						<div[bg:indigo1 rd:full w:13 h:13 d:vcc]>
							<img[w:12] src="/images/discord.svg" alt="discord logo">

						<h2[lh:120% mt:4]> "Connect Discord"
								
						<p[mb:2 fw:600 c:cooler5 mt:2]> "Log in to get your server role and benefits"
					
					<a.button.external[py:2 mb:-3 mx:-3 mt:4 bg:sky7 c:white bg@hover:sky6] href="/login/discord?redirect=/discord/{discordId}" @click=(clicked? = yes)>
						if clicked?
							"Logging in..."
						else
							"Log in with Discord"
			else if !S.user..twitterId
				<div.card[bg:white p:6 w:240px d:flex fld:column]>
					<div[ta:center d:flex fld:column a:center flg:1]>
						<div[bg:cooler9 rd:full w:13 h:13 d:vcc ]>
							<img[w:8] src="/images/x.svg" alt="x logo">

						<h2[lh:120% mt:4]> "Got the Key?"
								
						<p[mb:2 fw:600 c:cooler5 mt:2]> "Log in with X to verify you hold the right Key on Friend Tech"
					
					<a.button.external[py:2 mb:-3 mx:-3 mt:4 bg:sky7 c:white bg@hover:sky6] href="/login/x?redirect=/discord/{discordId}" @click=(clicked? = yes)>
						if clicked?
							"Logging in..."
						else
							"Log in with X"
			else
				<div.card[bg:white p:6 w:240px d:flex fld:column]>
					<div[ta:center d:flex fld:column a:center flg:1]>
						<div[bg:indigo1 rd:full w:13 h:13 d:vcc]>
							<img[w:12] src="/images/discord.svg" alt="discord logo">
						
						<div[bg:cooler1 bxs:inner mt:4 p:2 fw:600 rd:100px d:flex ja:center pr:4] [bg:pink1]=(!keyHolder? and !checkingStatus?) [bg:green1]=(keyHolder? and !checkingStatus?)>
							if checkingStatus?
								<icon-tag[bg:cooler2 c:cooler4 rd:full mr:2 d:flex ja:center] name="loading-03" size=20 .spin>
								<p[c:cooler7]> "Checking status"
							else if keyHolder?
								<icon-tag[c:green5 mr:2] size=20 name="key-02">
								<p[c:green9]> "Key Holder"
							else
								<icon-tag[c:pink5 mr:2] size=20 name="lock-keyhole-circle">
								<p[c:pink9]> "Not a Key Holder"
								
						<p[mt:4 mb:2 fw:600 fs:sm c:cooler5]> 
							"You {if keyHolder? then "have received your role" else "are not eligible for roles"} on the server"
							if keyHolder?
								". You can close this page now."
				