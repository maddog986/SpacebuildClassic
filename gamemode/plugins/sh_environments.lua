--[[
	Author: MadDog (steam id md-maddog)

	TODO:
		- add a Fahrenheit or Celcius option
		- add blooms and colors to planets
		- reduce color blooms when planets are terra formed
		- on terraformed planets disable entities: env_smokestack, func_dustcloud
		- add planet ambient sounds
]]

local ENVIRONMENTS = {
	--plugin info
	Name = "Environments",
	Description = "Plugin that controls all Environments and Planets.",
	Author = "MadDog",
	Version = 12202015, --should always be a date format mmddyyyy

	--settings
	CVars = {
		--server setting
		"sb_environments_enable" = { server = true, text = "Enable Environments", default = true },
		"sb_environments_allow_spawn_damage" = { server = true, text = "Allow Damage on Spawn Planet", default = true },
		"sb_environments_gravity_time" = { server = true, text = "Space Gravity Check Interval", default = 1, min = 0.1, max = 10, decimals = 1 },
		
		--client settings
		"sb_environments_fahrenheit" = { text = "Temperature in Fahrenheit", default = true },
		"sb_environments_planetblooms" = { text = "Enable Planet Blooms", default = true },
		"sb_environments_planetcolors" = { text = "Enable Planet Colors", default = true },
		"sb_environments_sunrays" = { text = "Enable Sun Rays", default = true },
		"sb_environments_hudposition" = { text = "HUD (Heads Up Display) Position", default = "Top Left", options = {"Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"} },		
	},

	--[[	Shared Functions ]]
	GetDefaultEnvironment = function( self )
		return {Gravity = 1, Pressure = 1, Oxygen = 100, Atmosphere = 1, Temperature = 288, LowTemperature = 288, HighTemperature = 288}
	end,

	GetSpaceEnvironment = function( self )
		return {Gravity = 0, Pressure = 0, Oxygen = 0, Atmosphere = 0, Temperature = 0, LowTemperature = 0, HighTemperature = 0}
	end,

	GetValue = function( self, ent, value )
		return Either(type(value) == "function", value(ent), value)
	end
}

--[[	META MODS ]]
local ent = FindMetaTable("Entity")

AccessorFunc( ent, "e_pressure", "Pressure", FORCE_NUMBER )
AccessorFunc( ent, "e_oxygen", "Oxygen", FORCE_NUMBER )
AccessorFunc( ent, "e_atmosphere", "Atmosphere", FORCE_NUMBER )
AccessorFunc( ent, "e_temperature", "Temperature", FORCE_NUMBER )
AccessorFunc( ent, "e_planet", "Planet" )

function ent:HasValidPlanet()
	return IsValid(self:GetPlanet())
end

if ( SERVER ) then
	function ent:AddEnvironment( environment )
		self._environments = self._environments or {}
		table.insert( self._environments, environment )
		ENVIRONMENTS:EnvironmentUpdate( self )
	end

	function ent:RemoveEnvironment( environment )
		self._environments = self._environments or {}
		table.RemoveByValue( self._environments, environment )
		ENVIRONMENTS:EnvironmentUpdate( self )
	end

	function ent:GetEnvironments()
		return self._environments or {}
	end
end

--[[
	Client Functions
]]
if ( CLIENT ) then
	local environment = ENVIRONMENTS:GetDefaultEnvironment()
	local Atmosphere = "Normal"
	local Temperature = 0

	net.Receive( "EnvironmentUpdate", function()
		local ply = LocalPlayer()

		ply:SetGravity( net.ReadFloat() )
		ply:SetPressure( net.ReadFloat() )
		ply:SetOxygen( net.ReadFloat() )
		ply:SetAtmosphere( net.ReadFloat() )
		ply:SetTemperature( net.ReadFloat() )
		ply:SetPlanet( net.ReadEntity() )

		if ( ply:GetPlanet():IsWorld() ) then ply:SetPlanet(nil) end
	end)

	function ENVIRONMENTS:HUDPaint()
		if ( !self:IsActive() ) then return end

		local name = "Space"
		local ply = LocalPlayer()

		if ( IsValid(ply:GetPlanet()) ) then
			name = ply:GetPlanet():GetEnvironmentName()
		end

		local Temperature = ply:GetTemperature() or 288
		local TempDegree = "°F"

		if ( self:GetSetting("sb_environments_fahrenheit") ) then
			Temperature = math.ceil(Temperature * 9/5 - 459.67)
		else
			Temperature = math.ceil(Temperature - 273.15)
			TempDegree = "°C"
		end

		local Atmosphere = ply:GetAtmosphere()

		if Atmosphere == -1 then
			Atmosphere = "Water"
		elseif Atmosphere <= 0 then
			Atmosphere = "None"
		elseif Atmosphere >= 3 then
			Atmosphere = "Deadly!"
		elseif Atmosphere >= 2 then
			Atmosphere = "Dense"
		else
			Atmosphere = "Normal"
		end

		GAMEMODE:MakeHud({
			name = "EnvironmentsHud",
			position = self:GetSetting( "sb_environments_hudposition" ),
			enabled = true,
			minwidth = 130,
			rows = {
				{graph = { color = Color(80,80,80,100)}, text = name, color = Color(255, 255, 0), font = "MDSBtipBold22", xalign = TEXT_ALIGN_CENTER},
				{graph = { percent = utilx.Smoother(ply:GetOxygen(), "SBOxygen")}, text = "Oxygen:"},
				{graph = { percent = utilx.Smoother(ply:GetGravity(), "SBGravity")}, text = "Gravity:"},
				{graph = { color = Color(130,130,130,100)}, text = "Temperature: " .. tostring(utilx.Smoother(Temperature, "SBTemperature")) .. TempDegree },
				{graph = { color = Color(130,130,130,100)}, text = "Atmosphere: " .. Atmosphere }
			}
		})
	end

	--register the plugin with the gamemode
	GM:AddPlugin( ENVIRONMENTS )
return end


--[[
	Server Functions
]]
local entities = {}
local planets = {}
local stars = {}

ENVIRONMENTS.Ignore = { "sb_brush_environment", "base_lifesupport", "sb_planet", "logic_case", "func_*", "soundent", "player_manager", "bodyque", "env_message", "predicted_", "weapon_", "physgun_", "game_", "gmod_", "ai_network", "scene_" }

util.AddNetworkString( "EnvironmentUpdate" )

function ENVIRONMENTS:InitPostEntity()
	planets = {}
	stars = {}

	for _, ent in pairs( ents.FindByClass("sb_planet") ) do --cleanup planets since we are going to recreate them
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

	GAMEMODE:DebugPrint("ENVIRONMENTS: logic_case: ", #ents.FindByClass( "logic_case" ))

	for _, ent in pairs( ents.FindByClass( "logic_case" ) ) do
		local tab = ent:GetKeyValues()
		local case = tab.Case01

		if ( case == "planet_color" ) then
			local color = {}
			color.id = tab.Case16
			color.addcol = Vector( tab.Case02 )
			color.mulcol = Vector( tab.Case03 )
			color.brightness = tonumber( tab.Case04 )
			color.contrast = tonumber( tab.Case05 )
			color.color = tonumber( tab.Case06 )

			Colors[color.id] = color

		elseif ( case == "planet_bloom" ) then
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

	GAMEMODE:DebugPrint("Finding Planets:")

	for _, ent in pairs( ents.FindByClass( "logic_case" ) ) do
		local tab = ent:GetKeyValues()
		local case = tab.Case01
		local planet = {}

		if ( case == "env_rectangle" ) then
			MsgN("\n\n\n env_rectangle!!!!!! \n\n\n") --TODO: add support for this
		elseif ( case == "cube" ) then
			MsgN("\n\n\n CUBE!!!!!! \n\n\n") --TODO: add support for this
		elseif ( case == "planet" or case == "planet2" ) then --sb2 planet

			local flags = nil

			planet.Name = ""
			planet.Active = true
			planet.Position = ent:GetPos()
			planet.Size = tonumber(tab.Case02)
			planet.Gravity = tonumber(tab.Case03)
			planet.Atmosphere = tonumber(tab.Case04)

			if (case == "planet") then
				flags = tonumber(tab.Case16)

				planet.LowTemperature = tonumber(tab.Case05)
				planet.HighTemperature = tonumber(tab.Case06)
				planet.colorid = tostring(tab.Case07)
				planet.bloomid = tostring(tab.Case08)
				planet.Pressure = 1
			else
				flags = tonumber(tab.Case08)

				planet.LowTemperature = tonumber(tab.Case06)
				planet.HighTemperature = tonumber(tab.Case06)
				planet.colorid = tostring(tab.Case15)
				planet.bloomid = tostring(tab.Case16)
				planet.Pressure = tostring(tab.Case05)
				planet.Name = tostring(tab.Case13)
				planet.Oxygen = tonumber(tab.Case09)
			end

			--figure out the planet name if we can
			if (planet.Name == "" and planet.colorid ~= "") then
				planet.Name = planet.colorid:gsub("color_", "")
			end

			if (planet.Name == "" and planet.bloomid ~= "") then
				planet.Name = planet.colorid:gsub("bloom_", "")
			end

			if (planet.Name == "") then
				planet.Name = "Planet " .. (#planets + 1)
			end

			planet.Name = planet.Name:gsub("^%l", string.upper)

			planet.habitat = Extract_Bit(1, flags)
			planet.unstable = Extract_Bit(2, flags)
			planet.sunburn = Extract_Bit(3, flags)

			planet.color = Colors[planet.colorid]
			planet.bloom = Blooms[planet.bloomid]

			if ( planet.habitat ) then
				planet.Oxygen = 100
			end

			planet.spawnPlanet = self:IsSpawnPlanet(planet)

			GAMEMODE:DebugPrint("\tPlanet created: ", planet.Name)

		--[[elseif case == "planet2" then --sb3 planet

			--CreateEnvironment(case2, case3, case4, case5, case6, case7,  case9, case10, case11, case12, case8, case13)
			--CreateEnvironment(radius, Gravity, Atmosphere, Pressure, Temperature, Temperature2, o2, co2, n, h, flags, name)


			local planet = {}
			planet.Size = tonumber(tab.Case02) --Get Radius
			planet.Gravity = tonumber(tab.Case03) --Get Gravity
			planet.Atmosphere = tonumber(tab.Case04)
			planet.Pressure = tonumber(tab.Case05)
			planet.LowTemperature = tonumber(tab.Case06)
			planet.HighTemperature = tonumber(tab.Case07) || planet.LowTemperature
			planet.Oxygen = tonumber(tab.Case09)
			planet.Name = tostring(tab.Case13) || ("Planet " .. #planets + 1) --Get Name
			planet.color = Colors[tostring(tab.Case15)]
			planet.bloom = Blooms[tostring(tab.Case16)]
			planet.Position = ent:GetPos()
			--planet.spawnpoint = self:IsSpawnPlanet(planet)

			print("planet2 found.")]]
		elseif ( case == "sb_dev_tree" ) then

			local tree = ents.Create( "sb_tree" )

			tree.GrowthTime = tonumber(case2)
			tree:SetAngles( ent:GetAngles() )
			tree:SetPos( ent:GetPos() )
			tree:Spawn()
			tree:Activate()

			print(case.." found.")

		elseif ( case == "star" ) then
			
			star.Size = tonumber(tab.Case02)
			star.Position = ent:GetPos()
			star.Star = true

			print("star found.")
		elseif ( case == "star2" ) then

			star.Size = tonumber(tab.Case02) --Get Radius
			star.Gravity = tonumber(tab.Case03) --Get Gravity
			star.Name = tostring(tab.Case06 || "Star")
			star.Position = ent:GetPos()
			star.Star = true

			print("star2 found.")
		end

		if ( !data.Position ) then continue end

		local planet = ents.Create("sb_planet")

		planet:SetPos( data.Position )
		planet:Spawn()
		planet:Activate()

		planet:SetEnvironment( data )

		if ( data.Star ) then
			table.insert( stars, ent ) --add to stars
		else
			table.insert( planets, ent ) --add to planets
		end
	end

	GAMEMODE:DebugPrint("Planets Found: ", #planets)
	GAMEMODE:DebugPrint("Stars Found: ", #stars)

	--TODO: add a star when map doesnt have any
end

function ENVIRONMENTS:Startup() --this is only called when going from disabled to enabled
	--make sure all entities are updated
	for _, ent in pairs( entities ) do
		self:EnvironmentUpdate( ent, true )
	end
end

function ENVIRONMENTS:IgnoreClass( ent )
	if ( !IsValid(ent) or ent:IsWorld() or !IsValid(ent:GetPhysicsObject()) ) then return true end

	local class = ent:GetClass()

	for _, str in pairs( self.Ignore ) do
		if ( string.find(class, str) ) then return true end
	end

	return false --return table.HasValue(self.Ignore, ent:GetClass())
end

function ENVIRONMENTS:PhysgunPickup( ply, ent )
	if ( self:IgnoreClass(ent) ) then return false end
end

function ENVIRONMENTS:GetEntities()
	return entities
end

function ENVIRONMENTS:HasEntity( ent )
	return IsValid(entities[ent:EntIndex()])
end

function ENVIRONMENTS:EntityRemoved( ent )
	entities[ent:EntIndex()] = nil
end

function ENVIRONMENTS:OnEntitySpawn( ent )
	if ( !IsValid(ent) or self:IgnoreClass(ent) ) then return end

	entities[ent:EntIndex()] = ent
end

function ENVIRONMENTS:PlayerSpawnedNPC( ply, ent ) self:OnEntitySpawn( ent ) end
function ENVIRONMENTS:PlayerSpawnedSENT( ply, ent ) self:OnEntitySpawn( ent ) end
function ENVIRONMENTS:PlayerSpawnedVehicle( ply, ent ) self:OnEntitySpawn( ent ) end
function ENVIRONMENTS:PlayerSpawnedProp( ply, model, ent ) self:OnEntitySpawn( ent ) end
function ENVIRONMENTS:PlayerSpawnRagdoll( ply, model ) self:OnEntitySpawn( ent ) end
function ENVIRONMENTS:OnEntityCreated( ent ) self:OnEntitySpawn(ent) end

function ENVIRONMENTS:GetTemperature( ent, low, high )
	if ( !IsValid(ent) or !high or !low or low == high) then return (low or high or 0) end

	for _, star in pairs( stars ) do
		if ( util.TraceLine({ start = ent:GetPos(), endpos = star:GetPos(), filter = ent, mask = MASK_SOLID_BRUSHONLY }).Hit ) then
			return high
		end
	end

	return (low or high or 0)
end

--registers player within the environment quicker
function ENVIRONMENTS:PlayerSpawn( ply )
	self:OnEntitySpawn( ply )

	ply._environments = {} --environments the player is currently within, planets and artificial

	self:EnvironmentUpdate( ply, true )
end

function ENVIRONMENTS:EntityTakeDamage( ent, inflictor, attacker, amount, dmginfo )
	if ( self:IgnoreClass(ent) ) then return false end
	if ( IsValid(ent:GetPlanet()) and ent:GetPlanet().spawnPlanet and !self:GetSetting("sb_environments_allow_spawn_damage") ) then return false end
end

function ENVIRONMENTS:PlayerShouldTakeDamage( ply, attacker )
	if ( IsValid(ply:GetPlanet()) and ply:GetPlanet().spawnPlanet and !self:GetSetting("sb_environments_allow_spawn_damage") ) then return false end
end

-- Returns True if the planet is a spawn point
function ENVIRONMENTS:IsSpawnPlanet( planet )
	if ( !planet ) then return false end
	if ( planet.spawnPlanet ) then return true end

	for _, ent in pairs( ents.FindByClass("info_player_start") ) do
		if ( ent:GetPos():Distance(planet.Position) < planet.Size ) then
			planet.spawnPlanet = true --cache the result
			return true
		end
	end

	for _, ent in pairs( ents.FindByClass("info_player_terrorist") ) do
		if ( ent:GetPos():Distance(planet.Position) < planet.Size ) then
			planet.spawnPlanet = true --cache the result
			return true
		end
	end

	return false
end


--called when entity enters an environment
function ENVIRONMENTS:EnterEnvironment( ent, environment )
	if ( !self:HasEntity(ent) or self:IgnoreClass(ent) ) then return end

	ent:AddEnvironment( environment )

	GAMEMODE:DebugPrint("EnterEnvironment", environment, ent )
end

--called when entity leaves an environment
function ENVIRONMENTS:LeaveEnvironment( ent, environment )
	if ( !self:HasEntity(ent) or self:IgnoreClass(ent) ) then return end

	ent:RemoveEnvironment(environment)

	GAMEMODE:DebugPrint("LeaveEnvironment", environment, ent )
end

function ENVIRONMENTS:EnvironmentUpdate( ent, forceupdate )
	if ( !IsValid(ent) or (ent:IsPlayer() and !ent:Alive()) or !self:IsActive() ) then return end

	local oldvalues = ent._environment_data or self:GetDefaultEnvironment()
	local values = self:GetSpaceEnvironment()

	--set base environments as the planet
	if ( IsValid(ent:GetPlanet()) ) then
		table.Merge( values, ent:GetPlanet():GetEnvironment() )
	end

	--add environments to the mix
	for _, environment in pairs( ent:GetEnvironments() ) do
		if ( !IsValid(environment) ) then ent:RemoveEnvironment(environment); return end
		if ( environment:IsPlanet() or !environment:IsActive() ) then continue end

		--loop and get all values
		for name, value in pairs( environment:GetEnvironment() ) do
			values[name] = self:GetValue(environment, value)
		end
	end

	--temp checks
	values.Temperature = self:GetTemperature( ent, values.LowTemperature, values.HighTemperature )

	--water level check
	if ( ent:WaterLevel() >= 2 ) then
		values.Oxygen = 0
		values.Atmosphere = -1
		values.Pressure = 2
	end

	values.Gravity = (values.Gravity or 0) + 0.00001

	ent:SetPressure( math.ceil(values.Pressure) )
	ent:SetOxygen( math.ceil(values.Oxygen) )
	ent:SetAtmosphere( math.ceil(values.Atmosphere) )
	ent:SetTemperature( math.Round(values.Temperature, 2) )

	ent:SetGravity( values.Gravity )

	local phys = ent:GetPhysicsObject()

	if ( IsValid(phys) ) then
		phys:EnableGravity( (values.Gravity > 0) )
		phys:EnableDrag( (values.Pressure > 0.01) )
	end

	ent._environment_data = data

	--send environment update, only if its changed. lame attempt to cache the results to save some net sends
	if ( ent:IsPlayer() and (forceupdate or (oldvalues.Gravity ~= values.Gravity or oldvalues.Pressure ~= values.Pressure or oldvalues.Oxygen ~= values.Oxygen or oldvalues.Atmosphere ~= values.Atmosphere or oldvalues.Temperature ~= values.Temperature or oldvalues.planet ~= values.planet)) ) then
		net.Start( "EnvironmentUpdate" )
		net.WriteFloat( math.Round(values.Gravity * 100, 0) )
		net.WriteFloat( values.Pressure )
		net.WriteFloat( values.Oxygen )
		net.WriteFloat( values.Atmosphere )
		net.WriteFloat( values.Temperature )
		net.WriteEntity( ent:GetPlanet() )
		net.Send( ent )
	end
end

function ENVIRONMENTS:Think()
	if ( !self:IsActive() ) then return end

	self.NextThink = CurTime() + self:GetSetting("sb_environments_gravity_time")

	for _, ent in pairs( entities ) do
		if ( !IsValid(ent) or IsValid(ent:GetPlanet()) or ent:GetGravity() ~= 0.00001 ) then continue end

		local tr = util.TraceLine({
			start = ent:GetPos(),
			endpos = ent:GetPos() - Vector(0,0,150),
			filter = ent
		})

		if ( IsValid(tr.Entity) ) then
			ent:SetGravity( 0.5 )
		end
	end
end

--register the plugin with the gamemode
GM:AddPlugin( ENVIRONMENTS )