AddCSLuaFile( 'cl_init.lua' )
AddCSLuaFile( 'shared.lua' )
include( 'shared.lua' )

function  ENT:Initialize()
	self.BaseClass.Initialize(self)

	self:DrawShadow( false )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )
	--self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

	--set the life based off the model size
	self.Life = math.ceil(self:OBBMaxs():Length()) / 2
	self.SpawnTime = CurTime()

	--self:PhysWake()
end
