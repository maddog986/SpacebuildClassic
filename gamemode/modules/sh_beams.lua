--[[
	Created by MadDog
	Last Update May 2012

	Example usuage:
		--create the beam settings
		-- entity, material, size, color
		beams.Settings( ent, "cable/rope_icon", 2, Color(100, 100, 100) )

		--add the beam points
		-- entity, entity2,
		beams.Add( ent, ent2, ent:WorldToLocal(ent2:GetPos))

	TODO: this was made long ago, really needs a complete recode to make more efficient but for now, it works.
]]

beams = {}

if (SERVER) then
	hook.Add( "PlayerInitialSpawn", "beamsPlayerUpdate", function( ply )
		beams.ResendAll( ply )
	end )

	beams.ResendAll = function(ply)
		if (!ply and game.SinglePlayer()) then ply = Entity(1) end --for testing
		if !IsValid(ply) then return end

		for _, ent in pairs( ents.GetAll() ) do
			if (!ent._beams) then continue end
			data.Send("beams.Update", ent, ent._beams, "nocache")
		end
	end
end

beams.QuickLink = function( ent1, ent2 )
	beams.Settings( ent1 )
	beams.Add( ent1, ent2, ent1:WorldToLocal(ent2:GetPos()) )

	if SERVER then
		data.Send("beams.QuickLink", ent1, ent2, "nocache")
	end
end

beams.Settings = function( ent, material, size, color )
	if (!ent._beams) then ent._beams = {} end

	table.Add(ent._beams, {{settings = {material = material,size = size,color = color}, entities = {}}})

	if CLIENT then
		beams.OverrideDraw( ent )
	elseif SERVER then
		data.Send("beams.Settings", ent, material, size, color, "nocache")
	end
end

beams.Add = function( sEnt, fEnt, beamVec )
	if (!sEnt._beams or !IsValid(fEnt)) then return end

	sEnt._beams[#sEnt._beams].entities[fEnt:EntIndex()] = sEnt._beams[#sEnt._beams].entities[fEnt:EntIndex()] or {}
	table.insert(sEnt._beams[#sEnt._beams].entities[fEnt:EntIndex()], beamVec)

	if (fEnt!=sEnt) then
		if (!fEnt._beams) then fEnt._beams = {} end
		if (!fEnt._beams_constraints) then fEnt._beams_constraints = {} end

		fEnt._beams_constraints[sEnt:EntIndex()] = #sEnt._beams --tell the other entity its being constrained by this one
	end

	if SERVER then
		--saving this to the entity means you wont have to call beams.Connect as often!
		local connected = beams.Connected(sEnt)
		for _, ent in pairs(connected) do
			ent._beamsconnected = connected
		end

		duplicator.StoreEntityModifier( sEnt, "beams", {sEnt._beams, sEnt._beams_constraints}) --duplicator support
		duplicator.StoreEntityModifier( fEnt, "beams", {fEnt._beams, fEnt._beams_constraints}) --duplicator support

		data.Send("beams.Add", sEnt, fEnt, beamVec, "nocache")
	end
end

beams.Clear = function( self, entity, stop )
	for rowid, info in pairs( self._beams or {} ) do
		for id, _ in pairs( info.entities or {} ) do
			local ent = ents.GetByIndex(id)

			if (IsValid(entity) and entity != ent) then continue end

			if (ent._beams_constraints) then ent._beams_constraints[self:EntIndex()] = nil end

			self._beams[rowid] = nil
		end
	end

	if IsValid(entity) then
		if (!stop) then beams.Clear( entity, self , true ) end

		--saving this to the entity means you wont have to call beams.Connect as often!
		local connected = beams.Connected(self)
		for _, ent in pairs(connected) do
			ent._beamsconnected = connected
		end
	else
		for id, _ in pairs(self._beams_constraints or {}) do
			self._beams_constraints[id] = nil
			beams.Clear( ents.GetByIndex(id), self )
		end

		--clear all the beam info and constraints
		self._beams = nil
		self._beamsconnected = nil
		self._beams_constraints = nil
	end

	if SERVER then
		data.Send("beams.Clear", self, entity, "nocache")
	end
end

beams.Connected = function(ent, entites)
	local connected = {}
	local first = (entites == nil)
	local start = CurTime()

	entites = entites or {}

	entites[ent:EntIndex()] = ent

	for _id, _info in pairs( ent._beams or {} ) do --loop through all the saved beams
		for _entid, _vecs in pairs( ent._beams[_id].entities ) do
			if !entites[_entid] then connected[_entid] = ents.GetByIndex(_entid) end
		end
	end

	for _entid, _rowid in pairs( ent._beams_constraints or {} ) do --loop through all the saved beams
		if !entites[_entid] then connected[_entid] = ents.GetByIndex(_entid) end
	end

	for _, _ent in pairs( connected ) do --keep going down the line
		beams.Connected( _ent, entites )
	end

	if (first == true) then return entites; end
end

if (CLIENT) then
	if (!beams.Materials) then
		--materails for links
		list.Add( "beams.Materials", "cable/rope_icon" )
		list.Add( "beams.Materials", "cable/cable2" )
		list.Add( "beams.Materials", "cable/xbeam" )
		list.Add( "beams.Materials", "cable/redlaser" )
		list.Add( "beams.Materials", "cable/blue_elec" )
		list.Add( "beams.Materials", "cable/physbeam" )
		list.Add( "beams.Materials", "cable/hydra" )
		list.Add( "beams.Materials", "cable/hose_black1" )
		list.Add( "beams.Materials", "sprites/orangelight1" )
		list.Add( "beams.Materials", "cable/new_cable_lit" )
		list.Add( "beams.Materials", "cable/cable_metalwinch01" )
		list.Add( "beams.Materials", "cable/cable" )
		list.Add( "beams.Materials", "vgui/progressbar" )
		list.Add( "beams.Materials", "models/debug/debugwhite" )

		--holds the materials
		beams.Materials = {}

		--preload materials
		for _, mat in pairs(list.Get( "beams.Materials" )) do
			beams.Materials[mat] = Material(mat)
		end
	end

	beams.Update = function(ent, info, tries)
		 --a little hacky i know, but sometimes on dupe spawns GetTable isnt ready yet for clients
		if (!IsValid(ent)) then return end
		if ent:GetTable() == nil and (tries or 0) < 10 then
			timer.Simple(0.1, beams.Update, ent, info, (tries or 0) + 1);
		return end

		ent._beams = info
		beams.OverrideDraw( ent )
	end

	beams.OverrideDraw = function( ent )
		local t = ent:GetTable()

		if (!t.MDBeams_oldDraw) then
			t.MDBeams_oldDraw = ent.Draw
			function t:Draw()
				self:MDBeams_oldDraw()
				beams.Render( self )
			end
		end
	end

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

	beams.Render = function( ent )
		if (!ent._beams) then return end --no beams dont render

		local mins, maxs = ent:WorldSpaceAABB()
		local segments = 15
		local position = Vector()

		for _id, _info in pairs( ent._beams ) do --loop through all the saved beams
			local entities = _info.entities
			local settings = _info.settings

			local beamMaterial, beamSize, beamColor = beams.Materials[settings.material or "cable/rope_icon"], tonumber(settings.size or 0), settings.color or color_white

			local startingPoint, endingPoint, startingTangent, endingTangent

			for entid, beampoints in pairs( entities ) do
				local beamEnt = ents.GetByIndex(entid)

				if (!startingPoint) then
					startingPoint = beamEnt:LocalToWorld(beampoints[1])
					startingTangent = (beamEnt:GetPos() - startingPoint) * -5
				else
					endingPoint = beamEnt:LocalToWorld(beampoints[1])
					endingTangent = (beamEnt:GetPos() - endingPoint) * -5
				end
			end

			if (!startingPoint or !endingPoint) then continue end --not yet ready to do it

			render.DrawSphere(startingPoint, beamSize * 0.5, 10, 10, beamColor)
			render.DrawSphere(endingPoint, beamSize * 0.5, 10, 10, beamColor)

			render.SetMaterial( beamMaterial )
			render.StartBeam(segments)
			render.AddBeam(startingPoint, beamSize, 1, beamColor)

			for segment = 2, segments - 1 do
				local t = 1 / segments * segment

				position.x = hermite(startingPoint.x - startingTangent.x, startingPoint.x, endingPoint.x, endingPoint.x - endingTangent.x, t, -1, 0)
				position.y = hermite(startingPoint.y - startingTangent.y, startingPoint.y, endingPoint.y, endingPoint.y - endingTangent.y, t, -1, 0)
				position.z = hermite(startingPoint.z - startingTangent.z, startingPoint.z, endingPoint.z, endingPoint.z - endingTangent.z, t, -1, 0)

				render.AddBeam(position, beamSize, 1, beamColor)

				local localpos = ent:WorldToLocal(position)

				if (localpos.x < mins.x) then mins.x = localpos.x end
				if (localpos.y < mins.y) then mins.y = localpos.y end
				if (localpos.z < mins.z) then mins.z = localpos.z end

				if (localpos.x > maxs.x) then maxs.x = localpos.x end
				if (localpos.y > maxs.y) then maxs.y = localpos.y end
				if (localpos.z > maxs.z) then maxs.z = localpos.z end
			end

			render.AddBeam(endingPoint, beamSize, 1, beamColor)
			render.EndBeam()
		end

		--ent:SetRenderBounds(mins, maxs)
	end

	--[[
	OLD CODE
	beams.Render = function( ent )
		if (!ent._beams) then return end --no beams dont render

		local bbmin, bbmax

		if (CurTime() >= (ent.NextBoundsUpdate or 0)) then
			bbmin, bbmax = ent:OBBMins(), ent:OBBMaxs() 	--render bounds vars
			ent.NextBoundsUpdate = CurTime() + 0.5 -- how often to update per second
		end

		for _id, _info in pairs( ent._beams ) do --loop through all the saved beams
			if (!ent._beams[_id].entities or table.Count(ent._beams[_id].entities) <= 1) then continue; end --only need to render if we have a complete beam

			local beamMaterial, beamSize, beamColor = beams.Materials[_info.settings.material or "cable/rope_icon"], tonumber(_info.settings.size or 0), _info.settings.color or Color(255, 255, 255 )
			if (beamSize<=0) then continue end --dont draw, since beam size is zero

			local total, scroll, start = 0, CurTime() * 0.5, nil --make some vars we are about to use

			for _entid, _vecs in pairs( ent._beams[_id].entities ) do
				total = total + table.Count(_vecs)
			end

			if (total == 0) then continue; end --no vector points

			render.SetMaterial( beamMaterial )
			render.StartBeam( total )

			for _entid, _vecs in pairs( ent._beams[_id].entities ) do
				for _, _entvec in pairs( _vecs ) do
					if (!start) then start = _entvec end --set start point

					local beamEnt = ents.GetByIndex(_entid)

					if (!IsValid(beamEnt)) then
						ent._beams[_id].entities[_entid] = nil --clear this record
					else
						local pos = beamEnt:LocalToWorld(_entvec) --get beam world vector

						if (bbmin) then
							local beamPos = ent:WorldToLocal(pos)

							if (beamPos.x < bbmin.x) then bbmin.x = beamPos.x end
							if (beamPos.y < bbmin.y) then bbmin.y = beamPos.y end
							if (beamPos.z < bbmin.z) then bbmin.z = beamPos.z end
							if (beamPos.x > bbmax.x) then bbmax.x = beamPos.x end
							if (beamPos.y > bbmax.y) then bbmax.y = beamPos.y end
							if (beamPos.z > bbmax.z) then bbmax.z = beamPos.z end
						end

						scroll = scroll - (pos-start):Length()/10 --update scroll
						render.AddBeam(pos, beamSize, scroll, beamColor)
						start = pos --reset start postion
					end
				end
			end

			render.EndBeam()
		end

		if (bbmin and bbmax) then ent:SetRenderBounds(bbmin, bbmax) end
	end]]
end

GM:Register( beams )