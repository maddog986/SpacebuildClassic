ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName 	= "Base Environment"

function ENT:IsPlanet()
	return false
end

function ENT:GetName()
	return self:GetNWString("Name", "Environment")
end

function ENT:GetRadius()
	return self.radius or self:GetNWInt("Radius", 0)
end

function ENT:GetGravityRadius()
	return self:GetRadius()
end

function ENT:IsSpawnPoint()
	return self:GetNWBool("SpawnPoint", false)
end

function ENT:IsRaining()
	return self:GetNWBool("Raining", false)
end

function ENT:IsSnowing()
	return self:GetNWBool("Snowing", false)
end