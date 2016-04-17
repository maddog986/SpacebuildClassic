--[[

	Author: MadDog (steam id md-maddog)
	Contact: http://www.facepunch.com/members/145240-MadDog986

]]

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

DEFINE_BASECLASS( "gamemode_sandbox" )

--Up the PhysSpeed
local PhysSpeed = {}
PhysSpeed.MaxVelocity = 12000
physenv.SetPerformanceSettings(PhysSpeed)

--sb_gooniverse map fix
function GM:InitPostEntity()
	if ( game.GetMap() ~= "sb_gooniverse" ) then return end

	for _, ent in pairs( ents.FindInSphere( Vector(10000, -2610, 10458), 1300 ) ) do
		if ( !table.HasValue({"func_door","prop_dynamic","func_physbox_multiplayer","path_track","func_button","func_tracktrain"}, ent:GetClass()) ) then continue end
		SafeRemoveEntity(ent)
	end
end

--include the extra stuff
--GM:AddFiles( "content/models/*.mdl" )
--GM:AddFiles( "content/materials/models/*.vmt" )
--GM:AddFiles( "content/materials/spacebuild/*.vmt" )
--GM:AddFiles( "content/materials/effects/*.vmt" )
--GM:AddFiles( "content/resource/fonts/*" )
--GM:AddFiles( "sound/spacebuild/*" )

GM:Include( "core/sv_*" )
GM:Include( "plugins/sv_*" )

GM:DebugPrint("----------------------------------------------------------")
GM:DebugPrint("Loading Completed ----")
GM:DebugPrint("----------------------------------------------------------")