--[[

	Author: MadDog (steam id md-maddog)

	TODO:
		- Fix the menu in the options tab.
		- Cleanup
]]

local soundlevel = CreateClientConVar( "mdsb_soundlevel", "100", true, false )
local sbhudposition = CreateClientConVar( "mdsb_sbhudposition", "Right Top", true, false )
local sbsuitposition = CreateClientConVar( "mdsb_sbsuitposition", "Left Top", true, false )


local Options = {}

function Options:Create( parent )
	local Width = 300

	if (self.Settings) then
		self.Settings:Remove()
		self.Settings = nil
	end

	if (!parent) then
		self.Settings = vgui.Create( "DFrame" )
		self.Settings:Center()
		self.Settings:SetSize( 350, 500 )
		self.Settings:SetTitle( "Spacebuild Settings" )
		self.Settings:SetVisible( true )
		self.Settings:SetDraggable( true )
		self.Settings:SetSizable( true )
		self.Settings:ShowCloseButton( true )
		self.Settings:Center()
		self.Settings:MakePopup()

		Width = self.Settings:GetWide() - 40

		self.InnerPanel = vgui.Create( "DPanel", self.Settings )
		self.InnerPanel:StretchToParent( 5, 25, 5, 5 )

		self.Panel = vgui.Create( "DPanelList", self.InnerPanel )
		self.Panel:SetPaintBackgroundEnabled( true )
		self.Panel:SetPaintBorderEnabled( true )
		self.Panel:SetDrawBackground( true )
		self.Panel:SetPadding( 10 )
		self.Panel:SetSpacing( 5 )
		self.Panel:EnableVerticalScrollbar(true)
	else
		self.Settings = parent
		self.InnerPanel = parent
		self.Panel = parent
	end



	self.Blooms = vgui.Create( "DCheckBoxLabel", self.Panel )
	self.Blooms:SetText( "Enable Planet Blooms" )
	self.Blooms:SetConVar( "mdsb_blooms" )
	self.Panel:AddItem(self.Blooms)


	self.Colors = vgui.Create( "DCheckBoxLabel", self.Panel )
	self.Colors:SetText( "Enable Planet Colors" )
	self.Colors:SetConVar( "mdsb_colors" )
	self.Panel:AddItem(self.Colors)


	self.Rays = vgui.Create( "DCheckBoxLabel", self.Panel )
	self.Rays:SetText( "Enable Sun Rays" )
	self.Rays:SetConVar( "mdsb_suns" )
	self.Panel:AddItem(self.Rays)


	self.Ambient = vgui.Create( "DNumSlider", self.Panel )
	self.Ambient:SetText( "Ambient Sounds (0 = Disable)" )
	self.Ambient:SetMin( 0 )
	self.Ambient:SetMax( 100 )
	self.Ambient:SetDecimals( 0 )
	self.Ambient:SetConVar( "mdsb_soundlevel" )
	self.Panel:AddItem(self.Ambient)


	self.Rain = vgui.Create( "DNumSlider", self.Panel )
	self.Rain:SetText( "Rain Effects Level (0 = Disable)" )
	self.Rain:SetMin( 0 )
	self.Rain:SetMax( 2000 )
	self.Rain:SetDecimals( 0 )
	self.Rain:SizeToContents()
	self.Rain:SetConVar( "mdsb_rainintense" )
	self.Panel:AddItem(self.Rain)


	self.Snow = vgui.Create( "DNumSlider", self.Panel )
	self.Snow:SetWide( Width )
	self.Snow:SetText( "Snow Effects Level (0 = Disable)" )
	self.Snow:SetMin( 0 )
	self.Snow:SetMax( 3000 )
	self.Snow:SetDecimals( 0 )
	self.Snow:SetConVar( "mdsb_snowintense" )
	self.Panel:AddItem(self.Snow)


	self.HudTimeout = vgui.Create( "DNumSlider", self.Panel )
	self.HudTimeout:SetWide( Width )
	self.HudTimeout:SetText( "Hud Disappear Time In Seconds (0 = Disable)" )
	self.HudTimeout:SetMin( 0 )
	self.HudTimeout:SetMax( 150 )
	self.HudTimeout:SetDecimals( 0 )
	self.HudTimeout:SizeToContents()
	self.HudTimeout:SetConVar( "mdsb_sbhudtimeout" )
	self.Panel:AddItem(self.HudTimeout)


	local params = {}
	params["Top Left"] = { mdsb_sbhudposition = "Left Top" }
	params["Top Center"] = { mdsb_sbhudposition = "Center Top " }
	params["Top Right"] = { mdsb_sbhudposition = "Right Top" }
	params["Middle Left"] = { mdsb_sbhudposition = "Left Center" }
	params["Middle Center"] = { mdsb_sbhudposition = "Center Center" }
	params["Middle Right"] = { mdsb_sbhudposition = "Right Center" }
	params["Bottom Left"] = { mdsb_sbhudposition = "Left Bottom" }
	params["Bottom Center"] = { mdsb_sbhudposition = "Center Bottom" }
	params["Bottom Right"] = { mdsb_sbhudposition = "Right Bottom" }

	self.HudOptions = vgui.Create("DListView", self.Panel)
	self.HudOptions:SetMultiSelect( false )
	self.HudOptions:SetWide( Width )
	self.HudOptions:SetTall( 150 )
	self.HudOptions:AddColumn( "Environment Hud Position:" )
	self.Panel:AddItem(self.HudOptions)

	for k, v in pairs( params ) do
		local line = self.HudOptions:AddLine( k )
		line.data = v

		for k, v in pairs( line.data ) do
			if ( GetConVarString( k ) == v ) then
				line:SetSelected( true )
			end
		end
	end

	function self.HudOptions:OnRowSelected( LineID, Line )
		for k, v in pairs( Line.data ) do
			RunConsoleCommand( k, v )
		end
	end


	self.SuitTimeout = vgui.Create( "DNumSlider", self.Panel )
	self.SuitTimeout:SetWide( Width )
	self.SuitTimeout:SetText( "Suit Disappear Time In Seconds (0 = Disable)" )
	self.SuitTimeout:SetMin( 0 )
	self.SuitTimeout:SetMax( 120 )
	self.SuitTimeout:SetDecimals( 0 )
	self.SuitTimeout:SizeToContents()
	self.SuitTimeout:SetConVar( "mdsb_sbsuittimeout" )
	self.Panel:AddItem(self.SuitTimeout)


	local params = {}
	params["Top Left"] = { mdsb_sbsuitposition = "Left Top" }
	params["Top Center"] = { mdsb_sbsuitposition = "Center Top " }
	params["Top Right"] = { mdsb_sbsuitposition = "Right Top" }
	params["Middle Left"] = { mdsb_sbsuitposition = "Left Center" }
	params["Middle Center"] = { mdsb_sbsuitposition = "Center Center" }
	params["Middle Right"] = { mdsb_sbsuitposition = "Right Center" }
	params["Bottom Left"] = { mdsb_sbsuitposition = "Left Bottom" }
	params["Bottom Center"] = { mdsb_sbsuitposition = "Center Bottom" }
	params["Bottom Right"] = { mdsb_sbsuitposition = "Right Bottom" }

	self.SuitOptions = vgui.Create("DListView", self.Panel)
	self.SuitOptions:SetMultiSelect( false )
	self.SuitOptions:SetWide( Width )
	self.SuitOptions:SetTall( 150 )
	self.SuitOptions:AddColumn( "Suit Hud Position:" )
	self.Panel:AddItem(self.SuitOptions)

	for k, v in pairs( params ) do
		local line = self.SuitOptions:AddLine( k )
		line.data = v

		for k, v in pairs( line.data ) do
			if ( GetConVarString( k ) == v ) then
				line:SetSelected( true )
			end
		end
	end

	function self.SuitOptions:OnRowSelected( LineID, Line )
		for k, v in pairs( Line.data ) do
			RunConsoleCommand( k, v )
		end
	end

	if (!parent) then
		self.InnerPanel:InvalidateLayout()
		self.InnerPanel:StretchToParent( 5, 25, 5, 5 )
		self.Panel:InvalidateLayout()
		self.Panel:StretchToParent( 0, 0, 0, 0 )
	end

	return self.Settings
end


local function ShowOptions()
	Options:Create()
end
concommand.Add( "mdsb_settings", ShowOptions )

-- Tool Menu
local function AddPostProcessMenu()
	spawnmenu.AddToolMenuOption( "Spacebuild", "Options", "Visuals", "Options and Graphics", "", "", function()
		Options:Create( CPanel )
	end)--{ SwitchConVar = "mdsb_blooms" } )
end
hook.Add( "PopulateToolMenu", "AddPostProcessMenu_MDSB", AddPostProcessMenu )

