AddCSLuaFile( 'cl_init.lua' )
AddCSLuaFile( 'shared.lua' )
include( 'shared.lua' )

--Initialize
function ENT:Initialize()
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:PhysWake()

	self:SetUseType( SIMPLE_USE )

	self.Active = false
end

function ENT:CreateSounds()
	if (self.soundsCreated) then return end
	self.soundsCreated = true

	self.playsounds = {}
	self.stopsounds = {}
	self.forceoffsounds = {}

	for _, sound in pairs(self.RS.startsound or {}) do
		table.insert(self.playsounds, CreateSound(self, Sound(sound)) )	--start sound
	end

	self.forceoffsound = CreateSound(self, Sound("buttons/combine_button2.wav"))

	table.insert(self.forceoffsounds,  self.forceoffsound)	--force off sound

	for _, sound in pairs(self.RS.stopsound or {}) do
		table.insert(self.stopsounds, CreateSound(self, Sound(sound)) )	--stop sound
	end
end

function ENT:TurnOn()
	if (self.Active) then return end

	--make sure sounds are created
	self:CreateSounds()

	self.Active = true

	self:SetNWInt("Active", 1)

	for _, sound in pairs(self.stopsounds or {}) do sound:Stop() end
	for _, sound in pairs(self.playsounds or {}) do sound:PlayEx(0.5, 100) end
end

function ENT:TurnOff()
	if (!self.Active) then return end

	--make sure sounds are created
	self:CreateSounds()

	self.Active = false

	self:SetNWInt("Active", 0)

	for _, sound in pairs(self.stopsounds or {}) do
		sound:PlayEx(0.5, 100) --play sound
	end

	for _, sound in pairs(self.playsounds or {}) do
		sound:Stop() --stop sound
	end
end

function ENT:IsActive()
	return self.Active
end

function ENT:TriggerInput( name, value )
	if (name == "Active" or name == "On") then
		if (value == 0) then
			self:TurnOff()
		else
			self:TurnOn()
		end
	end
end

function ENT:AcceptInput(name, activator, caller)
	if (name == "Use") && (caller:IsPlayer()) && (caller:KeyDownLast(IN_USE) == false) then
		if (self.Active) then
			self:TurnOff()
		else
			self:TurnOn()
		end
	end

	return false
end

function ENT:OnRemove()
	self:TurnOff()
end