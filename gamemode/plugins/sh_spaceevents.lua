--[[
	Author: MadDog (steam id md-maddog)

	TODO: finish
]]

local EVENTS = {
	--plugin info
	Name = "Space Events",
	Author = "MadDog",
	Version = 12222015,

	--settings
	CVars = {
		"sb_space_events_enable" = { server = true, text = "Enable Space Events", default = true },
		"sb_space_events_total" = { server = true, text = "Total Events", default = 3, min = 0, max = 10, decimals = 0 },
		"sb_space_event_min" = { server = true, text = "Events Min Size", default = 2000, min = 500, max = 2000, decimals = 0 },
		"sb_space_events_max" = { server = true, text = "Events Max Size", default = 5000, min = 500, max = 5000, decimals = 0 },
	}
}

if CLIENT then GM:AddPlugin(ASTEROIDS) return end

EVENTS.Entities = { "sb_space_clouds" }

function EVENTS:Startup()
	self:InitPostEntity()
end

function EVENTS:ShutDown()
	for _, enttype in pairs( self.Entities ) do
		utilx.RemoveAllByClass( enttype )
	end
end

function EVENTS:InitPostEntity( )
	for _, enttype in pairs( self.Entities ) do
		utilx.RemoveAllByClass( enttype )
	end

	if ( !self:IsActive() ) then return end

	for variable = 0, self:GetSetting("sb_space_events_total"), 1 do
		self:SpawnEvents( math.random(self:GetSetting("sb_space_event_min"),self:GetSetting("sb_space_events_max")) )
	end
end

function EVENTS:SpawnEvents( size )
	local pos = utilx.RandomEmptyPosition( size )
	if (!pos) then MsgN("Could not spawn space events!") return end

	local ent = ents.Create( table.Random(self.Entities) )

	ent:SetPos(pos)
	ent:SetSize( size )
	ent:Spawn()
	ent:Activate()

	--if IsValid(Entity(1)) then Entity(1):SetPos( pos ) end
end

GM:AddPlugin(EVENTS)