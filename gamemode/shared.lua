--[[

	Author: MadDog (steam id md-maddog)
	Contact: http://www.facepunch.com/members/145240-MadDog986

]]

DeriveGamemode("Sandbox")

GM.Name = "Spacebuild Revolution"
GM.Author = "MadDog986"
GM.Website = "http://www.facepunch.com/members/145240-MadDog986"
GM.Version = 1

-- debug
function GM:DebugPrint(...)
	if CLIENT then return end --disable clientside debug for now
	if SERVER then color = Color(245, 255, 154, 255) else color = Color(178, 161, 126, 255) end

	MsgC(color, "--- ", ...)
	MsgC(color, "\n")
end

--loading message
GM:DebugPrint("----------------------------------------------------------")
GM:DebugPrint(GM.Name .. " v" .. GM.Version .. " by " .. GM.Author .. " ----")
if SERVER then GM:DebugPrint("Loading Serverside") else GM:DebugPrint("Loading Clientside") end
GM:DebugPrint("----------------------------------------------------------")

--load all core files
GM:Include( "core/sh_*" )

--adds a folder to download to client
function GM:ContentFolder( path )
	local p = string.match(path, "(.*/)")--:gsub( GM.Folder .. "/gamemode/" , "")
	local files, folders = file.Find( path .. "/*", "GAME" )

	for _, name in pairs( files ) do
		resource.AddFile( p .. name )
	end

	for _, name in pairs( folders ) do
		self:ContentFolder( path .. "/" .. name )
	end
end

--includes files to the script
function GM:Include( path )
	local p = path:match("(.*/)"):gsub( self.Folder .. "/gamemode/" , "")

	for _, fileName in SortedPairs( file.Find(self.Folder .. "/gamemode/" .. path, "GAME") ) do
		self:DebugPrint("file: ", p , fileName)

		if ( fileName:find("sv_") ) then --server only files
			if SERVER then include( p .. fileName ) end
		elseif ( fileName:find("cl_") ) then --clientside only files
			if ( SERVER ) then
				AddCSLuaFile( p .. fileName )
			else
				include( p .. fileName )
			end
		else --all other shared files
			IncludeCS( p .. fileName )
		end
	end
end

--load the modules
GM:Include( "plugins/sh_*" )
GM:Include( "drive/*" )