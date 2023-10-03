export const base =
	logout: do
		await (await window.fetch "/logout", {method: "POST"}).json!
	
	nonce: do
		await (await window.fetch "/nonce").text!

	disconnect: do
		await (await window.fetch "/disconnect", {method: "POST"}).json!
	
	post: do(url, body)
		try
			const res = await window.fetch url,
				method: "POST"
				mode: "same-origin"
				headers: {"Content-Type": "application/json"}
				body: JSON.stringify body

			await res.text!
		catch e
			E e
			false

	login: do(data)
		try
			const res = await window.fetch "/verify",
				method: "POST"
				mode: "same-origin"
				headers: {"Content-Type": "application/json"}
				body: JSON.stringify data

			await res.text!
		catch e
			E e
			false

	create: do(table, data)
		try
			await (await window.fetch "/create",
				method: "POST"
				mode: "same-origin"
				headers:
					"Content-Type": "application/json"
				body: JSON.stringify {table, data}).json!
		catch e
			E e
			false
	
	update: do(table, query, data)
		try	
			await (await window.fetch "/update",
				method: "POST"
				mode: "same-origin"
				headers:
					"Content-Type": "application/json"
				body: JSON.stringify {table, data, query}).json!
		catch e
			E e
			false

	del: do(table, query)
		try
			await window.fetch "/delete",
				method: "POST"
				mode: "same-origin"
				headers:
					"Content-Type": "application/json"
				body: JSON.stringify {table, query}
		catch e
			E e
			false

	get: do(table, query)
		try
			await (await window.fetch "/get",
				method: "POST"
				mode: "same-origin"
				headers:
					"Content-Type": "application/json"
				body: JSON.stringify {table, query}).json!
		catch e
			E e
			false

	query: do(table, query, external)
		try
			await (await window.fetch (if external then "/trades" else "/fetch"),
				method: "POST"
				mode: "same-origin"
				headers:
					"Content-Type": "application/json"
				body: JSON.stringify {table, query}).json!
		catch e
			E e
			false

	fetch: do(url)
		try
			await (await window.fetch url).json!
		catch e
			E e
			false
