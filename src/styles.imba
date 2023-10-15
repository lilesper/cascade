import "../assets/css/satoshi.css"

global css @root
	*
		transition: all 0.5s expo-out
		-webkit-font-smoothing: antialiased
		-moz-osx-font-smoothing: grayscale
		box-sizing: border-box

	body m:0 ff:Satoshi-Variable fs:6 lh:1.5 c:cooler7 cursor:default bg:sky5 fw:500
	svg, svg path color:inherit
	a td:none
	label d:block fs:3 fw:600 c:cooler5 mb:0 tt:capitalize pos:relative
	.label pos:absolute t:2 l:3
	input[type=number] appearance:none
	input::-webkit-outer-spin-button, input::-webkit-inner-spin-button -webkit-appearance:none appearance:none margin: 0
	button, .button, input, textarea, select c:cooler9 -webkit-appearance:none appearance:none bd:0 rd:20px fs:6 ff:Satoshi-Variable shadow:inner m:0 fw:500 px:2 py:1 fw:600
		@placeholder c:cooler4
		@focus
			outline: none
			bs: 0 0 0 3px rgba(66, 153, 225, 0.5)
	button, .button m:0 cursor:pointer rd:100px fw:600 d:flex j:center a:center ws:nowrap bg:sky7 bg@hover:sky8
	input, textarea, select pt:7 pb:3 px:3 mb:0 bg:cooler0
	textarea mb:0
	.help-text h:0 y:-24px fs:2 c:cooler4 mb:2 pos:relative pl:3
	input.has-help pb:6
	icon.select pos:absolute r:6 t:7
	.unit float:right pos:relative fs:6 c:cooler4 fw:600 mt:-9
	.disabled o:50% cursor:not-allowed pe:none
	.tab-container p:1 shadow:inner rd:full d:inline-flex
		div px:2 py:.5 rd:full cursor:pointer
	p, h1, h2, h3, h4, h5 m:0
	.tag px:1 rd:lg
	.splash pos:fixed zi:12 t:0 l:0 r:0 b:0 d:flex j:center a:center max-width:100% bg:sky5
	.card bg:white rd:32px shadow:xl
	.card-header d:flex ai:center
	.card.has-chart background-image:linear-gradient(0deg, violet1, white 70%)
	.circle w:6 h:6 rd:100px ai:center jc:center fw:900 d:flex fs:12px m:0 shadow:inner
	.spin animation: spin 3s linear infinite
	@keyframes spin 
		from transform: rotate(0deg) 
		to transform: rotate(360deg)
	
	.glow animation: glow 1s linear infinite
	@keyframes glow 
		from bgc: violet4/70
		to bgc: violet4/0
	

	.marquee
		overflow: hidden
		display: flex
		width: 100%

	.marquee.marquee-left .marquee-inner
		-webkit-animation: marquee-left 40s linear infinite
		animation: marquee-left 40s linear infinite
			
	.marquee.marquee-right .marquee-inner
		-webkit-animation: marquee-right 40s linear infinite
		animation: marquee-right 40s linear infinite

	marquee-inner 
		flex-shrink:0
		display: flex
		align-items: center
		width: -webkit-fit-content
		width: -moz-fit-content
		width: fit-content
		will-change: transform

	.marquee-content
		display: inline-block
		white-space: nowrap
	
	@keyframes marquee-left
		0% transform: translate3d(0, 0, 0)
		100% transform: translate3d(-100%, 0, 0)

	@keyframes marquee-right
		0% transform: translate3d(-100%, 0, 0)
		100% transform: translate3d(0%, 0, 0)
