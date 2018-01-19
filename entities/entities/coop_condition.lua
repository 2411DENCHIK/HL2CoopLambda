AddCSLuaFile()
DEFINE_BASECLASS( "base_anim" )

ENT.Enabled			= true

function ENT:Initialize()

	DbgPrint("Initialize")
			
end

function ENT:AcceptInput(name, activator, caller, data)
	
	name = string.Trim(name)
	DbgPrint("Received Input ("..tostring(self).."): "..name)
	
	if name == "Enable" then
		DbgPrint("Condition::OnEnable")
		self.Enabled = true
		self:OnEnabled()
	elseif name == "Disable" then
		DbgPrint("Condition::OnDisable")
		self.Enabled = false
		self:OnDisabled()
	elseif name == "Activate" then
		DbgPrint("Condition::OnActivate")
		self:OnActivate(activator)
	elseif name == "Trigger" then
		DbgPrint("Condition::OnTrigger")
		self:OnTrigger()
	elseif name == "Start" then
		DbgPrint("Condition::OnStart")
		self:OnStart()
	elseif name == "Reload" then
		DbgPrint("Condition::Reload")
		self:OnReload()
	end
	
	return true
	
end

function ENT:OnEnabled()

end

function ENT:OnDisabled()

end

function ENT:OnActivate()

end

function ENT:OnTrigger()

end

function ENT:OnStart()

end

function ENT:OnReload()

end

function ENT:SetEnabled(state)
	self.Enabled = state
end

-- Call this after creating the entity.
function ENT:Replace(trigger)

	self:SetName(trigger:GetName())	
	trigger:Remove()
	
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
			
			local targetents = ents.FindByName(entname) or {}
			for k,v in pairs(targetents) do
				v:Fire(cmd, param, delay)
			end
		end
	end
end