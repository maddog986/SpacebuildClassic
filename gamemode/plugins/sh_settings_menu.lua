--[[
	Author: MadDog (steam id md-maddog)
]]

if SERVER then 
	hook.Add("ShowHelp", "GamemodeMenuOpen", function( ply )
		ply:SendLua("GamemodeMenu()")
	end)
return end

if ( IsValid(GAMEMODE_MENU) ) then 
	GamemodeMenu()	
end

function GamemodeMenu()
	if ( IsValid(GAMEMODE_MENU) ) then GAMEMODE_MENU:Remove() end

	local MENU = vgui.Create("SBGamemodeSettingsMenu")

	MENU:AddControl({
		tab = "Client Settings",
		text = "Edit the options below to customize your experience.",
		hightlight = true, color = Color(220,255,255,255), bgcolor = Color(0,0,0,120)
	})

	MENU:AddControl({
		tab = "Server Settings",
		text = "Edit the options below to customize your server.",
		hightlight = true, color = Color(220,255,255,255), bgcolor = Color(0,0,0,120)
	})

	for _, plugin in pairs( GAMEMODE._plugins or {} ) do
		for _, setting in pairs( plugin.CVars ) do
			local name = Either( setting.server, "Server", "Client" )

			if ( name == "Server" and !LocalPlayer():IsAdmin() ) then continue end

			MENU:AddTab( name .. " Settings", "icon16/wrench.png" )

			MENU:AddControl({
				tab = name .. " Settings",
				text = "\"" .. plugin.Name .. "\"",
				description = plugin.Description,
				version = plugin.Version,
				author = plugin.Author,
			})

			for _, setting in pairs( vars ) do
				setting.tab = name .. " Settings"

				MENU:AddControl( setting )
			end
		end
	end

	GAMEMODE_MENU = MENU
end