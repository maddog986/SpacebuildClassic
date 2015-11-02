surface.CreateFont( "SpacebuildName", {
 font = "Orial",
 size = 40,
 weight = 700,
 blursize = 0,
 scanlines = 0,
 antialias = true
} )


local PANEL = {}

PANEL.tabs = {}

function PANEL:Init()
	local width, height = 600, 400
	local x, y = ScrW() / 2 - 150, ScrH() / 2 - 300

	self:SetSize( width, height )
	self:SetPos( x, y )
	self:SetTitle( "" )
	--self:SetDraggable( true )
	self:ShowCloseButton( true )
	self:SetVisible( true )
	self:MakePopup()


	local label = vgui.Create( "DLabel", self ) -- We only have to parent it to the DPanelList now, and set it's position.
	label:SetPos( 15,0 )
	label:SetText( "SPACEBUILD!" )
	label:SetSize( 300, 40)
	label:SetFont("SpacebuildName")
	label:SetColor( Color(255, 255, 255) )
	label:SetDark( true )
	label:SetWrap( false )

	self.Paint = function( self )
		draw.RoundedBox( 10, 0, 0, self:GetWide(), self:GetTall(), Color(0,0,0,180) )
	end

	self.sheet = vgui.Create( "DPropertySheet", self )
	self.sheet:Dock( FILL )
	self.sheet:DockMargin( 10, 10, 10, 10 )
end

function PANEL:Open()
	self:SetVisible( true )
	self:MakePopup()
end

function PANEL:AddTab( name, icon )
	local panel = vgui.Create( "DScrollPanel" )
	panel:SetPos( 0, 0 )
	panel:SetSize( self.sheet:GetWide(), self.sheet:GetTall() )

	self.sheet:AddSheet(name or "Settings", panel, icon or "icon16/wrench.png", false, false, name or "Settings")

	self.tabs[name] = panel

	return self.tabs[name]
end

function PANEL:GetTab( name )
	if (!self.tabs[name]) then self:AddTab( name ) end

	return self.tabs[name]
end

function PANEL:AddLabel( text, parent )
	local label = vgui.Create("DLabel") -- We only have to parent it to the DPanelList now, and set it's position.
	label:Dock( TOP )
	label:SetText( text )
	label:DockMargin( 5, 5, 5, 5 )
	label:SizeToContents()
	label:SetFont("DermaDefaultBold")
	label:SetDark( true )

	parent:Add(label)
end

function PANEL:AddCheckbox( text, var, parent )
	local label = vgui.Create("DCheckBoxLabel")
	label:Dock( TOP )
	label:DockMargin( 0,0,0, 5 )
	label:SetText( text )
	label:SetValue( OPTIONS:Get(var) )

	function label:OnChange( checked )
		OPTIONS:Set( var, checked )
	end

	parent:Add(label)
end

function PANEL:AddSlider( text, var, min, max, decimal, parent )
	local label = vgui.Create("DNumSlider")
	label:Dock( TOP )
	label:DockMargin( 0,0,10,5 )
	label:SetText( text )
	label:SetMin( min or 0)
	label:SetMax( max or 100)
	label:SetDecimals( decimal or 0 )
	label:SetValue( OPTIONS:Get(var) )

	function label:OnValueChanged(value)
		OPTIONS:Set(var, self:GetValue())
	end

	parent:Add(label)
end

function PANEL:AddList( name, var, list, parent )
	local label = vgui.Create( "DListView" )
	label:Dock( TOP )
	label:DockMargin( 0,0, 5, 5 )
	label:SetMultiSelect( false )
	label:AddColumn( name )
	label:SetTall( 100 )

	function label:OnRowSelected( line, row )
		OPTIONS:Set(var, list[line])
	end

	for _, name in pairs( list ) do
		local row = label:AddLine( name )

		if (OPTIONS:Get(var) == name) then
			label:SelectItem( row )
		end
	end

	parent:Add(label)
end


function PANEL:AddCollapsibleCategory( name, var, items, parent )
	local category = vgui.Create( "DCollapsibleCategory" )
	category:Dock( TOP )
	category:SetExpanded( 1 )
	category:SetLabel( name )
	category:DockMargin( 5, 5, 5, 5 )
	category:SizeToContents()

	local layout = vgui.Create( "DListLayout", category )
	layout:Dock( TOP )
	layout:DockMargin( 0, 5, 0, 5 )

	for i, row in pairs(items) do
		if (row.type == "checkbox") then
			self:AddCheckbox( row.text, row.var, layout )
		elseif (row.type == "slider") then
			self:AddSlider( row.text, row.var, row.min, row.max, row.decimal, layout )
		elseif (row.type == "list") then
			self:AddList( row.text, row.var, row.list, layout )
		elseif (row.type == "label") then
			self:AddLabel( row.text, layout )
		end
	end

	layout:SizeToContents()

	parent:Add(category)
end

vgui.Register("SBSettingsPanel", PANEL, "DFrame")




concommand.Add( "sbmodels", function()
	vgui.Create("SBSettingsPanel")
end)