--no saving allowed
if (SERVER and game.IsDedicated()) then
	concommand.Remove("gm_save")
end

--TODO: add more commands here
function GM:PlayerSay( ply, text, toall )
	-- This function clobbers Spacebuild 2 and 3 code, here is the replacement
	--self.BaseClass:PlayerSay( ply, text, toall )
	if ply:IsAdmin() then
		if (string.sub(text, 1, 10 ) == "!freemap") then
			game.CleanUpMap()
			return text
		end
	end
	-- End Spacebuild Code
end

--TODO: finish this
function GM:ShowHelp( ply ) --f1
end

function GM:ShowTeam( ply ) --f2
end

function GM:ShowSpare1( ply ) --f3
end

function GM:ShowSpare2( ply ) --f4
end