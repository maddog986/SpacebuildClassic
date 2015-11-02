if (!beams) || (!RS) then return end

local toolName = "Advanced Linker"
local ctoolName = "mdrslinker"

TOOL.Category		= "Life Support Tools"
TOOL.Tab 			= "Spacebuild"
TOOL.Mode			 = "mdrslinker"
TOOL.Name			= "#" .. toolName
TOOL.Command		= nil
TOOL.ConfigName		= ""

TOOL.ClientConVar[ "material" ] = "cable/cable"
TOOL.ClientConVar[ "width" ] = "2"
TOOL.ClientConVar[ "color_r" ] = "255"
TOOL.ClientConVar[ "color_g" ] = "255"
TOOL.ClientConVar[ "color_b" ] = "255"

--add to cleanup
cleanup.Register( ctoolName )

--tool language
if ( CLIENT ) then
	language.Add( "Tool." .. ctoolName .. ".name", "Advanced Linker" )
	language.Add( "Tool." .. ctoolName .. ".desc", "Link Life Support Devices together into a network." )
	language.Add( "Tool." .. ctoolName .. ".0", "Left Click: Start first link Right Click: Add extra link point, Reload: Remove points" )
	language.Add( "Tool." .. ctoolName .. ".width", "Connection Width" )
	language.Add( "Tool." .. ctoolName .. ".material", "Connection Material" )
	language.Add( "Tool." .. ctoolName .. ".color", "Connection Color" )
end

function TOOL:LeftClick( tr )
	--if client exit
	if ( CLIENT ) then return true end

	--if not valid or player, exit
	if !IsValid(tr.Entity) || !tr.Entity.RS then return false end

	-- If there's no physics object then we can't constraint it!
	if ( !util.IsValidPhysicsObject(tr.Entity, tr.PhysicsBone) ) then return false end

	--how many objects stored
	local iNum = self:NumObjects() + 1

	--save clicked postion
	self:SetObject( iNum, tr.Entity, tr.HitPos, tr.Entity:GetPhysicsObjectNum( tr.PhysicsBone ), tr.PhysicsBone, tr.HitNormal )

	--first clicked object
	if (iNum == 1) then
		--save beam settings
		beams.Settings( self:GetEnt(1), self:GetClientInfo("material"), self:GetClientInfo("width"), Color(self:GetClientInfo("color_r"), self:GetClientInfo("color_g"), self:GetClientInfo("color_b")) )
	else
		if (!RS:CanLink(self:GetEnt(1), tr.Entity)) then
			self:GetOwner():SendLua( "GAMEMODE:AddNotify('Must link similar devices!', NOTIFY_GENERIC, 7);" )

			--done with tool so clear objects
			self:ClearObjects()

			return false
		end

		if (self:IsAlreadyConnected( tr.Entity )) then
			self:GetOwner():SendLua( "GAMEMODE:AddNotify('Devices already linked together!', NOTIFY_GENERIC, 7);" )

			--done with tool so clear objects
			self:ClearObjects()

			return false
		end
	end

	--add beam
	beams.Add( self:GetEnt(1), tr.Entity, tr.Entity:WorldToLocal(tr.HitPos+tr.HitNormal) )

	--clear objects on 2nd click
	if ( iNum >= 2 ) then
		--update Resource System
		RS:Update( tr.Entity )

		--done with tool so clear objects
		self:ClearObjects()
	else
		self:SetStage( iNum + 1 )
	end

	--success!
	return true
end

function TOOL:IsAlreadyConnected( ent )
	local i

	for i=1, self:NumObjects()-1 do
		local _ent = self:GetEnt(i)

		local connected = beams.Connected(_ent)

		if connected[ent:EntIndex()] then
			return true
		end
	end

	return false
end

function TOOL:Holster()
	--done with tool so clear objects
	self:ClearObjects()
end

function TOOL:changetool()
	if (self:GetOwner().lasttool) then
		MsgN("self:GetOwner().lasttool: ", self:GetOwner().lasttool)

		CC_GMOD_Tool(self:GetOwner(),"",{self:GetOwner().lasttool})
	end

	return false
end

function TOOL:RightClick( tr )
	--if not valid or player, exit
	if ( IsValid(tr.Entity) && tr.Entity:IsPlayer() ) || (!IsValid(tr.Entity)) then self:changetool() end
	--if client exit
	if ( CLIENT ) then self:changetool() end
	-- If there's no physics object then we can't constraint it!
	if ( !util.IsValidPhysicsObject( tr.Entity, tr.PhysicsBone ) ) then self:changetool() end
	--entity must be a part of the Resource System
	if (!IsValid(tr.Entity) or tr.Entity.RS) then return false end


	--how many objects stored
	local iNum = self:NumObjects()

	if (iNum == 0) then
		return false
	end

	if (!RS.CanLink(self:GetEnt(iNum), tr.Entity)) then
		self:GetOwner():SendLua( "GAMEMODE:AddNotify('Must link similar devices!', NOTIFY_GENERIC, 7);" )

		return false
	end

	if (self:IsAlreadyConnected( tr.Entity )) then
		self:GetOwner():SendLua( "GAMEMODE:AddNotify('Devices already linked together!', NOTIFY_GENERIC, 7);" )

		--done with tool so clear objects
		self:ClearObjects()

		return false
	end

	--add beam
	beams.Add( self:GetEnt(1), tr.Entity, tr.Entity:WorldToLocal(tr.HitPos+tr.HitNormal) )

	--if first entity is different than the one we are linking, stop and start a new beam
	if (self:GetEnt(iNum) != tr.Entity) then
		--done with tool so clear objects
		self:ClearObjects()

		--save clicked postion
		self:SetObject( 1, tr.Entity, tr.HitPos, tr.Entity:GetPhysicsObjectNum( tr.PhysicsBone ), tr.PhysicsBone, tr.HitNormal )

		--save beam settings
		beams.Settings( tr.Entity, self:GetClientInfo("material"), self:GetClientInfo("width"), Color(self:GetClientInfo("color_r"), self:GetClientInfo("color_g"), self:GetClientInfo("color_b")) )

		--add beam
		beams.Add( tr.Entity, tr.Entity, tr.Entity:WorldToLocal(tr.HitPos+tr.HitNormal) )

		--reset stage
		self:SetStage( 1 )
	end

	--update Resource System
	RS:Update( tr.Entity )

	return true
end

function TOOL:Reload( tr )
	--if not valid or player, exit
	if ( tr.Entity:IsValid() && tr.Entity:IsPlayer() ) || (!tr.Entity || !IsValid(tr.Entity)) then return end
	--if client exit
	if ( CLIENT ) then return true end
	-- If there's no physics object then we can't constraint it!
	if ( !util.IsValidPhysicsObject( tr.Entity, tr.PhysicsBone ) ) then return false end
	--entity must be a part of the Resource System
	if (!tr.Entity.RS) then return false end

	--clear any previous beam settings
	beams.Clear( tr.Entity )

	--update Resource System
	RS:Update( tr.Entity )

	--clear any objects in the tool
	self:ClearObjects()

	return true
end

function TOOL.BuildCPanel( panel )
	--panel name
	panel:AddControl( "Header", {Text = "#Tool_" .. ctoolName .. "_name", Description = "#Tool_" .. ctoolName .. "_desc"})

	--size slider
	panel:AddControl("Slider", {
		Label = "#Tool_" .. ctoolName .."_width",
		Type = "Float",
		Min = ".1",
		Max = "10",
		Command = ctoolName .. "_width"
	})

	--materials
	panel:AddControl( "MatSelect", {
		Height = "3",
		Label = "#Tool_" .. ctoolName .. "_material",
		ItemWidth = 24,
		ItemHeight = 64,
		ConVar = ctoolName .. "_material",
		Options = list.Get( "beams.Materials" )
	})

	--color changer
	panel:AddControl("Color", {
		Label = "#Tool_" .. ctoolName .. "_color",
		Red = ctoolName .. "_color_r",
		Green = ctoolName .. "_color_g",
		Blue = ctoolName .. "_color_b",
		ShowAlpha = "0",
		ShowHSV = "1",
		ShowRGB = "1",
		Multiplier = "255"
	})
end