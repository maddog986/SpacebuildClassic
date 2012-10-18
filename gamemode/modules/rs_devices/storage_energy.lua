--energy storage
RS:AddDevice({
	tool = {"Storage"},
	category = "Energy",
	name = "Energy Storage",
	desc = "Holds Energy",
	model = {
		"models/props_c17/substation_stripebox01a.mdl",	--large energy cell
		"models/Items/car_battery01.mdl", --small car battery
		"models/Slyfo/crate_battery.mdl"
	},
	storage = {
		Energy = STORAGE
	},
	BaseClass = {
		OnTakeDamage = TAKEDAMAGE
	}
});