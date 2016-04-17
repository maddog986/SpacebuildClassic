--[[
	Author MadDog
]]

local RS = GM:GetPlugin("Resources")
if ( !RS ) then return end

--COOLANT STORAGE
ENT = {
	PrintName = "Coolant Storage",
	Information = "Holds small amounts of Coolant.",
	Model = "models/props_badlands/barrel01.mdl",
	CustomModelScale = 0.6,
	Storage = {
			Coolant = DEVICES.STORAGE.BASE_VOLUME
	}
}

RS:AddDevice( "coolant_storage", ENT )

--COOLANT GENERATOR
ENT = {
	PrintName = "Coolant Generator",
	Information = "Generates small amounts of Coolant from Water.",
	Model = "models/lt_c/sci_fi/generator_portable.mdl",
	Resources = {
		Coolant = DEVICES.GENERATE.COOLANT
	}
}

RS:AddDevice( "coolant_generator", ENT )