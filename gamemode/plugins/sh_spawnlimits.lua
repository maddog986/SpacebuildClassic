--[[
	Author: MadDog (steam id md-maddog)
]]

local LIMITS = {
	--plugin info
	Name = "Limits",
	Description = "Plugin that sets some limits to help keep the server more stable.",
	Author = "MadDog",
	Version = 12272015, --should always be a date format mmddyyyy

	--settings
	CVars = {
		--server setting
		"sb_limits_props" = { server = true, text = "Prop Limit Per Player", default = 100 },
		"sb_limits_maxsize" = { server = true, text = "Prop Size Limit", default = 400, min = 100, max = 2000 },
		"sb_limits_maxvelocity" = { server = true, text = "Max Prop Speed Velocity", default = 2000, min = 1500, max = 4000 },
		"sb_limits_maxanglevelocity" = { server = true, text = "Max Prop Angle Velocity", default = 2000, min = 1500, max = 4000 },
		"sb_limits_bannedchars" = { server = true, text = "Player Name Banned Characters or Words. Seperate using semi-colon (;).", default = "", editable = true }
	}
}

function GM:PlayerAuthed( ply, SteamID )
	if ( !ply:find("[A-Za-z1-9][A-Za-z1-9][A-Za-z1-9][A-Za-z1-9]") ) then
		ply:Kick( "A minimum of 4 alphanumeric characters is required in your name to play here." )
	
	elseif ( ply:Name():find(self:GetSetting("sb_limits_bannedchars")) ) then
		ply:Kick( "Your name has banned characters. Banned list: " .. self:GetSetting("sb_limits_bannedchars") )
	end
end

function LIMITS:PlayerSpawnProp( ply, model )
	-- Escape the bad characters from the model.
	model = model:gsub("\\", "/"):gsub("//", "/")

	if ( !util.IsValidModel(model) ) then
		--ply:Notify("That's not a valid model!",1)

		return false
	elseif ( !ply:IsAdmin() ) then 
		local props = 0

		for _, ent in pairs( ents.GetAll() ) do
			if ( ent:GetCreator() == ply ) then props = props + 1 end
		end

		if ( props > self:GetSetting("Prop Limit") ) then
			--ply:Notify("You hit the prop limit!",1)
			
			return false
		end
	end

	if ( !ply:IsAdmin() ) then
		local ent = ents.Create("prop_physics")
		ent:SetModel(model)
		local radius = ent:BoundingRadius()
		ent:Remove()

		if ( radius > self:GetSetting("sb_limits_maxsize") ) then
			--ply:Notify("That prop is too big!",1)

			return false
		end
	end
end

function LIMITS:Think()
	self.NextThink = CurTime() + 0.5

	local maxvel = self:GetSetting("sb_limits_maxvelocity")
	local maxanglevel = self:GetSetting("sb_limits_maxanglevelocity")

	for _, ent in pairs( ents.GetAll() ) do
		local phys = ent:GetPhysicsObject()
		if ( !IsValid(phys) ) then continue end

		local vel = phys:GetVelocity()
		local angvel = phys:GetAngleVelocity()

		if ( !util.IsInWorld(ent:GetPos()) ) then --rebound back into the world
			phys:ApplyForceCenter( -vel * (phys:GetMass() * 100) )
		
		elseif ( vel > maxvel ) then
			phys:ApplyForceCenter( -vel * 0.5 ) --slow down

		elseif ( angvel > maxanglevel ) then
			phys:EnableMotion( false )
			phys:EnableMotion( true )

			phys:AddAngleVelocity( -angvel * 0.5 )  --slow down 
		end

	end
end