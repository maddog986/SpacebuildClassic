--[[
	Author: MadDog (steam id md-maddog)

	TODO: finish
]]
AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.PrintName = "Spacebuild Ion Storm"
ENT.Author	= "MadDog"

ENT.Spawnable = false
ENT.AdminOnly = false

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

if CLIENT then return end

AccessorFunc( ENT, "size", "Size", FORCE_NUMBER )

function ENT:Initialize()
	self:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetNoDraw( true )

	self:SetGravity(0.00001)

	local phys = self:GetPhysicsObject()

	if(phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:EnableMotion( false )
	end

	local effect = EffectData()

	effect:SetEntity( self )
	effect:SetOrigin( self:GetPos() )
	effect:SetScale( self:GetSize() )

	util.Effect( "sb_space_cloud", effect )
end

--function ENT:UpdateTransmitState() return TRANSMIT_NEVER end
function ENT:PhysicsSimulate( phys, deltatime ) return SIM_NOTHING end --dont ever move.