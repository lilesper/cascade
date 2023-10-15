def Introduction do (await import "./Introduction.imba").default
def Privacy do (await import "./Privacy.imba").default
def SetupTutorial do (await import "./SetupTutorial.imba").default
def VerificationTutorial do (await import "./VerificationTutorial.imba").default

css 
	.sidebar a c:sky2 px:4 py:1 ml:-4 r:0 rdl:full bg@hover:sky8
	.sidebar .active c:white bg:sky6
	.content d:vtl w:100%
	dropdown-tag a c:cooler4 @hover:cooler2 d:block ws:nowrap
	dropdown-tag .active c:white

export default tag Docs
	<self[maw:540px mt:16] route="/docs">
		<div>
			<div[d:none @!954:flex shadow:inner p:4 pr@lt-md:2 ai:center jc:end cursor:pointer bg:cooler9 right@lt-md:0 @hover:cooler8 rd:full rdr@lt-md:0 pos:fixed ml:-16 ml@lt-md:0 mt@lt-md:-4 zi:20]>
				<icon-tag[c:white] name="list" size=20>
				<dropdown-tag[x@lt-md:-164px y@lt-md:26px]>
					<div[p:4]>
						<a route-to="/docs/"> "Introduction"
						<a route-to="/docs/privacy"> "Privacy Policy"

						# <h3[fs:xs tt:uppercase ls:0.02em mt:4 c:cooler5]> "Help"
						# <a route-to="/docs/setup"> "Discord Setup"
						# <a route-to="/docs/verification"> "Verification"

			<div[d:block @!954:none pos:fixed bg:sky7 ml:-48 w:60 p:6 pr:0 rdl:32px]>
				<h4[c:white]> "Frenpass"
				
				<div.sidebar[mt:4 d:flex fld:column]>
					<a route-to="/docs/"> "Introduction"
					<a route-to="/docs/privacy"> "Privacy Policy"

					# <h3[fs:xs tt:uppercase ls:0.02em mt:4 c:sky4]> "Help"
					# <a route-to="/docs/setup"> "Discord Setup"
					# <a route-to="/docs/verification"> "Verification"
			
			<div.card[rd:32px p:6 pos:relative w:100%]>
				<route-tag.content page=Introduction route="/docs/">
				<route-tag.content page=Privacy route="/docs/privacy">

				# <route-tag.content page=VerificationTutorial route="/docs/verification">
				# <route-tag.content page=SetupTutorial route="/docs/setup">