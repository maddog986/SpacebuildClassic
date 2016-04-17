surface.CreateFont("DeviceName", {
    font="Orial",
    size = 16,
    weight = 700,
    antialias = true
})

surface.CreateFont("DeviceDescription", {
    font="Orial",
    size = 14,
    weight = 700,
    antialias = true
})

surface.CreateFont("DeviceRequire", {
    font="Orial",
    size = 12,
    weight = 1000,
    antialias = true
})

local PANEL = {}

function PANEL:Init()
	self:SetSize( 300, 300 ) --width, height
	self:SetBackgroundColor( Color(0,0,0,0) )

	self.device_name = vgui.Create( "DLabel", self )
	self.device_name:Dock( TOP )
	self.device_name:SetFont( "DeviceName" )
	self.device_name:SetColor( Color(255,255,255) )
	self.device_name:SetWrap( true )
	self.device_name:SetText("")

	self.device_desc = vgui.Create( "DLabel", self )
	self.device_desc:Dock( TOP )
	self.device_desc:DockMargin( 0, 3, 0, 0 )
	self.device_desc:SetFont( "DeviceDescription" )
	self.device_desc:SetColor( Color(230,230,230) )
	self.device_desc:SetWrap( true )
	self.device_desc:SetText("")

	self.device_require = vgui.Create( "DLabel", self )
	self.device_require:Dock( TOP )
	self.device_require:DockMargin( 0, 3, 0, 0 )
	self.device_require:SetFont( "DeviceRequire" )
	self.device_require:SetColor( Color(255,200,200) )
	self.device_require:SetWrap( true )
	self.device_require:SetText("")

	self.modelpreview = vgui.Create( "SBModelPanel", self )
	self.modelpreview:Dock( TOP )
	self.modelpreview:DockMargin( 0, 3, 0, 0 )
	self.modelpreview:SetSize( 220, 180 )
	self.modelpreview:ChangeModel( "models/air_compressor.mdl" )


	self.activate = vgui.Create( "DButton", self )
	self.activate:Dock( TOP )
	self.device_require:DockMargin( 0, 3, 0, 0 )
	self.activate:SetText( "Deploy Device" )
	self.activate:SetSize( 80, 30 )
	self.activate.DoClick = function()
		print( "Button was clicked!" )
	end
end

function PANEL:SetName( name )
	self.device_name:SetText( name or "" )
	self.device_desc:SizeToContents()
end

function PANEL:SetDesc( desc )
	self.device_desc:SetText( desc or "" )
	self.device_desc:SizeToContents()
end

function PANEL:SetRequirements( requires )
	local text = "Requires: "

	if (!requires) then
		text = ""
	else
		for _, name in pairs( requires ) do
			text = text .. name .. ", "
		end

		text = string.sub( text, 1, #text - 2 )
	end

	self.device_require:SetText( text or "" )
	self.device_require:SizeToContents()
end

function PANEL:SetModel( model )
	self.modelpreview:ChangeModel( model )
end

vgui.Register("SBModelPreviewPanel", PANEL, "DPanel")