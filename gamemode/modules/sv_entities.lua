local _ent = FindMetaTable("Entity")

--this fixes some parent tools
if (_ent and !_ent.OldSetParent) then --dont set twice, then we really crash stuff
	_ent.OldSetParent = _ent.SetParent

	--lets fix some parenting error bullshit
	function _ent:SetParent( ent )
		--some checks to prevent crashes!
		if (self.Entity:GetParent() == self.Entity or ent == self.Entity) then
			return self.Entity
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