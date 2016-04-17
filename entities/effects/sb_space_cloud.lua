--[[
	Author MadDog
]]
function EFFECT:Init( data )
	self.Scale = data:GetScale()
	self.Magnitude = self.Scale / 2
	self.Position = data:GetOrigin()
	self.Emitter = ParticleEmitter( self.Position )
	self.Parent = data:GetEntity()

	self.particles = {}
end

function EFFECT:Think()
	if ( !IsValid(self.Parent) ) then self.Emitter:Finish(); return false end
	return true
end

function EFFECT:Render()
	if ( #self.particles > self.Magnitude ) then return end

	local a = math.random(1, 1000)
	local b = math.random(1,180)

	local pos = self.Position + (Vector(math.sin(b)*math.sin(a), math.sin(b)*math.cos(a), math.cos(b)) * VectorRand()) * self.Scale

	local particle = self.Emitter:Add( "particles/smokey", pos )

	if particle then
		particle:SetDieTime( 100 )
		particle:SetStartAlpha( 150 )
		particle:SetEndAlpha( 255 )
		particle:SetStartSize( 512 )
		particle:SetEndSize( 512 )
		particle:SetRoll( math.random(-4,4) )
		particle:SetRollDelta( math.random(-1,1) )
		particle:SetColor( 50, 50, 50 )

		table.insert(self.particles, particle)
	end

	return true
end