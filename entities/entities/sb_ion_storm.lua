--[[
	Author: MadDog (steam id md-maddog)

	TODO: finish
]]
AddCSLuaFile()

DEFINE_BASECLASS( "base_gmodentity" )

ENT.PrintName = "Spacebuild Ion Storm"
ENT.Author	= "MadDog"

ENT.Spawnable = false
ENT.AdminOnly = false

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

if CLIENT then return end

util.PrecacheSound("ambient/atmosphere/thunder1.wav")
util.PrecacheSound("ambient/atmosphere/thunder2.wav")
util.PrecacheSound("ambient/atmosphere/thunder3.wav")
util.PrecacheSound("ambient/atmosphere/thunder4.wav")

AccessorFunc( ENT, "size", "Size", FORCE_NUMBER )

function ENT:Initialize()

	self:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )

	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )

	self:SetGravity(0.00001)

	local phys = self:GetPhysicsObject()

	if(phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:EnableMotion( false )
	end


end

function ENT:Think()

	if ( (self.spacecloud or 0) < CurTime() ) then
		self.spacecloud = CurTime() + 10

		local effect = EffectData()

		effect:SetOrigin( self:GetPos() )
		effect:SetMagnitude( 100 )
		effect:SetScale( self:GetSize() )

		util.Effect( "sb_space_cloud", effect )
	end


	for i=1,math.random(10,15) do
		local mag = math.random(3, 10)
		local pos = self:GetPos() + (VectorRand() * 1000)

		local ent = ents.Create("point_tesla")
		ent:SetKeyValue("targetname", "teslab")
		ent:SetKeyValue("m_SoundName" ,"DoSpark")
		ent:SetKeyValue("texture" ,"sprites/physbeam.spr")
		ent:SetKeyValue("m_Color" ,"200 200 255")
		ent:SetKeyValue("m_flRadius" ,tostring(mag*80))
		ent:SetKeyValue("beamcount_min" ,tostring(math.ceil(mag)+4))
		ent:SetKeyValue("beamcount_max", tostring(math.ceil(mag)+12))
		ent:SetKeyValue("thick_min", tostring(mag))
		ent:SetKeyValue("thick_max", tostring(mag*8))
		ent:SetKeyValue("lifetime_min" ,"0.1")
		ent:SetKeyValue("lifetime_max", "0.2")
		ent:SetKeyValue("interval_min", "0.05")
		ent:SetKeyValue("interval_max" ,"0.08")
		ent:SetPos( pos )
		ent:Spawn()
		ent:Fire("DoSpark","",0)
		ent:Fire("kill","", 1)
		ent:EmitSound("ambient/atmosphere/thunder"..math.random(1,4)..".wav", 100, math.random(90,110) )
	end


	--[[
	for i=1,math.random(4,10) do


		local spark = ents.Create("point_tesla")
		spark:SetKeyValue("targetname", "teslab")
		spark:SetKeyValue("m_SoundName" ,"DoSpark")
		spark:SetKeyValue("texture" ,"sprites/plasma.spr")
		spark:SetKeyValue("m_Color" , math.random(0,255).." "..math.random(0,255).." "..150+math.random(0,100))
		spark:SetKeyValue("m_flRadius" , tostring(math.random(255,1500)))
		spark:SetKeyValue("beamcount_min", tostring(math.random(50,150)))
		spark:SetKeyValue("beamcount_max", tostring(math.random(150,250)))
		spark:SetKeyValue("thick_min", tostring(math.random(10,15)))
		spark:SetKeyValue("thick_max", tostring(math.random(20,30)))
		spark:SetKeyValue("lifetime_min" ,"0.4")
		spark:SetKeyValue("lifetime_max", "0.1")
		spark:SetKeyValue("interval_min", "0.05")
		spark:SetKeyValue("interval_max" ,"0.08")
		spark:SetPos(pos)
		spark:Spawn()
		spark:Fire("DoSpark","",0)
		spark:Fire("kill","", .1)
		spark:EmitSound("ambient/atmosphere/thunder"..math.random(1,4)..".wav", 500, 100)
	end
]]

	self:NextThink( CurTime() + 1 )
	return true
end

--function ENT:UpdateTransmitState() return TRANSMIT_NEVER end
function ENT:PhysicsSimulate( phys, deltatime ) return SIM_NOTHING end --dont ever move.