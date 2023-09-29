const iconModules = import.meta.glob "../../assets/icons/*.svg", as: "raw"

const icons = Object.fromEntries
	(Object.entries iconModules).map do([path, resolver])
		const name = (path.match /\/([^/]+).svg$/)[1]
		[name, resolver]

tag icon-tag
	prop name
	prop size = 24

	def mount
		self.innerHTML = await icons[name]! if name

	<self[w:{size}px h:{size}px d:hcc]>