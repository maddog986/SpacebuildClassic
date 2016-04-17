--[[
	Author: MadDog (steam id md-maddog)

	I may have stole some code from https://github.com/SimonSchick/sa2

	TODO: Finish
	Add better prop removal system, maybe fade out?
]]

local DAMAGE = {}
DAMAGE.Name = "Damage System"
DAMAGE.Author = "MadDog"
DAMAGE.Version = 1

DAMAGE.Multipliers = {
	metal_bouncy = 2.0,
	metal = 2.0,
	default = 1.0,
	dirt = 0.2,
	slipperyslime = 0.1,
	wood = 0.5,
	glass = 1.0,
	concrete_block = 1.5,
	ice = 0.4,
	rubber = 0.3,
	paper = 0.1,
	zombieflesh = 0.2,
	gmod_ice = 0.4,
	gmod_bouncy = 0.4,
	gmod_silent = 0.4,
	weapon = 2
}

function DAMAGE:GetHealth( ent )
	local phys = ent:GetPhysicsObject()

	if (!IsValid(phys) or !phys:GetMass() or !phys:GetVolume()) then return 100 end

	return (phys:GetMass()*phys:GetVolume()^0.1) * (self.Multipliers[phys:GetMaterial()] or 1)
end

function DAMAGE:OnEntityCreated( ent )
	if (!IsValid(ent) or ent:IsWorld() or ent:IsPlayer()) then return end

	timer.Simple(0, function()
		if (!IsValid(ent)) then return end

		local health = DAMAGE:GetHealth(ent)

		ent._damagehealth = health
		ent._damagemax = health
	end)
end

function DAMAGE:EntityTakeDamage( ent, dmg )
	if ( !IsValid(ent) or ent:IsWorld() or ent:IsPlayer() ) then return end
	if ( ent.IgnoreDamage ) then ent:OnTakeDamage( dmg ) return end

	local damage = dmg:GetDamage()

	--anti prop damage
	if ( ent:IsPlayer() and dmg:GetDamageType() == DMG_CRUSH ) then
		dmginfo:ScaleDamage( 0.0 )
    end

	if ( ent:IsPlayer() ) then return end

	--player needs to take some of the pod/vehicle damage
	if ( ent:IsVehicle() and IsValid(ent:GetDriver()) ) then
		local ply = ent:GetDriver()

		ply:TakeDamage( damage * 0.1, dmg:GetAttacker(), dmg:GetInflictor() )
	end

	local newhealth = math.Round(ent._damagehealth - damage)

	if ( newhealth <= 0 ) then
		local size, pos = ent:BoundingRadius(), ent:GetPos()

		local effect = EffectData()
		effect:SetOrigin( pos )
		effect:SetScale( size )
		effect:SetRadius( size )
		effect:SetMagnitude( size )

		util.Effect( "damaged_explode", effect )

		SafeRemoveEntity( ent )
	else
		local color = ((ent._damagehealth/ent._damagemax) * 255)

		ent._damagehealth = newhealth

		ent:SetColor( Color(color, color, color, 255) )
	end
end

GM:AddPlugin( DAMAGE )