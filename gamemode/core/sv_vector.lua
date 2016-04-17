--[[
	Author MadDog
]]
local meta = FindMetaTable("Vector")

if ( !meta ) then return end

--Apparently there is no higher than operator defined for Vectors by default.
--Credit to Overv for this one
function meta.__lt( vec1, vec2 )
	return vec1.x > vec2.x and vec1.y > vec2.y and vec1.z > vec2.z
end
