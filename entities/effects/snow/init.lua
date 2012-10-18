
function EFFECT:Init(data)
	self.amount = data:GetMagnitude()
	self.time = CurTime()+1
end

function EFFECT:Emit()
	local emitter = ParticleEmitter(LocalPlayer():GetPos())
	for i=0, math.Round(self.amount) do
		local a = math.random(9999)
		local b = math.random(1,180)
		local dist = math.random(256,2048)
		local X = math.sin(b)*math.sin(a)*dist
		local Y = math.sin(b)*math.cos(a)*dist
		local offset = Vector(X,Y,0)
		local spawnpos = LocalPlayer():GetPos()+Vector(0,0,600)+offset

		if !SB:GetClass( "Environments" ):OnPlanet( spawnpos ) then continue end

		local particle = emitter:Add("particle/snow", spawnpos)
		if (particle) then
			particle:SetLifeTime(math.random(-2,0))
			particle:SetDieTime(math.Clamp((self.amount/80)+math.random(-10,10), 10, 20))
			particle:SetStartAlpha(254)
			particle:SetEndAlpha(254)
			particle:SetStartSize(4)
			particle:SetEndSize(4)
			particle:SetAirResistance(1)
			particle:SetGravity(Vector(0,0,math.random(-125,-50)))
			particle:SetCollide(true)
			particle:SetBounce(.01)
			particle:SetColor(255,255,255,255)
		end
	end
	emitter:Finish()
end

function EFFECT:Think()
	if not (self.time < CurTime()) then
		self:Emit()
	else
		return false
	end
end

function EFFECT:Render()
end