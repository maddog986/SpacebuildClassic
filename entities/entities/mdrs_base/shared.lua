ENT.Type 		= "anim"
ENT.Base 		= "base_gmodentity"
ENT.Author  		= "MadDog"
ENT.Spawnable	= false
ENT.AdminSpawnable 	= false

function ENT:IsActive()
	return self:GetNWBool( "Active", false )
end