--[[

	Author: MadDog (steam id md-maddog)
]]

local _ent = FindMetaTable("Entity")

--[[
Begin custom EmitSound and StopSound functions, this fixes the StopSound function
]]
function _ent:EmitSound( path, volume )
	self.sounds = self.sounds or {}
	self.sounds[path] = CreateSound( self, path )

	if (volume) then
		self.sounds[path]:ChangeVolume( volume )
	end

	self.sounds[path]:Play()
end

function _ent:StopSound( path )
	if (!self.sounds or !self.sounds[path]) then return end
	self.sounds[path]:Stop()
	self.sounds[path] = nil
end

function _ent:StopAllSounds()
	if (!self.sounds) then return end

	for path, sound in pairs( self.sounds ) do
		self:StopSound( path )
	end
end

--this fixes some parent tools
if (_ent and !_ent.OldSetParent) then --dont set twice, then we really crash stuff
	_ent.OldSetParent = _ent.SetParent

	--lets fix some parenting error bullshit
	function _ent:SetParent( ent )
		--some checks to prevent crashes!
		if (self:GetParent() == self) then
			return self
		end

		return self:OldSetParent(ent) --passed checks ok to save now
	end
end

--[[
	START CUSTOM WIRE FUNCTIONS
]]
if (!_ent.WireInput) then
function _ent:WireInput( name )
	if (!WireAddon or !name) then return end

	if (self.Inputs) then return end --some other addon is controlling this

	if not (CurTime() >= (self._wireinputupdate or 0)) then return end
	self._wireinputupdate = CurTime() + 1

	self.WireDebugName = (self.PrintName or "Unknown")

	if (!self.WireInputs) then
		self.WireInputs = {name}
		self.RSInputs = Wire_CreateInputs( self, self.WireInputs )
	elseif (!table.HasValue( self.WireInputs, name)) then
		table.insert( self.WireInputs, name )
		table.sort(self.WireOutputs)

		--add new input
		Wire_AdjustInputs( self, self.WireInputs )
	end
end
end

if (!_ent.WireOutput) then
function _ent:WireOutput( name )
	if (!WireAddon or !name) then return end

	if (self.Outputs) then return end --some other addon is controlling this

	if not (CurTime() >= (self._wireoutputupdate or 0)) then return end
	self._wireoutputupdate = CurTime() + 1

	self.WireDebugName = (self.PrintName or "Unknown")

	if (!self.WireOutputs) then
		self.WireOutputs = {name}
		self.RSOutputs = Wire_CreateOutputs( self, self.WireOutputs )
	elseif (!table.HasValue( self.WireOutputs, name)) then
		table.insert( self.WireOutputs, name )
		table.sort(self.WireOutputs)

		--add new output
		Wire_AdjustOutputs( self, self.WireOutputs )
	end
end
end

if (!_ent.WireUpdate) then
function _ent:WireUpdate( name, value )
	if (!WireAddon) then return end

	if (self.Outputs or self.Inputs) then return end --some other addon is controlling this

	--make sure output exists
	if (!table.HasValue( self.WireOutputs or {}, name)) then self:WireOutput( name ) end

	--update output
	Wire_TriggerOutput( self, name, value )
end
end

--custom ignite functions. default one uses smoke and it lags bad!
function _ent:Ignite( duration, radius )
	--dont start if already on fire
	if (self._fire) and (self._fire:IsValid()) then return end --let the fire finish

	--env_fire
	self._fire = ents.Create("env_fire")
	self._fire:SetParent( self )
	self._fire:SetPos( self:GetPos() )
	self._fire:SetKeyValue( "targetname", "fire" )
	self._fire:SetKeyValue( "damagescale", 1 )
	self._fire:SetKeyValue( "health", (duration or 10) )
	self._fire:SetKeyValue( "fireattack", "0" )		--<integer> Amount of time the fire takes to grow to full strength. Set higher to make the flame build slowly.
	self._fire:SetKeyValue( "firesize", (radius or 20) )
	self._fire:SetKeyValue( "StartDisabled", "0" )
	self._fire:SetKeyValue( "spawnflags", tostring(2 + 4 + 16 + 128 + 256) )
	self._fire:Spawn()
	self._fire:Fire("StartFire","1","0")
	self._fire:CallOnRemove("IgniteRemove", function()
		if (self._fire.FireSound) then self._fire.FireSound:Stop() end
		self._fire = nil
	end)

	--the noise
	--self._fire.FireSound = CreateSound(self._fire, MDRP.FireSounds[math.random(1,#MDRP.FireSounds)])
	--self._fire.FireSound:Play()
end

function _ent:Extinguish()
	if (self._fire) and (self._fire:IsValid()) then self._fire:Remove() end
end

function _ent:IsOnFire()
	if (self._fire) and (self._fire:IsValid()) then
		return true
	else
		return false
	end
end

function _ent:IsInWater( pos )
	local trace = {}
	trace.start = pos
	trace.endpos = pos + Vector(0,0,1)
	trace.mask = bit.bor(MASK_WATER, MASK_SOLID)

	local tr = util.TraceLine(trace)

	return tr.Hit
end

function _ent:IsTouching( pos, class, range )
	for _, ent in pairs( ents.FindInSphere(pos, range) ) do
		local _pos = ent:LocalToWorld(ent:OBBCenter())

		if (ent:GetClass() == class) and ((pos-Vector(_pos.x, _pos.y, pos.z)):Length() <= range) then
			return true
		end
	end

	return false
end

if (!_ent.OldSetColor) then _ent.OldSetColor = _ent.SetColor end

--fixes alpha issues
function _ent:SetColor( color )
	if (color.a < 255) then self:SetRenderMode(1) end
	return self:OldSetColor(color)
end













function _ent:IsSkyAbove( )
	local tr = {}
	tr.start = self:GetPos() + (self:GetUp() * 3)
	tr.endpos = self:GetPos() + Vector(0, 0, 100000)
	tr.filter = self

	return util.TraceLine(tr).HitSky
end

function _ent:MakeSmoke()
	if (self.EnergyDamageEffects && self.EnergyDamageEffects > 0) then return end --dont do smoke if energy is sparking
	if ((self.SmokeDamageEffects or 0) > 1) then return end

	self.SmokeDamageEffects = (self.SmokeDamageEffects or 0) + 1

	timer.Simple(1.5, function(self)
		if (!IsValid(self)) then return end
		self.SmokeDamageEffects = self.SmokeDamageEffects - 1
	end, self)

	local Smoke = ents.Create("env_smoketrail")
	Smoke:SetKeyValue("opacity", 1)
	Smoke:SetKeyValue("spawnrate", 10)
	Smoke:SetKeyValue("lifetime", 2)
	Smoke:SetKeyValue("startcolor", "180 180 180")
	Smoke:SetKeyValue("endcolor", "255 255 255")
	Smoke:SetKeyValue("minspeed", 15)
	Smoke:SetKeyValue("maxspeed", 30)
	Smoke:SetKeyValue("startsize", (self:BoundingRadius() / 2))
	Smoke:SetKeyValue("endsize", self:BoundingRadius())
	Smoke:SetKeyValue("spawnradius", 10)
	Smoke:SetKeyValue("emittime", 300)
	Smoke:SetKeyValue("firesprite", "sprites/firetrail.spr")
	Smoke:SetKeyValue("smokesprite", "sprites/whitepuff.spr")
	Smoke:SetPos(self:GetPos())
	Smoke:SetParent(self)
	Smoke:Spawn()
	Smoke:Activate()
	Smoke:Fire("kill","", 1)
end



function _ent:CreateWaterEffect( pos )
	if (!self.WaterEffects) then self.WaterEffects = 0 end

	--make 10 water effects per ent
	if (self.WaterEffects > 3) then return end

	self.WaterEffects = self.WaterEffects + 1

	local waterEnt = ents.Create("water_projectile")

	if (!IsValid(waterEnt)) then return end

	waterEnt:SetPos(pos)
	waterEnt:Spawn()
	waterEnt:SetNetworkedInt("r", 100)
	waterEnt:SetNetworkedInt("g", 100)
	waterEnt:SetNetworkedInt("b", 255)
	waterEnt:SetNetworkedInt("a", 80)
	waterEnt:SetNetworkedInt("viscosity", 5)
	waterEnt:SetCollisionGroup( 4 )

	function waterEnt:OnRemove()
		self.WaterEffects = self.WaterEffects - 1
	end

	timer.Simple( 2, function()
		if (waterEnt && waterEnt:IsValid()) then
			waterEnt:Remove()
		end
	end, self, waterEnt)
end

function _ent:EnergyDamage( pos, mag )
	if ((self.EnergyDamageEffects or 0) > 3) then return end

	self.EnergyDamageEffects = (self.EnergyDamageEffects or 0) + 1

	timer.Simple(1.5, function(self)
		if (!IsValid(self)) then return end
		self.EnergyDamageEffects = self.EnergyDamageEffects - 1
	end, self)


	local ang = self:GetAngles()

	pos = pos or (self:LocalToWorld(self:OBBCenter()) + (ang:Up() * (self:BoundingRadius()/2)))

	local phys = self:GetPhysicsObject()

	if (!phys:IsValid()) then return end

	local mag = phys:GetVolume() / (phys:GetVolume() / 2) * (mag/10)

	self:EnergySparks((pos + (ang:Right() * mag)), mag)
	self:EnergySparks((pos - (ang:Right() * mag)), mag)
end

function _ent:EnergySparks( pos, magnitude )
	local ent = ents.Create("point_tesla")
	ent:SetKeyValue("targetname", "teslab")
	ent:SetKeyValue("m_SoundName" ,"DoSpark")
	ent:SetKeyValue("texture" ,"sprites/physbeam.spr")
	ent:SetKeyValue("m_Color" ,"200 200 255")
	ent:SetKeyValue("m_flRadius" ,tostring(magnitude*80))
	ent:SetKeyValue("beamcount_min" ,tostring(math.ceil(magnitude)+4))
	ent:SetKeyValue("beamcount_max", tostring(math.ceil(magnitude)+12))
	ent:SetKeyValue("thick_min", tostring(magnitude))
	ent:SetKeyValue("thick_max", tostring(magnitude*8))
	ent:SetKeyValue("lifetime_min" ,"0.1")
	ent:SetKeyValue("lifetime_max", "0.2")
	ent:SetKeyValue("interval_min", "0.05")
	ent:SetKeyValue("interval_max" ,"0.08")
	ent:SetPos( pos )
	ent:Spawn()
	ent:Fire("DoSpark","",0)
	ent:Fire("kill","", 1)
end