AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( "shared.lua" )

if (!table.Compare) then
	function table.Compare( tbl1, tbl2 )
	    for k, v in pairs( tbl1 ) do
		if ( type(v) == "table" and type(tbl2[k]) == "table" ) then
		    if ( !table.Compare( v, tbl2[k] ) ) then return false end
		else
		    if ( v != tbl2[k] ) then return false end
		end
	    end
	    for k, v in pairs( tbl2 ) do
		if ( type(v) == "table" and type(tbl1[k]) == "table" ) then
		    if ( !table.Compare( v, tbl1[k] ) ) then return false end
		else
		    if ( v != tbl1[k] ) then return false end
		end
	    end
	    return true
	end
end

ENT.TerraFormFinished = false

function ENT:Initialize()
	self.BaseClass.Initialize(self)

	self:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_NONE )

	self:DrawShadow( false )
	self:PhysicsInitSphere( self.radius * 1.5 )

	self:SetColor( Color(255,255,0,0) ) --hide the model

	local phys = self:GetPhysicsObject()

	phys:EnableMotion( false )
	phys:Sleep()
end

function ENT:Think()
	self.BaseClass.Think(self)

	self:SetPos(self.environment.position) --always make sure it stays here incase some other addon trys to move it

	local terraformerfound = false

	for i, ent in pairs( self.Entities ) do
		if (ent.RS and ent.RS.name == "Terraformer") then
			terraformerfound = true
			break
		end
	end

	--TODO: make the rain and snow start and stop randomly for longer periods of time

	--lets "fix" some planets to increase gameplay
	if (self:GetName() == "Endgame") then
		self.environment.unstable = 1
		self.environment.atmosphere = 0
	elseif (self:GetName() == "Cerebus") then
		self.environment.trees = 1
	elseif (self:GetName() == "Kobol") then
		self.environment.lowtemperature = 200
		self.environment.hightemperature = 200
		self.environment.gravity = 0.8
		self.environment.atmosphere = 2

		self:SetNWBool("Snowing", (self.environment.hightemperature < 273.150))
		self:SetNWBool("Raining", (self.environment.hightemperature > 273.150))
	elseif (self:GetName() == "Coruscant") then
		self:SetNWBool("Raining", true)
	end

	if (terraformerfound) then
		if (self.environment.oxygen) then self.environment.oxygen = math.Approach(self.environment.oxygen, 100, 0.1) end
		if (self.environment.gravity) then self.environment.gravity = math.Approach(self.environment.gravity, 1, 0.001) end
		if (self.environment.pressure) then self.environment.pressure = math.Approach(self.environment.pressure, 1, 0.01) end
		if (self.environment.atmosphere) then self.environment.atmosphere = math.Approach(self.environment.atmosphere, 1, 0.01) end
		if (self.environment.hightemperature) then self.environment.hightemperature = math.Approach(self.environment.hightemperature, 299, 1) end
		if (self.environment.lowtemperature) then self.environment.lowtemperature = math.Approach(self.environment.lowtemperature, 299, 1) end
	else
		if (self.environment.oxygen) then self.environment.oxygen = math.Approach(self.environment.oxygen, self.default_environment.oxygen or 0, 0.1) end
		if (self.environment.gravity) then self.environment.gravity = math.Approach(self.environment.gravity, self.default_environment.gravity or 0, 0.001) end
		if (self.environment.pressure) then self.environment.pressure = math.Approach(self.environment.pressure, self.default_environment.pressure or 0, 0.01) end
		if (self.environment.atmosphere) then self.environment.atmosphere = math.Approach(self.environment.atmosphere, self.default_environment.atmosphere or 0, 0.01) end
		if (self.environment.hightemperature) then self.environment.hightemperature = math.Approach(self.environment.hightemperature, self.default_environment.hightemperature or 0, 1) end
		if (self.environment.lowtemperature) then self.environment.lowtemperature = math.Approach(self.environment.lowtemperature, self.default_environment.lowtemperature or 0, 1) end
	end

	--planet is terraformed
	if (table.Compare( self.default_environment, self.environment )) then
		if (!self.TerraFormFinished) then self:TerraFormFinished() end
	else
		if (self.TerraFormFinished) then self:TerraFormReset() end
	end
end

function ENT:TerraFormFinished()
	self.TerraFormFinished = true

	for _, ent in pairs(ents.FindInSphere( self:GetPos(), self:GetRadius())) do
		if (ent:GetClass() == "func_dustcloud" or ent:GetClass() == "env_smokestack") then
			ent:Input("TurnOff")
		end
	end
end

function ENT:TerraFormReset()
	self.TerraFormFinished = false

	for _, ent in pairs(ents.FindInSphere( self:GetPos(), self:GetRadius())) do
		if (ent:GetClass() == "func_dustcloud" or ent:GetClass() == "env_smokestack") then
			ent:Fire("TurnOn")
		end
	end
end
