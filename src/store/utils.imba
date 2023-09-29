export def waitForElm selector, parent
	new Promise do(resolve)
		const elm = if parent then parent else document
		if elm.querySelector selector
			resolve elm.querySelector selector
		const observer = new MutationObserver do(mutations)
			if elm.querySelector selector
				resolve elm.querySelector selector
				observer.disconnect!
		observer.observe elm,
			childList: true
			subtree: true

export def errorHandler e, args
	const red = "\x1b[31m"
	const redBg = "\x1b[41m"
	const white = "\x1b[97m"
	const reset = "\x1b[0m"
	const message = e.message

	console.log "{red}::{reset} {redBg}{white} error {reset}{red} {message}{reset}"
	console.log args if args
	console.log e