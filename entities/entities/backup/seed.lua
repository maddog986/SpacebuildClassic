AddCSLuaFile("seed.lua")

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Seed"
ENT.Author	= "MadDog"

if CLIENT then return end

function ENT:Initialize()
	--self.BaseClass.Initialize(self)

	--self.Entity:SetModel( "models/gm_forest/tree_a.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	--self:SetUnFreezable( true )

	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:EnableMotion( false )
	end

	self.GermTime = 1
	self.GrowTime = 2
	self.StartSize = 0.01
	self.EndSize = math.random(0.8, 1)

	self.MaxTries = math.random(50, 150)
	self.Tries = 0
end

function ENT:OnTakeDamage( damage )
	if self:IsOnFire() then
	end
end



function ENT:InitGrow( germtime, growtime )
	self.GermTime = germtime --how long to wait to grow

	self:SetModelScale( self.StartSize )

	timer.Remove("seed" .. self:EntIndex())

	timer.Create("seed" .. self:EntIndex(), self.GermTime, 1, function()
		if (self.sounds) then
			self:EmitSound( self.sounds[ math.random(1, #self.sounds) ], self.GrowTime)
		end

		self:StartGrowing()
	end)

end

function ENT:StartGrowing()
	self:SetModelScale( self.StartSize, 0 )

	timer.Create( "growing" .. self:EntIndex(), 0.01, 0, function()
		if (!self) then return end

		if (!self.StartTime) then self.StartTime = CurTime() end
		local GrowthPercent = (CurTime() - self.StartTime) / self.GrowTime

		self:SetModelScale( math.Clamp(1 * GrowthPercent, 0, self.EndSize) )

		if ( self:GetModelScale() >= self.EndSize ) then
			self:StopGrowing()
		end
	end)
end

function ENT:StopGrowing()
	self:SetModelScale( self.EndSize, 0 )
	timer.Remove( "growing" .. self:EntIndex() )

	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:EnableMotion( false )
	end
end

function ENT:IsDoneGrowing()
	--MsgN("self:GetModelScale(): ", self:GetModelScale())
	return ( math.Round(self:GetModelScale(), 2) >= self.EndSize)
end

function ENT:OnRemove()
	timer.Remove( "seed" .. self:EntIndex() )
	timer.Remove( "growing" .. self:EntIndex() )
end

ENT.LastReproduce = 0

function ENT:Reproduce()
	if (self.LastReproduce > CurTime()) then return end --to soon
	self.LastReproduce = CurTime() + math.random(1, 2)

	if (self.MaxTries < self.Tries) then self:SetColor(Color(255,0,0,255)) return end --reached seed limit
	if (!self:IsDoneGrowing()) then
		self:SetColor(Color(0,0,0,255))
		--MsgN("self:GetModelScale(): ", math.Round(self:GetModelScale(), 2) , "-", self.EndSize)
	return end --must mature first to reproduce

	self:SetColor(Color(255,255,255,255))


	if (!SEEDS:CanPlant(self.Seed)) then return end



	local seed = SEEDS.Types[self.Seed]
	local spreeddistance = seed.SpreedDistance
	local spreedchance = seed.SpreedChance
	local chance = math.random(0,100)

	if (chance > spreedchance) then return end

	--up to 6 trys to plant a seed
	for i = 1, 6, 1 do
		self.Tries = self.Tries + 1

		local pos = self:GetPos() +  Vector( math.Rand( -spreeddistance[2], spreeddistance[2] ), math.Rand( -spreeddistance[2], spreeddistance[2] ), 20 )

		if (pos:Distance(self:GetPos()) < spreeddistance[1]) then continue end --gotta be min distance away

		local trace = util.TraceLine({
			start = pos,
			endpos = pos - Vector(0, 0, 80)
		})

		if (!trace.HitWorld or SEEDS:IsInWater(trace.HitPos)) then continue end

		pos = trace.HitPos --update the ground position

		--check to make sure conditions are good for new growth
		local ground = SEEDS.Materials[trace.MatType]

		if (ground != "Dirt" and ground != "Grass" and ground != "Sand") then continue end

		local toclose = false

		--debugoverlay.Sphere( pos, 20, 60, Color(0,255,255), true )

		for _, ent in pairs( ents.FindByClass( "seed" ) ) do
			if (ent.Seed == self.Seed and pos:Distance(ent:GetPos()) < spreeddistance[1]) then
				toclose = true
				break
			end
		end

		if (toclose) then continue end

		return SEEDS:Plant( pos, trace.HitNormal:Angle() + Angle(90, 0, 0), self.Seed, self.SeedType, self.Owner )
	end
end

function ENT:Think()
	if (self:IsTree() and self:IsDoneGrowing()) then
		local random = math.random(1, 50)

		if (random == 1) then
			self:EmitSound("ambient/crow4.wav")
		elseif (random == 2) then
			self:EmitSound("ambient/owl3.wav")
			--elseif (random >= 3 and random <= 10) then
			--	ent:EmitSound("/ambient/levels/forest/dist_birds" .. math.random(1, 6) .. ".wav")
			--elseif (random == 11) then
			--	ent:EmitSound("/ambient/levels/forest/flit1.wav")
			--elseif (random == 12) then
			--	ent:EmitSound("/ambient/levels/forest/peckr1.wav")
			--elseif (random == 13) then
			--	ent:EmitSound("/ambient/levels/forest/peckr2.wav")
			--elseif (random == 14) then
			--	ent:EmitSound("/ambient/levels/forest/chicka1.wav")
		elseif (random >= 45) then
		--	self:EmitSound("ambient/nature/wind_leaves_mild_gust_1.wav")
		end
	end

	self:Reproduce()

	self:NextThink( CurTime() + 1 )
	return true
end

--[[

SEEDS.Logs = {
	Models = {
		--"models/props_foliage/tree_slice_chunk01.mdl",
		--"models/props_foliage/tree_slice_chunk02.mdl",
		--"models/props_foliage/tree_slice_chunk03.mdl",
		"models/props_foliage/driftwood_03a.mdl",
		"models/props_foliage/driftwood_01a.mdl",
		"models/props_foliage/driftwood_02a.mdl"
	}
}


function SEEDS:EntityTakeDamage( ent, inflictor, attacker, amount, dmg )
	if !IsValid(ent) then return end

	if ent:IsBush() and !ent.Dead then
		ent.Dead = true
		SafeRemoveEntityDelayed(ent, math.random(1, 3))
		return
	elseif !ent:IsTree() then return end

	local damage = dmg:GetDamage()
	local ply = dmg:GetAttacker()

	if (ent.Life <= 0) then return end --already dead

	--reduce life
	ent.Life = math.Clamp(ent.Life - damage, 0, 20)
	if (ent.Life > 0) then return end --wait for tree to die


	local height = (ent:OBBMins() - ent:OBBMaxs()):Length()
	local pos = ent:GetPos()-ent:OBBMins()
	local angles = ent:GetAngles()

	--ent:SetModel( "models/props_foliage/tree_stump01.mdl" ) --change model to stump
	--ent:DropToFloor() --drop to the ground

	--max amount of logs to create per tree
	local maxLogs = height / 200
	local inc = 1

	local logs, stumps = 0,0
	local max = 200

	--spawn logs for the length/height of the tree
	while (height > 0) do
		--stop loop if we have reached the max amount of logs
		if (inc >= maxLogs) then break end

		--create the log fragment
		local log = ents.Create("prop_physics")
		if (!log) then return end

		log:SetModel( table.Random(SEEDS.Logs.Models) )
		log:SetAngles( Angle(90,0,0) )		--(Angle(math.random(0, 360), math.random(0, 360), math.random(0, 360)))
		log:SetPos( pos )-- + Vector(math.random(-15, 15), math.random(-15, 15), 0) )
		log:Spawn()
		log:Activate()
		log.SeedType = ent.SeedType --TODO: maybe make the stump reproduce after a long period?

		--get the size of the log
		local size = (log:OBBMins() - log:OBBMaxs()):Length()

		local phys = log:GetPhysicsObject()

		if (IsValid(phys)) then
			phys:SetMass(size * 10)
			phys:EnableMotion(false)
			phys:Sleep()
		end

		--update pos and height
		pos = pos + Vector(0, 0, size)	--reduce vector for next log spawn position
		height = height - size --reduce height to spawn next log
		inc = inc + 1 --increase log spawned count
	end

	ent:Remove()
end

]]