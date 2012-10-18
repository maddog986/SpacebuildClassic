--[[

	Author: MadDog (steam id md-maddog)

	TODO:
		- Cleanup/finish/improve
]]

local CHARACTERS = {}
CHARACTERS.Name = "Characters"
CHARACTERS.Author = "MadDog"
CHARACTERS.Version = 1

local meta = FindMetaTable("Player")

if SERVER then
	CHARACTERS.UpdateTime = 10 --10 minutes
	CHARACTERS.File = "sb_characters.txt"
	CHARACTERS.data = CHARACTERS.data or {}

	function CHARACTERS:InitPostEntity()
		self.data = glon.decode(file.Read(self.File, "DATA")) or {}
	end

	function CHARACTERS:Load( ply )
		local unixTime = os.time()
		local character = self.data[ply:SteamID()] or {}

		character.lastPlayed = character.lastPlayed or unixTime;
		character.timeCreated = character.timeCreated or unixTime;
		character.health = character.health or 100
		character.suit = character.suit or 0

		self.data[ply:SteamID()] = character

		return character
	end

	function CHARACTERS:Save()
		file.Write(self.File, glon.encode(self.data or {}))
	end

	function CHARACTERS:PlayerInitialSpawn( ply )
		ply.character = self:Load( ply )

		if (ply.character.health == 0) then ply.character.health = 100 end --cant spawn with zero heath

		--timer is used incase something else resets health or suit
		timer.Create("CPlayerInitialSpawn"..ply:SteamID(), 0.1, 2, function()
			ply:SetSuit( ply.character.suit or 100)
			ply:SetHealth( ply.character.health or 100)
		end)

		ply.character.inventory =ply.character.inventory or {}
	end

	function CHARACTERS:PlayerDisconnected( ply )
		if (!IsValid(ply)) then return end
		if (!ply.character) then return end

		local unixTime = os.time()
		local character = self.data[ply:SteamID()]

		character.lastPlayed = unixTime
		character.health = ply:Health()
		character.suit = ply:Suit()

		self:Save()
	end

	function CHARACTERS:Think()
		self.NextThink = CurTime() + (60*self.UpdateTime) --save every X minutes
		self:Save()
	end

	function CHARACTERS:ShutDown()
		self:Save()
	end

	if (!meta.SetHealthOld) then meta.SetHealthOld = meta.SetHealth end

	function meta:SetHealth( amount )
		self:SetNWInt("Health", math.Clamp(amount, 0, self:GetMaxHealth()))
		--if (self.SetHealthOld) then return self:SetHealthOld(amount) end
	end
end

function meta:GetMaxHealth()
	return self:GetNWInt("MaxHealth", 100)
end

if (!meta.SetMaxHealthOld) then meta.SetMaxHealthOld = meta.SetMaxHealth end

function meta:SetMaxHealth( amount )
	--if (self.SetMaxHealthOld) then self:SetMaxHealthOld(amount) end
	return self:GetNWInt("MaxHealth", amount)
end

SB:Register( CHARACTERS )