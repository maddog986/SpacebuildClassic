AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

--fixes stargate stuff
ENT.IgnoreStaff = true
ENT.IgnoreTouch = true
ENT.NotTeleportable = true

function ENT:Initialize()
	self:SetNWInt("Radius", self.radius or RS:GetNumber(self, self.RS.radius))

	self:PhysWake()
	self:SetTrigger( true )
	self:SetNotSolid( true )
	self:SetCollisionBounds( Vector(1, 1, 1) * -self:GetGravityRadius(), Vector(1, 1, 1) * self:GetGravityRadius() )

	self.Entities = {}
	self.Watch = {}
end

function ENT:AddWatch( ent )
	self:RemoveEntity( ent )

	self.Watch[ent:EntIndex()] = ent
end

function ENT:AddEntity( ent )
	self:RemoveWatch( ent )

	self.Entities[ent:EntIndex()] = ent
	ent:AddEnvironment( self )
end

function ENT:RemoveWatch( ent )
	self.Watch[ent:EntIndex()] = nil
	ent:RemoveEnvironment( self )
end

function ENT:RemoveEntity( ent )
	self.Entities[ent:EntIndex()] = nil
	ent:RemoveEnvironment( self )
end

function ENT:StartTouch( ent )
	if (!IsValid(ent) or ent:IsWorld() or ent:IsWeapon()) then return end
	if (self.Entities[ent:EntIndex()]) then return end
	if (ent:GetClass() == "sb_planet") then return end
	if (string.find(ent:GetClass(), "func_")) then return end
	if (string.find(ent:GetClass(), "raw_")) then return end
	if (string.find(ent:GetClass(), "predicted_")) then return end

	--if !table.HasValue(SB:GetClass( "Environments" ):GetEntities(), ent) then return end

	--if (!ent:IsPlayer()) then return end
	--MsgN(self, " StartTouch: ", ent)

	local distance = self:GetPos():Distance(ent:GetPos())

	if (distance > self:GetGravityRadius()) then  --way out of range
		self:RemoveEntity( ent )
	elseif (distance <= self:GetRadius()) then --within planet
		self:AddEntity( ent )
	else
		self:AddWatch( ent )
	end
end

function ENT:EndTouch( ent )
	if (!IsValid(ent) or ent:IsWorld() or ent:IsWeapon()) then return end
	if (ent:GetClass() == "sb_planet") then return end
	if (string.find(ent:GetClass(), "func_")) then return end
	if (string.find(ent:GetClass(), "raw_")) then return end
	if (string.find(ent:GetClass(), "predicted_")) then return end
	--if !table.HasValue(SB:GetClass( "Environments" ):GetEntities(), ent) then return end

	--if (!ent:IsPlayer()) then return end
	--MsgN(self, " EndTouch: ", ent)

	--if (!IsValid(ent) or ent:IsWorld()) then return end --dont want world props
	--if (!self.Entities[ent:EntIndex()] and !self.Watch[ent:EntIndex()]) then return end

	local distance = self:GetPos():Distance(ent:GetPos())

	if (distance <= self:GetRadius()) then --within planet still
		self:AddEntity(ent)
	elseif (distance < self:GetGravityRadius() and distance > self:GetRadius()) then --within gravity radius
		self:AddWatch(ent)
	else --gone for sure
		self:RemoveWatch(ent)
		self:RemoveEntity(ent)
	end
end

function ENT:OnTakeDamage() end --doesnt take damage

function ENT:OnRemove() end

function ENT:Think()
	local entities = ents.FindInSphere(self:GetPos(), self:GetGravityRadius()) --TODO: Add FindInBox for cube environments

	local allents = SB:GetClass( "Environments" ):GetEntities()

	for _, ent in pairs( entities ) do
		if (!IsValid(ent)) then continue end
		local idx = ent:EntIndex()
		if (!self.Entities[idx] and !self.Watch[idx] and allents[idx]) then
			self:StartTouch( ent )
		end
	end

	for idx, ent in pairs( self.Watch ) do
		if (!IsValid(ent)) then self.Entities[idx] = nil; continue end

		self:StartTouch( ent ) --try again
	end

	for idx, ent in pairs( self.Entities ) do
		if (!IsValid(ent)) then self.Entities[idx] = nil; continue end

		local distance = self:GetPos():Distance(ent:GetPos())

		if (distance > self:GetRadius()) then
			self:EndTouch( ent )
		else
			ent:AddEnvironment( self )
		end
	end

	self:NextThink(CurTime() + 0.3)
	return true
end

function ENT:SetEnvironment( data )
	self.environment = table.Copy(data)
	self.default_environment = table.Copy(data)

	self:SetNWBool("SpawnPoint", data.spawnpoint)
	self:SetNWString("Name", data.name)
	self:SetNWInt("Radius", data.radius)

	if data.color then
		self:SetNWVector("mulcol", data.color.mulcol)
		self:SetNWVector("addcol", data.color.addcol)
		self:SetNWFloat("contrast", data.color.contrast)
		self:SetNWVector("color", data.color.color)
		self:SetNWFloat("brightness", data.color.brightness)
	end

	if data.bloom then
		self:SetNWFloat("darken", data.bloom.darken)
		self:SetNWFloat("multiply", data.bloom.multiply)
		self:SetNWFloat("sizex", data.bloom.x)
		self:SetNWFloat("sizey", data.bloom.y)
		self:SetNWFloat("passes", data.bloom.passes)
		self:SetNWVector("bloomcolor", data.bloom.color)
	end
end

function ENT:GetEnvironment()
	return self.environment
end

function ENT:GetOxygen()
	return self.environment.oxygen
end

function ENT:GetAtmosphere()
	return self.environment.atmosphere
end

function ENT:GetLowTemperature()
	return self.environment.lowtemperature
end

function ENT:GetHighTemperature()
	return self.environment.hightemperature
end

function ENT:GetPressure()
	return self.environment.pressure
end

function ENT:GetGravity()
	return self.environment.gravity
end
