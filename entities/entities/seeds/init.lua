AddCSLuaFile( 'cl_init.lua' )
AddCSLuaFile( 'shared.lua' )
include( 'shared.lua' )

function  ENT:Initialize()
	self.BaseClass.Initialize(self)

	self.Entity:DrawShadow( false )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_NONE )
	--self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )

	--set the life based off the model size
	self.Life = math.ceil(self:OBBMaxs():Length()) / 2
	self.SpawnTime = CurTime()

	--self:PhysWake()
end
