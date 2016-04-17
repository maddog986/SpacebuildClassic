--[[
	Author: MadDog (steam id md-maddog)

	This brush point is required since touch functions are funky at best.
	Trying to setup proper touch based events.
]]
AddCSLuaFile()

DEFINE_BASECLASS( "sb_brush_base" ) --use should use brush, but we want this to be clientside sometimes

ENT.IgnoreDamage = true

--[[ Client Side ]]
if CLIENT then
	ENT.MaterialA = Material( "effects/shielda" )
	ENT.MaterialB = Material( "effects/shieldb" )

	function ENT:Draw()
		local size = self:GetSize()

		self:SetModelScale( (size / 6.2119002342224) + 4 )

		self:SetRenderBounds( vector_one * -size, vector_one * size )

		render.MaterialOverride( self.MaterialA )
		self:DrawModel()
		render.MaterialOverride( self.MaterialB )
		self:DrawModel()
		render.MaterialOverride( nil )
	end

	function ENT:GetSize()
		return self:GetNWInt("Size", 0)
	end
return end

function ENT:UpdateTransmitState() return TRANSMIT_PVS end

function ENT:SetSize( size )
	BaseClass.SetSize( self, size )

	self:SetNWInt("Size", size)
end