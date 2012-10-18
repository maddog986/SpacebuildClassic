--[[

	Author: MadDog (steam id md-maddog)

]]

SB = {}
SB.Name = "Spacebuild Classic v2";
SB.Email = "drew@aspinvision.com";
SB.Author = "MadDog";
SB.Website = "http://www.facepunch.com/members/145240-MadDog986";
SB.Folder = GM.Folder;
SB.IsSandboxDerived = true
SB.IsSpacebuildDerived = true

DeriveGamemode("Sandbox")

table.Merge(GM, SB)

--debug text
function SB:print( ... )
	local args = {...}
	table.insert(args, "\n")
	MsgC( Color(235, 190, 240), unpack(args) )
end

local s = {}

function smoothit( name, target )
	s[name] = (s[name] or target or 0)
	local a = (target - s[name]) * 0.1
	s[name] = s[name] + a
	return math.Round(s[name])
end

function SB:Config( name, default )
	local value = GetConVar(name)

	if (SERVER and !value and default and string.len(tostring(default)) > 0) then
		CreateConVar(name, tostring(default), {FCVAR_REPLICATED,FCVAR_ARCHIVE})
		return self:Config( name, default )
	end

	return value
end

function SB:ConfigBool( name, default )
	if (self:Config( name, default )) then
		return self:Config( name, default ):GetBool()
	else
		return false
	end
end

function SB:ConfigInt( name, default )
	if (self:Config( name, default )) then
		return self:Config( name, default ):GetInt()
	else
		return 0
	end
end

function SB:ConfigFloat( name, default )
	if (self:Config( name, default )) then
		return self:Config( name, default ):GetFloat()
	else
		return 0
	end
end


SB.stored = {}
SB.classes = {}

function SB:RegisterFunc( name, class, func )
	SB.stored[name] = {class = class, func = func}
end

function SB:Register( class )
	class.Name = class.Name or "Unknown-" .. SysTime()
	self:print("-- Register Class: ", class.Name)
	SB.classes[class.Name] = class
	--class.BaseClass = SB
end

function SB:Remove( name )
	self:print("-- Remove Class: ", name)
	SB.stored[name] = nil
end

function SB:RemoveClass( class )
	self:print("-- Remove Class: ", class.Name)
	if (class.Name) then SB.classes[class.Name] = nil end
end

function SB:GetClass( name )
	return SB.classes[name]
end

if ( !hook.SBCall ) then hook.SBCall = hook.Call; end

-- A function to call a hook.
function hook.Call( name, gamemode, ... )
	local arguments = {...}
	local hookCall = hook.SBCall

	if (!gamemode) then
		gamemode = SB
	end

	local value

	if (!SB.stored) then SB.stored = {} end
	if (!SB.classes) then SB.classes = {} end

	--function hooks
	if (SB.stored[name] and type( SB.stored[name].func ) == "function") then
		local value = SB.stored[name].func( SB.stored[name].class, unpack(arguments) )
		if (value != nil) then return value end
	end

	--class hooks
	for _, class in pairs(SB.classes) do
		if (class[name] and type(class[name]) == "function") then
			if (name == "Think" and class.NextThink and class.NextThink > CurTime()) then continue end

			local value = class[name]( class, unpack(arguments) )
			if (value != nil) then return value end
		end
	end

	--gamemode hooks...
	if (SB[name] and type( SB[name] ) == "function") then
		if ( name == "Think" and SB.NextThink and SB.NextThink > CurTime() ) then return end
		local value = SB[name]( SB, unpack(arguments) )
		if (value != nil) then return value end
	end

	if (value == nil) then
		return hookCall( name, gamemode, unpack(arguments) )
	else
		return value
	end
end

--extra files
for k, v in pairs( file.Find(SB.Folder .. "/gamemode/modules/sh_*", "GAME") ) do
	if (SERVER) then AddCSLuaFile("modules/"..v); end
	include("modules/"..v);
end


--[[
	fixes
]]

local meta = FindMetaTable("Entity")

if (!meta.OldSetColor) then meta.OldSetColor = meta.SetColor end

--fixes alpha issues
function meta:SetColor( color )
	if (color.a < 255) then self:SetRenderMode(1) end
	return self:OldSetColor(color)
end