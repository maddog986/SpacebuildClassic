--[[
	Author MadDog
]]
local beamM = Material("cable/blue_elec")
local beamSize = 3
local beamColor = Color(255, 255, 255 )

function EFFECT:Init( data )
	--data:GetOrigin()
	--data:GetStart()
	--data:GetScale()
	--data:GetMagnitude()
	--data:GetAngle()
	--data:GetRadius()
end

local function hermite( a, b, c, d, t, tens, bias)
	local t2 = t*t
	local t3 = t2*t
   	local a0 = (b-a)*(1+bias)*(1-tens)/2 + (c-b)*(1-bias)*(1-tens)/2
   	local a1 = (c-b)*(1+bias)*(1-tens)/2 + (d-c)*(1-bias)*(1-tens)/2
  	local b0 = 2*t3 - 3*t2 + 1
   	local b1 = t3 - 2*t2 + t
   	local b2 = t3 - t2
   	local b3 = -2*t3 + 3*t2
   	return b0 * b + b1 * a0 + b2 * a1 + b3 * c
end

function EFFECT:Think( )
end

function EFFECT:Render( )
	render.SetMaterial( beamM )
	render.StartBeam( #self.positions )

	for row, vec in pairs( self.positions ) do
		render.AddBeam(vec + ((vec-self.positions[row]) * 5), math.random(3.1, 4.1), 1, beamColor)
	end

	render.EndBeam()

	if (self.positons_update_sound < CurTime()) then
		self.positons_update_sound = CurTime() + 0.45
		self:EmitSound("npc/scanner/scanner_electric1.wav", math.random(50, 75), math.random(90, 100))
	end
end