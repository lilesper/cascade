import {generateNonce, SiweMessage} from "siwe"

export default do(app)
	app.get("/nonce") do(req, res)
		res.header "Cache-Control", "no-cache, no-store, must-revalidate"
		
		try
			req.session.nonce = generateNonce!

			res.send req.session.nonce
		catch e
			E e
			
			req.session.nonce = null
			
			res.status(500).send { error: e.message }
	
	app.post("/verify") do(req, res)
		res.header "Cache-Control", "no-cache, no-store, must-revalidate"

		return unless req.body.message
		
		try
			let SIWEObject = new SiweMessage req.body.message

			const {data: message} = await SIWEObject.verify signature: req.body.signature, nonce: req.session.nonce
			
			req.session.siwe = message
			req.session.cookie.expires = if message.expirationTime then new Date message.expirationTime else new Date Date.now! + 60 * 60 * 1000 * 24 * 7

			req.session.save do res.send true
		catch e
			E e
			
			req.session.siwe = null
			req.session.nonce = null
			
			res.status(500).send { error: e.message }

	app.get("/me") do(req, res)
		res.header "Cache-Control", "no-cache, no-store, must-revalidate"

		try
			if req.session.siwe then res.send req.session.siwe.address else res.send ""
		catch e
			E e
			res.status(500).send { error: e.message }
	
	app.post("/disconnect") do(req, res)
		res.header "Cache-Control", "no-cache, no-store, must-revalidate"
		
		try
			req.session.siwe = null
			req.session.nonce = null
			
			res.send { message: "user disconnected" }
		catch e
			E e
			res.status(500).send { error: e.message }