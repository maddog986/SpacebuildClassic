--[[
	Author: MadDog (steam id md-maddog)
]]
AddCSLuaFile()

DEFINE_BASECLASS( "base_lifesupport" )

ENT.PrintName = "TerraFormer"
ENT.Author	= "MadDog"
ENT.Spawnable = true
ENT.AdminSpawnable = true

if CLIENT then return end

ENT.Model = "models/props_combine/CombineThumper002.mdl"
ENT.SoundStartup = "ambient/machines/thumper_startup1.wav"
ENT.SoundIdle = "ambient/machines/thumper_amb.wav"
ENT.SoundShutdown = "ambient/machines/thumper_shutdown1.wav"
ENT.TurnOffOnDelay = 2
ENT.StartUpSequence = ""
ENT.IdleSequence = "idle"
ENT.ShutdownSequence = ""

function ENT:TurnOn()
	self.BaseClass.TurnOn( self )

	local startupseqlen = self:SequenceDuration( self.StartUpSequence )

	timer.Create("Dust"..self:EntIndex(), startupseqlen, 0, function()
		local effect = EffectData()
		effect:SetOrigin( self:GetPos() )
		effect:SetScale( 300 )
		util.Effect( "ThumperDust", effect, true, true )
	end)
end

function ENT:TurnOff()
	self.BaseClass.TurnOff( self )

	timer.Remove( "Dust"..self:EntIndex())
end

function ENT:OnRemove()
	self.BaseClass.OnRemove( self )

	timer.Remove( "Dust"..self:EntIndex())
end

function ENT:TerraForm()
	local planet = self:GetPlanet()

	planet.environment.gravity = math.Approach( planet.environment.gravity, 1, math.random(0.01, 0.08) )
	planet.environment.pressure = math.Approach( planet.environment.pressure, 1, math.random(0.01, 0.08) )
	planet.environment.oxygen = math.Approach( planet.environment.oxygen, 100, math.random(0.01, 0.08) )
	planet.environment.atmosphere = math.Approach( planet.environment.atmosphere, 1, math.random(0.01, 0.08) )
	planet.environment.lowtemperature = math.Approach( planet.environment.lowtemperature, 288, math.random(1, 3) )
	planet.environment.hightemperature = math.Approach( planet.environment.hightemperature, 288, math.random(1, 3) )
end

function ENT:TerraFormReset()
	local planet = self:GetPlanet()

	planet.environment.gravity = math.Approach( planet.default_environment.gravity, 1, math.random(0.01, 0.08) )
	planet.environment.pressure = math.Approach( planet.default_environment.pressure, 1, math.random(0.01, 0.08) )
	planet.environment.oxygen = math.Approach( planet.default_environment.oxygen, 100, math.random(0.01, 0.08) )
	planet.environment.atmosphere = math.Approach( planet.default_environment.atmosphere, 1, math.random(0.01, 0.08) )
	planet.environment.lowtemperature = math.Approach( planet.default_environment.lowtemperature, 288, math.random(0.5, 2) )
	planet.environment.hightemperature = math.Approach( planet.default_environment.hightemperature, 288, math.random(0.5, 2) )
end

function ENT:TerraFormQuickReset()
	local planet = self:GetPlanet()

	planet.environment = table.Copy(planet.default_environment)
end