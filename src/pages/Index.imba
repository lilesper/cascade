export default tag Index
	loaded? = no

	def mount
		const { Application } = await import "@splinetool/runtime"
		const spline = new Application $canvas
		await spline.load "https://prod.spline.design/OEasEvP9NF4asD6o/scene.splinecode"
		loaded? = yes

	<self[w:100% max-width:940px px:6 px@lt-xs:4]>
		<div[d:vcc w:100% py:12 pt@lt-xs:10 pb@lt-xs:0 pos:relative zi:2]>
			<h1[c:white ta:center fs:80px max-width:800px max-width@lt-md:500px fs@lt-md:5xl fs@lt-xs:4xl fw:800 ls:-0.05em ls@lt-xs:-0.025em lh:100% lh@lt-md:100% lh@lt-sm:100%]> "Give your key holders access to your discord"

			<p[ta:center c:sky1 fs:2xl fs@lt-md:xl fw:600 mt:8 mt@lt-xs:4 max-width:520px max-width@lt-md:400px mt@lt-md:4]> "Build a better chat experience for your audience in 2 minutes—tops. For free."

			if !w3.addy
				<button[mt:8 mt@lt-xs:4 py:2 px:8 px@lt-xs:6 fw:600 fs:2xl fs@lt-xs:xl ta:center c:cooler9 bg:sky9 c:white shadow:xl bg@hover:sky8] @click=$connect.triggerModal!> "Connect Wallet"
					<div[bg:sky7 w:10 h:10 w@lt-xs:8 h@lt-xs:8 ml:4 mr:-6 mr@lt-xs:-4 d:flex ai:center jc:center border-radius:full]>
						<icon-tag[c:sky4] name="zap">
			
			<div[d:vcc mt:10]>

				<connect-tag$connect[mb:4] hide=yes>
				
				if w3.addy
					<discord-tag>

		<div[pos:fixed w:100vw h:100vh top:0 left:0 d:vbc]>
			if loaded?
				<canvas$canvas[scale-x@lt-xs:1.5 scale-y@lt-xs:1.5 ml@lt-xs:20 mt@lt-xs:10 o@off:0 ea:1s] ease>