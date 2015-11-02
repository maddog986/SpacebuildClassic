--[[
	Author: MadDog (steam id md-maddog)
]]
AddCSLuaFile()

DEFINE_BASECLASS( "base_resource" )

ENT.PrintName = "LifeSupport Base"
ENT.Author	= "MadDog"
ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()
	self:NetworkVar( "Bool", 0, "Active" )

	self:NetworkVar( "String", 0, "DeviceName" )

	if SERVER then
		self:NetworkVarNotify( "Active", self.StateChanged )
	end
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()

		local offset = Vector( 30, 30, 0 )
		local ang = self:GetAngles()
		local pos = self:GetPos() + offset + ang:Up()

		--ang:RotateAroundAxis( ang:Forward(), 90 )
		--ang:RotateAroundAxis( ang:Right(), 90 )

		cam.Start3D2D( pos, self:GetAngles(), 0.25 )
			draw.DrawText( "testing", "Default", 2, 2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
		cam.End3D2D()
	end

	return
end

ENT._activechangedelay = 0

function ENT:SpawnFunction( ply, tr, ClassName )
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 10

	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()

	local phys = ent:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
	end

	return ent
end

ENT.Model = "models/air_compressor.mdl"
ENT.SoundStartup = ""
ENT.SoundIdle = ""
ENT.SoundShutdown = ""
ENT.TurnOffOnDelay = 1
ENT.StartUpSequence = ""
ENT.IdleSequence = ""
ENT.ShutdownSequence = ""

function ENT:Initialize()
	self:SetModel( self.Model )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	self:SetUseType( ONOFF_USE )
end

function ENT:AcceptInput( name, activator, caller )
	if (name == "Use" and caller:IsPlayer() and caller:KeyDownLast(IN_USE) == false) then
		self:EmitSound("tools/ifm/beep.wav")

		self:SetActive( !self:GetActive() )
    end
end

function ENT:StateChanged( name, old, value )
	if (name ~= "Active") then return end

	if (value) then
		self:TurnOn()
	else
		self:TurnOff()
	end
end

function ENT:TurnOn()
	if (self._activechangedelay > CurTime()) then return end --do nothing
	if (self.Active) then return end --already active

	self.Active = true
	self._activechangedelay = CurTime() + self.TurnOffOnDelay

	if (self.device) then
		self.device:SetActive( true )
	end

	local sounddelay = 0

	if (self.SoundStartup) then
		self:EmitSound( self.SoundStartup )

		sounddelay = SoundDuration( self.SoundStartup ) - 0.05
	end

	if (self.SoundIdle) then
		timer.Create( "Sound"..self:EntIndex(), sounddelay, 1, function()
			self:EmitSound( self.SoundIdle )
		end)
	end

	local startupseq = self:LookupSequence( self.StartUpSequence )
	local startupseqlen = self:SequenceDuration( self.StartUpSequence )

	local idleseq = self:LookupSequence( self.IdleSequence )
	local idleseqlen = self:SequenceDuration( self.IdleSequence )

	if (startupseq > -1) then
		self:SetPlaybackRate(1)
		self:ResetSequence( startupseq )
	else
		startupseqlen = 0
	end

	if (idleseq > -1) then
		timer.Simple(startupseqlen, function()
			if (!IsValid(self)) then return end

			self:SetPlaybackRate(1)
			self:ResetSequence( idleseq )
		end)
	end
end

function ENT:TurnOff()
	if (self._activechangedelay > CurTime()) then return end --do nothing
	if (!self.Active) then return end --already off

	self.Active = false
	self._activechangedelay = CurTime() + self.TurnOffOnDelay

	if (self.device) then
		self.device:SetActive( false )
	end

	timer.Remove( "Sound"..self:EntIndex())

	self:StopSound( self.SoundIdle )
	self:EmitSound( self.SoundShutdown )

	local shutdownseq = self:LookupSequence( self.ShutdownSequence )
	local shutdownseqlen = self:SequenceDuration( self.ShutdownSequence )

	if (shutdownseq > -1) then
		self:SetPlaybackRate(1)
		self:ResetSequence( shutdownseq )

		timer.Simple(shutdownseqlen, function()
			if (!IsValid(self)) then return end

			self:SetPlaybackRate(0)
		end)
	else
		self:SetPlaybackRate(0)
	end
end

function ENT:OnRemove()
	timer.Remove( "Sound"..self:EntIndex())
	self:StopAllSounds()
end

function ENT:SetupCustomEnvironment( data )
	local ent = ents.Create( "base_environment" )

	ent:SetPos( self:GetPos() )
	ent:SetOwner( self )
	ent:Spawn()
	ent:Activate()

	ent:SetEnvironment(data or {
		oxygen = 100,
		gravity = 1,
		radius = 200,
		active = true
	})

	self.device = ent

	self:CallOnRemove( "RemoveDevice", function( ent )
		if (IsValid(ent)) then ent.device:Remove() end
	end )
end

function ENT:Think()
	BaseClass.Think( self )

	if (self.device) then self.device:SetPos( self:GetPos() ) end

	self:NextThink(CurTime())
	return true
end