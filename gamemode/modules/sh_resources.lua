--[[

	Author: MadDog (steam id md-maddog)

	TODO:
		- Fix duping
		- Cleanup
]]

RS = {}
RS.Name = "Resources"
RS.Author = "MadDog"
RS.Version = 1
RS.Resources = {"Air","Coolant","Energy","Water"}
RS.Tools = {}


--[[
	SHARED FUNCTIONS
]]
function RS:GetNumber( ent, value, addition ) --if a value is a function, execute it and return it, else, return the value back
	if (type(value) == "function") then value = math.ceil(value(ent)) end --convert function into a value
	return math.ceil((addition or 0) + (value or 0))
end

function RS:GetTable( ent, tbl ) --returns a interger from interger or function
	if (!tbl) then return {} end
	if (type(tbl) == "function") then return tbl(ent) or {} end
	return tbl or {}
end

function RS:GetVolume( ent )
	return math.ceil(ent:OBBMaxs():Length())
end


--[[
tool header
	tool name
		devices
	tool name
		devices
	tool name
		devices
]]

RS._deviceid = 0

function RS:AddDevice( device )
	if (!device) then return end
	if (type(device.model) == "table") then for _, tmodel in pairs( device.model ) do RS:AddDevice( table.Merge( table.Copy(device), {model = tmodel}) ) end return end
	if (type(device.tool) == "table") then for _, ttool in pairs( device.tool ) do RS:AddDevice( table.Merge( table.Copy(device), {tool = ttool}) ) end return end

	--check to make sure its a valid model before we add it
	if !util.IsValidModel( device.model ) or !device.tool or !device.category then return end

	util.PrecacheModel(device.model)

	self._deviceid = self._deviceid + 1
	device.id = self._deviceid

	if (type(device.startsound) == "string") then device.startsound = {device.startsound} end
	if (type(device.stopsound) == "string") then device.stopsound = {device.stopsound} end

	for _, sound in pairs(device.stopsound or {}) do util.PrecacheSound(sound) end
	for _, sound in pairs(device.startsound or {}) do util.PrecacheSound(sound) end

	--setup tools for first time if needed
	RS.Tools[device.tool] = RS.Tools[device.tool] or {}
	RS.Tools[device.tool][device.category] = RS.Tools[device.tool][device.category] or {}

	--only save a short version to client
	if (CLIENT) then
		table.insert(RS.Tools[device.tool][device.category], {
			id = device.id,
			name = device.name,
			desc = device.desc,
			model = device.model,
			requires_name = device.requires_name
		})

		return
	end

	--save device to tool category
	table.insert(RS.Tools[device.tool][device.category], device)
end

function RS:AddTools()
end

function RS:SetupTool( toolInfo )
end

if CLIENT then
	function RS.RES( resources ) --receives new resources from the server
		RS.Resources = resources
	end

	--//start messy code
	function EntSetup( id, name, description )
		if (tries or 0) > 100 then return end --max attempts
		local ent = Entity(id)
		if (!IsValid(ent) or !ent:GetTable()) then
			timer.Simple(0.1, function()
				EntSetup( id, name, description, (tries or 0) + 1 )
			end)
		end

		ent:SetVar("name", name)
		ent:SetVar("description", description)
	end

	function EntResources( id, resources, stored, storage, requires )
		if (tries or 0) > 100 then return end --max attempts
		local ent = Entity(id)
		if (!IsValid(ent) or !ent:GetTable()) then
			timer.Simple(0.1, function()
				EntResources( id, resources, stored, storage, requires, (tries or 0) + 1 )
			end)
		end

		ent:SetVar("_resources", resources)
		ent:SetVar("_stored", stored)
		ent:SetVar("_storage", storage)
		ent:SetVar("_requires", requires)
	end
	--// end messy code


	function RS:HUDPaint()
		local ply = LocalPlayer()
		local tr = ply:GetEyeTrace()
		local ent = tr.Entity

		if (!IsValid(ent)) then return end

		if (ent:GetPos():Distance(ply:GetPos()) > 150) then return end

		local rows = {}

		if (ent.name) then table.insert(rows, {
			text=ent.name,
			color = Color(255, 255, 0),
			font = "MDSBtipBold18"
		}) end

		if (ent.description) then table.insert(rows, {
			text=ent.description,
			font = "MDSBtip16"
		}) end

		local active = ent:GetNWInt("Active", -1)
		if (active >= 0) then
			if (active == 1) then
				table.insert(rows, {text="(On)",font = "MDSBtip14"})
			else
				table.insert(rows, {text="(Off)",font = "MDSBtip14"})
			end
		end

		if ent._requires and table.Count(ent._requires) > 0 then
			table.insert(rows, {space=true, text="Requirements:", font = "MDSBtipBold16", color = Color(150,150,150,255)})

			for name, value in pairs(ent._requires) do
				table.insert(rows, {
					text= "\t" .. name .. ": " .. value
				})
			end
		end

		if ent._storage then
			for name, value in pairs(ent._storage) do
				if (!ent._stored[name]) then continue end

				local percent = 0

				if ( ent._stored[name] > 0) then
					percent = math.ceil(100*ent._stored[name]/value)
				end

				table.insert(rows, {
					graph = {percent = percent},
					text= name .. ": " .. ent._stored[name] .. "/" .. value
				})
			end
		end

		if ent._resources and table.Count(ent._resources) > 0 then
			table.insert(rows, {space=true, text="Resources:", font = "MDSBtipBold16", color = Color(150,150,150,255)})

			for name, value in pairs(ent._resources) do
				--if (value <= 0) then continue end

				table.insert(rows, {
					text= "\t" .. name .. ": " .. value
				})
			end
		end

		if (#rows == 0) then return end

		--make suit status hud
		GAMEMODE:MakeHud({
			name = "DeviceInfo",
			minwidth = 150,
			enabled = 1,
			rows = rows,
			pos = ent:LocalToWorld(ent:OBBCenter()):ToScreen()
		})

	end

elseif SERVER then

	function RS:AddResource( name )
		if (!table.HasValue(RS.Resources, name)) then
			table.insert(RS.Resources, name)
			data.Send( "RS.RES", RS.Resources ) --make sure everyone knows the new resource types
		end
	end

	function RS:PlayerInitialSpawn( ply )
		data.Send( "RS.RES", RS.Resources, ply ) --send the player all the resources currently known
	end

	function RS:EntityRemoved( ent )
		timer.Destroy("RSUpdate" .. ent:EntIndex())
	end


	local entity = {
		RS = {}
	}

	function entity:GetNode()
		return RS:Node( self )
	end

	function entity:GetStored( name )
		local stored = {}
		local node = RS:Node(ent)

		for resource, value in pairs( RS:GetTable( self, self.RS.stored ) ) do
			if (name and name ~= resource) then continue end

			stored[resource] = node.stored[resource]
		end

		return stored
	end

	function entity:GetStorage( name )
		local storage = {}
		local node = RS:Node(ent)

		for resource, value in pairs( RS:GetTable( self, self.RS.storage ) ) do
			if (name and name ~= resource) then continue end

			storage[ resource ] = node.storage[resource]

			if (!self:GetStored(resource)) then
				self.RS.stored = self.RS.stored or {}
				self.RS.stored[ resource ] = 0
			end
		end

		return storage
	end

	function entity:GetRequires( name )
		local requires = {}

		for resource, value in pairs( RS:GetTable( self, self.RS.requires ) ) do
			if (name and name ~= resource) then continue end

			requires[ resource ] = RS:GetNumber(self, value)
		end

		return requires
	end

	function entity:GetResources( name )
		local resources = {}

		for resource, value in pairs( RS:GetTable( self, self.RS.resources ) ) do
			if (name and name ~= resource) then continue end
			resources[ resource ] = RS:GetNumber( self, value)
		end

		return resources
	end






	function RS:Setup( ent, options )
		table.Merge( ent, entity )

		ent.RS.volume = self:GetVolume( ent )

		timer.Remove("RSUpdate" .. ent:EntIndex())
		timer.Create("RSUpdate" .. ent:EntIndex(), 1, 0, function()
			RS:Update(ent)
		end)

		if (ent.RS.status) then
			self:SetNWBool( "Active", false )
		end

		if (ent.RS.storage) then
			for name, value in pairs( ent.RS.storage ) do --if set as storage make sure the stored amount is set to zero
				if (!ent.RS.stored) then ent.RS.stored = {} end
				if (type(ent.RS.stored) != "function" && !ent.RS.stored[name]) then ent.RS.stored[name] = 0 end
			end
		end

		if (options) then
			for name, value in pairs( options or {} ) do --apply the custom settings
				if (name == "BaseClass") then
					table.Merge( ent, value )
				else
					ent.RS[name] = value
				end
			end
		end

		RS:Update( ent ) --force update right now
	end

	function RS:Node( Ent, reset ) --gets or sets the RS for the entity
		if !IsValid(Ent) or !Ent.RS then return end

		local node = Ent.RS.node
		local id = Ent:EntIndex()

		if (reset or !node) then
			node = {
				id = id,
				entities = {},
				stored = {},
				storage = {},
				update = 0
			}

			node.entities[id] = Ent

			Ent.RS.node = node
		end

		if (!node.entities[id]) then --not part of this node anymore
			return RS:Node( Ent, true )
		end

		return node
	end

	function RS:Think()
		self.NextThink = CurTime() + 0.5

		for _, ply in pairs( player.GetAll() ) do
			if (!IsValid(ply) or !ply:Alive()) then continue end

			local ent = ply:GetEyeTrace().Entity

			if (!IsValid(ent) or !ent.RS or ent:GetPos():Distance(ply:GetPos()) > 350) then continue end

			data.Send({"EntSetup", "entsetup" .. ent:EntIndex()}, ent:EntIndex(), ent.RS.name, ent.RS.desc, ply) --send name and description
			data.Send({"EntResources", "EntResources"..ent:EntIndex()}, ent:EntIndex(), ent:GetResources(), ent:GetStored(), ent:GetStorage(), ent:GetRequires(), ply)
		end
	end

	function RS:IsActive(ent)
		if (!ent.RS.status) then return true end --no toggle state (always on)
		return ent.Active
	end

	--the Think function to provide and/or consume resources every second
	function RS:Update( ent )
		if (!ent.RS) then return end --make sure valid

		--get the main node and setup the totals table
		local node = RS:Node( ent )

		if (!node) then return end --failure!

		if (CurTime() >= node.update) then --timer check to make sure node isnt updated to often
			node.update = CurTime() + 1

			--START: RECALCULATE NODE PRODUCES, STORED AND STORAGE VALUES
			node.entities, node.ents, node.produces, node.stored, node.storage = Ent._beamsconnected or beams.Connected(Ent), {}, {}, {}, {}

			--loop through the entities
			for i, ent in pairs( node.entities ) do
				if (!IsValid(ent) or !ent.RS) then node.entities[i] = nil; continue end --next please

				ent.RS.node = node

				--produce and/or consume values
				for name, value in pairs(  ent:GetResources() ) do
					self:AddResource( name )
					node.produces[name] = RS:GetNumber(ent, value, node.produces[name])
				end

				--max storage values
				for name, value in pairs( ent:GetStorage() ) do
					self:AddResource( name )
					node.storage[name] = RS:GetNumber(ent, value, node.storage[name])
					node.stored[name] = node.stored[name] or 0 --make sure this is always set.
				end

				--stored values
				for name, value in pairs( ent:GetStored() ) do
					self:AddResource( name )
					node.stored[name] = RS:GetNumber(ent, value, node.stored[name])
				end

				table.insert(node.ents, ent:EntIndex())
			end
			-- END: RECALCULATE NODE PRODUCES, STORED AND STORAGE VALUES
		end

		local stored = node.stored
		local requires = ent:GetRequires() --always assume its a function

		if (requires) then
			--check requirements the entity may have
			for name, value in pairs( requires ) do
				if ( ent.TurnOff and value > (stored[name] or 0)) then
					ent:TurnOff(nil, true)
					return
				end
			end
		end

		if (RS:IsActive(ent)) then
			RS:Commit( ent, requires )
			RS:Commit( ent, ent.RS.resources )
		end
	end

	function RS:Commit( ent, resources, justdoit ) --saves, or consumes, resources amoung all connected devices
		if (type(resources) == "function") then resources = RS:GetTable(ent, resources) end
		if (!resources or table.Count(resources) == 0) then return end --if no resources then exit
		if (!justdoit and !RS:IsActive(ent)) then return end --check to make sure device is active

		for name, value in pairs( resources ) do --go through all the resources to add or subtract
			local storageData = {}

			value = RS:GetNumber( ent, value ) --value of the resource. can be passed in as number of function

			for _, ent in pairs(  RS:Node(ent).entities ) do --we need to run through the entities to short them, this is so the entity with the least amount of storage gets resources first
				if (!IsValid(ent) or !ent.RS) then continue; end

				local storage = RS:GetTable(ent, ent.RS.storage)

				if (storage and storage[name]) then
					ent.RS.stored =  RS:GetTable(ent, ent.RS.stored)
					if (!ent.RS.stored[name]) then ent.RS.stored[name] = 0 end
				else
					continue --this device doesnt store anything
				end

				local stored = RS:GetTable(ent, ent.RS.stored) --get the stored value

				if (type(stored[name]) != "number") then continue; end --we can only store on devices that are not lua coded storage

				table.insert(storageData, {
					Ent = ent,
					Stored = stored[name]
				})
			end

			if (value > 0) then --small values first (for storing)
				table.SortByMember(storageData, "Stored", function(a, b) return a < b end)
			else --large values first (for consuming)
				table.SortByMember(storageData, "Stored")
			end

			for _, data in pairs( storageData ) do
				local ent = data.Ent
				local stored = RS:GetTable(ent, ent.RS.stored)
				local maxLocalStorage = (RS:GetNumber(ent, (RS:GetTable(ent, ent.RS.storage)[name]) or 0))

				if (value > 0) then
					local canStore = math.Clamp(math.Clamp(maxLocalStorage - RS:GetTable(ent, ent.RS.stored)[name], 0, value), 0, maxLocalStorage)
					ent.RS.stored[name] = stored[name] + canStore --store the new value
					value = math.Clamp((value - canStore), 0, 99999999999999999999) --subtract the value from consuming on next entity
				else
					local canConsume = math.Clamp(math.Clamp(value, -stored[name], 0), -maxLocalStorage, 0)
					ent.RS.stored[name] = stored[name] + canConsume --consume the value
					value = math.Clamp(value - canConsume, -99999999999999999999, 0) --subtract the value from consuming on next entity
				end
			end

			if (value <= 0) then break end --nothing left to store then exit
		end

		return value --how much left to store (or 0 for stored all)
	end

	function RS:Capacity( ent, res )
		return RS:Node(ent).storage[res] or 0
	end

	function RS:DeviceCapacity( ent )
		return RS:GetNumber(ent.RS.storage[name])
	end

	function RS:Stored( ent, res )
		if (!res) then
			return RS:Node(ent).stored or {}
		else
			return RS:Node(ent).stored[res] or 0
		end
	end

	function RS:DeviceStored( ent, res )
		if (!res) then
			return RS:GetTable(ent.RS.stored)
		else
			return RS:GetNumber(ent.RS.stored[res])
		end
	end

	function RS:EntityTakeDamage( ent, inflictor, attacker, amount, dmginfo )
		if (!IsValid(ent) or !ent.RS or !amount) then return end

		--leak stored resources in this device
		for _, name in pairs(  RS:DeviceStored(ent) ) do
			RS:Commit(ent, {[name] = -math.random(amount*0.9, amount*1.1)}, true )
		end

		--random chance of fail and turn off
		if (ent.TurnOff and amount > 30 and math.random(1, 10) < 9) then ent:TurnOff() end
	end

	function RS:CanLink( ent1, ent2 ) --checks to see if two entities can be linked. does not check if already in system though.
		return (ent1.RS and ent2.RS)
	end

	function RS:Link( ent1, ent2 )
		beams.QuickLink( ent1, ent2 )
	end

	function RS:Unlink( ent1, ent2 )
		beams.Clear( ent1, ent2 )
	end



	function RS:BuildDupeInfo( ent )
		return {
			RS = {
				storage = RS:Storage(ent),
				stored = RS:Stored(ent)
			}
		}
	end

	function RS:ApplyDupeInfo( ply, ent, CreatedEntities )
		if (!ent.RS) then return end
	end

	function GENERATE( ent )
		return RS:GetVolume( ent ) * 0.90 --devices should be 90% efficiency on average
	end

	function STORAGE( ent )
		return RS:GetVolume( ent ) * 350
	end

	function CONSUME( ent )
		return RS:GetVolume( ent )
	end

	function RADIUS( ent )
		return RS:GetVolume( ent ) * 10
	end
end

--load all client files
for _, f in pairs(file.Find(GM.Folder .. "/gamemode/modules/rs_devices/*.lua", "GAME")) do
	if SERVER then AddCSLuaFile( "rs_devices/" .. f ) end
	include( "rs_devices/" .. f )
end

GM:Register( RS )