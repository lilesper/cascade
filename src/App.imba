import * as store from "./store/index.imba"
import "./styles.imba"
import "./components/nav-tag.imba"
import "./components/modal-tag.imba"
import "./components/connect-tag.imba"
import "./components/icon-tag.imba"
import "./components/tip-tag.imba"
import "./components/dropdown-tag.imba"
import "./components/discord-tag.imba"
import "./components/notify-tag.imba"
import "./components/route-tag.imba"

def Index do (await import "./pages/Index.imba").default
def Discord do (await import "./pages/Discord.imba").default

const web? = !import.meta.env.SSR
const dev? = if web? and window.location.hostname is "localhost" then yes else no

extend tag element
	get store do store
	get w3 do store.w3
	get client do store.client
	get dev? do dev?
	get web? do web?

	def onlyConnected
		if !w3.client
			emit "triggerConnection"
			no
	
	def waitFor obj, key, callback
		let interval
		
		interval = setInterval(&,100) do
			if obj[key]
				clearInterval interval
				callback!

export default tag App
	def hydrate
		schedule!
		imba.commit!
	
	def mount
		document.getElementById("dev_ssr_css")..remove!
		
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

	def render
		<self> if web?
			<div.main[d:flex fld:column ai:center w:100% mb:20]>
				<nav-tag[my:8 zi:100]>

				<route-tag route="/" page=Index>
				<route-tag route="/discord/" page=Discord>
				<route-tag route="/discord/:subject" page=Discord>
			
			<notify-tag>