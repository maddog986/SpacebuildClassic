AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

--fixes stargate stuff
ENT.IgnoreStaff = true
ENT.IgnoreTouch = true
ENT.NotTeleportable = true

function ENT:Initialize()
	local rad = self.radius

	if (self.RS && self.RS.radius) then rad = self.RS.radius end
	if (self.Environment && self.Environment.radius) then rad = self.Environment.radius end

	rad = RS:GetNumber(self, rad)

	local radius = Vector( 1,1,1 ) * rad

	self:SetColor( Color(255,255,0,0) ) --hide the model

	self:SetCollisionBounds( radius * -1, radius )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	self:PhysicsInitSphere( radius.x )
	self:SetNotSolid( true )
	self:SetTrigger( true )
	self:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )

	self.Entities = {} --within the environment
	self.Watch = {} --within the gravity of the environment
end

function ENT:AddWatch( ent )
	self:RemoveEntity( ent )
	self.Watch[ent:EntIndex()] = ent
end

function ENT:AddEntity( ent )
	self:RemoveWatch( ent )
	self.Entities[ent:EntIndex()] = ent

	hook.Call("EnterEnvironment", ent, environment )
end

function ENT:RemoveWatch( ent )
	self.Watch[ent:EntIndex()] = nil

	hook.Call("LeaveEnvironment", ent, environment )
end

function ENT:RemoveEntity( ent )
	self.Entities[ent:EntIndex()] = nil
	ent:EnvironmentRemove( self )
end

function ENT:StartTouch( ent )
	if (!IsValid(ent) or ent:IsWorld() or ent:IsWeapon()) then return end
	if (self.Entities[ent:EntIndex()]) then return end
	if (ent:GetClass() == "sb_planet") then return end
	if (string.find(ent:GetClass(), "func_")) then return end
	if (string.find(ent:GetClass(), "raw_")) then return end
	if (string.find(ent:GetClass(), "predicted_")) then return end
	if (!SB:GetClass( "Environments" ):GetEntities()[ent:EntIndex()]) then return end

	local distance = self:GetPos():Distance(ent:GetPos())

	if (distance > self:GetGravityRadius()) then  --way out of range
		self:RemoveEntity( ent )
	elseif (distance <= self:GetRadius()) then --within planet
		self:AddEntity( ent )
	else --keep on eye on entity as its getting closer
		self:AddWatch( ent )
	end
end

function ENT:EndTouch( ent )
	if (!IsValid(ent) or ent:IsWorld() or ent:IsWeapon()) then return end
	if (ent:GetClass() == "sb_planet") then return end
	if (string.find(ent:GetClass(), "func_")) then return end
	if (string.find(ent:GetClass(), "raw_")) then return end
	if (string.find(ent:GetClass(), "predicted_")) then return end
	if (!SB:GetClass( "Environments" ):GetEntities()[ent:EntIndex()]) then return end

	local distance = self:GetPos():Distance(ent:GetPos())
	local radius = self:GetRadius()
	local gravityradius = self:GetGravityRadius()

	if (distance <= self:GetRadius()) then --within planet still
		self:AddEntity(ent)
	elseif (distance <gravityradius and distance > radius) then --within gravity radius
		self:AddWatch(ent)
	else --gone for sure
		self:RemoveWatch(ent)
		self:RemoveEntity(ent)
	end
end

function ENT:OnTakeDamage() end --doesnt take damage

function ENT:OnRemove() end

function ENT:Think()
	if (!SB:GetClass( "Environments" )) then --oops not a sb map so remove!
		self:Remove()
		return
	end

	local allents = SB:GetClass( "Environments" ):GetEntities()

	for _, ent in pairs( ents.FindInSphere(self:GetPos(), self:GetGravityRadius()) ) do
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
			ent:EnvironmentAdd( self )
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
	self:SetName( data.name )
	self:SetRadius( data.radius )

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
	return RSGetNumber(self, self.environment.oxygen)
end

function ENT:GetAtmosphere()
	return RSGetNumber(self, self.environment.atmosphere)
end

function ENT:GetLowTemperature()
	return RSGetNumber(self, self.environment.lowtemperature)
end

function ENT:GetHighTemperature()
	return RSGetNumber(self, self.environment.hightemperature)
end

function ENT:GetPressure()
	return RSGetNumber(self, self.environment.pressure)
end

function ENT:GetGravity()
	return RSGetNumber(self, self.environment.gravity)
end

function ENT:SetRadius( value )
	self.radius = value
	self:SetNWInt("Radius", value)
	self:PhysicsInitSphere( RSGetNumber(self, self:GetGravityRadius()) )
	self:SetCollisionBounds( Vector(1, 1, 1) * -self:GetGravityRadius(), Vector(1, 1, 1) * self:GetGravityRadius() )
end

--save some lag by not sending the client info since this is really only used serverside
--function ENT:UpdateTransmitState()
--	return TRANSMIT_NEVER
--end