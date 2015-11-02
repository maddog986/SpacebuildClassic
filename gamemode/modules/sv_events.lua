--[[

	Author: MadDog (steam id md-maddog)

	TODO:
		- Add more events to planets
		- Code an admin tool to allow admins to change events per planet
]]
--[[
	Add options to admin panel
]]
OPTIONS:Register({
	tab = "Framework Settings",
	name = "Planet Gravity Settings",
	type = "label",
	admin = true
})

OPTIONS:Register({
	tab = "Framework Settings",
	name = "Gravity Update Interval",
	var = "update_gravity",
	type = "slider",
	level = "server",
	min = 0,
	max = 5,
	decimal = 1,
	default = 0.1,
	admin = true
})

OPTIONS:Register({
	tab = "Framework Settings",
	name = "Gravity Force Multipler",
	var = "gravity_force",
	type = "slider",
	level = "server",
	min = 0,
	max = 1,
	decimal = 6,
	default = 0.000009,
	admin = true
})

OPTIONS:Register({
	tab = "Framework Settings",
	name = "Planets Event Settings",
	type = "label",
	admin = true
})

OPTIONS:Register({
	tab = "Framework Settings",
	name = "Unstable Planets Interval (0 = Disable)",
	var = "update_unstable",
	type = "slider",
	level = "server",
	min = 0,
	max = 500,
	default = 30,
	admin = true
})

OPTIONS:Register({
	tab = "Framework Settings",
	name = "Meteors Interval (0 = Disable)",
	var = "update_meteors",
	type = "slider",
	level = "server",
	min = 0,
	max = 500,
	default = 15,
	admin = true
})


EVENTS = {}
EVENTS.Name = "Events"
EVENTS.Author = "MadDog"
EVENTS.Version = 1
EVENTS.events = {}

function EVENTS:AddEvent( name, func )
	if type(func) == "table" then
		self.events[name] = func
	else
		self.events[name] = {func = func}
	end
end

function EVENTS:RemoveEvent( name )
	self.events[name] = nil
end

function EVENTS:Think()
	if (!GAMEMODE:GetClass( "Environments" )) then
		self.NextThink = CurTime() + 5
	return end

	for _, event in pairs(EVENTS.events) do
		if (event.NextUpdate and event.NextUpdate >= CurTime()) then continue end

		for _, planet in pairs( ents.FindByClass("sb_planet") ) do
			event.func( event , planet )
		end
	end
end

GM:Register( EVENTS )


--[[
	Change gravity for entities on planet
]]
EVENTS:AddEvent("gravity", function( self, planet )
	self.NextUpdate = CurTime() + OPTIONS:Get("update_gravity", 0.1)

	if (!planet:IsPlanet()) then return end

	local entities = planet:GetEntities()

	--planet.Watch contains entities that are out of the planet and within its gravity pull (between radius and radius * 1.5)
	for i, ent in pairs( ents.FindInSphere(planet:GetPos(), planet:GetRadius() * 1.5) ) do
		if !IsValid(ent) or !ent.GetAtmosphere then continue end
		if (ent == planet) then continue end
		if (!ENVIRONMENTS.Entities[ent:EntIndex()]) then continue end
		if (entities[ent:EntIndex()]) then continue end --within environment so skip
		if (ent:GetAtmosphere() > 0) then continue end --in artifical environment so skip

		local phys = ent:GetPhysicsObject()

		if !IsValid(phys) or !phys:IsMotionEnabled() then continue end

		phys:Wake()

		local radius = planet:GetRadius()
		local gradius = planet:GetGravityRadius()
		local ppos = planet:GetPos()
		local epos = ent:GetPos()
		local distance = ppos:Distance(epos)

		local force = (gradius - (distance - radius)) * OPTIONS:Get("gravity_force", 0.000009)

		--MsgN(self, " pulling ", ent)

		if (ent:IsPlayer()) then --apply player force
			ent:SetVelocity( (ppos - epos) * force * 0.1 )
		else
			phys:ApplyForceCenter( (ppos - epos) * (phys:GetMass() * force) * 0.1 )
		end
	end
end)

--[[
	TODO: Update this once the Terra Forming stuff is complete. Add Trees (maybe even plants) to newly Terra Formed planets

EVENTS:AddEvent("trees", function( self, planet )
	self.NextUpdate = CurTime() + OPTIONS:Get("sb_update_trees", 1)

	planet.Trees = 0

	for i, ent in pairs( ents.FindInSphere(planet:GetPos(), planet:GetRadius()) ) do
		if !IsValid(ent) then continue end
		if (ent.IsTree and ent:IsTree()) then planet.Trees = planet.Trees + 1 end
	end

	planet:SetNWBool("Raining", (planet.Trees > 40) ) --rain forest always rain :)
end)
]]

--[[
	UNSTABLE PLANETS
]]
EVENTS:AddEvent("unstable", function( self, planet )
	self.NextUpdate = CurTime() + OPTIONS:Get("update_unstable", 30)

	if (OPTIONS:Get("update_unstable", 30) == 0) then return end --disabled

	if (!planet.environment) then return end
	if (!planet.environment.unstable or planet.environment.unstable == 0) then return end --only want unstable planets

	--get position of planet
	local pos = planet:GetPos()
	local radius = planet:GetRadius()
	local shaketime = math.random(1, 8)

	util.ScreenShake( pos, shaketime, 1, math.random(1, 3), radius)
	sound.Play(Sound("ambient/explosions/exp" .. math.random(1, 4) .. ".wav"), pos, 100, 100) --earth quake sounds
end)


--[[
	METEORS
]]
EVENTS:AddEvent("meteors", function( self, planet )
	local time = 10--OPTIONS:Get("update_meteors", 15)

	if (time == 0) then return end --disable

	self.NextUpdate = CurTime() + time

	if (!planet.environment) then return end

	if (!planet.environment.unstable or planet.environment.unstable == 0) then return end --only want unstable planets
	if (table.Count(planet.entities) == 0) then return end --wait tell someone is on it to reduce lag, TODO: fix

	--get position of planet
	local Pos = planet:GetPos()
	local radius = planet:GetRadius()
	local num = 10

	if math.random(1, 20) > 19 then num = 20 end
	if math.random(1, 50) > 49 then num = 40 end

	--cleanup incase some are left behind for some reason
	for _, meteor in pairs( ents.FindByClass("sb_meteor") ) do
	--	if !meteor:GetPlanet() or meteor:GetPlanet() == planet then meteor:Remove() end
	end

	local Spread = 8

	for i = 0, num, 1 do
		timer.Simple(math.random(0.5, time), function()
			if (!IsValid(planet)) then return end

			local Ang = math.random(0, 360)
			local Offset = planet:GetUp()*math.sin(Ang)*(radius/2) + planet:GetRight()*math.cos(Ang)*(radius/2)
			local pos = Pos + Offset
			--local Dir = (pos - planet:GetPos())
			local Dir = planet:GetForward() + planet:GetUp()*math.Rand(Spread,Spread*-1) + planet:GetRight()*math.Rand(Spread,Spread*-1)
			local Angles = Dir:Angle()

			local Met = ents.Create("sb_meteor")
			local x = math.random(pos.x, pos.x + (radius/2))
			local y = math.random(pos.y, pos.y + (radius/2))

			pos = Vector(x,y, Pos.z + radius)

			if (IsValid(Met)) then
				Met:SetPos( pos )
				Met:SetAngles( Angles )
				Met:Spawn()
				Met:Activate()
			end
		end)
	end
end)