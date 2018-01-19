function GM:InitMapScript()
	if SERVER then	

		self:SetupCheckpoint(
			Vector(-1599.8081054688, 5506.1899414063,-47.928123474121), 
			Vector(-35, -5, 0), 
			Vector(35, 5, 100), 
			Vector(-1599.8081054688, 5506.1899414063,-46.928123474121), 
			Angle(0,-90,0)
		)
		
		local gman = ents.Create("npc_gman")
		gman:SetPos(Vector(-3068.6823730469, 4161.5805664063,-95.96875))
		gman:SetAngles(Angle(0,90,0))
		gman:Spawn()
		gman:Activate()

		local gman_trigger = ents.Create("coop_triggeronce")
		gman_trigger:Init(Vector(-3071.0554199219, 4987.7153320313,-47.77127456665), Angle(0,0,0), Vector(-50,-50,-50), Vector(50, 50, 50))
		gman_trigger.Filter = function(self, ent)
			return IsValid(ent) and ent:IsPlayer()	
		end
		gman_trigger.Trigger = function(self)
			DbgPrint("Triggered")
			gman:SetLastPosition(Vector(-3165.1037597656, 4065.1303710938,-95.96875))
			gman:SetSchedule(SCHED_FORCED_GO)
			timer.Simple(3, function()
				if IsValid(gman) then
					gman:Remove()
				end
			end)
		end


	end
end
