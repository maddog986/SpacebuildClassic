local playerMeta = FindMetaTable( "Player" )

function playerMeta:staminaCheck()

	if self.staminaUpdate == nil then
	
		self.staminaUpdate = 0
		
	end	
	
	
	if !self:Alive() then self:stopBreathe() end
	
	if self:KeyDown( IN_SPEED ) && self:Alive() && !self:InVehicle() && self:GetVelocity():Length() > 1 && self:GetNWInt( "stamina" ) > 0 then		
	
		self:startSprinting()
		
	else	
	
		self:stopSprinting()

	end
	
end			


function playerMeta:startBreathe()

	if self.breatheSound == nil then
	
		self.breatheSound = CreateSound( self, Sound( "player/breathe1.wav" ) )
		
	end

	if self.breatheSound_playing then return end
	
	self.breatheSound:Play()
	
	self.breatheSound_playing = true

end	


function playerMeta:stopBreathe()

	if self.breatheSound == nil then
	
		self.breatheSound = CreateSound( self, Sound( "player/breathe1.wav" ) )
		
	end
	
	if !self.breatheSound_playing then return end	
	
	self.breatheSound:Stop()
	
	self.breatheSound_playing = false	

end	


function playerMeta:takeStamina()

	if CurTime() > self.staminaUpdate then
	
		local playerStamina = self:GetNWInt( "stamina" ) 		
	
		self:SetNWInt( "stamina", playerStamina - 1 )
		
		self.staminaUpdate = CurTime() + .5
		
	end	

end


function playerMeta:giveStamina()

	if CurTime() > self.staminaUpdate then
	
		local playerStamina = self:GetNWInt( "stamina" ) 	

		if playerStamina < 100 then
	
			self:SetNWInt( "stamina", playerStamina + 1 )
			
			self.staminaUpdate = CurTime() + 1
			
		end	
		
	end	

end


function playerMeta:startSprinting()

	if ( self.canRun ) then
	
		if ( self.staminaSpeed != 300 ) then
	
			GAMEMODE:SetPlayerSpeed( self, 300, 300 )
			self.staminaSpeed = 300
			
		end				

		self:startBreathe()					
		
		self:takeStamina()
		
	end	

end


function playerMeta:stopSprinting()

	if ( self.staminaSpeed != 150 ) then

		GAMEMODE:SetPlayerSpeed( self, 150, 150 )
		self.staminaSpeed = 150
		
	end	

	self:stopBreathe()					
	
	self:giveStamina()

end