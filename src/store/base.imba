export def logout do await (await window.fetch "/logout", {method: "POST"}).json!
export def nonce do await (await window.fetch "/nonce").text!

export def disconnect do await (await window.fetch "/disconnect", {method: "POST"}).json!

export def me
	try
		await (await window.fetch "/me").text!
	catch e
		E e
		false

export def post url, body
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

export def login data
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

export def create table, data
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
	
export def update table, query, data
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

export def del table, query
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

export def get table, query
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

export def fetch table, query, external
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
