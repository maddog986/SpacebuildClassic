AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

local sounds = {"/weapons/explode1.wav","/weapons/explode2.wav","/weapons/explode3.wav","/weapons/explode4.wav"}

for _,sound in pairs(sounds) do
	Sound(sound)
end

function ENT:Initialize()
	self.BaseClass.Initialize(self)

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetAngles(Angle(math.random(1, 360), math.random(1, 360), math.random(1, 360)))
	self:SetGravity(0.00001)

	self.IsAsteroid = 1
	self.CDSIgnore = true

	local phys = self:GetPhysicsObject()

	if(!phys:IsValid()) then MsgN("asteroid has no physics? " .. self:GetModel()); self:Remove(); return end

	local size = math.Clamp(phys:GetVolume() * 0.00001, 10, 400)

	phys:Wake()
	phys:SetMass(size * 16)
	phys:EnableDrag(true)
	phys:EnableGravity(false)
--[[	phys:EnableMotion(false)
	phys:Sleep()

	timer.Simple(3, function()
		phys:Sleep()
	end)
]]
	self.AsteroidHealth = size * 3

	local res_chance = math.random(1, 100)

	if ( res_chance <= 10 ) then
		res_rarity = 1
	elseif ( res_chance <= 40 ) then
		res_rarity = 2
	else
		res_rarity = 3
	end

	self.Resource = {}
	self.Resource.rarity = res_rarity
	self.Resource.name = SB:GetClass("Asteroids"):GetResource(res_rarity)
	self.Resource.yield = math.random(1, math.floor(size))

	--self:SetMoveType(MOVETYPE_NONE)
end

local FadeTime = 10

function ENT:ReleaseResources()
	if (self.Dead) then return end --already exploding
	self.Dead = true

	local Effect = EffectData()
	Effect:SetEntity(self)
	Effect:SetScale(math.random(3, 5))
	Effect:SetMagnitude(self:BoundingRadius()*4)
	util.Effect("cds_disintergrate", Effect, true, true)

	local try = math.ceil(self.Resource.yield/20)

	local height = (self:OBBMins() - self:OBBMaxs()):Length()

	for var = 0, (height/70), 1  do
		local raw = ents.Create( "raw_asteroid" )

		raw:SetModel( table.Random({
			"models/props_coalmines/boulder2.mdl",
			"models/props_coalmines/boulder3.mdl",
			"models/props_coalmines/boulder4.mdl"
		}) )

		if height < (raw:OBBMins() - raw:OBBMaxs()):Length()*1.1 then --most be smalelr than the curent one
			raw:Remove()
			continue
		end

		raw:SetPos( self:GetPos()+(VectorRand()*40) )
		raw:SetAngles( Angle(math.random(0, 360), math.random(0, 360), math.random(0, 360)) )
		raw:Spawn()
		raw:Activate()

		local phys = raw:GetPhysicsObject()

		phys:EnableMotion(true)
		phys:EnableGravity(false)
		phys:ApplyForceCenter(raw:GetUp() * 1)
		phys:SetMass(math.Clamp(phys:GetVolume() * 0.00001, 10, 400) * 16)

		SafeRemoveEntityDelayed(raw, 20)
--[[
		timer.Create("A"..raw:EntIndex(), 0.1, 0, function(ent)
			if (!IsValid(ent)) then timer.Destroy("A"..ent:EntIndex()); return end
			 local color = ent:GetColor()

			 color.a = color.a - 2

			 ent:SetColor(color)

			 if (color.a <= 0) then
				timer.Destroy("A"..ent:EntIndex())
				ent:Remove()
			end
		end, raw)]]
	end

	for var = 0, math.min((height/150), 1), 1  do
		local raw = ents.Create( "raw_resource" )

		raw:SetPos( self:GetPos()+(VectorRand()*40) )
		raw:SetAngles( Angle(math.random(0, 360), math.random(0, 360), math.random(0, 360)) )
		raw:Spawn()

		local phys = raw:GetPhysicsObject()
		phys:EnableMotion(true)
		phys:EnableGravity(false)
		phys:ApplyForceCenter(raw:GetUp() * 200)

		raw.resource = table.Copy(self.Resource) --save resource info

		if (raw.resource.rarity == 3) then
			raw:SetColor( Color(255, 0, 0, 255) )
		elseif (raw.resource.rarity == 2) then
			raw:SetColor( Color(0, 255, 0, 255) )
		elseif (raw.resource.rarity == 1) then
			raw:SetColor( Color(0, 0, 255, 255) )
		end

		raw:SetOverlayText( raw.resource.name .. ": " .. raw.resource.yield )
	end

	self:EmitSound(table.Random(sounds))

	SafeRemoveEntityDelayed(self, 0.1)
end

function ENT:OnTakeDamage( dmginfo )
	self.AsteroidHealth = self.AsteroidHealth - dmginfo:GetDamage()

	if (self.AsteroidHealth > 0) then return end

	self:ReleaseResources()
end