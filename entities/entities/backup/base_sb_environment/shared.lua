ENT.Type = "brush"
ENT.Base = "base_gmodentity"
ENT.PrintName 	= "Base Environment"


function RSGetNumber( ent, value, addition ) --returns a interger from interger or function
	if (type(value) == "function") then value = math.ceil(value(ent)) end --convert function into a value
	return math.ceil((addition or 0) + (value or 0))
end

function ENT:IsPlanet()
	return false
end

function ENT:GetName()
	return self:GetNWString("Name", "Environment")
end

function ENT:GetRadius()
	return RSGetNumber(self, (self.radius or self:GetNWInt("Radius", 0)))
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

function ENT:IsActive()
	return (self:GetNWInt("Active", -1) == -1 or self:GetNWInt("Active", -1) == 1)
end