--[[
	Author: MadDog (steam id md-maddog)
]]
AddCSLuaFile()

DEFINE_BASECLASS( "sb_brush_base" )

ENT.PrintName = "Base Brush Environment"
ENT.Author	= "MadDog"

ENT.Spawnable = false
ENT.AdminOnly = false

ENT.brush_active = false

--shared functions
function ENT:IsPlanet() return false end

--[[ Client Side ]]
if CLIENT then
	function ENT:Draw() return false end
return end

--[[	Server Side ]]
function ENT:SetActive( active )
	self.brush_active = active

	for _, ent in pairs( self:GetEntities() ) do --forces update since environment status has changed
		ENVIRONMENTS:EnvironmentUpdate( ent )
	end
end

function ENT:GetActive() return self.brush_active end

function ENT:StartTouchFixed( ent )
	if ( self:IsPlanet() ) then
		ent:SetPlanet( self )
	else
		self:TouchEffect(ent)
	end

	hook.Run( "EnterEnvironment", ent, self )
end

function ENT:EndTouchFixed( ent )
	if ( self:IsPlanet() ) then
		ent:SetPlanet( nil )
	else
		self:TouchEffect(ent)
	end

	hook.Run( "LeaveEnvironment", ent, self )
end

function ENT:TouchEffect( ent )
	if ( !self:GetActive() ) then return end

	local pos = ent:GetPos()
	local normal = (pos - self:GetPos()):GetNormalized()

	local effect = EffectData()
	effect:SetStart( pos )
	effect:SetOrigin( pos )
	effect:SetScale( 10 )
	effect:SetMagnitude( 10 )
	effect:SetEntity( ent )
	util.Effect("TeslaHitBoxes" ,effect )

	local effect = EffectData()
	effect:SetEntity( ent )
	effect:SetOrigin( pos )
	effect:SetNormal( normal )
	effect:SetScale( 350 )

	util.Effect( "climate_passing", effect )
end

function ENT:SetEnvironment( data )
	self.environment = data or {}

	if ( type(data.Size) == "number" and self.Size ~= data.Size ) then self:SetSize( data.Size ) end
	if ( type(data.Shape) == "number" and self.Shape ~= data.Shape ) then self:SetShape( data.Shape ) end
	if ( type(data.Active) == "boolean" and self.Active ~= data.Active ) then self:SetActive( data.Active ) end
end

function ENT:PassesTriggerFilters( ent ) return BaseClass:PassesTriggerFilters(ent) and IsValid(ent:GetPhysicsObject()) end
function ENT:GetEnvironment() return self.environment or {} end

function ENT:Think()
	local parent = self.rsentity

	if ( !IsValid(parent) ) then return end

	local data = {}

	for name, value in pairs( parent.Environment ) do
		if ( type(value) == "function" ) then value = value( parent ) end
		data[name] = value
	end

	self:SetEnvironment( data )
	self:SetPos( parent:GetPos() + parent:OBBCenter() )

	self:NextThink( CurTime() + 1 )
	return true
end