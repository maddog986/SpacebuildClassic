-- air compressors
RS:AddDevice({
	tool = {"Generator"},
	category = "Air",
	status = true,
	name = "Air Compressor",
	desc = "Generates Compressed Air into Air Storage container.",
	startsound = "vehicles/Crane/crane_extend_loop1.wav",
	stopsound = "vehicles/Crane/crane_extend_stop.wav",
	model = {
		"models/air_compressor.mdl",
		"models/props_wasteland/laundry_washer003.mdl",		--large air compressor
		"models/Gibs/airboat_broken_engine.mdl",			--small air compressor
		"models/props_farm/air_intake.mdl",					--medium air compressor
		"models/props_vehicles/generatortrailer01.mdl",
		"models/SBEP_community/d12airscrubber.mdl",
		"models/Slyfo_2/acc_oxygenpaste.mdl"
	},
	requires_name = {"Oxygen"},
	resources = {
		Air = function(self)
			--maddogs_spacebuild support
			if (self.GetOxygen and self:GetOxygen() <= 0) then --no oxygen so don't produce oxygen
				return 0
			end

			return GENERATE(self) * (self:GetOxygen() / 100) --only produce at oxygen level
		end
	},
	requires = {
		Energy = CONSUME
	}
})