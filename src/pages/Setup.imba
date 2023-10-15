export default tag Setup
	loaded? = no
	clicked? = no

	<self[w:100% max-width:940px px:6 px@lt-xs:4]> if web?
		<div[d:vcc mt:10]>
			if S.user
				<discord-setup>
			else
				<div.card[bg:white p:6 w:240px d:flex fld:column]>
					<div[ta:center d:flex fld:column a:center flg:1]>
						<div[bg:indigo1 rd:full w:13 h:13 d:vcc]>
							<img[w:12] src="/images/discord.svg" alt="discord logo">

						<h2[lh:120% mt:4]> "Connect Discord"
								
						<p[mb:2 fw:600 c:cooler5 mt:2]> "Log in to get your server role and benefits"
					
					<a.button.external[py:2 mb:-3 mx:-3 mt:4 bg:sky7 c:white bg@hover:sky6] href="/login/discord?redirect=/setup" @click=(clicked? = yes)>
						if clicked?
							"Logging in..."
						else
							"Log in with Discord"