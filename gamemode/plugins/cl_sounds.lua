--[[

	Author: MadDog (steam id md-maddog)

	TODO:
		-Add more ambient sounds to enhance the gameplay.
		-recode to support enable/disable options
		-add sound level configs
]]

local SOUNDS = {
	--plugin info
	Name = "Sounds",
	Description = "Plugin to enable custom sounds. Requires Environments to work.",
	Author = "MadDog",
	Version = 12212015,

	--settings
	CVars = {
		--client settings
		"sb_sounds_enable" = { text = "Enable Ambient Sounds", default = true },
	}
}

local alive = false
local health = 100
local BreatheSound
local SpaceSound
local PlanetSound
local HeartBeat

function SOUNDS:Think()
	self.NextThink = CurTime() + 0.1

	if ( !self:IsActive() or !GAMEMODE:IsPluginActive("Environments") ) then return end

	local ply = LocalPlayer()

	if ( !BreatheSound ) then BreatheSound = CreateSound( ply, "player/breathe1.wav") end
	if ( !SpaceSound ) then SpaceSound = CreateSound( ply, "spacebuild/spaceloop2.wav") end
	if ( !PlanetSound ) then PlanetSound = CreateSound( ply, "ambient/atmosphere/ambience_base.wav") end
	if ( !HeartBeat ) then HeartBeat = CreateSound( ply, "player/heartbeat1.wav") end


	if (alive ~= ply:Alive() and !ply:Alive()) then --death sound
		ply:EmitSound("player/death" .. math.random(1, 6) .. ".wav")
	end

	if  (alive and ply:Alive() and health ~= ply:Health() ) then
		HeartBeat:Play()
	else
		HeartBeat:FadeOut(0.5)
	end

	if ( !IsValid(ply:GetPlanet()) ) then --inspace now
		SpaceSound:Play()
		PlanetSound:FadeOut(0.5)
	else
		SpaceSound:FadeOut(0.5)
		PlanetSound:Play()
		PlanetSound:ChangeVolume( 0.1, 0 )
	end

	alive = ply:Alive()
	health = ply:Health()
end

function SOUNDS:ShutDown()
	if ( BreatheSound ) then BreatheSound:Stop() end
	if ( SpaceSound ) then SpaceSound:Stop() end
	if ( PlanetSound ) then PlanetSound:Stop() end
	if ( HeartBeat ) then HeartBeat:Stop() end
end

GM:AddPlugin( SOUNDS )