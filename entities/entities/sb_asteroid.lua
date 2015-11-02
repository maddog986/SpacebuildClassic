--[[
	Author: MadDog (steam id md-maddog)

	TODO: finish
]]
AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.PrintName = "Spacebuild Asteroid"
ENT.Author	= "MadDog"

ENT.Spawnable = false
ENT.AdminOnly = false

function ENT:Initialize()
	self:SetModel( "models/props_wasteland/rockgranite04b.mdl" )

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	self:SetGravity(0.00001)

	local phys = self:GetPhysicsObject()

	if(phys:IsValid()) then
		phys:Wake()
		phys:SetMass(2000)
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:EnableMotion( false )
	end

	self:SetModelScale( math.random(0.5, 5) )
end