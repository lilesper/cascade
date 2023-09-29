tag tip-tag
	prop text
	prop bg = "cooler1"
	prop c = "cooler4"
	prop show? = no
	prop align
	prop width

	<self @mouseenter=(show? = yes) @mouseleave=(show? = no)>
		<div.circle[bg:{bg} c:{c} pos:relative d:flex j:center a:center]>
			<icon-tag size=18 name="info-circle">
			if show?
				<div.card[pos:absolute y:-4px b:100% bg:cooler9 fw:500 c:cooler0 px:2 rd:8px py:1 y@off:-0px o@off:0 ease:.5s expo-out] [r:-32px]=(align == "right") [l:-32px]=(align == "left") ease>
					<div[ease:.5s back-out s@off:0.9 fs:14px] [w:width]=width>
						<slot>