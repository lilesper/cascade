tag route-tag
	page
	resolvedPage
	
	def routed do resolvedPage = await page!
  
	<self[w:100% d:vcc]> if resolvedPage then <{resolvedPage} context={route: self.route}>