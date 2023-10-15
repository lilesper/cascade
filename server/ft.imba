import fetch from "node-fetch"

const ftApi = "https://prod-api.kosetto.com/"


export default do(app)
	app.get("/twitter-ftdata/:address") do(req, res, next)
		try
			const response = await fetch "{ftApi}users/{req.params.address}",
				method: "GET"
				headers:
					"Content-Type": "application/json"
					"Authorization": "Bearer " + process.env.FT_JWT
			const data = await response.json!

			res.send data
		catch e next e