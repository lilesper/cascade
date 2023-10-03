import { Client, GatewayIntentBits } from "discord.js"
import cronjob from "node-cron"
import { store } from "../src/store/index.imba"
import { pc, getTrades } from "./prisma.imba"
import { getAddress, isAddressEqual } from "viem"
import { auth } from "./auth.imba"
import fetch from "node-fetch"

const { contract, ftApi } = store

const discord = new Client {intents: [GatewayIntentBits.Guilds, GatewayIntentBits.GuildMembers]}

discord.login process.env.DISCORD_TOKEN
discord.setMaxListeners 50

discord.on "guildCreate", do(guild)
	return if !guild

	try		
		const role = await guild.roles.create
			name: "🔑 Key Holder"
			color: "#11a5e9"
			reason: "To allow access for key holders"
		
		let interval
		let tries = 0
		
		interval = setInterval(&,1000) do
			clearInterval interval if tries > 10

			const auditLogs = await guild.fetchAuditLogs type: 28
			const botFirstAdded = auditLogs.entries.first!

			if botFirstAdded
				clearInterval interval
				
				await pc.discordServer.create
					data:
						id: guild.id
						creatorId: botFirstAdded.executor.id
						roleId: role.id
						isConnected: yes
			else
				tries++
		
	catch e 
		E e
		
discord.on "guildDelete", do(guild)
	try
		await pc.discordServer.delete
			where:
				id: guild.id
	catch e E e

export const monitorRoles = cronjob.schedule("*/30 * * * *", &, {scheduled: no, runOnInit: no}) do
	try
		const [users, discordServers] = await Promise.all [
			pc.user.findMany
				where:
					ftAddress:
						not: ""
			pc.discordServer.findMany
				where:
					ftAddress:
						not: ""
		]
		
		users.forEach do(u)
			getTrades({trader: getAddress u.ftAddress})
				.then(do(trades) 
					return if !trades
					
					const subjects = [...new Set trades.map do $1.subject]
					const frenPassSubjects = subjects.filter do(s) users.some do isAddressEqual $1.ftAddress, s
					
					for subject in frenPassSubjects
						const sharesBalance = await contract.read.sharesBalance [subject, u.ftAddress]

						if sharesBalance is 0n
							try
								const discordServer = discordServers.find do isAddressEqual $1.ftAddress, subject
								const guild = await discord.guilds.fetch discordServer.id
								const member = await guild.members.fetch u.discordId
								const roleObj = await guild.roles.fetch discordServer.roleId
								
								await member.roles.remove roleObj
							catch e
								E e, subject, u.ftAddress, sharesBalance
				).catch do(e)
					E e
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
			const discordServer = await pc.discordServer.findUnique
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
					pc.discordServer.findUnique
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

				await pc.user.update
					where:
						id: session.user.userId
					data:
						ftAddress: user.address
						twitterAvatar: user.twitterPfpUrl
				
				userAddress = user.address
				
			else
				userAddress = session.user.ftAddress
				discordServer = await pc.discordServer.findUnique
					where:
						id: req.params.discordId

			const keyBalance = await contract.read.sharesBalance [discordServer.ftAddress, userAddress]

			if keyBalance > 0n
				const guild = await discord.guilds.fetch discordServer.id
				const member = await guild.members.fetch session.user.discordId
				const roleObj = await guild.roles.fetch discordServer.roleId
				
				await member.roles.add roleObj
		
				res.send true
			else 
				res.send false	
		catch e
			E e
			res.status(500).send { error: e.message }

	