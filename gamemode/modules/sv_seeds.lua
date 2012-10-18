SEEDS = {} --create the roleplay part of this game

SEEDS.Types = {
	Tree = {
		Distance = 800,
		MinDistance = 150,
		Grow = 2,
		GrowthTime = 45,
		Max = 40,

		Other = {
			"models/props/de_inferno/tree_large.mdl",
			"models/props/de_inferno/tree_small.mdl"
		},

		Pine = {
			"models/props_foliage/tree_pine04.mdl",
			"models/props_foliage/tree_pine05.mdl",
			"models/props_foliage/tree_pine06.mdl",
			"models/props_foliage/tree_pine_01.mdl",
			"models/props_foliage/tree_pine_03.mdl",
			"models/props_foliage/tree_pine_large.mdl",
			"models/props_foliage/tree_pine_tall_02.mdl"
		}
	},
	Bush = {
		Distance = 100,
		MinDistance = 40,
		Grow = 2,
		GrowthTime = 25,
		Max = 60,

		Other = {
			"models/props_foliage/bush2.mdl"
		},

		Ferns = {
			"models/props_swamp/fern_01.mdl",
			"models/props_swamp/fern_02.mdl",
			"models/props_swamp/fern_03.mdl",
			"models/props_swamp/fern_04.mdl",
			"models/props_swamp/fern_05.mdl",
			"models/props_swamp/fern_06.mdl"
		},

		Shrooms = {
			"models/props_swamp/shroom_ref_01.mdl",
			"models/props_swamp/shroom_ref_01_cluster.mdl"
		}
	},
	Grass = {
		Distance = 100,
		MinDistance = 40,
		Grow = 100,
		GrowthTime = 15,
		Max = 60,

		Small = {
			"models/props_foliage/grass3.mdl",
			"models/props_foliage/grass_cluster01.mdl",
			"models/props_foliage/grass_cluster01a.mdl"
		},

		Tall = {
			"models/props_swamp/tallgrass_01.mdl",
			"models/props_swamp/tallgrass_02.mdl",
			"models/props_swamp/tallgrass_03.mdl",
			"models/props_swamp/tallgrass_04.mdl",
			"models/props_swamp/tallgrass_05.mdl",
			"models/props_swamp/tallgrass_06.mdl",
			"models/props_swamp/tallgrass_07.mdl",
			"models/props_swamp/tallgrass_08.mdl",
			"models/props_foliage/cattails.mdl",
			"models/props_foliage/small_cattails.mdl"
		},

		CatTails = {
			"models/props_foliage/cattails.mdl"
		}
	}
}

if CLIENT then return end

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

SEEDS.Materials = {}
SEEDS.Materials[MAT_CONCRETE] = "Concrete"
SEEDS.Materials[MAT_METAL] = "Iron"
SEEDS.Materials[MAT_DIRT] = "Wood"
SEEDS.Materials[MAT_VENT] = "Iron"
SEEDS.Materials[MAT_GRATE] = "Iron"
SEEDS.Materials[MAT_TILE] = "Stone"
SEEDS.Materials[MAT_SLOSH] = "Wood"
SEEDS.Materials[MAT_WOOD] = "Wood"
SEEDS.Materials[MAT_COMPUTER] = "Iron"
SEEDS.Materials[MAT_GLASS] = "Glass"
SEEDS.Materials[MAT_FLESH] = "Wood"
SEEDS.Materials[MAT_BLOODYFLESH] = "Wood"
SEEDS.Materials[MAT_CLIP] = "Wood"
SEEDS.Materials[MAT_ANTLION] = "Wood"
SEEDS.Materials[MAT_ALIENFLESH] = "Wood"
SEEDS.Materials[MAT_FOLIAGE] = "Wood"
SEEDS.Materials[MAT_PLASTIC] = "Wood"
SEEDS.Materials[MAT_DIRT] = "Dirt"
SEEDS.Materials[MAT_SAND] = "Sand"


function SEEDS:IsTouching( pos, class, range )
	for _, ent in pairs( ents.FindInSphere(pos, range) ) do
		local _pos = ent:LocalToWorld(ent:OBBCenter())

		if (ent:GetClass() == class) and ((pos-Vector(_pos.x, _pos.y, pos.z)):Length() <= range) then
			return true
		end
	end

	return false
end

function SEEDS:IsInWater( pos )
	local tr = {}
	tr.start = pos
	tr.endpos = pos + Vector(0,0,1)
	tr.mask = bit.bor(MASK_WATER, MASK_SOLID)

	return util.TraceLine(tr).Hit
end

--this function creates a plant that will grow
function SEEDS.DoPlant( ply, cmd, args )
	local tr = ply:GetEyeTrace()

	if (!tr.HitWorld) then
		ply:ChatPrint( "Aim at the ground to plant." )
		return
	end

	local seed = args[1]
	local name = args[2]

	if (!seed) or (!SEEDS.Types[seed]) or (!name) then
		ply:ChatPrint( "Sorry the seed is not valid (" .. seed.. "-" .. name .. ")." )
		return
	end

	local ground = SEEDS.Materials[tr.MatType]

	--check to make sure conditions are good
	if (ground == "Dirt" or ground == "Grass" or ground == "Sand") and (!SEEDS:IsInWater(tr.HitPos)) then
		if (SEEDS:IsTouching( tr.HitPos, "seeds", 30 )) then
			ply:ChatPrint( "You need more distance between seeds/props." )
		else
			SEEDS:Plant( tr.HitPos, tr.HitNormal:Angle() + Angle(90, 0, 0), seed, name )
		end
	else
		ply:ChatPrint( "You cannot plant on this terrain (" .. ground .. ")." )
	end
end
concommand.Add("plant", SEEDS.DoPlant)

--plant the seed
function SEEDS:Plant( pos, ang, type, name, owner )
	local seed = ents.Create("seeds")

	seed:SetModel( "models/weapons/w_bugbait.mdl" )
	seed:SetPos( pos )
	seed:SetAngles( ang )
	seed:Spawn()
	seed:Activate()

	seed.SeedType = type
	seed.SeedName = name

	timer.Simple(1, function()
		SEEDS:Grow(seed)
	end)
end

function SEEDS:Grow( seed )
	if (!IsValid(seed)) then return end

	local type = seed.SeedType
	local name = seed.SeedName
	local info = SEEDS.Types[type]
	local model = table.Random(info[name])

	if !util.IsValidModel(model) then MsgN( "Model for seed is not valid (" .. model .. ")." ); return end

	local pos = seed:GetPos()
	local tr = util.TraceLine({
		filter = seed,
		start = pos + Vector(0,0,(seed:OBBMins() - seed:OBBMaxs()):Length()),
		endpos = pos
	})

	seed:SetModel( model )
	--seed:SetPos( tr.HitPos ) --stump goes underground to fix some collison issues

	if (type == "Tree") then
		seed:EmitSound("/ambient/atmosphere/terrain_rumble1.wav", 80)
	end

	--seed:DropToFloor()
	seed.SpawnTime = CurTime()
	seed:SetNWInt("GrowthTime", info.GrowthTime or 30 )

	local phys = seed:GetPhysicsObject()

	if (IsValid(phys)) then
		phys:EnableMotion(false)
		phys:Sleep()
	end
end

function SEEDS:Think()
	self.NextThink = CurTime() + 5

	for seed, data in pairs(self.Types) do
		data.Count = 0
	end

	local seeds = ents.FindByClass("seeds")

	for _, ent in pairs( seeds ) do
		for seed, data in pairs(self.Types) do
			if (ent.SeedType == seed) then
				data.Count = data.Count + 1
			end
		end
	end

	for _, ent in pairs( seeds ) do

		if ent:IsOnFire() then
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
		else
			self:Reproduce( ent )

			if (ent:IsTree()) then
				if (CurTime() >= (ent.TreeNoiseUpdate or -10)) then --timer check to make sure node isnt updated to often
					ent.TreeNoiseUpdate = CurTime() + math.random(1, 5)

					local random = math.random(1, 50)

					if (random == 1) then
						ent:EmitSound("ambient/crow4.wav")
					elseif (random == 2) then
						ent:EmitSound("ambient/owl3.wav")
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
					elseif (random >= 30) then
						ent:EmitSound("ambient/nature/wind_leaves_mild_gust_1.wav")
					end
				end
			end
		end
	end
end

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

concommand.Add("remove_plants", function()
	for _, ent in pairs( ents.GetAll() ) do
		if (ent.SeedType) then ent:Remove() end
	end
end)







function SEEDS:Reproduce( ent )
	if (!ent:IsTree() and !ent:IsBush()) then return  end
	if ent:IsOnFire() then return end
	if (ent.Dead or ent:GetNWBool( "Dead" )) then return end --is dead, cant reproduce

	local max = self.Types[ent.SeedType].Max or 1000
	local count = self.Types[ent.SeedType].Count or 0

	if (count > max) then return  end --max seeds already planted

	--wait for seed to mature
	if (ent.SpawnTime and CurTime() < ( ent.SpawnTime + self.Types[ent.SeedType].GrowthTime)) then return end

	local growrate = (self.Types[ent.SeedType].Grow)
	if (math.random(1,100) > growrate) then return end

	--up to 8 trys to plant a seed
	for variable = 1, 8, 1 do
		local mindistance = self.Types[ent.SeedType].MinDistance or 100
		local distance = self.Types[ent.SeedType].Distance or 400

		local pos = ent:GetPos() + Vector(math.random(-distance,distance),math.random(-distance,distance),math.random(-distance,distance))

		local tr = util.TraceLine({
			start = pos,
			endpos = pos - Vector(0, 0, math.random(10, 200))
		})

		if (!tr.HitWorld) then continue end

		local ground = self.Materials[tr.MatType]

		pos = tr.HitPos --update the ground position

		--check to make sure conditions are good for new growth
		if (ground != "Dirt" and ground != "Grass" and ground != "Sand") or SEEDS:IsInWater(pos) then continue end

		local toclose = false

		--make sure it doesnt spawn so close
		for _, ent in pairs( ents.FindInSphere( pos, mindistance) ) do
			if (ent.SeedType and ent.SeedType == ent.SeedType) then
				toclose = true
				break
			end
		end

		if (toclose) then continue end

		SEEDS:Plant( pos, tr.HitNormal:Angle() + Angle(90, 0, 0), ent.SeedType, ent.SeedName )

		break --we got our seed planted
	end

end


SB:Register( SEEDS )























local _ent = FindMetaTable("Entity")

--returns true or false if the model matches the entity (used for other functions)
function _ent:IsModelMatch( tbl )
	local model = string.lower(self:GetModel() or "")

	for _, _model in pairs( tbl or {}) do
		_model = string.lower(_model)

		if (model == _model) or (model == string.gsub(_model,"/","\\")) then
			return true
		end
	end

	return false
end

--checks model to see if its a tree
function _ent:IsTree()
	for _, info in pairs(SEEDS.Types.Tree or {}) do
		if type(info) == "table" then
			if (self:IsModelMatch(info)) then return true end
		end
	end

	return false
end

function _ent:IsBush()
	for _, info in pairs(SEEDS.Types.Bush or {}) do
		if type(info) == "table" then
			if (self:IsModelMatch(info)) then return true end
		end
	end

	for _, info in pairs(SEEDS.Types.Grass or {}) do
		if type(info) == "table" then
			if (self:IsModelMatch(info)) then return true end
		end
	end

	return false
end

--checks model to see if its a rock
function _ent:IsRock()
	return self:IsModelMatch( SEEDS.Types.Rock.Models or {} )
end



--[[
--this function ignites a prop
function SEEDS.StartFire( ply, cmd, args )
	local tr = ply:GetEyeTrace()
	local ent = tr.Entity

	if (!IsValid(ent)) then return end

	ent:Ignite( 2 )
end
concommand.Add("SEEDS_startfire", SEEDS.StartFire)



--this function ignites a prop
function SEEDS.StopFire( ply, cmd, args )
	local tr = ply:GetEyeTrace()
	local ent = tr.Entity

	if (!IsValid(ent)) then return end

	ent:Extinguish()
end
concommand.Add("SEEDS_stopfire", SEEDS.StopFire)

]]
