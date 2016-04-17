--[[

	Author: MadDog (steam id md-maddog)
	Contact: http://www.facepunch.com/members/145240-MadDog986

]]

local meta = FindMetaTable("Player")

function meta:GetEyeEntity()
	return self:GetEyeTrace().Entity
end



local meta = FindMetaTable("Entity")

function meta:Distance( ent )
	return self:GetPos():Distance( ent:GetPos() )
end

--Credit JetBloom https://facepunch.com/showthread.php?t=1338842&p=43314258&viewfull=1#post43314258
function meta:CollisionRulesChanged()
	if not self.m_OldCollisionGroup then self.m_OldCollisionGroup = self:GetCollisionGroup() end
	self:SetCollisionGroup(self.m_OldCollisionGroup == COLLISION_GROUP_DEBRIS and COLLISION_GROUP_WORLD or COLLISION_GROUP_DEBRIS)
	self:SetCollisionGroup(self.m_OldCollisionGroup)
	self.m_OldCollisionGroup = nil
end

--i believe this crap helps stop some issues like physics crashes? if not please let me know!
--got the idea from this post: https://facepunch.com/showthread.php?t=1460189&p=47511040&viewfull=1#post47511040
function meta:CollisionChanged()
	self:CollisionRulesChanged()

	local phys = self:GetPhysicsObject()

	if ( IsValid(phys) ) then
		phys:Wake()
		phys:RecheckCollisionFilter()
	end
end

function meta:GetVolume()
	local mins, maxs = self:OBBMins(), self:OBBMaxs()
	return (maxs.x - mins.x) + (maxs.y - mins.y) + (maxs.z - mins.z)
end

function meta:SetAlpha( alpha )
	local color = self:GetColor()

	color.a = alpha

	self:SetColor( color )
end

function meta:GetAlpha()
	return self:GetColor().a
end

--[[
	Begin custom EmitSound and StopSound functions, this fixes the StopSound function
]]
function meta:EmitSound( path, volume )
	self.sounds = self.sounds or {}
	
	local sound = self.sounds[path] or CreateSound( self, Sound(path) )

	if ( !IsValid(sound) ) then return end

	if ( volume ) then sound:ChangeVolume( volume ) end

	sound:Play()

	self:DeleteOnRemove(sound)

	self.sounds[path] = sound

	self:CallOnRemove( "EmitSoundStopAll", function() self:StopAllSounds() end)
end

function meta:StopSound( path )
	if ( !self.sounds or !IsValid(self.sounds[path]) ) then return end

	self.sounds[path]:Stop()
end

function meta:StopAllSounds()
	for path, sound in pairs( self.sounds or {} ) do
		if ( !IsValid(sound) ) then continue end
		sound:Stop()
	end
end

--this fixes some parent tools
meta.OldSetParent = meta.OldSetParent or meta.SetParent

function meta:SetParent( ent )
	if ( self:GetParent() == self ) then return self end

	return self:OldSetParent(ent)
end

--custom ignite functions. default one uses smoke and it lags bad!
function meta:Ignite( duration, radius )
	if ( IsValid(self._fire) ) then return end --let the fire finish

	local fire = ents.Create("env_fire")
	fire:SetPos( self:GetPos() )
	fire:SetParent( self )
	fire:SetKeyValue( "targetname", "fire" )
	fire:SetKeyValue( "damagescale", 1 )
	fire:SetKeyValue( "health", (duration or 10) )
	fire:SetKeyValue( "fireattack", math.random(0,3) )	--<integer> Amount of time the fire takes to grow to full strength. Set higher to make the flame build slowly.
	fire:SetKeyValue( "firesize", (radius or 20) )
	fire:SetKeyValue( "StartDisabled", "0" )
	fire:SetKeyValue( "spawnflags", (2 + 4 + 16 + 128 + 256) )
	fire:Spawn()
	fire:Fire("StartFire","1","0")

	self._fire = fire
end

function meta:Extinguish()
	SafeRemoveEntity( self._fire )
end

function meta:IsOnFire()
	return IsValid(self._fire)
end