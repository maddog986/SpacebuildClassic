--[[
	Author: MadDog (steam id md-maddog)
]]
function AddContentFolderToSpawn( name, path, cutpath )
	local contents = {}

	local function PopulateFolder( path, replace )
		local files, folders = file.Find( path .. "/*", "GAME" )

		for k, v in pairs( files ) do
			if ( !v:find(".mdl") ) then continue end

			table.insert( contents, {
				type = "model",
				model = (path .. "/" .. v):gsub( replace , "")
			})
		end

		local files, folders = file.Find( path .. "/*", "GAME" )

		for k, v in pairs( folders ) do
			table.insert( contents, {
				type = "header",
				text = v
			})
			PopulateFolder( path .. "/" .. v, replace )
		end
	end
--[[
	-- Props
	table.insert( contents, {
		type = "header",
		text = "Props"
	} )

	for k, filepath in pairs( file.Find(file.Find( "addons/cap_resources/models/*.mdl", "GAME" ), "GAME") ) do
		table.insert( contents, {
			type = "model",
			model = "models/" .. filepath
		})
	end
]]
	PopulateFolder( path, cutpath)

	spawnmenu.AddPropCategory( name:gsub(" ", ""), name, contents, "icon16/page.png")
end

hook.Add( "PopulatePropMenu", "SBMenu", function()
	AddContentFolderToSpawn( "SmallBridge Models", GAMEMODE.Folder .. "/content/models/smallbridge", GAMEMODE.Folder .. "/content/" )

	AddContentFolderToSpawn( "Stargate Models", "addons/cap_resources/models", "addons/cap_resources/" )
end)