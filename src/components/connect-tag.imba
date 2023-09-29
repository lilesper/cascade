import { getAddress } from "viem"

tag connect-tag
	hide = no
	hideAll = no
	name
	avatar
	verifying? = no
	savingSignature? = no
	checkingAccount? = no
	walletType = ""
	pendingAccount = ""
	savedAccount = ""
	auth? = no
	uri
	wcm
	wcmParent
	connectingB = no
	connectingW = no
	wcmProvider
	pendingUser = null

	def triggerModal do $connect.open = yes

	def connectWalletApp refresh = no
		connectingW = yes

		const { EthereumProvider } = await import "@walletconnect/ethereum-provider"
		
		imba.commit!

		document.querySelectorAll("wcm-modal").forEach do $1.remove! if $1
		
		if refresh
			try window.localStorage.removeItem "wc@2:client:0.3//session" catch e console.error e

		try
			wcmProvider = await EthereumProvider.init
				projectId: import.meta.env.VITE_WC_ID
				chains: [8453]
				rpcMap: {8453: import.meta.env.VITE_BASE_RPC}
				methods: ["eth_sendTransaction", "personal_sign", "eth_signTypedData_v4"]
				optionalMethods: ["wallet_switchEthereumChain", "wallet_addEthereumChain"]
				showQrModal: yes
				qrModalOptions:
					themeMode: "light"
					themeVariables:
						"--wcm-font-family": "Satoshi-Variable"
						"--wcm-z-index": "1000"
						"--wcm-accent-color": "#0ea2e7"
						"--wcm-accent-fill-color": "white"
						"--wcm-background-color": "transparent"
		catch e
			E e

		if auth?
			connectWallet wcmProvider, "app"
		else
			wcmProvider.on "display_uri" do(id)
				uri = id
				wcmParent = await store.waitForElm("wcm-modal", document)
				wcm = wcmParent.shadowRoot
				
				const container = wcm.querySelector(".wcm-container")
				
				container.style.border = "none"
				container.style.width = "294px"

				store.waitForElm("wcm-modal-backcard", container).then do(back)
					store.waitForElm(".wcm-toolbar", back.shadowRoot).then do
						$1.querySelector("svg").style.opacity = "0"
				
				loadQR!
				listenForClicks!

			try 
				await wcmProvider.enable!
				connectWallet wcmProvider, "app"
			catch e
				E e
				connectingW = no
			

	def connectWallet provider = window.ethereum, type = "browser"
		const { createWalletClient, custom } = (await import "viem")

		connectingB = yes unless connectingW
		
		w3.client = createWalletClient
			chain: store.chain
			transport: custom provider
		
		if w3.chainId isnt await w3.client.getChainId!
			await requestNetwork!

		if w3.chainId isnt await w3.client..getChainId!
			disconnect!
		else
			walletType = type
		
			checkForFtData!
	
	def setChain id
		w3.chainId = id
		w3.client.chain = store.chain
		
		window.localStorage.setItem "lastChain", id

	def requestNetwork id
		try
			await w3.client.switchChain { id: "0x2105" }
			setChain id if walletType is "app"
		catch e
			try
				await w3.client.addChain { chain: store.chain }
				setChain id if walletType is "app"
			catch e
				if e.details is "Failed to switch chain"
					emit "notify", {message: "Wallet doesn't support Base chain", type: "error"}
				else
					E e, id
				
				disconnect!

	def checkForFtData
		if auth?
			checkIfVerified!
		else
			checkingAccount? = yes
			imba.commit!

			try
				const address = (await w3.client.requestAddresses!)[0]
				const ftAddress = await store.getFtAddress address

				pendingUser =
					address: getAddress address
					ftAddress: getAddress ftAddress

				checkIfVerified!
			catch e
				E e
				disconnect!
	
	def setProfile
		name = w3.ftData.twitterName
		avatar = w3.ftData.twitterPfpUrl

		imba.commit!
	
	def checkIfVerified
		if !auth?
			pendingAccount = (await w3.client.requestAddresses!)[0]
			checkingAccount? = no
			verifying? = yes
			
			imba.commit!
		else
			w3.addy = (await w3.client.requestAddresses!)[0]
			
			disconnect! if w3.addy isnt savedAccount
			
			checkingAccount? = no
			imba.commit!
			finalize!

	def verify
		savingSignature? = yes
		
		try
			const res = await store.verify! pendingAccount
			
			if res
				w3.addy = pendingAccount
				
				finalize!
		catch e
			E e
			verifying? = no
		
		savingSignature? = no
		
		imba.commit!

			
	def finalize
		w3.addy = pendingAccount if !w3.addy and pendingAccount
		w3.client.account = w3.addy
		
		window.localStorage.setItem "wallet-type", walletType
		
		$connect.open = no
		
		imba.commit!
		
		emit "connected"

		startListening!
		
		unless w3.user
			w3.user = try await store.get "keyHolder", address: getAddress w3.addy
		unless w3.user
			w3.user = await store.create "keyHolder", pendingUser
		unless w3.ftData
			w3.ftData = await store.getTwitterData w3.user.ftAddress, w3.addy
			setProfile!
		
		H.identify w3.addy
		
		connectingB = no
		connectingW = no
		
		imba.commit!
		
	
	def styleGrid grid
		grid.style.gridTemplateColumns = "repeat(4, 60px)"
		# await store.waitForElm "wcm-wallet-button", grid
		grid.querySelectorAll("wcm-wallet-button").forEach do(w)
			const target = w.shadowRoot.querySelector("wcm-wallet-image")
			target.style.width = "54px"
			target.style.height = "54px"
		const allWallets = grid.querySelector("wcm-view-all-wallets-button")
		if allWallets
			const last = allWallets.shadowRoot
			last.querySelector("button").style.padding = "6px 2px"
			const icons = last.querySelector(".wcm-icons")
			icons.style.width = "54px"
			icons.style.height = "54px"
			icons.style.padding = "4px"

	def loadQR e
		const modal = await store.waitForElm "wcm-modal-router", wcm
		
		modal.style.boxShadow = "var(--box-shadow-xl,0 20px 25px -5px hsla(var(--bxs-xl-color,0,0%,0%), var(--bxs-xl-alpha,.1)), 0 10px 10px -5px hsla(var(--bxs-xl-color,0,0%,0%), calc(var(--bxs-xl-alpha,.1) * .4)))"
		
		const background = await store.waitForElm "#wcm-modal", wcmParent.shadowRoot
		
		background.style.backgroundColor = "hsla(199, 89%, 48%, .9)"
		background.style.backdropFilter = "blur(16px)"
		background.style.webkitBackdropFilter = "blur(16px)"
		
		const router = await store.waitForElm ".wcm-router", modal.shadowRoot

		store.waitForElm("wcm-qrcode-view", router).then do(view)
			replaceQr view.shadowRoot.querySelector "wcm-walletconnect-qr"

		store.waitForElm("wcm-connect-wallet-view", router).then do(view)
			store.waitForElm("wcm-desktop-wallet-selection", view.shadowRoot).then do(s) afterSelection s
			store.waitForElm("wcm-mobile-wallet-selection", view.shadowRoot).then do(s) afterSelection s, yes
		store.waitForElm("wcm-wallet-explorer-view", router).then do(explorer)
			const explorerGrid = if explorer then (await store.waitForElm "wcm-modal-content", explorer.shadowRoot).querySelector(".wcm-grid") else null
			styleGrid explorerGrid
	
	def afterSelection selection, mobile?
		const grid = await store.waitForElm (if mobile? then "div" else ".wcm-grid"), selection.shadowRoot
		styleGrid grid
		const mTitle = selection.shadowRoot.querySelector(".wcm-mobile-title")
		mTitle.style.marginBottom = "0px" if mTitle
		replaceQr selection.shadowRoot.querySelector "wcm-walletconnect-qr" unless mobile?
	
	def replaceQr wQr
		const QRCodeStyling = (await import "qr-code-styling").default

		const qr = wQr.shadowRoot
		const qrCode = new QRCodeStyling
			width: 294
			height: 294
			type: "svg"
			image: "/images/frenpass-door.svg"
			data: uri
			dotsOptions:
				color: "#0f1729"
				type: "rounded"
			imageOptions:
				margin: 4
			backgroundOptions:
				color: "#fff"
		let parent = await store.waitForElm ".wcm-qr-container", qr
		parent.style.marginBottom = "-20px"
		parent.style.cursor = "none"
		const old = (await store.waitForElm "wcm-qrcode", parent).shadowRoot.querySelector "div"
		const oldReplacementInstance = old.querySelector "#svg-container" if old
		oldReplacementInstance.remove! if oldReplacementInstance
		old.remove! if old
		const child = parent.appendChild <div#svg-container.wawu[w:280px h:280px mx:auto]>
		qrCode.append child

	def listenForClicks
		wcm.addEventListener "click" do(e) loadQR e
	
	listening? = no
	
	def startListening
		return if listening?

		if wcmProvider and wcmProvider.connected
			wcmProvider.on "accountsChanged" do
				disconnect! if w3.addy isnt $1[0]
				imba.commit!
			wcmProvider.on "disconnect" do
				disconnect!
				imba.commit!
		else
			window.ethereum.on "accountsChanged" do
				disconnect! if w3.addy isnt $1[0]
				imba.commit!
			window.ethereum.on "chainChanged" do
				if w3.chainId isnt Number $1
					disconnect!
				else
					setChain w3.chainId
				
				imba.commit!
			window.ethereum.on "disconnect" do
				disconnect! unless $1.code is 1013 # disconnecting from chain only (MetaMask)
				imba.commit!
	
	def disconnect retry = no
		listening? = no
		verifying? = no
		savingSignature? = no
		connectingB = no
		connectingW = no
		w3.client = null
		w3.addy = ""
		w3.chainId = 8453
		w3.sig = ""
		w3.user = null
		name = ""
		avatar = ""
		auth? = no
		checkingAccount? = no

		imba.commit!
		
		window.localStorage.removeItem "wallet-type"
		try window.localStorage.removeItem "wc@2:client:0.3//session" catch e console.error e
		
		emit "disconnect"

		await store.disconnect!
		
		connectWalletApp yes if retry

	
	def copyAddress
		await window.navigator.clipboard.writeText w3.addy
		
		$copy.innerHTML = "Copied!"
		$copy.style.color = "#49de80"
		
		setTimeout(&,3000) do
			if $copy
				$copy.innerHTML = "Copy Address" 
				$copy.style.color = "white"

	def initiate
		const type = window.localStorage.getItem "wallet-type"
		w3.chainId = (Number window.localStorage.getItem "lastChain") or 8453

		if type and auth?
			if type == "browser" then connectWallet! else connectWalletApp!
		else disconnect!
	
	def mount
		savedAccount = await store.me!
		auth? = yes if savedAccount
		
		initiate!

	<self>
		<global @triggerConnection=($connect.open = yes)>
		unless w3.addy
			<button[c:white px:4 py:.5 shadow:inner] @click=(if auth? then initiate! else $connect.open = yes)> "Connect" unless hide or hideAll
		else
			unless hideAll
				<div[d:flex a:center]>
					if w3.chainId
						<button[pos:relative rd:100px w:7 h:7 d:flex j:center a:center zi:3 shadow:inner mr:4]>
							if w3.chainId is 8453
								<img[w:5] src="/images/base.svg" alt="base logo">
							else
								<icon-tag[c:pink5] name="globe-01">
						
							<icon-tag[c:white shadow:md pos:absolute l:100% ml:-1.5 bg:sky4 rd:100px mt:.5] [bg:pink6]=(w3.chainId isnt 8453) name="chevron-down" size=14>
						
							<dropdown-tag[r:0 j:end x:100px y:12px]>
								<h2[fs:2 c:cooler3 mb:2]> "Switch Networks"

								<div[w:100% d:vts]>
									<button[p:1 bg@hover:cooler8 bg:transparent mx:-1 c:white fs:4 pr:3] @click=(requestNetwork 8453)>
										<img[rd:100px w:5 h:5 mr:2 bg:cooler6] src="/images/base.svg" alt="base logo">

										<span[flg:1 min-width:128px mr:2 ta:left]> "Base"
							
										if w3.chainId is 8453
											<div[w:2 h:2 rd:100px bg:green4]>
					
					<button[c:white pl:2 pr:2 py:.5 shadow:inner pos:relative] [pl:1]=avatar> 
						<img[w:6.5 h:6.5 my:-.5 rd:100px ml:-1] src="{avatar}" alt="user avatar"> if avatar
						
						<p[mx:2 fw:700]> if name then name else w3.addy.slice 0,6
						
						<icon-tag[c:sky4 mt:.5] name="chevron-down" size=14>
						
						<dropdown-tag[r:0 j:end x:8px y:12px]>
							<button[px:2 bg@hover:cooler8 j:start w:100% bg:transparent c:white fs:4] @click=copyAddress>
								<icon-tag[mr:2 c:cooler4] name="copy-03" size="16">
								<span$copy> "Copy Address"
							
							<button[px:2 bg@hover:cooler8 j:start w:100% bg:transparent c:white fs:4] @click=disconnect!>
								<icon-tag[mr:2 c:cooler4] name="log-out-04-alt" size="16">
								"Disconnect"

		<modal-tag$connect @closed=(disconnect!)>
			<div.card[p:6 w:320px]>
				if verifying?
					<div[ta:center d:vflex a:stretch]>
						<div[d:vflex a:center]>
							<div[bg:sky1 p:3 rd:100px]>
								<icon-tag[c:sky6 w:6 h:6] name="edit-02">
							<h2[lh:120% mt:4]> "Verify {pendingAccount.slice 0,6}...{pendingAccount.slice pendingAccount.length - 4}" if pendingAccount
							<p[mt:2 lh:150% c:cooler5]> "Please sign a message to verify that you are the owner of this wallet"
						
						<button[py:2 mt:4 mb:-3 mx:-3 bg:sky7 c:white bg@hover:sky8] disabled=savingSignature? [bg:cooler2 bg@hover:cooler2 c:cooler4]=savingSignature? @click=verify!>
							if savingSignature? then "Verifying" else "Sign Message"
						
						<button[c:sky7 bg:none mb:-3 mt:4 shadow:none] @click=(disconnect yes)> "Choose other wallet" if walletType is "app"
				else if checkingAccount?
					if w3.ftData is "not found"
						<div[ta:center d:vflex a:stretch]>
							<div[d:vflex a:center]>
								<div[bg:pink1 p:3 rd:100px]>
									<icon-tag[c:pink6 w:6 h:6] name="alert-circle">
								<h2[lh:120% mt:4]> "No Friend Tech account associated with this wallet"
					else
						<div[ta:center d:vflex a:stretch]>
							<div[d:vflex a:center]>
								<div[bg:cooler1 p:3 rd:100px]>
									<icon-tag.spin[c:cooler6 w:6 h:6] name="loading-03">
								<h2[lh:120% mt:4]> "Checking for Friend Tech account..."
				else
					<div.card-header>
						<h3[flg:1 fs:3 c:cooler5 tt:uppercase ls:.05rem]> "Connect with"
						
						<tip-tag align="right"> 
							<div[p:2]>
								<p[w:220px]> "Wallets let you manage digital assets like Ethereum tokens & NTFs. You can also use them to login to apps without passwords."
					
								<a[d:flex a:center] href="/docs/wallet" target="_blank"> 
									<button[px:1 py:0 rd:8px bg:cooler8 c:white mt:2 fs:sm]> 
										<icon-tag[mr:1 c:cooler5] name="link-external-01-alt" size=14>
										"Learn More"
					
					<div[mx:-2 mt:4]>
						<button[bg:transparent shadow:none w:100% j:start] @click=connectWallet!>
							<div[rd:100px w:8 h:8 zi:3 shadow:sm bg:cooler9 d:flex a:center j:center]>
								if connectingB then <icon-tag.spin[c:white] name="loading-03" size=16> else <icon-tag[c:white] name="browser" size=16>
					
							<p[ml:2 fw:600 c:cooler9]> "Browser Wallet"
						
						<button[bg:transparent shadow:none w:100% j:start mt:2] @click=connectWalletApp!>
							<div[rd:100px w:8 h:8 zi:3 shadow:sm bg:cooler9 d:flex a:center j:center]>
								if connectingW then <icon-tag.spin[c:white] name="loading-03" size=16> else <icon-tag[c:white] name="phone-01" size=16>
					
							<p[ml:2 fw:600 flg:1 ta:left pr:2 c:cooler9]> "Wallet App"
								<span[c:cooler5 fw:500 float:right]> "WalletConnect"
