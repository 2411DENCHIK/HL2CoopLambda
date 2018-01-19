AddCSLuaFile()
DEFINE_BASECLASS( "base_anim" )

ENT.PrintName		= ""
ENT.Author			= ""
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.Spawnable		= false
ENT.AdminSpawnable	= false

function ENT:AcceptInput(name, activator, caller, data)
	
	if( self:OnInput(name, activator, caller, data) ) == false then
		return false
	end

	return true
end

function ENT:OnInput(name, activator, caller, data)
	
end

function ENT:Initialize()		
end

function ENT:OnRemove()
end

-- Call this after creating the entity.
function ENT:Replace(trigger)

	-- Important.
	self:SetName(trigger:GetName())
	
	local mins = trigger:OBBMins()
	local maxs = trigger:OBBMaxs()
	local pos = trigger:GetPos()
	local ang = trigger:GetAngles()
	
	trigger:Remove()	
		
	local w = (maxs.x - mins.x)
	local l = (maxs.y - mins.y)
	local h = (maxs.z - mins.z)

	mins = Vector(0 - (w / 2), 0 - (l / 2), 0 - (h / 2))
	maxs = Vector(w / 2, l / 2, h / 2)
	
	return self:Init(pos, ang, mins, maxs)
	
end

-- Call this after creating the entity.
function ENT:Init(pos, ang, mins, maxs)
			
	self:Spawn()
	self:SetPos(pos)
	self:DrawShadow(false)
	self:SetCollisionBounds(mins, maxs)
	self:SetSolid(SOLID_BBOX)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:SetMoveType(0)
	self:SetTrigger(true)
	
end

function ENT:SetupDataTables()
end

function ENT:StartTouch( ent )
end

function ENT:Trigger()
end

function ENT:EndTouch( ent )
end

function ENT:Draw()
end

function ENT:TriggerOutputs()
	if self.Outputs then
		for _, out in pairs(self.Outputs) do
			local entname = out[1]
			local cmd = out[2]
			local delay = out[3] or 0
			local param = out[4] or ""
			
			local targetents = ents.FindByName(entname) or {}
			for k,v in pairs(targetents) do
				v:Fire(cmd, param, delay)
			end
		end
	end
end