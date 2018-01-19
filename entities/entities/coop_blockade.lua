AddCSLuaFile()
DEFINE_BASECLASS( "base_anim" )

ENT.PrintName		= ""
ENT.Author			= ""
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.Spawnable		= false
ENT.AdminSpawnable	= false

function ENT:Initialize()

	DbgPrint("Initialize")
	
	self:PhysicsInit(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
	end
	
	-- By default we always draw.
	self:SetShouldDraw(true)
	
end

function ENT:SetupDataTables()

	self:NetworkVar( "Bool", 0, "ShouldDraw" )
	
end

function ENT:Draw()
	if self:GetShouldDraw() then
		self:DrawModel()
	end
end