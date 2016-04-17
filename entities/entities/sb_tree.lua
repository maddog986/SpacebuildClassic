--[[
	Author: MadDog (steam id md-maddog)

	TODO: finish. add terraform bonus. something...
]]
AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.PrintName = "Spacebuild Tree"
ENT.Author	= "MadDog"

ENT.Spawnable = true
ENT.AdminOnly = true

ENT.SpreedChance = 100
ENT.SpreedDistance = {250, 800}
ENT.GrowthTime = 15
ENT.Max = 15

ENT.Materials = {}
ENT.Materials[MAT_CONCRETE] = "Concrete"
ENT.Materials[MAT_METAL] = "Iron"
ENT.Materials[MAT_VENT] = "Iron"
ENT.Materials[MAT_GRATE] = "Iron"
ENT.Materials[MAT_TILE] = "Stone"
ENT.Materials[MAT_SLOSH] = "Wood"
ENT.Materials[MAT_WOOD] = "Wood"
ENT.Materials[MAT_COMPUTER] = "Iron"
ENT.Materials[MAT_GLASS] = "Glass"
ENT.Materials[MAT_FLESH] = "Wood"
ENT.Materials[MAT_BLOODYFLESH] = "Wood"
ENT.Materials[MAT_CLIP] = "Wood"
ENT.Materials[MAT_ANTLION] = "Wood"
ENT.Materials[MAT_ALIENFLESH] = "Wood"
ENT.Materials[MAT_FOLIAGE] = "Wood"
ENT.Materials[MAT_PLASTIC] = "Wood"
ENT.Materials[MAT_DIRT] = "Dirt"
ENT.Materials[MAT_SAND] = "Sand"
ENT.Materials[MAT_GRASS] = "Dirt"
ENT.Materials[MAT_SNOW] = "Dirt"

--shared side
function ENT:CanTool() return false end
function ENT:GravGunPunt() return false end
function ENT:GravGunPickupAllowed() return false end
function ENT:OnTakeDamage() return false end
function ENT:PhysicsSimulate() return SIM_NOTHING end

--server side
if CLIENT then return end

function ENT:Initialize()
	self:SetModel( "models/harvest/tree/tree_small.mdl" )

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	self.GrowTime = 2
	self.StartSize = 0.01
	self.GermTime = 30
	self.EndSize = math.random(0.8, 1)

	self.MaxTries = math.random(50, 150) --how many attempts to plant a new tree
	self.Tries = 0 --how many tries we have tried to plant a tree

	self:SetModelScale( self.StartSize )

	timer.Create( "growing" .. self:EntIndex(), 0.01, 0, function()
		if ( !IsValid(self) ) then return end
		
		self.StartTime = self.StartTime or CurTime()

		self:SetModelScale( math.Clamp(1 * ((CurTime() - self.StartTime) / self.GrowTime), 0, self.EndSize) )

		if ( self:GetModelScale() >= self.EndSize ) then
			self:FinishGrowing()
		end
	end)
end

function ENT:FinishGrowing()
	self:SetModelScale( self.EndSize, 0 )
	timer.Remove( "growing" .. self:EntIndex() )

	local phys = self:GetPhysicsObject()

	if ( IsValid(phys) ) then
		phys:EnableMotion( false )
	end
end

function ENT:IsDoneGrowing()
	return ( math.Round(self:GetModelScale(), 2) >= self.EndSize)
end

function ENT:OnRemove()
	timer.Remove( "seed" .. self:EntIndex() )
	timer.Remove( "growing" .. self:EntIndex() )
end


ENT.LastReproduce = 0

function ENT:Reproduce()
	if ( self.LastReproduce > CurTime() ) then return end --to soon
	self.LastReproduce = CurTime() + math.random(1, 2)

	--color me red, reached max amount of tires, TODO: remove before release
	if ( self.MaxTries < self.Tries ) then
		self:SetColor(Color(255,0,0,255))
		return
	end

	--must mature first to reproduce
	if ( !self:IsDoneGrowing() ) then
		self:SetColor(Color(0,0,0,255))
		--MsgN("self:GetModelScale(): ", math.Round(self:GetModelScale(), 2) , "-", self.EndSize)
	return end

	--only try to reproduce if not already at the max
	if ( self:ReachedPlanetMax() ) then return end --currently at planet max

	self:SetColor(Color(255,255,255,255))

	local spreeddistance = self.SpreedDistance
	local spreedchance = self.SpreedChance
	local chance = math.random(0,100)

	if ( chance > spreedchance ) then return end

	--up to 6 trys to plant a seed
	for i = 1, 6, 1 do
		self.Tries = self.Tries + 1

		local pos = self:GetPos() +  Vector( math.Rand( -spreeddistance[2], spreeddistance[2] ), math.Rand( -spreeddistance[2], spreeddistance[2] ), 20 )

		if (pos:Distance(self:GetPos()) < spreeddistance[1]) then continue end --gotta be min distance away

		local trace = util.TraceLine({
			start = pos,
			endpos = pos - Vector(0, 0, 80)
		})

		if (!trace.HitWorld or util.IsInWater(trace.HitPos)) then continue end

		pos = trace.HitPos --update the ground position

		--check to make sure conditions are good for new growth
		local ground = self.Materials[trace.MatType]

		if (ground != "Dirt" and ground != "Grass" and ground != "Sand") then continue end

		local toclose = false

		--debugoverlay.Sphere( pos, 20, 60, Color(0,255,255), true )

		for _, ent in pairs( ents.FindByClass( "sb_tree" ) ) do
			if (ent == self) then continue; end

			if (pos:Distance(ent:GetPos()) < spreeddistance[1]) then
				toclose = true
				break
			end
		end

		if (toclose) then continue end

		return self:Plant( pos, trace.HitNormal:Angle() + Angle(90, 0, 0) )
	end
end

function ENT:Plant( pos, angle )
	local ent = ents.Create( "sb_tree" )
	ent:SetPos( pos )
	ent:SetAngles( angle )
	ent:Spawn()
	ent:Activate()
end

function ENT:ReachedPlanetMax()
	if ( !IsValid(self:GetPlanet()) ) then return true end

	local count = 0

	for _, ent in pairs( ents.FindByClass("sb_tree") ) do
		if ( ent:GetPlanet() == self:GetPlanet() ) then
			count = count + 1
		end
	end

	return (count >= self.Max)
end

--TODO: remove before release, only leave here for debugging
concommand.Add("remove_trees", function()
	for _, ent in pairs( ents.FindByClass("sb_tree") ) do
		ent:Remove()
	end
end)

function ENT:Think()
	if (self:IsDoneGrowing()) then
		local random = math.random(1, 50)

		if (util.InRange( random, 1, 3)) then
			self:EmitSound("ambient/crow4.wav")
		elseif (util.InRange( random, 3, 5)) then
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
		elseif (util.InRange( random, 45, 50)) then
			self:EmitSound("ambient/nature/wind_leaves_mild_gust_1.wav")
		end

		self:Reproduce()
	end

	self:NextThink( CurTime() + 1 )
	return true
end

function ENT:UpdateTransmitState()
	return TRANSMIT_PVS
end