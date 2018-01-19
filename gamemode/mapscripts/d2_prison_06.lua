function GM:InitMapScript()
	if SERVER then
		
		-- Apparently ai_goal_lead is broken in this map.
		local alyx_goal_lead_2 = ents.FindFirstByName("alyx_goal_lead_2")
		local coop_goal = ents.Create("coop_goal_lead")
		coop_goal:Replace(alyx_goal_lead_2)
		
		local alyx_goal_lead_introom_2 = ents.FindFirstByName("alyx_goal_lead_introom_2")
		local coop_goal = ents.Create("coop_goal_lead")
		coop_goal:Replace(alyx_goal_lead_introom_2)
		
		-- Elevator trigger
		--
		local elevator_trigger_go_up_1 = ents.FindByName("elevator_trigger_go_up_1")[1]
		local trigger = ents.Create("coop_triggerplayerall")
		trigger:Replace(elevator_trigger_go_up_1, 30)
		trigger:SetEnabled(false) -- Enabled by elevator_alyx_filter_1
		trigger.Outputs = {
			{"pclip_ele_door_B_1", "Enable", 0, ""},
			{"prop_elevatordoor_bottom_1", "SetAnimation", 1.0, "close"},
			{"introom_elevator_doors_1", "Close", 1.0, ""},
			{"ele_innerdoor_B_1", "Close", 0.2, ""},
			{"ele_innerdoor_T_1", "Close", 0, ""},
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
		end
		
		-- Doors with eli
		local int_door_close_inside_1 = ents.FindFirstByName("int_door_close_inside_1")
		local trigger = ents.Create("coop_triggeronce")
		trigger:Replace(int_door_close_inside_1, 30)
		trigger.Outputs = {
			{"lcs_np_cell01b", "Cancel", 0, ""},
			--{"pClip_introom_door_1", "Enable", 0, ""},
			--{"introom_door_1", "SetAnimation", 0, "close"},
			{"lcs_np_cell02", "Start", 0.1, ""},
			{"logic_EIntRoomNags", "CancelPending", 0, ""},
			{"logic_EIntRoomNags", "Kill", 0.2, ""},
			{"speaker_EIntRoomNags", "TurnOff", 0, ""},
			{"speaker_EIntRoomNags", "Kill", 0.2, ""},
		}
		trigger.Trigger = function(self)
			self:TriggerOutputs()
			
			timer.Create("COOP_FixSceneStuck", 1, 0, function()
				local lcs_np_cell02 = ents.FindFirstByName("lcs_np_cell02")
				if IsValid(lcs_np_cell02) then
					lcs_np_cell02:Fire("Resume")	-- Ugly but this way alyx wont get stuck.
				end
			end)			
		end
		trigger.Filter = function(self, ent)
			return IsValid(ent) and ent:IsPlayer()
		end
		
		-- We wan't to kill the timer when everything is over.
		local lcs_np_cell02 = ents.FindFirstByName("lcs_np_cell02")
		lcs_np_cell02:Fire("AddOutput", "OnTrigger2 logic_removetimer,Activate", 0)
		
		local coop_logic_removetimer = ents.Create("coop_condition")
		coop_logic_removetimer:SetName("coop_logic_removetimer")
		coop_logic_removetimer:Spawn()
		coop_logic_removetimer.OnActivate = function(self)
			print("Destroying Timer")
			timer.Destroy("COOP_FixSceneStuck")
		end
		
		-- Doesn't need to close when outside.
		ents.RemoveByName("int_door_close_outside_1")
		
		-- Intercept the door lock.
		local logic_alyx_EMP_3 = ents.FindFirstByName("logic_alyx_EMP_3")
		logic_alyx_EMP_3:Fire("AddOutput", "OnTrigger coop_door_controlroom_1,Activate", 0)
		
		local coop_door_controlroom_1 = ents.Create("coop_condition")
		coop_door_controlroom_1:SetName("coop_door_controlroom_1")
		coop_door_controlroom_1:Spawn()
		coop_door_controlroom_1.OnActivate = function(self)
			-- Rename door after unlocking and opening.
			local door_controlroom_1 = ents.FindFirstByName("door_controlroom_1")
			door_controlroom_1:Fire("Unlock")
			door_controlroom_1:Fire("Open")
			door_controlroom_1:SetName("foobar")
			DbgPrint("Renamed door")
		end
		
		-- Don't close the gate behind player.
		ents.RemoveByPos(Vector(512, -992, 36))
		
	end
end
