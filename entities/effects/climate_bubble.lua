EFFECT.Material = Material("models/props_combine/portalball001_sheet")

function EFFECT:Init(data)
	self.Parent = data:GetEntity()
	self.Radius = data:GetScale()

	self:SetModel( "models/dav0r/hoverball.mdl" )

	self:SetRenderMode( RENDERMODE_TRANSALPHA )
	self:SetRenderBounds( Vector( -self.Radius, -self.Radius, -self.Radius ), Vector( self.Radius, self.Radius, self.Radius ) )

	self.Size = self.Radius/self:OBBMaxs().z
end

function EFFECT:Think()
	return IsValid(self.Parent)
end

function EFFECT:Render()
	if (!IsValid(self.Parent)) then return end

	self:SetPos(self.Parent:GetPos())

	if (self.Parent:GetActive()) then
		self.tween = math.Approach( self.tween or 0, self.Size, (self.Size/500) )
	else
		self.tween = math.Approach( self.tween or 0, 0, (self.Size/500) )
	end

	render.MaterialOverride( self.Material )

	local mat = Matrix()
	mat:Scale( Vector(self.tween, self.tween, self.tween) )
	mat:SetAngles( self.Parent:GetAngles() )

	self:EnableMatrix( "RenderMultiply", mat )
	self:DrawModel()

	render.MaterialOverride(nil)
end