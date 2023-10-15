tag avatar-tag
	img
	size = 6.5
		
	<self [rd:full w:{size} h:{size}]=img> if img
		<img[w:{size} h:{size} rd:full] src=img @error=(img = null) alt="user avatar">