--[[
	Author MadDog

	Credit: Effects/Materials taken from Stargate/CAP.
]]
EFFECT.MaterialA = Material( "effects/shielda" )
EFFECT.MaterialB = Material( "effects/shieldb" )

function EFFECT:Init(data)
	self.Entity = data:GetEntity()
	self.Size = 0
	self.Flags = data:GetFlags()

	if ( self.Flags == BRUSH_BOX ) then
		self:SetModel( "models/hunter/blocks/cube025x025x025.mdl" ) --box
	else --default shape
		self:SetModel( "models/dav0r/hoverball.mdl" ) --sphere
	end

	self:SetColor( Color(0,0,200,255) )
	self:SetRenderMode( RENDERMODE_TRANSALPHA )
	self:SetRenderBounds( Vector(1,1,1) * -2000, Vector(1,1,1) * 2000 )

	self.Draw = true
end

function EFFECT:Think()
	if ( !IsValid(self.Entity) ) then return end

	local maxsize = self.Entity:GetEffectSize() / self:OBBMax().x

	self:SetPos( self.Entity:GetPos() )
	self.Size = LerpVector( RealFrameTime(), self.Size, Either(self.Entity:GetActive(), maxsize, 0) )

	local mat = Matrix()
	mat:Scale( Vector(self.Size, self.Size, self.Size) )
	mat:SetAngles( self.Entity:GetAngles() )

	self:EnableMatrix( "RenderMultiply", mat )

	return self.Draw
end

function EFFECT:Render()
	if ( !IsValid(self.Entity) ) then self.Draw = false return end

	render.MaterialOverride( self.MaterialA )
	self:DrawModel()
	render.MaterialOverride( self.MaterialB )
	self:DrawModel()
	render.MaterialOverride(nil)
end