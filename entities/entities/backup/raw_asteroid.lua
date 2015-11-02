AddCSLuaFile("raw_asteroid.lua")

ENT.Type 		= "anim"
ENT.Base 		= "base_gmodentity"

ENT.PrintName	= "Asteroid"
ENT.Author	= "MadDog"
ENT.Contact	= ""

if CLIENT then return end

function ENT:Initialize()
	self.BaseClass.Initialize(self)

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	self:SetAngles(Angle(math.random(1, 360), math.random(1, 360), math.random(1, 360)))
	self:SetUnFreezable( true )

	local phys = self:GetPhysicsObject()

	phys:EnableMotion( false )
end

function ENT:OnTakeDamage( damage )

end

ENT.lasteffect = 0

function ENT:PhysicsCollide( data, phy )
	if (self.lasteffect > CurTime()) then return end
	self.lasteffect = CurTime() + 1

	self:SetModelScale( self:GetModelScale() * 0.80, 1 )

	local effectdata = EffectData()

	effectdata:SetOrigin( data.HitPos + data.HitNormal )

	util.Effect( "cball_explode", effectdata )
end