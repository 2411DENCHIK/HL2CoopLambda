AddCSLuaFile()
DEFINE_BASECLASS( "base_anim" )

ENT.PrintName		= ""
ENT.Author			= ""
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.Spawnable		= false
ENT.AdminSpawnable	= false

ENT.Enabled			= true

if CLIENT then
	ENT.DebugMat = Material("models/wireframe")
end

function ENT:Initialize()

	DbgPrint("Initialize")
	
	if CLIENT then 
		hook.Add("PostDrawOpaqueRenderables", self, self.DrawDebugBox)
	end
		
end

function ENT:AcceptInput(name, activator, caller, data)
	
	DbgPrint("Received Input ("..tostring(self).."): "..name)
	
	if name == "Enable" then
		print("Enabled trigger")
		self.Enabled = true
	elseif name == "Disable" then
		print("Disabled trigger")
		self.Enabled = false
	end
	
	return true
	
end

function ENT:SetEnabled(state)
	self.Enabled = state
end

function ENT:OnRemove()
	if CLIENT then 
		hook.Remove("PostDrawOpaqueRenderables", self)
	end
end

function ENT:Filter(ent)
	return true -- Always trigger
end

-- Call this after creating the entity.
function ENT:Replace(trigger)

	self:SetName(trigger:GetName())
	
	local mins, maxs = trigger:GetCollisionBounds()
	local pos = trigger:GetPos()
	local ang = trigger:GetAngles()
	
	trigger:Remove()	
		
	return self:Init(pos, ang, mins, maxs)
	
end

-- Call this after creating the entity.
function ENT:Init(pos, ang, mins, maxs)

	DbgPrint("Creating Trigger at " .. tostring(pos) .. "\n\tMins: "..tostring(mins) .. "\n\tMaxs: " .. tostring(maxs))
			
	self:Spawn()
	self:SetPos(pos)
	self:DrawShadow(false)
	self:SetCollisionBounds(mins, maxs)
	self:SetSolid(SOLID_BBOX)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:SetMoveType(0)
	self:SetTrigger(true)
	self:SetAngles(ang)
	
end

function ENT:SetupDataTables()
	
end

function ENT:Touch( ent )
	if IsValid(ent) and ent:IsPlayer() and self.Enabled == true then
		if self:Filter(ent) then
			self:Trigger(ent)
			self:Remove()
		end
	end
end

function ENT:Trigger(ent)
	return false -- Override me.
end

function ENT:EndTouch( ent )
end

function ENT:Draw()
end

function ENT:DrawDebugBox()
	if GetConVarNumber("coop_drawtriggers") >= 1 then
		
		local mins = self:OBBMins()
		local maxs = self:OBBMaxs()
		local pos = self:GetPos() 
		local ang = self:GetAngles()
		
		render.SuppressEngineLighting( true )
		render.SetColorModulation( 1, 1, 1 )
		render.SetMaterial(self.DebugMat)
		render.SetBlend(1)
		render.DrawBox(pos, ang, mins, maxs, Color(255, 255, 255, 155))
		render.SuppressEngineLighting( false )
	end
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