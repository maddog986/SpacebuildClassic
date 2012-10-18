-- air compressors
RS:AddDevice({
	tool = {"Generator"},
	category = "Air",
	status = true,
	name = "Air Compressor",
	desc = "Compresses Air for Air Storage",
	startsound = "vehicles/Crane/crane_extend_loop1.wav",
	stopsound = "vehicles/Crane/crane_extend_stop.wav",
	model = {
		"models/props_wasteland/laundry_washer003.mdl",		--large air compressor
		"models/Gibs/airboat_broken_engine.mdl",			--small air compressor
		"models/props_farm/air_intake.mdl",					--medium air compressor
		"models/props_vehicles/generatortrailer01.mdl",
		"models/SBEP_community/d12airscrubber.mdl",
		"models/Slyfo_2/acc_oxygenpaste.mdl"
	},
	resources = {
		Air = function(self)
			--maddogs_spacebuild support
			if (self.EnvironmentValues && self.EnvironmentValues.oxygen) then
				if (self.EnvironmentValues.oxygen <= 0) then --no oxygen so don't produce oxygen and turn off
					if (self:IsActive()) then self:TurnOff() end
					return 0
				end
			end

			return GENERATE(self)
		end
	},
	requires = {
		Energy = CONSUME
	}
})