--[[
	Author MadDog
]]
function EFFECT:Init( data )
	self.Magnitude = data:GetMagnitude()
	self.Scale = data:GetScale()
	self.Position = data:GetOrigin()
	self.Emitter = ParticleEmitter( self.Position )
end

function EFFECT:Think()
	if ( self.Emitter:GetNumActiveParticles() < self.Magnitude ) then
		local pos = self.Position + (VectorRand() * self.Scale)
		local particle = self.Emitter:Add( "effects/fire_cloud1", pos )

		if particle then
			particle:SetDieTime( math.random(8, 10) )
			particle:SetStartAlpha( 150 )
			particle:SetEndAlpha( 255 )
			particle:SetStartSize( 512 )
			particle:SetEndSize( 512 )
			particle:SetRoll( math.random(-4,4) )
			particle:SetRollDelta( math.random(-1,1) )
		end
	end

	return true
end