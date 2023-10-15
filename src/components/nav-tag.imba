css a.nav-link fw:600 c:white px:4 py:0 rd:full bg@hover:sky6/50

tag nav-tag
	<self>
		<nav[zi:1000 pos:fixed t:0 l:0 r:0 d:hcc p:6]>
			<div[bg:sky5/50 p:2 rd:full backdrop-filter:blur(16px) -webkit-backdrop-filter:blur(16px) bxs:xl d:hcs bdt:sky4/30]>
				<a[d:flex ai:center rd:100px pl:2 pr:2 py:0 mr:6 bg:white shadow:lg] route-to="/">
					<div[w:2 h:3 bg:sky5 rdt:full mr:1]>
					<div[td:none fw:700 c:cooler9]> "frenpass"
				
				<div[flg:1 d:hcc]>
					<a.nav-link[d@lt-xs:none] route-to="/docs"> "Docs"
					<a.nav-link[d@lt-xs:none] href="https://github.com/blokku-chan/frenpass-app"> "Github"
					if S.user
						<user-tag>
					else
						<a.nav-link.external[bg:sky6 py:0] href="/login/discord?redirect=/setup"> "Get Started"
					