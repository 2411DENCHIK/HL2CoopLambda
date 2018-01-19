AddCSLuaFile()
DEFINE_BASECLASS( "base_anim" )

ENT.Enabled			= true

function ENT:Initialize()

	DbgPrint("Initialize")
			
end

function ENT:AcceptInput(name, activator, caller, data)
	
	DbgPrint("Received Input ("..tostring(self).."): "..name)
	
	if name == "Enable" then
		self.Enabled = true
		self:OnEnabled()
	elseif name == "Disable" then
		self.Enabled = false
		self:OnDisabled()
	elseif name == "Activate" then
		self:OnActivate()
	end
	
	return true
	
end

function ENT:OnEnabled()

end

function ENT:OnDisabled()

end

function ENT:OnActivate()

	DbgPrint("Goal Activated")
	
	local actor = ents.FindByName(self.Actor)[1]
	local goal = ents.FindByName(self.Target)[1]
	
	if not IsValid(actor) or not IsValid(goal) then
		return
	end
	
	local pos = goal:GetPos()
	
	print("Goal: ", goal, tostring(pos))
	
	actor:SetTarget(goal)
	actor:SetLastPosition(pos)
	actor:ClearSchedule()
	actor:ExitScriptedSequence()
	actor:TaskComplete()
	actor:SetNPCState(NPC_STATE_IDLE)
	
	if self.Run then
		actor:SetSchedule(SCHED_FORCED_GO_RUN)
	else
		actor:SetSchedule(SCHED_FORCED_GO)
	end
	
end

function ENT:SetEnabled(state)
	self.Enabled = state
end

function ENT:OnRemove()
end

-- Call this after creating the entity.
function ENT:Replace(goal)

	PrintTable(goal:GetRealKeyValues())
	
	self:SetName(goal:GetName())	
	self.Target = goal:GetKeyValue("goal")
	self.Actor = goal:GetKeyValue("actor")
	self.Run = (goal:GetKeyValue("Run") or "0") == "1"
	
	goal:Remove()	
		
	self:Spawn()
	
end

function ENT:SetupDataTables()
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
			
			local ent = ents.FindByName(entname)[1]
			if not IsValid(ent) then 
				continue 
			end
			ent:Fire(cmd, param, delay)
		end
	end
end