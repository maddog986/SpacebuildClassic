
function EFFECT:Init(data)
	self.amount = data:GetMagnitude()
	self.time = CurTime()+1
end

function EFFECT:Emit()
	local emitter = ParticleEmitter(LocalPlayer():GetPos())
	for i=0, self.amount*2 do
		local a = math.random(9999)
		local b = math.random(1,180)
		local dist = math.random(256,2048)
		local X = math.sin(b)*math.sin(a)*dist
		local Y = math.sin(b)*math.cos(a)*dist
		local offset = Vector(X,Y,0)
		local spawnpos = LocalPlayer():GetPos()+Vector(0,0,600)+offset

		--TODO: add a planet check to make sure it doesnt rain in space
		--if !SB:GetClass( "Environments" ):OnPlanet( spawnpos ) then continue end

		local particle = emitter:Add("particle/Water/WaterDrop_001a", spawnpos)
		if (particle) then
			particle:SetVelocity(Vector(math.random(-75,75),math.random(-75,75),0))
			particle:SetLifeTime(0)
			particle:SetDieTime(6)
			particle:SetStartAlpha(150)
			particle:SetEndAlpha(150)
			particle:SetStartSize(4)
			particle:SetEndSize(4)
			particle:SetAirResistance(0)
			particle:SetGravity(Vector(0,0,math.random(-600,-200)))
			particle:SetCollide(true)
			particle:SetBounce(0)
			particle:SetColor(0,0,255,255)
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