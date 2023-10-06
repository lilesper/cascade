import { Client, GatewayIntentBits } from "discord.js"
import cronjob from "node-cron"
import { store } from "../src/store/index.imba"
import { prisma, getTrades } from "./prisma.imba"
import { getAddress, isAddressEqual } from "viem"
import { auth } from "./auth.imba"
import fetch from "node-fetch"
import { padlock } from "./redis.imba"

const { contract, ftApi } = store

export const discord = new Client {intents: [GatewayIntentBits.Guilds, GatewayIntentBits.GuildMembers]}

discord.login process.env.DISCORD_TOKEN
discord.setMaxListeners 50

discord.on "guildCreate", do(guild)
	return if process.env.ENV is "staging"
	return if guild.id is "1123937233368522832" and process.env.ENV is "production"
	return if !guild

	const lockKey = "lock:guildCreate:{guild.id}"

	if await padlock.lock lockKey, 1
		try
			const role = await guild.roles.create
				name: "🔑 Key Holder"
				color: "#11a5e9"
				reason: "To allow access for key holders"
			
			let interval
			let tries = 0
			
			interval = setInterval(&,1000) do
				if tries > 10
					clearInterval interval
					padlock.unlock lockKey

				const auditLogs = await guild.fetchAuditLogs type: 28
				const botFirstAdded = auditLogs.entries.first!

				if botFirstAdded
					clearInterval interval
					padlock.unlock lockKey
					
					try
						await prisma.discordServer.upsert
							where:
								id: guild.id
							create:
								id: guild.id
								creatorId: botFirstAdded.executor.id
								roleId: role.id
								isConnected: yes
							update:
								creatorId: botFirstAdded.executor.id
								roleId: role.id
								isConnected: yes
					catch e E e
				else
					tries++
			
		catch e 
			E e
		
discord.on "guildDelete", do(guild)
	return if process.env.ENV is "staging"
	return if guild.id is "1123937233368522832" and process.env.ENV is "production"
	
	const lockKey = "lock:guildDelete:{guild.id}"

	if await padlock.lock lockKey, 1
		try
			await prisma.discordServer.update
				where:
					id: guild.id
				data:
					isConnected: no
			await prisma.membership.deleteMany
				where:
					serverId: guild.id
			
			padlock.unlock lockKey
		catch e E e

export const monitorRoles = cronjob.schedule("*/5 * * * *", &, {scheduled: no, runOnInit: no}) do
	L "checking roles"
	
	const lockKey = "lock:monitorRoles"
	
	L lockKey
	
	if await padlock.lock lockKey, 4
		def deleteMembership userId, serverId
			await prisma.membership.delete
				where:
					userId_serverId:
						userId: userId
						serverId: serverId

		try
			const memberships = await prisma.membership.findMany
				include:
					user: yes
					discordServer: yes
			
			L memberships.length
			
			for m in memberships
				L "MEMBERSHIP--------------------------------------"
				L m.serverId, m.userId
				
				const keyBalances = try await Promise.all m.discordServer.ftAddresses.map do contract.read.sharesBalance [$1, m.user.ftAddress]
				catch e
					E e, m.discordServer.ftAddress, m.user.ftAddress
					if !m.user.ftAddress
						await deleteMembership m.userId, m.serverId
						return L "removed membership"
					else
						return
				
				const totalBalance = keyBalances.reduce(&, 0n) do $1 + $2

				L m.discordServer.ftAddress
				L m.user.ftAddress
				L totalBalance
				
				if totalBalance is 0n
					try
						const guild = await discord.guilds.fetch m.serverId
						
						const member = try await guild.members.fetch m.user.discordId
						catch e 
							if e.code is 10007
								await deleteMembership m.userId, m.serverId
								return L "removed membership"
							else
								E e, "tried to get member"

						const roleObj = await guild.roles.fetch m.discordServer.roleId

						await member.roles.remove roleObj

						L "removed"
					catch e
						E e, m.discordServer.ftAddress, m.user.ftAddress, keyBalances
		catch e
			E e

export default do(app)
	app.get("/discord-roles/:guildId") do(req, res)
		try
			const server = await discord.guilds.fetch req.params.guildId
			
			res.send await server.roles.fetch!
		catch e
			E e
			res.status(500).send { error: e.message }
	
	app.get("/discord-remove/:discordId") do(req, res)
		try

			const server = await discord.guilds.fetch req.params.discordId
			const discordServer = await prisma.discordServer.findUnique
				where:
					id: req.params.discordId
			const role = await server.roles.fetch discordServer.roleId
			
			await role.delete "Removing Bot from Server"
			await server.leave!
			
			res.send true
		catch e
			E e, req.body
			res.status(500).send { error: e.message }
		
	app.get("/discord-assign-role/:discordId") do(req, res)
		const authRequest = auth.handleRequest req, res
		const session = await authRequest.validate!

		try
			let discordServer
			let userAddress

			if !session.user.ftAddress
				const [prismaResponse, freindTechResponse] = await Promise.all [
					prisma.discordServer.findUnique
						where:
							id: req.params.discordId
					fetch "{ftApi}search/users?username={session.user.twitterUsername}",
						method: "GET"
						headers:
							"Content-Type": "application/json"
							"Acceot": "application/json"
							"Referer": "https://www.friend.tech/"
							"Authorization": process.env.FT_JWT
				]
				discordServer = prismaResponse
				
				const ftUsers = await freindTechResponse.json!
				const user = ftUsers.users.find do $1.twitterUsername is session.user.twitterUsername

				await prisma.user.update
					where:
						id: session.user.userId
					data:
						ftAddress: user.address
						twitterAvatar: user.twitterPfpUrl
				
				userAddress = user.address
				
			else
				userAddress = session.user.ftAddress
				discordServer = await prisma.discordServer.findUnique
					where:
						id: req.params.discordId

			const keyBalances = await Promise.all discordServer.ftAddresses.map do contract.read.sharesBalance [$1, userAddress]
			const totalBalance = keyBalances.reduce(&, 0n) do $1 + $2

			if totalBalance > 0n
				const guild = await discord.guilds.fetch discordServer.id
				const member = await guild.members.fetch session.user.discordId
				
				const roleObj = await guild.roles.fetch discordServer.roleId
				
				await member.roles.add roleObj
		
				prisma.membership.upsert(
					where:
						userId_serverId:
							userId: session.user.userId
							serverId: discordServer.id
					update: {}
					create:
						userId: session.user.userId
						serverId: discordServer.id
				).catch do E $1
				
				res.send true
			else 
				res.send false	
		catch e
			E e
			res.status(500).send { error: e.message }

	