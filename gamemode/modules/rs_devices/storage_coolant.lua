--add coolant storage
RS:AddDevice({
	tool = {"Storage"},
	category = "Coolant",

	name = "Coolant Storage",
	desc = "Holds Coolant",
	model = {
		"models/bluebarrel001.mdl"
	},
	storage = {
		Coolant = STORAGE
	}
})
