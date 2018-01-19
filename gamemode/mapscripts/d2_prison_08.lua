function GM:InitMapScript()
	if SERVER then

		for k,v in pairs(ents.FindByClass("ai_goal_lead")) do
			local coop_goal = ents.Create("coop_goal_lead")
			coop_goal:Replace(v)
			print("Replacing ai_goal_lead: ",v)
		end
		
		local alyx_goal_follow_1 = ents.FindFirstByName("alyx_goal_follow_1")
		alyx_goal_follow_1:Fire("Activate")
		
		-- First Door
		local trigger_teleport01 = ents.FindFirstByName("trigger_teleport01")
		local trigger = ents.Create("coop_triggeronce")
		trigger:Replace(trigger_teleport01, 30)
		trigger.Outputs = {
			{"mossman_trap_monitor_1", "Disable", 0, ""},
			--{"logic_door_comb_1_close", "Trigger", 0, ""},
			{"lcs_np_teleport01", "Start", 1.0, ""},
			{"soldier_radio_1", "PlaySound", 10.0, ""},
			{"soldier_radio_2", "PlaySound", 16.0, ""},
		}
		trigger.Filter = function(self, ent)
			return IsValid(ent) and ent:IsPlayer()
		end
		trigger.Trigger = function(self)
			self:TriggerOutputs()		
		end
		
		-- Mossman door
		local trigger_close_console_door_1 = ents.FindFirstByName("trigger_close_console_door_1")
		local trigger = ents.Create("coop_triggeronce")
		trigger:Replace(trigger_close_console_door_1)
		trigger.Outputs = {
			--{"prop_camerasx", "Kill", 0, ""},
			--{"sec_room_door_1", "Close", 0, ""},
			{"logic_apply_relationships_1", "Trigger", 0, ""},
			--{"combine_door_1", "SetAnimation", 0, "Close"},
			--{"combine_door_1", "SetAnimation", 5.5, "idle_closed"},
		}
		trigger.Filter = function(self, ent)
			return IsValid(ent) and ent:IsPlayer()
		end
		trigger.Trigger = function(self)
			self:TriggerOutputs()		
		end
		
		-- Teleporter Room Door.
		local trigger_tp_scene_start = ents.FindFirstByName("trigger_tp_scene_start")
		local trigger = ents.Create("coop_triggeronce")
		trigger:Replace(trigger_tp_scene_start)
		trigger.Outputs = {
			{"logic_teleport_wheels_start_1", "Trigger", 0, ""},
			{"lcs_np_teleport04", "Start", 0, ""},
			--{"PClip_sec_tp_door_1", "Enable", 0, ""},
			{"music_song24", "PlaySound", 1.0, ""},
		}
		trigger.Filter = function(self, ent)
			return IsValid(ent) and ent:IsPlayer()
		end
		trigger.Trigger = function(self)
			self:TriggerOutputs()
			
			-- Also rename the doors here, we don't have to override the lcs_np_teleport04 this way.
			local combine_door_2 = ents.FindFirstByName("combine_door_2")
			combine_door_2:SetName("combine_door_22")
			
			local sec_tp_door_1 = ents.FindFirstByName("sec_tp_door_1")
			sec_tp_door_1:SetName("sec_tp_door_11")		
		end
		
		-- Fix Turrets
		for k,v in pairs(ents.FindByClass("npc_turret_floor")) do
			v:SetKeyValue("spawnflags", "704")
		end
		for k,v in pairs(ents.FindByName("turret_buddy")) do
			v:SetKeyValue("spawnflags", "576")
		end
		-- Add another turret into empty closet.
		local turret = ents.Create("npc_turret_floor")
		turret:SetPos(Vector(-272, 810, 997))
		turret:SetKeyValue("spawnflags", "640")
		turret:SetAngles(Angle(0,180,0))
		turret:SetName("turret_buddy")
		turret:Spawn()
		turret:Fire("AddOutput", "OnPhysGunPickup !activator,Enable,-1,0,-1",0)
				
		-- Teleport Trigger
		local trigger_teleport_player_enter_1 = ents.FindFirstByName("trigger_teleport_player_enter_1")
		local trigger = ents.Create("coop_triggerplayerall")
		trigger:Replace(trigger_teleport_player_enter_1, 30)
		trigger.Outputs = {
			{"teleport_lift_platform_1", "SetAnimation", 0, "close"},
			{"teleport_front_door_clip_1", "Enable", 0, ""},
			{"prop_Tport_shields", "Skin", 0, "0"},
			{"forcefield_sound_far_6", "PlaySound", 0, ""},
			{"shield_sound_trigger_6", "Enable", 0, ""},
			{"PClip_teleport_shield_final", "Enable", 0, ""},
			{"physexp_final_assault_1", "Explode", 0, ""},
			{"maker_combine_final_1", "Spawn", 0.50, ""},
			{"teleport_lift_train_1", "Resume", 1.00, ""},
			{"teleport_lift_train_1", "SetSpeed", 1.00, "40"},
			{"holster", "Start", 1.00, ""},
			{"brush_teleport_shield_1", "Enable", 1.10, ""},
			{"sound_teleport_shield_1", "PlaySound", 1.10, ""},
			{"assault_combine_teleporter_final", "StartSchedule", 1.20, ""},
			{"logic_final_destruction", "Trigger", 2.00, ""},
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
	end
end
