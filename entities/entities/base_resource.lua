--[[
	Author: MadDog (steam id md-maddog)
]]
AddCSLuaFile()

DEFINE_BASECLASS( "base_gmodentity" )

ENT.PrintName = "Resource Entity"
ENT.Author	= "MadDog"
ENT.Spawnable = false
ENT.AdminSpawnable = false

ENT.socket_offsets = {}


--[[
function ENT:SetupDataTables()
	local num = 0

	for name, vector in pairs( self.socket_offsets ) do
		self:NetworkVar( "Entity", num, "Socket" .. name )
		num = num + 1
	end
end
]]

if CLIENT then
	local function hermite(startingPoint, startingTangent, endingTangent, endingPoint, time, tension, bias)

		local time2 = time ^ 2
		local time3 = time ^ 3

		local m0 = (startingTangent - startingPoint) * (1 + bias) * (1 - tension) / 2 + (endingTangent - startingTangent) * (1 - bias) * (1 - tension) / 2
		local m1 = (endingTangent - startingTangent) * (1 + bias) * (1 - tension) / 2 + (endingPoint - endingTangent) * (1 - bias) * (1 - tension) / 2

		local a0 = 2 * time3 - 3 * time2 + 1;
		local a1 = time3 - 2 * time2 + time;
		local a2 = time3 - time2;
		local a3 = -2 * time3 + 3 * time2;

		return (a0 * startingTangent + a1 * m0 + a2 * m1 + a3 * endingTangent)

	end

	local beamMaterial = Material("cable/cable2")
	local beamSize = 3
	local beamColor = Color(255, 255, 255 )

	local beamM = Material("cable/blue_elec")

	ENT.positons_update = 0
	ENT.positons_update_sound = 0
	ENT.shocks = false

	function ENT:Draw()
		BaseClass.Draw( self )

		self:DrawModel()

		if (true) then return end

		local updatebounds = false
		local mins, maxs = self:WorldSpaceAABB()

		local segments = 30

		for name, vector in pairs( self.socket_offsets ) do
			if (name == "Energy") then
				beamColor = color_darkgrey
			else
				beamColor = color_green
			end

			render.SetMaterial( beamMaterial )

			if (name == "BaseClass") then continue end

			local othersocket = self:GetNetworkKeyValue( "Socket" .. name )

			if (!othersocket or !IsValid(othersocket)) then continue end

			local startingPoint = self:LocalToWorld(vector[1])
			local endingPoint = othersocket:LocalToWorld(othersocket.socket_offsets[name][1])

			local startingTangent, endingTangent = vector[2], othersocket.socket_offsets[name][2]

			if (type(startingTangent) == "string") then
				if (startingTangent == "forward") then
					startingTangent = self:GetForward() * 100
				elseif (startingTangent == "up") then
					startingTangent = self:GetUp() * 100
				end
			end

			if (type(endingTangent) == "string") then
				if (endingTangent == "forward") then
					endingTangent = othersocket:GetForward() * 100
				elseif (endingTangent == "up") then
					endingTangent = othersocket:GetUp() * 100
				end
			end

			render.DrawSphere(startingPoint, beamSize * 0.8, 5, 10, beamColor)
			render.DrawSphere(endingPoint, beamSize * 0.8, 5, 10, beamColor)

			local position = Vector()
			local positions = {}
			table.insert(positions, startingPoint + (VectorRand() * 1.2))

			render.StartBeam(segments)
			render.AddBeam(startingPoint, beamSize, 1, beamColor)

			mins, maxs = self:GetBounds( startingPoint )

			for segment = 2, segments - 1 do
				local t = 1 / segments * segment

				position.x = hermite(startingPoint.x - startingTangent.x, startingPoint.x, endingPoint.x, endingPoint.x - endingTangent.x, t, -1, 0)
				position.y = hermite(startingPoint.y - startingTangent.y, startingPoint.y, endingPoint.y, endingPoint.y - endingTangent.y, t, -1, 0)
				position.z = hermite(startingPoint.z - startingTangent.z, startingPoint.z, endingPoint.z, endingPoint.z - endingTangent.z, t, -1, 0)

				render.AddBeam(position, beamSize, 1, beamColor)

				table.insert(positions, position + (VectorRand() * 1.2))

				local localpos = self:WorldToLocal(position)

				if (localpos.x < mins.x) then mins.x = localpos.x end
				if (localpos.y < mins.y) then mins.y = localpos.y end
				if (localpos.z < mins.z) then mins.z = localpos.z end

				if (localpos.x > maxs.x) then maxs.x = localpos.x end
				if (localpos.y > maxs.y) then maxs.y = localpos.y end
				if (localpos.z > maxs.z) then maxs.z = localpos.z end
			end

			table.insert(positions, endingPoint + (VectorRand() * 1.2))

			render.AddBeam(endingPoint, beamSize, 1, beamColor)
			render.EndBeam()
		end

		--self:SetRenderBounds(mins, maxs)
--[[
		if (self.positons_update < CurTime()) then
			self.positons_update = CurTime() + 0.12
			self.positions = positions
		end

		if (!self.positions or !self.shocks) then return end

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
	]]
	end

	function ENT:GetBounds( position )
		local mins, maxs = self:OBBMins(), self:OBBMaxs()

		if (position) then
			local pos = self:WorldToLocal( position )

			if (pos.x < mins.x) then mins.x = pos.x end
			if (pos.y < mins.y) then mins.y = pos.y end
			if (pos.z < mins.z) then mins.z = pos.z end
			if (pos.x > maxs.x) then maxs.x = pos.x end
			if (pos.y > maxs.y) then maxs.y = pos.y end
			if (pos.z > maxs.z) then maxs.z = pos.z end
		end

		return mins, maxs
	end
return end