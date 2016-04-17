--[[
	Author MadDog
]]

local PP = {
	--plugin info
	Name = "Prop Protection",
	Author = "MadDog",
	Version = 12272015,

	--settings
	CVars = {
		--server setting
		"pp_enable" = { server = true, text = "Enable Prop Protection", default = true }
	}
}

GM:AddPlugin( PP )

if CLIENT then

	local function PPPanel( panel )
		panel:ClearControls()
		panel:AddControl( "Label", {Text = "Prop Protection: Adding a buddy allows them to touch, control and use your props."} )
		panel:AddControl( "Button", {Text = "Cleanup All My Props", Command = "pp_propscleanup"} )
		panel:AddControl( "Label", {Text = "Buddies Panel:"} )

		local plys = player.GetAll()

		if ( #plys == 1) then
			panel:AddControl( "Label", {Text = "No current players online."} )
		else
			for _, ply in pairs( plys ) do
				panel:AddControl( "CheckBox", { Label = ply:Nick(), Command = "pp_buddies " .. ply:SteamID64() } )
			end
		end

		panel:AddControl( "Button", {Text  = "Clear All Buddies", Command = "pp_buddies clear"} )

		if ( !LocalPlayer():IsAdmin() ) then return end

		panel:AddControl( "CheckBox", {Label = "Enable Prop Protection", Command = "pp_enable"} )

		panel:AddControl( "Label", {Text = "Cleanup Panel"} )

		for _, ply in pairs( plys ) do
			if ( !IsValid(ply) ) then continue end

			panel:AddControl( "Button", {Text = ply:Nick(), Command = "pp_admin_cleanup "..ply:SteamID64() } )
		end

		panel:AddControl( "Label", {Text = "Other Cleanup Options"} )
		panel:AddControl( "Button", {Text = "Cleanup Disconnected Players Props", Command = "pp_admin_cleanup all"} )
	end

	function PP:PopulateToolMenu()
		spawnmenu.AddToolMenuOption( "Spacebuild", "Settings", "Prop Protection", "Prop Protection", "", "", PPPanel )
	end
return end

concommand.Add("pp_buddies", function( player, cmd, args)
	if ( args[1] == "clear" ) then
		PP:ClearBuddies( player )
	return end

	local steamid64 = args[1]
	local buddy = Either( args[2] == 1, true, false)
	local ply = player.GetBySteamID64( steamid64 )

	if ( !IsValid(ply) ) then return end

	if ( buddy ) then
		player:AddBuddy( ply )
	else
		player:RemoveBuddy( ply )
	end
end)

concommand.Add("pp_propscleanup", function( ply, cmd, args)
	for _, ent in pairs( ents.GetAll() ) do
		if ( !IsValid(ent) ) then continue end
		if ( ent:GetCreated() == ply ) then SafeRemoveEntity( ent ) end
	end
end)

concommand.Add("pp_admin_cleanup", function( player, cmd, args)
	if ( args[1] == "all" ) then
		game.CleanUpMap()
	return end

	local steamid64 = args[1]
	local ply = player.GetBySteamID64( steamid64 )

	if ( !IsValid(ply) ) then return end

	for _, ent in pairs( ents.GetAll() ) do
		if ( !IsValid(ent) ) then continue end
		if ( ent:GetCreator() == ply ) then SafeRemoveEntity( ent ) end
	end
end)



--[[	SET OWNER STUFF	]]
function PP:PlayerSpawnedNPC( ply, ent ) ent:SetCreator(ply) end
function PP:PlayerSpawnedSENT( ply, ent ) ent:SetCreator(ply) end
function PP:PlayerSpawnedVehicle( ply, ent ) ent:SetCreator(ply) end
function PP:PlayerSpawnedProp( ply, model, ent ) ent:SetCreator(ply) end
function PP:PlayerSpawnRagdoll( ply, model ) ent:SetCreator(ply) end

--makes sure an owner is set when someone touches something with the physgun
function PP:PhysgunPickup( ply, ent )
	if ( !IsValid(ent:GetCreator()) ) then ent:SetCreator(ply) end
end

function PP:CanUse( ply, ent )
	if ( !PP:IsActive() ) then return true end --PP turned off
	if ( ent:IsWorld() ) then return ply:IsAdmin() end --only admins can use world object
	if ( !IsValid(ent:GetCreator()) ) then ent:SetCreator(ply) end
	return ( ply:IsAdmin() or ply:IsBuddy(ent) )
end

function PP:CanTool( ply, tr, tool )
	if ( !tr or !IsValid(tr.Entity) ) then return end
	return self:CanUse( ply, tr.Entity )
end

--shortcut other hooks
function PP:AllowPlayerPickup( ply, ent )
	return PP:CanUse( ply, ent )
end

function PP:GravGunPickupAllowed( ply, ent )
	return PP:CanUse( ply, ent )
end

function PP:PlayerCanPickupItem( ply, ent )
	return PP:CanUse( ply, ent )
end

function PP:OnPhysgunReload( weap, ply )
	local ent = ply:GetEyeTrace().Entity

	if ( !IsValid(ent) ) then return true end

	return self:CanUse( ply, ent )
end

function PP:PlayerUse( ply, ent )
	if ( !IsValid(ent:GetCreator()) ) then ent:SetCreator(ply) end
end

function PP:EntityTakeDamage( ent, dmg )
	if ( !IsValid(ent:GetCreator()) ) then return end

	local ply = dmg:GetAttacker()

	if ( IsValid(ply:GetCreator()) ) then ply = ply:GetCreator() end
	if ( !ply:IsPlayer() ) then return false end

	return self:CanUse( ply, ent )
end

if ( !PP.cleanup) then PP.cleanup = cleanup.Add end

function cleanup.Add( ply, type, ent )
	ent:SetCreator(ply)
	return PP.cleanup( ply, type, ent )
end

function PP:PlayerDisconnect( ply )
	ply:SaveBuddies()

    for _, ent in pairs( ents.GetAll() ) do
    	if ( !IsValid(ent) ) then continue end

		local phys = ent:GetPhysicsObject()

		if ( !IsValid(phys) ) then continue end

		if ( ent:GetCreator() == ply ) then
			phys:EnableMotion(false)
		end
    end
end








--[[	ENTITY FUNCTIONS
local meta = FindMetaTable( "Entity" )

function meta:SetCreator( ply )
	self.m_PlayerCreator = ply:SteamID64()
end

function meta:GetCreator()
	return player.GetBySteamID64( self.m_PlayerCreator )
end
]]


--[[	PLAYER FUNCTIONS	]]
local ply = FindMetaTable( "Player" )

ply.GetBuddies = function( self )
	self._buddies = self._buddies or pon.decode(self:GetPData("ppbuddies", "{}"))
	return self._buddies
end

ply.AddBuddy = function( self, ent )
	self:GetBuddies()
	table.insert( self._buddies, ent:SteamID64() )
	self:SaveBuddies()
end

ply.RemoveBuddy = function( self, ent )
	self:GetBuddies()
	table.RemoveByValue( self._buddies, ent:SteamID64() )
	self:SaveBuddies()
end

ply.IsBuddy = function( self, ent )
	self:GetBuddies()
	if ( type(ent) == "string" ) then return table.HasValue( self._budies, ent ) end
	if ( IsValid(ent) and ent:IsPlayer() ) then return table.HasValue( self._budies, ent:SteamID64() ) end
	return false
end

ply.ClearBuddies = function( self )
	self._buddies = {}
	self:SaveBuddies()
end

ply.SaveBuddies = function( self )
	self:SetPData( "ppbuddies", pon.encode(self._buddies) )
end