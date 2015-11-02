AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

local Ground = 1 + 0 + 2 + 8 + 32

function ENT:Initialize()
	self:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )
	self:SetMaterial("models/debug/debugwhite")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	local hash = { }
		hash.name = "nothing"
		hash.rarity = 3
		hash.yield = 0
	self.resource = hash

	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:SetMass(200)
		phys:Wake()
	end

	timer.Simple(60, function(ent)
		if(ent:IsValid()) then
			ent:Remove()
		end
	end, self)
end

function ENT:PhysicsCollide( data, physobj )
	local hitent = data.HitEntity

	if (!IsValid(hitent) or hitent:IsWorld()) then return end

	local temp = constraint.GetAllConstrainedEntities( hitent )

	for _, ent in pairs( temp ) do
		if (ent:GetClass() == "ore_collector") then

			self:EmitSound( "Rubber.BulletImpact" )
			--RD_SupplyResource(ent, self.resource.name, self.resource.yield)
			self:Remove()

			break
		end
	end
end