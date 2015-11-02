--[[
	Author: MadDog (steam id md-maddog)
]]
AddCSLuaFile()

DEFINE_BASECLASS( "base_lifesupport" )

ENT.PrintName = "Climate Regulator"
ENT.Author	= "MadDog"
ENT.Spawnable = true
ENT.AdminSpawnable = true

ENT.socket_offsets = {
	Energy = { Vector( 8.303002, -8.761134, 15.328613 ), "forward" },
	Storage =  { Vector( 8.303002, -8.761134, 15.328613 ), "forward" }
}

ENT.Materiala = Material("effects/shielda")
ENT.Materialb = Material("effects/shieldb")

if CLIENT then
--[[
	function ENT:Think()
		self.socket_offsets = {
			Energy = { Vector( 8.303002, -8.761134, 15.328613 ), (self:GetPos() - self:LocalToWorld(Vector( 8.303002, -8.761134, 0 ))) * -5 },
			Storage =  { Vector( 8.303002, -8.761134, 15.328613 ), "forward" }
		}
	end
]]
	return end

ENT.Model = "models/efg_basic.mdl"
ENT.SoundStartup = "ambient/machines/thumper_startup1.wav"
ENT.SoundIdle = "ambient/machines/thumper_amb.wav"
ENT.SoundShutdown = "ambient/machines/thumper_shutdown1.wav"
ENT.TurnOffOnDelay = 1
ENT.StartUpSequence = "deploy"
ENT.IdleSequence = ""
ENT.ShutdownSequence = "retract"

if !SERVER then return end

function ENT:Initialize()
	BaseClass.Initialize( self )

	self:SetupCustomEnvironment({
		oxygen = 100,
		gravity = 1,
		lowtemperature = 298,
		hightemperature = 298,
		atmosphere = 1,
		pressure = 1,
		radius = 400,
		active = false
	})

	local fx = EffectData()
	fx:SetOrigin(self:GetPos())
	fx:SetEntity(self)
	fx:SetScale(400)
	util.Effect("climate_bubble", fx)
end