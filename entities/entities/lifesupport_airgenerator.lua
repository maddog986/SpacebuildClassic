--[[
	Author: MadDog (steam id md-maddog)
]]
AddCSLuaFile()

DEFINE_BASECLASS( "base_lifesupport" )

ENT.PrintName = "Air Generator"
ENT.Author	= "MadDog"
ENT.Spawnable = true
ENT.AdminSpawnable = true

ENT.socket_offsets = {
	Energy = { Vector( 20.534195, 0.786633, 7.653804 ), "forward" },
	Storage =  { Vector( 15.625233, -17.009909, 18.109396 ), "forward" }
}

if CLIENT then
--[[
function ENT:Think()
		self.socket_offsets = {
			Energy = { Vector( 20.534195, 0.786633, 7.653804 ), (self:GetPos() - self:LocalToWorld(Vector( 20.534195, 0.786633, 0 ))) * -5 },
			Storage =  { Vector( 15.625233, -17.009909, 18.109396 ), "forward" }
		}
	end
]]
	return end

ENT.Model = "models/air_compressor.mdl"
ENT.SoundStartup = "vehicles/tank_turret_start1.wav"
ENT.SoundIdle = "vehicles/tank_turret_loop1.wav"
ENT.SoundShutdown = "vehicles/tank_turret_stop1.wav"
ENT.TurnOffOnDelay = 1
ENT.StartUpSequence = "idle"
ENT.IdleSequence = "active"
ENT.ShutdownSequence = "idle"