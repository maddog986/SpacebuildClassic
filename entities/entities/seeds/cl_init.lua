include("shared.lua")

local SHeight = 5
local SWidth = 2.5
local MaxHeight = 25
local MaxWidth = 15

function ENT:Draw()
	if (!self:GetNWBool("Dead")) then
		local growthtime = self:GetNWInt("GrowthTime", 30)

		if (!self.spawnTime) then self.spawnTime = CurTime() end

		local GrowthPercent = (CurTime() - self.spawnTime) / growthtime

		if GrowthPercent <= 1 then
			local W = SWidth + (GrowthPercent * MaxWidth )
			self.scale = .05 * Vector(W, W, SHeight + (GrowthPercent * MaxHeight))
			self:SetModelScale(self.scale)
		end
	end

	if (self:GetNWFloat("Resize")) and (self:GetNWFloat("Resize") > 0) then
		if (!self.scale) then self.scale = Vector(1, 1, 1) end

		self:SetModelScale(self.scale * self:GetNWFloat("Resize"))
	end

	self:DrawModel()
end