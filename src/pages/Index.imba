export default tag Index
	loaded? = no

	def loadSpline
		const { Application } = await import "@splinetool/runtime"
		const spline = new Application $canvas

		await spline.load "https://prod.spline.design/OEasEvP9NF4asD6o/scene.splinecode"

		loaded? = yes

		imba.commit!

	users = []
	thirdOfUsers

	def loadUsers
		users = await S.query "user", {}, null
			discordAvatar: yes
			discordId: yes
			twitterAvatar: yes

		thirdOfUsers = Math.floor(users.length / 3)

	def mount
		loadSpline!
		loadUsers!

	<self[w:100% d:vcc pt:12 px@lt-xs:4]> if web?
		<div[d:vcc max-width:940px w:100% py:12 pt@lt-xs:10 pb@lt-xs:0 pos:relative zi:2]>
			<div[d:vcc mt:-40 zi:1 maw:100% h:120 of:hidden]>
				if loaded?
					<canvas$canvas[y:-120px scale@lt-md:0.8 scale@lt-xs:0.5] ease>

			<h1[c:white mt:-10 @lt-xs:-40 zi:1 pos:relative ta:center fs:72px max-width:800px max-width@lt-md:500px fs@lt-md:4xl fs@lt-xs:3xl fw:800 ls:-0.05em ls@lt-xs:-0.025em lh:100% lh@lt-md:100% lh@lt-sm:100%]> "Move your Friend Tech chat to Discord. In 2 mins"

			<p[ta:center c:sky1 fs:2xl fs@lt-md:xl fw:600 mt:8 mt@lt-xs:4 max-width:520px max-width@lt-md:400px mt@lt-md:4]> "Frenpass is a Discord bot that grants a Key Holder role to verified members. Just add the bot, and share a verification link."

			<a.button.external[mt:8 mt@lt-xs:4 py:4 @lt-sm:2 x:12 pl:8 pr:4 @lt-sm:2 fw:600 fs:3xl fs@lt-xs:xl d:hcc c:cooler9 bg:sky9 c:white shadow:xl bg@hover:sky8] href="/login/discord?redirect=/setup"> "Connect Discord"
				<div[bg:sky7 w:12 h:12 w@lt-xs:8 h@lt-xs:8 ml:6 d:flex ai:center jc:center border-radius:full]>
					<icon-tag[c:sky4] name="zap">

			<p[c:sky2 fw:600 mt:4]> "Completely free. No keys needed."

		<div[d:vcc mt@lt-sm:8]>
			<div[d:vcc pos:relative zi:2]>
				<h2[c:white fs:2xl fw:800 mb:4]> "Join {users.length} Frenpass enjoyers"

				<div[w:100vw d:vcc pos:relative of:hidden]>
					<div[w:120px h:100% pos:absolute l:0 bg:linear-gradient(90deg, hsla(198.63,88.66%,48.43%,100%) 20%, hsla(198.63,88.66%,48.43%,0%) 100%) zi:4]>
					<div[w:120px h:100% pos:absolute r:0 bg:linear-gradient(90deg, hsla(198.63,88.66%,48.43%,0%) 0%, hsla(198.63,88.66%,48.43%,100%) 80%) zi:4]>
					
					<div.marquee.marquee-right[d:hcc]>
						<div.marquee-inner[d:hcc]>
							for user in users.slice 0, thirdOfUsers
								<avatar-tag.marquee-content[m:1] img="{if user.discordAvatar then "{S.avatarLink}/{user.discordId}/{user.discordAvatar}" else ""}" id=user.discordId size=8>
						<div.marquee-inner[d:hcc]>
							for user in users.slice 0, thirdOfUsers
								<avatar-tag.marquee-content[m:1] img="{if user.discordAvatar then "{S.avatarLink}/{user.discordId}/{user.discordAvatar}" else ""}" id=user.discordId size=8>
						<div.marquee-inner[d:hcc @lt-sm:none]>
							for user in users.slice 0, thirdOfUsers
								<avatar-tag.marquee-content[m:1] img="{if user.discordAvatar then "{S.avatarLink}/{user.discordId}/{user.discordAvatar}" else ""}" id=user.discordId size=8>
						<div.marquee-inner[d:hcc @lt-sm:none]>
							for user in users.slice 0, thirdOfUsers
								<avatar-tag.marquee-content[m:1] img="{if user.discordAvatar then "{S.avatarLink}/{user.discordId}/{user.discordAvatar}" else ""}" id=user.discordId size=8>
					
					<div.marquee.marquee-left[d:hcc ml:7 mt:-1]>
						<div.marquee-inner[d:hcc]>
							for user in users.slice thirdOfUsers, 2 * thirdOfUsers
								<avatar-tag.marquee-content[m:1] img="{if user.discordAvatar then "{S.avatarLink}/{user.discordId}/{user.discordAvatar}" else ""}" id=user.discordId size=8>
						<div.marquee-inner[d:hcc]>
							for user in users.slice thirdOfUsers, 2 * thirdOfUsers
								<avatar-tag.marquee-content[m:1] img="{if user.discordAvatar then "{S.avatarLink}/{user.discordId}/{user.discordAvatar}" else ""}" id=user.discordId size=8>
						<div.marquee-inner[d:hcc @lt-sm:none]>
							for user in users.slice thirdOfUsers, 2 * thirdOfUsers
								<avatar-tag.marquee-content[m:1] img="{if user.discordAvatar then "{S.avatarLink}/{user.discordId}/{user.discordAvatar}" else ""}" id=user.discordId size=8>
						<div.marquee-inner[d:hcc @lt-sm:none]>
							for user in users.slice thirdOfUsers, 2 * thirdOfUsers
								<avatar-tag.marquee-content[m:1] img="{if user.discordAvatar then "{S.avatarLink}/{user.discordId}/{user.discordAvatar}" else ""}" id=user.discordId size=8>

					<div.marquee.marquee-right[d:hcc mt:-1]>
						<div.marquee-inner[d:hcc]>
							for user in users.slice 2 * thirdOfUsers
								<avatar-tag.marquee-content[m:1] img="{if user.discordAvatar then "{S.avatarLink}/{user.discordId}/{user.discordAvatar}" else ""}" id=user.discordId size=8>
						<div.marquee-inner[d:hcc]>
							for user in users.slice 2 * thirdOfUsers
								<avatar-tag.marquee-content[m:1] img="{if user.discordAvatar then "{S.avatarLink}/{user.discordId}/{user.discordAvatar}" else ""}" id=user.discordId size=8>
						<div.marquee-inner[d:hcc @lt-sm:none]>
							for user in users.slice 2 * thirdOfUsers
								<avatar-tag.marquee-content[m:1] img="{if user.discordAvatar then "{S.avatarLink}/{user.discordId}/{user.discordAvatar}" else ""}" id=user.discordId size=8>
						<div.marquee-inner[d:hcc @lt-sm:none]>
							for user in users.slice 2 * thirdOfUsers
								<avatar-tag.marquee-content[m:1] img="{if user.discordAvatar then "{S.avatarLink}/{user.discordId}/{user.discordAvatar}" else ""}" id=user.discordId size=8>

		<h2[c:white mt:20 fs:4xl fw:800]> "How does it work?"
		
		<div[d:vcc pos:relative py:16]>
			<div[pos:absolute zi:-1 h:100% d:vcc t:0]>
				<div[rd:full bd:sky3 bw:4px w:4 h:4]>
				<div[w:1 flg:1 bg:sky3]>
				<div[rd:full bd:sky3 bw:4px w:4 h:4]>

			
			<div[mt:4 rd:full p:2 d:hcc bg:sky3 pos:relative zi:1 bxs:lg rotate:-5deg]>
				<div[w:10 h:10 pos:absolute t:0 mt:-6 l:50% bxs:md ml:-5 rd:full bg:white]>
					<img[w:100%] src="/images/discord.svg">

				<avatar-tag img="/images/frenpass.png" size=8>
				
				<icon-tag[mx:2 c:sky6] name="dots-horizontal" size=20>
				
				<avatar-tag img="/images/blokku.png" size=8>
			
			<div[bg:sky9 c:sky2 rotate:5deg px:2 rd:full d:hcc]> 
				<span.circle[bg:sky6 c:white w:4.5 h:4.5 ml:-1 mr:1]> "1"
				<p> "Log in with discord"
			
			<div[mt:12 rd:4 p:2 bg:sky3 pos:relative zi:1 bxs:lg rotate:3deg]>
				<p[tt:uppercase fw:800 c:sky6 fs:xxs mb:3]> "Your server"
				<div[d:hcl]>
					<icon-tag[mr:2 c:white] name="arrow-right" size=20>
					<avatar-tag[mr:2] img="/images/frenpass.png" size=6>
					<p[pr:2 c:sky7]>
						<b[fw:700 c:sky9]> "frenpass"
						" just showed up!"
			
			<div[bg:sky9 c:sky2 rotate:-3deg px:2 rd:full mt:1 d:hcc]>
				<span.circle[bg:sky6 c:white w:4.5 h:4.5 ml:-1 mr:1]> "2"
				<p> "Add Frenpass to your server"
			
			<div[mt:12 rd:4 p:2 bg:sky3 pos:relative zi:1 bxs:lg rotate:-5deg]>
				<p[tt:uppercase fw:800 c:sky6 fs:xxs mb:3]> "Key Addresses"
				
				<div[d:hcl]>
					<icon-tag[mr:2 c:white] name="key-01" size=20>
					<p[pr:2 c:sky7 fw:700]> "0x12Ab...34Cd"
				
				<div[d:hcl]>
					<icon-tag[mr:2 c:white] name="key-01" size=20>
					<p[pr:2 c:sky7 fw:700]> "0x56Ef...78Gh"
			
			<div[bg:sky9 c:sky2 rotate:3deg px:2 rd:full mt:1 d:hcc]> 
				<span.circle[bg:sky6 c:white w:4.5 h:4.5 ml:-1 mr:1]> "3"
				<p> "Choose the keys members need to hold"
			
			<div[mt:12 rd:4 p:2 bg:sky3 pos:relative zi:1 bxs:lg rotate:3deg]>
				<p[tt:uppercase fw:800 c:sky6 fs:xxs mb:3]> "Your server"
				
				<div[d:htl]>
					<avatar-tag[mr:2] img="/images/blokku.png" size=6>

					<div[pr:2]>
						<p[c:sky7]> "Hey guys, go here to verify"
						<div[d:hcl]>
							<p[fw:700 c:sky9]> "frenpass.app/verify"
			
			<div[bg:sky9 c:sky2 rotate:-3deg px:2 rd:full mt:1 d:hcc]> 
				<span.circle[bg:sky6 c:white w:4.5 h:4.5 ml:-1 mr:1]> "4"
				<p> "Share your verification link"
		
		<p[fs:3xl fw:700 ta:center lh:120% c:white maw:120 mt:8]> "That's it! Frenpass will verify members and assign a Key Holder role if they hold your keys"

		<a.button.external[mt:8 mt@lt-xs:4 py:4 @lt-sm:2 x:12 pl:8 pr:4 @lt-sm:2 fw:600 fs:3xl fs@lt-xs:xl d:hcc c:cooler9 bg:sky9 c:white shadow:xl bg@hover:sky8] href="/login/discord?redirect=/setup"> "Get Started"
			<div[bg:sky7 w:12 h:12 w@lt-xs:8 h@lt-xs:8 ml:6 d:flex ai:center jc:center border-radius:full]>
				<icon-tag[c:sky4] name="zap">
		
		<p[c:sky2 fw:600 mt:4]> "Completely free. No keys needed."

		<div[d:hcc fw:700 mt:20 w:100%]>
			<a[c:white] href="https://twitter.com/blokku_chan"> "Twitter"
			<a[c:white mx:4] route-to="/docs"> "Docs"
			<a[c:white] href="https://github.com/blokku-chan/frenpass-app"> "Github"
			
		<p[mt:4 c:sky2]> "Copyright © Frenpass, 2023"