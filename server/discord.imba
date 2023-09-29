import { Client, GatewayIntentBits } from "discord.js"
import cronjob from "node-cron"
import { client, getAbiItem, contract } from "../src/store/index.imba"
import { prisma, getTrades } from "./prisma.imba"
import { getAddress, isAddressEqual } from "viem"

const discord = new Client {intents: [GatewayIntentBits.Guilds, GatewayIntentBits.GuildMembers]}

discord.login process.env.DISCORD
discord.setMaxListeners 50

discord.on "guildDelete", do(guild)
	try
		await prisma.keyHolder.updateMany
			where:
				discordServer: guild.id
			data:
				discordServer: ""
				discordRoleId: ""
	catch e E e, guild

def listener guild, address
	if !guild or !address then return
	
	try
		const role = await guild.roles.create
			name: "🔑 Key Holder"
			color: "#11a5e9"
			reason: "To allow access for key holders"

		await prisma.keyHolder.update
			where:
				address: getAddress address
			data:
				discordServer: guild.id
				discordUserId: guild.ownerId
				discordRoleId: role.id
	catch e E e, {...guild}, address

export const monitorRoles = cronjob.schedule("* * * * * *", &, {scheduled: no, runOnInit: no}) do
	try
		const users = await prisma.keyHolder.findMany
			where:
				discordUserId:
					not: ""
		
		users.forEach do(u)
			getTrades({trader: getAddress u.ftAddress})
				.then(do(trades) 
					return if !trades
					
					const subjects = [...new Set trades.map do $1.subject]
					const frenPassSubjects = subjects.filter do(s) users.some do isAddressEqual $1.address, s
					
					for subject in frenPassSubjects
						const sharesBalance = await contract.read.sharesBalance [subject, u.ftAddress]

						if sharesBalance is 0n
							try
								const keyHolder = users.find do isAddressEqual $1.address, subject
								const role = keyHolder.discordRoleId
								const discordServer = await discord.guilds.fetch keyHolder.discordServer
								const member = await discordServer.members.fetch u.discordUserId
								const roleObj = await discordServer.roles.fetch role
								
								await member.roles.remove roleObj
							catch e
								E e, subject, u.ftAddress, sharesBalance
				).catch do(e)
					E e

	catch e
		E e

export default do(app)
	app.get("/discord-on") do(req, res) 
		try
			discord.on "guildCreate", do(guild) listener guild, req.session.siwe.address

			setTimeout(&,20minutes) do
				discord.off "guildCreate", listener
		catch e
			E e
		res.send true
	
	app.get("/discord-off") do(req, res)
		try
			discord.off "guildCreate", listener
			res.send true
		catch e
			E e
			res.status(500).send { error: e.message }
	
	app.get("/discord-name/:guildId") do(req, res)
		try
			const server = await discord.guilds.fetch req.params.guildId
			
			res.send await server.name
		catch e
			E e
			res.status(500).send { error: e.message }

	app.get("/discord-roles/:guildId") do(req, res)
		try
			const server = await discord.guilds.fetch req.params.guildId
			
			res.send await server.roles.fetch!
		catch e
			E e
			res.status(500).send { error: e.message }
	
	app.post("/discord-remove") do(req, res)
		try
			const server = await discord.guilds.fetch req.body.guildId
			
			await server.leave!

			res.send true
		catch e
			E e, req.body
			res.status(500).send { error: e.message }
		
	app.post("/discord-assign-role") do(req, res)
		try
			const [keyHolder, subjectKeyHolder] = await Promise.all [
				prisma.keyHolder.findUnique 
					where:
						address: getAddress req.session.siwe.address
				prisma.keyHolder.findUnique 
					where:
						address: getAddress req.body.subject
			]

			const keyBalance = await contract.read.sharesBalance [subjectKeyHolder.ftAddress, keyHolder.ftAddress]

			if keyBalance > 0n
				const role = subjectKeyHolder.discordRoleId
				const discordServer = await discord.guilds.fetch subjectKeyHolder.discordServer
				const member = await discordServer.members.fetch keyHolder.discordUserId
				const roleObj = await discordServer.roles.fetch role
		
				await member.roles.add roleObj
		
				res.send true
			else res.status(500).send { error: e.message }	
		catch e
			E e, req.body
			res.status(500).send { error: e.message }