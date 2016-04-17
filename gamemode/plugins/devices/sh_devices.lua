--[[
	Author MadDog
]]

local RS = GM:GetPlugin("Resources")
if ( !RS ) then return end

ENT = {
	PrintName = "Small Lamp",
	Information = "Creates a small amount of light using Energy.",
	Model = "models/props_combine/CombineThumper002.mdl",
	UseType = USE_TOGGLE,
	CheckRequirements = DEVICES.ENERGY.REQUIREMENTS,
	Resources = {
		Energy = DEVICES.GENERATE.BASE_VOLUME
	},
	TurnOn = function( self )
		self.BaseClass.TurnOn( self )

		local light = ents.Create("env_projectedtexture")
        light:SetParent( self )
        light:SetLocalPos( vector_origin )
        light:SetLocalAngles( Angle(90, 90, 90) )
        light:SetKeyValue( "enableshadows", 0 )
        light:SetKeyValue( "farz", 2048 )
        light:SetKeyValue( "nearz", 8 )
        light:SetKeyValue( "lightfov", 50 ) --the size of the light
        light:SetKeyValue( "lightcolor", "255 255 255" ) 
        light:Spawn()
        light:Input( "SpotlightTexture", NULL, NULL, "effects/flashlight001" )

		self.light = light
	end,
	TurnOff = function( self )
		self.BaseClass.TurnOff( self )

		SafeRemoveEntity( self.light )
	end
}