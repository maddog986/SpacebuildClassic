--[[

	Author: MadDog (steam id md-maddog)
	Contact: http://www.facepunch.com/members/145240-MadDog986

]]

if ( CLIENT ) then
	net.Receive("SkillUnlocked", function()

	end)
return end

local SKILLS = {
	Name = "Skills",
	Description = "Skills and upgrades."
}

function SKILLS:EnterEnvironment( ply, environment )
	if ( !ply:IsPlayer() or !environment:IsPlanet() ) then return end

	local times = ply:GetPData("EnterPlanet", 0) + 1

	ply:SetPData( "EnterPlanet", times )

	if ( times > 100 ) then
		ply:SkillUnlock( "PlanetTraveler" )
	end
end

function SKILLS:LeaveEnvironment( ply, environment )
	if ( !ply:IsPlayer() or !environment:IsPlanet() ) then return end

	local times = ply:GetPData("LeavePlanet", 0) + 1

	ply:SetPData( "LeavePlanet", times )

	if ( times > 100 ) then
		ply:SkillUnlock( "SpaceTraveler" )
	end
end

function SKILLS:Think()
	self.NextThink = 5

	local RS = GAMEMODE:GetPlugin( "Resources" )
	if ( !RS ) then return end

	for _, device in pairs( RS.devices ) do

		for name, value in pairs( RS:GetEntityStored( device ) or {} ) do
			if ( value > 10000 and IsValid(device:GetCreator()) and device:GetCreator():IsPlayer() ) then
				device:GetCreator():SkillUnlock( "StorageMaster" )
			end
		end

	end
end

GM:AddPlugin( SKILLS )




function DEVICES.STORAGE.BASE_VOLUME( ent )
	return RS:GetVolume(ent)
end

function DEVICES.CONSUME.BASE_VOLUME( ent, RS )
	return RS:GetVolume(ent) * 0.5
end




--[[	Player Meta Table	]]
local ply = FindMetaTable( "Player" )

util.AddNetworkString("SkillUnlocked")

function ply:SkillUnlock( name )
	if ( self:HasSkill(name) ) then return end --already unlocked

	self:SetPData( name, true )

	net.Start( "SkillUnlocked" )
	net.WriteString( name )
	net.Send( self )
end

function ply:GetSkill( name )
	return self:GetPData( name )
end

function ply:HasSkill( name )
	return (self:GetSkill(name) ~= nil)
end