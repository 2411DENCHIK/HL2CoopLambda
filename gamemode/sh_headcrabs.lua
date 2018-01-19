
if SERVER then

	AddCSLuaFile()
	
	util.AddNetworkString("BecomeZombiePlayer")
	
	local function SendPlayerZombieState(ply, zombie, state)
		net.Start("BecomeZombiePlayer")
		net.WriteEntity(ply)
		net.WriteUInt(zombie:EntIndex(), 32)
		net.WriteBit(state)
		net.Broadcast()
	end
	
	function GM:PlayerZombieDeath(ply, zombie)
	
		DbgPrint("Removing player zombie: "..tostring(ply), zombie)
				
		--zombie:Remove()
		SafeRemoveEntityDelayed(zombie, 0.001)
		ply.Zombie = nil
		
		ply:CreateRagdoll()
		local ragdoll = ply:GetRagdollEntity()

		self:CreateEntityRagdoll(ply, ragdoll)
		
		SendPlayerZombieState(ply, zombie, false)
		
	end
	
	function GM:PlayerBecomeZombie(ply, headcrab)
	
		DbgPrint("Creating player zombie: "..tostring(ply), zombie)
		
		local zombie = ents.Create("npc_zombie")
		zombie:SetPos(ply:GetPos())
		zombie:Spawn()
		zombie.OnDeath = function(self, attacker, weapon)
			
			GAMEMODE:PlayerZombieDeath(ply, self)
			
		end
		
		--headcrab:SetOwner(zombie)
		SafeRemoveEntityDelayed(headcrab, 0.001)
		
		ply.Zombie = zombie
		SendPlayerZombieState(ply, zombie, true)
		
	end
	
	hook.Add("PlayerShouldBecomeZombie", "HL2CoopBecomeZombie", function(ply, headcrab)
	
		GAMEMODE:PlayerBecomeZombie(ply, headcrab)
		
	end)
	
else

	function GM:PlayerBecomeZombie(ply, zombie)
	
		DbgPrint("Creating player zombie: "..tostring(ply), zombie)
				
		-- Hide from drawing
		ents.WaitForEntity(zombie, function(self)
			DbgPrint("Zombie created on client")
			
			ply.Zombie = self
			self.Player = ply
				
			local zombie = self
			local mdl = ply:GetModel()

			local bonemdl = ClientsideModel(mdl)
			bonemdl:SetParent(self)
			bonemdl:AddEffects(EF_BONEMERGE)
			bonemdl.RenderOverride = function(self)
				if not IsValid(zombie) then
					return
				end
				
				if self:GetParent() ~= zombie then
					self:SetParent(zombie)
					self:AddEffects(EF_BONEMERGE)
				end
				
				self:DrawModel()
			end
			ply.Zombie.BoneMdl = bonemdl
					
			local headcrab = ClientsideModel("models/headcrabclassic.mdl")
			--headcrab:SetPos(pos)
			headcrab:SetParent(zombie)
			headcrab:AddEffects(EF_BONEMERGE)
			--headcrab:Spawn()
			headcrab.RenderOverride = function(self)
			
				if not IsValid(zombie) then
					return
				end
								
				local id = zombie:LookupAttachment("chest")
				local data = zombie:GetAttachment(id)
				local ang = data.Ang
				local pos = data.Pos
				
				for i=1, self:GetBoneCount() do
					local boneName = self:GetBoneName(i)
					if boneName == "HeadcrabClassic.UpperArmR_Bone" then
						self:ManipulateBoneAngles(i, Angle(0, 100, 0))
					elseif boneName == "HeadcrabClassic.UpperArmL_Bone" then
						self:ManipulateBoneAngles(i, Angle(0, -100, 0))
					end
				end
				
				self:SetPos(pos + (ang:Up() * 5.1) + (ang:Forward() * 5.5))
				self:SetAngles(data.Ang)
				
				self:DrawModel()
			end

			-- Hide zombie NPC.
			self.RenderOverride = function() end
			
		end)
		
	end
	
	function GM:PlayerZombieDeath(ply, zombie)
	
		DbgPrint("Removing player zombie: "..tostring(ply), zombie)
		
		-- In case the headcrab is still alive we want to see it.
		zombie.RenderOverride = nil
				
		if IsValid(ply.Zombie) and IsValid(ply.Zombie.BoneMdl) then
			ply.Zombie.BoneMdl:Remove()
		end

		if IsValid(ply.Zombie) and IsValid(ply.Zombie.Headcrab) then
			ply.Zombie.Headcrab:Remove()
		end

		ply.Zombie = nil
		ply:BecomeRagdollOnClient()
		
	end
	
	net.Receive("BecomeZombiePlayer", function(len)
	
		local ply = net.ReadEntity()
		local zombie = net.ReadUInt(32)
		local state = (net.ReadBit() == 1)
		
		if state == true then
			GAMEMODE:PlayerBecomeZombie(ply, zombie)
		else
			GAMEMODE:PlayerZombieDeath(ply, Entity(zombie))
		end
		
	end)
	
	hook.Add("CreateClientsideRagdoll", "HL2CoopZombieRagdoll", function(ent, ragdoll)
	
		DbgPrint("Ragdoll created: "..tostring(ent))
		
		if IsValid(ent) and IsValid(ent.Player) then
			ragdoll:Remove()
		end
		
	end)
	
end
