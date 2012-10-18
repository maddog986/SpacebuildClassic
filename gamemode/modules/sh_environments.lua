--[[

	Author: MadDog (steam id md-maddog)

	TODO:
		- add a Fahrenheit or Celcius option
		- reduce color blooms when planets are terra formed
		- on terraformed planets disable entities: env_smokestack, func_dustcloud
		- add planet ambient sounds
]]

local ENVIRONMENTS = {}
ENVIRONMENTS.Name = "Environments"
ENVIRONMENTS.Author = "MadDog"
ENVIRONMENTS.Version = 1

if CLIENT then
	local sbhudposition = CreateClientConVar( "mdsb_sbhudposition", "Right Top", true, false )
	local sbhudtimeout = CreateClientConVar( "mdsb_sbhudtimeout", 20, true, false )
	local blooms = CreateClientConVar( "mdsb_blooms", "1", true, false )
	local colors = CreateClientConVar( "mdsb_colors", "1", true, false )
	local suns = CreateClientConVar( "mdsb_suns", "1", true, false )
	local snow_intense = CreateClientConVar( "mdsb_snowintense", "20", true, false )
	local rain_intense = CreateClientConVar( "mdsb_rainintense", "20", true, false )

	local ename = "Environment"
	local oxygen = 0
	local gravity = 0
	local temperature = math.random(0, 100)
	local atmosphere = 0

	function SetEnvironment( o, g, t, a, name, ent )
		if (name == "") then name = "Environment" end

		oxygen = o
		gravity = (g * 100)
		temperature = math.Round(t * 9/5 - 459.67) --kelvin to fahrenheit
		atmosphere = math.ceil(a)
		ename = name
	end

	local laste = ""
	local lastetime = 0

	function ENVIRONMENTS:HUDPaint()
		local o = smoothit("oxygen", oxygen)
		local g = smoothit("gravity", gravity)
		local t = smoothit("temperature", temperature)

		local hudtimeout = sbhudtimeout:GetInt()

		if ((o .. g .. t .. sbhudposition:GetString()) != laste) then
			laste = (o .. g .. t .. sbhudposition:GetString())
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

		SB:MakeHud({
			name = "EnvironmentsHud",
			position = sbhudposition:GetString(),
			enabled = ((LocalPlayer():Alive() and lastetime > CurTime()) or hudtimeout == 0),
			minwidth = 130,
			rows = {
				{
					graph = {
						color=Color(80,80,80,100)},
						text = ename,
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

	function ENVIRONMENTS:RenderColor( color )
		if (!colors:GetBool() or !vector_origin) then return end
		if (!color or (color.addcol == vector_origin and color.mulcol == vector_origin and color.contrast == 1 and color.brightness == 1 and color.color == 1)) then return end
		if (color.addcol == vector_origin and color.mulcol == vector_origin and color.contrast == 0 and color.brightness == 0 and color.color == 0) then return end

		local cmod = {}
		cmod["$pp_colour_addr"] = color.addcol.x
		cmod["$pp_colour_addg"] = color.addcol.y
		cmod["$pp_colour_addb"] = color.addcol.z
		cmod["$pp_colour_brightness"] = color.brightness
		cmod["$pp_colour_contrast"] = color.contrast
		cmod["$pp_colour_colour"] = color.color
		cmod["$pp_colour_mulr"] = color.mulcol.x
		cmod["$pp_colour_mulg"] = color.mulcol.y
		cmod["$pp_colour_mulb"] = color.mulcol.z

		DrawColorModify( cmod )
	end

	function ENVIRONMENTS:RenderBloom(bloom)
		if (!blooms:GetBool()) then return end
		--DrawBloom(bloom.darken,bloom.multiply,bloom.sizex,bloom.sizey,bloom.passes,bloom.color,bloom.color.r,bloom.color.g,bloom.color.b)
	end

	--strong wind: /ambient/ambience/wind_light02_loop.wav
	--/ambient/animal/flies1.wav - files5.wav
	--/ambient/creatures/rats1.wav - rates4.wav
	--/ambient/halloween/windgust_01.wav - windguest_12.wav

	local rainbrightness = 0
	local raincontrast = 1
	local raincolour = 1

	function ENVIRONMENTS:RenderScreenspaceEffects()
		for _, ent in ipairs(ents.FindByClass("sb_planet")) do
			local onplanet = LocalPlayer():GetPos():Distance(ent:GetPos()) < ent:GetRadius()

			if (suns:GetBool() and ent:GetName() == "Star") then ent:RenderSunbeams() end

			if (!onplanet) then continue end

			if (!self.RainSound) then
				self.RainSound = CreateSound(LocalPlayer(), Sound("/ambient/weather/rumble_rain_nowind.wav"))
			end

			if ( ent:IsRaining() or SB:ConfigInt("sb_israining") == 1 ) then
				self.RainSound:Play()

				if (rain_intense:GetInt() > 0) then
					local e = EffectData()
					e:SetMagnitude(rain_intense:GetInt())
					util.Effect("rain", e)
				end

				rainbrightness = math.Approach(rainbrightness, -0.07, 0.005)
				raincontrast = math.Approach(raincontrast, 0.9, 0.005)
				raincolour = math.Approach(raincolour, 0.5, 0.005)
			else
				if self.RainSound:IsPlaying() then self.RainSound:FadeOut(2) end

				rainbrightness = math.Approach(rainbrightness, 0, 0.005)
				raincontrast = math.Approach(raincontrast, 1, 0.005)
				raincolour = math.Approach(raincolour, 1, 0.005)
			end

			if ( ent:IsSnowing() or SB:ConfigInt("sb_issnowing") == 1 ) then
				if (!self.SnowSoundPlay or self.SnowSoundPlay < CurTime()) then
					self.SnowSoundPlay = CurTime() + 4

					sound.Play(Sound("ambient/halloween/windgust_0" .. math.random(1, 9) .. ".wav"), LocalPlayer():GetPos()) -- windguest_12.wav
				end

				if (snow_intense:GetInt() > 0) then
					local e = EffectData()
					e:SetMagnitude(snow_intense:GetInt())
					util.Effect("snow", e)
				end
			end

			self:RenderColor({
				mulcol = Vector(0,0,0),
				addcol = Vector(0,0,0),
				contrast = raincontrast,
				color = raincolour,
				brightness = rainbrightness
			})

			local color = ent:GetNWVector("bloomcolor")

			self:RenderBloom({
				darken = ent:GetNWFloat("darken"),
				multiply = ent:GetNWFloat("multiply"),
				sizex = ent:GetNWFloat("sizex"),
				sizey = ent:GetNWFloat("sizey"),
				passes = ent:GetNWFloat("passes"),
				color = Color(color.x, color.y, color.z)
			})

			self:RenderColor({
				mulcol = ent:GetNWVector("mulcol"),
				addcol = ent:GetNWVector("addcol"),
				contrast = ent:GetNWFloat("contrast"),
				color = ent:GetNWFloat("color"),
				brightness = ent:GetNWFloat("brightness")
			})
		end
	end
end

-- Returns True if the planet is a spawn point
function ENVIRONMENTS:IsSpawnPlanet( planet )
	if (!planet) then return false end
	if (planet.spawnPlanet) then return true end

	for _, ent in pairs(ents.FindByClass("info_player_start")) do
		if (ent:GetPos():Distance(planet.position) < planet.radius) then
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

if SERVER then
	ENVIRONMENTS.Entities = {}
	ENVIRONMENTS.Planets = {}
	ENVIRONMENTS.Stars = {}
	ENVIRONMENTS.Spacebuild = false

	ENVIRONMENTS.default_environment =  {gravity = 1, oxygen = 100, atmosphere = 1, temperature = 288, lowtemperature = 288, hightemperature = 288}
	ENVIRONMENTS.space_environment =  {gravity = 0, oxygen = 0, atmosphere = 0, temperature = 0, lowtemperature = 0, hightemperature = 0}

	function ENVIRONMENTS:GetEntities()
		return self.Entities
	end

	function ENVIRONMENTS:EntityRemoved( ent )
		table.RemoveByValue( self.Entities, ent )
	end

	local function OnEntitySpawn( ent )
		if not table.HasValue(ENVIRONMENTS.Entities, ent) then
			table.insert( ENVIRONMENTS.Entities, ent )
		end
	end

	function ENVIRONMENTS:PlayerSpawnedNPC( ply, ent ) OnEntitySpawn( ent ) end
	function ENVIRONMENTS.PlayerSpawnedSENT( ply, ent ) OnEntitySpawn( ent ) end
	function ENVIRONMENTS.PlayerSpawnedVehicle( ply, ent ) OnEntitySpawn( ent ) end
	function ENVIRONMENTS:PlayerSpawnedProp( ply, model, ent ) OnEntitySpawn( ent ) end

	function ENVIRONMENTS:GetTemperature( ent, low, high )
		if (!IsValid(ent)) then return (low or high) end
		if (low == high or (low and !high)) then return low or 0 end
		if (!low and high) then return high end
		if (!low and !high) then return -1 end

		for _idx, _ent in pairs( self.Stars ) do --go through all the stars
			if (ent:Visible(_ent)) then return high end
		end

		return low
	end

	--registers player within the environment quicker
	function ENVIRONMENTS:PlayerSpawn( ply )
		OnEntitySpawn( ply )

		ply.Environments = {}
		ply.EnvironmentValues = table.Copy(self.default_environment)
		ply:SetGravity( 1 )
		ply:SetHealth(100)
	end

	function ENVIRONMENTS:Think()
		self.NextThink = CurTime() + 0.5

		if (!self.Spacebuild) then return end

		if not table.HasValue(self.Entities, Entity(1)) then
			table.insert( self.Entities, Entity(1) )
		end

		for _, ent in pairs( self.Entities ) do
			if (!IsValid(ent)) then
				table.RemoveByValue( self.Entities, ent )
			continue end

			local values = table.Copy(self.space_environment)
			local valuesin = table.Copy(values)
			local pname = ""
			local pos = ent:GetPos()

			if (ent:IsPlayer() and !ent:Alive()) then
				values = table.Copy(self.default_environment)
			else
				for _, environment in pairs( ent:GetEnvironments() ) do
					if (!IsValid(environment)) then
						ent:RemoveEnvironment( environment )
					continue end

					local radius = environment:GetRadius()
					local epos = environment:GetPos()
					local distance = pos:Distance(epos)
					local onplanet = (distance <= radius)

					if (!onplanet) then
						ent:RemoveEnvironment( environment )
						continue
					elseif (environment:IsPlanet()) then
						pname = environment:GetName()
					end

					local e = environment:GetEnvironment()

					for name, value in pairs(values) do
						if type(e[name]) != "number" then continue end
						values[name] = values[name] + e[name]
						valuesin[name] = valuesin[name] + 1
					end
				end

				for name, value in pairs( values ) do
					if (valuesin[name] == 0) then
						values[name] = 0
					else
						values[name] = (value / valuesin[name])
					end
				end

				values.temperature = self:GetTemperature( ent, values.lowtemperature, values.hightemperature )

				if (values.gravity <= 0) then
					values.gravity = 0.0001
				end

				if (ent:WaterLevel() > 2) then
					values.oxygen = 0
					values.atmosphere = -1
				end
			end

			ent.EnvironmentValues = values
			ent:SetGravity( values.gravity )

			local phys = ent:GetPhysicsObject()

			if (phys and phys:IsValid()) then --need to have physics
				phys:Wake()
				phys:EnableGravity( values.gravity > 0.01 )
				phys:EnableDrag( values.gravity > 0.01 )
			end

			if (ent:IsPlayer()) then
				data.Send("SetEnvironment", values.oxygen, values.gravity, values.temperature, values.atmosphere, pname, ent )
			end
		end
	end

	function ENVIRONMENTS:EntityTakeDamage( ent, inflictor, attacker, amount, dmginfo )
		if (ent:GetClass() == "sb_planet") then return false end
		if (ent:GetClass() == "base_sb_environment") then return false end

		if (SB:ConfigInt("sb_spawndamage") == 1) then
			for _, ent in pairs( ent:GetEnvironments() ) do
				if (ent.spawnpoint) then return false end
			end
		end
	end

	function ENVIRONMENTS:PlayerShouldTakeDamage( ply, attacker )
		if (SB:ConfigInt("sb_spawndamage") == 1 && ply ~= attacker) then
			for _, ent in pairs(  ply:GetEnvironments() ) do
				if (IsValid(ent) and ent.spawnpoint) then return false end
			end
		end
	end

	function ENVIRONMENTS:AddPlanet( data )
		local ent = ents.Create("sb_planet")

		table.Merge( ent:GetTable(), data )
		ent:SetEnvironment( data )

		ent:SetPos( data.position )
		ent:Spawn()
		ent:Activate()
		ent:SetName( data.name )

		MsgN("Add Planet ", ent)

		if (data.star) then
			table.insert( self.Stars, ent ) --add to stars
		else
			table.insert( self.Planets, ent ) --add to planets
		end
	end

	function ENVIRONMENTS:InitPostEntity( )
		timer.Simple(1, function()
			--make sure our stuff gets registered
			if (!ents.CreateOld) then ents.CreateOld = ents.Create end
			function ents.Create( ... )
				local ent = ents.CreateOld( ... )
				if (ent and ent:GetClass() ~= "sb_planet") then OnEntitySpawn( ent ) end
				return ent
			end
		end)

		ENVIRONMENTS.Planets = {}
		ENVIRONMENTS.Stars = {}

		for _, ent in pairs(ents.FindByClass("sb_planet")) do
			ent:Remove()
		end

		SB:print("----------------------------------------")
		SB:print("-- Looking for environments:")

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
			local Type = tab.Case01

			if Type == "planet_color" then
				local color = {}
				color.id = tab.Case16
				color.addcol = Vector( tab.Case02 )
				color.mulcol = Vector( tab.Case03 )
				color.brightness = tonumber( tab.Case04 )
				color.contrast = tonumber( tab.Case05 )
				color.color = tonumber( tab.Case06 )

				Colors[color.id] = color

				SB:print("-- Color Found " .. color.id)

			elseif Type == "planet_bloom" then
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

				SB:print("-- Bloom Found" .. bloom.id)
			end
		end

		for _, ent in pairs( ents.FindByClass( "logic_case" ) ) do
			local tab = ent:GetKeyValues()
			local Type = tab.Case01
			local planet = {}

			if Type == "env_rectangle" then
				SB:print("--     Spacebuild Rectangle Found (Skipping)")
			elseif Type == "cube" then
				SB:print("--     Spacebuild Cube Found (Skipping)")
			elseif Type == "planet" then --sb2 planet
				local flags = tonumber(tab.Case16)

				local planet = {}
				planet.radius = tonumber(tab.Case02)
				planet.gravity = tonumber(tab.Case03)
				planet.atmosphere = tonumber(tab.Case04)
				planet.lowtemperature = tonumber(tab.Case05)
				planet.hightemperature = (tonumber(tab.Case06) || planet.lowtemperature)
				planet.colorid = tostring(tab.Case07)
				planet.color = Colors[planet.colorid]
				planet.bloomid = tostring(tab.Case08)
				planet.bloom = Blooms[planet.bloomid]
				planet.name = "Planet " .. #self.Planets + 1
				planet.position = ent:GetPos()
				planet.spawnpoint = self:IsSpawnPlanet(planet)
				planet.habitat = Extract_Bit(1, flags)
				planet.unstable = Extract_Bit(2, flags)
				planet.sunburn = Extract_Bit(3, flags)

				--sometimes SB2 planets use bloom ids that are the planet names. lets try to get it
				Extract_SBPlanetName( planet.bloomid, planet )
				Extract_SBPlanetName( planet.colorid, planet )

				if (planet.habitat) then
					planet.oxygen = 100
				else
					planet.oxygen = 0
				end

				planet.pressure = 1

				self:AddPlanet( planet )

				SB:print("-- Spacebuild2 Planet Found " .. planet.name)
			elseif Type == "planet2" then --sb3 planet
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
				planet.spawnpoint = self:IsSpawnPlanet(planet)

				self:AddPlanet( planet )

				SB:print("-- Spacebuild3 Planet Found " .. planet.name)
			elseif Type == "star" then
				SB:print("--- star")
				local star = {}
				star.radius = tonumber(tab.Case02)
				star.position = ent:GetPos()
				star.star = true

				self:AddPlanet( star )

				SB:print("-- Spacebuild2 Star Found " .. star.name)
			elseif Type == "star2" then
				local star = {}
				star.radius = tonumber(tab.Case02) --Get Radius
				star.gravity = tonumber(tab.Case03) --Get Gravity
				star.name = tostring(tab.Case06 || "Star")
				star.position = ent:GetPos()
				star.star = true

				self:AddPlanet( star )

				SB:print("-- Spacebuild3 Star Found " .. star.name)
			end
		end

		if (table.Count(self.Stars) == 0) then
			local star = {}
			star.radius = 1
			star.gravity = 0
			star.name = "Star"
			star.star = true
			star.position = Vector(0,0,13000)

			self:AddPlanet( star )

			SB:print("-- Star Manually Added")
		end

		self.Spacebuild = #ents.FindByClass("sb_planet") > 0

		SB:print("----------------------------------------")

		if (!self.Spacebuild) then
			SB:RemoveClass( self )

			SB:print("----------------------------------------")
			SB:print("ERROR: Not a Spacebuild map. Removing Environments.")
			SB:print("----------------------------------------")
		end
	end

	ENVIRONMENTS.OnReloaded = ENVIRONMENTS.InitPostEntity

	concommand.Add("sb_environments_reload", function()
		ENVIRONMENTS:InitPostEntity()
	end)

	function ENVIRONMENTS:PlayerNoClip( ply )
		if (ply:IsAdmin()) then
			return true
		else
			return self:OnPlanet( ply )
		end
	end

	local function GetPlanetsDetails( ply, cmd, args )
		local environments  = ply:GetEnvironments()

		for _, ent in pairs(environments) do
			if (!IsValid(ent)) then continue end

			local onplanet = ply:GetPos():Distance(ent:GetPos()) < ent:GetRadius()

			MsgN("----------------\n", ent)
			MsgN("OnEnvironment: ", onplanet)
			PrintTable(ent:GetEnvironment(), 1)
			MsgN("--- Entities")
			PrintTable(ent.Entities, 3)
			MsgN("--- Watch")
			PrintTable(ent.Watch, 3)
			MsgN("----------------")
		end
	end
	concommand.Add("sb_environments_details", GetPlanetsDetails)

	SB:print("Dev command: sb_environments_details")

	--[[
		META MODS
	]]
	local meta = FindMetaTable( "Entity" )

	meta.Environments = {}

	function meta:AddEnvironment( ent )
		self.Environments[ent:EntIndex()] = ent
	end

	function meta:RemoveEnvironment( ent )
		self.Environments[ent:EntIndex()] = nil
	end

	function meta:GetEnvironments()
		return self.Environments
	end
end

--Returns the planet entity if the position is within a planet
function ENVIRONMENTS:OnPlanet( pos )
	if (!pos) then return end
	if type(pos) == "Entity" or type(pos) == "Player" then pos = pos:GetPos() end

	for _, ent in pairs( ents.FindByClass("sb_planet") ) do
		if (ent.GetRadius and ent:GetPos():Distance(pos) < ent:GetRadius()) then
			return ent
		end
	end
end

local meta = FindMetaTable( "Entity" )

function meta:GetEnvironmentData()
	return self.EnvironmentValues or {gravity = 1, oxygen = 100, temperature = 288, atmosphere = 1}
end

function meta:GetPlanet()
	return ENVIRONMENTS:OnPlanet( self:GetPos() )
end

function meta:IsOnPlanet()
	return IsValid(ENVIRONMENTS:OnPlanet( self:GetPos() ))
end

function meta:IsOnSpawnPlanet()
	return IsValid(ENVIRONMENTS:OnPlanet( self:GetPlanet() ))
end

function meta:GetOxygen()
	return self:GetEnvironmentData().oxygen
end

function meta:GetTemperature()
	return self:GetEnvironmentData().temperature
end

SB:Register( ENVIRONMENTS )