--[[

	Author: MadDog (steam id md-maddog)
	Contact: http://www.facepunch.com/members/145240-MadDog986

]]

include("shared.lua")

GM:Include( "vgui/*" )
GM:Include( "modules/cl_*" )
GM:Include( "derma/*" )


hook.Add( "PopulatePropMenu", "SBMenu", function()
	local contents = {}

	local function PopulateFolder( path )
		local files, folders = file.Find( GAMEMODE.Folder .. "/content/" .. path .. "/*.mdl", "GAME" )

		for k, v in pairs( files ) do
			--MsgN("model: ", path .. "/" .. v)

			table.insert( contents, {
				type = "model",
				model = path .. "/" .. v
			})
		end

		local files, folders = file.Find( GAMEMODE.Folder .. "/content/" .. path .. "/*", "GAME" )

		for k, v in pairs( folders ) do
			table.insert( contents, {
				type = "header",
				text = v
			} )

			PopulateFolder( path .. "/" .. v )
		end
	end

	-- Props
	table.insert( contents, {
		type = "header",
		text = "Props"
	} )

	for k, filepath in pairs( file.Find(GAMEMODE.Folder .. "/content/models/devices/*.mdl", "GAME") ) do
		table.insert( contents, {
			type = "model",
			model = "models/devices/" .. filepath
		})
	end

	PopulateFolder("models/smallbridge")

	spawnmenu.AddPropCategory( "SpacebuildProps", "Spacebuild Models", contents, "icon16/page.png")
end)