--[[

	Author: MadDog (steam id md-maddog)

	TODO:
		- Cleanup/finish/improve
]]
if true then return end

local PP = {}
PP.Name = "Prop Protection"
PP.Author = "MadDog"
PP.Version = 1

function PP:IsEnabled()
	return true
end

--[[
	META MODS
]]
local meta = FindMetaTable("Player")

function meta:CleanSteamID( )
	if (SERVER) then
		return string.gsub(self:SteamID(), ":", "_")
	else
		return string.gsub(self:GetNWString("SteamID"), ":", "_")
	end
end

function meta:IsBuddy( ply )
	if (!PP:IsEnabled()) or (!ply) or (!ply:IsValid()) or !(self:GetPData( ply:CleanSteamID() ) ) then return false end
	if (!self.Buddies) then self:LoadBuddies() end
	return table.HasValue( self.Buddies, MD.CleanSteamID( ply ) )
end

function meta:AddBuddy( ply )
	if (!MDPP.IsEnabled()) or (!ply) or (!ply:IsValid()) then return end
	if (!self.Buddies) then self:LoadBuddies() end

	--add buddy to table
	table.insert(self.Buddies, MD.CleanSteamID( ply ))

	--save buddies
	self:SaveBuddies()
end

function meta:RemoveBuddy( ply )
	if (!MDPP.IsEnabled()) or (!ply) or (!ply:IsValid()) then return end
	if (!self.Buddies) then self:LoadBuddies() end

	--remove buddy
	MD.DeleteFromTable( self.Buddies, MD.CleanSteamID( ply ) )

	--save buddies
	self:SaveBuddies()
end

function meta:ClearBuddies()
	if (!MDPP.IsEnabled()) then return end
	self:SetPData("MPPBuddies", nil)
	self.Buddies = {}
end

function meta:LoadBuddies()
	if (!MDPP.IsEnabled()) or (self.Buddies) then return end

	--convert to table
	self.Buddies = MD.Explode( self:GetPData("MPPBuddies"), ";" )
end

function meta:SaveBuddies()
	if (!MDPP.IsEnabled()) or (!self.Buddies) then return end

	--save the buddies table as a string
	self:SetPData( "MPPBuddies", table.concat(self.Buddies,";") )
end

--[[
MDPP.PlayerInitialSpawn = function( ply )

end
hook.Add("PlayerInitialSpawn", "MDPP.PlayerSpawn", MDPP.PlayerSpawn)


MDPP.PlayerDisconnected = function( ply )

end
hook.Add("PlayerDisconnected", "MDPP.PlayerDisconnected", MDPP.PlayerDisconnected)
]]

function MDPP.CleanupProps( ply, cmd, args )
	if (!MDPP.IsEnabled()) then return end

	for _, _ent in pairs(ents.GetAll()) do
		if (_ent:GetOwner() == ply) and (!_ent:IsWeapon()) then _ent:Remove() end
	end

	ply:EasyMessage("All of your stuff has been cleaned up!")
end
concommand.Add("MDPP_CleanupProps", MDPP.CleanupProps)




function MDPP.ApplyBuddySettings( ply, cmd, args )
	if (!MDPP.IsEnabled()) then return end

	for _, _ply in pairs(player.GetAll()) do
		if (ply != _ply) then
			local steamID = MD.CleanSteamID( _ply )
			local isBuddy = tonumber(ply:GetInfo("MDPP_Buddy_" .. steamID))

			--remove buddy
			if (ply:IsBuddy( _ply )) and (isBuddy == 0) then
				ply:RemoveBuddy( ply )
			--add buddy
			elseif (!ply:IsBuddy( _ply )) and (isBuddy == 1) then
				ply:AddBuddy( ply )
			end
		end
	end

end
concommand.Add("MDPP_ApplyBuddySettings", MDPP.ApplyBuddySettings)


--[[
MDPP.PhysGravGunPickup = function( ply, ent )

end
hook.Add("GravGunPunt", "MDPP.GravGunPunt", MDPP.PhysGravGunPickup)
hook.Add("GravGunPickupAllowed", "MDPP.GravGunPickupAllowed", MDPP.PhysGravGunPickup)
hook.Add("PhysgunPickup", "MDPP.PhysgunPickup", MDPP.PhysGravGunPickup)




MDPP.CanTool = function( ply, tr, toolgun )
	return true
end
hook.Add("CanTool", "MDPP.CanTool", MDPP.CanTool)



MDPP.EntityTakeDamage = function(ent, inflictor, attacker, amount)
	return true
end
hook.Add("EntityTakeDamage", "MDPP.EntityTakeDamage", MDPP.EntityTakeDamage)



MDPP.PlayerUse = function(ply, ent)
	return true
end
hook.Add("PlayerUse", "MDPP.PlayerUse", MDPP.PlayerUse)



MDPP.OnPhysgunReload = function(weapon, ply)
	return true
end
hook.Add("OnPhysgunReload", "MDPP.OnPhysgunReload", MDPP.OnPhysgunReload)



MDPP.EntityRemoved = function( ent )
end
hook.Add("EntityRemoved", "MDPP.EntityRemoved", MDPP.EntityRemoved)



MDPP.PlayerSpawnedSENT = function( ply, ent )
end
hook.Add("PlayerSpawnedSENT", "MDPP.PlayerSpawnedSENT", MDPP.PlayerSpawnedSENT)



MDPP.PlayerSpawnedVehicle = function( ply, ent )
end
hook.Add("PlayerSpawnedVehicle", "MDPP.PlayerSpawnedVehicle", MDPP.PlayerSpawnedVehicle)


]]


