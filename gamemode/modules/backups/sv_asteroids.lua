--[[

	Author: MadDog (steam id md-maddog)

	TODO:
		- Make the asteroids blow up if they take damage.
		- At point point recode so the asteroids release smaller rocks instead of balls of resources
]]

ASTEROIDS = {}
ASTEROIDS.Name = "Asteroids"
ASTEROIDS.Author = "MadDog"
ASTEROIDS.Version = 1

ASTEROIDS.Asteroids = {
	Small = {
		"models/props/cs_militia/militiarock05.mdl",
		"models/props_wasteland/rockgranite02b.mdl",
		"models/props_wasteland/rockgranite02a.mdl",
		"models/props_wasteland/rockcliff01k.mdl"
	},
	Medium = {
		"models/props_wasteland/rockgranite01c.mdl",
		"models/props_wasteland/rockgranite01c.mdl",
		"models/props_wasteland/rockgranite01b.mdl",
		"models/props_wasteland/rockgranite01a.mdl",
		"models/props_wasteland/rockcliff01b.mdl",
		"models/props_wasteland/rockcliff01c.mdl",
		"models/props_wasteland/rockcliff01e.mdl",
		"models/props_wasteland/rockcliff01f.mdl",
		"models/props_wasteland/rockcliff01g.mdl"
	},
	Large = {
		"models/props_wasteland/rockcliff_cluster03c.mdl"
	}
}

--map load
function ASTEROIDS:InitPostEntity()
end

function ASTEROIDS:SpawnAsteroid( model, pos )
	local asteroid = ents.Create( "raw_asteroid" )

	if (!IsValid(asteroid)) then MsgN("raw_asteroid not created"); return end

	asteroid:SetModel( model )
	asteroid:SetPos( pos )
	asteroid:Spawn()
	asteroid:Activate()
	asteroid:SetColor(Color(255,255,200,255))
end

function ASTEROIDS:CreateAsteroidCluster()

	for _, ent in pairs( ents.FindByClass("raw_asteroid") ) do
		ent:Remove()
	end


	local total = math.random(15,30)
	local size = math.random(1000,3000)
	local asteroids = {}

	--get the random models we are about to use
	for var = 0, math.random(15,30) do
		local rnd = math.random(1, 8)
		local models = {}

		if (rnd == 1) then
			models = self.Asteroids.Large
		elseif (rnd >= 2 or rnd <= 4) then
			models = self.Asteroids.Medium
		else
			models = self.Asteroids.Small
		end

		table.insert(asteroids, models[math.random( 1, #models)])
	end

	local found = false
	local trys = 0
	local start = Vector(0,0,0)

	while (found == false and trys < 40) do
		local start = VectorRand()*16384

		if (util.IsInWorld( start )) then
			local trace = util.TraceHull({
				start = start,
				endpos = start,
				min = Vector(-size,-size,-size),
				max = Vector(size, size, size)
			})

			if (trace.Hit) then
				continue
			else
				found = true
			end
		end

		trys = trys + 1
	end

	if (found) then
		for _, model in ipairs( asteroids ) do
			local pos = start + (VectorRand()*size)

			self:SpawnAsteroid( model, pos )

			Entity(1):SetPos(pos)
		end
	end
end

function ASTEROIDS:Think()
	self.NextThink = CurTime() + 10
end

GM:Register( ASTEROIDS )

























if true then return end --disable for now

ASTEROIDS = {}
ASTEROIDS.Name = "Asteroids"
ASTEROIDS.Author = "MadDog"
ASTEROIDS.Version = 1

ASTEROIDS.Asteroids = {
	Small = {
		"models/props/cs_militia/militiarock05.mdl",
		"models/props_wasteland/rockgranite02b.mdl",
		"models/props_wasteland/rockgranite02a.mdl",
		"models/props_wasteland/rockcliff01k.mdl"
	},
	Medium = {
		"models/props_wasteland/rockgranite01c.mdl",
		"models/props_wasteland/rockgranite01c.mdl",
		"models/props_wasteland/rockgranite01b.mdl",
		"models/props_wasteland/rockgranite01a.mdl",
		"models/props_wasteland/rockcliff01b.mdl",
		"models/props_wasteland/rockcliff01c.mdl",
		"models/props_wasteland/rockcliff01e.mdl",
		"models/props_wasteland/rockcliff01f.mdl",
		"models/props_wasteland/rockcliff01g.mdl"
	},
	Large = {
		"models/props_wasteland/rockcliff_cluster03c.mdl"
	}
}

ASTEROIDS.Resources = {}

function ASTEROIDS:InitPostEntity()
	self:RemoveAsteroids()

	self.Resources = {}
	self:AddResource("greenterracrystal", 1)
	self:AddResource("titanium", 2)
	self:AddResource("redterracrystal", 3)

	timer.Simple(10, function()
		ASTEROIDS.Started = true
	end)
end

function ASTEROIDS:AddResource( name, rarity )
	self.Resources[rarity] = self.Resources[rarity] or {}
	table.insert(self.Resources[rarity], name)
end

function ASTEROIDS:GetResource(rarity)
	return table.Random(self.Resources[rarity])
end

function ASTEROIDS:SpawnAsteroid( model, pos )
	if (!util.IsValidModel( model )) then MsgN("Asteroid model not valid!"); return end

	local asteroid = ents.Create( "raw_asteroid" )

	if (!IsValid(asteroid)) then MsgN("raw_asteroid not created"); return end

	asteroid:SetModel( model )
	asteroid:SetPos( pos )
	asteroid:Spawn()
	asteroid:Activate()
	asteroid:SetColor(Color(255,255,200,255))
end

function ASTEROIDS:RemoveAsteroids()
	for _, ent in pairs( ents.FindByClass("raw_asteroid") ) do
		ent:Remove()
	end

	for _, ent in pairs( ents.FindByClass("raw_resource") ) do
		ent:Remove()
	end
end

function ASTEROIDS:ResetAsteroids()
	self:RemoveAsteroids()
	self:CreateRandomAsteroidCluster()
end

function ASTEROIDS:Think()
	self.NextThink = CurTime() + 10

	if (!self.Started) then return end --hasnt started up yet

	if (#ents.FindByClass("raw_asteroid") <= 5) then
		for var = 0, math.random(2, 4) do --for fields
			self:CreateRandomAsteroidCluster()
		end
	end
end

function ASTEROIDS:CreateRandomAsteroidCluster()
	local radius = math.random(2000, 5000)
	local volume = self:AllocateVolume(radius)
	local start = volume.pos

	for var = 0, math.random(15,30) do
		local radius = math.random(1000, 3000)
		local pos = start + (VectorRand()*radius)
		local model = table.Random(table.Random(self.Asteroids))

		if (SB_OnEnvironment and SB_OnEnvironment(pos)) then MsgN("cant spawn in planet"); continue end
		if (GAMEMODE:GetClass( "Environments" ).OnPlanet(pos)) then continue end
		if !util.IsInWorld(pos) then continue end

		timer.Simple(var * 0.1, function()
			ASTEROIDS:SpawnAsteroid(model, pos)
		end)
	end
end

function ASTEROIDS:AllocateVolume( radius )
	local tries = 10
	local pos = Vector(0, 0, 0)
	local hash = {}
	local found = 0
	while ( ( found == 0 ) and ( tries > 0 ) ) do
		tries = tries - 1
		pos = VectorRand()*16384
		if (util.IsInWorld( pos ) == true) then
			found = 1
			if (found == 1) then
				if SB_OnEnvironment and SB_OnEnvironment(pos, nil, radius + 16) then
					found = 0
				end
			end
			if (found == 1) then
				local edges = {
					pos+(Vector(1, 0, 0)*radius),
					pos+(Vector(0, 1, 0)*radius),
					pos+(Vector(0, 0, 1)*radius),
					pos+(Vector(-1, 0, 0)*radius),
					pos+(Vector(0, -1, 0)*radius),
					pos+(Vector(0, 0, -1)*radius)
				}
				local trace = {}
				trace.start = pos
				for _, edge in pairs( edges ) do
					trace.endpos = edge
					trace.filter = { }
					local tr = util.TraceLine( trace )
					if (tr.Hit) then
						found = 0
						break
					end
				end
			end
		end
		if (tries > 0) then
			hash.pos = pos
			hash.num = 1
		else
			hash.pos = Vector(0, 0, 0)
			hash.num = 0
		end
		return hash
	end
end



local function CreateRandomAsteroidCluster( ply, cmd, args )
	if ply:IsAdmin() then ASTEROIDS:CreateRandomAsteroidCluster() end
end
concommand.Add("sb_asteroid_random_cluster", CreateRandomAsteroidCluster)

local function RemoveAsteroids( ply, cmd, args )
	if ply:IsAdmin() then ASTEROIDS:RemoveAsteroids() end
end
concommand.Add("sb_asteroid_clear", RemoveAsteroids)

local function ResetAsteroids( ply, cmd, args )
	if ply:IsAdmin() then ASTEROIDS:ResetAsteroids() end
end
concommand.Add("sb_asteroid_reset", ResetAsteroids)



local function AsteriodPhysGravGunPickup(ply, ent)
	if(!IsValid(ent)) then return end
	if (ent.IsAsteroid) then return false end
end
hook.Add("GravGunPunt", "AsteriodGravGunPunt", AsteriodPhysGravGunPickup)
hook.Add("GravGunPickupAllowed", "AsteriodGravGunPickupAllowed", AsteriodPhysGravGunPickup)
hook.Add("PhysgunPickup", "AsteriodPhysgunPickup", AsteriodPhysGravGunPickup)

local function AsteriodCanTool(ply, tr, toolgun)
	if(tr.HitWorld) then return end
	local ent = tr.Entity
	if(!IsValid(ent)) then return end
	if (ent.IsAsteroid) then
		return ply:IsAdmin()
	end
end
hook.Add("CanTool", "AsteriodCanTool", AsteriodCanTool)
