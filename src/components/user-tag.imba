tag user-tag
	loggingOut?

	get avatar
		if S.user.discordAvatar
			"https://cdn.discordapp.com/avatars/{S.user.discordId}/{S.user.discordAvatar}.png"
		else if S.user.twitterAvatar
			"https://cdn.discordapp.com/avatars/{S.user.twitterId}/{S.user.twitterAvatar}.png"
		else ""
	
	get name
		S.user.discordUsername or S.user.twitterUsername or ""

	<self>
		<button[c:white pl:2 pr:2 py:.5 shadow:inner pos:relative] [pl:1]=avatar> 
			if loggingOut?
				<icon-tag.sping[c:cooler4] name="loader-03">
			else
				<img[w:6.5 h:6.5 my:-.5 rd:100px ml:-1] src="{avatar}" alt="user avatar"> if avatar
			
			<p[mx:2 fw:700]> if loggingOut? then "Logging out..." else name
			
			<icon-tag[c:sky4 mt:.5] name="chevron-down" size=16>
			
			<dropdown-tag[r:0 j:end x:8px y:12px]>
				<a.button.external[px:2 bg@hover:cooler8 j:start w:100% bg:transparent c:white fs:4] href="/logout" @click=(loggingOut? = yes)>
					<icon-tag[mr:2 c:cooler4] name="log-out-04-alt" size="16">
					"Log out"