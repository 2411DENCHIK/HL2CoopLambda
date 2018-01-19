function GM:InitMapScript()
	if SERVER then
	
		self:SetupCheckpoint(
			Vector(456.98590087891, 1688.0145263672,-2733.9692382813), 
			Vector(-50, -50, 0), 
			Vector(50, 50, 50), 
			Vector(456.98590087891, 1688.0145263672,-2733.9692382813),
			Angle(0, 90, 0),
			nil,
			nil,
			true
		)
	
		-- First Door
		--
		local trigger_inner_door = ents.FindByName("trigger_inner_door")[1]
		local trigger = ents.Create("coop_triggeronce")
		trigger:Replace(trigger_inner_door)
		trigger.Outputs = {
			{"speaker_FollowMossNag", "TurnOff", 0.1},
			{"logic_FollowMossNag0", "Disable"},
			{"counter_lcs_mosstour03", "Add", 0, "1"},
			--{"inner_door", "Close"},
			{"logic_beams_elevator_1", "Trigger"},
		}
		trigger.Trigger = function(self)
			self:TriggerOutputs()
		end
		
		local secondary_spawn = ents.Create("info_player_start")
		secondary_spawn:SetPos(Vector(-41.356239318848, 2718.1889648438,-1279.96875))
		secondary_spawn:SetAngles(Angle(0, -90, 0))
		secondary_spawn.Master = false
		secondary_spawn:Spawn()
		
		-- Scan trigger
		--
		local trigger_startScene = ents.FindByName("trigger_startScene")[1]
		local logic_startScene = ents.FindByName("logic_startScene")[1]
		local trigger = ents.Create("coop_triggerplayerall")
		
		trigger:Replace(trigger_startScene, 30)
		trigger.OnCondition = function(self)
			self:StartScene()
		end
		trigger.OnTimeout = function(self)
			for k, v in pairs(player.GetAll()) do
				if not self:HasPlayer(v)  then
					v:SetPos(self:GetPos() + Vector(0, 0, 5))
				end
			end
			self:StartScene()
		end
		trigger.StartScene = function(self)				
			logic_startScene:Fire("Trigger")
			secondary_spawn.Master = true -- After connecting
			self:Remove()
		end
		
		-- Elevator trigger
		--
		local elevator_trigger_go_up_1 = ents.FindByName("elevator_trigger_go_up_1")[1]
		local trigger = ents.Create("coop_triggerplayerall")
		trigger:Replace(elevator_trigger_go_up_1, 30)
		trigger.Outputs = {
			{"elevator_link", "TurnOff"},
			{"portal_elevator_ride_1", "Open", 3.0},
			{"logic_RepairmenScene_Start", "Trigger", 14.2},
			{"ele_door_L", "Close"},
			{"elevator_lab", "Resume", 3.0},
			{"ele_door_R", "Close"},
			{"lcs_mosstour05", "Start"},
			{"logic_FollowMossNag", "Disable"},
			{"speaker_FollowMossNag", "TurnOff", 0.1},
			{"logic_kitchenscene_start", "Trigger", 6.5},
			{"logic_BGwalkersTopFloor_Kill", "Trigger"},
			{"logic_loungers_start", "Trigger", 4.0},
			{"brush_ele_door_PClip", "Enable"},
			{"prop_elevatordoor_top_1", "SetAnimation", 0, "close"},
		}
		trigger.OnCondition = function(self)
			self:Start()
		end
		trigger.OnTimeout = function(self)
			for k, v in pairs(player.GetAll()) do
				if not self:HasPlayer(v)  then
					v:SetPos(self:GetPos() + Vector(0, 0, 5))
				end
			end
			self:Start()
		end
		trigger.Start = function(self)				
			self:TriggerOutputs()
			self:Remove()
			
			secondary_spawn:SetPos(Vector(410.75183105469, 1914.8231201172,-2735.96875))
			secondary_spawn:SetAngles(Angle(0, 90, 0))
		end
		
		-- Don't close the doors.
		local trigger_alyxtour01 = ents.FindByName("trigger_alyxtour01")[1]
		local trigger = ents.Create("coop_triggeronce")
		trigger:Replace(trigger_alyxtour01)
		trigger.Outputs = {
			{"logic_kitchenscene_kill", "Trigger"},
			{"speaker_GoWithAlyxNag", "TurnOff", 0.1},
			{"logic_GoWithALyxNag", "Disable"},
			{"lcs_alyxtour01", "Start", 1.0},
			--{"lab_exit_door_raven", "Close"},
			{"logic_Xen_BeamsKill", "Trigger"},
			{"logic_beams_elevator_1", "Trigger"},
			--{"brush_exit_door_raven_PClip", "Enable"},
		}
		trigger.Trigger = function(self)
			self:TriggerOutputs()
		end
		
		ents.RemoveByName("trigger_alyxtour01_door_close")
		
		-- Alyx Tour 4b, this one appears to be also a changelevel trigger.
		local trigger_alyxtour04b = ents.FindByName("trigger_alyxtour04b")[1]
		local trigger = ents.Create("coop_triggerplayerall")
		trigger:Replace(trigger_alyxtour04b, 30)
		trigger.OnCondition = function(self)
			self:Start()
		end
		trigger.OnTimeout = function(self)
			for k, v in pairs(player.GetAll()) do
				if not self:HasPlayer(v)  then
					v:SetPos(self:GetPos() + Vector(0, 0, 5))
				end
			end
			self:Start()
		end
		trigger.Start = function(self)				
			game.ConsoleCommand("changelevel d1_eli_02\n")
			--self:Remove()
		end
		
	end
end
