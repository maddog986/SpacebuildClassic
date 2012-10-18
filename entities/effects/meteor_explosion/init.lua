function EFFECT:Init( data )
	local vOffset = data:GetOrigin()
	local vScale = data:GetScale()
	local NumParticles = 15 * vScale
	local emitter = ParticleEmitter( vOffset )
		for i=0, (NumParticles / 5) do
			local Pos = Vector( math.Rand(-1,1), math.Rand(-1,1), math.Rand(-1,1) ):GetNormalized()
			local particle = emitter:Add( "particles/smokey", vOffset + Pos * math.Rand(20, 150 ))
			if (particle) then
				particle:SetVelocity( Pos * math.Rand(50, 100) )
				particle:SetLifeTime( 0 )
				particle:SetDieTime( math.Rand( 1, 5 ) )
				particle:SetStartAlpha( math.Rand( 200, 255 ) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( 100 * vScale )
				particle:SetEndSize( 400 )
				particle:SetRoll( math.Rand(0, 360) )
				particle:SetRollDelta( math.Rand(-0.2, 0.2) )
				particle:SetColor( 40 , 40 , 40 )
			end
		end
		for i=0, (NumParticles) do
			local Pos = Vector( math.Rand(-1,1), math.Rand(-1,1), 0 ):GetNormalized()
			local particle = emitter:Add( "particles/flamelet"..math.random(1,5), vOffset + Pos * math.Rand( 75*vScale, 125*vScale )+Vector(0 ,0 ,5))
			if (particle) then
				particle:SetVelocity( Pos * math.Rand(300, 1000) )
				particle:SetLifeTime( 0 )
				particle:SetDieTime( math.Rand( 0.2, 1 ) )
				particle:SetStartAlpha( math.Rand( 200, 255 ) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( 40 * vScale )
				particle:SetEndSize( 0 )
				particle:SetRoll( math.Rand(0, 360) )
				particle:SetRollDelta( math.Rand(-2, 2) )
				particle:SetColor( 255 , 100 , 100 )
			end
		end
		for i=0, (NumParticles * 2) do
			local Pos = Vector( math.Rand(-1,1), math.Rand(-1,1), math.Rand(-1,1) ):GetNormalized()
			local particle = emitter:Add( "particles/flamelet"..math.random(1,5), vOffset + Pos * math.Rand( 1, 25*vScale ))
			if (particle) then
				particle:SetVelocity( Pos + Vector( math.Rand(-1,1), math.Rand(-1,1), math.Rand(0,2)):GetNormalized() * math.Rand(50, 500) )
				particle:SetLifeTime( 0 )
				particle:SetDieTime( math.Rand( 1, 3 ) )
				particle:SetStartAlpha( math.Rand( 200, 255 ) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( 75 * vScale )
				particle:SetEndSize( 0 )
				particle:SetRoll( math.Rand(0, 360) )
				particle:SetRollDelta( math.Rand(-2, 2) )
				local Col = math.Rand(10, 75)
				particle:SetColor( 255 , 255-Col , 255-Col )
			end
			
		end	
	emitter:Finish()
end

function EFFECT:Think( )
	return false
end

function EFFECT:Render()
end