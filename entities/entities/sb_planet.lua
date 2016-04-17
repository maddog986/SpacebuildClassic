--[[
	Author: MadDog (steam id md-maddog)
]]

AddCSLuaFile()

DEFINE_BASECLASS( "sb_brush_environment" )

ENT.PrintName = "SB Planet"
ENT.Author	= "MadDog"
ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:SetupDataTables()
	self:NetworkVar( "Int", 0, "Size" )

	if SERVER then
		self:NetworkVarNotify( "Size", self.SizeChanged )
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

function ENT:GetGravitySize() return self:GetSize() * 1.5 end
function ENT:IsPlanet() return true end

if (CLIENT) then return end

function ENT:SizeChanged( name, old, size )
	if (name ~= "Size") then return end

	BaseClass.SetSize( self, size )
end

function ENT:SetEnvironment( data )
	BaseClass.SetEnvironment( self, data )

	self.default_environment = self.default_environment or data

	self:SetEnvironmentName( data.name or "Unknown" )

	--lets "fix" some planets to increase gameplay
	if (self.environment.name == "Endgame") then
		self.environment.unstable = true
		self.environment.atmosphere = 2
		self.environment.pressure = 2 --dense
	elseif (self.environment.name == "Cerebus") then
		self.environment.trees = 1
	elseif (self.environment.name == "Kobol") then
		self.environment.lowtemperature = 200
		self.environment.hightemperature = 200
		self.environment.gravity = 0.8
		self.environment.atmosphere = 2
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

function ENT:IsSpawn()
	return self.environment.spawnPlanet
end

--TODO: find out why the planets randomly move... seemed tied to entities being removed or something
--this is really hacky and i hate it. something makes the planet move at some point, cant figure out what so this is here to stop that shit
function ENT:Think()
	if (self.default_environment.position) then self:SetPos( self.default_environment.position ) end
	self:NextThink( CurTime() + 1 )
	return true
end

function ENT:UpdateTransmitState() return TRANSMIT_ALWAYS end
function ENT:GetDefaultEnvironment() return self.default_environment or {} end



function ENT:IsStable()
	return !self.environment.unstable
end

function ENT:IsTerraFormed() --TODO: finish
	return false
end

--TODO: finish terraform stuff
function ENT:TerraForm( name, amount )
	if (!self.default_environment[name]) then return end --planet doesnt have this type for some reason so exit

	self.environment[name] = math.Approach( self.environment[name], ENVIRONMENTS:GetDefaultEnvironment()[name], amount )
end

function ENT:TerraFormFinished()
	self.TerraFormFinished = true

	for _, ent in pairs(ents.FindInSphere( self:GetPos(), self:GetSize())) do
		if (ent:GetClass() == "func_dustcloud" or ent:GetClass() == "env_smokestack") then
			ent:Input("TurnOff")
		end
	end
end

function ENT:TerraFormFullReset()
	self.TerraFormFinished = false

	self.environment = table.Copy(self.default_environment)

	for _, ent in pairs(ents.FindInSphere( self:GetPos(), self:GetSize())) do
		if (ent:GetClass() == "func_dustcloud" or ent:GetClass() == "env_smokestack") then
			ent:Fire("TurnOn")
		end
	end
end