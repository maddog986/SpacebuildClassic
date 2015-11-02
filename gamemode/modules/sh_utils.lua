--[[

	Author: MadDog (steam id md-maddog)

]]

function util.InRange( num, low, high )
	return (num >= low and num <= high)
end

function util.IsInWater( pos )
	return util.TraceLine({
		start = pos,
		endpos = pos + Vector(0,0,1),
		bit.bor(MASK_WATER, MASK_SOLID)
	}).Hit
end


--credit goes to Overv for this, posted at http://facepunch.com/showthread.php?t=1044809#post27158859
function table.Compare( tbl1, tbl2 )
	for k, v in pairs( tbl1 ) do
		if ( type(v) == "table" and type(tbl2[k]) == "table" ) then
		    if ( !table.Compare( v, tbl2[k] ) ) then return false end
		else
		    if ( v != tbl2[k] ) then return false end
		end
	end
	for k, v in pairs( tbl2 ) do
		if ( type(v) == "table" and type(tbl1[k]) == "table" ) then
		    if ( !table.Compare( v, tbl1[k] ) ) then return false end
		else
		    if ( v != tbl1[k] ) then return false end
		end
	end
	return true
end

util.smoother = function(target, current, smooth)
	return current + math.Clamp((target - current) * math.Clamp(FrameTime(), 0.0001, 10) / smooth, -1, 1)
end

concommand.Add("sb_pos", function( ply, cmd, args )

	local trace = ply:GetEyeTrace()

	local ent = trace.Entity

	if (!ent) then return end

	MsgN("Normal: ", trace.HitNormal)
	MsgN("Local Pos:", ent:WorldToLocal(trace.HitPos))

end)

--[[
	DEBUG FUNCTIONS
]]
concommand.Add("sb_environments_details", function( ply, cmd, args )
	local environments  = ply:GetEnvironments()

	for _, ent in pairs(environments) do
		if (!IsValid(ent)) then continue end

		local onplanet = ply:GetPos():Distance(ent:GetPos()) < ent:GetRadius()

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

print("Dev command: sb_environments_details")
print("Dev command: sb_environments_reload")


	concommand.Add("rs_trace", function(ply)
		if (!ply:GetEyeTrace().Entity or !ply:GetEyeTrace().Entity.RS) then return end
		local ent = ply:GetEyeTrace().Entity
		MsgN("-------------------------\nENTITY: ", ent)
		PrintTable(ent.RS, 1)
		MsgN("-------------------------\nNODE:")
		PrintTable(RS:Node(ent), 1)
	end)




local function Explode1( ent )
	if ent:IsValid() then
		local Effect = EffectData()
			Effect:SetOrigin(ent:GetPos() + Vector( math.random(-60, 60), math.random(-60, 60), math.random(-60, 60) ))
			Effect:SetScale(1)
			Effect:SetMagnitude(25)
		util.Effect("Explosion", Effect, true, true)
	end
end

local function Explode2( ent )
	if ent:IsValid() then
		local Effect = EffectData()
			Effect:SetOrigin(ent:GetPos())
			Effect:SetScale(3)
			Effect:SetMagnitude(100)
		util.Effect("Explosion", Effect, true, true)
		ent:Remove()
	end
end

function LS_Destruct( ent, Simple )
	if (Simple) then
		Explode2( ent )
	else
		timer.Simple(1, Explode1, ent)
		timer.Simple(1.2, Explode1, ent)
		timer.Simple(2, Explode1, ent)
		timer.Simple(2, Explode2, ent)
	end
end

function FusionBomb( pos, mag, scale )
	local effectdata = EffectData()
	effectdata:SetMagnitude( mag )
	effectdata:SetOrigin( pos )
	effectdata:SetScale( scale )
	util.Effect( "warpcore_breach", effectdata )
end

color_black = Color(0, 0, 0, 255)
color_white = Color(255, 255, 255, 255)
color_grey = Color(97, 95, 90, 255)
color_darkgrey = Color(43, 42, 39, 255)
color_green = Color(194, 255, 72, 255)
color_orange = Color(255, 137, 44, 255)
color_purple = Color(135, 81, 201, 255)
color_blue = Color(59, 142, 209, 255)
color_tan = Color(178, 161, 126, 255)
color_cream = Color(245, 255, 154, 255)
color_mooca = Color(107, 97, 78, 255)
color_yellow = Color(255, 216, 0, 255)
color_brightyellow = Color(255, 255, 0, 255)
color_red = Color(191, 75, 37, 255)
color_brightred = Color(255, 0, 0, 255)