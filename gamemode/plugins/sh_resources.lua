--[[
	Author: MadDog (steam id md-maddog)

	TODO: Finish
]]

local RS = {
	--plugin info
	Author = "MadDog",
	Name = "Resources",
	Description = "Provides the backend system for Life Support.",
	Version = 12212015,

	--settings
	CVars = {
		"sb_resources_update_time" = { server = true, text = "Update Time.", default = 0.1, min = 0.1, max = 1, decimals = 1 },
		"sb_resources_tick_rate" = { server = true, text = "Resources Commit Interval", default = 1, min = 0.1, max = 3, decimals = 1}
	},

	GetValue = function( self, ent, value )
		return Either( type(value) == "function", math.ceil(value(ent, self), value )
	end
}

--Shared global function
function IsRS( ent )
	return ( IsValid(ent) and type(ent.RS) == "table" )
end

--register plugin
GM:AddPlugin( RS )

RS.devices = RS.devices or {}

function RS:AddDevice( name, ENT )
	--easy way to add more than one model for the same device with less code
	if ( type(ENT.Model) == "table" ) then for _, model in pairs( ENT.Model ) do ENT.Model = model; self:AddDevice( name, ENT ) end return end

	if ( !util.IsValidModel(ENT.Model) ) then return end
	util.PrecacheModel( ENT.Model )

	ENT.Spawnable = true

	DEFINE_BASECLASS( "rs_base_device" )

	scripted_ents.Register( ENT, name )

	self.devices[name] = ENT
end

include("devices/sh_energy.lua")
include("devices/sh_coolant.lua")
include("devices/sh_climate.lua")

function RS:SetupDevice( ent )
	ent.RS = {}

	if ( ent.Resources ) then ent.RS.resources = ent.Generate end

	if ( ent.Storage ) then
		ent.RS.stored = {}
		ent.RS.maxstorage = {}

		for resource, amount in pairs( ent.Storage ) do
			ent.RS.stored[resource] = 0
			ent.RS.maxstorage[resource] = math.ceil(RS:GetValue(ent, amount))
		end
	end
end

function RS:GetEntityStored( ent, resource )
	if ( !IsRS(ent) or !ent.RS.stored ) then return end

	if ( type(resource) == "table" ) then
		local res = {}; for _, r in pairs( resource ) do res[r] = self:GetEntityStored( ent, r ) end; return res
	elseif ( resource ) then
		return RS:GetValue(ent, ent.RS.stored[resource])
	end

	return RS:GetValue( ent, ent.RS.stored )
end

function RS:GetEntityStorage( ent, resource )
	if ( !IsRS(ent) or ! ent.RS.maxstorage ) then return end

	if ( type(resource) == "table" ) then
		local res = {}; for _, r in pairs( resource ) do res[r] = self:GetEntityStorage( ent, r ) end; return res end
	elseif ( resource ) then
		return RS:GetValue(ent, ent.RS.maxstorage[resource])
	end

	RS:GetValue( ent, ent.RS.maxstorage )
end

function RS:GetNodeInfo( ent )
	if ( !IsRS(ent) ) then return end

	if ( (ent.RS.nextupdate or 0) < CurTime() ) then
		ent.RS.nextupdate = CurTime() + (self:GetSetting("sb_resources_update_time") / 2)

		if ( SERVER ) then
			local node = { entities = beams.Connected( ent ), storage_entities = {}, stored = {}, maxstorage = {} }

			for _, entity in pairs( node.entities ) do
				if ( !IsRS(entity) or !entity.RS.stored ) then continue end

				for resource, amount in pairs( ent.RS.stored ) do
					node.storage_entities[resource] = node.storage_entities[resource] or {}
					table.insert( node.storage_entities[resource], entity )

					node.stored[resource] = (node.stored[resource] or 0) + (RS:GetEntityStored(entity, resource) or 0)
					node.maxstorage[resource] = (node.maxstorage[resource] or 0) + (RS:GetEntityStorage(entity, resource) or 0)
				end
			end

			ent.RS.node = node
		elseif ( ent.__node ) then
			ent.RS.node.stored = ent.__node.stored
			ent.RS.node.maxstorage = ent.__node.maxstorage
		end
	end

	return ent.RS.node
end

function RS:GetConnected( ent ) --function to help limit the times we call beams.Connected
	return RS:GetNodeInfo(ent).entities
end

function RS:GetNodeStored( ent, resource )
	if ( type(resource) == "table" ) then
		local res = {}; for _, r in pairs( resource ) do res[r] = self:GetEntityStored( ent, r ) end; return res;
	elseif ( resource ) then
		return RS:GetNodeInfo(ent).stored[resource] or 0
	end

	return RS:GetNodeInfo(ent).stored or {}
end

function RS:GetNodeStorage( ent, resource )
	if ( type(resource) == "table" ) then
		local res = {}; for _, r in pairs( resource ) do res[r] = self:GetNodeStorage( ent, r ) end; return res;
	elseif ( resource ) then
		return RS:GetNodeInfo(ent).maxstorage[resource] or 0
	end

	return RS:GetNodeInfo(ent).maxstorage or {}
end

--[[	CLIENT SIDE	]]
if CLIENT then
	net.Receive("RS.StorageDeviceInfo", function()
		local ent = net.ReadEntity()

		ent.RS = {stored = net.ReadTable(), maxstorage = net.ReadTable()}
		ent.__node = {stored = net.ReadTable(), maxstorage = net.ReadTable()}
		ent.RS.owner = net.ReadString()
	end)

	net.Receive("RS.GeneratorDeviceInfo", function()
		local ent = net.ReadEntity()

		ent.RS = {active = net.ReadBool(), owner = net.ReadString()}
	end)

	function RS:HUDPaint()
		local ply = LocalPlayer()
		local ent = ply:GetEyeEntity()

		if ( !IsRS(ent) or ent:Distance(ply) > 300 ) then return end

		local rows = {}

		if ( ent.PrintName ) then table.insert( rows, { text = ent.PrintName, color = Color(255, 255, 0), font = "MDSBtipBold18" }) end
		if ( ent.Information ) then table.insert( rows, { text = ent.Information, font = "MDSBtip16" }) end
		if ( ent.RS.owner ) then table.insert( rows, { text = "Owner: " .. ent.RS.owner, font = "MDSBtip14" }) end

		if ( ent.RS.stored ) then
			local node = RS:GetNodeInfo(ent)

			for resource, amount in pairs( ent.RS.stored ) do
				local percent = math.ceil( 100 * node.stored[resource] / node.maxstorage[resource] )

				table.insert( rows, {
					graph = { percent = percent },
					text= resource .. ": " .. amount .. "/" .. ent.RS.maxstorage[resource] .. "/" .. node.maxstorage[resource]
				})
			end
		end

		if ( ent.UseType == USE_TOGGLE ) then
			table.insert( rows, { text = Either( ent.RS.active, "(On)", "(Off)"), font = "MDSBtip14"} )
		end

		if ( #rows == 0 ) then return end

		GAMEMODE:MakeHud({
			name = "DeviceInfo",
			minwidth = 150,
			enabled = 1,
			rows = rows,
			pos = ent:LocalToWorld(ent:OBBCenter()):ToScreen()
		})
	end
return end

--[[	SERVER SIDE ]]
util.AddNetworkString( "RS.StorageDeviceInfo" )
util.AddNetworkString( "RS.GeneratorDeviceInfo" )

-- add or take resources from device
function RS:StorageCommit( ent, resource, amount )
	if ( !IsRS(ent) or !ent.RS.stored or !ent.RS.stored[resource] ) then return 0 end

	local take = math.Clamp( amount, -ent.RS.stored[resource], (ent.RS.maxstored[resource]-amount) )

	ent.RS.stored[resource] = math.ceil(ent.RS.stored[resource] + take)

	return (amount - take) --return remaining amount
end

-- add or take the resource from the connected system
function RS:Commit( ent, resource, amount )
	local node = RS:GetNodeInfo(ent)
	if ( !node.storage_entities[resource] ) then return amount end

	-- if adding get the lowest stored first, if removing get the highest stored first
	table.sort( node.storage_entities[resource], function(a, b) return a.RS.stored[resource] < b.RS.stored[resource] and (amount > 0) end )

	for _, entity in ipairs( node.storage_entities[resource] ) do
		amount = amount - RS:StorageCommit( entity, resource, amount )
		if ( amount == 0 ) then return 0 end
	end

	return amount --could not store or consume this amount left
end

function RS:Think()
	self.NextThink = CurTime() + self:GetSetting("sb_resources_update_time")

	for _, ply in pairs( player.GetAll() ) do
		local ent = ply:GetEyeEntity()
		if ( !IsRS(ent) or ent:Distance(ply) > 120 ) then continue end

		if ( ent.RS.stored ) then
			local node = RS:GetNodeInfo( ent )

			local datastring = pon.encode({ent, ent.RS.stored, ent.RS.maxstorage, node.stored, node.maxstorage})

			if (datastring ~= ply.RSStorageDeviceInfo) then
				ply.RSStorageDeviceInfo = datastring

				net.Start("RS.StorageDeviceInfo")
				net.WriteEntity( ent )
				net.WriteTable( ent.RS.stored )
				net.WriteTable( ent.RS.maxstorage )
				net.WriteTable( node.stored )
				net.WriteTable( node.maxstorage )

				if ( IsValid(ent:GetCreator()) ) then
					net.WriteString( ent:GetCreator():Nick() )
				else
					net.WriteString("Unknown")
				end

				net.Send( ply )
			end
		end

		if ( ent.RS.resources ) then
			local datastring = pon.encode({ent, ent:GetActive()})

			if (datastring ~= ply.RSGeneratorDeviceInfo ) then
				ply.RSGeneratorDeviceInfo = datastring

				net.Start("RS.GeneratorDeviceInfo")
				net.WriteEntity( ent )
				net.WriteBool( ent:GetActive() )

				if ( IsValid(ent:GetCreator()) ) then
					net.WriteString( ent:GetCreator():Nick() )
				else
					net.WriteString("Unknown")
				end

				net.Send( ply )
			end
		end
	end
end

function RS:GetVolume( ent )
	if ( self.Volume ) then return self.Volume end

	--get the prop size
	local min, max = self:OBBMins(), self:OBBMaxs()

	--save the volume as cubit feet
	self.Volume = (math.abs(max.x-min.x) * math.abs(max.y-min.y) * math.abs(max.z-min.z)/(16^3))

	return self.Volume
end

--[[
	Default consume, generate and storage functions here.
	DO NOT EDIT THIS FILE TO ADD YOURS. Create a new file.
]]
DEVICES = {}

function DEVICES.ISACTIVE( ent, RS )
	return ent:GetActive()
end

DEVICES.STORAGE = {}

function DEVICES.STORAGE.BASE_VOLUME( ent )
	return RS:GetVolume(ent)
end

DEVICES.CONSUME = {}

function DEVICES.CONSUME.BASE_VOLUME( ent, RS )
	return RS:GetVolume(ent) * 0.5
end

DEVICES.GENERATE = {}

function DEVICES.GENERATE.BASE_VOLUME( ent, RS )
	if ( !ent:GetActive() ) then return 0 end

	return RS:GetVolume(ent)
end

function DEVICES.GENERATE.SOLAR( ent, RS )
	if ( !IsValid(ent:GetPlanet()) ) then return 0 end

	--TODO: add a trace to check for clear sky

	return DEVICES.GENERATE.BASE_VOLUME( ent, RS ) * math.random(1, 3)
end

function DEVICES.GENERATE.FUSION( ent, RS )
	local volume = DEVICES.GENERATE.BASE_VOLUME( ent, RS )
	local cool = volume * 0.5

	--TODO: reduce coolant when in space with no environment
	ent.fusion_life = ent.fusion_life or 100

	if ( RS:GetNodeStored( ent, "Coolant" ) <= cool ) then
		ent.fusion_life = ent.fusion_life - math.random(1, 5)

		if ( ent.fusion_life <= 0 ) then
			self:EnergyDamage( pos, mag )
		end

		--TODO: when health reaches low lets go crictal and explode

		return volume * math.random(0.1, 0.4) --limit output due to damage
	end

	RS:Commit( ent, "Coolant", cool )

	return volume * math.random(1, 3)
end

function DEVICES.GENERATE.HYDRO( ent, RS )
	return Either( (ent:WaterLevel() >= 1), RS:GetVolume(ent), 0 )
end


DEVICES.REQUIREMENTS = {}

function DEVICES.REQUIREMENTS.BASE_VOLUME( ent, rs )
	return RS:GetVolume(ent)
end

function DEVICES.REQUIREMENTS.ENERGY( ent, RS )
	local consume = DEVICES.REQUIREMENTS.BASE_VOLUME( ent, RS ) * 0.5

	local res = RS:GetNodeStored( ent, "Energy" )
	if ( consume > res ) then self:SetActive( false ); return false end

	return true
end

function DEVICES.REQUIREMENTS.WATER( ent, RS )
	local consume = DEVICES.REQUIREMENTS.BASE_VOLUME( ent, RS ) * 0.5

	local res = RS:GetNodeStored( ent, "Water" )
	if ( consume > res ) then self:SetActive( false ); return false end

	return true
end

function DEVICES.REQUIREMENTS.COOLANT( ent, RS )
	if ( !ent:GetActive() ) then return 0 end

	local volume = DEVICES.REQUIREMENTS.BASE_VOLUME( ent, RS )
	local water = volume * 0.5

	if ( RS:GetNodeStored( ent, "Water" ) <= water ) then
		ent:TurnOff()
	return end

	RS:Commit( ent, "Water", -water )

	return volume
end


DEVICES.CLIMATE = {}

function DEVICES.CLIMATE.BASE_VOLUME( ent, rs )
	return RS:GetVolume(ent)
end

function DEVICES.GET_CLIMATE_DEFAULT( name, RS )
	local enviro = GAMEMODE:GetPlugin("Environments")
	if (!enviro) then return end

	return enviro:GetDefaultEnvironment()[name]
end

function DEVICES.CLIMATE.PROVIDE_GRAVITY( ent, RS )
	if ( !ent:HasValidPlanet() ) then return 0 end
	return DEVICES.GET_CLIMATE_DEFAULT( "Gravity" ) or 0
end

function DEVICES.CLIMATE.PROVIDE_PRESSURE( ent, RS )
	return DEVICES.GET_CLIMATE_DEFAULT( "Pressure" ) or 1
end

function DEVICES.CLIMATE.PROVIDE_OXYGEN( ent, RS )
	return DEVICES.GET_CLIMATE_DEFAULT( "Oxygen" )
end

function DEVICES.CLIMATE.PROVIDE_ATMOSPHERE( ent, RS )
	return DEVICES.GET_CLIMATE_DEFAULT( "Atmosphere" ) or 1
end

function DEVICES.CLIMATE.PROVIDE_TEMPERATURE( ent, RS )
	return DEVICES.GET_CLIMATE_DEFAULT( "Temperature" ) or 288
end

function DEVICES.CLIMATE.PROVIDE_SIZE( ent, RS )
	return DEVICES.CLIMATE.BASE_VOLUME(ent, RS) * 2.5
end

function DEVICES.CLIMATE.CONSUME_ENERGY( ent, RS )
	return DEVICES.CLIMATE.BASE_VOLUME(ent, RS)
end

function DEVICES.CLIMATE.CONSUME_OXYGEN( ent, RS )
	--TODO: add pressure and atmosphere
	return DEVICES.CLIMATE.BASE_VOLUME(ent, RS) * 0.2
end

function DEVICES.CLIMATE.REQUIREMENTS( ent, RS )
	local consume = DEVICES.CLIMATE.BASE_VOLUME(ent, RS) * 0.1

	if ( !IsValid(ent:GetPlanet()) ) then consume = consume * 0.5 end --double requirements while in space

	local res = RS:GetNodeStored( ent, "Energy" )
	if ( consume > res ) then self:SetActive( false ); return false end

	local res = RS:GetNodeStored( ent, "Oxygen" )
	if ( consume > res ) then self:SetActive( false ); return false end

	return true
end
