css .modal backdrop-filter:blur(16px) -webkit-backdrop-filter:blur(16px) pos:fixed t:0 r:0 b:0 l:0 d:flex fld:column j:center a:center zi:10

tag modal-tag
	prop open = no
	prop scroll = no
	
	<self>
		if open
			<div.modal[bg:sky5/80% opacity@off:0 ease:.5s expo-out] [pt:20 a:center j:start of:scroll]=scroll @click.self=(open = no; emit "closed") ease>
				<div[pos:relative y@off:32px ease:.5s back-out d:vflex a:center pb:20]>
					<slot>