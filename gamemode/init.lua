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

local meta = FindMetaTable("Player")

function meta:EasyMessage( message, int )
	self:SendLua("SB:SendMessage(\"" .. message .. "\", " .. (int or 1) .. ")")
end