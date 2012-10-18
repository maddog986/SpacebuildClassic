--add petrol pump
RS:AddDevice({
	tool = {"Generator"},
	category = "Petrol",
	status = true,

	name = "Petrol Pump",
	desc = "Creates Petrol",
	model = {
		"models/props_wasteland/gaspump001a.mdl"
	},
	resources = {
		Petrol = function(self)
			return GENERATE(self) / 10
		end,
	},
	requires = {
		Energy = CONSUME,
		Oil = CONSUME
	}
})