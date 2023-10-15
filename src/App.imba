import { store } from "./store/index.imba"
import "./styles.imba"
import "./components/nav-tag.imba"
import "./components/modal-tag.imba"
import "./components/icon-tag.imba"
import "./components/tip-tag.imba"
import "./components/dropdown-tag.imba"
import "./components/discord-setup.imba"
import "./components/notify-tag.imba"
import "./components/confirm-modal.imba"
import "./components/route-tag.imba"
import "./components/user-tag.imba"
import "./components/avatar-tag.imba"

global.S = store

def Index do (await import "./pages/Index.imba").default
def Setup do (await import "./pages/Setup.imba").default
def Discord do (await import "./pages/Discord.imba").default
def Docs do (await import "./pages/docs/Index.imba").default

const web? = !import.meta.env.SSR
const dev? = if web? and window.location.hostname is "localhost" then yes else no

extend tag element
	get dev? do dev?
	get web? do web?

	def onlyConnected
		if !S.w3.client
			emit "triggerConnection"
			no
	
	def waitFor obj, key, callback
		let interval
		
		interval = setInterval(&,100) do
			if obj[key]
				clearInterval interval
				callback!

tag june-tag
	def mount
		window.analytics = {}
		
		window.analytics._writeKey = import.meta.env.VITE_JUNE
		
		let script = document.createElement("script");
		
		script.type = "application/javascript";
		script.onload = do 
			window.analytics.page!
			
			if S.user
				window.analytics.identify S.user.userId,
					name: S.user.discordUsername or S.user.twitterUsername
					avatar: if S.user.discordAvatar then "https://cdn.discordapp.com/avatars/{S.user.discordId}/{S.user.discordAvatar}.png" else S.user.twitterAvatar
				
				window.analytics.track "Connected"

		script.src = "https://unpkg.com/@june-so/analytics-next/dist/umd/standalone.js";
		
		let first = document.getElementsByTagName('script')[0];
		
		first.parentNode.insertBefore(script, first);

export default tag App
	def hydrate
		schedule!
		imba.commit!
	
	def mount
		document.getElementById("dev_ssr_css")..remove!

		store.fetch("/user").then do
			S.user = $1

			imba.commit!

			if S.user and imba.router.path is "/" then imba.router.go "/setup"

		const { H } = await import "highlight.run"

		H.init "jd4k49e5",
			environment: if dev? then "development" else "production"
			tracingOrigins: ["localhost", "frenpass.app", "www.frenpass.app"]
			networkRecording: {enabled: yes, recordHeadersAndBody: yes}

		global.H = H
		global.E = do(e, args)
			if dev?
				store.errorHandler e, args
			else
				H.consumeError e, "{e.message}"

		waitFor S, "user", do 
			H.identify S.user.userId, 
				avatar: if S.user.discordAvatar then "https://cdn.discordapp.com/avatars/{S.user.discordId}/{S.user.discordAvatar}.png" else S.user.twitterAvatar
				highlightDisplayName: S.user.discordUsername or S.user.twitterUsername
		
		
		

	def render
		<self> if web?
			<june-tag>

			<div.main[d:flex fld:column ai:center w:100% mb:20]>
				<nav-tag[my:8 zi:100]>
				
				<route-tag route="/" page=Index>
				<route-tag route="/setup" page=Setup>
				<route-tag route="/docs" page=Docs>
				<route-tag route="/discord/" page=Discord>
				<route-tag route="/discord/:id" page=Discord>

			<notify-tag>
			<confirm-modal>