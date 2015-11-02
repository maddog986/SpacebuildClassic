--[[
	Author: MadDog (steam id md-maddog)

	TODO:
		- Add server convars to allow admins to always noclip
]]
local NOCLIP = {}
NOCLIP.Name = "Noclip"
NOCLIP.Author = "MadDog"
NOCLIP.Version = 1

function NOCLIP:PlayerSpawn(ply)
	ply._enablenoclip = false
end

function NOCLIP:PlayerNoClip( ply )
	ply._enablenoclip = !ply._enablenoclip

	return ply._enablenoclip
end

function NOCLIP:EnterEnvironment( ent, environment )
	self:CheckEnvironment( ent )
end

function NOCLIP:LeaveEnvironment( ent, environment )
	self:CheckEnvironment( ent )
end

function NOCLIP:CheckEnvironment( ent )
	if (ply._enablenoclip) then
		ply:SetMoveType( MOVETYPE_NOCLIP )
		return
	end

	local gravity = ply:GetGravity()

	if (gravity == 0) then
		ply:SetMoveType( MOVETYPE_FLY )
	else
		ply:SetMoveType( MOVETYPE_WALK )
		ply:SetWalkSpeed( (200 / (ply:GetPressure() * 0.5)) )
	end
end


--[[
function NOCLIP:Think()
	self.NextThink = CurTime() + 0.5

	for _, ply in pairs( player.GetAll() ) do
		if (!IsValid(ply)) then continue end --player left

		local gravity = ply:GetGravity()

		if (gravity < 0.001) then
			if (ply:GetMoveType() == MOVETYPE_NOCLIP) then ply.backtonoclip = true end

			ply:SetMoveType( MOVETYPE_FLY )
		elseif ply:GetMoveType() == MOVETYPE_FLY then
			if (ply.backtonoclip) then
				ply:SetMoveType( MOVETYPE_NOCLIP)
				ply.backtonoclip = nil
			else
				ply:SetMoveType( MOVETYPE_WALK)
			end
		end
	end
end
]]
GM:Register( NOCLIP )