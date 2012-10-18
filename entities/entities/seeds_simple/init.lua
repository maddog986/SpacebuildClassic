AddCSLuaFile( 'cl_init.lua' )
AddCSLuaFile( 'shared.lua' )
include( 'shared.lua' )

function  ENT:Initialize()
	self.BaseClass.Initialize(self)

	self.Entity:DrawShadow( false )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )

	if (self:IsTree() or self:IsStump() or self:IsBush()) then
		self.Entity:SetMoveType( MOVETYPE_NONE )
	else
		self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	end

	self.Entity:SetSolid( SOLID_VPHYSICS )

	--set the life based off the model size
	self.Life = math.ceil(self:OBBMaxs():Length()) / 2
	self.SpawnTime = CurTime()

	local phys = self:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
	end
--[[
	if self:IsBush() then
		self.Foliage = ents.Create("prop_dynamic")

		if (self.Foliage) then
			self.Foliage:SetModel("models/props/pi_shrub.mdl")
			self.Foliage:SetPos(self:GetPos()+Vector(0,0,15))
			self.Foliage:Spawn()
			self.Foliage:Activate()
		end

		self:DeleteOnRemove(self.Foliage)
	end]]
end
--[[
function ENT:PhysicsSetup()
	local mins = self.Entity:OBBMins() * self.MaxHeight
	local maxs = self.Entity:OBBMaxs() * self.MaxHeight

	self.Entity:PhysicsInitBox( mins, maxs )
	self.Entity:SetCollisionBounds( mins, maxs )
end
]]
--[[
function ENT:OnRemove()
	if (!self.Owner) or (!self.Owner:IsValid()) or (!self.Type) then return end
--	self.Owner:RemoveItemCount( self.Type )
end
]]

function ENT:Think()
	self.BaseClass.Think(self)

	if self:IsOnFire() then
		self:TakeDamage(math.random(1, 5), self, self)
	end

	--[[
		Fire Spreading
	]]
	self:FireSpread()

	--[[
		Seed Reproduce
	]]
	self:Reproduce()

	--[[
		Forest sounding effects for trees
	]]
	if (self:IsTree()) then
		if (CurTime() >= (self.TreeNoiseUpdate or -10)) then --timer check to make sure node isnt updated to often
			self.TreeNoiseUpdate = CurTime() + math.random(5, 20)

			local random = math.random(1, 50)

			if (random == 1) then
				self:EmitSound("ambient/crow4.wav")
			elseif (random == 2) then
				self:EmitSound("ambient/owl3.wav")
			elseif (random >= 3 and random <= 10) then
				self:EmitSound("/ambient/levels/forest/dist_birds" .. math.random(1, 6) .. ".wav")
			elseif (random == 11) then
				self:EmitSound("/ambient/levels/forest/flit1.wav")
			elseif (random == 12) then
				self:EmitSound("/ambient/levels/forest/peckr1.wav")
			elseif (random == 13) then
				self:EmitSound("/ambient/levels/forest/peckr2.wav")
			elseif (random == 14) then
				self:EmitSound("/ambient/levels/forest/chicka1.wav")
			else
				self:EmitSound("ambient/nature/wind_leaves_mild_gust_1.wav")
			end
		end
	end

	self.Entity:NextThink( CurTime() + 1)
	return true
end

function ENT:OnTakeDamage( dmg )
	self.BaseClass.OnTakeDamage( self, dmg )

	if (self:IsTree()) then
		self:TreeHatchet( dmg )
	elseif (self:IsBush()) then
		self.Dead = true
		--self:Ignite()
		--self:Fire("Break", "", 0)

		SafeRemoveEntityDelayed(self, math.random(1, 3))
	end
end


function ENT:Use( activator, caller )
	if ( !activator:IsPlayer() ) then return end

	if (self:IsBush()) then
		self.Entity:Remove()
	end
end



function ENT:Touch( ent )
	if self:IsOnFire() and (ent:IsLog() or ent:IsTree() or ent:IsBush()) then
		ent:Ignite()
	end
end

function ENT:FireSpread()
	if (!self:IsOnFire()) then return end

	self.MaxHeight = (self.MaxHeight or 1) - 0.01

	if (self.MaxHeight <= 0) then
		self:Remove()
		return
	end

	--self:SetColor(255 * self.MaxHeight,255 * self.MaxHeight,255 * self.MaxHeight, 255)
	self:SetNWFloat("Resize", self.MaxHeight)

	--[[
		cant call PhysicsSetup to often (crashes game) so using a time check

	if (CurTime() >= (self.NextFireReduce or 0)) then
		self:PhysicsSetup()
		self.NextFireReduce = CurTime() + 1.5
	end
]]

	--Get near by props that we can light up :)
	for _, ent in pairs( ents.FindInSphere( self.Entity:GetPos(), 60 ) or {} ) do
		if (ent != self.Entity and !ent:IsOnFire() and (ent:IsLog() or ent:IsTree() or ent:IsBush())) then
			ent:Ignite()
		end
	end
end

--[[
	Makes the seeds so stuff reproduces
]]
function ENT:Reproduce()
	if (!self:IsTree() and !self:IsBush() or self:IsOnFire()) then return end
	if (self.Dead or self:GetNWBool( "Dead" )) then return end --is dead, cant reproduce

	--wait for seed to mature
	if (self.SpawnTime and CurTime() < ( self.SpawnTime + SB.seeds.Types[self.SeedType].GrowthTime)) then return end

	local growrate = (SB.seeds.Types[self.SeedType].Grow)

	if (math.random(1,100) > growrate) then return end

	local max = SB.seeds.Types[self.SeedType].Max or 1000
	local count = SB.seeds.Types[self.SeedType].Count or 0

	if (count > max) then
	return end --max seeds already planted

	for variable = 1, 8, 1 do
		local mindistance = SB.seeds.Types[self.SeedType].MinDistance or 100
		local distance = SB.seeds.Types[self.SeedType].Distance or 400

		local pos = self:GetPos() + Vector(math.random(-distance,distance),math.random(-distance,distance),math.random(-distance,distance))

		local tr = util.TraceLine({
			start = pos,
			endpos = pos - Vector(0, 0, math.random(10, 200))
		})

		if (!tr.HitWorld) then continue end

		local ground = SEEDS.Materials[tr.MatType]

		pos = tr.HitPos --update the ground position

		--check to make sure conditions are good for new growth
		if (ground != "Dirt" and ground != "Grass" and ground != "Sand") or SEEDS.IsInWater(pos) then continue end

		local toclose = false

		--make sure it doesnt spawn so close
		for _, ent in pairs( ents.FindInSphere( pos, mindistance) ) do
			if (ent.SeedType and ent.SeedType == self.SeedType) then
				toclose = true
				break
			end
		end

		if (toclose) then continue end

		SEEDS.PlantSeed( pos, tr.HitNormal:Angle() + Angle(90, 0, 0), self.SeedType, self.SeedName, self.Owner )

		break --we got our seed planted
	end

end


--[[
	Splits out tree chunks after enough damage
]]
function ENT:TreeHatchet( dmg )
	local damage = dmg:GetDamage()
	local ply = dmg:GetAttacker()

	if (self.Life == 0) then return end --already dead

	--reduce life
	self.Life = math.Clamp(self.Life - damage, 0, 20)

	--if tree is now dead break it up into logs
	if !(self.Life == 0) then return end

	local pos = self:GetPos()
	local height = (self:OBBMins() - self:OBBMaxs()):Length()
	local onfire = self:IsOnFire()
	local angles = self:GetAngles()

	--remove tree since its chopped up now
	self:Remove()

	--Create a new stump entity to replace tree
	local stump = ents.Create("seeds")

	if (!stump) then return end

	local tr = util.TraceLine({
			start = pos + Vector(0, 0, 80),
			endpos = pos - Vector(0, 0, 800)
		})

	stump:SetModel( "models/props_foliage/tree_stump01.mdl" )
	stump:SetPos( tr.HitPos )
	stump:SetAngles( angles )
	stump:Activate()
	stump:Spawn()
	stump:SetNWInt("GrowthTime", 0.1)
	stump.SeedType = self.SeedType
	stump.Dead = true --mark as dead so it doesnt spawn seeds

	timer.Simple(math.random(20, 40), function()
		SB.seeds.LogCleanup( stump )
	end)

	--get the first position to place the logs
	local pos = stump:GetPos()

	--max amount of logs to create per tree
	local maxLogs = height / 200
	local inc = 1

	local logs, stumps = 0,0
	local max = 200

	if !game.SinglePlayer() then
		max = 40
	end

	--some extra cleanup for multiplayer (performance reasons)
	for _, ent in pairs( ents.FindByClass( "seeds" ) ) do
		if ent:IsLog() then
			logs = logs + 1

			if (logs > max) then SafeRemoveEntity(ent) end
		elseif ent:IsStump() then
			stumps = stumps + 1

			if (stumps > max/3) then SafeRemoveEntity(ent) end
		end
	end


	--spawn logs for the length/height of the tree
	while (height > 0) do
		--stop loop if we have reached the max amount of logs
		if (inc >= maxLogs) then break end

		--create the log fragment
		local log = ents.Create("seeds")

		if (!log) then return end

		log:SetMoveType( MOVETYPE_VPHYSICS )
		log:SetModel( table.Random(SB.seeds.Logs.Models) )
		log:SetPos( pos + Vector(math.random(1, 15), math.random(1, 15), 0) )
		log:Spawn()
		log:Activate()
		log:SetNWInt("GrowthTime", 0.1)
		log.SeedType = self.SeedType
		log.Dead = true

		timer.Simple(math.random(20, 40), function()
			SB.seeds.LogCleanup( log )
		end)

		--if tree was on fire, so are the logs :)
		if (onfire) then log:Ignite() end

		--get the size of the log
		local size = (log:OBBMins() - log:OBBMaxs()):Length()

		--update pos and height
		pos = pos + Vector(0, 0, size)	--reduce vector for next log spawn position
		height = height - size	--reduce height to spawn next log
		inc = inc + 1 --increase log spawned count
	end
end