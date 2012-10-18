include("shared.lua")

ENT.radius = 1

--function ENT:Draw() end

function ENT:Think()
	if (self.radius ~= self:GetNWInt("Radius",1)) then
		self.radius = self:GetNWInt("Radius",1)
		self:SetRenderBounds( Vector(-1, -1, -1) * self.radius, Vector(1, 1, 1) *  self.radius )
	end
end