import express from "express"
import compression from "compression"
import serveStatic from "serve-static"
import helmet from "helmet"
import { redis } from "./redis.imba"

import path from "path"
import np from 'node:path'
import url from 'node:url'

import prisma from "./prisma.imba"
import auth from "./auth.imba"
import ft from "./ft.imba"
import discord, { monitorRoles } from "./discord.imba"

import * as Vite from "vite"
import { store } from "../src/store/index"
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

let port = Number process.env.PORT or 3000
const args = process.argv.slice(2)
const portArgPos = args.indexOf("--port") + 1

if portArgPos > 0
	port = parseInt(args[portArgPos], 10)

global.E = do(e, args) store.errorHandler e, args

redis.on "error", do E $1

def createServer(root = process.cwd(), dev? = import.meta.env.MODE === "development")
	const resolve = do(p) path.resolve(root, p)

	let manifest\Object
	if !dev?
		manifest = try (await import("../dist_client/manifest.json")).default
	
	const app = express!
	const configFile = np.join(_dirname, "../vite.config.js")
	
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
			imgSrc: ["'self'", "data:", "https://explorer-api.walletconnect.com", "https://pbs.twimg.com", "https://d3egfmvgqzu76k.cloudfront.net", "https://cdn.discordapp.com"]
			connectSrc: ["'self'", "ws://localhost:28000", "https://prod.spline.design", "https://draft.spline.design", "https://pub.highlight.run", "wss://relay.walletconnect.com", "https://explorer-api.walletconnect.com", "https://discord.com"]
			fontSrc: ["'self'", "https:"]
			objectSrc: ["'none'"]
			frameSrc: ["https://verify.walletconnect.org", "https://verify.walletconnect.com"]
	
	app.use express.urlencoded extended: yes
	app.use express.json!

	auth app
	prisma app
	discord app
	ft app

	if process.env.ENV is "production"
		app.all /.*/, do(req, res, next)
			let host = req.header "host"
			
			if host.startsWith "www."
				res.redirect 301, "http://" + host.replace("www.", "") + req.url
			else
				next!

	app.use "/*/assets", express.static (path.join (new URL(".", import.meta.url).pathname, "dist_client/assets"))

	app.use "*", do(req, res)
		const url = req.originalUrl
		a++
		try
			let html = String <html lang="en">
				<head>
					<meta charset="UTF-8">
					
					# seo tags
					<meta name="viewport" content="width=device-width, initial-scale=1">
					<meta name="description" content="Frenpass helps active Friend Tech users manage large audiences by migrating them to an organized Discord server with on-chain verification and auto-moderation">
					<title> "Frenpass | Organize your community beyond the chaos of Friend Tech"
					<link rel="icon" type="image/png" href="/images/frenpass-ico.png">

					# open graph tags
					<meta property="og:url" content="https://www.frenpass.app">
					<meta property="og:type" content="website">
					<meta property="og:title" content="Organize your community beyond the chaos of Friend Tech">
					<meta property="og:description" content="Frenpass helps active Friend Tech users manage large audiences by migrating them to an organized Discord server with on-chain verification and auto-moderation">
					<meta property="og:image" content="/images/og-img.jpg">

					# open graph tags (twitter)
					<meta name="twitter:card" content="summary_large_image">
					<meta property="twitter:domain" content="frenpass.app">
					<meta property="twitter:url" content="https://www.frenpass.app">
					<meta name="twitter:title" content="Organize your community beyond the chaos of Friend Tech">
					<meta name="twitter:description" content="Frenpass helps active Friend Tech users manage large audiences by migrating them to an organized Discord server with on-chain verification and auto-moderation">
					<meta name="twitter:image" content="/images/og-img.jpg">

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

monitorRoles.start! if process.env.ENV isnt "staging"

const server = app.listen port, do console.log "http://localhost:{port}"
const exitProcess = do
	console.log "exiting process"
	try await server.close do console.log "server closed" finally process.exit 0

process.stdin.on "end", exitProcess