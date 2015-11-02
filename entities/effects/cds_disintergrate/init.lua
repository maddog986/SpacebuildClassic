function EFFECT:Init(data)
	self = data:GetEntity()
	if(!self:IsValid()) then return end
	self.mag = math.Clamp(self:BoundingRadius()/8,1,9999999)
	self.dur = data:GetScale()+CurTime()
	self.emitter = ParticleEmitter(self:GetPos())
	self.amp = 255/data:GetScale()
end

function EFFECT:Think()
	if not self:IsValid() then return false end
	local t = CurTime()
	local vOffset = self:GetPos()
	local Low, High = self:WorldSpaceAABB()
	for i=1, self.mag do --don't fuck with this or you FPS dies
		local vPos = Vector(math.random(Low.x,High.x), math.random(Low.y,High.y), math.random(Low.z,High.z))
		local particle = self.emitter:Add("effects/combinemuzzle2", vPos)
		if (particle) then
			particle:SetVelocity(Vector(0,0,0))
			particle:SetLifeTime(0)
			particle:SetDieTime(.5)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(6)
			particle:SetEndSize(6)
			particle:SetRoll(math.random(0, 360))
			particle:SetRollDelta(0)
			particle:SetAirResistance(100)
			particle:SetGravity(Vector(0, 0, 0))
			particle:SetBounce(0.3)
		end
	end
	local tmp2 = math.Clamp(self.amp*((self.dur-t)),0,255)
	self:SetColor(Color(tmp2,tmp2,tmp2,tmp2))
	if not (t < self.dur) then
		self.emitter:Finish()
	end
	return t < self.dur
end

function EFFECT:Render()
end
