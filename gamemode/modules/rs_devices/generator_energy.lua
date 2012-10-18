--fusion generator
RS:AddDevice({
	tool = {"Generator"},
	category = "Energy - Fusion",
	status = true,
	name = "Fusion Energy Generator",
	desc = "Generates Energy. Needs coolant to keep running.\nProvide Hydrogen for big boost.",
	startsound = {"k_lab.ambient_powergenerators","ambient/machines/thumper_startup1.wav"},
	stopsound = "vehicles/APC/apc_shutdown.wav",
	model = {
		"models/props_c17/substation_circuitbreaker01a.mdl",
		"models/combine_dropship_container_static.mdl",
		"models/Combine_Helicopter/helicopter_bomb01.mdl",
		"models/roller.mdl",
		"models/Slyfo/electrolysis_gen.mdl",
		"models/Slyfo_2/miscequipmentfieldgen.mdl",
		"models/SmallBridge/Life Support/sbfusiongen.mdl",
		"models/Cerus/Modbridge/Misc/LS/ls_gen11a.mdl",
		"models/SBEP_community/d12shieldemitter.mdl",
		"models/SBEP_community/d12siesmiccharge.mdl",
		"models/MarkJaw/gate_buster.mdl",
		"models/naquada-reactor.mdl"
	},
	resources = {
		Energy = GENERATE
	},
	BaseClass = {
		Think = function(self)
			self.BaseClass.Think(self)

			--must be active
			if (self:IsActive()) then DoFusionThink( self ) end

			self.Entity:NextThink(CurTime() + 1)
			return true
		end
	}
})





--energy generator (v8 engine)
RS:AddDevice({
	tool = {"Generator"},
	category = "Energy - Petrol",
	status = true,
	name = "Small Energy Generator",
	desc = "Generates Energy",
	startsound = "vehicles/v8/v8_start_loop1.wav",
	stopsound = "vehicles/v8/v8_stop1.wav",
	model = "models/vehicle/vehicle_engine_block.mdl",
	resources = {
		Energy = GENERATE
	},
	requires = {
		Petrol = CONSUME
	}
})

--energy generator (air boat engine)
RS:AddDevice({
	tool = {"Generator"},
	category = "Energy - Petrol",
	status = true,
	name = "Small Energy Generator",
	desc = "Generates Energy",
	startsound = "vehicles/Airboat/fan_motor_start1.wav",
	stopsound = "vehicles/Airboat/fan_motor_shut_off1.wav",
	model = "models/props_c17/TrapPropeller_Engine.mdl",
	resources = {
		Energy = GENERATE
	},
	requires = {
		Petrol = CONSUME
	}
})

--energy generator (larger trailer generator)
RS:AddDevice({
	tool = {"Generator"},
	category = "Energy - Petrol",
	status = true,
	name = "Small Energy Generator",
	desc = "Generates Energy",
	startsound = "vehicles/v8/v8_firstgear_rev_loop1.wav",
	stopsound = "vehicles/v8/v8_stop1.wav",
	model = {
		"models/props_mining/diesel_generator.mdl",
		"models/props_c17/TrapPropeller_Engine.mdl"
	},
	resources = {
		Energy = GENERATE
	},
	requires = {
		Petrol = CONSUME
	}
})

--energy generator (solar panel)
RS:AddDevice({
	tool = {"Generator"},
	category = "Energy - Solar",
	name = "Solar Power",
	desc = "Generates Energy from direct Sunlight",
	model = {
		"models/props_trainstation/traincar_rack001.mdl",
		"models/props_combine/combine_explosivepanel_ceiling02a_shard01.mdl",
		"models/props_lab/lockerdoorsingle.mdl",
		"models/props_outland/basementdoor01a.mdl",
		"models/Slyfo/door1blocker.mdl",
		"models/Slyfo/fhatch.mdl",
		"models/Slyfo/frigate1ramp.mdl",
		"models/Slyfo_2/miscequipmentsolar.mdl",
		"models/Slyfo_2/miscequipmentradiodish.mdl",
		"models/madjawa/laser_reflector.mdl",
		"models/Spacebuild/medbridge2_large_solar_sail.mdl",
		"models/Slyfo_2/acc_sci_spaneltanks.mdl"
	},
	resources = {
		Energy = function( self )
			return GENERATE(self) / 10
		end
	},
	BaseClass = {
		Think = function(self)
			if !SERVER then return end

			DoSolar( self )
		end
	}
})



--energy generator (wind)
RS:AddDevice({
	tool = {"Generator"},
	category = "Energy - Wind",
	status = true,
	name = "Wind Power",
	desc = "Generates Energy from wind.",
	model = "models/props_trainstation/pole_448Connection001a.mdl",
	resources = {
		Energy = function( self )
			return GENERATE(self)
		end
	},
	BaseClass = {
		Think = function(self)
			if !SERVER then return end

			self.BaseClass.Think(self)

			DoWind( self )
		end
	}
})





function DoFusionThink( self )
	local generateAmount = GENERATE( self ) --get base generate amount
	local consumeAmount = CONSUME( self ) * 0.1 --how much to consume
	local stored = RS:Stored( self ) --how much resources are stored up

	--big boost from Hydrogen
	if (stored.Hydrogen && stored.Hydrogen > consumeAmount) then
		RS:Commit( self, { Hydrogen = -consumeAmount * 5 } )

		generateAmount = generateAmount + consumeAmount * 1.5
	end

	--if no coolant, cause damage
	if (!stored.Coolant or stored.Coolant < consumeAmount) then
		self:TakeDamage( math.random(5, 15), self, self ) --kill life

		self:MakeSmoke()

		self:EnergySparks( self:GetPos(), math.random(100, 200) )

		self.Entity:EmitSound( "common/warning.wav" )
	else
		RS:Commit( self, { Coolant = -consumeAmount } )

		generateAmount = generateAmount --give energy boost
	end
end

function DoSolar( self )
	local outdoors = self.sunlight

	if (!self.sunlight) then
		-- Return result
		self.sunlight = self:IsSkyAbove( )
	end

	if (self.sunlight) then
		self:TurnOn()
	elseif (!self.sunlight) then
		self:TurnOff()
	end

	if self:IsActive() then
		self.Entity:SetColor( Color(10, 96, 255, 255) ) --light up when on
	else
		self.Entity:SetColor( Color(10, 96, 140, 255) ) --dark when off
	end
end

function DoWind( self )
	if (self:IsActive() && self.LEnvironments && !self.LEnvironments.Planet) then
		self:TurnOff()
	elseif (!self:IsActive() && self.LEnvironments && self.LEnvironments.Planet) then
		self:TurnOn()
	elseif (!self:IsActive() && !self.LEnvironments) then
		self:TurnOn()
	end
end
