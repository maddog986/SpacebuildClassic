RS:AddDevice({
	tool = {"Tools"},
	category = "Lights",
	status = true,

	name = "Lamp",
	desc = "Provides light.",
	startsound = "Buttons.snd17",
	stopsound = "Buttons.snd17",
	model = {
		"models/props_wasteland/light_spotlight01_lamp.mdl"
	},
	requires = {
		Energy = CONSUME
	},
	BaseClass = {
		Think = function(self)
			self.BaseClass.Think(self)

			if (!self._rs) then return end

			DoLight( self )

			self.Entity:NextThink(CurTime() + 1)
			return true
		end
	}
})

function DoLight( self )


	if self:IsActive() and not self.light then
		local angForward = self.Entity:GetAngles() + Angle( 0, 0, 0 )

		self.light = ents.Create( "env_projectedtexture" )
		self.light:SetParent( self.Entity )
		self.light:SetLocalPos( Vector( 0, 0, 0 ) + self.Entity:GetUp() * 10 )
		self.light:SetLocalAngles( Angle(0,0,0) )
		self.light:SetKeyValue( "enableshadows", 1 )
		self.light:SetKeyValue( "farz", 2048 )
		self.light:SetKeyValue( "nearz", 8 )
		self.light:SetKeyValue( "lightfov", 100 )
		self.light:SetKeyValue( "lightcolor", "255 255 255 800" )
		self.light:Spawn()
		self.light:Input( "SpotlightTexture", NULL, NULL, "effects/flashlight001" )
	elseif !self:IsActive() && self.light then
		SafeRemoveEntity( self.light )
		self.light = nil
	end

	if self:IsActive() then
		self:SetSkin(2)
	else
		self:SetSkin(1)
	end
end