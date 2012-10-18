include("shared.lua")

for k, v in pairs( file.Find(SB.Folder .. "/gamemode/vgui/*", "GAME") ) do
	MsgN("--\t\t" .. v .. " loaded.")
	include("vgui/"..v)
end

--extra files
for k, v in pairs( file.Find(SB.Folder .. "/gamemode/modules/cl_*", "GAME") ) do
	MsgN("--\t\t" .. v .. " loaded.")
	include("modules/"..v)
end


function SB:SendMessage( msg, t )
	--[[
	NOTIFY_GENERIC = 0
	NOTIFY_ERROR = 1
	NOTIFY_UNDO	 = 2
	NOTIFY_HINT	 = 3
	NOTIFY_CLEANUP = 4
	]]

	local sound = ""

	t = tonumber(t)

	if (t == NOTIFY_GENERIC) then
		sound = "buttons/button17.wav"
	elseif (t == NOTIFY_ERROR) then
		sound = "buttons/button10.wav"
	elseif (t == NOTIFY_UNDO) then
		sound = "buttons/bell1.wav"
	elseif (t == NOTIFY_HINT) then
		sound = "ambient/machines/slicer"..math.random(1, 4)..".wav"
	else
		sound = "ambient/water/drip"..math.random(1, 4)..".wav"
	end

	GAMEMODE:AddNotify( msg, math.Clamp(t, 0, 4), 10 )
	surface.PlaySound(sound)
end