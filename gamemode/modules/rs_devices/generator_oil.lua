RS:AddDevice({
	tool = {"Generator"},
	category = "Oil",
	status = true,
	name = "Large Oil Driller",
	desc = "Cores the ground for oil. Used in Petrol production.",
	--startsound = {"Airboat_engine_idle","apc_engine_start"},
	--stopsound = "Airboat_engine_stop",
	model = {
		"models/props_combine/CombineThumper002.mdl"
	},
	resources = {
		Oil = function(self)
			return GENERATE(self) / 20
		end,
	},
	--requires = {
	--	Energy = CONSUME,
	--	Water = CONSUME
	--},
	BaseClass = {
		Think = function(self)
			self.BaseClass.Think(self)

			-- Create a thumper
			if (!self.thumper) then
				self:SetColor( Color(0,0,0,1) )

				self.thumper = ents.Create( "prop_thumper" )
				self.thumper:SetPos( self:GetPos() )
				self.thumper:SetAngles( self:GetAngles() )
				self.thumper:SetModel( self:GetModel() )
				self.thumper:Spawn()
				self.thumper:Activate()
				self.thumper:SetParent( self.Entity )
				self.thumper:Fire("Disable","",0)

				self.thumper:SetMoveType( MOVETYPE_NONE )
				self.thumper:SetSolid( SOLID_NONE )
				self.thumper:SetNotSolid( true )

				self:DeleteOnRemove( self.thumper )

				self.thumper.enabled = 0
			elseif self:IsActive() and self.thumper.enabled == 0 then
				self.thumper:Fire("Enable","",0)
				self.thumper.enabled = 1
			elseif !self:IsActive() and self.thumper.enabled == 1 then
				self.thumper:Fire("Disable","",0)
				self.thumper.enabled = 0
			end

			--if not on ground turn off device
			if (self:IsActive() && !self:GetGroundEntity():IsWorld()) then self:TurnOff() end
		end
	}
})