--[[
	Author: MadDog (steam id md-maddog)

	TODO: finish
]]
ASTEROIDS = {}
ASTEROIDS.Name = "Asteroids"
ASTEROIDS.Author = "MadDog"
ASTEROIDS.Version = 1
ASTEROIDS.Ignore = "sb_asteroid"
ASTEROIDS.Size = 4000
ASTEROIDS.Clusters = 3

function ASTEROIDS:PhysgunPickup( ply , ent )
	if table.HasValue(self.Ignore, ent:GetClass()) then
		return false
	end
end

function ASTEROIDS:InitPostEntity( )
	for _, ent in pairs( ents.FindByClass("sb_asteroid") ) do
		ent:Remove()
	end

	for variable = 0, self.Clusters, 1 do
		self:SpawnCluster()
	end
end

function ASTEROIDS:SpawnCluster()
	local pos = self:FindEmptySpace()
	if (!pos) then return end

	for variable = 0, math.Round(self.Size/50), 1 do --try 100 times to find a good spot
		local newpos = pos + Vector(math.random(-self.Size-400, self.Size-400), math.random(-self.Size-400, self.Size-400), math.random(-self.Size-400, self.Size-400))

		if !util.IsInWorld(newpos) then continue end

		local asteroid = ents.Create( "sb_asteroid" )
		asteroid:SetPos( newpos )
		asteroid:SetAngles(Angle(math.random(1, 360), math.random(1, 360), math.random(1, 360)))
		asteroid:Spawn()
	end
end

function ASTEROIDS:FindEmptySpace()
	for variable = 0, 100, 1 do --try 100 times to find a good spot
		local pos = self:GetNewPos()
		local ents = ents.FindInSphere( pos, self.Size )

		if #ents == 0 then
			return pos
		end
	end
end

function ASTEROIDS:GetNewPos()
	while true do
		local pos = self:RandomXYZ()

		if util.IsInWorld(pos) then
			return pos
		end
	end
end

function ASTEROIDS:RandomXYZ()
	local x = math.random(-15000, 15000)
	local y = math.random(-15000, 15000)
	local z = math.random(-15000, 15000)

	return Vector(x, y, z)
end