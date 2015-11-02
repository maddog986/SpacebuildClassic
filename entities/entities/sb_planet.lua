--[[
	Author: MadDog (steam id md-maddog)
]]
AddCSLuaFile()

DEFINE_BASECLASS( "base_environment" )

ENT.PrintName = "SB Planet"
ENT.Author	= "MadDog"
ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:SetupDataTables()
	self:NetworkVar( "Bool", 0, "Raining" )
	self:NetworkVar( "Bool", 1, "Snowing" )

	self:NetworkVar( "Int", 0, "Radius" )

	if SERVER then
		self:NetworkVarNotify( "Radius", self.RadiusChanged )
	end

	self:NetworkVar( "String", 0, "EnvironmentName" )

	--custom colors
	self:NetworkVar( "Vector", 0, "ColorMul" )
	self:NetworkVar( "Vector", 1, "ColorAdd" )
	self:NetworkVar( "Float", 1, "ColorContrast" )
	self:NetworkVar( "Float", 2, "ColorColor" )
	self:NetworkVar( "Float", 3, "ColorBrightness" )

	--blooms
	self:NetworkVar( "Float", 4, "BloomDarken" )
	self:NetworkVar( "Float", 5, "BloomMultiply" )
	self:NetworkVar( "Float", 6, "BloomSizeX" )
	self:NetworkVar( "Float", 7, "BloomSizeY" )
	self:NetworkVar( "Float", 8, "BloomPasses" )
	self:NetworkVar( "Vector", 3, "BloomColor" )
	self:NetworkVar( "Float", 9, "BloomColorMul" )
end

function ENT:GetGravityRadius() return self:GetRadius() * 1.5 end
function ENT:IsPlanet() return true end

if (CLIENT) then return end

function ENT:RadiusChanged( name, old, value )
	if (name ~= "Radius") then return end

	self:PhysicsInitSphere( value )
	self:SetCollisionBounds( -Vector(value, value, value), Vector(value, value, value) )
end

function ENT:SetEnvironment( data )
	BaseClass.SetEnvironment( self, data )

	self:SetEnvironmentName( data.name or "device" )

	--lets "fix" some planets to increase gameplay
	if (self.environment.name == "Endgame") then
		self.environment.unstable = 1
		self.environment.atmosphere = 0
	elseif (self.environment.name == "Cerebus") then
		self.environment.trees = 1
	elseif (self.environment.name == "Kobol") then
		self.environment.lowtemperature = 200
		self.environment.hightemperature = 200
		self.environment.gravity = 0.8
		self.environment.atmosphere = 2

		self:SetSnowing( (self.environment.hightemperature < 273.150) )
		self:SetRaining( (self.environment.hightemperature > 273.150) )
	elseif (self.environment.name == "Coruscant") then
		self:SetRaining( true )
	end

	--save custom color
	if data.color then
		self:SetColorMul( data.color.mulcol )
		self:SetColorAdd( data.color.addcol )
		self:SetColorContrast( data.color.contrast )
		self:SetColorColor( data.color.color )
		self:SetColorBrightness( data.color.brightness )
	end

	--save custom bloom
	if data.bloom then
		self:SetBloomDarken( data.bloom.darken )
		self:SetBloomMultiply( data.bloom.multiply )
		self:SetBloomSizeX( data.bloom.x )
		self:SetBloomSizeY( data.bloom.y )
		self:SetBloomPasses( data.bloom.passes )
		self:SetBloomColor( data.bloom.color )
		self:SetBloomColorMul( data.bloom.colormul )
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end







--TODO: finish terraform stuff
function ENT:TerraForm( name, amount )
	if (!self.default_environment[name]) then return end --planet doesnt have this type for some reason so exit

	self.environment[name] = math.Approach( self.environment[name], self.livable_environment[name], amount )
end

function ENT:TerraFormFinished()
	self.TerraFormFinished = true

	for _, ent in pairs(ents.FindInSphere( self:GetPos(), self:GetRadius())) do
		if (ent:GetClass() == "func_dustcloud" or ent:GetClass() == "env_smokestack") then
			ent:Input("TurnOff")
		end
	end
end

function ENT:TerraFormFullReset()
	self.TerraFormFinished = false

	self.environment = table.Copy(self.default_environment)

	for _, ent in pairs(ents.FindInSphere( self:GetPos(), self:GetRadius())) do
		if (ent:GetClass() == "func_dustcloud" or ent:GetClass() == "env_smokestack") then
			ent:Fire("TurnOn")
		end
	end
end