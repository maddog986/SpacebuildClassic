surface.CreateFont( "SpacebuildName", {
	font = "Roboto",
	size = 21,
	weight = 800
})

surface.CreateFont( "SettingsPluginName", {
	font = "Roboto",
	size = 18,
	weight = 800
})

surface.CreateFont( "SettingsPluginDesc", {
	font = "Roboto",
	size = 14
})

surface.CreateFont( "SettingsPluginVerAut", {
	font = "Roboto",
	size = 12
})

local PANEL = {}

function PANEL:Init()
	self:SetSize( 600, 500 ) --w,h
	self:Center()

	self.lblTitle:SetFont( "SpacebuildName" )
	self:SetTitle( "Spacebuild Revolution Settings" )

	self.btnMaxim:SetVisible( false )
	self.btnMinim:SetVisible( false )

	local blur_material = Material( "pp/blurscreen" )

	blur_material:SetFloat( "$blur", 3 )
	blur_material:Recompute()

	self.Paint = function( self, w, h )
		local x, y = self:LocalToScreen( 0, 0 )

		surface.SetDrawColor( Color( 0, 0, 0, 180 ) )
		surface.SetMaterial( blur_material )
		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect( -x, -y, ScrW(), ScrH() )
		draw.RoundedBox( 10, 0, 0, self:GetWide(), self:GetTall(), Color(0,0,0,180) )
	end

	self.DProperty = self:Add( "DPropertySheet" )
	self.DProperty:Dock( FILL )
	self.DProperty:DockMargin( 5, 5, 5, 5 )

	self:MakePopup()
end

function PANEL:AddTab( name, icon )
	local panel = self:Add( "DScrollPanel" )
	panel:SetPos( 0, 0 )
	panel:SetSize( self.DProperty:GetWide(), self.DProperty:GetTall() )
	panel:SetPadding( 10, 10, 10, 10 )
	panel.Paint = function( self, w, h )
		surface.SetDrawColor( Color( 0, 0, 0, 100 ) )
		surface.DrawRect( 0, 0, w, h )
	end

	self.DProperty:AddSheet( name, panel, icon  )
end

function PANEL:GetTab( name )
	for row, tab in pairs( self.DProperty.Items ) do
		--return tab or return last tab if no tab is found
		if ( tab.Name == name or row == #self.DProperty.Items) then return tab.Panel end
	end
end

function PANEL:AddControl( data, parent )
	if ( !data or data.admin and !LocalPlayer():IsAdmin() ) then return end

	local tab = parent or self:GetTab( data.tab )

	table.Inherit( data, {
		text = "",
		font = "DermaDefaultBold",
		dark = false,
		bright = false,
		hightlight = false,
		bgcolor = Color( 0, 0, 0, 100 )
	})

	if ( type(data.default) == "boolean" ) then
		self:Checkbox( data, tab )
	elseif ( data.min and data.max ) then
		self:Slider( data, tab )
	elseif ( data.options ) then
		self:List( data, tab )
	elseif ( data.category ) then
		self:CollapsibleCategory( data, tab )
	elseif ( data.description ) then
		self:PluginInfo( data, tab )
	elseif ( data.button ) then
		self:Button( data, tab )
	else
		self:Label( data, tab )
	end
end

function PANEL:Button( data, parent )
	local button = parent:Add("DButton")
	button:Dock( TOP )
	button:DockMargin( 15, 5, 15, 5 )
	button:SetText( data.text )
	button:SetConVar( data.var )
end

function PANEL:Label( data, parent )
	local panel = parent:Add( "DListLayout" )
	panel:Dock( TOP )
	panel:DockMargin( 5, 5, 5, 5 )
	panel:DockPadding( 0, 0, 0, 5 )

	if ( data.hightlight ) then
		panel.Paint = function( self, w, h )
			surface.SetDrawColor( data.bgcolor )
			surface.DrawRect( 0, 0, w, h )
		end
	end

	local label = panel:Add( "DLabel" )
	label:SetWrap( true )
	label:DockMargin( 5, 5, 5, 5 )
	label:SetText( data.text )
	if ( data.color ) then label:SetTextColor( data.color ) end
	label:SetFont( data.font )
	label:SetDark( data.dark )
	label:SetBright( data.bright )
	label:SetAutoStretchVertical( true )
end

function PANEL:PluginInfo( data, parent )
	local gradient_material = Material( "gui/gradient_down" )

	local panel = parent:Add( "DListLayout" )
	panel:Dock( TOP )
	panel:DockMargin( 5, 0, 5, 0 )
	panel:DockPadding( 0, 0, 0, 0 )
	panel.Paint = function( self, w, h )
		surface.SetDrawColor( data.bgcolor )
		surface.DrawRect( 0, 0, w, h )
		surface.SetMaterial( gradient_material )
		surface.DrawTexturedRect( 0, 0, w, h)
	end

	local name = panel:Add( "DLabel" )
	name:DockMargin( 5, 5, 5, 5 )
	name:SetText( data.text )
	name:SetFont( "SettingsPluginName" )
	name:SetBright( true )

	local desc = panel:Add( "DLabel" )
	desc:SetWrap( true )
	desc:DockMargin( 5, 0, 0, 0 )
	desc:SetText( data.description or "" )
	desc:SetFont( "SettingsPluginDesc" )
	desc:SetAutoStretchVertical( true )

	local row = panel:Add( "DListLayout" )
	row:DockMargin( 5, 0, 5, 0 )

	local version = row:Add( "DLabel" )
	version:Dock( RIGHT )
	version:SetText( "Version: " .. data.version )
	version:SetFont( "SettingsPluginVerAut" )
	version:SetTextColor( Color(255,255,255,80) )
	version:SizeToContents()

	local author = row:Add( "DLabel" )
	author:Dock( LEFT )
	author:SetText( "Author: " .. data.author )
	author:SetFont( "SettingsPluginVerAut" )
	author:SetTextColor( Color(255,255,255,80) )
	author:SizeToContents()

	row:SizeToContents()
end

function PANEL:Checkbox( data, parent )
	local label = parent:Add( "DCheckBoxLabel" )
	label:Dock( TOP )
	label:DockMargin( 15, 5, 15, 5 )
	label:SetText( data.text )
	label:SetConVar( data.var )
end

function PANEL:Slider( data, parent )
	local label = parent:Add( "DNumSlider" )
	label:Dock( TOP )
	label:DockMargin( 15, 0, 15, 0 )
	label:SetText( data.text )
	label:SetMin( data.min )
	label:SetMax( data.max )
	label:SetDecimals( data.decimal or 0 )
	label:SetConVar( data.var )
end

function PANEL:List( data, parent )
	local label = parent:Add( "DListView" )
	label:Dock( TOP )
	label:DockMargin( 15, 5, 15, 15 )
	label:SetMultiSelect( false )
	label:AddColumn( data.text )
	label:SetTall( #data.options * 10 )
	label.OnRowSelected = function( self, line, row )
		RunConsoleCommand( data.var, data.options[line] )
	end

	for _, name in pairs( data.options ) do
		local row = label:AddLine( name )

		if ( GetConVar(data.var):GetString() == name ) then
			label:SelectItem( row )
		end
	end
end

function PANEL:CollapsibleCategory( data, parent )
	local category = parent:Add( "DCollapsibleCategory" )
	category:Dock( TOP )
	category:SetExpanded( 1 )
	category:SetLabel( data.text )
	category:DockMargin( 5, 5, 5, 5 )

	local layout = category:Add( "DListLayout" )
	layout:Dock( TOP )
	layout:DockMargin( 0, 5, 0, 5 )

	for _, row in pairs( data.items ) do
		self:AddControl( row, layout )
	end

	layout:SizeToContents()
	category:SizeToContents()
end

vgui.Register("SBGamemodeSettingsMenu", PANEL, "DFrame")
