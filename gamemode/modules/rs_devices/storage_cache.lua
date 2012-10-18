--black hole cheat
RS:AddDevice({
	tool = {"Storage"},
	category = "Cache",
	name = "Resource Cache",
	desc = "Holds all resources possible!",
	model = {
		"models/props_c17/substation_transformer01a.mdl",
		"models/props_lab/powerbox01a.mdl",
		"models/props/CS_militia/silo_01.mdl",
		"models/Slyfo/crate_resource_large.mdl",
		"models/Slyfo/crate_resource_small.mdl",
		"models/Slyfo/sat_resourcetank.mdl",
		"models/SmallBridge/Life Support/sbhullcache.mdl",
		"models/SmallBridge/Life Support/sbwallcachee.mdl",
		"models/SmallBridge/Life Support/sbwallcachel.mdl",
		"models/SmallBridge/Life Support/sbwallcachel05.mdl",
		"models/SmallBridge/Life Support/sbwallcaches.mdl",
		"models/SmallBridge/Life Support/sbwallcaches05.mdl"
	},
	storage = function( self )
		return CacheResources(self)
	end,
	BaseClass = {
		OnTakeDamage = TAKEDAMAGE
	}
});

RS:AddDevice({
	tool = {"Other"},
	category = "(Cheats) Cache",
	status = false,

	name = "(Cheat) Cache Storage",
	desc = "Holds and Generatores all resources!",
	model = {
		"models/props_borealis/bluebarrel001.mdl",
		"models/props_junk/PopCan01a.mdl",
		"models/props_lab/powerbox01a.mdl"
	},
	storage = function(self)
		return CacheResources(self)
	end,
	resources = function(self)
		return CacheResources(self)
	end,
	stored = function(self)
		return CacheResources(self)
	end,
	BaseClass = {
		Think = function(self)
			self.BaseClass.Think(self)

			--always on
			self:TurnOn()
		end
	}
});


function CacheResources( self )
	local resources = {}

	for _, name in pairs(RS.Resources or {}) do
		resources[name] = math.ceil(STORAGE(self)/ #RS.Resources)
	end

	table.sort(resources)

	return resources
end

