import { PrismaClient } from "@prisma/client"
import fetch from "node-fetch"

export const pc = new PrismaClient!

export def getTrades query
	try
		await (await fetch "https://frentool-production.up.railway.app/trades"
			method: "POST"
			headers:
				"Content-Type": "application/json",
				"x-api-key": process.env.FRENTOOL_API
			body: JSON.stringify {query}).json!
	catch e
		E e, query
		no

export default do(app)
	app.post("/create") do({body}, res) 
		try
			res.send await pc[body.table].create data: body.data
		catch e
			E e, body
			res.status(500).send { error: e.message }
	
	app.post("/get") do({body}, res)
		try
			res.send await pc[body.table].findUnique where: body.query
		catch e
			E e, body
			res.status(500).send { error: e.message }

	app.post("/update") do({body}, res) 
		try
			res.send await pc[body.table].update
				where: body.query
				data: body.data
		catch e
			E e, body
			res.status(500).send { error: e.message }
	
	app.post("/delete") do({body}, res)
		try
			res.send await pc[body.table].delete
				where: body.query
		catch e
			E e, body
			res.status(500).send { error: e.message }
	
	app.post("/fetch") do({body}, res)
		try
			res.send await pc[body.table].findMany where: body.query
		catch e
			E e, body
			res.status(500).send { error: e.message }
	
	app.post("/trades") do({body}, res)
		try
			res.send await getTrades body.query
		catch e
			E e, body
			res.status(500).send { error: e.message }
	
	app.get("/transactions/:address") do(req, res)
		try
			res.send await (await fetch "https://api.basescan.org/api?module=account&action=txlist&address={req.params.address}&startblock=0&endblock=99999999&sort=asc&apikey={process.env.BASECAN_API}").json!
		catch e
			E e, req.body
			res.status(500).send { error: e.message }