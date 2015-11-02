AddCSLuaFile()

ENT.Base = "base_nextbot"

ENT.Model = "models/Humans/Group01/Male_01.mdl"

ENT.WalkSpeed = 100
ENT.WalkAct = ACT_WALK

ENT.ChaseSpeed = 200
ENT.ChaseAct = ACT_HL2MP_RUN_FAST

ENT.NPCHealth = 20
ENT.AttackRange = 60

ENT.DeathSound = Sound("NPC_MetroPolice.Die")
ENT.HurtSound = Sound("NPC_MetroPolice.Pain")
ENT.AlertSound = Sound("NPC_MetroPolice.Attack")
ENT.MissSound = Sound("NPC_MetroPolice.AttackMiss")
ENT.HitSound = Sound("NPC_MetroPolice.AttackHit")
ENT.IdleSounds = {Sound("NPC_MetroPolice.Idle")}


function ENT:Initialize()
	if( CLIENT ) then return end

	self:SetCollisionBounds(Vector(-12,-12,0),Vector(12,12,64))

	self:SetModel( self.Model )

	self.Attacking = true

	self:StartActivity( ACT_WALK )
	self.WalkAct = math.random( 1628, 1631 )

	self:SetHealth(self.NPCHealth)

	self.NextAmble=0

	self:FindTarget()


	--self:GiveWeapon("weapon_smg1")
end

function ENT:PathDistanceToPos( pos )
	return ( self:GetPos() - pos ):Length()
end

ENT.Targets = {}
ENT.NextTargetFind = 0

function ENT:FindTarget()
	local target
	local lastdis = 0

	if self.NextTargetFind < CurTime() then
		self.NextTargetFind = CurTime() + math.random(1,2)

		for _, ent in pairs( player.GetAll() ) do
			if (!ent:IsValid() or !ent:Alive()) then continue end

			local pos = ent:GetPos()
			local dis = self:PathDistanceToPos( pos )

			if( lastdis < dis ) then
				lastdis = dis
				target = ent
			end
		end

		self.Target = target

		self.targetname=target:GetClass().."_"..tostring(target:EntIndex())
		self:SetKeyValue("targetname",self.targetname)
	end
end

function ENT:HandleStuck()
	self:SetPos(self:GetPos()+Vector(math.random(-32,32),math.random(-32,32),math.random(0,10)))

	if not self.loco:IsStuck() then
		self:ClearStuck()
	end

	coroutine.yield()
end

function ENT:OnInjured(dmginfo)
	if math.random(1,2) == 1 then
		self:EmitSound(self.HurtSound)
	end

	self:Injured(dmginfo)
end

function ENT:Injured()
end

function ENT:OnKilled(dmginfo)
	self:Killed(dmginfo)
	self:EmitSound(self.DeathSound)
	self:BecomeRagdoll(dmginfo)
end

function ENT:Killed(dmginfo)
	--override
end

function ENT:OnOtherKilled(dmginfo)
end

function ENT:OnLandOnGround() end

function ENT:ShouldChase(entity)
	return self.Attacking and not self:EnemyInRange()
end

function ENT:MoveToPos( pos, optons )
	local options = options or {}
	local path = Path( "Follow" )
	path:SetMinLookAheadDistance( options.lookahead or 300 )
	path:SetGoalTolerance( options.tolerance or 20 )
	path:Compute( self, pos )

	if( !path:IsValid() ) then return "failed" end

	while ( path:IsValid() ) do
		if( !self.Target or !self.Target:IsValid() ) then return "lost target" end

		path:Update( self )

		-- Draw the path (only visible on listen servers or single player)
		if ( options.draw ) then
			path:Draw()
		end

		-- If we're stuck then call the HandleStuck function and abandon
		if ( self.loco:IsStuck() ) then
			self:HandleStuck()
			return "stuck"
		end

		-- If they set maxage on options then make sure the path is younger than it
		if ( options.maxage ) then
			if ( path:GetAge() > options.maxage ) then return "timeout" end
		end

		-- If they set repath then rebuild the path every x seconds
		if ( options.repath ) then
			if ( path:GetAge() > options.repath ) then path:Compute( self, pos ) end
		end

		coroutine.yield()
	end

	return "ok"
end

function ENT:GetEnemy(ent)
	return self.Target
end

function ENT:TargetDistance()
	return (self:GetRangeSquaredTo(self.Target) <= self.AttackRange)
end

function ENT:EnemyInRange()
	if not IsValid(self.Target) then return end

	if self.Target.Alive and not self.Target:Alive() then return end

	return self:TargetDistance()
end

ENT.NextCheckEnemy = 0


function ENT:Chase( ent )
	local pos = ent:GetPos()
	local path = Path( "Follow" )
	path:SetMinLookAheadDistance( 0 )
	path:SetGoalTolerance( 20 )
	path:Compute( self, pos )

	if( !path:IsValid() ) then return "failed" end

	while( path:IsValid() and !self:EnemyInRange() ) do
		if( !ent or !ent:IsValid() ) then return "lost target" end

		path:Update( self )
		path:Draw()

		self:FindTarget()

		local dist = ( pos - self:GetPos() ):Length();

		if( dist > 1500 and path:GetAge() > 1 ) then
				path:Compute( self, pos );
		elseif( dist <= 1500 and path:GetAge() > 0.3 ) then
				path:Compute( self, pos );
		end

		if (!IsValid(ent)) then
			return "lost targets"
		else
			pos = ent:GetPos()
		end

		coroutine.yield();
	end

	return "ok"
end

function ENT:Think()
	self.NextThink = CurTime() + 0.1

	self:FindTarget()
end

function ENT:RunBehaviour()

	while ( true ) do

		if (!self.Target) then
			self:StartActivity( ACT_WALK )
			self.loco:SetDesiredSpeed( self.WalkSpeed )
			self:Wander() --walk around
		else
			if self:EnemyInRange() then
				self.loco:FaceTowards( self.Target:GetPos() )

				self:StartActivity( ACT_WALK )

				--self:RestartGesture( ACT_GMOD_GESTURE_RANGE_ZOMBIE )
			else
				--chase
				self:StartActivity( ACT_RUN )
				self:SetSequence( "WalkUnarmed_All" )
				self.loco:SetDesiredSpeed( self.ChaseSpeed )
				self:Chase( self.Target )
			end
		end

		coroutine.yield()
	end
end
function ENT:BodyUpdate()

	local act = self:GetActivity()
	local seq = self:GetSequenceName( self:GetSequence() )
	if ( act == ACT_RUN || act == ACT_HL2MP_RUN_FIST || act == ACT_HL2MP_RUN_FAST || seq == "zombie_run" ) then
		self:BodyMoveXY()
	end
	self:FrameAdvance()

end
function ENT:Wander()
	self:MoveToPos( self:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 200 ) -- walk to a random place within about 200 units (yielding)
end

function ENT:MeleeAttack( dmg, reach )




end




















function ENT:GiveWeapon(wep)

	local wep = ents.Create(wep)
	local pos = self:GetAttachment(self:LookupAttachment("anim_attachment_RH")).Pos
	wep:SetOwner(self)
		wep:SetPos(pos)

		wep:Spawn()
		wep.DontPickUp = true
		wep:SetSolid(SOLID_NONE)

		wep:SetParent(self)

		wep:Fire("setparentattachment", "anim_attachment_RH")
		wep:AddEffects(EF_BONEMERGE)

	self.Weapon = wep




end



function ENT:FireWeapon()
	local bullet = {}
					bullet.Num = self.Primary.NumberofShots
					bullet.Src = self.Owner:GetShootPos()
					bullet.Dir = self.Owner:GetAimVector()
					bullet.Spread = Vector( self.Primary.Spread * 0.1 , self.Primary.Spread * 0.1, 0)
					bullet.Tracer = 1
					bullet.TracerName = "Tracer"
					bullet.Force = self.Primary.Force
					bullet.Damage = math.random(20,24)
					bullet.AmmoType = self.Primary.Ammo


	self:FireBullets(bullet)

end
























--[[

ENT.FeetBones = {
    ["left"] = "ValveBiped.Bip01_L_Foot",
    ["right"] = "ValveBiped.Bip01_R_Foot",
}

ENT.FeetOnGround = {
    ["left"] = false,
    ["right"] = false,
}

ENT.StepSound = "npc/dog/dog_footstep1.wav"

function ENT:Think()
    if !IsValid(self) then return end
    if !self.nxtThink then self.nxtThink = 0 end
    if CurTime() < self.nxtThink then return end

    self.nxtThink = CurTime() + 0.025

    for k, v in pairs(self.FeetBones) do
        if type(v) != "string" then continue end
        local bId = self:LookupBone(v)

        if !bId then continue end

        local pos, ang = self:GetBonePosition(bId)

        local eAng = self:GetAngles()

        local tr = {}
        tr.start = pos //- ang:Forward()*4 + ang:Right()*4
        tr.endpos = tr.start - ang:Right()*5 + ang:Forward()*10
        tr.filter = self
        tr = util.TraceLine(tr)

        if tr.Hit && !self.FeetOnGround[k] then
            self:EmitSound(self.StepSound)
            //print("Poof!")
        end

        self.FeetOnGround[k] = tr.Hit
        //print("Hit? " .. tostring(tr.Hit))
    end
end











if SERVER then
    function IsNPC()
        local name = self:GetClass()

        if string.lower( string.sub(name, 1, 4) ) == "npc_" then
            return true
        else
            return false
        end
    end
    function giveNPCWeapon(ent, class)
        if !IsValid(ent) || !ent:IsNPC() then return end

        local att = "anim_attachment_RH"
        local shootpos = ent:GetAttachment(ent:LookupAttachment(att))

        local wep = ents.Create(class)
        wep:SetOwner(ent)
        wep:SetPos(shootpos.Pos)
        --wep:SetAngles(ang)
        wep:Spawn()

        wep:SetSolid(SOLID_NONE)


        wep:SetParent(ent)

        wep:Fire("setparentattachment", "anim_attachment_RH")
        wep:AddEffects(EF_BONEMERGE)
        wep:SetAngles(ent:GetForward():Angle())

        ent.Weapon = wep
    end
    function fireNPCWeapon(ent)
        if !IsValid(ent) || !ent.Weapon then return end
        local wep = ent.Weapon

        local muzzle = wep:GetAttachment(wep:LookupAttachment("muzzle"))
        local spread = .1

        local shootPos = muzzle.Pos

        local bullet = {}
            bullet.Num = 1
            bullet.Src = shootPos
            bullet.Dir = ent:GetForward() -- ENT:GetAimVector() equivalent
            bullet.Spread = Vector( spread * 0.1 , spread * 0.1, 0)
            bullet.Tracer = 1
            bullet.TracerName    = "Tracer"
            bullet.Force = 50
            bullet.Damage = 18
            bullet.AmmoType = "Pistol"

        wep:FireBullets(bullet)
        --print("Fired bullets")

    end
end

]]