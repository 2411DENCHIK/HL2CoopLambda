GM.SkyboxOverride = "turquoise"

function GM:InitMapScript()
	if SERVER then
	
		ents.RemoveByName("ai_breakin_cop3goal3_blockplayer2")
		--ents.RemoveByName("npc_breakincop3")
		ents.RemoveByName("citizen_DoorBracer")
		ents.RemoveByName("brush_prevent_cops_getting_to_bracer")
		ents.RemoveByName("brush_breakin_blockplayer1")
		ents.RemoveByName("trigger_doorBracerBeckon")
		ents.RemoveByName("trigger_tv_turnoffall")
		ents.RemoveByName("trigger_tv_turnonall")
		ents.RemoveByName("ai_breakin_cop3goal3_blockplayer")
		ents.RemoveByName("ai_breakin_cop3goal4_blockplayer")
		ents.RemoveByName("ai_breakin_cop3goal4_blockplayer")
				
		timer.Create("AnnoyingPushTrigger", 1, 0, function()
			ents.RemoveByName("attic_door_push_trigger")
			ents.RemoveByName("attic_door_push")
		end)
		
		-- After the map is reset we shall turn it back on.
		local gordon_criminal_global = ents.FindFirstByName("gordon_criminal_global")
		gordon_criminal_global:Fire("TurnOn")
		
		-- Fix cops cock blocking and actually disappear
		local cop_goal_1 = ents.Create("npc_citizen")
		cop_goal_1:SetName("cop_goal_1")
		cop_goal_1:SetPos(Vector(-4408.5698242188, -4124.072265625,256.03125))
		cop_goal_1:Spawn()
		cop_goal_1:Activate()
		cop_goal_1:SetHealth(1)
		
		local cop_goal_2= ents.Create("npc_citizen")
		cop_goal_2:SetName("cop_goal_1")
		cop_goal_2:SetPos(Vector(-4193.2778320313, -4076.1928710938,256.03125))
		cop_goal_2:Spawn()
		cop_goal_2:Activate()
		cop_goal_1:SetHealth(1)
		
		local cop_goal_3 = ents.Create("info_target")
		cop_goal_3:SetPos(Vector(-4244.625, -4535.4995117188,256.03125))
		cop_goal_3:SetName("cop_goal_2")
		cop_goal_3:Spawn()
		
		local coop_breakin1 = ents.Create("coop_condition")
		coop_breakin1:SetName("coop_breakin1")
		coop_breakin1:Spawn()
		coop_breakin1.OnActivate = function(self)
		
			ents.RemoveByName("SS_Kickin")
			ents.RemoveByName("SS_Kickin_Runin")
			
			local npc_breakincop1 = ents.FindFirstByName("npc_breakincop1")
			npc_breakincop1:SetName("coop_npc_breakincop1")
			
			local npc_breakincop2 = ents.FindFirstByName("npc_breakincop2")
			npc_breakincop2:SetName("coop_npc_breakincop2")
			
			local npc_breakincop3 = ents.FindFirstByName("npc_breakincop3")
			npc_breakincop3:SetName("coop_npc_breakincop3")
			
			npc_breakincop1:ClearSchedule()
			npc_breakincop1:ExitScriptedSequence()
			npc_breakincop1:TaskComplete()
			npc_breakincop1:SetTarget(cop_goal_1)
			npc_breakincop1:SetEnemy(cop_goal_1)
			npc_breakincop1:SetLastPosition(cop_goal_1:GetPos())
			npc_breakincop1:SetNPCState(NPC_STATE_COMBAT)
			npc_breakincop1:SetSchedule(SCHED_FORCED_GO_RUN)
			
			npc_breakincop1:AddEntityRelationship(cop_goal_1, D_HT, 99)
			npc_breakincop1:AddEntityRelationship(cop_goal_2, D_HT, 99)
			npc_breakincop2:AddEntityRelationship(cop_goal_1, D_HT, 99)
			npc_breakincop2:AddEntityRelationship(cop_goal_2, D_HT, 99)
			
			cop_goal_1:AddEntityRelationship(npc_breakincop1, D_FR, 99)
			cop_goal_1:AddEntityRelationship(npc_breakincop2, D_FR, 99)
			cop_goal_2:AddEntityRelationship(npc_breakincop1, D_FR, 99)
			cop_goal_2:AddEntityRelationship(npc_breakincop2, D_FR, 99)
			
			npc_breakincop2:ClearSchedule()
			npc_breakincop2:ExitScriptedSequence()
			npc_breakincop2:TaskComplete()
			npc_breakincop2:SetTarget(cop_goal_2)
			npc_breakincop2:SetEnemy(cop_goal_2)
			npc_breakincop2:SetLastPosition(cop_goal_2:GetPos())
			npc_breakincop2:SetNPCState(NPC_STATE_COMBAT)
			npc_breakincop2:SetSchedule(SCHED_FORCED_GO_RUN)	
			
			npc_breakincop3:ClearSchedule()
			npc_breakincop3:ExitScriptedSequence()
			npc_breakincop3:TaskComplete()
			npc_breakincop3:SetTarget(cop_goal_3)
			npc_breakincop3:SetLastPosition(cop_goal_3:GetPos())
			npc_breakincop3:SetNPCState(NPC_STATE_IDLE)
			npc_breakincop3:NavSetGoal(Vector(-4244.625, -4535.4995117188,256.03125))
			npc_breakincop3:Fire("SetPoliceGoal", "cop_goal_2", 0)
			npc_breakincop3:SetTarget(cop_goal_2)
			npc_breakincop3:SetSchedule(SCHED_FORCED_GO)
			
			local relay_beating_start = ents.FindFirstByName("relay_beating_start")
			relay_beating_start:Fire("Trigger", "", 1)
						
		end
				
		ents.WaitForEntityByName("door_breakin1", function(ent)
			ent:Fire("AddOutput", "OnFullyOpen coop_breakin1,Activate", 0)
		end)
		
		--ents.RemoveByName("SS_Kickin")
		ents.FindFirstByName("brush_staircase_block"):SetKeyValue("Solidity", "0")
				
		-- Prevent going back
		local ent = ents.Create("coop_blockade")
		ent:SetPos(Vector(-4998.8413085938, -4166.681640625, 54.371845245361))
		ent:SetAngles(Angle(0, -90, 0))
		ent:SetModel("models/props_c17/door01_left.mdl")
		ent:Spawn()
				
	end
end