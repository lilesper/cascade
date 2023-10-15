import "lucia/polyfill/node"
import { lucia } from "lucia"
import { prisma as prismaAdapter } from "@lucia-auth/adapter-prisma"
import { ioredis as redisAdapter } from "@lucia-auth/adapter-session-redis"
import { prisma } from "./prisma.imba"
import { express } from "lucia/middleware"
import { discord, twitter } from "@lucia-auth/oauth/providers"
import { OAuthRequestError } from "@lucia-auth/oauth"
import { parseCookie } from "lucia/utils"
import { redis } from "./redis.imba"

const dev? = process.env.ENV is "development"

export const auth = lucia
	env: if dev? then "DEV" else "PROD"
	adapter: 
		user: prismaAdapter prisma
		session: redisAdapter redis
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
	app.get "/login/discord", do(req, res, next)
		try
			const [url, state] = await discordAuth.getAuthorizationUrl!
			const sessionData =
				state: state
				originalRoute: req.query.redirect or "/"
			
			redis.set "temp:{state}", (JSON.stringify sessionData), "EX", 3600

			res.status(302).setHeader("Location", url.toString!).end!
		catch e next e

	app.get "/login/x", do(req, res, next)
		try
			const authRequest = auth.handleRequest req, res
			const session = await authRequest.validate!
			const [url, codeVerifier, state] = await twitterAuth.getAuthorizationUrl!
			const sessionData =
				codeVerifier: codeVerifier
				sessionUserId: session.user.userId
				state: state
				originalRoute: req.query.redirect or "/"
			
			redis.set "temp:{state}", (JSON.stringify sessionData), "EX", 3600
			
			res.status(302).setHeader("Location", url.toString!).end!
		catch e
			E e
			next e
	
	app.get "/login/discord/callback", do(req, res, next)
		try
			const state = req.query.state
			const code = req.query.code
			const sessionData = JSON.parse await redis.get "temp:{state}"
			
			if sessionData then redis.del "temp:{state}"
			
			const storedState = sessionData.state
			const originalRoute = sessionData.originalRoute

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
			return res.sendStatus 400 if e isa OAuthRequestError
			next e
	
	app.get "/login/x/callback", do(req, res, next)
		try
			const state = req.query.state
			const code = req.query.code
			const sessionData = JSON.parse await redis.get "temp:{state}"
			
			if sessionData then redis.del "temp:{state}"

			const storedState = sessionData.state
			const originalRoute = sessionData.originalRoute

			if !storedState or !state or storedState isnt state or code !isa "string"
				return res.status(302).setHeader("Location", originalRoute).end!
			
			const codeVerifier = sessionData.codeVerifier
			const userId = sessionData.sessionUserId
			const { getExistingUser, twitterUser, createKey } = await twitterAuth.validateCallback code, codeVerifier
			
			let user = await getExistingUser!
			
			if !user
				user = await auth.transformDatabaseUser (await auth.getUser userId)
				await createKey userId if user

				await prisma.user.update
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
			return res.sendStatus 400 if e isa OAuthRequestError
			next e

	app.get "/user", do(req, res, next)
		try
			const authRequest = auth.handleRequest req, res
			const session = await authRequest.validate!
			
			if session
				res.json session.user
			else
				res.json null
		catch e next e
	
	app.get "/logout", do(req, res, next)
		try
			const authRequest = auth.handleRequest req, res
			const session = await authRequest.validate!

			return res.sendStatus 401 if !session

			await auth.invalidateSession session.sessionId
			authRequest.setSession null

			res.status(302).setHeader("Location", "/").end!
		catch e next e
	
