--storage
RS:AddDevice({
	tool = {"Storage"},
	category = "Hydrogen",
	name = "Hydrogen Storage",
	desc = "Holds Hydrogen",
	model = {
		"models/props_wasteland/horizontalcoolingtank04.mdl",	--large tank
		"models/props_junk/PropaneCanister001a.mdl"	--small propane tank
	},
	storage = {
		Hydrogen = STORAGE
	}
})