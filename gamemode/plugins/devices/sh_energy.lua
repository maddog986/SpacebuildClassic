--[[
	Author MadDog
]]

local RS = GM:GetPlugin("Resources")
if ( !RS ) then return end

local function EnergySparks( pos, magnitude )
	local mag = magnitude or 10
	local ent = ents.Create("point_tesla")
	ent:SetKeyValue("targetname", "teslab")
	ent:SetKeyValue("m_SoundName" ,"DoSpark")
	ent:SetKeyValue("texture" ,"sprites/physbeam.spr")
	ent:SetKeyValue("m_Color" ,"200 200 255")
	ent:SetKeyValue("m_flRadius" ,tostring(mag*80))
	ent:SetKeyValue("beamcount_min" ,tostring(math.ceil(mag)+4))
	ent:SetKeyValue("beamcount_max", tostring(math.ceil(mag)+12))
	ent:SetKeyValue("thick_min", tostring(mag))
	ent:SetKeyValue("thick_max", tostring(mag*8))
	ent:SetKeyValue("lifetime_min" ,"0.1")
	ent:SetKeyValue("lifetime_max", "0.2")
	ent:SetKeyValue("interval_min", "0.05")
	ent:SetKeyValue("interval_max" ,"0.08")
	ent:SetPos( pos )
	ent:Spawn()
	ent:Fire("DoSpark","",0)
	ent:Fire("kill","", 1)
end

--ENERGY STORAGE
RS:AddDevice( "energy_storage", {
	PrintName = "Energy Storage",
	Information = "Holds small amounts of Energy.",
	Model = "models/lt_c/sci_fi/dm_container.mdl",
	Storage = {
		Energy = DEVICES.STORAGE.BASE_VOLUME
	},
	OnTakeDamage = function( self, dmg )
		RS:Commit( self, "Energy", -math.random(dmg:GetDamage() * 0.5, dmg:GetDamage()))

		EnergySparks( dmg:GetDamagePosition(), dmg:GetDamage() * 0.1 )
	end
})

--ENERGY GENERATOR
RS:AddDevice( "energy_generator", {
	PrintName = "Energy Generator",
	Information = "Generates small amounts of Energy.",
	Model = "models/lt_c/sci_fi/generator_portable.mdl",
	OnSound = "vehicles/tank_turret_loop1.wav",
	UseType = USE_TOGGLE,
	Resources = {
		Energy = DEVICES.GENERATE.BASE_VOLUME
	}
})

--ENERGY HYDRO
RS:AddDevice( "energy_hydro_generator", {
	PrintName = "Hydro Energy Generator",
	Information = "Generates small amounts of Energy from direct water sources.",
	Model = "models/lt_c/sci_fi/generator_portable.mdl",
	OnSound = "vehicles/tank_turret_loop1.wav",
	Resources = {
		Energy = DEVICES.GENERATE.HYDRO
	}
})

--ENERGY FUSION REACTOR
RS:AddDevice( "energy_fusion_generator", {
	PrintName = "Energy Fusion Generator",
	Information = "Generates large amounts of Energy using Coolant.",
	Model = "models/lt_c/sci_fi/generator_portable.mdl",
	OnSound = "vehicles/tank_turret_loop1.wav",
	UseType = USE_TOGGLE,
	Resources = {
		Energy = DEVICES.GENERATE.FUSION
	}
})

--ENERGY SOLAR GENERATOR
RS:AddDevice( "energy_solar_generator", {
	PrintName = "Solar Panel",
	Information = "Generates small amounts of Energy when on planet surfaces.",
	Model = "models/devices/solar_panel.mdl",
	Resources = {
		Energy = DEVICES.GENERATE.SOLAR
	}
})