--[[
	Author: MadDog (steam id md-maddog)

	This brush point is required since touch functions are funky at best.
	Trying to setup proper touch based events.
]]
AddCSLuaFile()

DEFINE_BASECLASS( "base_entity" ) --use should use brush, but we want this to be clientside sometimes

ENT.IgnoreDamage = true

--[[ Client Side ]]
if CLIENT then
	function ENT:Draw() end --never draw brush by default
return end

--[[	Server Side ]]
AccessorFunc( ENT, "brush_shape", "Shape", FORCE_NUMBER )

function ENT:Initialize()
	self:PhysicsInit( SOLID_NONE )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_NONE )

	self:SetNotSolid( true )
	self:SetTrigger( true )

	if ( self:GetShape() == BRUSH_BOX ) then
		self:SetModel( "models/hunter/blocks/cube025x025x025.mdl" )
	else
		self:SetModel( "models/dav0r/hoverball.mdl" ) --sphere
	end
end

function ENT:SetSize( size, size2 )
	if ( self:GetShape() == BRUSH_BOX ) then --square box
		self:PhysicsInitBox( vector_one * -size, vector_one * size )
		self:SetCollisionBounds( vector_one * -size, vector_one*size )

	elseif ( self:GetShape() == BRUSH_ELLIPSOID and type(size) == "vector" and type(size2) == "vector" ) then
		self:PhysicsInitBox( size, size2 )
		self:SetCollisionBounds( size, size2 )

	else--sphere is default
		self:PhysicsInitSphere( size )
		self:SetCollisionBounds( vector_one * -size, vector_one * size )
	end

	self.brush_size = size
end

function ENT:GetSize() return self.brush_size or 0 end

function ENT:IsWithin( pos ) --Vector or Entity may be passed in for convience
	if ( type(pos) ~= "Vector" ) then pos = pos:NearestPoint( self:GetPos() ) end
	if ( type(pos) ~= "Vector" ) then return false end

	if ( self:GetShape() == BRUSH_BOX ) then
		--TODO: finish
		--local mins, maxs = self:LocalToWorld(self:OBBMins()), self:LocalToWorld(self:OBBMaxs())
		local dir = ( pos - self:GetPos() ):GetNormalized()
		local dist = pos:Distance( self:GetPos() )

		local hit, hitpos, hitfrac = util.IntersectRayWithOBB( pos, dir * dist, self:GetPos(), self:GetAngles(), self:OBBMins(), self:OBBMaxs() )

		--MsgN("hitfrac: ", hitfrac)

		return (hitfrac)

		--return hitfrac == 0
		--TODO: add proper box support with angles of device
		--return (pos.x > mins.x and pos.x < maxs.x and pos.y > mins.y and pos.y < maxs.y and pos.z > mins.z and pos.z < maxs.z)
	elseif ( self:GetShape() == BRUSH_ELLIPSOID ) then
		local spos = self:GetPos()

		return ((pos.x/spos.x)^2 + (pos.y/spos.y)^2 + (pos.z/spos.z)^2) == 1
	end

	return ( pos:Distance( self:GetPos() ) < self:GetSize() )
end

function ENT:StartTouch( ent )
	if ( !self:PassesTriggerFilters(ent) or self:HasEntity(ent) or !self:IsWithin(ent) ) then return false end

	self.brush_touched_entities = self.brush_touched_entities or {}
	self.brush_touched_entities[ent:EntIndex()] = ent
	self:CallOnRemove( self:EntIndex() .. "RemoveEnt" .. ent:EntIndex(), function( ent ) self.brush_touched_entities[ent:EntIndex()] = nil end) --cleanup

	self:StartTouchFixed( ent )

	return true
end

function ENT:EndTouch( ent )
	if ( !self:PassesTriggerFilters(ent) or !self:HasEntity(ent) or self:IsWithin(ent) ) then return false end

	self.brush_touched_entities[ent:EntIndex()] = nil
	self:RemoveCallOnRemove( self:EntIndex() .. "RemoveEnt" .. ent:EntIndex() ) --cleanup

	self:EndTouchFixed( ent )

	return true
end

function ENT:Touch( ent )
	if ( !self:PassesTriggerFilters(ent) ) then return end

	if (( !self:HasEntity(ent) and self:StartTouch( ent ) ) or ( self:HasEntity(ent) and !self:EndTouch( ent ) ))  then
		self:TouchFixed( ent )
	end
end

--functions to ignore touchs by enties
function ENT:IgnoreEntity( ent )
	self.brush_ignore_entities = self.brush_ignore_entities or {}
	self.brush_ignore_entities[ ent:EntIndex() ] = ent
end

function ENT:RemoveIgnoreEntity( ent )
	self.brush_ignore_entities[ ent:EntIndex() ] = nil
end

function ENT:ShouldIgnoreEntity( ent )
	return self.brush_ignore_entities and IsValid(self.brush_ignore_entities[ ent:EntIndex() ])
end

function ENT:StartTouchFixed( ent ) end --use this in your entity
function ENT:EndTouchFixed( ent ) end --use this in your entity
function ENT:TouchFixed( ent ) end --use this in your entity
function ENT:PassesTriggerFilters( ent ) return IsValid(ent) and !self:ShouldIgnoreEntity(ent) end
function ENT:HasEntity( ent ) return self.brush_touched_entities and IsValid(self.brush_touched_entities[ent:EntIndex()]) end
function ENT:GetEntitiesByClass( class )
	local entities = {}

	for _, ent in pairs( self.brush_touched_entities or {} ) do
		if ( ent:GetClass() == class ) then
			table.insert( entities, ent )
		end
	end

	return entities
end
function ENT:GetEntities() return self.brush_touched_entities or {} end
function ENT:UpdateTransmitState() return TRANSMIT_NEVER end
function ENT:PhysicsSimulate( phys, deltatime ) return SIM_NOTHING end --dont ever move.
function ENT:CanTool() return false end
function ENT:GravGunPunt() return false end
function ENT:GravGunPickupAllowed() return false end
function ENT:PhysgunPickup() return false end
function ENT:OnTakeDamage() return false end