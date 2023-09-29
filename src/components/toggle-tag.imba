tag toggle-tag
	on = no
	loading = no
	reverse = no

	<self[d:hcl] [fld:row-reverse]=reverse>
		if loading
			<icon-tag.spin[c:cooler4 mr:1] name="loading-03">
		else
			<div[rd:100px h:24px w:40px shadow:inner mr:2 bg:cooler2 bg@hover:cooler3 cursor:pointer] [mr:0 ml:2]=reverse [bg:green5 bg@hover:green6]=on>
				<div [x:16px]=on [m:2px w:20px h:20px rd:100px bg:white shadow:sm]>
	
		<div[fw:600 fs:sm c:cooler5 flg:1]>
			<slot>