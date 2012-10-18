--add water storage
RS:AddDevice({
	tool = {"Storage"},
	category = "Water",

	name = "Water Storage",
	desc = "Holds Water",
	model = {
		"models/props_junk/metalgascan.mdl",
		"models/props/water_bottle/water_bottle.mdl",
		"models/props_borealis/bluebarrel001.mdl",
		"models/props_c17/oildrum001.mdl",
		"models/props_wasteland/coolingtank02.mdl",
		"models/props_spytech/watercooler.mdl",
		"models/Slyfo/crate_watersmall.mdl"
	},
	storage = {
		Water = STORAGE
	}
})