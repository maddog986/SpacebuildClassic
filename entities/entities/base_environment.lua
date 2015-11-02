--[[
	Author: MadDog (steam id md-maddog)
]]
AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.PrintName = "Base Environment"
ENT.Author	= "MadDog"

ENT.Spawnable = false
ENT.AdminOnly = false

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

--shared functions
function ENT:IsPlanet() return false end
function ENT:CanTool() return false end
function ENT:GravGunPunt() return false end
function ENT:GravGunPickupAllowed() return false end
function ENT:OnTakeDamage() return false end
function ENT:PhysicsSimulate() return SIM_NOTHING end

--client functions
if CLIENT then
	function ENT:Draw() end
	function ENT:DrawModel() end
return end

--server side
function ENT:Initialize()
	self:SetModel( "models/dav0r/hoverball.mdl" )

	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_NONE )
	self:SetNotSolid( true )
	self:SetTrigger( true )

	local phys = self:GetPhysicsObject()

	if phys:IsValid() then
		phys:EnableCollisions( true )
		phys:EnableMotion( false )
	end

	self.active = true
	self.entities = {}
end

function ENT:SetRadius( radius )
	self.radius = radius

	self:PhysicsInitSphere( radius )
	self:SetCollisionBounds( -Vector(radius, radius, radius), Vector(radius, radius, radius) )
end

function ENT:GetRadius() return self.radius or 0 end

function ENT:SetActive( active )
	self.active = active
	self:SetTrigger( active )
end

function ENT:GetActive() return self.active end

function ENT:StartTouch( ent )
	if (!IsValid(ent) or !ENVIRONMENTS:HasEntity(ent) or self.entities[ent:EntIndex()]) then return end
	if (ent:GetPos():Distance(self:GetPos()) > self:GetRadius()) then return end --box to sphere fix

	self.entities[ent:EntIndex()] = ent

	hook.Run( "EnterEnvironment", ent, self )

	return true
end

function ENT:EndTouch( ent )
	if (!IsValid(ent)) then return end
	if (!ENVIRONMENTS.Entities[ent:EntIndex()]) then return end
	if (!self.entities[ent:EntIndex()]) then return end --never called starttouch?

	if (ent:GetPos():Distance(self:GetPos()) < self:GetRadius()) then --ummm still in the environment? wtf
		timer.Simple(0.01, function()
			self:StartTouch( ent )
		end)
	end

	self.entities[ent:EntIndex()] = nil

	hook.Run( "LeaveEnvironment", ent, self )

	MsgN("LeaveEnvironment", ent, self)
end

function ENT:Touch( ent )
	if (!IsValid(ent)) then return end
	if (!ENVIRONMENTS.Entities[ent:EntIndex()]) then return end

	if (!self.entities[ent:EntIndex()] and ent:GetPos():Distance(self:GetPos()) < self:GetRadius()) then
		self:StartTouch( ent )
	elseif (ent:GetPos():Distance(self:GetPos()) > self:GetRadius()) then --fix for collisions not being sphere
		self:EndTouch( ent )
	end
end

function ENT:SetEnvironment( data )
	self.environment = data or {}
	self.default_environment = table.Copy(self.environment)
	self.livable_environment = {
		oxygen = 100,
		pressure = 1,
		atmosphere = 1,
		lowtemperature = 299,
		hightemperature = 299,
		unstable = 0
	}
	self:SetRadius( data.radius or 0 )

	if (data.active) then self:SetActive( data.active ) end
end

function ENT:GetEnvironment() return self.environment or {} end
function ENT:GetDefaultEnvironment() return self.default_environment or {} end
function ENT:GetEntities() return self.entities end
function ENT:UpdateTransmitState() return TRANSMIT_NEVER end