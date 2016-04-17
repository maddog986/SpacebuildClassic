local PANEL = {}

function PANEL:Init()
	local width, height = 600, 400
	local x, y = ScrW() / 2 - (width/2), ScrH() / 2 - (height/2)

	self:SetSize( width, height )
	self:SetPos( x, y )
	self:SetTitle( "" )

	self:ShowCloseButton( true )
	self:SetVisible( true )
	self:MakePopup()
end

function PANEL:Open()
	self:SetVisible( true )
	self:MakePopup()
end

vgui.Register("SBResources", PANEL, "DFrame")



concommand.Add( "resources_menu", function()
	vgui.Create("SBResources")
end)