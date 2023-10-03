import "lucia/polyfill/node"
import { lucia } from "lucia"
import { prisma } from "@lucia-auth/adapter-prisma"
import { pc } from "./prisma.imba"
import { express } from "lucia/middleware"
import { discord, twitter } from "@lucia-auth/oauth/providers"
import { OAuthRequestError } from "@lucia-auth/oauth"
import { parseCookie } from "lucia/utils"

const dev? = process.env.ENV is "development"

export const auth = lucia
	env: if dev? then "DEV" else "PROD"
	adapter: prisma pc
	middleware: express!

	getUserAttributes: do
		discordId: $1.discordId
		discordUsername: $1.discordUsername
		discordAvatar: $1.discordAvatar
		twitterId: $1.twitterId
		twitterUsername: $1.twitterUsername
		twitterAvatar: $1.twitterAvatar
		ftAddress: $1.ftAddress

export const discordAuth = discord auth,
	clientId: process.env.DISCORD_CLIENT
	clientSecret: process.env.DISCORD_SECRET
	redirectUri: "{process.env.HOST}/login/discord/callback"
	scope: ["identify"]

export const twitterAuth = twitter auth,
	clientId: process.env.TWITTER_CLIENT
	clientSecret: process.env.TWITTER_SECRET
	redirectUri: "{process.env.HOST}/login/x/callback"

export default do(app)
	app.get "/login/discord", do(req,res)
		try
			const [url, state] = await discordAuth.getAuthorizationUrl!

			res.cookie "discord_oauth_state", state,
				httpOnly: yes
				secure: !dev?
				path: "/"
				maxAge: 1hours
			
			res.cookie "original_route", req.query.redirect or "/",
				httpOnly: yes
				secure: !dev?
				path: "/"
				maxAge: 1hours
			
			res.status(302).setHeader("Location", url.toString!).end!
		catch e
			E e
			res.status(500).send {message: e.message}

	app.get "/login/x", do(req,res)
		try
			const authRequest = auth.handleRequest req, res
			const session = await authRequest.validate!
			const [url, codeVerifier, state] = await twitterAuth.getAuthorizationUrl!

			res.cookie "twitter_code_verifier", codeVerifier,
				httpOnly: yes
				secure: !dev?
				path: "/"
				maxAge: 1hours
			
			res.cookie "user_id", session.user.userId,
				httpOnly: yes
				secure: !dev?
				path: "/"
				maxAge: 1hours
			
			res.cookie "twitter_oauth_state", state,
				httpOnly: yes
				secure: !dev?
				path: "/"
				maxAge: 1hours
			
			res.cookie "original_route", req.query.redirect or "/",
				httpOnly: yes
				secure: !dev?
				path: "/"
				maxAge: 1hours
			
			res.status(302).setHeader("Location", url.toString!).end!
		catch e
			E e
			res.status(500).send {message: e.message}
	
	app.get "/login/discord/callback", do(req,res)
		try
			const cookies = parseCookie req.headers.cookie or ""
			const storedState = cookies.discord_oauth_state
			const originalRoute = cookies.original_route
			const state = req.query.state
			const code = req.query.code

			if !storedState or !state or storedState isnt state or code !isa "string"
				return res.status(302).setHeader("Location", originalRoute).end!
		
			const { getExistingUser, discordUser, createUser } = await discordAuth.validateCallback code
			const user = await getExistingUser! or await createUser
				attributes:
					discordUsername: discordUser.username
					discordId: discordUser.id
					discordAvatar: discordUser.avatar
			const session = await auth.createSession userId: user.userId
			const authRequest = auth.handleRequest req, res

			authRequest.setSession session

			res.status(302).setHeader("Location", originalRoute).end!
		catch e
			E e
			return res.sendStatus 400 if e isa OAuthRequestError
			res.status(500).send {message: e.message}
	
	app.get "/login/x/callback", do(req,res)
		try
			const cookies = parseCookie req.headers.cookie or ""
			const storedState = cookies.twitter_oauth_state
			const originalRoute = cookies.original_route
			const state = req.query.state
			const code = req.query.code

			if !storedState or !state or storedState isnt state or code !isa "string"
				return res.status(302).setHeader("Location", originalRoute).end!
			
			const codeVerifier = cookies.twitter_code_verifier
			const userId = cookies.user_id
			const { getExistingUser, twitterUser, createKey } = await twitterAuth.validateCallback code, codeVerifier
			
			let user = await getExistingUser!
			
			if !user
				user = await auth.transformDatabaseUser (await auth.getUser userId)
				await createKey userId if user

				await pc.user.update
					where:
						id: userId
					data:
						twitterUsername: twitterUser.username
						twitterId: twitterUser.id
				
				user.userId = userId

			const session = await auth.createSession userId: user.userId
			const authRequest = auth.handleRequest req, res

			authRequest.setSession session

			res.status(302).setHeader("Location", originalRoute).end!
		catch e
			E e
			return res.sendStatus 400 if e isa OAuthRequestError
			res.status(500).send {message: e.message}

	app.get "/user", do(req, res)
		try
			const authRequest = auth.handleRequest req, res
			const session = await authRequest.validate!
			
			if session
				res.json session.user
			else
				res.json null
		catch e
			E e
			res.status(500).send {error: e.message}
	
	app.get "/logout", do(req, res)
		try
			const authRequest = auth.handleRequest req, res
			const session = await authRequest.validate!

			return res.sendStatus 401 if !session

			await auth.invalidateSession session.sessionId
			authRequest.setSession null

			res.status(302).setHeader("Location", "/").end!
		catch e
			E e
			res.status(500).send {error: e.message}
	
