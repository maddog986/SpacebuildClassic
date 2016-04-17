--[[
	Author: MadDog (steam id md-maddog)
]]
AddCSLuaFile()

DEFINE_BASECLASS( "base_gmodentity" )

ENT.Spawnable = false
ENT.AdminOnly = false
ENT.ResourceEntity = true

ENT.PrintName = "Base Device"
ENT.Information = "Base Device"
ENT.Author	= "MadDog"
ENT.Model = "models/lt_c/sci_fi/generator_portable.mdl"
ENT.UseType = USE_OFF
ENT.Category = "Life Support"

function ENT:SetupDataTables()
	self:NetworkVar( "Bool", 0, "Active" )

	if SERVER then
		self:NetworkVarNotify( "Active", self.ActiveChanged )
	end
end

--[[	CLIENT SIDE ]]
if CLIENT then
	net.Receive("DeviceUpdateInfo", function()
		local ent = net.ReadEntity()
		local name = net.ReadString()
		local desc = net.ReadString()

		ent.PrintName = name
		ent.Information = desc
	end)
return end

--[[	SERVER SIDE ]]
ENT.Actions = {
	turnon = function( self )
		self:TurnOn()
	end,
	turnoff = function( self )
		self:TurnOff()
	end
}

util.AddNetworkString("DeviceUpdateInfo")

function ENT:SpawnFunction( ply, tr, class )
	if ( !tr.Hit ) then return end

	local ent = ents.Create( class )
	ent:SetCreater( ply )
	ent:SetPos( tr.HitPos + (vector_up * 100) )
	ent:Spawn()
	ent:Activate()
	ent:DropToFloor()

	return ent
end

function ENT:UpdateInfo( name, desc )
	net.Start("DeviceUpdateInfo")
	net.WriteEntity( self )
	net.WriteString( name )
	net.WriteString( desc )
	net.Broadcast()
end

--server side
function ENT:Initialize()
	self:SetModel( self.Model )

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( self.UseType )

	self.Active = false

	local RS = GM:GetPlugin("Resources")
	if ( !IsValid(RS) ) then self:Remove(); return end

	RS:SetupDevice( self )

	if ( self.OnSound ) then
		self.OnSound = self:AddSound( self.OnSound )
	end

	if ( self.OffSound ) then
		self.OffSound = self:AddSound( self.OffSound )
	end

	self:PhysWake()

	if (self.CustomModelScale) then self:SetModelScale( self.CustomModelScale ) end

	if ( self.Environment ) then --custom environment
		local environment = ents.Create( "sb_brush_environment" )
		environment.rsentity = self
		environment:Spawn()
		environment:Activate()

		self.environment_entity = environment

		self:DeleteOnRemove(environment)

		timer.Simple(1, function()
			local effect = EffectData()
			effect:SetEntity( self )
			effect:SetRadius( environment:GetSize() )
			effect:SetFlags( self.Environment.Shape or ENVIRONMENT_SPHERE )

			util.Effect( "climate_bubble", effect )
		end)
	end

	if ( IsValid(ent:GetCreator()) ) then ent:GetCreator():SkillUnlock( "DeviceSpawn", self ) end
end

function ENT:TriggerInput( name, value )
	if ( self.Triggers[name] ) then
		self.Triggers[name]( self, value )
	end
end

function ENT:ActiveChanged( name, old, active )
	if (name ~= "Active") then return end

	self:Fire( Either(active, "turnon", "turnoff") )

	if (WireAddon) then Wire_TriggerOutput(self, "On", Either( active, 1, 0)) end
end

function ENT:Use( activator, caller, type, value )
	if ( !activator:IsPlayer() ) then return end

	self:SetActive( !self:GetActive() )
end

function ENT:AcceptInput( name, activator, caller )
	if (self.Actions[name]) then
		return self.Actions[name]( self )
	end
end

function ENT:TurnOn()
	if ( self.OffSound ) then self.OffSound:Stop() end
	if ( self.OnSound ) then self.OnSound:Play() end
end

function ENT:TurnOff()
	if ( self.OffSound ) then self.OffSound:Play() end
	if ( self.OnSound ) then self.OnSound:Stop() end
end

function ENT:Think()
	if ( !GM:IsPluginActive("Resources") ) then return end

	local RS = GAMEMODE:GetPlugin("Resources")

	if ( IsValid(RS) or !RS:IsActive() or !self.RS or !self.RS.resources or !self:GetActive() ) then return end
	if ( self.CheckRequirements and !self:CheckRequirements() ) then return end
	if ( !self:GetActive() ) then return end --checking to check if active again after calling CheckRequirements

	for resource, callback in pairs( self.RS.resources ) do
		RS:Commit( self, resource, RS:GetValue(self, callback) ) --can be negitive or positive
	end

	--unlocks and such
	if ( self.RS.stored[resource] > 100000 and IsValid(ent:GetCreator()) ) then
		ent:GetCreator():SkillUnlock( "StorageMaster", self )
	end

	self:NextThink( CurTime() + RS:GetSetting("sb_resources_tick_rate") )
	return true
end


--[[	SOUND FUNCTIONS	]]
ENT.sounds = {}

function ENT:AddSound( path )
	self.sounds = self.sounds or {}
	self.sounds[path] = CreateSound( self, path )

	if (volume) then self.sounds[path]:ChangeVolume( volume ) end

	if IsValid(self.sounds[path]) then self:DeleteOnRemove(self.sounds[path]) end

	self:CallOnRemove( "StopAllSounds", self.StopAllSounds )

	return self.sounds[path]
end

function ENT:PlaySound( id )
	if ( !self.sounds[id] ) then return end

	self.sounds[id]:Play()
end

function ENT:StopSound( id )
	if ( !self.sounds[id] ) then return end

	self.sounds[id]:Stop()
end

function ENT:StopAllSounds()
	for path, sound in pairs( self.sounds ) do
		sound:Stop()
	end
end

--[[	DUPE SUPPORT	]]
function ENT:PreEntityCopy()
	if ( !IsRS(self) or !self.RS.stored ) then return end --nothing to save

	duplicator.StoreEntityModifier( self, "RSDupeInfo", {
		stored = self.RS.stored --saved resources stored
	})

	if ( WireLib ) then
		duplicator.StoreEntityModifier( self, "WireDupeInfo", WireLib.BuildDupeInfo(self) or {} )
	end
end

function ENT:PostEntityPaste( ply, ent, entities )
	if ( !IsRS(ent) or !ent.EntityMods or !ent.EntityMods.RSDupeInfo ) then return end

	local info = ent.EntityMods.RSDupeInfo

	if ( info.stored ) then --restore resources stored
		ent.RS.stored = info.stored
	end

	if ( WireLib ) then
		WireLib.ApplyDupeInfo( ply, ent, ent.EntityMods.WireDupeInfo, function(id) return entities[id] end)
	end
end