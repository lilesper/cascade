tag discord-button-tag
	fragment
	clicked? = no
	discordUser
	accessToken
	tokenType
	state
	redirectRoute = ""

	getting? = no
	
	def getUser
		try
			getting? = yes

			const res0 = await window.fetch "https://discord.com/api/users/@me",
				headers:
					authorization: "{tokenType} {accessToken}"
			
			discordUser = await res0.json!

			emit "got user"
			
			getting? = no
		catch e E e, accessToken, tokenType, state

	
	def logIn
		window.open "https://discord.com/api/oauth2/authorize?client_id=1153405181296386202&redirect_uri=http%3A%2F%2F{window.location.hostname}{if dev? then '%3A3000' else ''}%2F{redirectRoute}&response_type=token&scope=identify", "_blank"
	
	def mount
		fragment = new URLSearchParams window.location.hash.slice 1
		
		if fragment
			accessToken = fragment.get "access_token"
			tokenType = fragment.get "token_type"
			state = fragment.get "state"

			getUser accessToken, tokenType, state if accessToken

	<self> if web?
		<a.button[py:2 mb:-3 mx:-3 mt:4 px:3 bg:sky7 c:white bg@hover:sky6] @click=(clicked? = yes) @click=logIn! .disabled=(getting? or clicked?)>
			if clicked? or getting?
				"Logging in..."
			else
				"Log in with Discord"