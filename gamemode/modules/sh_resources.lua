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
tool header
	tool name
		devices
	tool name
		devices
	tool name
		devices
]]

function RS:AddDevice( device )
	if (type(device.model) == "table") then for _, tmodel in pairs( device.model ) do RS:AddDevice( table.Merge( table.Copy(device), {model = tmodel}) ) end return end
	if (type(device.tool) == "table") then for _, ttool in pairs( device.tool ) do RS:AddDevice( table.Merge( table.Copy(device), {tool = ttool}) ) end return end

	--check to make sure its a valid model before we add it
	if !util.IsValidModel( device.model ) then return end

	--precache model
	Model(device.model)

	--make sure description is set
	device.desc = (device.desc || "")
	device.header = (device.header or "Life Support")

	if (device.startsound && type(device.startsound) == "string") then device.startsound = {device.startsound} end
	if (device.stopsound && type(device.stopsound) == "string") then device.stopsound = {device.stopsound} end

	for _, sound in pairs(device.stopsound or {}) do util.PrecacheSound(sound) end
	for _, sound in pairs(device.startsound or {}) do util.PrecacheSound(sound) end

	--setup tools for first time if needed
	RS.Tools[device.header] = RS.Tools[device.header] or {}
	RS.Tools[device.header][device.tool] = RS.Tools[device.header][device.tool] or {}
	RS.Tools[device.header][device.tool][device.category] = RS.Tools[device.header][device.tool][device.category] or {}

	self.NextDeviceID = (self.NextDeviceID or 0) + 1

	device.id = self.NextDeviceID

	--only save a short version to client
	if (CLIENT) then
		device = {
			id = device.id,
			name = device.name,
			desc = device.desc,
			model = device.model,
			category = device.category,
			header = device.header,
			tool = device.tool
		}
	end

	--save device to tool category
	RS.Tools[device.header][device.tool][device.category][device.id] = device
end

function RS:AddTools()
	TOOL = nil

	for header, info in pairs( RS.Tools ) do --loop through all tools
		for name, categories in pairs( info ) do --loop through tool sections
			RS:SetupTool({
				header = header,
				name = name,
				categories = categories
			})
		end
	end
end

function RS:SetupTool( toolInfo )
	--[[
	toolInfo Input:
		toolInfo.tab
		toolInfo.header
		toolInfo.name
		toolInfo.categories
	]]

	--clean up tool name to provide a clean string for commands
	local shortName = string.Replace(string.Replace(string.lower(string.Replace(toolInfo.name, " ", "_")), "(", ""), ")", "")

	MsgN("--\tRS Tool: ", shortName)

	TOOL = ToolObj:Create()
	TOOL.Mode = shortName
	TOOL.Category = (toolInfo.header || "Life Support")
	TOOL.Tab = (toolInfo.tab || "Spacebuild")
	TOOL.Name = toolInfo.name
	TOOL.Command = nil
	TOOL.ConfigName = ""
	TOOL.ClientConVar[ "weld" ] = 1
	TOOL.ClientConVar[ "worldweld" ] = 1
	TOOL.ClientConVar[ "frozen" ] = 1
	TOOL.ClientConVar[ "model" ] = ""
	TOOL.ClientConVar[ "category" ] = ""
	TOOL.ClientConVar[ "id" ] = 0
	TOOL.ClientConVar[ "flat" ] = 0

	--add to cleanup
	cleanup.Register( shortName )

	--tool language
	if ( CLIENT ) then
		language.Add( "Tool." .. shortName .. ".name", (toolInfo._name || toolInfo.name .. " Tool") )
		language.Add( "Tool." .. shortName .. ".desc", (toolInfo._desc || "Spawn " .. toolInfo.name) )
		language.Add( "Tool." .. shortName .. ".0", (toolInfo._0 || "Left Click: Spawn Device") )
		language.Add( "Tool." .. shortName .. ".weld", (toolInfo._weld || "Weld on Spawn") )
		language.Add( "Tool." .. shortName .. ".worldweld", (toolInfo._worldweld || "Weld to World") )
		language.Add( "Tool." .. shortName .. ".frozen", (toolInfo._frozen || "Spawn Frozen") )
		language.Add( "Tool." .. shortName .. ".flat", (toolInfo._flat || "Rotate Angles") )
		language.Add( "Tool." .. shortName .. ".devices", (toolInfo._devices || "Devices") )
		language.Add( "undone." .. shortName, (toolInfo._undone || "Undone Device") )
	end

	function TOOL:LeftClick( tr )
		if CLIENT then return end

		--get entity info
		local id, category = tonumber(self:GetClientInfo( "id" )), self:GetClientInfo( "category" )

		--get tool settings
		local weld, worldweld, frozen = tonumber(self:GetClientInfo( "weld" )), tonumber(self:GetClientInfo( "worldweld" )), tonumber(self:GetClientInfo( "frozen" ))

		local ply = self:GetOwner() --get info we are about to use
		local ang = tr.HitNormal:Angle() --get angle to place model
		local pos = tr.HitPos - tr.HitNormal

		--get the device settings (also prevents cheating)
		local settings = table.Copy(RS.Tools[toolInfo.header][toolInfo.name][category][id])
		if (!settings) then return false end

		local model = settings.model

		if !util.IsValidModel( model ) then MsgN("not a valid model: ", model); PrintTable(settings); return end

		--create entity
		local ent = ents.Create( settings.base || "mdrs_base" )

		ent:SetModel( model )

		if (self:GetClientNumber("flat") == 0) then
			ang = ang + Angle(90, 0, 0)
			pos = tr.HitPos - tr.HitNormal * ent:OBBMins().z
		end

		--register the device in the Resource System
		RS:Setup( ent, settings )

		ent:SetPos( tr.HitPos )
		ent:SetAngles( ang )
		ent:SetPlayer( ply )
		ent:SetPos(pos)
		ent:Spawn()
		ent:Activate()

		--custom create functions
		if (settings.createfunction) then settings.createfunction( ent ) end

		--weld if enabled
		if (weld == 1 && tr.Entity:IsValid()) || (weld == 1 && worldweld == 1 && tr.Entity:IsWorld()) then
			local const = constraint.Weld(ent, tr.Entity, 0, tr.PhysicsBone, 0, true )

			--if spawning on top of another RS device, auto link them
			if (RS:CanLink(ent, tr.Entity)) then
				timer.Simple(0.1, function()
					--save beam settings
					beams.Settings( ent, "cable/cable", "1", Color(255, 255, 255) )

					--add beam
					beams.Add( ent, ent, ent:WorldToLocal(tr.HitPos+tr.HitNormal) )

					--add beam
					beams.Add( ent, tr.Entity, tr.Entity:WorldToLocal(tr.HitPos+tr.HitNormal) )
				end)
			end
		end

		--get phys to freeze
		local phys = ent:GetPhysicsObject()

		--do some phys stuff if spawn frozen, freeze it and add to frozen objects
		if (phys:IsValid() and frozen == 1) then
			phys:EnableMotion( false )
			ply:AddFrozenPhysicsObject( ent, phys )
		end

		--add to undo list
		undo.Create( shortName )
		undo.AddEntity( ent )	--add new ent to undo
		undo.AddEntity( const ) 	--add weld contraint to undo
		undo.SetPlayer( ply )	--save undo to player
		undo.Finish()

		--add to clean up
		ply:AddCleanup( shortName, ent )
		ply:AddCleanup( shortName, const )
		ply:AddCount( shortName, ent )	--add count against sbox_max[TOOL.Mode]

		return true
	end

	function TOOL:RightClick( tr )
		if CLIENT then return end
		self:GetOwner().lasttool = self.Mode
		CC_GMOD_Tool(self:GetOwner(),"",{"mdrslinker"})
		return false
	end

	function TOOL:Reload( tr )
		if (CLIENT or !IsValid(tr.Entity) or !tr.Entity.Repair or type(tr.Entity) != "function") then return end

		--check to see if entity can be repaired
		if (!tr.Entity.Repair) then
			self:GetOwner():SendLua("GAMEMODE:AddNotify('Object cannot be repaired!', NOTIFY_GENERIC, 7); surface.PlaySound(\"ambient/water/drip"..math.random(1, 4)..".wav\")")
			return
		end

		--run repair function
		tr.Entity:Repair()

		return true
	end

	--Name: Think
	--Desc: Tool think function
	function TOOL:Think( )
		if (CLIENT) then return end

		local model = self:GetClientInfo( "model" )
		if (!model or model == "" or !util.IsValidModel(model)) then return end

		local ent = self.GhostEntity

		if (!IsValid(ent) or string.lower(model) != string.lower(ent:GetModel())) then --string.lower is the key to prevent entity creation spam messages!
			self:MakeGhostEntity( model, Vector(), Angle() )
		return end

		local ply = self:GetOwner()
		local tr = ply:GetEyeTrace()
		local Ang = tr.HitNormal:Angle()

		if (self:GetClientNumber("flat") == 0) then
			Ang = Ang + Angle(90, 0, 0)
			ent:SetPos( tr.HitPos - tr.HitNormal * ent:OBBMins().z )	--update position
		else
			ent:SetPos( tr.HitPos - tr.HitNormal )	--update position
		end

		ent:SetAngles( Ang )		--update angles
		ent:SetNoDraw( false )	--make sure entity is viewable
	end

	if (CLIENT) then
		function TOOL.BuildCPanel( panel )
			panel:AddControl("CheckBox", {Label = "#Tool_" .. shortName .. "_weld",Command = shortName .. "_weld"})
			panel:AddControl("CheckBox", {Label = "#Tool_" .. shortName .. "_worldweld",Command = shortName .. "_worldweld"})
			panel:AddControl("CheckBox", {Label = "#Tool_" .. shortName .. "_frozen",Command = shortName .. "_frozen"})
			panel:AddControl("Checkbox", {Label = "#Tool_" .. shortName .. "_flat",Command = shortName .. "_flat"})

			local Categories = RS.Tools[toolInfo.header][toolInfo.name]  or {}

			local List = vgui.Create("DPanelList", panel)
			List:SetAutoSize( true )
			panel:AddPanel( List )

			local catcontrols = {}

			for name, data in pairs(Categories) do
				local Category = vgui.Create("DCollapsibleCategory", List)

				catcontrols[#catcontrols+1] = Category

				List:AddItem(Category)

				Category:SetSize(70*4, 96 * math.Clamp(table.Count(data)/4, 1, 5))
				Category:SetExpanded( true )
				Category:SetLabel(name)

				function Category.Header:OnMousePressed()
					for k,v in ipairs( catcontrols ) do
						if ( v:GetExpanded() and v.Header != self ) then v:Toggle() end
						if (!v:GetExpanded() and v.Header == self ) then v:Toggle() end
					end
				end

				-- Create a list inside the category
				local Content  = vgui.Create("DPanelList")

				Content:EnableHorizontal( true )
				Content:EnableVerticalScrollbar()
				Content:SetSpacing( 1 )
				Content:SetPadding( 3 )
				Content:SetAutoSize( true )
				Content:SetSpacing( 0 )
				Content:SetPadding( 0 )

				Category:SetContents( Content  )

				for _, info in pairs(data) do
					local icon = vgui.Create( "SpawnIcon", Content  )
					icon:SetModel( info.model )
					icon.ConVars = {id = info.id, category = info.category, model = info.model}
					icon.DoClick = function( self )
						surface.PlaySound( "ui/buttonclickrelease.wav" )

						for name, value in pairs( self.ConVars ) do
							local cmd = Format( "%s \"%s\"\n", shortName .. "_" .. name, value )
							MsgN(cmd)
							LocalPlayer():ConCommand( cmd )
						end
					end

					Content:AddItem( icon )
				end
			end

			for k,v in ipairs( catcontrols ) do
				v:Toggle()
			end

			catcontrols[1]:SetExpanded( true )
		end
	end

	TOOL:CreateConVars()
 	SWEP.Tool[ shortName ] = TOOL
	TOOL = nil
end




function RS:GetResourceKey( id )
	return table.KeyFromValue(self.Resources, id) or 0
end

function RS:GetResourceName( key )
	return self.Resources[key] or key
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
		if (active > 0) then
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
					text= "\t" .. RS:GetResourceName(name).. ": " .. value
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
					text= RS:GetResourceName(name).. ": " .. ent._stored[name] .. "/" .. value
				})
			end
		end

		if ent._resources and table.Count(ent._resources) > 0 then
			table.insert(rows, {space=true, text="Resources:", font = "MDSBtipBold16", color = Color(150,150,150,255)})

			for name, value in pairs(ent._resources) do
				table.insert(rows, {
					text= "\t" .. RS:GetResourceName(name).. ": " .. value
				})
			end
		end

		if (#rows == 0) then return end

		--make suit status hud
		SB:MakeHud({
			name = "DeviceInfo",
			minwidth = 150,
			enabled = 1,
			rows = rows,
			pos = ent:LocalToWorld(ent:OBBCenter()):ToScreen()
		})

	end



--[[

	entity.RS = {

	}
]]
elseif SERVER then

	concommand.Add("rs_trace", function(ply)
		if (!ply:GetEyeTrace().Entity or !ply:GetEyeTrace().Entity.RS) then return end
		local ent = ply:GetEyeTrace().Entity
		MsgN("-------------------------\nENTITY: ", ent)
		PrintTable(ent.RS, 1)
		MsgN("-------------------------\nNODE:")
		PrintTable(RS:Node(ent), 1)
	end)

	function RS:AddResource( name )
		if (!table.HasValue(RS.Resources, name)) then
			table.insert(RS.Resources, name)
			data.Send( "RS.RES", RS.Resources ) --make sure everyone knows the new resource types
		end
	end

	function RS:PlayerInitialSpawn( ply )
		data.Send( "RS.RES", RS.Resources, ply ) --send the player all the resources currently known
	end

	function RS:Setup( ent, options )
		if (!ent.RS) then
			ent.RS = {}
			ent.RS.volume = math.ceil(ent:OBBMaxs():Length())

			timer.Create("RSUpdate" .. ent:EntIndex(), 1, 0, function()
				RS:Update(ent)
			end)

			ent:CallOnRemove("RSRemove", timer.Destroy, "RSUpdate" .. ent:EntIndex())

			if (ent.RS.status) then
				self:SetNWInt("Active", 0)
			end
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
					for n, v in pairs( value ) do
						ent[n] = v
					end
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
				storage = {}
			}

			node.entities[id] = Ent

			Ent.RS.node = node
		end

		if (!node.entities[id]) then --not part of this node anymore
			return RS:Node( Ent, true )
		end

		--if (IsValid(node)) then Ent.RS.node = node end
		--if (!IsValid(Ent.RS.node)) then Ent.RS.node = (node or Ent) end

		if (CurTime() >= (node.update or -10)) then --timer check to make sure node isnt updated to often
			node.update = CurTime() + 1

			--START: RECALCULATE NODE PRODUCES, STORED AND STORAGE VALUES
			node.entities, node.ents, node.produces, node.stored, node.storage = Ent._beamsconnected or beams.Connected(Ent), {}, {}, {}, {}

			node._produces, node._stored, node._storage = {},{},{} --short resource name to send to client

			--loop through the entities
			for i, ent in pairs( node.entities ) do
				if (!IsValid(ent) or !ent.RS) then node.entities[i] = nil; continue end --next please

				ent.RS.node = node

				local resources = RS:GetTable(ent, ent.RS.resources)
				local storage = RS:GetTable(ent, ent.RS.storage)
				local stored = RS:GetTable(ent, ent.RS.stored)

				--produce and/or consume values
				for name, value in pairs( resources ) do
					self:AddResource( name );
					node.produces[name] = RS:GetNumber(ent, value, node.produces[name])
					node._produces[self:GetResourceKey(name)] = node.produces[name]
				end

				--max storage values
				for name, value in pairs( storage ) do
					self:AddResource( name );
					node.storage[name] = RS:GetNumber(ent, value, node.storage[name])
					node.stored[name] = node.stored[name] or 0 --make sure this is always set.
					node._storage[self:GetResourceKey(name)] = node.storage[name]
				end

				--stored values
				for name, value in pairs( stored ) do
					self:AddResource( name );
					node.stored[name] = RS:GetNumber(ent, value, node.stored[name])
					node._stored[self:GetResourceKey(name)] = node.stored[name]
				end

				table.insert(node.ents, ent:EntIndex())
			end

			for _, ent in pairs( node.entities ) do --loop through the entities to update wire
				if (!IsValid(ent) or !ent.RS) then continue end

				--stored values
				for name, value in pairs( node.stored or {} ) do
					ent:WireUpdate( name, node.stored[name] )
					ent:WireUpdate( "Max: " .. name, node.storage[name] )
				end
			end

			-- END: RECALCULATE NODE PRODUCES, STORED AND STORAGE VALUES
		end

		return node
	end

	function RS:Think()
		self.NextThink = CurTime() + 0.1

		for _, ply in pairs( player.GetAll() ) do
			if (!IsValid(ply) or !ply:Alive()) then continue end

			local ent = ply:GetEyeTrace().Entity

			if (!IsValid(ent) or !ent.RS) then continue end
			if (ent:GetPos():Distance(ply:GetPos()) > 350) then continue end

			local node = RS:Node(ent)
			local resources, stored, storage, requires = {},{},{},{}

			for name,value in pairs(RS:GetTable(ent, ent.RS.resources)) do
				resources[ name ] = RS:GetNumber(ent, value)
			end

			for name,value in pairs(RS:GetTable(ent, ent.RS.storage)) do
				storage[ name ] = node.storage[name]

				if (!RS:GetTable(ent, ent.RS.stored)[name]) then
					ent.RS.stored = ent.RS.stored or {}
					ent.RS.stored[ name ] = 0
				end
			end

			for name,value in pairs(RS:GetTable(ent, ent.RS.stored)) do
				stored[ name ] = node.stored[name]
			end

			for name,value in pairs(RS:GetTable(ent, ent.RS.requires)) do
				requires[ name ] = RS:GetNumber(ent, value)
			end

			data.Send({"EntSetup", "entsetup" .. ent:EntIndex()}, ent:EntIndex(), ent.RS.name, ent.RS.desc, ply) --send name and description
			data.Send({"EntResources", "EntResources"..ent:EntIndex()}, ent:EntIndex(), resources, stored, storage, requires, ply)
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
		local stored = node.stored
		local requires = RS:GetTable(ent, ent.RS.requires) --always assume its a function

		if (requires) then
			--check requirements the entity may have
			for name, value in pairs( requires ) do
				value = RS:GetNumber(ent, value)

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

	function RS:GetNumber( ent, value, addition ) --if a value is a function, execute it and return it, else, return the value back
		if (type(value) == "function") then value = math.ceil(value(ent)) end --convert function into a value
		return math.ceil((addition or 0) + (value or 0))
	end

	function RS:GetTable( ent, tbl ) --returns a interger from interger or function
		if (!tbl) then return {} end
		if (type(tbl) == "function") then return tbl(ent) or {} end
		return tbl or {}
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
		return ent.RS.volume * 0.90 --devices should be 90% efficiency on average
	end

	function STORAGE( ent )
		return ent.RS.volume * 350
	end

	function CONSUME( ent )
		return ent.RS.volume
	end

	function RADIUS( ent )
		return ent.RS.volume * 10
	end
end



local meta = FindMetaTable( "Entity" )

function meta:IsSkyAbove( )
	local tr = {}
	tr.start = self:GetPos() + (self:GetUp() * 3)
	tr.endpos = self:GetPos() + Vector(0, 0, 100000)
	tr.filter = self

	return util.TraceLine(tr).HitSky
end


--load all client files
for _, f in pairs(file.Find(SB.Folder .. "/gamemode/modules/rs_devices/*.lua", "GAME")) do
	if SERVER then AddCSLuaFile( "rs_devices/" .. f ) end
	include( "rs_devices/" .. f )
end

SB:Register( RS )
















local meta = FindMetaTable( "Entity" )

function meta:MakeSmoke()
	if (self.EnergyDamageEffects && self.EnergyDamageEffects > 0) then return end --dont do smoke if energy is sparking
	if ((self.SmokeDamageEffects or 0) > 1) then return end

	self.SmokeDamageEffects = (self.SmokeDamageEffects or 0) + 1

	timer.Simple(1.5, function(self)
		if (!ValidEntity(self)) then return end
		self.SmokeDamageEffects = self.SmokeDamageEffects - 1
	end, self)

	local Smoke = ents.Create("env_smoketrail")
	Smoke:SetKeyValue("opacity", 1)
	Smoke:SetKeyValue("spawnrate", 10)
	Smoke:SetKeyValue("lifetime", 2)
	Smoke:SetKeyValue("startcolor", "180 180 180")
	Smoke:SetKeyValue("endcolor", "255 255 255")
	Smoke:SetKeyValue("minspeed", 15)
	Smoke:SetKeyValue("maxspeed", 30)
	Smoke:SetKeyValue("startsize", (self.Entity:BoundingRadius() / 2))
	Smoke:SetKeyValue("endsize", self.Entity:BoundingRadius())
	Smoke:SetKeyValue("spawnradius", 10)
	Smoke:SetKeyValue("emittime", 300)
	Smoke:SetKeyValue("firesprite", "sprites/firetrail.spr")
	Smoke:SetKeyValue("smokesprite", "sprites/whitepuff.spr")
	Smoke:SetPos(self.Entity:GetPos())
	Smoke:SetParent(self.Entity)
	Smoke:Spawn()
	Smoke:Activate()
	Smoke:Fire("kill","", 1)
end



function meta:CreateWaterEffect( pos )
	if (!self.WaterEffects) then self.WaterEffects = 0 end

	--make 10 water effects per ent
	if (self.WaterEffects > 3) then return end

	self.WaterEffects = self.WaterEffects + 1

	local waterEnt = ents.Create("water_projectile")

	if (!ValidEntity(waterEnt)) then return end

	waterEnt:SetPos(pos)
	waterEnt:Spawn()
	waterEnt:SetNetworkedInt("r", 100)
	waterEnt:SetNetworkedInt("g", 100)
	waterEnt:SetNetworkedInt("b", 255)
	waterEnt:SetNetworkedInt("a", 80)
	waterEnt:SetNetworkedInt("viscosity", 5)
	waterEnt:SetCollisionGroup( 4 )

	function waterEnt:OnRemove()
		self.WaterEffects = self.WaterEffects - 1
	end

	timer.Simple( 2, function()
		if (waterEnt && waterEnt:IsValid()) then
			waterEnt:Remove()
		end
	end, self, waterEnt)
end

function meta:EnergyDamage( pos, mag )
	if ((self.EnergyDamageEffects or 0) > 3) then return end

	self.EnergyDamageEffects = (self.EnergyDamageEffects or 0) + 1

	timer.Simple(1.5, function(self)
		if (!ValidEntity(self)) then return end
		self.EnergyDamageEffects = self.EnergyDamageEffects - 1
	end, self)


	local ang = self.Entity:GetAngles()

	pos = pos or (self.Entity:LocalToWorld(self:OBBCenter()) + (ang:Up() * (self.Entity:BoundingRadius()/2)))

	local phys = self:GetPhysicsObject()

	if (!phys:IsValid()) then return end

	local mag = phys:GetVolume() / (phys:GetVolume() / 2) * (mag/10)

	self:EnergySparks((pos + (ang:Right() * mag)), mag)
	self:EnergySparks((pos - (ang:Right() * mag)), mag)
end

function meta:EnergySparks( pos, magnitude )
	local ent = ents.Create("point_tesla")
	ent:SetKeyValue("targetname", "teslab")
	ent:SetKeyValue("m_SoundName" ,"DoSpark")
	ent:SetKeyValue("texture" ,"sprites/physbeam.spr")
	ent:SetKeyValue("m_Color" ,"200 200 255")
	ent:SetKeyValue("m_flRadius" ,tostring(magnitude*80))
	ent:SetKeyValue("beamcount_min" ,tostring(math.ceil(magnitude)+4))
	ent:SetKeyValue("beamcount_max", tostring(math.ceil(magnitude)+12))
	ent:SetKeyValue("thick_min", tostring(magnitude))
	ent:SetKeyValue("thick_max", tostring(magnitude*8))
	ent:SetKeyValue("lifetime_min" ,"0.1")
	ent:SetKeyValue("lifetime_max", "0.2")
	ent:SetKeyValue("interval_min", "0.05")
	ent:SetKeyValue("interval_max" ,"0.08")
	ent:SetPos( pos )
	ent:Spawn()
	ent:Fire("DoSpark","",0)
	ent:Fire("kill","", 1)
end

local function Explode1( ent )
	if ent:IsValid() then
		local Effect = EffectData()
			Effect:SetOrigin(ent:GetPos() + Vector( math.random(-60, 60), math.random(-60, 60), math.random(-60, 60) ))
			Effect:SetScale(1)
			Effect:SetMagnitude(25)
		util.Effect("Explosion", Effect, true, true)
	end
end

local function Explode2( ent )
	if ent:IsValid() then
		local Effect = EffectData()
			Effect:SetOrigin(ent:GetPos())
			Effect:SetScale(3)
			Effect:SetMagnitude(100)
		util.Effect("Explosion", Effect, true, true)
		ent:Remove()
	end
end

function LS_Destruct( ent, Simple )
	if (Simple) then
		Explode2( ent )
	else
		timer.Simple(1, Explode1, ent)
		timer.Simple(1.2, Explode1, ent)
		timer.Simple(2, Explode1, ent)
		timer.Simple(2, Explode2, ent)
	end
end

function FusionBomb( pos, mag, scale )
	local effectdata = EffectData()
	effectdata:SetMagnitude( mag )
	effectdata:SetOrigin( pos )
	effectdata:SetScale( scale )
	util.Effect( "warpcore_breach", effectdata )
end

















--[[
	Resources API
		Last Update: April 2012

		file: resources_api.lua

	Use this in your Life Support devices. Using these function names will
	insure they are compatibile with other systems that use this API.

	This will be called as a shared file as it contains both SERVER and
	CLIENT functions.

	To setup a device you need to run the code:
		ent:InitResources()

	After that the following functions are available to use:
		Client Side Functions:
			ent:ResourcesDraw()

		Server Side Functions:
			ent:ResourcesConsume( resourcename, amount )
			ent:ResourcesSupply( resourcename, amount )
			ent:ResourcesGetCapacity( resourcename )
			ent:ResourcesSetDeviceCapacity( resourcename, amount )
			ent:ResourcesGetAmount( resourcename )
			ent:ResourcesGetDeviceAmount( resourcename )
			ent:ResourcesGetDeviceCapacity( resourcename )
			ent:ResourcesLink( entity )
			ent:ResourcesUnlink( entity )
			ent:ResourcesCanLink( entity )
]]

RESOURCES = {}
RESOURCES.Version = 1 --only changes when something major gets changed

--register the device clientside
function RESOURCES:Setup( ent )
	--[[
		your shared code here
	]]

	--client functions
	if CLIENT then
		--[[
			your client side code here
		]]

		--Used do draw any connections, "beams", info huds, etc for the devices.
		--this would be placed within the ENT:Draw() function
		function self:ResourcesDraw( ent )
			-- your code here
		end

	--server functions
	elseif SERVER then

		--[[
			your server side code here
		]]

		--Can be negitive or positive (for consume and generate)
		-- supply: resource name or resource table
		-- returns: amount not consumed
		function ent:ResourcesConsume( res, amount )
			if type(res) == "table" then
				local consume = {}
				for n, v in pairs( res ) do
					consume[n] = self:ResourcesConsume( n,v )
				end
				return consume
			end

			--your code here
			return 0 --0 = success. Anything larger and it couldnt consume the amount
		end

		--Supplies the resource to the connected network
		-- supply: resource name or resource table
		-- returns:
		function ent:ResourcesSupply( res, amount )
			if type(res) == "table" then
				local supply = {}
				for n, v in pairs( res ) do
					supply[n] = self:ResourcesGenerate( n,v )
				end
				return supply
			end

			--your code here
			return 0 --0 = success. Anything larger and it couldnt supply the amount (insufficient storage)
		end

		--Gets the devices networks total storage for the resource
		-- supply: resource name
		-- returns: number
		-- note: If passed in nothing (nil), return the capity for each resource
		function ent:ResourcesGetCapacity( res )
			if (!res) then
				--your code here
				return 0
			else
				--your code here
				return {} --table of resources
			end
		end

		--Sets the device max storage capacity
		-- supply: resource name or resource table
		-- returns:
		function ent:ResourcesSetDeviceCapacity( res, amount )
			if type(res) == "table" then
				for n, v in pairs( res ) do self:ResourcesSetDeviceCapacity( n,v ) end
			return end

			--your code here
		end

		--  Gets the devices stored amount of resource from the connected network
		--  supply: resource name
		--  returns: number
		function ent:ResourcesGetAmount( res )
			if (!res) then
				--your code here
				return 0
			else
				--your code here
				return {} --table of resources
			end
		end

		--how much this devive is holding
		-- supply: resource name
		-- returns: number
		function ent:ResourcesGetDeviceAmount( res )
			if (!res) then
				--your code here
				return 0
			else
				--your code here
				return {} --table of resources
			end
		end

		--how much this devives network is holding
		-- supply: resource name
		-- returns: number
		function ent:ResourcesGetDeviceCapacity( res )
			if (!res) then
				--your code here
				return 0
			else
				--your code here
				return {} --table of resources
			end
		end

		--link to another device/network
		-- supply: entity
		-- returns:
		function ent:ResourcesLink( entity )
			--your code here
		end

		--removes all link from a network
		-- supply: entity or table of entities (all optional)
		-- returns:
		-- note: if an entity is passed in then unlink with that entity, otherwise unlink all
		function ent:ResourcesUnlink( entity )
			if type(entity) == "table" then
				for _, v in pairs( res ) do self:ResourcesUnlink( v ) end
			return end

			if (!entity) then
				--your code here, unlink all
			else
				--your code here, unlink with entity
			end
		end

		function ent:ResourcesGetLinks()
			return {} --table of connected entities
		end

		--Determains if two devices can be linked
		-- supply: entity or table of entities
		-- returns: boolean (if entity passed in), or table (if table of entities passed in)
		function ent:ResourcesCanLink( entity )
			if type(ent) == "table" then
				local links = {}
				for _, v in pairs( ent ) do
					links[ent] = self:ResourcesCanLink( v )
				end
				return links
			end

			--your code here
			return false
		end

		--Returns a list of connected entities
		function ent:ResourcesGetConnected()
			return {} --returns a table of all connected entities
		end

		--This function is called to save any resource info so it can be saved using the duplicator
		--this goes into ENT:PreEntityCopy
		function ent:ResourcesBuildDupeInfo()
			--your code here
		end

		--This function is called to store any resource info after a dup
		--this goes into ENT:PostEntityPaste
		function ent:ResourcesApplyDupeInfo( ply, ent, CreatedEntities )
			--your code here
		end
	end
end

local meta = FindMetaTable( "Entity" )

--sets up the functions to be used on the "Life Support" devices
-- supply: entity
function meta:InitResources( )
	RESOURCES:Setup( self )
end