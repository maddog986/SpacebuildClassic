--[[
	Author MadDog
]]

local RS = GM:GetPlugin("Resources")
if ( !RS ) then return end

--CLIMATE PROVIDER
ENT = {
	PrintName = "Climate Provider",
	Information = "Creates an artificial environment to survive.",
	Model = "models/props_combine/CombineThumper002.mdl",
	CustomModelScale = 0.5,
	UseType = USE_TOGGLE,
	CheckRequirements = DEVICES.CLIMATE.REQUIREMENTS,
	Resources = {
		Energy = DEVICES.CLIMATE_.CONSUME_ENERGY,
		Oxygen = DEVICES.CLIMATE.CONSUME_OXYGEN
	},
	Environment = {
		Gravity = DEVICES.CLIMATE.PROVIDE_GRAVITY,
		Pressure = DEVICES.CLIMATE.PROVIDE_PRESSURE,
		Oxygen = DEVICES.CLIMATE.PROVIDE_OXYGEN,
		Atmosphere = DEVICES.CLIMATE.PROVIDE_ATMOSPHERE,
		LowTemperature = DEVICES.CLIMATE.PROVIDE_TEMPERATURE,
		HighTemperature = DEVICES.CLIMATE.PROVIDE_TEMPERATURE,
		Active = DEVICES.ISACTIVE,
		Size = DEVICES.CLIMATE.PROVIDE_SIZE
	}
}

RS:AddDevice( "climate_regulator", ENT )