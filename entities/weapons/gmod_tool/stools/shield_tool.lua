TOOL.Name			= "#tool.shield_tool.name"
TOOL.Tab 			= "Spacebuild"
TOOL.Category		= "Life Support"

TOOL.ClientConVar[ "model" ] = "models/dav0r/hoverball.mdl"
TOOL.ClientConVar[ "keytoggle" ] = "46"
TOOL.ClientConVar[ "size" ] = "600"

cleanup.Register( "shield_tool" )

if CLIENT then
	language.Add( "Tool.shield_tool.name", "Shield" )
	language.Add( "Tool.shield_tool.desc", "Click on a place to spawn a shield device." )
	language.Add( "Tool.shield_tool.keyon", "Select a key to enable/disable the shield." )

	function TOOL.BuildCPanel( panel )
		--panel name
		panel:AddControl( "Header", {Text = "#Tool.shield_tool.name", Description = "#Tool.shield_tool.desc"})

		panel:AddControl( "Slider", { Label = "#tool.shield_tool.size", Command = "shield_tool_size", Type = "Integer", Min = "100", Max = "2000" } )

		panel:AddControl( "Numpad", { Label = "#tool.shield_tool.keytoggle", Command = "shield_tool_keytoggle" } )
		panel:AddControl( "PropSelect", { Label = "#tool.shield_tool.model", ConVar = "shield_tool_model", Models = list.Get( "HoverballModels" ), Height = 4 } )
	end

	return
end

function TOOL:SendNotice( msg, msgtype, time )
	self:GetOwner():SendLua( "notification.AddLegacy('" .. msg .. "', ".. msgtype ..", " .. time .. ");" )
	return false
end

function TOOL:LeftClick( trace )
	local model = self:GetClientInfo( "model" )
	local keyon = self:GetClientNumber( "keyon" )
	local size = math.Clamp( self:GetClientNumber( "size" ), 100, 2000 )

	if ( !util.IsValidModel( model ) ) then return false end
	if ( !util.IsValidProp( model ) ) then return false end

	local ply = self:GetOwner()
	local shield = ents.Create("sb_shield")

	shield.Model = model
	shield.ShieldSize = size

	shield:SetPos(trace.HitPos)
	shield:Spawn()
	shield:Activate()

	numpad.OnDown( ply, self:GetClientNumber( "keytoggle" ), "SBShieldEnable", shield, true )

	undo.Create( "shield_tool" )
		undo.AddEntity( shield )
		undo.SetPlayer( ply )
	undo.Finish()

	ply:AddCleanup( "shield_tool", shield )

	return true
end

function TOOL:RightClick( trace )
	return true
end

function TOOL:Think()

	if ( !IsValid( self.GhostEntity ) || self.GhostEntity:GetModel() != self:GetClientInfo( "model" ) ) then
		self:MakeGhostEntity( self:GetClientInfo( "model" ), Vector( 0, 0, 0 ), Angle( 0, 0, 0 ) )
	end

	self:UpdateGhostShield( self.GhostEntity, self:GetOwner() )

end

function TOOL:UpdateGhostShield( ent, pl )
	if ( !IsValid( ent ) ) then return end

	local tr = util.GetPlayerTrace( pl )
	local trace	= util.TraceLine( tr )
	if ( !trace.Hit ) then return end

	if ( trace.Entity:IsPlayer() || trace.Entity:GetClass() == "sb_shield" ) then

		ent:SetNoDraw( true )
		return

	end

	local CurPos = ent:GetPos()
	local NearestPoint = ent:NearestPoint( CurPos - ( trace.HitNormal * 512 ) )
	local Offset = CurPos - NearestPoint

	ent:SetPos( trace.HitPos + Offset )

	ent:SetNoDraw( false )

end