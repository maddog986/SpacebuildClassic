--[[
	Author: MadDog (steam id md-maddog)
]]
local DEATHVIEW = {
	Name = "Deathview",
	Author = "MadDog",
	Version = 12242015
}

function DEATHVIEW:CalcView(ply, pos, angles, fov)
	local ragdoll = ply:GetRagdollEntity()
	if ( !IsValid(ragdoll) ) then return end

	local eyes = ragdoll:GetAttachment( ragdoll:LookupAttachment( "eyes" ) )
	if ( !eyes ) then return end

	return {
		origin = eyes.Pos,
		angles = eyes.Ang,
		fov = 90
	}
end

function DEATHVIEW:HUDPaint()
	if ( LocalPlayer():Alive() ) then return end

	GAMEMODE:MakeHud({
		name = "DeathHud",
		position = "Center Center",
		enabled = true,
		rows = {
			{text = "You're Dead. Press any key to respawn.", color = Color(255,255,0,255), font = "SBHudBold22"}
		}
	})
end

GM:AddPlugin( DEATHVIEW )