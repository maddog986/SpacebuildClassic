RS:AddDevice({
	tool = {"Mining"},
	category = "Minerals",
	status = true,

	name = "Mineral Laser",
	desc = "Takes minerals out of asteroids.",
	startsound = "Canals.d1_canals_01_chargeloop",
	model = {
		"models/Slyfo/probe2.mdl",
		"models/Slyfo/probe1.mdl"
	},--[[
	requires = {
		Energy = CONSUME
	},]]
	BaseClass = {
		Think = function(self)
			self.BaseClass.Think(self)

			DoMining(self)

			self.Entity:NextThink(CurTime() + 1)
			return true
		end
	}
})

if CLIENT then return end

function DoMining(self)
	if (!self:IsActive()) then return end

	local tr = util.QuickTrace( self.Entity:GetPos(), self.Entity:GetForward() * 500, { self.Entity } )

	local asteroid = tr.Entity

	if (!tr.Hit || !asteroid || !IsValid(asteroid) || !asteroid._rs || !asteroid.IsAsteroid) then
		self:TurnOff()
		return
	end



	local take = self:GetConsumeAmount()
	local stored = asteroid:NodeStoredAmount().Minerals

	if (take == 0 || stored == 0) then
		self:TurnOff()
		return
	end

	if (stored < take) then
		take = stored --take whatever is left
	end

	--add back to rock after a bit
	timer.Simple(math.random(1200, 1800), function()
		if (!IsValid(asteroid) or !asteroid._rs) then return end

		asteroid._rs.stored.Minerals = asteroid._rs.stored.Minerals + take
	end)

	asteroid:CommitResources( {Minerals = -take}, true )

	local effectdata = EffectData()
	effectdata:SetStart( tr.HitPos ) // not sure if we need a start and origin (endpoint) for this effect, but whatever
	effectdata:SetOrigin( tr.HitPos )
	effectdata:SetScale( 1 )
	util.Effect( "HelicopterMegaBomb", effectdata )

	sound.Play("physics/surfaces/sand_impact_bullet" .. math.random(1, 4) .. ".wav", tr.HitPos, 100)

	self:CommitResources({
		Minerals = take
	})


	local effectdata = EffectData()
	effectdata:SetOrigin( tr.HitPos )
	effectdata:SetStart( self.Entity:GetPos()) --move beam start to front of dish
	util.Effect( "ScanBeam", effectdata )
end