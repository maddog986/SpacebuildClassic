--add petrol storage
RS:AddDevice({
	tool = {"Storage"},
	category = "Petrol",

	name = "Petrol Storage",
	desc = "Holds Petrol",
	model = {
		"models/props_junk/PropaneCanister001a.mdl",
		"models/props_junk/gascan001a.mdl",
		"models/props_c17/oildrum001_explosive.mdl",
		"models/props_industrial/oil_storage.mdl"
	},
	storage = {
		Petrol = STORAGE
	}
})