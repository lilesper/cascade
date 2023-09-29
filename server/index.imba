import path from "path"
import express from "express"
import compression from "compression"
import serveStatic from "serve-static"
import Session from "express-session"
import RedisStore from "connect-redis"
import { createClient } from "redis"
import * as Vite from "vite"
import np from 'node:path'
import url from 'node:url'
import prisma from "./prisma.imba"
import auth from "./auth.imba"
import ft from "./ft.imba"
import discord, { monitorRoles } from "./discord.imba"
import { errorHandler } from "../src/store/index"
import helmet from "helmet"
import App from "../src/App.imba"

let a = 1
# import moduleGraph from "./server.moduleGraph.json"
const _dirname = url.fileURLToPath(new URL('.', import.meta.url));
# We need to load SSR styles manually in order to prevent FOUC
# We leverage vite-node to create a module graph from the server entry point
# And we load all the tags CSS in separate files and concatenate them  here
# We didn't put them in one big css file because Vite transforms them to be
# imported as ESModules so their string contain some js specific stuff
# like \n ... Instead we keep them to avoid breaking anything and import them
# as they should be
const ssr-css-modules = import.meta.glob("./.ssr/*.css.js")
let ssr-styles = ""

for own key of ssr-css-modules
	ssr-styles += (await ssr-css-modules[key]()).default

let port = 3000
const args = process.argv.slice(2)
const portArgPos = args.indexOf("--port") + 1

if portArgPos > 0
	port = parseInt(args[portArgPos], 10)

global.E = do(e, args) errorHandler e, args

def createServer(root = process.cwd(), dev? = import.meta.env.MODE === "development")
	const resolve = do(p) path.resolve(root, p)

	let manifest\Object
	if !dev?
		manifest = try (await import("../dist_client/manifest.json")).default
	
	const app = express()
	const configFile = np.join(_dirname, "../vite.config.js")
	
	const client = if dev? then createClient! else createClient
		username: process.env.REDIS_USERNAME
		password: process.env.REDIS_PASSWORD
		socket:
			host: process.env.REDIS_HOST
			port: Number process.env.REDIS_PORT
			tls: no
			reconnectStrategy: do(retries)
				if retries > 10
					const error = new Error "Too many retries on REDIS — connection terminated."
					E error
					error
				else
					retries


	client.connect!.catch do E $1
	client.on "error", do E $1
	
	let vite
	
	if dev?
		vite = await Vite.createServer
			root: root
			appType: "custom"
			configFile: configFile
			server:
				middlewareMode: true
				port: port
				strictPort: true
				hmr:
					port: port + 25000
		app.use vite.middlewares
	else
		const inlineCfg =
			root: root
			appType: "custom"
			server:
				middlewareMode: true
		# maybe use a different config
		app.use compression!
		app.use serveStatic "dist_client", index: no
	
	app.use helmet.contentSecurityPolicy
		directives:
			defaultSrc: ["'self'"]
			scriptSrc: ["'self'", "'unsafe-inline'", "'unsafe-eval'", "https://verify.walletconnect.org", "https://verify.walletconnect.com", "https://static.highlight.io"]
			workerSrc: ["'self'", "blob:"]
			styleSrc: ["'self'", "'unsafe-inline'"]
			imgSrc: ["'self'", "data:", "https://explorer-api.walletconnect.com", "https://pbs.twimg.com", "https://d3egfmvgqzu76k.cloudfront.net"]
			connectSrc: ["'self'", "ws://localhost:28000", "https://prod.spline.design", "https://pub.highlight.run", "wss://relay.walletconnect.com", "https://explorer-api.walletconnect.com", "https://discord.com"]
			fontSrc: ["'self'", "https:"]
			objectSrc: ["'none'"]
			frameSrc: ["https://verify.walletconnect.org", "https://verify.walletconnect.com"]

	app.use Session
		name: "frenpass"
		secret: process.env.SECRET
		saveUninitialized: yes
		resave: no
		cookie:
			secure: "auto"
			sameSite: yes
		store: new RedisStore
			client: client
			prefix: "s:"
			ttl: 86400000
	app.use express.json!

	auth app
	prisma app
	discord app
	ft app

	app.use "/*/assets", express.static (path.join (new URL(".", import.meta.url).pathname, "dist_client/assets"))

	app.get "*", do(req, res)
		const url = req.originalUrl
		a++
		try
			let html = String <html lang="en">
				<head>
					<meta charset="UTF-8">
					<meta name="viewport" content="width=device-width, initial-scale=1">
					<title> "Frenpass | KeyHolder Access Management"
					<meta name="description" content="Frenpass helps Friend Tech Key Holders go places">
					<link rel="icon" type="image/png" href="/images/frenpass-ico.png">
					
					if dev?
						<script type="module" src="/@vite/client">
						<script type="module" src="/src/main.js">
						<style id="dev_ssr_css" innerHTML=ssr-styles>
					else
						const prod-src = manifest["src/main.js"].file
						const css-files = manifest["src/main.js"].css
						<script type="module" src=prod-src>
						for css-file in css-files
							<style src=css-file>
				
				<body>
					<App>

			res.status(200).set("Content-Type": "text/html").end html
		catch e
			vite and vite.ssrFixStacktrace(e)
			E e
			res.status(500).send { error: e.message }
	return
		app: app
		vite: vite

const {app} = await createServer!
console.log "server created"

const server = app.listen port, do console.log "http://localhost:{port}"
const exitProcess = do
	console.log "exiting process"
	try await server.close do console.log "server closed" finally process.exit 0

process.stdin.on "end", exitProcess