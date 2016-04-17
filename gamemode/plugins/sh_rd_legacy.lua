--[[

	Author: MadDog (steam id md-maddog)
	Contact: http://www.facepunch.com/members/145240-MadDog986

]]

MsgN("-- Resource Distribution Legacy Loaded")

--stargate fixes
if (StarGate) then
	StarGate.HasResourceDistribution = true
end

--fixes resource names
local function RF( name )
	return name:gsub("^%l", string.upper):gsub(" ", "_")
end

--[[
	LS3 Legacy Support
]]
rd3_dev_link = true

CAF = {}

CAF.GetAddon = function( name )
	if ( name == "Resource Distribution" ) then return RD end
end

RD = {}

RD.GetNetTable = function( entid )
	local ent = Entity(entid)
	if (!ValidEntity(ent)) then return {} end

	return {}
end

RD.CreateNetwork = function(ent)
	return ent:EntIndex()
end

RD.UnlinkAllFromNode = function( ent )
	beams.Clear(ent)
end

RD.Link = function( ent1, ent2 )
	ent2 = Entity(ent2)
	beams.Settings( ent1, "cable/cable", "20", Color(255, 255, 255) )
	beams.Add( ent1, ent1, Vector(0,0,0) )
	beams.Add( ent1, ent2, Vector(0,0,0) )
end

RD.Unlink = function( ent )
	beams.Clear(ent)
end

RD.RemoveRDEntity = function( ent ) end --my system is smart enough to figure this out

RD.AddResource = function( ent, resource, maximum, default )
	resource = RF(resource)

end

RD.SupplyResource = function( ent, resource, amount)
	resource = RF(resource)
end

RD.ConsumeResource = function( ent, resource, amount)
	resource = RF(resource)
end

RD.GetResourceAmount = function( ent, resource )
	resource = RF(resource)
end

RD.GetUnitCapacity = function( ent, resource )
	resource = RF(resource)
end

RD.GetNetworkCapacity = function( ent, resource )
	resource = RF(resource)
end


--[[
	LS2 Legacy Support
]]

IsSpaceBuildDerived = true
FairTemp_Min = 288 --15°C
FairTemp_Max = 303 --30°C

TrueSun = nil
SunAngle = Vector(0,0,-1)

function RD_AddResource( ent, resource, amount )
	resource = RF(resource)
	amount = math.floor(amount)
end

function RD_GetResourceAmount( ent, resource )
	resource = RF(resource)

end

function RD_GetNetworkCapacity( ent, resource )
	resource = RF(resource)

end

function RD_GetUnitCapacity( ent, resource )
	resource = RF(resource)

end

function RD_SupplyResource( ent, resource, amount )
	resource = RF(resource)
	amount = math.floor(amount)

end

function RD_ConsumeResource( ent, resource, amount )
	resource = RF(resource)
	amount = math.floor(amount)

end

function Dev_Link(e1,e2,e1Pos,e2Pos,Cable,Color,SM)
	--save beam settings
	beams.Settings( e1, Cable, SM, Color )

	--add beam
	beams.Add( e1,e1, e1Pos )
	beams.Add( e1,e2, e2Pos )
end

function Dev_Unlink_All( ent1 )
	--clear any previous beam settings
	beams.Clear( ent1 )
end
