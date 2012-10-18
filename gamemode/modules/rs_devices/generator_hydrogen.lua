--Hydrogen generators
RS:AddDevice({
	tool = {"Generator"},
	category = "Hydrogen",
	status = true,

	name = "Hydrogen Generator",
	desc = "Creates Hydrogen from Energy and Water",
	startsound = "vehicles/Crane/crane_extend_loop1.wav",
	stopsound = "vehicles/Crane/crane_extend_stop.wav",
	model = "models/props_c17/FurnitureBoiler001a.mdl",	--boiler
	resources = {
		Hydrogen = function(self)
			return GENERATE(self) / 6
		end
	},
	requires = {
		Energy = function(self)
			return CONSUME(self) * 3
		end,
		Water = function(self)
			return CONSUME(self) * 3
		end
	}
})