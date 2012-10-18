--coolant generator
RS:AddDevice({
	name = "Coolant Generater",
	desc = "Creates coolant.",
	model = {
		"models/Gibs/airboat_broken_engine.mdl",
		"models/Slyfo_2/acc_sci_coolerator.mdl"
	},
	startsound = "vehicles/Airboat/fan_motor_start1.wav",
	stopsound = "vehicles/Airboat/fan_motor_shut_off1.wav",
	resources = {
		Coolant = function( self )
			return GENERATE(self) * 2
		end
	},
	requires = {
		Energy = CONSUME--,
		--Water = CONSUME
	},
	tool = {"Generator"},
	category = "Coolant",
	status = true
})