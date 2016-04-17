
--[[
	DEBUG FUNCTIONS
]]

concommand.Add("sb_pos", function( ply, cmd, args )
	local trace = ply:GetEyeTrace()

	local ent = trace.Entity

	if (!ent) then return end

	MsgN("Normal: ", trace.HitNormal)
	MsgN("Local Pos:", ent:WorldToLocal(trace.HitPos))
end)

concommand.Add("sb_environments_details", function( ply, cmd, args )
	local environments  = ply:GetEnvironments()

	for _, ent in pairs(environments) do
		if (!IsValid(ent)) then continue end

		local onplanet = ply:GetPos():Distance(ent:GetPos()) < ent:GetSize()

		MsgN("----------------\n", ent)
		MsgN("OnEnvironment: ", onplanet)
		MsgN("Environments:")
		PrintTable(ent:GetEnvironment(), 1)
		MsgN("--- Entities")
		PrintTable(ent.Entities, 3)
		MsgN("--- Watch")
		PrintTable(ent.Watch, 3)
		MsgN("----------------")
	end
end)

concommand.Add("sb_environments_reload", function()
	ENVIRONMENTS:InitPostEntity()
end)

concommand.Add("sb_terraform", function( ply )
	local environments  = ply:GetEnvironments()

	for _, ent in pairs(environments) do
		if (!IsValid(ent)) then continue end

		timer.Create("terraform" .. ent:EntIndex(), 1, 60, function()
			ent:TerraForm()
		end)
	end
end)

concommand.Add("sb_terraform_reset", function( ply )
	local environments  = ply:GetEnvironments()

	for _, ent in pairs(environments) do
		if (!IsValid(ent)) then continue end

		timer.Create("terraformreset" .. ent:EntIndex(), 1, 60, function()
			ent:TerraFormReset()
		end)
	end
end)

concommand.Add("PointToSun", function( ply, command )

	ply:PrintMessage( HUD_PRINTTALK, tostring(ply:GetEyeTrace().HitPos) )


	local Vec1 = (SunAngle or Vector( 0, 0, -1 ))
	local Vec2 = ply:GetShootPos() -- This is where we are
	local Ang = (Vec1 - Vec2):Angle() -- Gets the angle between the two points
	ply:SetEyeAngles( Ang ) -- Sets the angle

	local trace = {}
	trace.start = ply:GetPos() - (SunAngle * 4096)
	trace.endpos = ply:GetPos()
	trace.filter = ply
	--trace.mask = MASK_NPCWORLDSTATIC

	local tr = util.TraceLine( trace )

	if (tr.Hit) and (tr.Entity:IsValid()) then
		ply:PrintMessage( HUD_PRINTTALK, "No Sun Light - " .. tostring(tr.Hit) )
	else
		ply:PrintMessage( HUD_PRINTTALK, "Wear Sun Glasses - " .. tostring(tr.Hit) )
	end

end)


game.ConsoleCommand("sbox_weapons 0\n")
game.ConsoleCommand("sv_noclipspeed 15\n") --TODO: remove before release
game.ConsoleCommand("sv_cheats 1\n")

--Removing the cleanup command since it removes things it shouldnt
concommand.Remove( "gmod_admin_cleanup" )
concommand.Add( "gmod_admin_cleanup", function( ply, cmd, args )
	game.CleanUpMap()
end)

if (!game.CleanUpMapOld) then game.CleanUpMapOld = game.CleanUpMap end

function game.CleanUpMap() --preventing the planets from being cleaned up
	game.CleanUpMapOld( false, {"sb_planets","logic_case"} )
end

--no saving allowed
concommand.Remove("gm_save")

--TODO: add more commands here
function GM:PlayerSay( ply, text, toall )
	-- This function clobbers Spacebuild 2 and 3 code, here is the replacement
	--self.BaseClass:PlayerSay( ply, text, toall )
	if ply:IsAdmin() then
		if (string.sub(text, 1, 10 ) == "!freemap") then
			game.CleanUpMap()
			return text
		end
	end
	-- End Spacebuild Code
end

--TODO: finish this


function GM:ShowTeam( ply ) --f2
end

function GM:ShowSpare1( ply ) --f3
end

function GM:ShowSpare2( ply ) --f4
end