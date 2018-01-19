AddCSLuaFile()
DEFINE_BASECLASS( "base_point" )

ENT.Enabled = true

-- How often (in seconds) a new NPC will be spawned. If set to -1, a new NPC will be made when the last NPC dies.
ENT.SpawnFrequency = 0

-- Number of NPCs that will spawn before this spawner is exhausted.
ENT.MaxNPCCount = 0

-- Maximum number of live children allowed at any one time (new ones will not be made until one dies). If set to -1, no limit is applied.
ENT.MaxLiveChildren = 0

ENT.TemplateName = ""
ENT.NPCTargetname = ""

-- Internal Data.
ENT.NPCAlive = 0
ENT.NPCCount = 0
ENT.NPCSpawnTime = CurTime()

function ENT:Initialize()

	--DbgPrint("Initialize")
	
	DbgPrint(" -- Initialize: coop_npc_template_maker -- ")
	DbgPrint("  NPCTargetname", self.NPCTargetname)
	DbgPrint("  TemplateName", self.TemplateName)
	DbgPrint("  MaxLiveChildren", self.MaxLiveChildren)
	DbgPrint("  MaxNPCCount", self.MaxNPCCount)
	DbgPrint("  SpawnFrequency", self.SpawnFrequency)
	DbgPrint("  Enabled", self.Enabled)
			
end

function ENT:AcceptInput(name, activator, caller, data)
	
	name = string.Trim(name)
	DbgPrint("Received Input ("..tostring(self).."): "..name)
		
	if name == "Enable" then
		self.Enabled = true
	elseif name == "Disable" then
		self.Enabled = false
	elseif name == "Spawn" then
		self:SetupNPC()
	end
	
	return true
	
end

function ENT:Replace(ent)

	if not IsValid(ent) then
		DbgPrint("Tried to replace an invalid entity: " .. tostring(ent))
		return
	end
	
	DbgPrint(" -- coop_npc_template_maker replacement: " .. tostring(ent) .. " -- ")
	
	self.NPCTargetname = ent:GetKeyValue("NPCTargetname") or ""
	self.TemplateName = ent:GetKeyValue("TemplateName") or ""
	self.MaxLiveChildren = ent:GetKeyValue("MaxLiveChildren") and tonumber(ent:GetKeyValue("MaxLiveChildren")) or 0	
	self.MaxNPCCount = ent:GetKeyValue("MaxNPCCount") and tonumber(ent:GetKeyValue("MaxNPCCount")) or 0
	self.SpawnFrequency = ent:GetKeyValue("SpawnFrequency") and tonumber(ent:GetKeyValue("SpawnFrequency")) or 0	
	self.Enabled = ent:GetKeyValue("StartDisabled") and (tonumber(ent:GetKeyValue("StartDisabled")) == 0) and true
	
	local pos = ent:GetPos()
	local name = ent:GetName()
	
	self:SetName(name)
	self:SetPos(pos)
	self:Spawn()
	
	-- Remove original entity.	
	ent:Remove()
		
end

function ENT:SetupDataTables()
end

function ENT:Think()
	
	if self.Enabled == false then
		return
	end
		
	--DbgPrint("Thinking!")
	
	local elapsedTime = CurTime() - self.NPCSpawnTime
	local allowSpawn = false
	local exhausted = false
	
	if self.MaxNPCCount > 0 then
		
		if self.NPCCount >= self.MaxNPCCount then
			allowSpawn = false
			exhausted = true
		else
			allowSpawn = true
		end
		
	else
	
		allowSpawn = true
		
	end
	
	if allowSpawn == true and self.NPCAlive < self.MaxLiveChildren then
		
		if elapsedTime >= self.SpawnFrequency then
			self.NPCSpawnTime = CurTime()			
			self:SetupNPC()
		else
			--DbgPrint("Can't spawn NPC, frequency not passed by")
		end
		
	elseif allowSpawn == true then
	
		--DbgPrint("We are beyond MaxLiveChildren (" .. tostring(self.MaxLiveChildren) .. ")")
		
	else
	
		if exhausted == true then
			DbgPrint("NPCs exhausted (" .. tostring(self) .. ")")
			self:Remove()
		else
			DbgPrint("Not allowed to spawn, strange case")
		end
		
	end
		
end

function ENT:SetupNPC()

	local targetName = ""
	local class = ents.GetCachedClassByName(self.TemplateName)

	if class == nil then
		local ent = ents.FindFirstByName(self.NPCTargetname)
		targetName = self.NPCTargetname
		if not IsValid(ent) then
			DbgPrint("Unable to find cached template info")
			return
		else
			class = ent:GetClass()
		end
	end
	
	DbgPrint(tostring(self) .. ": creating new npc of template '"..self.TemplateName.."'")
		
	local npc = ents.Create(class)
	npc:SetPos(self:GetPos())
	npc:SetName(targetName)
	npc:Spawn()
	npc:Activate()
		
	self:RegisterNPC(npc)
	
end

function ENT:RegisterNPC(npc)

	local this_self = self
		
	npc.OnKilled = function()
		DbgPrint("NPC got killed, decrementing coop_npc_maker npc count")
		if IsValid(this_self) then
			this_self.NPCAlive = this_self.NPCAlive - 1
		end
	end
	
	self.NPCAlive = self.NPCAlive + 1
	self.NPCCount = self.NPCCount + 1
	
end
