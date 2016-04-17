--[[
	Resources API
		Last Update: April 2012

		file: resources_api.lua

	Use this in your Life Support devices. Using these function names will
	insure they are compatibile with other systems that use this API.

	This will be called as a shared file as it contains both SERVER and
	CLIENT functions.

	To setup a device you need to run the code:
		ent:InitResources()

	After that the following functions are available to use:
		Client Side Functions:
			ent:ResourcesDraw()

		Server Side Functions:
			ent:ResourcesConsume( resourcename, amount )
			ent:ResourcesSupply( resourcename, amount )
			ent:ResourcesGetCapacity( resourcename )
			ent:ResourcesSetDeviceCapacity( resourcename, amount )
			ent:ResourcesGetAmount( resourcename )
			ent:ResourcesGetDeviceAmount( resourcename )
			ent:ResourcesGetDeviceCapacity( resourcename )
			ent:ResourcesLink( entity )
			ent:ResourcesUnlink( entity )
			ent:ResourcesCanLink( entity )
]]

RESOURCES = {}
RESOURCES.Version = 1 --only changes when something major gets changed

--register the device clientside
function RESOURCES:Setup( ent )
	--[[
		your shared code here
	]]

	--client functions
	if CLIENT then
		--[[
			your client side code here
		]]

		--Used do draw any connections, "beams", info huds, etc for the devices.
		--this would be placed within the ENT:Draw() function
		function self:ResourcesDraw( ent )
			-- your code here
		end

	--server functions
	elseif SERVER then

		RS:SetupDevice( ent )

		--Can be negitive or positive (for consume and generate)
		-- supply: resource name or resource table
		-- returns: amount not consumed
		function ent:ResourcesConsume( res, amount )
			return RS:Commit( self, res, -amount )
		end

		--Supplies the resource to the connected network
		-- supply: resource name or resource table
		-- returns:
		function ent:ResourcesSupply( res, amount )
			return RS:Commit( self, res, amount )
		end

		--Gets the devices networks total storage for the resource
		-- supply: resource name
		-- returns: number
		-- note: If passed in nothing (nil), return the capity for each resource
		function ent:ResourcesGetCapacity( res )
			return RS:GetNodeStored( self, res )
		end

		--Sets the device max storage capacity
		-- supply: resource name or resource table
		-- returns:
		function ent:ResourcesSetDeviceCapacity( res, amount )
			ent.RS.stored = ent.RS.stored or {}
			ent.RS.maxstorage = ent.RS.maxstorage or {}

			ent.RS.stored[res] = ent.RS.stored[res] or 0
			ent.RS.maxstorage[res] = amount
		end

		--  Gets the devices stored amount of resource from the connected network
		--  supply: resource name
		--  returns: number
		function ent:ResourcesGetAmount( res )
			return RS:GetEntityStorage( self, res )
		end

		--how much this devive is holding
		-- supply: resource name
		-- returns: number
		function ent:ResourcesGetDeviceAmount( res )
			return RS:GetEntityStored( self, res )
		end

		--how much this devives network is holding
		-- supply: resource name
		-- returns: number
		function ent:ResourcesGetDeviceCapacity( res )
			return RS:GetEntityStorage( self, res )
		end

		--link to another device/network
		-- supply: entity
		-- returns:
		function ent:ResourcesLink( entity )
			--your code here
		end

		--removes all link from a network
		-- supply: entity or table of entities (all optional)
		-- returns:
		-- note: if an entity is passed in then unlink with that entity, otherwise unlink all
		function ent:ResourcesUnlink( entity )
			if type(entity) == "table" then
				for _, v in pairs( res ) do self:ResourcesUnlink( v ) end
			return end

		end

		function ent:ResourcesGetLinks()
			return {} --table of connected entities
		end

		--Determains if two devices can be linked
		-- supply: entity or table of entities
		-- returns: boolean (if entity passed in), or table (if table of entities passed in)
		function ent:ResourcesCanLink( entity )
			if type(ent) == "table" then
				local links = {}
				for _, v in pairs( ent ) do
					links[ent] = self:ResourcesCanLink( v )
				end
				return links
			end

			--your code here
			return false
		end

		--Returns a list of connected entities
		function ent:ResourcesGetConnected()
			return {} --returns a table of all connected entities
		end

		--This function is called to save any resource info so it can be saved using the duplicator
		--this goes into ENT:PreEntityCopy
		function ent:ResourcesBuildDupeInfo()
			--your code here
		end

		--This function is called to store any resource info after a dup
		--this goes into ENT:PostEntityPaste
		function ent:ResourcesApplyDupeInfo( ply, ent, CreatedEntities )
			--your code here
		end
	end
end

local meta = FindMetaTable( "Entity" )

--sets up the functions to be used on the "Life Support" devices
-- supply: entity
function meta:InitResources( )
	RESOURCES:Setup( self )
end