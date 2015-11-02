--[[

	Author: MadDog (steam id md-maddog)

	TODO:
		- add a Fahrenheit or Celcius option
		- add blooms and colors to planets
		- reduce color blooms when planets are terra formed
		- on terraformed planets disable entities: env_smokestack, func_dustcloud
		- add planet ambient sounds
]]

local ValidEntity = ValidEntity
local Color = Color
local math = math
local type = type
local data = data
local table = table
local pairs = pairs
local net = net

ENVIRONMENTS = {
	Name = "Environments",
	Author = "MadDog",
	Version = 1
}

function ENVIRONMENTS:GetDefaultEnvironment()
	return {gravity = 1, pressure = 1, oxygen = 100, atmosphere = 1, temperature = 288, lowtemperature = 288, hightemperature = 288}
end

function ENVIRONMENTS:GetSpaceEnvironment()
	return {gravity = 0, pressure = 0, oxygen = 0, atmosphere = 0, temperature = 0, lowtemperature = 0, hightemperature = 0}
end

if CLIENT then
	net.Receive( "EnvironmentUpdate", function( len, ply )
		local data = {
			gravity = net.ReadFloat(),
			pressure = net.ReadFloat(),
			oxygen = net.ReadFloat(),
			atmosphere = net.ReadFloat(),
			temperature = net.ReadFloat(),
			planet = net.ReadEntity()
		}

		LocalPlayer().environment = data

		ENVIRONMENTS.environment = ENVIRONMENTS.environment or {}

		table.Merge( ENVIRONMENTS.environment, data)
	end)

	function ENVIRONMENTS:InitPostEntity()
		self.environment = self:GetDefaultEnvironment()
	end

	local laste = ""
	local lastetime = 0

	function ENVIRONMENTS:HUDPaint()
		local hudposition = OPTIONS:Get( "hudposition", "Right Top" )
		local hudtimeout = OPTIONS:Get( "hudtimeout", 30)

		local atmosphere = self.environment.atmosphere
		local oxygen = self.environment.oxygen
		local gravity = self.environment.gravity
		local temperature = self.environment.temperature
		local environmentname = "Space"

		if (IsValid(self.environment.planet)) then
			environmentname = self.environment.planet:GetEnvironmentName()
		end

		local o = GAMEMODE:Tween("oxygen", oxygen)
		local g = GAMEMODE:Tween("gravity", gravity)
		local t = GAMEMODE:Tween("temperature", temperature)

		if ((o .. g .. t .. hudposition) != laste) then
			laste = (o .. g .. t .. hudposition)
			lastetime = CurTime() + hudtimeout
		end

		local as = ""

		if atmosphere == -1 then
			as = "Water"
		elseif atmosphere <= 0 then
			as = "None"
		elseif atmosphere>= 3 then
			as = "Deadly!"
		elseif atmosphere >= 2 then
			as = "Dense"
		elseif atmosphere > 0 then
			as = "Normal"
		end

		GAMEMODE:MakeHud({
			name = "EnvironmentsHud",
			position = hudposition,
			enabled = ((LocalPlayer():Alive() and lastetime > CurTime()) or hudtimeout == 0),
			minwidth = 130,
			rows = {
				{
					graph = {
						color=Color(80,80,80,100)},
						text = environmentname,
						color = Color(255, 255, 0),
						font = "MDSBtipBold18",
						xalign = TEXT_ALIGN_CENTER
					},
				{
					graph = {percent = o},
					text = "Oxygen:"
				},{
					graph = {percent = g},
					text = "Gravity:"
				},{
					graph = {color = Color(130,130,130,100)},
					text = "Temperature: " .. tostring(t)
				},{
					graph = {color = Color(130,130,130,100)},
					text = "Atmosphere: " .. as
				}
			}
		})
	end
end

GM:Register( ENVIRONMENTS )


--[[
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////// SERVER SIDE STUFF IS HERE //////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////
]]
if !SERVER then return end

ENVIRONMENTS.Entities = {}
ENVIRONMENTS.Planets = {}
ENVIRONMENTS.Stars = {}
ENVIRONMENTS.Spacebuild = false
ENVIRONMENTS.Ignore = { "base_environment", "sb_planet", "base_resource", "base_lifesupport", "logic_case", "func_physbox_multiplayer", "func_physbox" }

util.AddNetworkString( "EnvironmentUpdate" )

function ENVIRONMENTS:IgnoreClass( ent )
	return table.HasValue(self.Ignore, ent:GetClass())
end

function ENVIRONMENTS:PhysgunPickup( ply , ent )
	if table.HasValue(self.Ignore, ent:GetClass()) then
		return false
	end
end

function ENVIRONMENTS:GetEntities()
	return self.Entities
end

function ENVIRONMENTS:HasEntity( ent )
	return IsValid(self.Entities[ent:EntIndex()])
end

function ENVIRONMENTS:EntityRemoved( ent )
	self.Entities[ent:EntIndex()] = nil
end

function ENVIRONMENTS:OnEntitySpawn( ent )
	if (!IsValid(ent)) then return end

	self.Entities[ent:EntIndex()] = ent
end

function ENVIRONMENTS:PlayerSpawnedNPC( ply, ent ) self:OnEntitySpawn( ent ) end
function ENVIRONMENTS:PlayerSpawnedSENT( ply, ent ) self:OnEntitySpawn( ent ) end
function ENVIRONMENTS:PlayerSpawnedVehicle( ply, ent ) self:OnEntitySpawn( ent ) end
function ENVIRONMENTS:PlayerSpawnedProp( ply, model, ent ) self:OnEntitySpawn( ent ) end
function ENVIRONMENTS:PlayerSpawnRagdoll( ply, model ) self:OnEntitySpawn( ent ) end
function ENVIRONMENTS:OnEntityCreated( ent ) self:OnEntitySpawn(ent) end

function ENVIRONMENTS:GetTemperature( ent, low, high )
	if (!IsValid(ent)) then return (low or high) end
	if (low == high or (low and !high)) then return low or 0 end
	if (!low and high) then return high end
	if (!low and !high) then return -1 end
	for _, _ent in pairs( self.Stars ) do
		if (ent:Visible(_ent)) then return high end
	end
	return low
end

--registers player within the environment quicker
function ENVIRONMENTS:PlayerSpawn( ply )
	self:OnEntitySpawn( ply )

	ply.Environments = {}
	ply.EnvironmentValues = self:GetSpaceEnvironment()
	ply:SetGravity( 1 )
	ply:SetHealth(100)
end

function ENVIRONMENTS:EntityTakeDamage( ent, inflictor, attacker, amount, dmginfo )
	if (self:IgnoreClass(ent) or OPTIONS:Get("spawndamage", 1) ~= 1) then return false end

	for _, ent in pairs( ent:GetEnvironments() ) do
		if (ent.spawnpoint) then return false end
	end
end

function ENVIRONMENTS:PlayerShouldTakeDamage( ply, attacker )
	if (OPTIONS:Get("spawndamage", 1) == 1 && ply ~= attacker) then
		for _, ent in pairs(  ply:GetEnvironments() ) do
			if (IsValid(ent) and ent.spawnpoint) then return false end
		end
	end
end

function ENVIRONMENTS:CreatePlanet( data )
	local ent = ents.Create("sb_planet")

	ent:SetPos( data.position )
	ent:Spawn()
	ent:Activate()
	ent:SetEnvironment( data )

	if (data.star) then
		table.insert( self.Stars, ent ) --add to stars
	else
		table.insert( self.Planets, ent ) --add to planets
	end
end

-- Returns True if the planet is a spawn point
function ENVIRONMENTS:IsSpawnPlanet( planet )
	if (!planet) then return false end
	if (planet.spawnPlanet) then return true end

	for _, ent in pairs(ents.FindByClass("info_player_start")) do
		if (ent:GetPos():Distance (planet.position) < planet.radius) then
			planet.spawnPlanet = true --cache the result
			return true
		end
	end

	for _, ent in pairs(ents.FindByClass("info_player_terrorist")) do
		if (ent:GetPos():Distance(planet.position) < planet.radius) then
			planet.spawnPlanet = true --cache the result
			return true
		end
	end

	return false
end

function ENVIRONMENTS:InitPostEntity( )
	self.Planets = {}
	self.Stars = {}

	for _, ent in pairs(ents.FindByClass("sb_planet")) do --cleanup planets since we are going to recreate them
		ent:Remove()
	end

	local Blooms = {}
	local Colors = {}

	local function Extract_Bit(bit, field) --used to get SB2 planet flags
		if not bit or not field then return false end
		local retval = 0
		if ((field <= 7) and (bit <= 4)) then
			if (field >= 4) then
				field = field - 4
				if (bit == 4) then return true end
			end
			if (field >= 2) then
				field = field - 2
				if (bit == 2) then return true end
			end
			if (field >= 1) then
				field = field - 1
				if (bit == 1) then return true end
			end
		end
		return false
	end

	--try to get a planet name based off bloom or color id values. works on some SB2 maps.
	local function Extract_SBPlanetName( value, planet )
		local name = string.Replace(value, "bloom_", "")
		name = string.Replace(value, "color_", "")

		if (name ~= "") then
			name = string.upper(string.Left(name, 1)) .. string.Right(name, string.len(name)-1)

			if (string.len(name) > 1) then planet.name = name end
		end
	end

	for _, ent in pairs( ents.FindByClass( "logic_case" ) ) do
		--get values
		local tab = ent:GetKeyValues()
		local case = tab.Case01

		if case == "planet_color" then
			local color = {}
			color.id = tab.Case16
			color.addcol = Vector( tab.Case02 )
			color.mulcol = Vector( tab.Case03 )
			color.brightness = tonumber( tab.Case04 )
			color.contrast = tonumber( tab.Case05 )
			color.color = tonumber( tab.Case06 )

			Colors[color.id] = color

		elseif case == "planet_bloom" then
			local bloom = {}
			bloom.id = tab.Case16
			bloom.color = Vector( tab.Case02 )
			bloom.x = tonumber( string.Explode( " ", tab.Case03 )[1] )
			bloom.y = tonumber( string.Explode( " ", tab.Case03 )[2] )
			bloom.passes = tonumber( tab.Case04 )
			bloom.darken = tonumber( tab.Case05 )
			bloom.multiply = tonumber( tab.Case06 )
			bloom.colormul = tonumber( tab.Case07 )

			Blooms[bloom.id] = bloom
		end
	end

	for _, ent in pairs( ents.FindByClass( "logic_case" ) ) do
		local tab = ent:GetKeyValues()
		local case = tab.Case01

		if case == "env_rectangle" then
			MsgN("\n\n\n env_rectangle!!!!!! \n\n\n")
		elseif case == "cube" then
			MsgN("\n\n\n CUBE!!!!!! \n\n\n")
		elseif case == "planet" then --sb2 planet
			local flags = tonumber(tab.Case16)

			local planet = {}
			planet.radius = tonumber(tab.Case02)
			planet.gravity = tonumber(tab.Case03)
			planet.atmosphere = tonumber(tab.Case04)
			planet.lowtemperature = tonumber(tab.Case05)
			planet.hightemperature = (tonumber(tab.Case06) || planet.lowtemperature)
			--planet.colorid = tostring(tab.Case07)
			planet.color = Colors[planet.colorid]
			--planet.bloomid = tostring(tab.Case08)
			planet.bloom = Blooms[planet.bloomid]
			planet.name = "Planet " .. #self.Planets + 1
			planet.position = ent:GetPos()
			--planet.spawnpoint = self:IsSpawnPlanet(planet)
			planet.habitat = Extract_Bit(1, flags)
			planet.unstable = Extract_Bit(2, flags)
			planet.sunburn = Extract_Bit(3, flags)

			--sometimes SB2 planets use bloom ids that are the planet names. lets try to get it
			Extract_SBPlanetName( tostring(tab.Case08), planet )
			Extract_SBPlanetName( tostring(tab.Case07), planet )

			if (planet.habitat) then
				planet.oxygen = 100
			else
				planet.oxygen = 0
			end

			planet.pressure = 1

			self:CreatePlanet( planet )
			print("planet found.")
		elseif case == "planet2" then --sb3 planet
			local planet = {}
			planet.radius = tonumber(tab.Case02) --Get Radius
			planet.gravity = tonumber(tab.Case03) --Get Gravity
			planet.atmosphere = tonumber(tab.Case04)
			planet.pressure = tonumber(tab.Case05)
			planet.lowtemperature = tonumber(tab.Case06)
			planet.hightemperature = tonumber(tab.Case07) || planet.lowtemperature
			planet.oxygen = tonumber(tab.Case09)
			planet.name = tostring(tab.Case13) || ("Planet " .. #self.Planets + 1) --Get Name
			planet.color = Colors[tostring(tab.Case15)]
			planet.bloom = Blooms[tostring(tab.Case16)]
			planet.position = ent:GetPos()
			--planet.spawnpoint = self:IsSpawnPlanet(planet)

			self:CreatePlanet( planet )

			print("planet2 found.")
		elseif case == "star" then
			local star = {}
			star.radius = tonumber(tab.Case02)
			star.position = ent:GetPos()
			star.star = true

			self:CreatePlanet( star )
			print("star found.")
		elseif case == "star2" then
			local star = {}
			star.radius = tonumber(tab.Case02) --Get Radius
			star.gravity = tonumber(tab.Case03) --Get Gravity
			star.name = tostring(tab.Case06 || "Star")
			star.position = ent:GetPos()
			star.star = true

			self:CreatePlanet( star )
			print("star2 found.")
		end
	end

	self.Spacebuild = #self.Planets > 0

	if (!self.Spacebuild) then
		GAMEMODE:RemoveClass( self )

		print("----------------------------------------")
		print("ERROR: Not a Spacebuild map. Removing Environments.")
		print("----------------------------------------")
	end
end

--called when entity enters an environment
function ENVIRONMENTS:EnterEnvironment( ent, environment )
	if (!self:HasEntity(ent) or self:IgnoreClass(ent)) then return end

	ent.Environments = ent.Environments or {}
	ent.Environments[environment:EntIndex()] = environment

	if (environment:IsPlanet()) then
		ent:SetPlanet( environment )
	end

	self:EnvironmentUpdate( ent )

	MsgN("EnterEnvironment", ent, environment)
end

--called when entity leaves an environment
function ENVIRONMENTS:LeaveEnvironment( ent, environment )
	if (!self:HasEntity(ent) or self:IgnoreClass(ent)) then return end

	ent.Environments = ent.Environments or {}

	if (environment:IsPlanet()) then
		ent:SetPlanet()
	end

	ent.Environments[environment:EntIndex()] = nil

	self:EnvironmentUpdate( ent )

	MsgN("LeaveEnvironment", ent, environment)
end

function ENVIRONMENTS:GetPlanet( ent )
	--get all the entities claiming to control the environment for this entity
	for _, environment in pairs( ent:GetEnvironments() ) do
		if (!IsValid(environment)) then continue end
		if (environment:IsPlanet()) then
			return environment
		end
	end
end

function ENVIRONMENTS:EnvironmentUpdate( ent )
	if (!IsValid(ent)) then return end
	if (ent:IsPlayer() and !ent:Alive()) then return end

	local oldvalues = ent:GetEnvironmentData()
	local values = self:GetSpaceEnvironment()
	local pos = ent:GetPos()
	local planet = ent:GetPlanet()-- or self:GetPlanet( ent )

	values.planet = planet

	if (planet) then
		table.Merge(values, planet:GetEnvironment())
	end

	--add environments to the mix
	for _, environment in pairs( ent:GetEnvironments() ) do
		if (!IsValid(environment) or environment:IsPlanet() or !environment:GetActive()) then continue end

		table.Merge(values, environment:GetEnvironment())
	end

	--temp checks
	values.temperature = self:GetTemperature( ent, values.lowtemperature, values.hightemperature )

	--water level check
	if (ent:WaterLevel() > 2) then
		values.oxygen = 0
		values.atmosphere = -1
	end

	--apply gravity in space only if entity can land on something below them..
	if (!planet and values.gravity > 0) then
		local trace = util.TraceLine({
			start = ent:GetPos(),
			endpos = ent:GetPos() - Vector(0,0,200),
			filter = ent
		})

		if (!IsValid(trace.Entity) ) then
			values.gravity = 0
		end
	end

	local phys = ent:GetPhysicsObject()

	if (IsValid(phys)) then
		phys:EnableGravity( values.gravity > 0 )
		phys:EnableDrag( values.pressure > 0.01 )
	end

	ent:SetEnvironmentData( values )
	ent:SetGravity( values.gravity )

	--send environment update, only if its changed
	if (ent:IsPlayer() and (oldvalues.gravity ~= values.gravity or oldvalues.pressure ~= values.pressure or oldvalues.oxygen ~= values.oxygen or oldvalues.atmosphere ~= values.atmosphere or oldvalues.temperature ~= values.temperature or oldvalues.planet ~= values.planet)) then
		net.Start( "EnvironmentUpdate" )
		net.WriteFloat( (values.gravity * 100) )
		net.WriteFloat( values.pressure )
		net.WriteFloat( values.oxygen )
		net.WriteFloat( math.ceil(values.atmosphere) )
		net.WriteFloat( math.Round(values.temperature * 9/5 - 459.67) )
		net.WriteEntity( values.planet )
		net.Send( ent )
	end
end
--[[
this should not be needed anymore due to the touch events but leaving code here
for debug or justincase touch events dont work anymore ~MadDog

	function ENVIRONMENTS:Think()
		self.NextThink = CurTime() + OPTIONS:Get("environmentsupdate", 1)

		if (!self.Spacebuild) then return end

		for _, ent in pairs( self:GetEntities() ) do
			self:EnvironmentUpdate( ent )
		end
	end
]]
-- META MODS
ENVIRONMENTS.entity = {}

function ENVIRONMENTS.entity:SetPlanet( planet )
	self.EnvironmentValues = self.EnvironmentValues or {}
	self.EnvironmentValues.planet = planet
end

function ENVIRONMENTS.entity:GetPlanet()
	self.EnvironmentValues = self.EnvironmentValues or {}
	return self.EnvironmentValues.planet
end

--returns the global list of all environments (planets, entities, etc)
function ENVIRONMENTS.entity:GetEnvironments()
	return self.Environments or {}
end

function ENVIRONMENTS.entity:GetEnvironmentData()
	return self.EnvironmentValues or ENVIRONMENTS:GetSpaceEnvironment()
end

function ENVIRONMENTS.entity:SetEnvironmentData( data )
	self.EnvironmentValues = data or ENVIRONMENTS:GetSpaceEnvironment()
end

function ENVIRONMENTS.entity:GetPressure()
	return self:GetEnvironmentData().pressure or 0
end

function ENVIRONMENTS.entity:GetOxygen()
	return self:GetEnvironmentData().oxygen or 0
end

function ENVIRONMENTS.entity:GetAtmosphere()
	return self:GetEnvironmentData().atmosphere or 0
end

function ENVIRONMENTS.entity:GetTemperature()
	return self:GetEnvironmentData().temperature or 0
end