AddCSLuaFile()

DEFINE_BASECLASS( "rs_base_device" )

ENT.Spawnable = true
ENT.AdminOnly = true

ENT.PrintName = "Shield Device"
ENT.Information = "Shield Device"
ENT.Author	= "MadDog"
ENT.Model = "models/maxofs2d/thruster_projector.mdl"
ENT.UseType = USE_TOGGLE
ENT.Category = "Life Support"
ENT.ShieldSize = 400
ENT.ShieldColor = color_blue

function ENT:GetSize() return 300 end

if (CLIENT) then
	function ENT:Draw()
		self:DrawModel()
	end
return end

local special_classes = {
	player = function( self, ent, phys, normal, vel )
		if ( ent:GetMoveType() == MOVETYPE_NOCLIP ) then
			ent:SetMoveType( MOVETYPE_WALK )

			local name = "ChangeMoveTypeShield" .. self:EntIndex()
			timer.Remove(name)
			timer.Create(name, 0.5, 1, function()
				if ( IsValid(ent) ) then ent:SetMoveType( MOVETYPE_NOCLIP ) end
			end)
		end

		ent:SetLocalVelocity( normal * -(vel * 10) )
		ent:SetVelocity( normal * -(vel * 10) )
	end,
	grenade_spit = function( self, ent, phys, normal, vel )
		ent:SetLocalVelocity( normal * -vel )
	end,
	grenade_ar2 = function( self, ent, phys, normal, vel )
		ent:SetLocalVelocity( normal * -vel )
	end,
	crossbow_bolt = function( self, ent, phys, normal, vel )
		ent:SetLocalVelocity( normal * -vel )
	end,
	npc_grenade_frag = function( self, ent, phys, normal, vel )
		phys:ApplyForceCenter( normal * -vel )
	end,
	prop_combine_ball = function( self, ent, phys, normal, vel )
		phys:AddVelocity( normal * -vel)
	end,
	rpg_missile = function( self, ent, phys, normal, vel )
		local dmginfo = DamageInfo()
		dmginfo:SetDamage( 1000 )
		dmginfo:SetDamageType( DMG_AIRBOAT )

		ent:SetSaveValue("m_flAugerTime", 0) --this function actually allows it to take damage
		ent:TakeDamageInfo(dmginfo) --
	end
}

function ENT:Initialize()
	self:SetModel( "models/props_borealis/bluebarrel001.mdl" )

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	local brush = ents.Create("shield_brush")

	brush.IsActive = self.GetActive
	brush:IgnoreEntity( self )
	brush.UpdateTransmitState = function() return TRANSMIT_ALWAYS end
	brush.StartTouchFixed = self.StartTouchFixed
	brush.EndTouchFixed = self.EndTouchFixed
	brush.TouchFixed = self.TouchFixed
	brush.BulletCollide = self.BulletCollide
	brush.Reflect = self.Reflect

	brush:Spawn()
	brush:Activate()

	brush:SetSize( 300 )

	self.brush = brush
	self:DeleteOnRemove( brush )

	brush:CallOnRemove("SheildBulletCheck", function( self )
		hook.Remove("SheildBulletCheck" .. self:EntIndex())
	end)

	hook.Add("EntityFireBullets", "SheildBulletCheck" .. brush:EntIndex(), function( entity, bullet )
		if ( !IsValid(brush) ) then return end

		local hit, hitdist = utilx.RayIntersectSphere(  bullet.Src, bullet.Dir, brush:GetPos(), brush:GetSize() )

		if ( !hit ) then return end

		local tr = util.TraceLine({
			start = bullet.Src,
			endpos = bullet.Src + (bullet.Dir * hitdist),
			filter = entity
		})

		if ( tr.Fraction ~= 1 ) then return end

		bullet.HitPos = bullet.Src + (bullet.Dir * hitdist)
		bullet.HitNormal = (brush:GetPos() - bullet.HitPos):GetNormalized()
		bullet.Distance = hitdist

		if ( bullet.Callback ) then
			local dmg = DamageInfo()
			dmg:SetDamage( bullet.Damage or 0 )
			bullet.Callback( self, tr, dmg )
		end

		if ( bullet.Tracer ~= 0 ) then
			local effect = EffectData()
			effect:SetStart( bullet.Src )
			effect:SetOrigin( bullet.HitPos )
			effect:SetScale( 5000 )
			effect:SetNormal( bullet.Dir )

			util.Effect( bullet.TracerName or "Tracer", effect, true, true )
		end

		brush:BulletCollide( bullet )

		return true
	end)
end

function ENT:Think()
	if ( !self.brush ) then return end
	self.brush:SetPos( self:GetPos() )
	self.brush:SetAngles( self:GetAngles() )
	self.brush:CollisionChanged()

	self:NextThink(CurTime())
	return true
end

function ENT:Reflect( ent )
	local phys = ent:GetPhysicsObject()
	local normal = ( self:GetPos() - ent:GetPos() ):GetNormalized()
	local vel = ent:GetVelocity()

	if ( ent:IsPlayerHolding() ) then ent:ForcePlayerDrop() end

	if ( special_classes[ent:GetClass()] ) then
		special_classes[ent:GetClass()]( self, ent, phys, normal, vel )
	elseif ( IsValid(phys) ) then
		phys:Wake()
		phys:EnableMotion( false )
		phys:EnableMotion( true )
		phys:ApplyForceOffset( normal * phys:GetMass() * -5, self:GetPos() )
		phys:AddVelocity( normal * phys:GetMass() * -5 )
		phys:Wake()
	end
end

function ENT:StartTouchFixed( ent )
	self:Reflect( ent )

	local normal = ( self:GetPos() - ent:GetPos() ):GetNormalized()
	local hit, hitdist, hitpos = utilx.RayIntersectSphere(  ent:GetPos(), normal, self:GetPos(), self:GetSize() )

	if (hit) then
		local effect = EffectData()
		effect:SetEntity( self )
		effect:SetOrigin( self:WorldToLocal(hitpos) )
		effect:SetNormal( normal  )
		effect:SetScale( 20 )

		util.Effect( "shield_hit", effect )
	end
end

function ENT:TouchFixed( ent )
	self:Reflect( ent )
end

function ENT:EndTouchFixed( ent ) end

function ENT:BulletCollide( bullet )
	local effect = EffectData()
	effect:SetEntity( self )
	effect:SetOrigin( self:WorldToLocal(bullet.HitPos) )
	effect:SetNormal( bullet.HitNormal  )
	effect:SetScale( math.Clamp( bullet.Damage * 2, 20, 80) )

	util.Effect( "shield_hit", effect )
end

function ENT:PassesTriggerFilters( ent )
	return IsValid(ent) and
		!self:ShouldIgnoreEntity(ent) and
		!ent:IsWorld() and
		ENVIRONMENTS:HasEntity(ent) and
		ent ~= self and
		ent ~= self.brush
end

numpad.Register( "SBShieldEnable", function( ply, ent, keydown, idx )
	if ( !IsValid( ply ) ) then return false end
	if ( !IsValid( ent ) ) then return false end
	if ( ent:GetClass() ~= "sb_shield" ) then return false end

	ent:SetActive( !ent:GetActive() )

	return true
end )
