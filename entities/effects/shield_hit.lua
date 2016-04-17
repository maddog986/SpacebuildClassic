--[[
	Author MadDog
]]
EFFECT.MaterialA = Material( "effects/refract_ring" )
EFFECT.MaterialB = Material( "models/roller/rollermine_glow" )

function EFFECT:Init(data)
	self.Size = 0
	self.AddSize = data:GetScale()
	self.StartSize = math.random(10,20)

	self.Parent = data:GetEntity()
	self.Position = data:GetOrigin()
	self.Normal = data:GetNormal()

	self.Refract = 0
	self.Alpha = 0.8
	self.Color = Color(0,0,200,255)

	local offset = ( self.Parent:LocalToWorld(self.Position) - self.Parent:GetPos())

	self:SetRenderBounds( -1 * offset, offset )

	self.Draw = true
end

function EFFECT:Think()
	if ( !IsValid(self.Parent) ) then return end

	self.Refract = self.Refract + 2 * FrameTime()

	if (self.Refract > 1) then
		self.Alpha = self.Alpha - (FrameTime() / 2)
	end

	self.Size = self.StartSize * self.Refract^(0.2)+self.AddSize

	self:SetPos( self.Parent:LocalToWorld(self.Position) )

	return (self.Draw and self.Alpha > 0)
end

function EFFECT:Render()
	if ( !IsValid(self.Parent) ) then self.Draw = false return end

	self.MaterialA:SetFloat( "$alpha", self.Alpha )
	self.MaterialA:SetFloat( "$refractamount", math.sin(self.Refract * math.pi) * 0.1 )

	render.SetMaterial( self.MaterialA )

	render.UpdateRefractTexture()

	render.DrawQuadEasy( self:GetPos(), self.Normal, self.Size, self.Size, Color(0,0,0,0) )
	render.DrawQuadEasy(self:GetPos(), -1*self.Normal, self.Size, self.Size)

	self.MaterialB:SetVector( "$color", Vector(self.Color.r/255,self.Color.g/255,self.Color.b/255))
	self.MaterialB:SetFloat( "$alpha", math.Clamp(self.Alpha,0,1))

	render.SetMaterial( self.MaterialB )

	render.DrawQuadEasy(self:GetPos(), self.Normal, self.Size*2, self.Size*2)
	render.DrawQuadEasy(self:GetPos(), -1*self.Normal, self.Size*2, self.Size*2)
end