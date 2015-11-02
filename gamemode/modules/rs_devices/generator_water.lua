--water generator (small hand pump)
RS:AddDevice({
	name = "Water Pump",
	desc = "Pumps water. Must be at least 2/3 under water to work.",
	model = {
		"models/water_pump.mdl",
		"models/props_wasteland/buoy01.mdl",
		"models/props_2fort/waterpump001.mdl"
	},
	requires_name = {"Energy","Atmosphere"},
	resources = {
		Water = function(self)
			return GENERATE(self) * 2
		end
	},
	requires = {
		Energy = CONSUME
	},
	tool = {"Generator"},
	category = "Water",
	status = true,
	BaseClass = {
		Think = function(self)
			self.BaseClass.Think(self)

			--if active and not under water turn off
			if (self:IsActive() && self:WaterLevel() < 2) then self:TurnOff() end
		end
	}
})