
--[[

I did not code this. Stolen from https://github.com/disseminate/infected

]]

if true then return end

AI = {}
AI.Name = "AI Bot"
AI.Author = "MadDog"
AI.Version = 1

AI.StartPoints = {} --holds all the starting node type and positions
AI.MaxAutospawnAIs = 1
AI.FileName = ""
AI.Debug = true


--[[

	StartPoints looks something like this:
		{

			{
				name: "Human",
				model: "",
				pos: Vector(0,0,0),
				limit: 5
			}
		}
]]
--function AI:Initialize() end

function AI:InitPostEntity()
	self.FileName = "sb_ai/" .. game.GetMap() .. "_nodes.txt"

	if !file.IsDir("sb_ai", "DATA") then -- check to see if folder exists
		file.CreateDir("sb_ai") -- create it if it doesn't
	end

	if !file.Exists(self.FileName, "DATA") then -- check to see if file exists
		file.Write(self.FileName, "") -- create it if it doesn't
	end

	self.StartPoints = util.JSONToTable( file.Read( self.FileName, "DATA" ) or "{ }" ) or {}

	--[[for _, v in pairs( self.StartPoints ) do
		v.pos = Vector(v.pos)
	end]]
end

function AI:SaveNodes()
	file.Write( self.FileName, util.TableToJSON( self.StartPoints ) )
end

--[[
	ENTITY MODS
]]
local meta = FindMetaTable( "Entity" )

function meta:CanSeePlayer( ply )
	local trace = { }
	trace.start = self:EyePos()
	trace.endpos = ply:EyePos()
	trace.filter = { self, ply }
	trace.mask = MASK_SOLID + CONTENTS_WINDOW + CONTENTS_GRATE
	local tr = util.TraceLine( trace )

	if( tr.Fraction == 1.0 ) then
		return true
	end

	return false
end

function meta:IsDoor()
	if( self:GetClass() == "prop_door_rotating" ) then return true end
	return false
end

local meta = FindMetaTable( "Player" )

function meta:IsAI()
	return self:IsBot()	--( self:PlayerClass() == PLAYERCLASS_INFECTED or self:PlayerClass() == PLAYERCLASS_SPECIALINFECTED )
end



local function CanSeePos( pos1, pos2, filter )
	local trace = { }
	trace.start = pos1
	trace.endpos = pos2
	trace.filter = filter
	trace.mask = MASK_SOLID + CONTENTS_WINDOW + CONTENTS_GRATE
	local tr = util.TraceLine( trace )

	if( tr.Fraction == 1.0 ) then
		return true
	end

	return false
end

--adds a node where AI will spawn
function AI:AddStartNode( name, model, pos, limit )
	--if (self.Debug) then MsgN( "AddStartNode ", name, model, pos, limit ) end

	local start = {}
	start.name = name
	start.model = model
	start.pos = pos
	start.limit = limit

	local trace = { }
	trace.start = pos
	trace.endpos = trace.start - Vector( 0, 0, 1 )
	trace.filter = v
	local tr = util.TraceLine( trace )
	local pos2 = tr.HitNormal

	navmesh.AddWalkableSeed( pos, pos2 )

	self.StartPoints[name] = start

	--if (self.Debug) then PrintTable(self.StartPoints) end
end


function AI:ShouldCollide( ent1, ent2 )
	if ( ent1:GetClass() == "sb_ai" and ent2:GetClass() ==  ent1:GetClass() ) then
		return false
	end
end

function AI:DrawNavmesh()
	if( !AI.Debug ) then return end

	for _, v in pairs( player.GetAll() ) do
		local nav = navmesh.Find( v:GetEyeTrace().HitPos, 500, 50, 50 )

		for _, n in pairs( nav ) do
			n:Draw()
			n:DrawSpots()
		end
	end
end

function AI:Think()
	if (self.Disabled) then return end

	if( table.Count(self.StartPoints) > 0 and self:Total() < ( self.MaxAutospawnAIs or 30 ) ) then
		if( !self.NextSpawnAI ) then self.NextSpawnAI = CurTime() end

		if( CurTime() >= self.NextSpawnAI ) then
			self.NextSpawnAI = CurTime() + 0.1
			self:SpawnRandom()
		end
	end

	if( !self.NextNodeCheck ) then self.NextNodeCheck = CurTime() end

	if( CurTime() >= self.NextNodeCheck ) then
		local shouldSave = false

		for _, v in pairs( player.GetBots() ) do
			if( v:Alive() and v:OnGround() and v:GetGroundEntity() == game.GetWorld() ) then
				local trace = { }
				trace.start = v:EyePos()
				trace.endpos = trace.start + Vector( 0, 0, 32768 )
				trace.filter = v
				local tr = util.TraceLine( trace )

				if( tr.HitSky ) then
					local goodtrace = true

					for _, n in pairs( { Vector( 1, 0, 0 ), Vector( -1, 0, 0 ), Vector( 0, 1, 0 ), Vector( 0, -1, 0 ) } ) do
						local trace = { }
						trace.start = v:EyePos()
						trace.endpos = trace.start + n * 16
						trace.filter = v
						local tr = util.TraceLine( trace )

						if( tr.HitWorld ) then goodtrace = false end
					end

					if( goodtrace ) then
						local pos = v:GetPos()
						local good = true

						for _, v in pairs( self.StartPoints ) do
							if( pos:Distance( v.pos ) < 128 ) then
								good = false
								break
							end
						end

						if( good ) then
							--table.insert( self.StartPoints, pos )
							shouldSave = true
						end
					end
				end
			end
		end

		if (self.Debug) then
			for _, v in pairs( self.StartPoints ) do
				debugoverlay.Line( v.pos - Vector( 16, 0, 0 ), v.pos + Vector( 16, 0, 0 ), 0.1, Color( 255, 200, 0, 255 ), true )
				debugoverlay.Line( v.pos - Vector( 0, 16, 0 ), v.pos + Vector( 0, 16, 0 ), 0.1, Color( 255, 200, 0, 255 ), true )
				debugoverlay.Line( v.pos, v.pos + Vector( 0, 0, 72 ), 0.1, Color( 255, 200, 0, 255 ), true )
			end
		end

		if( shouldSave ) then
			self:SaveNodes()
		end

		self.NextNodeCheck = CurTime() + 0.1
	end
end



function AI:IsTargetable( ent )
	if( ent:GetNoDraw() ) then return false end
	if( ent:IsPlayer() and !ent:Alive() ) then return false end
	--if( ent:IsBot() ) then return false end

	return true
end

function AI:CanPlayerSee( pos )

	for _, v in pairs( player.GetAll() ) do
		--if( self:IsTargetable(v) ) then
			local d = v:GetPos():Distance( pos )

			if( d < 1000 ) then return true end
			if( v:VisibleVec( pos ) ) then return true end

			local dir = ( pos * v:EyePos() ):GetNormal()

			if( dir:Dot( v:GetAimVector() ) > 0.7071 and d < 2500 ) then
				return true
			end
		--end
	end

	return false
end

function AI:IsSpotClear( pos )


	local trace = {
		start = pos,
		endpos = pos,
		mins = Vector( -16, -16, 0 ),
		maxs = Vector( 16, 16, 71 )
	}

	local tr = util.TraceHull( trace )

	return !tr.Hit
end

function AI:SpawnRandom()
	--if (self.Debug) then MsgN("SpawnRandom") end

	local tab = { }

	for n, v in pairs( self.StartPoints ) do
		--if( self:IsSpotClear( v ) and !self:CanPlayerSee( v ) ) then
		if( self:IsSpotClear( v.pos ) ) then
			tab[n] = v
		end
	end

	if ( table.Count(tab) == 0 ) then
		return
	end

	--if (self.Debug) then PrintTable(tab) end

	local ai = table.Random( tab )

	--if (self.Debug) then MsgN("New bot ", ai) end

	local z = ents.Create( "sb_ai" )
	z:SetPos( ai.pos )
	z:SetAngles( Angle( 0, math.random( -180, 180 ), 0 ) )
	z:Spawn()
	z:Activate()
end

function AI:RemoveAll()
	for _, v in pairs( ents.FindByClass( "sb_ai" ) ) do
		v:Remove()
	end
end

function AI:InSphere( p, r )
	local tab = { }

	for _, v in pairs( ents.FindByClass( "sb_ai" ) ) do
		if( v:GetPos():Distance( p ) <= r ) then
			tab[name] = v
		end
	end

	return tab
end

function AI:Total()
	return #ents.FindByClass( "sb_ai" )
end


--[[

	Console Commands

]]
local function Disable( ply, cmd, args )
	if (!ply:IsAdmin()) then return end --admin only command

	AI.Disabled = true
	AI.SavedMaxAutospawnAIs = AI.MaxAutospawnAIs

	AI:RemoveAll()
end
concommand.Add( "sb_ai_disable", Disable, true )

local function Enable( ply, cmd, args )
	if (!ply:IsAdmin()) then return end --admin only command

	AI.Disabled = false
	AI.MaxAutospawnAIs = AI.SavedMaxAutospawnAIs or AI.MaxAutospawnAIs or 6
end
concommand.Add( "sb_ai_enable", Enable, true )

local function AddSpawnNode( ply, cmd, args )
	if (!ply:IsAdmin() or !args or !args[1]) then return end --admin only command

	local name = args[1]
	local model = args[2]
	local limit = args[3] or AI.MaxAutospawnAIs
	local pos = ply:GetPos()

	AI:AddStartNode( name, model, pos, limit )
	AI:SaveNodes()
end
concommand.Add( "sb_ai_addnavseeds", AddSpawnNode, true )

local function GenerateNavmesh( ply, cmd, args )
	if (!ply:IsAdmin()) then return end --admin only command
	if( AI.GeneratingNavmesh ) then return end

	AI.GeneratingNavmesh = true

	navmesh.BeginGeneration()

	AI.GeneratingNavmesh = false --if we reach this point there was something wrong when generating a new nav mesh
end
concommand.Add( "sb_ai_generatenavmesh", GenerateNavmesh, true )