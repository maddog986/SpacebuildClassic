AddCSLuaFile( 'cl_init.lua' )
AddCSLuaFile( 'shared.lua' )
include( 'shared.lua' )

--Initialize
function ENT:Initialize()
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:PhysWake()

	self:SetUseType( ONOFF_USE )

	if (self.Environment) then
		if (!IsValid(self.ent_environment)) then
			self.ent_environment = ents.Create("base_sb_environment")
			self.ent_environment:Spawn()
			self.ent_environment:Activate()
		end

		self.ent_environment:SetPos( self:GetPos() )
		self.ent_environment:SetParent( self )
		self.ent_environment:SetEnvironment( data ) --save the data to the base_sb_environment entity

		self:EnvironmentAdd(self.ent_environment)
	end
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
	if (self:IsActive()) then return end

	--make sure sounds are created
	self:CreateSounds()

	self:SetNWBool( "Active", true )

	for _, sound in pairs(self.stopsounds or {}) do sound:Stop() end
	for _, sound in pairs(self.playsounds or {}) do sound:PlayEx(0.5, 100) end

	if (self.start_sequence) then
		local sequence = self:LookupSequence( self.start_sequence )
		self:ResetSequence(sequence)
	end
end

function ENT:TurnOff()
	if (!self:IsActive()) then return end

	--make sure sounds are created
	self:CreateSounds()

	self:SetNWBool( "Active", false )

	for _, sound in pairs(self.stopsounds or {}) do
		sound:PlayEx(0.5, 100) --play sound
	end

	for _, sound in pairs(self.playsounds or {}) do
		sound:Stop() --stop sound
	end

	if (self.stop_sequence) then
		local sequence = self:LookupSequence( self.stop_sequence )
		self:ResetSequence(sequence)
	end
end

function ENT:TriggerInput( name, value )
	if (name == "Active" or name == "On") then
		if (value ~= 1) then
			self:TurnOff()
		else
			self:TurnOn()
		end
	end
end

function ENT:AcceptInput(name, activator, caller)
	if (name == "Use") && (caller:IsPlayer()) && (caller:KeyDownLast(IN_USE) == false) then
		if (self:IsActive()) then
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