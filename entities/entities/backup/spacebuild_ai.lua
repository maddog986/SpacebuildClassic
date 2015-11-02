AddCSLuaFile()

ENT.Base = "base_nextbot"

ENT.Model = "models/Zombie/Classic.mdl"

ENT.WalkSpeed = 80
ENT.ChaseSpeed = 60

ENT.MaxHealth = 200

ENT.AttackRange = 40
ENT.MaxEnemyDistance = 600

function ENT:Initialize()
	if( CLIENT ) then return end

	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	self:SetCollisionBounds(Vector(-12,-12,0),Vector(12,12,64))

	self:SetModel( self.Model )
	self:StartActivity( ACT_WALK )

	self:SetHealth( self.MaxHealth )

	--self:StartActivity(ACT_HL2MP_ZOMBIE_SLUMP_IDLE)
	--self:EmitSound( "npc/zombie/moan_loop" .. math.random(1, 3) .. ".wav", math.random(80,110) )
end




--[[

	Enemy Functions

]]
function ENT:GetEnemy()
	return self.Enemy
end

function ENT:SetEnemy( ent )
	self.Enemy = ent
end

ENT.NextEnemyFind = 0

function ENT:FindEnemy()
	if self.NextEnemyFind > CurTime() then return end

	self.NextEnemyFind = CurTime() + math.random(1,2)

	local Enemy = Entity(1)

	if (Enemy != self.Enemy) then
		--self:OnNewEnemy()
	end
end

function ENT:HasEnemy()
	return IsValid(self.Enemy) and self.Enemy:Alive()
end

function ENT:EnemyDistance()
	return self:GetRangeSquaredTo(self.Enemy) or 0
end

function ENT:OnNewEnemy()
	self:EmitSound( "npc/zombie/zombie_alert" .. math.random(1, 3) .. ".wav" )
end



function ENT:EnemyWithinDistance()
	return (self.MaxEnemyDistance > self:EnemyDistance())
end

function ENT:EnemyWithinAttachDistance()
	return (self.AttackRange > self:EnemyDistance())
end


ENT.TakeDamageAmount = 0

function ENT:OnInjured( dmginfo )
	self:EmitSound( "npc/zombie/zombie_pain" .. math.random(1, 6) .. ".wav" )

	self.TakeDamageAmount = dmginfo:GetDamage()

	if IsValid(dmginfo:GetAttacker()) and dmginfo:GetAttacker():IsPlayer() then
		self:SetEnemy( dmginfo:GetAttacker() )
	end
end

function ENT:Injured()
end

function ENT:OnTakeDamage( dmginfo )

end

function ENT:IsInjured()
	return (self.TakeDamageAmount > 0)
end

function ENT:OnKilled(dmginfo)
	self:Killed(dmginfo)
	self:EmitSound( "npc/zombie/zombie_die" .. math.random(1, 3) .. ".wav" )
	self:BecomeRagdoll(dmginfo)
end

function ENT:Killed(dmginfo)
	--override
end










--[[

	MOVE FUNCTIONS

]]





--chases the Enemy
function ENT:ChaseEnemy()
	local pos = self:GetEnemy():GetPos()
	local path = Path( "Follow" )
	path:SetMinLookAheadDistance( 0 )
	path:SetGoalTolerance( 20 )
	path:Compute( self, pos )

	if( !path:IsValid() ) then return "failed" end

	while( path:IsValid() and self:HasEnemy() and self:EnemyWithinDistance() ) do
		if( !IsValid(self:GetEnemy()) ) then return "lost enemy" end
		if ( self:IsInjured() ) then return "injured" end

		if self:EnemyWithinAttachDistance() then
			return "ok"
		end

		path:Update( self )
		path:Draw()

		-- If we're stuck then call the HandleStuck function and abandon
		if ( self:IsStuck() ) then
			path:Invalidate()
			self:HandleStuck()
			return "stuck"
		end

		local maxageScaled=math.Clamp(self:GetEnemy():GetPos():Distance(self:GetPos())/1000,0.1,3)
		self:MoveToPos(self.Enemy:GetPos(),{maxage=maxageScaled})

		if ( path:GetAge() > maxageScaled ) then path:Compute( self, pos ) end

		coroutine.yield();
	end

	return "ok"
end


function ENT:MoveToPos( pos, options )
	local pathnodes = NODES:Compute( self, pos )

	if (!pathnodes) then return end

	local options = options or {}

	local i = 0

	for _, node in pairs( pathnodes ) do
		i = i + 1

		if (self:IsStuck() or self.stuck) then return end

		--MsgN("-------Moving to node ", i, " distance: ", node.pos:Distance(self:GetPos()))

		self:SilentMoveToPos( node.pos, options )
	end
end

local lastposvec = Vector(0,0,0)

function ENT:SilentMoveToPos( pos, options )
	--MsgN("SilentMoveToPos: ", pos)

	local path = Path( "Follow" )
	path:SetMinLookAheadDistance( options.lookahead or 0 )
	path:SetGoalTolerance( options.tolerance or 40 )
	path:Compute( self, pos )

	if ( !path:IsValid() ) then return "failed" end

	local lastpos = lastposvec

	while ( path:IsValid() ) do
		--MsgN(CurTime())

		if ( self:IsInjured() ) then return "injured" end

		path:Update( self )

		-- Draw the path (only visible on listen servers or single player)
		path:Draw()

		-- If we're stuck then call the HandleStuck function and abandon
		if ( self:IsStuck() ) then
			path:Invalidate()
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


ENT.NextStuckThinkTime = 0

function ENT:IsStuck()
	if (self.loco:IsStuck()) then return true end

	if (self.NextStuckThinkTime > CurTime()) then return self.stuck end
	self.NextStuckThinkTime = CurTime() + 0.05

	local trace = util.TraceHull({
		start = self:GetPos(),
		endpos = self:GetPos(),
		ignoreworld = true,
		filter = self,
		mins = self:OBBMins(),
		maxs = self:OBBMaxs()
	})

	self.stuck = trace.Entity:IsValid()

	return self.stuck
end

--attemp to get bot unstuck by setting random pos
function ENT:HandleStuck()
	--MsgN("bot stuck")
	MsgN("HandleStuck")

	self.loco:Jump()
	self:SetPos( self:FindGoodSpot() )
	self.stuck = false

	self.loco:ClearStuck()

	coroutine.yield()
end

function ENT:OnLandOnGround()
	self:StartActivity( ACT_WALK )
end

function ENT:FindGoodSpot( counter )
	counter = (counter or 0) + 1

	local trace = util.TraceHull({
		start = self:GetPos(),
		endpos = self:GetPos() + (self:OBBMins() * 5),
		ignoreworld = false,
		filter = self,
		mask = MASK_PLAYERSOLID,
		mins = self:OBBMins(),
		maxs = self:OBBMaxs()
	})

	if ( trace.Hit and counter < 6 ) then
		return self:FindGoodSpot(trace.HitPos, counter)
	end

	return trace.endpos
end

--check for what bot should be doing
function ENT:RunBehaviour()

	while ( true ) do
		if ( !self.Awake ) then
			self.Awake = true


			--self:PlaySequenceAndWait("slumprise_a",1)

			--if ( math.random(1, 2) == 1 ) then


			--else
			--	self:PlaySequenceAndWait("slumprise_b")
			--end
		end

		if ( self:IsInjured() ) then
			self.TakeDamageAmount = 0

			self:EmitSound("npc/zombie/zombie_pain" .. math.random(1, 3) .. ".wav")

			if ( math.random(1, 20) >= 18 ) then
				self:PlaySequenceAndWait("physflinch" .. math.random(1, 3))

				self:EmitSound("npc/zombie/zombie_alert" .. math.random(1, 3) .. ".wav")
				self:PlaySequenceAndWait("Tantrum")
			end
		end

		--if ( self:IsStuck() ) then
		--	self:PlaySequenceAndWait("WallPound")
		--end



		-- just idle
		if (!self:HasEnemy()) then
			--self:StartActivity( ACT_WALK )
			self.loco:SetDesiredSpeed( self.WalkSpeed )

			--MsgN("Wander ", self:GetPos(), " ", self.RandomSpot)

			--if (!self.RandomSpot or self:GetPos() == self.RandomSpot) then
			self.RandomSpot = self:FindSpot( "near", { type = 'hiding', radius = 5000 } )

			if (!self.RandomSpot) then return end --no spots found, oh-no!
			--end

			--walk around randomly
			--self:MoveToPos( self:GetPos() + Vector( math.Rand( -1, 1 ), math.Rand( -1, 1 ), 0 ) * 200 ) -- walk to a random place within about 200 units (yielding)

			if (self.RandomSpot:Distance( self:GetPos() ) < 100) then
				self:StartActivity( ACT_IDLE )
			else
				self:StartActivity( ACT_WALK )
				self:MoveToPos( self.RandomSpot )
			end

		else
			self:StartActivity( ACT_WALK )
			self.loco:FaceTowards( self.Enemy:GetPos() )

			--we have an enemy and within distance to attack
			if self:EnemyWithinAttachDistance() then
				self:AttackMelee()
			--run after enemy
			else
				self.loco:SetDesiredSpeed( self.ChaseSpeed )
				self:ChaseEnemy()
			end
		end

		coroutine.yield()
	end
end

function ENT:OnContact( ent )
	--only looking for doors at this point
	if ( !string.match(ent:GetClass(),"door") ) then return end

	self:PlaySequenceAndWait("WallPound")

	ent:Fire("Open")
end


function ENT:AttackMelee()
	if (math.random(1, 3) >= 2) then
		self:StartActivity( ACT_MELEE_ATTACK1 )
	else
		self:StartActivity( ACT_MELEE_ATTACK2 )
	end

	local offset=Vector(0,0,50)
	local tr = util.TraceHull({
		start = self:GetPos() + offset,
		endpos = self:GetPos() + (self:EyeAngles():Forward()*70) + offset,
		filter = self
	})

	MsgN("trace: ", tr.Hit, tr.Entity)

	local hitEnemy = ( IsValid( tr.Entity ) and tr.Entity == self:GetEnemy() )

	if hitEnemy then
		local dmginfo = DamageInfo()
		dmginfo:SetDamagePosition(self:GetPos()+Vector(0,0,50))
		dmginfo:SetDamage(0) --damageless atm
		dmginfo:SetDamageType( DMG_SLASH )
		dmginfo:SetAttacker( self )
		self:GetEnemy():TakeDamageInfo(dmginfo)
	end

	coroutine.wait(0.9)

	if (hitEnemy) then
		self:GetEnemy():ViewPunch( Angle( 0, 16, 0 ) )
		self:EmitSound("npc/zombie/claw_strike" .. math.random(1, 3) .. ".wav")
	else
		self:EmitSound("npc/zombie/claw_miss" .. math.random(1, 2) .. ".wav")
	end

	coroutine.wait(0.1)
end





ENT.NextThinkTime = 0

function ENT:Think()
	if (self.NextThinkTime >= CurTime()) then return end

	self.NextThinkTime = CurTime() + math.random(0.025)

	self:FindEnemy() --keep checking for Enemys


	-- First Step
        local bones = self:LookupBone("ValveBiped.Bip01_R_Foot")

        local pos, ang = self:GetBonePosition(bones)

        local tr = {}
        tr.start = pos
        tr.endpos = tr.start - ang:Right()*5 + ang:Forward()*4
        tr.filter = self
        tr = util.TraceLine(tr)

        if tr.Hit && !self.FeetOnGround then
		self:EmitSound("npc/zombie/foot"..math.random(3)..".wav", 70)
        end

        self.FeetOnGround = tr.Hit

	-- Second Step
		local bones2 = self:LookupBone("ValveBiped.Bip01_L_Foot")

        local pos2, ang2 = self:GetBonePosition(bones2)

        local tr = {}
        tr.start = pos2
        tr.endpos = tr.start - ang2:Right()*5 + ang2:Forward()*4
        tr.filter = self
        tr = util.TraceLine(tr)

        if tr.Hit && !self.FeetOnGround2 then
		self:EmitSound("npc/zombie/foot"..math.random(3)..".wav", 70)
        end

        self.FeetOnGround2 = tr.Hit

end

















ENT.Category		= "SNPCs"

local Category = "SNPCs"
local NPC = { 	Name = "Spacebuild AI",
				Class = "spacebuild_ai",
				Category = Category}

list.Set("NPC", NPC.Class, NPC)