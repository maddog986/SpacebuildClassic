include("shared.lua")

--[[
function ENT:Draw()
	local scale = Vector(1,1,1) * self:GetRadius() * 0.09

	self:SetModelScale(scale)

	self:DrawModel()
end
]]
function ENT:RenderSunbeams()
	local radius = self:GetRadius() * 2
	local pos = self:GetPos()
	local BeamRadius = radius * 6

	if true then return end

	if !(pos - EyePos()) then return end
	if (!EyeAngles():Forward()) then return end

	-- calculate brightness.
	local dot = math.Clamp( EyeAngles():Forward():DotProduct( ( pos - EyePos() ):Normalize() ), 0, 1 )
	local dist = ( pos - EyePos() ):Length()

	-- draw sunbeams.
	local sunpos = EyePos() + ( pos - EyePos() ):Normalize() * ( dist * 0.5 )
	local scrpos = sunpos:ToScreen()

	if( dist <= BeamRadius && dot > 0 ) then
		local frac = ( 1 - ( ( 1 / ( BeamRadius ) ) * dist ) ) * dot

		-- draw sun.
		DrawSunbeams(0.65, frac, 0.055, scrpos.x / ScrW(), scrpos.y / ScrH())
        end

	-- calculate brightness.
	local dot = math.Clamp( EyeAngles():Forward():DotProduct( ( pos - EyePos() ):Normalize() ), 0, 1 )
	local dist = pos:Distance(EyePos())

	-- can the sun see us?
	local trace = {
		start = pos,
		endpos = EyePos(),
		filter = LocalPlayer(),
	}

	local tr = util.TraceLine( trace )

	-- draw!
	if (dist <= radius && dot > 0 && tr.Fraction >= 1) then
		-- calculate brightness.
		local frac = ( 1 - ( ( 1 / radius ) * dist ) ) * dot

		-- draw bloom.
		DrawBloom(0.428,3 * frac,15 * frac, 15 * frac,5,0,1,1,1)

		-- draw color.
		local tab = {
			['$pp_colour_addr']		= 0.35 * frac,
			['$pp_colour_addg']		= 0.15 * frac,
			['$pp_colour_addb']		= 0.05 * frac,
			['$pp_colour_brightness']	= 0.8 * frac,
			['$pp_colour_contrast']		= 1 + ( 0.15 * frac ),
			['$pp_colour_colour']		= 1,
			['$pp_colour_mulr']		= 0,
			['$pp_colour_mulg']		= 0,
			['$pp_colour_mulb']		= 0,
		}

		-- draw colormod.
		DrawColorModify( tab )
	end
end


