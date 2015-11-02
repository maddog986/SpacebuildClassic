--[[

	Author: MadDog (steam id md-maddog)
	Contact: http://www.facepunch.com/members/145240-MadDog986

]]

--speed up vars
local GM = GM
local include = include
local type = type
local hook = hook
local unpack = unpack
local pairs = pairs
local math = math
local table = table
local resource = resource
local string = string

GM.Name = "Spacebuild Classic"
GM.Email = "drew@aspinvision.com"
GM.Author = "MadDog"
GM.Version = 1
GM.Website = "http://www.facepunch.com/members/145240-MadDog986"
GM.IsSandboxDerived = true
GM.IsSpacebuildDerived = true

print("---------------------------------------------------------------------------------")
print("-- " .. GM.Name .. " v" .. GM.Version .. " by " .. GM.Author .. " Loading --")
print("---------------------------------------------------------------------------------")

--DEFINE_BASECLASS( "gamemode_sandbox" )
DeriveGamemode("Sandbox")

--internal vars
GM._s = {}
GM._stored = {}
GM._classes = {}

function GM:AddFolder( path )
	local files, folders = file.Find( path .. "/*", "GAME" )

	for k, v in pairs( files ) do
		resource.AddFile( path .. "/" .. v )
	end

	for k, v in pairs( folders ) do
		self:AddFolder( path .. "/" .. v )
	end
end

function GM:AddFiles( path )
	local p = string.match(path, "(.*/)")--:gsub( GM.Folder .. "/gamemode/" , "")

	for _, fileName in pairs( file.Find( path, "GAME" ) ) do
		resource.AddFile( p .. fileName )
	end
end

function GM:Include( path )
	local p = string.match(path, "(.*/)")--:gsub( GM.Folder .. "/gamemode/" , "")

	for _, fileName in pairs( file.Find(GM.Folder .. "/gamemode/" .. path, "GAME") ) do
		if fileName:find("cl_") then
			if (SERVER) then
				AddCSLuaFile( p .. fileName )
			else
				include( p .. fileName )
			end
		elseif fileName:find("sh_") then
			if (SERVER) then
				AddCSLuaFile( p .. fileName )
			end

			include( p .. fileName )
		elseif SERVER and fileName:find("sv_") then
			include( p .. fileName )
		end
	end
end

function GM:Tween( name, target )
	self._s[name] = (self._s[name] or target or 0)
	local a = (target - self._s[name]) * 0.1
	self._s[name] = self._s[name] + a
	return math.Round(self._s[name])
end

function GM:RegisterFunc( name, class, func )
	self._stored[name] = {class = class, func = func}
end

function GM:Register( class )
	class.Name = class.Name or "Unknown-" .. SysTime()
	self._classes[class.Name] = class

	if (class.player) then
		table.Merge( FindMetaTable( "Player" ), class.player)
	end

	if (class.entity) then
		table.Merge( FindMetaTable( "Entity" ), class.entity)
	end
end

function GM:RemoveClass( class )
	if (!class.Name) then return end

	if (self._classes[class.Name].Disable) then
		self._classes[class.Name]:Disable()
	end

	self._classes[class.Name] = nil
end

function GM:GetClass( name )
	return self._classes[name]
end

if ( !hook.SBCall ) then hook.SBCall = hook.Call; end

-- A function to call a hook.
function hook.Call( name, GM, ... )
	local arguments = {...}

	if (!GM) then GM = GAMEMODE end

	--function hooks
	if (GM._stored[name] and type( GM._stored[name].func ) == "function") then
		local value = GM._stored[name].func( GM._stored[name].class, unpack(arguments) )
		if (value != nil) then return value end
	end

	--class hooks
	for _, class in pairs(GM._classes) do
		if (class[name] and type(class[name]) == "function") then
			if (name == "Think" and class.NextThink and class.NextThink > CurTime()) then continue end

			local value = class[name]( class, unpack(arguments) )
			if (value != nil) then return value end
		end
	end

	--gamemode hooks...
	if (GM[name] and type( GM[name] ) == "function") then
		if ( name == "Think" and GM.NextThink and GM.NextThink > CurTime() ) then return end
		local value = GM[name]( GM, unpack(arguments) )
		if (value != nil) then return value end
	end

	if (value == nil) then
		return hook.SBCall( name, GM, unpack(arguments) )
	else
		return value
	end
end

function IsValid( object )
	if (!object or !object.IsValid) then return false end
	return object:IsValid()
end

--load the modules
GM:Include( "modules/cl_*" )
GM:Include( "modules/sh_*" )