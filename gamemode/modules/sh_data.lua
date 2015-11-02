--[[
	Author: MadDog (steam id md-maddog)
]]
module( "data", package.seeall )

local table = table
local util = util
local type = type
local net = net
local unpack = unpack

if SERVER then
	util.AddNetworkString( "data.Receive" )

	local _history = {}
	local historycount = 0

	function Send( name, ... )
		local args = {...}
		local ply = args[#args]	--use last arg as Player
		local cacheid = name

		if (type(name) == "table") then
			cacheid = name[2]
			name = name[1]
		end

		if (type(ply) == "Player") then
			table.remove( args )
		else
			ply = nil
		end

		local nocache = args[#args]	--use last for cache check
		local dataT ={n = name, a = args}

		if (type(args[#args]) == "string" and args[#args] == "nocache") then
			table.remove( args )
		else
			local historyid = cacheid

			if IsValid(ply) then historyid = historyid.. ply:SteamID() end

			if (_history[historyid] && table.Compare( _history[historyid], dataT)) then return end --if same as last call then dont send (save bandwidth)

			_history[historyid] = dataT --no history found so save to history

			historycount = historycount + 1
			if (historycount > 1500) then _history[table.GetFirstKey(_history)] = nil end --keep cache down under a certain size for performance
		end

		net.Start( "data.Receive" )
		net.WriteString( name )
		net.WriteString( von.serialize(args) )

		if (ply) then
			net.Send(ply)
		else
			net.Broadcast()
		end
	end

else
	local function Receive( len, ply )
		local name = net.ReadString()
		local args = von.deserialize(net.ReadString())
		local func

		for _, n in pairs( string.Explode( ".", name) ) do
			if (func) then
				func = func[n]
			else
				func = _G[n]
			end
		end

		if !func then MsgN("data.Receive: not such function: ", name); return end

		func(unpack(args))
	end

	net.Receive("data.Receive", Receive)
end