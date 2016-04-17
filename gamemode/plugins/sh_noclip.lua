--[[
	Author: MadDog (steam id md-maddog)

	TODO:
		- Add server convars to allow admins to always noclip
		- add drag depending on the Presure

]]

local NOCLIP = {
	Name = "Noclip",
	Author = "MadDog",
	Version = 12212015,

	--settings
	CVars = {
		"sb_noclip_admin_enable" = { server = true, text = "Allow Admin Noclip", default = true },
		"sb_noclip_player_enable" = { server = true, text = "Allow Player Noclip", default = true },
	}
}

if ( CLIENT ) then GM:AddPlugin( NOCLIP ) return end

function GM:PlayerNoClip( pl, on ) end --override base gamemode

function NOCLIP:PlayerSpawn(ply)
	ply._enablenoclip = false
end

function NOCLIP:PlayerNoClip( ply, state )
	ply._enablenoclip = state

	return true
end

function NOCLIP:EnterEnvironment( ent, environment ) self:CheckEnvironment( ent ) end
function NOCLIP:LeaveEnvironment( ent, environment ) self:CheckEnvironment( ent ) end

function NOCLIP:CheckEnvironment( ent )
	if ( !IsValid(ent) or !ent:IsPlayer() ) then return end

	local gravity = ent:GetGravity()

	ent:SetWalkSpeed( (200 / ((ent:GetPressure() or 1) * 0.5)) )

	if ( ent._enablenoclip ) then
		ent:SetMoveType( MOVETYPE_NOCLIP )
	elseif ( gravity == 0.00001 ) then
		ent:SetMoveType( MOVETYPE_FLY )
	else
		ent:SetMoveType( MOVETYPE_WALK )
	end
end

GM:AddPlugin( NOCLIP )