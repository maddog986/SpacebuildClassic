--add climate regulators
RS:AddDevice({
	tool = {"Climate"},
	category = "Climate Regulators",
	status = true,
	name = "Climate Regulator",
	base = "base_sb_environment",
	desc = "Provides climate control to make friendly climate.",
	startsound = "vehicles/APC/apc_start_loop3.wav",
	stopsound = "vehicles/APC/apc_shutdown.wav",
	model = {
		"models/props_combine/combine_generator01.mdl",
		"models/props/combine_ball_launcher.mdl",
		"models/SmallBridge/Life Support/sbclimatereg.mdl"
	},
	radius = 1024,
	requires = {
		Energy = function(self)
			return CONSUME(self) / 2
		end
	},
	BaseClass = {
		Think = function(self)
			self.BaseClass.Think(self)

			--if (self:IsActive()) then
			ClimateThink(self)
			--end

			self:NextThink(CurTime() + 1)
			return true
		end
	}
})

--TODO: Finish
function ClimateThink( self )
	self.radius = 1024

	local atmosphere  = GetEnvironmentNormal( self, "atmosphere", 1 )
end

--add plants
RS:AddDevice({
	tool = {"Climate"},
	category = "Plants",

	name = "Plant",
	desc = "Provides a little bit of oxygen in a airless environment.",
	model = {
		"models/props/cs_office/plant01.mdl",
		"models/props/cs_office/plant01_p1.mdl",
		"models/props/de_inferno/potted_plant1.mdl",
		"models/props/de_inferno/potted_plant3_p1.mdl",
		"models/props_foliage/potted_plant3.mdl",
		"models/props/de_inferno/tree_small.mdl",
		"models/props/de_inferno/tree_large.mdl"
	},
	BaseClass = {
		Think = function(self)
			self.BaseClass.Think(self)

			DoPlant( self )

			self.Entity:NextThink(CurTime() + 1)
			return true
		end
	}
})

--add climate regulators
RS:AddDevice({
	tool = {"Climate"},
	category = "Oxygen",
	status = true,
	name = "Oxygen Regulator",
	desc = "Provides oxygen so you can breath.",
	startsound = "vehicles/APC/apc_start_loop3.wav",
	stopsound = "vehicles/APC/apc_shutdown.wav",
	model = {
		"models/props/cs_assault/ACUnit02.mdl",
		"models/props/cs_assault/ACUnit01.mdl"
	},
	requires = {
		Energy = CONSUME,
		Air = CONSUME
	},
	BaseClass = {
		Environment = {
			radius = RADIUS,
			oxygen = function(self)
				return GetEnvironmentNormal( self, "oxygen", 100 )
			end
		}
	}
})

RS:AddDevice({
	tool = {"Climate"},
	category = "Atmosphere",
	status = true,
	name = "Atmosphere Regulator",
	desc = "Provides an Atmosphere and normal Gravity.",
	startsound = "vehicles/APC/apc_start_loop3.wav",
	stopsound = "vehicles/APC/apc_shutdown.wav",
	model = {
		"models/magnusson_device.mdl"
	},
	requires = {
		Energy = CONSUME
	},
	BaseClass = {
		Environment = {
			radius = function(self)
				return Teraform( self )
			end,
			atmosphere = function(self)
				return GetEnvironmentNormal( self, "atmosphere", 1 )
			end,
			gravity = function(self)
				return GetEnvironmentNormal( self, "gravity", 1 )
			end
		}
	}
})

--add heaters
RS:AddDevice({
	tool = {"Climate"},
	category = "Heaters",
	status = true,

	name = "Heater & Chiller",
	desc = "Smothes out Hot and Cold environments. Heat also helps plants live longer.",
	startsound = "vehicles/APC/apc_start_loop3.wav",
	stopsound = "vehicles/APC/apc_shutdown.wav",
	model = {
		"models/props_wasteland/prison_heater001a.mdl",
		"models/props_forest/sawmill_boiler.mdl",
		"models/props_combine/combine_light001a.mdl",
		"models/props_combine/combine_light001b.mdl",
		"models/props_combine/combine_light002a.mdl"
	},
	requires = {
		Energy = CONSUME
	},
	BaseClass = {
		Environment = {
			radius = RADIUS,
			lowtemperature = function(self)
				return GetEnvironmentNormal( self, "lowTemperature", 295.777 )
			end,
			hightemperature = function(self)
				return GetEnvironmentNormal( self, "lowTemperature", 295.777 )
			end
		}
	}
})

RS:AddDevice({
	tool = {"Climate"},
	category = "Heaters - Wood",
	status = true,
	name = "Wood Heater",
	desc = "Burns wood to provide heat.",
	startsound = "vehicles/APC/apc_start_loop3.wav",
	stopsound = "vehicles/APC/apc_shutdown.wav",
	model = {
		"models/props_c17/FurnitureFireplace001a.mdl",
		"models/props_furniture/fireplace1.mdl",
		"models/props_furniture/fireplace2.mdl"
	},
	requires = {
		Wood = CONSUME
	},
	BaseClass = {
		Environment = {
			radius = function(self)
				return (self:GetDistanceAmount() * 500) --lots of heat
			end,
			lowTemperature = function(self)
				return GetEnvironmentNormal( self, "lowTemperature", 295.777 )
			end,
			highTemperature = function(self)
				return GetEnvironmentNormal( self, "lowTemperature", 295.777 )
			end
		}
	}
})








function Teraform( self )
	if !IsValid(self) then return end

	if (!self.Environments) then return 10000 end

	for _idx, ent in pairs(self.Environments.Ents or {}) do
		if (ent.planet == 1) then
			--make sure environment is started from same point of the planent
			self.OtherPos = ent:GetPos()

			return ent.Environment.radius
		end
	end

	return 10000
end


function DoPlant( self )
	if !IsValid(self) then return end

	--kill life
	if (math.random(1, 10) < 6) then
		RS.SetHealthInc(self, -1)
	end
end





function GetEnvironmentNormal( ent, name, target )
	if !IsValid(ent) then return end

	local values, valuesIn = {}, {}

	--dont provide gravity in space... duh
	if (name == "gravity" && ent.Environments && !ent.Environments.Planet) then return 0 end

	for _, _environment in pairs(ent:GetEnvironments()) do
		if _environment == ent then continue; end --dont compare to self

		--get environment from temp entity
		local Environment = _environment:GetEnvironment() --entites use ent.Environment, planets dont

		if (!Environment or !Environment[name]) then continue; end --not what we need

		local val = Environment[name]

		values[name] = (values[name] or 0) + val
		valuesIn[name] = (valuesIn[name] or 0) + 1
	end

	if (valuesIn[name]) then values[name] = (values[name] / valuesIn[name]) end

	if (!values[name]) then
		return target
	else
		return (target - values[name]) + target
	end
end

function GetEnvironmentAvg( ent, name, target )
	if !IsValid(ent) then return end

	local values, valuesIn = {}, {}

	--dont provide gravity in space... duh
	if (name == "gravity" && ent.Environments && !ent.Environments.Planet) then return 0 end

	for _, _environment in pairs(ent.Environments.Ents) do
		if _environment == ent then continue; end --dont compare to self

		--get environment from temp entity
		local Environment = MDSB.CheckValue(_environment, _environment.Environment or _environment) --entites use ent.Environment, planets dont

		if (!Environment or !Environment[name]) then continue; end --not what we need

		local val = MDSB.CheckValue( _environment, Environment[name] )

		if (val != 0) then
			values[name] = (values[name] or 0) + val
			valuesIn[name] = (valuesIn[name] or 0) + 1
		end
	end

	values[name] = (values[name] or 0) + target
	valuesIn[name] = (valuesIn[name] or 0) + 1

	values[name] = (values[name] / valuesIn[name])

	return values[name]
end
