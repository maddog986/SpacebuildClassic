TOOL.Name			= "#tool.resource_tool.name"
TOOL.Tab 			= "Spacebuild"
TOOL.Category		= "Life Support"

TOOL.ClientConVar[ "simple" ] = "0"
TOOL.ClientConVar[ "material" ] = "cable/cable"
TOOL.ClientConVar[ "width" ] = "2"
TOOL.ClientConVar[ "color_r" ] = "255"
TOOL.ClientConVar[ "color_g" ] = "255"
TOOL.ClientConVar[ "color_b" ] = "255"

if CLIENT then
	language.Add( "Tool.resource_tool.name", "Device Linker" )
	language.Add( "Tool.resource_tool.desc", "Link two resource devices together." )
	language.Add( "Tool.resource_tool.0", "Click on a resource device." )
	language.Add( "Tool.resource_tool.1", "Click on another resource device to complete the link." )
	language.Add( "Tool.resource_tool.simple", "Make simple beam connection (lower fps)" )
	language.Add( "Tool.resource_tool.width", "Connection Width" )
	language.Add( "Tool.resource_tool.material", "Connection Material" )
	language.Add( "Tool.resource_tool.color", "Connection Color" )

	function TOOL.BuildCPanel( panel )
		--panel name
		panel:AddControl( "Header", {Text = "#Tool.resource_tool.name", Description = "#Tool.resource_tool.desc"})

		panel:AddControl("CheckBox", {
			Label = "#Tool.resource_tool.simple",
			Command = "resource_tool_simple"
		})

		--size slider
		panel:AddControl("Slider", {
			Label = "#Tool.resource_tool.width",
			Type = "Float",
			Min = ".1",
			Max = "10",
			Command = "resource_tool_width"
		})

		--materials
		panel:AddControl( "MatSelect", {
			Height = "3",
			Label = "#Tool.resource_tool.material",
			ItemWidth = 24,
			ItemHeight = 64,
			ConVar = "resource_tool_material",
			Options = list.Get( "beams.Materials" )
		})

		--color changer
		panel:AddControl("Color", {
			Label = "#Tool.resource_tool.color",
			Red = "resource_tool_color_r",
			Green = "resource_tool_color_g",
			Blue = "resource_tool_color_b",
			ShowAlpha = "0",
			ShowHSV = "1",
			ShowRGB = "1",
			Multiplier = "255"
		})
	end

	return
end

function TOOL:SendNotice( msg, msgtype, time )
	self:GetOwner():SendLua( "notification.AddLegacy('" .. msg .. "', ".. msgtype ..", " .. time .. ");" )
	return false
end

function TOOL:LeftClick( trace )
	if ( !IsValid(trace.Entity) ) then return self:SendNotice( "Click on a device entity!", 1, 4 ) end
	if ( !trace.Entity.ResourceEntity ) then return self:SendNotice( "Please select a valid device to link!", 1, 4 ) end
	if ( !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return self:SendNotice( "No physics, can not link!", 1, 4 ) end

	if (self:NumObjects() == 0) then
		--save beam settings
		beams.Settings( trace.Entity, self:GetClientInfo("material"), self:GetClientNumber("width"), Color(self:GetClientNumber("color_r"), self:GetClientNumber("color_g"), self:GetClientNumber("color_b")), self:GetClientNumber("simple") == 1 )

		--add beam
		beams.Add( trace.Entity, trace.Entity, trace.Entity:WorldToLocal(trace.HitPos+trace.HitNormal) )

		self:SetObject( 1, trace.Entity, trace.HitPos, trace.Entity:GetPhysicsObjectNum( trace.PhysicsBone ), trace.PhysicsBone, trace.HitNormal )
		self:SetStage( 1 )

		return true
	end

	if (beams.IsAlreadyConnected( self:GetEnt(1), trace.Entity)) then
		return self:SendNotice( "Devices already linked together!", 1, 4 )
	end

	--add beam
	beams.Add( self:GetEnt(1), trace.Entity, trace.Entity:WorldToLocal(trace.HitPos+trace.HitNormal) )

	self:ClearObjects()	--clear objects

	return true
end

function TOOL:RightClick( trace )
	local ent = trace.Entity

	if ( !IsValid(ent) or !ent.ResourceEntity ) then return false end
	if ( !util.IsValidPhysicsObject( ent, trace.PhysicsBone ) ) then return false end

	if (self:NumObjects() == 0) then return false end

	local ent1 = self:GetEnt(1) 	--get first ent

	--add beam
	beams.Add( ent1, ent, ent:WorldToLocal(trace.HitPos+trace.HitNormal) )

	--if first entity is different than the one we are linking, stop and start a new beam
	if (ent ~= ent1) then
		--done with tool so clear objects
		self:ClearObjects()

		--save beam settings
		beams.Settings( ent, self:GetClientInfo("material"), self:GetClientInfo("width"), Color(self:GetClientInfo("color_r"), self:GetClientInfo("color_g"), self:GetClientInfo("color_b")) )

		self:SetObject( 1, ent, trace.HitPos, ent:GetPhysicsObjectNum( trace.PhysicsBone ), trace.PhysicsBone, trace.HitNormal )
		self:SetStage( 1 )

		--add beam
		beams.Add( ent, ent, ent:WorldToLocal(trace.HitPos+trace.HitNormal) )

		--reset stage
		self:SetStage( 1 )
	end

	return true
end

function TOOL:Reload( trace )
	if ( !IsValid(trace.Entity) or !trace.Entity.ResourceEntity ) then self:ClearObjects(); return end
	if ( CLIENT ) then return true end

	self:ClearObjects()	--clear objects

	--clear any previous beam settings
	beams.Clear( trace.Entity )

	return true
end

function TOOL:Holster()
	self:ClearObjects()
end