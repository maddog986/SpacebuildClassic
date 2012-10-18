RS:AddDevice({
	tool = {"Tools"},
	category = "Suit Chargers",
	status = false,
	name = "Suit Charger",
	desc = "Restore your suit.",
	startsound = "Buttons.snd17",
	stopsound = "Buttons.snd17",
	model = {
		"models/props_combine/health_charger001.mdl",
		"models/props_combine/suit_charger001.mdl"
	},
	requires = {
		Energy = CONSUME
	},
	BaseClass = {
		AcceptInput = function(self, name, activator, ply)
			if (name == "Use") && (ply:IsPlayer()) && (ply:KeyDownLast(IN_USE) == false) then
				DoSuitCharge( ply )
			end
		end
	}
})

function DoSuitCharge( ply )
	ply.Suit = 120

	ply:EmitSound("player/recharged.wav")

	data.Send("MDSB.ShowHud", {true, 120}, "nocache", ply)
end