--[[

	Author: MadDog (steam id md-maddog)
	Contact: http://www.facepunch.com/members/145240-MadDog986

]]

DEFINE_BASECLASS( "gamemode_sandbox" )

-- Enable realistic fall damage for this gamemode.
game.ConsoleCommand("mp_falldamage 1\n")
game.ConsoleCommand("sbox_godmode 1\n") --TODO: remove before release
game.ConsoleCommand("sv_cheats 1\n") --TODO: remove before release

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

--include the extra stuff
GM:AddFiles( "content/models/*.mdl" )
GM:AddFiles( "content/materials/models/*.vmt" )
GM:AddFiles( "content/materials/spacebuild/*.vmt" )
GM:AddFiles( "content/materials/effects/*.vmt" )
GM:AddFiles( "content/resource/fonts/*" )
GM:AddFiles( "sound/spacebuild/*" )

GM:Include( "modules/sv_*" )

--Removing the cleanup command since it removes things it shouldnt
concommand.Remove( "gmod_admin_cleanup" )
concommand.Add( "gmod_admin_cleanup", function( ply, cmd, args )
	game.CleanUpMap()
end)

if (!game.CleanUpMapOld) then game.CleanUpMapOld = game.CleanUpMap end

function game.CleanUpMap() --reventing the planets from being cleaned up
	game.CleanUpMapOld( false, {"sb_planets","logic_case"} )
end