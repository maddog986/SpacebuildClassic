--[[
	Author: MadDog (steam id md-maddog)

	TODO: finish
]]
AddCSLuaFile()

DEFINE_BASECLASS( "base_entity" )

ENT.PrintName = "Spacebuild Asteroid"
ENT.Author	= "MadDog"
ENT.Spawnable = false
ENT.AdminOnly = false

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
return end

function ENT:Initialize()
	local models = {
		"models/props_wasteland/rockgranite04b.mdl",
		--"models/mandrac/asteroid/crystal1.mdl","models/mandrac/asteroid/crystal2.mdl","models/mandrac/asteroid/crystal3.mdl","models/mandrac/asteroid/crystal4.mdl",
		--"models/mandrac/asteroid/geode1.mdl","models/mandrac/asteroid/geode2.mdl","models/mandrac/asteroid/geode3.mdl","models/mandrac/asteroid/geode4.mdl",
		--"models/mandrac/asteroid/pyroxveld1.mdl","models/mandrac/asteroid/pyroxveld2.mdl","models/mandrac/asteroid/pyroxveld3.mdl","models/mandrac/asteroid/pyroxveld4.mdl",
		--"models/mandrac/asteroid/rock5.mdl","models/mandrac/asteroid/rock2.mdl","models/mandrac/asteroid/rock3.mdl","models/mandrac/asteroid/rock4.mdl"
	}

	self:SetModel( table.Random(models) )

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )

	self:SetGravity(0.00001)

	local phys = self:GetPhysicsObject()

	if(phys:IsValid()) then
		phys:Wake()
		phys:SetMass( 2000 )
		phys:EnableGravity( false )
		phys:EnableDrag( false )
		phys:EnableMotion( false )
	end
end

function ENT:CanTool() return false end
function ENT:GravGunPunt() return false end
function ENT:GravGunPickupAllowed() return false end
function ENT:PhysgunPickup() return false end

function ENT:OnTakeDamage( dmg )
	local damage = dmg:GetDamage() * 0.01
	local scale = self:GetModelScale()
	local newscale = math.Clamp((scale - damage), 0, 10)

	if (newscale <= 0) then
		local effectdata = EffectData()
		effectdata:SetStart( dmg:GetDamagePosition() )
		effectdata:SetOrigin( dmg:GetDamagePosition() )
		effectdata:SetScale(1)
		util.Effect("Explosion", effectdata)

		self:Remove()
	return end

	local effectdata = EffectData()
	effectdata:SetOrigin( dmg:GetDamagePosition() )
	util.Effect( "cball_explode", effectdata )

	self:SetModelScale( newscale )
end