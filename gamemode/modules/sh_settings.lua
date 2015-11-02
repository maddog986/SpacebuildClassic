OPTIONS:RegisterTab({ name = "Player Settings", icon = "icon16/wrench.png"})
OPTIONS:RegisterTab({ name = "Framework Settings", icon = "icon16/wrench.png", admin = true})
OPTIONS:RegisterTab({ name = "Help", icon = "icon16/help.png"})

--[[
	FRAME WORK SETTINGS
]]
OPTIONS:Register({
	tab = "Framework Settings",
	name = "Allow Damage on Spawn Planet",
	var = "spawndamage",
	type = "checkbox",
	level = "server",
	default = 1,
	admin = true
})

OPTIONS:Register({
	tab = "Framework Settings",
	name = "Environments Update Interval",
	var = "environmentsupdate",
	type = "slider",
	min = 0.1,
	max = 1,
	decimal = 1,
	level = "server",
	default = 1,
	admin = true
})


--[[
	PLAYER OPTIONS
]]
OPTIONS:Register({
	tab = "Player Settings",
	name = "Enable Planet Blooms",
	var = "planetblooms",
	type = "checkbox",
	default = 1
})

OPTIONS:Register({
	tab = "Player Settings",
	name = "Enable Planet Colors",
	var = "planetcolors",
	type = "checkbox",
	default = 1
})

OPTIONS:Register({
	tab = "Player Settings",
	name = "Enable Sun Rays",
	var = "sunrays",
	type = "checkbox",
	default = 1
})


OPTIONS:Register({
	tab = "Player Settings",
	name = "Ambient Sound Level",
	var = "soundlevel",
	type = "slider",
	min = 0,
	max = 100,
	default = 50
})

OPTIONS:Register({
	tab = "Player Settings",
	name = "Rain Effects Level",
	var = "rainintense",
	type = "slider",
	min = 0,
	max = 3000,
	default = 1000
})

OPTIONS:Register({
	tab = "Player Settings",
	name = "Snow Effects Level",
	var = "snowintense",
	type = "slider",
	min = 0,
	max = 3000,
	default = 1000
})

OPTIONS:Register({
	tab = "Player Settings",
	name = "Hud Disappear Time In Seconds",
	var = "hudtimeout",
	type = "slider",
	min = 0,
	max = 300,
	default = 150
})

OPTIONS:Register({
	tab = "Player Settings",
	name = "HUD (Heads Up Display) Position",
	var = "hudposition",
	type = "list",
	list = {"Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"},
	default = 1
})

OPTIONS:Register({
	tab = "Player Settings",
	name = "Suit Hud Disappear Time In Seconds",
	var = "suittimeout",
	type = "slider",
	min = 0,
	max = 300,
	default = 150
})

OPTIONS:Register({
	tab = "Player Settings",
	name = "Suit HUD (Heads Up Display) Position",
	var = "suitposition",
	type = "list",
	list = {"Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"},
	default = 1
})


