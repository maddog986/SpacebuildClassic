--[[
	Author: MadDog (steam id md-maddog)
]]

OPTIONS = {}
OPTIONS.Name = "Player Options"
OPTIONS.Version = 1
OPTIONS.tabs = {}
OPTIONS.options = {}
OPTIONS.vars = {} --holds the serverside vars
OPTIONS.default = {} --holds all the default vars values
OPTIONS.playervars = {} --holds the clientside vars

if SERVER then
	util.AddNetworkString( "options_server_update" )

	net.Receive( "options_server_update", function( len, ply )
		local name = net.ReadString()
		local value = von.deserialize(net.ReadString())[1]

		OPTIONS:Set( name, value, ply )
	end)

	--client setup
	function OPTIONS:PlayerInitialSpawn( ply )
		self.default = {}

		if !file.IsDir("settings", "DATA") then -- check to see if folder exists
			file.CreateDir("settings") -- create it if it doesn't
		end

		local filename = "settings/" .. string.gsub( ply:SteamID(), ":", "_" ) .. ".txt"

		if !file.Exists(filename, "DATA") then -- check to see if file exists
			file.Write(filename, "") -- create it if it doesn't
		end

		self.playervars[ply] = util.JSONToTable( file.Read( filename, "DATA" ) or "{ }" ) or {}

		if (ply:IsAdmin()) then
			table.Merge(self.playervars[ply], self.vars)
		end

		data.Send( "OPTIONSSTART", self.playervars[ply], self.tabs, self.options )
	end

	--server setup
	function OPTIONS:Initialize()
		if !file.IsDir("settings", "DATA") then -- check to see if folder exists
			file.CreateDir("settings") -- create it if it doesn't
		end

		self.ServerFileName = "settings/settings.txt"

		if !file.Exists(self.ServerFileName, "DATA") then -- check to see if file exists
			file.Write(self.ServerFileName, "") -- create it if it doesn't
		end

		self.vars = util.JSONToTable( file.Read( self.ServerFileName, "DATA" ) or "{ }" ) or {}
	end

	function OPTIONS:SaveServer() --called when LUA is being shutdown, aka server turning off, used to save settings
		file.Write(self.ServerFileName, util.TableToJSON(self.vars) )
	end

	function OPTIONS:SaveClient( ply )
		local filename = "settings/" .. string.gsub( ply:SteamID(), ":", "_" ) .. ".txt"
		local vars = self.playervars[ply]

		if (ply:IsAdmin()) then
			for name, value in pairs(vars or {}) do
				if (data.level == "server") then
					vars[name] = nil
				end
			end
		end

		file.Write(filename, util.TableToJSON(vars) )
	end

	function OPTIONS:PlayerDisconnected( ply ) --called when LUA is being shutdown, aka server turning off, used to save settings
		self:SaveClient( ply )
		self.playervars[ply] = nil
	end
end

function OPTIONS:Get( name, defaultvalue, ply )
	if (!self.default[name] and defaultvalue) then
		self.default[name] = defaultvalue
	end

	return self.vars[name] or self.playervars[name] or defaultvalue or self.default[name]
end

function OPTIONS:IsServerSetting( var )
	for _, data in pairs(self.options or {}) do
		if (data.var == var and data.level == "server") then
			return true
		end
	end

	return false
end

function OPTIONS:Set( name, value, ply )
	if SERVER then
		MsgN("Options.Set IsServerSetting: ", self:IsServerSetting( name ))

		if (self:IsServerSetting( name )) then
			if (ply and !ply:IsAdmin()) then return end --wtf user shouldnt be here

			self.vars[name] = value

			MsgN("Saved Server setting: ", name)

			self:SaveServer()
		else
			self.playervars[ply][name] = value

			MsgN("Saved Client setting: ", name)

			self:SaveClient( ply )
		end
	else
		self.vars[name] = value

		net.Start( "options_server_update" )
		net.WriteString( name )
		net.WriteString( von.serialize({value}) )
		net.SendToServer()
	end
end

function OPTIONS:Register( data )
	if (data.default) then self.default[data.name] = data.default end
	table.insert(self.options, data)
end

function OPTIONS:RegisterTab( data )
	table.insert(self.tabs, data)
end

GM:Register( OPTIONS )






if SERVER then return end





OPTIONS.vars = {}
OPTIONS.default = {}

function OPTIONSSTART( settings, tabs, options )
	OPTIONS.vars = settings or {}
	OPTIONS.tabs = tabs or {}
	OPTIONS.options = options or {}
end

function OPTIONS:OpenPanel()

	self.panel = vgui.Create("SBSettingsPanel")

	for _, tab in pairs(self.tabs) do
		if (tab.admin and !LocalPlayer():IsAdmin()) then continue end
		self.panel:AddTab( tab.name, tab.icon )
	end

	for _, data in pairs(self.options) do
		if (data.admin and !LocalPlayer():IsAdmin()) then continue end

		if (!self.vars[data.var] and data.default) then self.vars[data.var] = data.default end
		if (!self.default[data.var] and data.default) then self.default[data.var] = data.default end

		local tab = self.panel:GetTab( data.tab )

		if (data.type == "checkbox") then
			self.panel:AddCheckbox( data.name, data.var, tab )
		elseif (data.type == "slider") then
			self.panel:AddSlider( data.name, data.var, data.min, data.max, data.decimal, tab )
		elseif (data.type == "list") then
			self.panel:AddList( data.name, data.var, data.list, tab )
		elseif (data.type == "label") then
			self.panel:AddLabel( data.name, tab )
		elseif (data.type == "category") then
			self.panel:AddCollapsibleCategory( data.name, data.var, data.list, tab )
		end
	end


	local models = self.panel:AddTab( "Life Support", "icon16/wrench.png" )




	local device_preview = vgui.Create( "SBModelPreviewPanel", models )
	device_preview:Dock( LEFT )









	local ctrl = vgui.Create( "DTree", models )
	ctrl:Dock( RIGHT )
	ctrl:SetPadding( 5 )
	ctrl:SetSize( 200, 330 )


	for categoryname, data in pairs( RS.Tools ) do
		local node = ctrl:AddNode( categoryname )

		for name, devices in pairs( data ) do
			local cnode = node:AddNode( name )

			for num, info in pairs( devices ) do
				local ccnode = cnode:AddNode( info.name .. "#" .. num )

				ccnode.OnNodeSelected = function( self )
					device_preview:SetName( info.name )
					device_preview:SetDesc( info.desc )
					device_preview:SetModel( info.model )
					device_preview:SetRequirements( info.requires_name )
				end
			end
		end
	end





















if (true) then return end
	local panel = vgui.Create( "DScrollPanel", models )
	panel:Dock( RIGHT )
	panel:SetSize( 260, 330 )
	--models:Add( panel )



	local sheet = vgui.Create( "DPropertySheet", panel )
	sheet:Dock( FILL )
	sheet:SetSize( 220, 330 )

	local tabpanel = vgui.Create( "DScrollPanel", sheet )
	--tabpanel.Paint = function( self, w, h ) draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 128, 255 ) ) end

	sheet:AddSheet( "test", tabpanel, "icon16/cross.png" )


	for name, devices in pairs( RS.Tools["Life Support"]["Generator"] ) do
		local category = vgui.Create("DCollapsibleCategory", tabpanel )
		category:Dock( TOP )
		category:DockMargin( 5, 5, 5, 5 )
		category:SetExpanded( false )
		category:SetLabel( name )

		local iconlist = vgui.Create( "DIconLayout", category )
		iconlist:SetSpaceY( 5 )
		iconlist:SetSpaceX( 5 )

		category:SetContents( iconlist )

		for id, data in pairs( devices ) do

			local layout = vgui.Create( "DListLayout", iconlist )

			local icon = vgui.Create( "SpawnIcon", layout )
			icon:Dock( TOP )
			icon:SetModel( data.model )
			layout:Add(icon)

			function icon:DoClick()
				device_preview:SetName( data.name )
				device_preview:SetDesc( data.desc )
				device_preview:SetModel( data.model )
			end

			local icon_name = vgui.Create( "DLabel", layout )
			icon_name:Dock( TOP )
			icon_name:SetText( data.name )
			layout:Add(icon_name)

			iconlist:Add( layout )
		end

		iconlist:SizeToChildren( false, true )
		category:SizeToChildren( false, true )

		tabpanel:Add(category)
	end



--[[



	category:SetContents( content )

	models:Add( panel )]]

end



-- Tool Menu
hook.Add( "PopulateToolMenu", "OptionsMenu", function()
	spawnmenu.AddToolMenuOption( "Spacebuild", "Options", "Visuals", "Options and Graphics", "", "", function( Panel )
		local button = vgui.Create( "DButton", Panel )
		button:Dock( TOP )
		button:SetText( "Open Settings Window" )
		button:SetSize( 120, 60 )
		button.DoClick = function()
			OPTIONS:OpenPanel()
		end
	end)
end)

concommand.Add( "mdsb_settings", function()
	OPTIONS:OpenPanel()
end)