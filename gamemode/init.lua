--[[

	Author: MadDog (steam id md-maddog)

]]

AddCSLuaFile("cl_init.lua");
AddCSLuaFile("shared.lua");

include("shared.lua");

for k, v in pairs( file.Find(SB.Folder .. "/gamemode/modules/cl_*", "GAME") ) do
	AddCSLuaFile("modules/"..v);
end

for k, v in pairs( file.Find(SB.Folder .. "/gamemode/modules/sv_*", "GAME") ) do
	include("modules/"..v);
end

--Removing the cleanup command since it removes things it shouldnt
concommand.Remove( "gmod_admin_cleanup" )
concommand.Add( "gmod_admin_cleanup", function( ply, cmd, args )
	print("Cannot use cleanup in this gamemode!")
end)

game.ConsoleCommand("sbox_persist 0") --messes up everything

if (!game.CleanUpMapOld) then game.CleanUpMapOld = game.CleanUpMap end

function game.CleanUpMap()
	game.CleanUpMap(false, {"sb_planets","base_sb_environment"})

end



local meta = FindMetaTable("Player")

function meta:EasyMessage( message, int )
	self:SendLua("SB:SendMessage(\"" .. message .. "\", " .. (int or 1) .. ")")
end