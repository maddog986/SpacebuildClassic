--[[
	Author: MadDog (steam id md-maddog)

	TODO: finish
]]
local ASTEROIDS = {
	--plugin info
	Name = "Asteroids",
	Description = "Random asteroid placing in space. Can be used to gather resources.",
	Author = "MadDog",
	Version = 12222015,

	--settings
	CVars = {
		"sb_asteroids_enable" = { server = true, text = "Enable Asteroids", default = true },
		"sb_asteroids_clusters" = { server = true, text = "Asteroid Clusters", default = 3, min = 0, max = 10, decimals = 0 },
		"sb_asteroids_cluster_min" = { server = true, text = "Asteroid Cluster Min Size", default = 2000, min = 500, max = 2000, decimals = 0 },
		"sb_asteroids_cluster_max" = { server = true, text = "Asteroid Cluster Max Size", default = 5000, min = 500, max = 5000, decimals = 0 },
	}
}

function ASTEROIDS:PhysgunPickup( ply , ent )
	if ( ent:GetClass() == "sb_asteroid" ) then
		return false
	end
end

if CLIENT then GM:AddPlugin(ASTEROIDS) return end

function ASTEROIDS:Startup()
	self:InitPostEntity()
end

function ASTEROIDS:ShutDown()
	utilx.RemoveAllByClass("sb_asteroid")
end

function ASTEROIDS:InitPostEntity( )
	utilx.RemoveAllByClass("sb_asteroid")

	if ( !self:IsActive() ) then return end

	for variable = 0, self:GetSetting("sb_asteroids_clusters"), 1 do
		self:SpawnSpaceCluster( math.random(self:GetSetting("sb_asteroids_cluster_min"), self:GetSetting("sb_asteroids_cluster_max")) )
	end

	--for _, ent in pairs( ents.FindByClass("sb_planet") ) do
	--	self:SpawnPlanetCluster( ent )
	--end

	MsgN("Asteroids: ", #ents.FindByClass( "sb_asteroid" ))
end

function ASTEROIDS:SpawnPlanetCluster( ent )
	local pos = ent:GetPos()
	local size = ent:GetSize()
	local amount = math.Clamp(math.Round(size / 100), 5, 50)
	local ang = 0

	for variable = 0, amount, 1 do

		local pos = Vector(
			(math.cos(variable) * size) + pos.x,
			(math.sin(-variable) * size) + pos.y,
			(math.cos(variable) * size) + pos.z)

		--local newpos = pos-- + Vector(math.random(-size-200, size-200), math.random(-size-200, size-200), math.random(200, size-200))

		local a = variable
		local b = variable*variable
		pos.x = pos.x + math.sin(b)*math.sin(a)*size
		pos.y = pos.y + math.sin(b)*math.cos(a)*size
		pos.z = pos.z + math.cos(b)*size

		if !util.IsInWorld(pos) then continue end


		--if (newpos:Distance(pos) > ent:GetSize()) then continue end --no within planet
--[[
		local tr = util.TraceLine({
			start = newpos,
			endpos = newpos + Vector(0,0,-size)
		})

		if (tr.Hit) then newpos = tr.HitPos end
]]
		local asteroid = ents.Create( "sb_asteroid" )
		asteroid:SetPos( pos )
		asteroid:SetAngles( AngleRand() )
		asteroid:Spawn()
		asteroid:Activate()
		asteroid:SetModelScale( math.random(1, 2) )
	end
end

function ASTEROIDS:SpawnSpaceCluster( size )
	local pos = utilx.RandomEmptyPosition( size )
	if (!pos) then MsgN("Could not spawn space cluster!") return end

	local amount = math.Clamp(math.Round(size / 60), 10, 150)

	MsgN("asteroid field: ", size, "-", amount)

	for variable = 0, amount, 1 do
		local newpos = pos + (VectorRand() * size)

		if !util.IsInWorld(newpos) then continue end

		local asteroid = ents.Create( "sb_asteroid" )
		asteroid:SetPos( newpos )
		asteroid:SetAngles( AngleRand() )
		asteroid:Spawn()
		asteroid:Activate()
		asteroid:SetModelScale( math.random(1, 5) )
	end
end

GM:AddPlugin(ASTEROIDS)