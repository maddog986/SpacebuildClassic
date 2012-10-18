RS:AddDevice({
	tool = {"Climate"},
	category = "Terraformers",
	status = true,
	name = "Terraformer",
	desc = "Terraforms a planet over time.",
	model = {
		"models/props_combine/CombineThumper002.mdl",
		"models/props_combine/CombineThumper001a.mdl"
	},
	startsound = "ambient/alarms/citadel_alert_loop2.wav",
	--[[
	requires = {
		Air = function(self)
			local planet = self:GetPlanet()
			local inc = 1

			if (IsValid(planet)) then inc = inc * (planet:GetRadius()/100000) end

			return CONSUME(self) * inc
		end,
		Energy = function(self)
			local planet = self:GetPlanet()
			local inc = 1

			if (planet and planet.radius) then inc = inc * (planet:GetRadius()/20000) end

			return CONSUME(self) * inc
		end,
		Water = function(self)
			local planet = self:GetPlanet()
			local inc = 1

			if (planet and planet.radius) then inc = inc * (planet:GetRadius()/100000) end

			return CONSUME(self) * inc
		end
	},]]
	BaseClass = {
		Think = function(self)
			self.BaseClass.Think(self)

			--if (self:IsActive()) then
			TheraformerThink(self)
			--end

			self:NextThink(CurTime() + 1)
			return true
		end
	}
});

function TheraformerThink(ent)
	local planet = ent:GetPlanet()

	if !IsValid(planet) then
		self:TurnOff() --no planet
	return end

	local oxygen = planet:GetOxygen()
	local gravity = planet:GetGravity()
	local pressure = planet:GetPressure()
	local atmosphere = planet:GetAtmosphere()
	local hightemperature = planet:GetHighTemperature()
	local lowtemperature = planet:GetLowTemperature()
	--unstable
	--sunburn


end