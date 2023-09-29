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
	subject
	subjectKeyHolder
	keyHolder?

	getting? = no
	
	def getUser accessToken, tokenType, state
		try
			getting? = yes
			subject = state

			const [res0, res1] = await Promise.all [
				window.fetch "https://discord.com/api/users/@me",
					headers:
						authorization: "{tokenType} {accessToken}"
				store.get "keyHolder", {address: getAddress subject}
			]
			discordUser = await res0.json!
			subjectKeyHolder = res1

			if w3.addy then checkStatus!
			
			getting? = no
		catch e E e, accessToken, tokenType, state

	subscriptions = []
	checkingStatus?
	
	def checkStatus
		return unless discordUser
		
		checkingStatus? = yes
		
		try
			await store.update "keyHolder", {address: getAddress w3.addy}, {discordUserId: discordUser.id} if !w3.user..discordUserId
		catch e E e
		
		try
			const res = await (await window.fetch "/discord-assign-role",
				method: "POST"
				mode: "same-origin"
				headers: {"Content-Type": "application/json"}
				body: JSON.stringify {subject}).json!

			keyHolder? = res if res and !res.error
		catch e E e
	
		checkingStatus? = no
		
		imba.commit!
	
	def mount
		if !context.route.params.subject
			const fragment = new URLSearchParams window.location.hash.slice 1
			const [accessToken, tokenType, state] = [(fragment.get 'access_token'), (fragment.get 'token_type'), (fragment.get 'state')]
			getUser accessToken, tokenType, state if accessToken

	<self.splash> if web?
		<div[d:vcc]>
			<connect-tag$connect[mb:4] hide=yes @connected=checkStatus!>

			if discordUser
				if !w3.addy
					<div.card[bg:white p:6 w:240px h:380px d:flex fld:column]>
						<div[ta:center d:flex fld:column a:center flg:1]>
							<div[d:flex a:center]>
								<div[bg:sky1 p:3 rd:100px]>
									<icon-tag[c:sky6 w:6 h:6] name="activity">
							
							<h2[lh:120% mt:4]> "{discordUser.username}, connect your wallet to verify"
							
							<div[w:64px h:4px rd:13px my:24px bg:cooler2]>
							
							<p[mb:2 fw:600 fs:sm c:cooler5]> "Connect with"
							
							<div[d:flex]>
								<div.wallet[ml:-2 bg:orange1 zi:3]>
									<img src="/images/metamask.svg" alt="metamask logo">
								<div.wallet[bg:blue8 zi:2]>
									<img[w:5] src="/images/rainbow.svg" alt="rainbow logo">
								<div.wallet[bg:blue6 zi:1]>
									<img[w:8] src="/images/coinbase.svg" alt="coinbase logo">
								<div.wallet[bg:cooler9]> ""
									<img[w:6] src="/images/ledger.svg" alt="ledger logo">
						
						<button[py:2 mb:-3 mx:-3 bg:sky7 c:white bg@hover:sky8] @click=$connect.triggerModal!> "Connect"
				else
					<div.card[bg:white p:6 w:240px d:flex fld:column]>
						<div[ta:center d:flex fld:column a:center flg:1]>
							<div[bg:indigo1 rd:full w:13 h:13 d:vcc]>
								<img[w:12] src="/images/discord.svg" alt="discord logo">
							
							<div[bg:cooler1 bxs:inner mt:4 p:2 fw:600 rd:100px d:flex ja:center pr:4] [bg:pink1]=(!keyHolder? and !checkingStatus?) [bg:green1]=(keyHolder? and !checkingStatus?)>
								if checkingStatus?
									<icon-tag[bg:cooler2 c:cooler4 rd:full mr:2 d:flex ja:center] name="loading-03" stroke="3" size=20 .spin>
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
							
			else
				<div.card[bg:white p:6 w:240px d:flex fld:column]>
					<div[ta:center d:flex fld:column a:center flg:1]>
						<div[bg:indigo1 rd:full w:13 h:13 d:vcc]>
							if getting?
								<icon-tag.spin[c:indigo5] name="loading-03">
							else
								<img[w:12] src="/images/discord.svg" alt="discord logo">

						<h2[lh:120% mt:4]> "Connect Discord"
								
						<p[mb:2 fw:600 c:cooler5 mt:2]> "Log in to get your server roles and subscription benefits"
					
					<a.button[py:2 mb:-3 mx:-3 mt:4 bg:sky7 c:white bg@hover:sky6] href="https://discord.com/api/oauth2/authorize?client_id=1153405181296386202&redirect_uri=http%3A%2F%2F{window.location.hostname}{if dev? then '%3A3000' else ''}%2Fdiscord&response_type=token&scope=identify&state={context.route.params.subject}" @click=(clicked? = yes) .disabled=(getting? or clicked?)>
						if clicked? or getting?
							"Logging in..."
						else
							"Log in with Discord"