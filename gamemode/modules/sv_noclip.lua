local NOCLIP = {}

function NOCLIP:PlayerSpawn(ply)
	ply.backtonoclip = nil
end

function NOCLIP:Think()
	self.NextThink = CurTime() + 0.5

	for _, ply in pairs( player.GetAll() ) do
		if (!IsValid(ply)) then continue end --only players wanted

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

SB:Register( NOCLIP )