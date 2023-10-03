import SharesV1 from "../../contracts/sharesv1.json"
import { parseUnits, recoverAddress, formatUnits, isAddressEqual, getAddress, getContract, createPublicClient, http, hashMessage } from "viem"
import { base as viemBase } from "viem/chains"
import { base } from "./base.imba"

const address = "0xCF205808Ed36593aa40a44F10c7f7C2F67d4A4d4"
const client = createPublicClient
	chain: viemBase,
	batch: {multicall: yes}
	transport: http import.meta.env.VITE_BASE_RPC

export const w3 =
	ftApi: "https://prod-api.kosetto.com/"
	chain: base
	client: client
	contract: getContract
		address: address
		abi: SharesV1.abi
		publicClient: client
	getAbiItem: do(name) SharesV1.abi.find do $1.name is name
	w3:
		provider: null
		client: null
		addy: ""
		chainId: 8453
		sig: ""
		user: null
		ftData: null
	
	verify: do(account)
		const { SiweMessage } = await import "siwe"
		
		try 
			const res = await nonce!
			const msg = new SiweMessage
				domain: window.location.host
				address: account
				statement: "I am verifying ownership of this wallet"
				uri: window.location.origin
				version: "1"
				chainId: w3.chainId
				nonce: res
			
			const prepped = msg.prepareMessage!

			w3.sig = await w3.client.signMessage {message: prepped, account}
			
			await login
				message: msg.prepareMessage!
				signature: w3.sig
			
			true
		catch e
			E e

	toWei: do(value, decimals = 18)
		decimals = Number decimals if typeof decimals is "bigint"
		value = if typeof value === "string" then value else value.toString!

		parseUnits value, decimals

	fromWei: do(value, decimals = 18)
		decimals = Number decimals if typeof decimals is "bigint"
		
		formatUnits value, decimals

	sign: do(message)
		const v = await w3.client.signMessage message: message
		const addy = recoverAddress hashMessage(message), v
		
		if addy isnt w3.addy then false else true

	getTwitterData: do(ftAddress)
		const res = await window.fetch "/twitter-ftdata/{ftAddress}"

		const data = await res.json!

		if data.message isnt "Address/User not found." then data else null


	getFtAddress: do(addy)
		try
			const [trades, transfers] = await Promise.all [
				base.query "", {trader: getAddress addy}, yes
				window.fetch "/transactions/{addy}"
			]

			if !trades and !transfers then return ""

			if !trades.length
				const haveSeenToAlready = {}
				let found? = no

				for transfer in (await transfers.json!).result
					return if haveSeenToAlready[transfer.to] or w3.ftData

					haveSeenToAlready[transfer.to] = yes

					if transfer.value > 0 and !isAddressEqual transfer.to, addy
						let hasToTrades = if (await fetch "", { trader: getAddress transfer.to }, yes).length then yes else no

						const toTransfers = await window.fetch "/transactions/{transfer.to}"
						const firstTx = (await toTransfers.json!).result[0]
						
						if hasToTrades and isAddressEqual firstTx.from, addy
							found? = yes
							transfer.to
				
				if !found? then ""
			else
				addy
		catch e
			E e