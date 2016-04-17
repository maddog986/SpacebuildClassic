--[[

	Author: MadDog (steam id md-maddog)
	Contact: http://www.facepunch.com/members/145240-MadDog986

]]

--base for all plugins (shared code)
local BasePlugin = {
	--plugininfo
	Name = "Base",
	Description = "Base Plugin",
	Version = 0, --should always be in date format, example ddmmyyyy

	CVars = {}, --holds settings

	Startup = function( self ) end, --called when going from disabled to enable
	ShutDown = function( self ) end, --called wgeb going from enabled to disabled, also called when server shuts down

	NextThink = 0,

	AddSetting = function( self, data )
		self.Cvars[data.cvar] = { server = data.server, name = data.name, default = data.default, flags = data.flags or { FCVAR_ARCHIVE }, callback = data.callback}
	end

	--called once plugin is loaded
	OnLoaded = function( self )
		self.cvar = "sb_" .. self.Name:gsub(" ", "_"):lower() .. "_enable" --TODO: need to add addtional remove for nonstring characters

		self:AddSetting({
			cvar = self.cvar,
			server = SERVER or ConVarExists(self.cvar),
			name = "Enable",
			default = 1,
			flags = { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED },
			callback = function( cvar, old, new ) old = tobool(old); new = tobool(new);
				if ( old and !new ) then
					self:ShutDown()
				elseif ( !old and new ) then
					self:Startup()
				end
			end
		})

		for cvar, setting in pairs( self.CVars ) do
			if ( setting.server ) then
				CreateConVar( cvar, tostring(setting.default), setting.flags or { FCVAR_ARCHIVE })
			else
				CreateClientConVar( cvar, tostring(setting.default), true )
			end

			if ( setting.callback ) then cvars.AddChangeCallback( cvar, setting.callback, cvar ) end
		end
	end,

	IsActive = function( self )
		return GetConVar(self.cvar):GetBool()
	end,

	IsValid = function( self ) return true end,

	GetSetting = function( self, name )
		local cvar = GetConVar( name )
		local setting = self.CVars[name]

		if ( !cvar or !setting ) then return end

		if ( type(setting.default) == "number" ) then
			return cvar:GetFloat()
		elseif ( type(setting.default) == "boolean" ) then
			return cvar:GetBool()
		else
			return cvar:GetString()
		end
	end,

	Call = function( name, ... )
		if ( !self[name] or (name == "Think" and self.NextThink > CurTime())) then return end
		self[name]( self, unpack({...}) )
	end
}

--holds all the plugins
local plugins = {}

--adds a plugin to the system
function GM:AddPlugin( plugin )
	if ( type(plugin) ~= "table" or !plugin.Name ) then MsgN("GM:AddPlugin: Failed, not a proper plugin."); return end

	--make sure all the basics are given
	table.Inherit( plugin, BasePlugin )

	plugin:OnLoaded() --plugin init/load

	plugins[plugin.Name] = plugin
end

--returns a plugin
function GM:GetPlugin( name ) return plugins[name] end
function GM:IsPluginActive( name ) return IsValid(plugins[name]) and plugins[name]:IsActive() end
function GM:GetPlugins() return plugins end

--[[
	hook.Call Override, very important part, the heart of the plugins
]]
if ( !hook.OrigCall ) then hook.OrigCall = hook.Call end

function hook.Call( name, GM, ... )
	local result = hook.OrigCall( name, GM, unpack({...}) )
	if ( result ~= nil ) then return result end

	--plugin hooks
	for _, plugin in pairs( plugins ) do
		plugin:Call( name )
	end
end