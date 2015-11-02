TOOL.Category		= "Life Support"
TOOL.Tab 			= "Spacebuild"
TOOL.Mode			= "resource_tool_energy"
TOOL.Name			= "Resource Tool Energy"
TOOL.Command		= nil
TOOL.ConfigName		= ""

function TOOL:LeftClick( trace )
	--if client exit
	if ( CLIENT ) then return true end

	--if not valid or player, exit
	if ( trace.Entity:IsValid() and trace.Entity:IsPlayer() ) then return end

	if (!trace.Entity.socket_offsets) then return end

	-- If there's no physics object then we can't constraint it!
	if ( !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false end

	--how many objects stored
	local iNum = self:NumObjects() + 1

	--save clicked postion
	self:SetObject( iNum, trace.Entity, trace.HitPos, trace.Entity:GetPhysicsObjectNum( trace.PhysicsBone ), trace.PhysicsBone, trace.HitNormal )

	if (iNum > 1) then
		local Ent1 = self:GetEnt(1) 	--get first ent
		local Ent2 = self:GetEnt(iNum) 	--get last ent

		for name, vector in pairs( Ent1.socket_offsets ) do
			if (Ent2.socket_offsets[name]) then
				Ent1:SetNWEntity("Socket" .. name, Ent2)
				Ent2:SetNWEntity("Socket" .. name, Ent1)
			end
		end

		self:ClearObjects()	--clear objects
	else
		self:SetStage( iNum )
	end

	return true
end

function TOOL:RightClick( trace )

end

function TOOL:Reload( trace )
end