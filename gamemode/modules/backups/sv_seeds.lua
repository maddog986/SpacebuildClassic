--[[

	Author: MadDog (steam id md-maddog)

	TODO:
		- Finished/improve.
]]

if true then return end

SEEDS = {} --create the roleplay part of this game
SEEDS.Name = "Seeds"
SEEDS.Author = "MadDog"
SEEDS.Version = 1

SEEDS.Types = {
	Tree = {
		SpreedChance = 100,
		SpreedDistance = {100, 300},
		GrowthTime = 15,
		Max = 40,
		Germinate = 1,
		Sounds = {"ambient/atmosphere/terrain_rumble1.wav"},
		Other = {
			"models/cherokemodels/palmy/strom1.mdl",
			"models/cherokemodels/palmy/strom2.mdl",
			"models/cherokemodels/palmy/tree_big03.mdl"
		},
		Other2 = {
			"models/gm_forest/tree_a.mdl",
			"models/gm_forest/tree_b.mdl",
			"models/gm_forest/tree_c.mdl",
			"models/gm_forest/tree_d.mdl",
			"models/gm_forest/tree_f.mdl",
			"models/gm_forest/tree_g.mdl"

		},
		Alder = {
			"models/gm_forest/tree_alder.mdl",
			"models/props_foliage/ac_appletree02.mdl",
			"models/props_foliage/appletree01.mdl",
			"models/props_foliage/rd_appletree01.mdl"
		},
		Pine = {
			"models/cod4/red_pine_sm.mdl",
			"models/cod4/red_pine_xl.mdl",
			"models/cod4/red_pine_xxl.mdl"
		}
	},
	Bush = {
		SpreedChance = 2,
		SpreedDistance = {40, 70},
		GrowthTime = 25,
		Max = 60,
		Germinate = 5,

		Other = {
			"models/cherokemodels/palmy/kapradi05.mdl",
			"models/gm_forest/growth_a.mdl",
			"models/gm_forest/growth_b.mdl",
			"models/gm_forest/growth_c.mdl",
			"models/gm_forest/growth_d.mdl",
			"models/gm_forest/growth_e.mdl"
		}
	},
	Grass = {
		SpreedChance = 100,
		SpreedDistance = {30, 100},
		GrowthTime = 2,
		Max = 1500,
		Germinate = 1,
		WasteLand = {
			"models/props_foliage2/grass-wasteland02.mdl",
			"models/props_foliage2/grass_wasteland1.mdl",
			"models/props_foliage2/grass_wasteland3.mdl",
			"models/props_foliage2/grass_wasteland4.mdl",
			"models/props_foliage2/grass_wasteland5.mdl",
			"models/props_foliage2/grass_wasteland6.mdl",
			"models/props_foliage2/grass_wasteland7.mdl"
		},
		Other = {
			"models/gm_forest/grass.mdl",


		},
		CatTails = {
			"models/cod4/riverreeds.mdl",
			"models/cod4/riverreeds_cattails.mdl",
			"models/cod4/riverreeds_cattails_2.mdl"
		}
	}
}

if CLIENT then return end



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

concommand.Add("plant", function( ply, cmd, args )
	local seed = args[1]
	local seedtype = args[2]

	if (!seed or !seedtype or !SEEDS.Types[seed] or !SEEDS.Types[seed][seedtype]) then
		ply:ChatPrint( "Sorry the seed is not valid (" .. tostring(seed).. "-" .. tostring(seedtype) .. ")." )
		return
	end

	local trace = ply:GetEyeTrace()
	local pos = trace.HitPos
	local angle = trace.HitNormal:Angle() + Angle(90, 0, 0)

	if (!trace.HitWorld) then
		ply:ChatPrint( "Aim at the ground to plant." )
		return
	end

	local ground = SEEDS.Materials[trace.MatType]

	--check to make sure conditions are good
	if !(ground == "Dirt" or ground == "Grass" or ground == "Sand") then
		ply:ChatPrint( "You cannot plant on this terrain (" .. ground .. ")." )
		return
	end

	SEEDS:Plant( pos, angle, seed, seedtype, ply )
end)

--plant the seed
function SEEDS:Plant( pos, angle, seed, seedtype, owner )
	local germtime = self.Types[seed].Germinate
	local growtime = self.Types[seed].GrowthTime
	local model = self.Types[seed][seedtype][ math.random( 1, #self.Types[seed][seedtype] ) ]
	local sounds = self.Types[seed][seedtype].Sounds

	local ent = ents.Create("seed")
	ent:SetPos( pos )
	ent:SetAngles( angle )
	ent.Owner = owner
	ent:SetModel( model )
	ent.Seed = seed
	ent.SeedType = seedtype
	ent.SpawnTime = CurTime()
	ent:Spawn()
	ent:Activate()

	ent:InitGrow( germtime, growtime )

	if (IsValid(owner)) then
		undo.Create( "seed" )
		undo.AddEntity( ent )
		undo.SetPlayer( owner )
		undo.Finish()
	end
end

function SEEDS:RemoveAll()
	for _, ent in pairs( ents.FindByClass("seed") ) do
		ent:Remove()
	end
end

concommand.Add("remove_plants", function()
	SEEDS:RemoveAll()
end)



function SEEDS:Think()
	self.NextThink = CurTime() + 1

	self.counts = {}

	local seeds = ents.FindByClass("seed")

	for seed, data in pairs(self.Types) do
		self.counts[seed] = 0

		for _, ent in pairs( seeds ) do
			if (ent.Seed == seed) then
				self.counts[seed] = self.counts[seed] + 1
			end
		end
	end

	--MsgN("self.counts: ")
	--PrintTable(self.counts)
end


function SEEDS:CanPlant( seed )
	return self.counts[seed] < self.Types[seed].Max
end


















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


GM:Register( SEEDS )