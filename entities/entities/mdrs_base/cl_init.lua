include("shared.lua")

local SHeight = 5
local SWidth = 2.5
local MaxHeight = 25
local MaxWidth = 15

--ENT.newbeams = {}

--[[
local Sprite1 = Material("sprites/sent_ball")
local Sprite2 = Material("sprites/light_glow02_add")
]]

function ENT:Draw( )
	--self.BaseClass.Draw(self)
	if (!self:GetNWBool("Dead")) then
		local spawnTime = self:GetNWFloat("SpawnTime")

		if (spawnTime) then
			local GrowthPercent = (CurTime() - spawnTime) / self:GetNWInt("GrowthTime")

			if GrowthPercent <= 1 then
				local W = SWidth + (GrowthPercent * MaxWidth )
				self.scale = .05 * Vector(W, W, SHeight + (GrowthPercent * MaxHeight))
				self:SetModelScale(self.scale)
			end
		end
	end

	if (self:GetNWFloat("Resize")) and (self:GetNWFloat("Resize") > 0) then
		if (!self.scale) then self.scale = Vector(1, 1, 1) end

		self:SetModelScale(self.scale * self:GetNWFloat("Resize"))
	end

--[[
	--Shield Sprite
	render.SetMaterial(Sprite1)
	render.DrawSprite(self.Entity:GetPos(), 500, 500, Color(125, 125, 125, 40))
	render.SetMaterial(Sprite2)
	render.DrawSprite(self.Entity:GetPos(), 500, 500, Color(128, 255, 255, 255))
]]
	--show title if there is one
	if self.title && self.title != "" && RS.AddWorldTip then
		--if player within distance show title
		if ( LocalPlayer():GetEyeTrace().Entity == self.Entity && EyePos():Distance( self.Entity:GetPos() ) < 300 ) then
			RS.AddWorldTip( self )	--add the title
		end
	end

	self.Entity:DrawModel()	//Draw the model
end

--[[
Additional functions
function ENT:Think() end
function ENT:IsTranslucent() end
function ENT:OnRemove() end
function ENT:OnRestore() end
function ENT:PhysicsCollide( physobj ) end
function ENT:PhysicsUpdate( phys ) end
]]