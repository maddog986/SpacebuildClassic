local SoundEffect = Sound("ambient/atmosphere/undercity_loop1.wav")

drive.Register( "drive_shuttle", {
	--
	-- Called on creation
	--
	Init = function( self )
		self.CameraDist 	= 200
		self.CameraDistVel 	= 0.1
	end,

	--
	-- Calculates the view when driving the entity
	--
	CalcView =  function( self, view )

		--
		-- Use the utility method on drive_base.lua to give us a 3rd person view
		--
		local idealdist = math.max( 10, self.Entity:BoundingRadius() ) * self.CameraDist

		self:CalcView_ThirdPerson( view, idealdist, 2, { self.Entity } )

		--view.angles.roll = 0
	end,


	--
	-- Called before each move. You should use your entity and cmd to
	-- fill mv with information you need for your move.
	--
	StartMove =  function( self, mv, cmd )

		--
		-- Set the observer mode to chase so that the entity is drawn
		--
		self.Player:SetObserverMode( OBS_MODE_CHASE )

		--
		-- Use (E) was pressed - stop it.
		--
		if ( mv:KeyReleased( IN_USE ) ) then
			self:Stop()
		end

		--
		-- Update move position and velocity from our entity
		--
		mv:SetOrigin( self.Entity:GetNetworkOrigin() )
		mv:SetVelocity( self.Entity:GetAbsVelocity() )
		mv:SetMoveAngles( mv:GetAngles() )		-- Always move relative to the player's eyes

		local angles = mv:GetAngles()

		angles.roll = self.Entity:GetAngles().roll

		local speed = 0.5 * FrameTime()
		if ( mv:KeyDown( IN_SPEED ) ) then speed = 0.5 * FrameTime() end

		if ( mv:KeyDown( IN_MOVELEFT ) ) then
			self.RollSpeed = self.RollSpeed + speed
		elseif ( mv:KeyDown( IN_MOVERIGHT ) ) then
			self.RollSpeed = self.RollSpeed - speed
		else
			self.RollSpeed = 0
		end
		--MsgN("self.RollSpeed: ", self.RollSpeed)

		angles.roll = angles.roll + self.RollSpeed

		mv:SetAngles( angles )

		if self.Sound then
			self.Sound:ChangePitch(math.Clamp(self.Entity:GetVelocity():Length()/5,100,200),0.001)
		end
	end,

	--
	-- Runs the actual move. On the client when there's
	-- prediction errors this can be run multiple times.
	-- You should try to only change mv.
	--
	Move = function( self, mv )

		--
		-- Set up a speed, go faster if shift is held down
		--
		local speed = 0.0005 * FrameTime()
		if ( mv:KeyDown( IN_SPEED ) ) then speed = 0.005 * FrameTime() end

		--
		-- Get information from the movedata
		--
		local ang = mv:GetMoveAngles()
		local pos = mv:GetOrigin()
		local vel = mv:GetVelocity()

		--
		-- Add velocities. This can seem complicated. On the first line
		-- we're basically saying get the forward vector, then multiply it
		-- by our forward speed ( which will be > 0 if we're holding W, < 0 if we're
		-- holding S and 0 if we're holding neither ) - and add that to velocity.
		-- We do that for right and up too, which gives us our free movement.
		--
		vel = vel + ang:Forward() * mv:GetForwardSpeed() * speed
		--vel = vel + ang:Right() * mv:GetSideSpeed() * speed
		vel = vel + ang:Up() * mv:GetUpSpeed() * speed

		self.Sound:ChangePitch(math.Clamp(vel:Length() * 50,100,200),0.001)

		--
		-- We don't want our velocity to get out of hand so we apply
		-- a little bit of air resistance. If no keys are down we apply
		-- more resistance so we slow down more.
		--

		if (self.Entity:GetGravity() > 0 ) then
			vel = vel * 0.90
		else
			vel = vel * 0.99
		end

		--movement
		mv:SetVelocity( vel )
		mv:SetOrigin( pos + vel )
	end

}, "drive_sandbox" )



concommand.Add("drive_shuttle", function( ply )
	if (IsValid(ply:GetVehicle())) then
		drive.PlayerStopDriving( ply )

		return
	end

	local ent = ply:GetEyeTrace().Entity

	if (!IsValid(ent)) then return end

	drive.PlayerStartDriving( ply, ent, "drive_shuttle" )
end)