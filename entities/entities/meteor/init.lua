AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

--[[
local rockmodels = {
	"models/props_canal/rock_riverbed01d.mdl",
	"models/props_canal/rock_riverbed02a.mdl",
	"models/props_canal/rock_riverbed02b.mdl",
	"models/props_canal/rock_riverbed02c.mdl",
	"models/props_debris/concrete_spawnchunk001a.mdl",
	"models/props_debris/concrete_spawnchunk001b.mdl",
	"models/props_debris/concrete_spawnchunk001c.mdl",
	"models/props_debris/concrete_spawnchunk001d.mdl",
	"models/props_debris/concrete_spawnchunk001e.mdl",
	"models/props_debris/concrete_spawnchunk001f.mdl",
	"models/props_debris/concrete_spawnchunk001g.mdl",
	"models/props_debris/concrete_spawnchunk001h.mdl",
	"models/props_debris/concrete_spawnchunk001i.mdl",
	"models/props_debris/concrete_spawnchunk001j.mdl",
	"models/props_debris/concrete_spawnchunk001k.mdl",
	"models/props_wasteland/rockcliff01g.mdl",
	"models/props_wasteland/rockgranite01c.mdl",
	"models/props_wasteland/rockgranite04b.mdl",
	"models/props_wasteland/rockcliff01c.mdl",
	"models/props_wasteland/rockcliff01j.mdl",
	"models/props_wasteland/rockgranite02a.mdl",
	"models/props_wasteland/rockgranite04c.mdl",
	"models/props_wasteland/rockcliff01e.mdl",
	"models/props_wasteland/rockgranite01a.mdl",
	"models/props_wasteland/rockgranite03c.mdl",
	"models/props_wasteland/rockcliff01b.mdl",
	"models/props_wasteland/rockcliff01f.mdl",
	"models/props_wasteland/rockgranite01b.mdl",
	"models/props_wasteland/rockgranite04a.mdl",
	"models/props_wasteland/rockcliff01g.mdl"
}
]]

function ENT:Initialize()
	local rockmodels = {
		"models/props_coalmines/boulder1.mdl"
	}

	self:SetModel("models/props_wasteland/rockgranite01b.mdl")

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )


	local phys = self:GetPhysicsObject()

	if (!phys:IsValid()) then self:Remove(); MsgN("NOT VALID PHYSICS FOR METEOR"); return end

	phys:SetMass(250)
	phys:Wake()
	phys:EnableGravity(false)
	phys:EnableDrag(false)
	phys:EnableCollisions(true)

	self:SetGravity(0.00001)

	self.Trail = ents.Create("env_fire_trail")
	self.Trail:SetAngles( self:GetAngles() )
	self.Trail:SetPos( self:GetPos() )
	self.Trail:SetParent( self )
	self.Trail:Spawn()
	self.Trail:Activate()

	self.Force = math.random(800, 2000)
	self.Damage = math.random(1200, 1800)
	self.Magnitude = math.random(100, 200)

	self.Sound = CreateSound(self, Sound("/ambient/nature/fire/fire_small1.wav"))
	self.Sound:PlayEx(1.5, 120)
end

function ENT:PhysicsUpdate()
	self:GetPhysicsObject():ApplyForceCenter(self:GetUp() * self.Force)
end

function ENT:OnRemove()
	if (self.Sound) then self.Sound:Stop() end
end

function ENT:PhysicsCollide( data, phys )
	if (data.HitEntity and (data.HitEntity:GetClass() == "sb_planet" or data.HitEntity:GetClass() == "meteor" or data.HitEntity:GetClass() == "asteroid")) then return end --dont interact with planets

	if self.Once then return end
	self.Once = true

	local Pos = self:GetPos()
	local Scale = self.Magnitude / 100.0
	local scale = math.Clamp(Scale, 0, 100)

	if (self:WaterLevel() > 2) then
		sound.Play(Sound("/ambient/water_splash" .. math.random(1, 3) .. ".wav"), Pos, scale * 60, 80)
		self:Remove()
	return end --no water exploding

	local effectdata = EffectData()
	effectdata:SetStart( Pos )
	effectdata:SetOrigin( Pos )
	effectdata:SetScale( Scale )
	util.Effect( "meteor_explosion", effectdata )

	util.BlastDamage( self, self, Pos, self.Magnitude*3, self.Damage*3 )

	for _,ent in pairs(ents.FindInSphere(self.Entity:GetPos(),300)) do
		if IsValid(ent) then constraint.RemoveAll(ent) end
	end

	util.ScreenShake( Pos, 5, 1, math.random(3, 6), scale*40)

	sound.Play(Sound("ambient/explosions/explode_" .. math.random(1, 9) .. ".wav"), Pos, scale * 60, 80)

	timer.Simple(math.random(1, 2), function()
		sound.Play(Sound("/ambient/materials/rock" .. math.random(1, 4) .. ".wav"), Pos, scale * 120, 80 )
	end)

	self:Remove()
end

function ENT:Think()
	if (!SB:GetClass( "Environments" ):OnPlanet( self )) then self:Remove() end --remove if not on a planet

	self:NextThink(CurTime() + 0.1)
	return true
end