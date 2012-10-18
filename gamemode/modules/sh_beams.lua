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

]]
//holds all the beam settings
beams = {}

if (SERVER) then

	--this is used to get the CreatedEntities table since its not passed into duplicator.RegisterEntityModifier
	-- credit to TomyLobo for this http://facepunch.com/threads/874611?p=19479141&viewfull=1#post19479141
	-- modified a little so it also works with AdvDup2 ~MadDog
	function WireLibPostDupe(entid, func)
	    local CreatedEntities
	    local paste_functions = {[duplicator.Paste] = true,[AdvDupe.Paste] = true,[AdvDupe.OverTimePasteProcess] = true}
	    local i,info = 1,debug.getinfo(1)
	    while info do
		if paste_functions[info.func] then
		    for j = 1,20 do
			local name, value = debug.getlocal(i, j)
			if name == "CreatedEntities" then
			    CreatedEntities = value
			    break
			end
		    end
		    break
		end
		i = i+1
		info = debug.getinfo(i)
	    end
	    if not CreatedEntities then  -- fix for AdvDup2
			local function dupefinished( TimedPasteData, TimedPasteDataCurrent )
				local ent = TimedPasteData[TimedPasteDataCurrent].CreatedEntities[entid]
				if ent then func(ent) end
			end
			hook.Add("AdvDupe_FinishPasting", "WireLibPostDupeFallback", dupefinished )
		return end
	    local unique = {}
	    timer.Create(unique, 1, 240, function(CreatedEntities, entid, unique, func)
		local ent = CreatedEntities[entid]
		if ent then
		    timer.Remove(unique)
		    func(ent)
		end
	    end, CreatedEntities, entid, unique, func)
	end

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

	--adv dup call when entity is restored!
	function beams.SettingsDup( ply, ent, beamsdata )
		if (!beamsdata) then return end

		ent:GetTable()._beams = beamsdata[1]
		ent:GetTable()._beams_constraints = beamsdata[2]

		local timerid = "beamupdate"..ent:EntIndex()

		timer.Create(timerid, 1, 0, function()
			if (!IsValid(ent)) then timer.Destroy(timerid) end
			data.Send("beams.Update", ent, ent._beams, "nocache")
		end)

		for id, _data in pairs(ent:GetTable()._beams) do
			for entid, vecs in pairs(_data.entities) do
				WireLibPostDupe(entid, function(sent)
					_data.entities[sent:EntIndex()] = _data.entities[entid]
					_data.entities[entid] = nil

					--kinda hacky but seems to work. only sends out the data when done dupping
					timer.Destroy(timerid)
					timer.Create(timerid, 1, 0, function()
						timer.Destroy(timerid)
						data.Send("beams.Update", ent, ent._beams, "nocache")
					end)
				end)
			end
		end
	end
	duplicator.RegisterEntityModifier( "beams", beams.SettingsDup )



	--THIS IS OLD! Not sure if this even works right now. TODO: Recode it?
	beams.MaxDistance = 400
	beams.CheckDistance = function( ent )
		if (!ent._beams_constraints) then return end
		if (!ent._beams_warn) then ent._beams_warn = {} end

		--new system, work in progress
		for _entid, _rowid in pairs( ent._beams_constraints or {} ) do --loop through all the saved beams
			local _ent = ents.GetByIndex(_entid)

			if (!_ent or !IsValid(_ent)) then
				ent._beams_constraints[_rowid] = nil --remove
				continue --next record please
			end

			local distance = (_ent:GetPos() - ent:GetPos()):Length()

			if (distance > beams.MaxDistance) then
				ent._beams_warn[_ent:EntIndex()] = (ent._beams_warn[_ent:EntIndex()] or 0) + 1 --increase timer for this connection

				--5 chances to fix
				if (ent._beams_warn[_ent:EntIndex()] >= 5) then
					ent._beams_warn[_ent:EntIndex()] = nil --reset length warn count

					ent._beams_constraints[_entid] = nil
					if (_ent._beams) then _ent._beams[_rowid].entities[ent:EntIndex()] = nil end	--remove ent from the link

					data.Send("beams.Add", _ent, _rowid, ent:EntIndex(), nil, "nocache") --send an update to remove

					--break sound
					_ent:EmitSound("physics/metal/metal_computer_impact_bullet"..math.random(1,3)..".wav", 500)
					ent:EmitSound("physics/metal/metal_computer_impact_bullet"..math.random(1,3)..".wav", 500)
				else
					local vol = 30 * self._beams_warn[_ent:EntIndex()]
					_ent:EmitSound("ambient/energy/newspark0"..math.random(1,9)..".wav", vol)
					self:EmitSound("ambient/energy/newspark0"..math.random(1,9)..".wav", vol)
				end
			else
				self._beams_warn[_ent:EntIndex()] = nil
			end
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
		 --a little hacky i know, but sometimes on dupe spawns GetTable isnt ready yet for clients :)
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
	end
end