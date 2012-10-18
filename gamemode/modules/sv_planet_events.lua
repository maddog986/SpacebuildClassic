--[[

	Author: MadDog (steam id md-maddog)

	TODO:
		- Add more events to planets
		- Code an admin tool to allow admins to change events per planet
]]
local EVENTS = {}

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
	if (!SB:GetClass( "Environments" )) then
		self.NextThink = CurTime() + 5
	return end

	for _, event in pairs(EVENTS.events) do
		if (event.NextUpdate and event.NextUpdate >= CurTime()) then continue end

		for _, planet in pairs( SB:GetClass( "Environments" ).Planets ) do
			event.func( event , planet )
		end
	end
end

SB:Register( EVENTS )





--[[
	Change gravity for entities on planet
]]
EVENTS:AddEvent("gravity", function( self, planet )
	self.NextUpdate = CurTime() + SB:ConfigFloat("sb_update_gravity", 0.1)

	--planet.Watch contains entities that are out of the planet and within its gravity pull (between radius and radius * 1.5)
	for i, ent in pairs( planet.Watch or {} ) do
		if !IsValid(ent) then continue end

		local phys = ent:GetPhysicsObject()

		if !IsValid(phys) then return end

		phys:Wake()

		local radius = planet:GetRadius()
		local gradius = planet:GetGravityRadius()
		local ppos = planet:GetPos()
		local epos = ent:GetPos()
		local distance = ppos:Distance(epos)

		if (distance < radius or distance > gradius) then return end --not far enough out yet // gone

		local force = (gradius - (distance - radius)) * SB:ConfigFloat("sb_gravity_force", 0.000009)

		if (ent:IsPlayer()) then --apply player force
			ent:SetVelocity( (ppos - epos) * force * 0.1 )
		else
			phys:ApplyForceCenter( (ppos - epos) * (phys:GetMass() * force) * 0.1 )
		end
	end
end)

--[[
	TODO: Update this once the Terra Forming stuff is complete. Add Trees (maybe even planets) to newly Terra Formed planets

EVENTS:AddEvent("trees", function( self, planet )
	self.NextUpdate = CurTime() + SB:ConfigFloat("sb_update_trees", 1)

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
	self.NextUpdate = CurTime() + SB:ConfigFloat("sb_update_unstable", 30)

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
	local time = SB:ConfigFloat("sb_update_meteors", 15)

	self.NextUpdate = CurTime() + time

	if (!planet.environment.unstable or planet.environment.unstable == 0) then return end --only want unstable planets
	if (table.Count(planet.Entities) == 0 and table.Count(planet.Watch) == 0) then return end --wait tell someone is on it

	--get position of planet
	local Pos = planet:GetPos()
	local radius = planet:GetRadius()
	local num = 10

	if math.random(1, 20) > 19 then num = 20 end
	if math.random(1, 50) > 49 then num = 40 end

	--cleanup incase some are left behind for some reason
	for _, meteor in pairs( ents.FindByClass("meteor") ) do
		if !SB:GetClass( "Environments" ):OnPlanet(meteor) or SB:GetClass( "Environments" ):OnPlanet(meteor) == planet then meteor:Remove() end
	end

	local Spread = 8

	for i = 0, num, 1 do
		timer.Simple(math.random(0.5, time), function()
			local Ang = math.random(0, 360)
			local Offset = planet:GetUp()*math.sin(Ang)*(radius/2) + planet:GetRight()*math.cos(Ang)*(radius/2)
			local pos = Pos + Offset
			local Dir = (pos - planet:GetPos())--planet:GetForward() + planet:GetUp()*math.Rand(Spread,Spread*-1) + planet:GetRight()*math.Rand(Spread,Spread*-1)
			local Angles = Dir:Angle()

			local Met = ents.Create("meteor")
			Met:SetPos( pos )
			Met:SetAngles( Angles )
			Met:Spawn()
			Met:Activate()
		end)
	end
end)