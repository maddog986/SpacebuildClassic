--[[

	Author: MadDog (steam id md-maddog)

	TODO:
		-Add more ambient sounds to enhance the gameplay.
]]

local SOUNDS = {}

SOUNDS.Name = "Sounds"
SOUNDS.Author = "MadDog"
SOUNDS.Version = 1
SOUNDS.Alive = false
SOUNDS.Suit = 100
SOUNDS.NextWarningSound = 0
SOUNDS.Health = 100

function SOUNDS:Think()
	self.NextThink = CurTime() + 0.1

	local ply = LocalPlayer()

	if (!self.BreatheSound) then self.BreatheSound = CreateSound( ply, Sound("player/breathe1.wav") ) end
	if (!self.SpaceSound) then self.SpaceSound = CreateSound( ply, Sound("spacebuild/spaceloop2.wav")) end
	if (!self.PlanetSound) then self.PlanetSound = CreateSound( ply, Sound("ambient/atmosphere/ambience_base.wav")) end
	if (!self.HeartBeat) then self.HeartBeat = CreateSound( ply, Sound("player/heartbeat1.wav")) end

	if (self.Alive ~= ply:Alive() and !ply:Alive()) then --death sound
		ply:EmitSound("player/death" .. math.random(1, 6) .. ".wav")
	elseif (self.Alive and ply:Alive() and self.Suit ~= ply:Suit() and self.Suit > ply:Suit()) then
		if (self.NextWarningSound < CurTime()) then
			self.NextWarningSound = CurTime() + 2
			ply:EmitSound(Sound("/common/warning.wav"))
		end
	end

	if (self.Alive and ply:Alive() and self.Health ~= ply:Health()) then
		self.HeartBeat:Play()
	else
		self.HeartBeat:FadeOut(0.5)
	end

	ply.environment = ply.environment or {}

	if ply.environment.atmosphere == 0 then --inspace now
		self.SpaceSound:Play()
		self.PlanetSound:FadeOut(0.5)
	else
		self.SpaceSound:FadeOut(0.5)
		self.PlanetSound:Play()
		self.PlanetSound:ChangeVolume( 0.1, 0 )
	end

	self.Alive = ply:Alive()
	self.Suit = ply:Suit()
	self.Health = ply:Health()
end

GM:Register( SOUNDS )