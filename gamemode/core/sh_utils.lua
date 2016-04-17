--[[

	Author: MadDog (steam id md-maddog)

]]

utilx = {}

function utilx.RemoveAllByClass( class )
	for _, ent in pairs( ents.FindByClass(class) ) do
		SafeRemoveEntity(ent)
	end
end

utilx._smooth = {}

function utilx.Smoother( to, from, frac )
	frac = frac or 0.05

	local previus = utilx._smooth[from] or Either( type(from) == "string", to, from )
	local result = previus + (to - previus) * frac

	if ( type(from) == "string" ) then
		utilx._smooth[from] = result
	end

	return math.Round(result)
end

function utilx.IsStuck( ent )
	return util.TraceLine( {start = ent:GetPos(), endpos = ent:GetPos(), filter = ent} ).StartSolid
end

function utilx.IsInSphere( pos, pos2, radius )
	return ( pos:Distance(pos2) <= radius )
end

function utilx.IsInBox( ent, min, max )
	local pos = ent:GetPos()

	return ( pos > min and pos < max )
end

function utilx.InRange( num, low, high )
	return ( num >= low and num <= high )
end

function utilx.IsInWater( ent )
	return util.TraceLine({
		start = ent:GetPos(),
		endpos = ent:GetPos(),
		mask = MASK_WATER,
		filter = ent
	}).Hit
end

function utilx.IsSkyAbove( ent )
		return util.TraceLine({
		start = ent:GetPos(),
		endpos = ent:GetPos() + Vector(0, 0, 15000),
		filter = ent
	}).HitSky
end

function utilx.IsVisible( posa, posb )
	return not util.TraceLine({ start = posa, endpos = posb, mask = MASK_SOLID_BRUSHONLY }).Hit
end

function utilx.RayIntersectSphere( startPos, rayDir, spherePos, sphereRadius )
	local dst = startPos - spherePos
	local b = dst:Dot( rayDir )
	local c = dst:Dot( dst ) - ( sphereRadius * sphereRadius )
	local d = b * b - c

	if ( d > 0 ) then
		local dist = ( -b - math.sqrt( d ) )
		return true, dist, startPos + (rayDir * dist)
	end

	return false
end

function utilx.CapitaliseFirstLetter(str)
    return string.gsub(str, "%w", string.upper, 1)
end

function utilx.FastExplode( str, sep )
	local k, t = "", { }

	for k in str:gmatch( "[^" .. sep .. "]+" ) do
        table.insert( t, k )
	end

	return t
end

function utilx.GetPlayerTrace( ply, disc )
	return util.TraceLine({
		start = ply:GetPos(),
		endpos = ply:GetPos() + ( ply:GetAimVector() * disc ),
		filter = ply
	})
end

function utilx.IsValidPhysics( ent )
	return IsValid(ent) and IsValid(ent:GetPhysicsObject())
end

--credit goes to Overv for this, posted at http://facepunch.com/showthread.php?t=1044809#post27158859
function utilx.TableCompare( tbl1, tbl2 )
	for k, v in pairs( tbl1 ) do
		if ( type(v) == "table" and type(tbl2[k]) == "table" ) then
		    if ( !table.Compare( v, tbl2[k] ) ) then return false end
		else
		    if ( v != tbl2[k] ) then return false end
		end
	end
	for k, v in pairs( tbl2 ) do
		if ( type(v) == "table" and type(tbl1[k]) == "table" ) then
		    if ( !table.Compare( v, tbl1[k] ) ) then return false end
		else
		    if ( v != tbl1[k] ) then return false end
		end
	end
	return true
end

function utilx.Explode( ent, scale, mag )
	if ( !IsValid(ent) ) then return end

	local effect = EffectData()
	effect:SetOrigin( ent:GetPos() + (VectorRand() * 60) )
	effect:SetScale( scale or 1 )
	effect:SetMagnitude( mag or 25 )

	util.Effect( "Explosion", effect, true, true )
end

function utilx.HasBit( x, p )
	return x % (p + p) >= p
end

function utilx.RandomPosition()
	while true do
		local pos = VectorRand() * 15000

		if util.IsInWorld(pos) then
			return pos
		end
	end
end

function utilx.RandomEmptyPosition( size )
	for variable = 0, 50, 1 do --try a few times to find a good spot
		local pos = utilx.RandomPosition()

		if ( #ents.FindInSphere( pos, size or 1 ) == 0 ) then
			return pos
		end
	end
end