ENT.Type = "anim"
ENT.Base = "base_sb_environment"
ENT.PrintName = "Planet Environment"

function ENT:IsPlanet()
	return true
end

function ENT:IsWorld() return true end --fake it so hopefully it disables things like stargates and pewpew

function ENT:GetGravityRadius()
	return self:GetRadius() * 1.8
end

function ENT:IsActive()
	return true
end