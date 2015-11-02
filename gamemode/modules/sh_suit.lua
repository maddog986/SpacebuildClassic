--[[

	Author: MadDog (steam id md-maddog)

	TODO:
		- add some kind of space thruster to suit
			- energy that regenerates over long period
]]
local SUIT = {}

SUIT.Name = "Suit"
SUIT.Author = "MadDog"
SUIT.Version = 1

if SERVER then
	function SUIT:EntityTakeDamage( ent, inflictor, attacker, amount, dmginfo )
		if (!ent:IsPlayer() or !ent:Alive() or !ent:HasSuit()) then return end

		ent:SuitDamage( amount )

		dmginfo:SetDamage( amount )

		return (ent:Suit() > 0)
	end

	function SUIT:PlayerSpawn( ply )
		ply:SetSuit(100)
		ply.alive = true
	end

	function SUIT:PlayerDeath( ply, inflictor, attacker )
		ply.alive = false
	end

	function SUIT:Think()
		self.NextThink = CurTime() + 1

		if (!GAMEMODE:GetClass("Environments")) then return end

		for _, ply in pairs( player.GetAll() ) do
			if (!IsValid(ply)) then continue end

			if ((ply.dead or 0) > CurTime()) then continue end

			if (!ply:Alive() or !ply.alive) then
				ply.dead = CurTime() + 2
				continue
			end

			--if (ply.dead and ply.dead > CurTime()) then continue end --give our player some time to spawn before dealing damage

			--ply:SetNWInt("Health", ply:Health()) --todo: why did i add this here? cant remember if its needed. we dont want to set this every frame though...

			if (ply:GetOxygen() < 5) then
				ply:TakeDamage(math.random(1, 5), ply, ply)
			end

			if (ply:GetTemperature() > 321 or ply:GetTemperature() < 260) then --temps way out of control
				ply:TakeDamage(math.random(1, 5), ply, ply)
			end

			if (ply:GetAtmosphere() >= 3 or ply:GetAtmosphere() == 0) then --crushing atmosphere, or nothing at all
				ply:TakeDamage(math.random(1, 5), ply, ply)
			end

			--todo: add pressure crush damage
			--atmosphere charge
			--	0 = None
			--	1 = Normal
			--	2 = Water
		 	--	3 = Dense
			--	4 = Deadly
		end
	end
end

--[[
	PLAYER MODS
]]
local meta = FindMetaTable( "Player" )

function meta:HasSuit()
	return self:GetNWBool("HasSuit", false)
end

function meta:HasSuitArmor()
	return self:GetNWBool("HasSuitArmor", false)
end

function meta:Suit()
	return self:GetNWInt("Suit")
end

function meta:GetMaxSuit()
	return self:GetNWInt("MaxSuit", 0)
end

function meta:GetMaxSuitArmor()
	return self:GetNWInt("MaxSuitArmor", 0)
end

function meta:SuitArmor()
	return self:GetNWInt("SuitArmor")
end


if SERVER then
	function meta:SetSuit( amount )
		self:SetNWInt("Suit", math.Clamp(amount, 0, self:GetMaxSuit()))
	end

	function meta:SuitDamage( amount )
		if (self:HasSuitArmor()) then amount = amount / (self:SuitArmor() / 20) end
		self:SetSuit(self:Suit() - amount)
	end

	function meta:SetMaxSuit( amount )
		self:SetNWInt("MaxSuit", amount)
	end

	function meta:SetSuitArmor( amount )
		self:SetNWInt("SuitArmor", math.Clamp(amount, 0, self:GetMaxSuitArmor()))
	end

	function meta:SuitArmorDamage( amount )
		self:SetSuitArmor(self:SuitArmor() - amount)
	end

	function meta:SetMaxSuitArmor( amount )
		self:SetNWInt("MaxSuitArmor", amount)
	end

else

	local hidesuit = 0
	local lastsuit = ""
	local lastsuittime = 0

	local disabledhuds = {"CHudHealth", "CHudBattery"}

	function SUIT:HUDShouldDraw( name ) --disable stock huds
		if (table.HasValue(disabledhuds, name)) then return false end
	end

	local CircleMat = Material( "SGM/playercircle" )

	function SUIT:PrePlayerDraw( ply )
		if (!ply:IsAdmin()) then return end

		local colour = Color(255,255,255,75)-- Only change these
		local radius = 50                 --

		local trace = {}
		trace.start = ply:GetPos() + Vector(0,0,50)
		trace.endpos = trace.start + Vector(0,0,-300)
		trace.filter = ply
		local tr = util.TraceLine( trace )
		if !tr.HitWorld then
			tr.HitPos = ply:GetPos()
		end
		render.SetMaterial( CircleMat )
		render.DrawQuadEasy( tr.HitPos + tr.HitNormal, tr.HitNormal, radius, radius, colour )
	end

	function SUIT:RenderScreenspaceEffects()
	    local tab = {}
	    tab[ "$pp_colour_addr" ]        = 0
	    tab[ "$pp_colour_addg" ]        = 0
	    tab[ "$pp_colour_addb" ]        = 0
	    tab[ "$pp_colour_brightness" ]  = 0
	    tab[ "$pp_colour_contrast" ]    = 1
	    tab[ "$pp_colour_colour" ]      = math.Clamp( LocalPlayer():Health() / 100, 0, 1 )
	    tab[ "$pp_colour_mulr" ]        = 0
	    tab[ "$pp_colour_mulg" ]        = 0
	    tab[ "$pp_colour_mulb" ]        = 0

	    DrawColorModify( tab )
	end

	function SUIT:HUDPaint()
		local suittimeout = OPTIONS:Get( "suittimeout", 30 )
		local suitposition = OPTIONS:Get( "suitposition", "Left Top" )

		local percent = LocalPlayer():Suit() / LocalPlayer():GetMaxSuit() * 100
		local s = GAMEMODE:Tween("suit", percent)
		local h = GAMEMODE:Tween("health", LocalPlayer():Health())

		local percent2 = 0

		if (LocalPlayer():GetMaxSuitArmor() > 0) then percent2 = LocalPlayer():SuitArmor() / LocalPlayer():GetMaxSuitArmor() * 100 end

		local s2 = GAMEMODE:Tween("suitarmor", percent2)

		if ((s .. s2 .. h .. suitposition) != lastsuit) then
			lastsuit = (s .. s2 .. h .. suitposition)
			lastsuittime = CurTime() + suittimeout
		end

		local rows = {{
			graph = {percent = h},
			text = "Health (" .. LocalPlayer():GetMaxHealth() .. ")",
			icon = "icon16/heart.png"
		}}

		if (LocalPlayer():HasSuit()) then
			table.insert(rows, {
				graph = {percent = s},
				text = "Suit Level (" ..  LocalPlayer():GetMaxSuit() .. ")",
				icon = "icon16/user.png"
			})
		end

		if (LocalPlayer():HasSuitArmor()) then
			table.insert(rows, {
				graph = {percent = s2},
				text = "Suit Armor (" ..  LocalPlayer():GetMaxSuitArmor() .. ")",
				icon = "icon16/award_star_silver_1.png"
			})
		end

		--make suit status hud
		GAMEMODE:MakeHud({
			name = "SuitHud",
			minwidth = 160,
			position = suitposition,
			enabled = ((LocalPlayer():Alive() and lastsuittime > CurTime()) or suittimeout == 0),
			rows = rows
		})
	end

end

GM:Register( SUIT )