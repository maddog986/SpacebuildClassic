--[[
	Author: MadDog (steam id md-maddog)
]]
AddCSLuaFile()

DEFINE_BASECLASS( "base_lifesupport" )

ENT.PrintName = "Air Storage"
ENT.Author	= "MadDog"
ENT.Spawnable = true
ENT.AdminSpawnable = true

ENT.socket_offsets = {
	Storage =  { Vector( -0.052794, 0.004846, 58.081451 ), "up" }
}

if CLIENT then return end

ENT.Model = "models/air_tank.mdl"
ENT.SoundStartup = ""
ENT.SoundIdle = ""
ENT.SoundShutdown = ""
ENT.TurnOffOnDelay = 1
ENT.StartUpSequence = ""
ENT.IdleSequence = ""
ENT.ShutdownSequence = ""