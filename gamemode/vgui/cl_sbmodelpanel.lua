local PANEL = {}

function PANEL:Init()
end

function PANEL:ChangeModel( name )
	self:SetModel( name )

	local PrevMins, PrevMaxs = self.Entity:GetRenderBounds()
	self:SetCamPos(PrevMins:Distance(PrevMaxs)*Vector(0.75, 0.75, 0.5))
	self:SetLookAt((PrevMaxs + PrevMins)/2)
end

vgui.Register("SBModelPanel", PANEL, "DModelPanel")