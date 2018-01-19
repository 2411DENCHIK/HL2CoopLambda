function GM:InitMapScript()
	if SERVER then
	
		ents.RemoveByName("brush_soda_clip_player")
		ents.RemoveByName("brush_soda_clip_player_2")
		ents.RemoveByName("Alyx_lab_entry_closedoor_1")
		ents.RemoveByName("lab_door_clip")
		
		-- Don't let alyx block the way.
		--local mark_alyx_intro = ents.FindByName("mark_alyx_intro")[1]
		--mark_alyx_intro:SetPos(Vector(-6502.6450195313, -897.01739501953,0.03125))
		
		-- Make sure barney is not getting blocked by players, move him somewhere safer.
		local barney_enter_lab_spawn_1 = ents.FindByName("barney_enter_lab_spawn_1")[1]
		barney_enter_lab_spawn_1:SetPos(Vector(-5821.6245117188, -662.92108154297,64.03125))
		local Barney_lab_entry_opendoor_1 = ents.FindByName("Barney_lab_entry_opendoor_1")[1]
		Barney_lab_entry_opendoor_1:SetPos(Vector(-5821.6245117188, -662.92108154297,64.03125))
		
		-- Set the proper flags on the ichy
		ents.WaitForEntityByName("viewcontrol_ickycam", function(ent)
			ent:Remove()
		end)
		
		-- Keep suits available						
		local suit = ents.FindFirstByClass("item_suit")
		
		local suitspawner = ents.Create("coop_triggermultiple")
		suitspawner:Replace(suit)
		suitspawner.Outputs = {
			{"song_suit", "PlaySound", 0, ""},
			{"phys_knocked_nag_rl", "Kill", 0, ""},
			{"hevnag_speaker", "Kill", 0, ""},
			{"get_suit_math_1", "Add", 0, "1"},
			{"suitnag_loopall01_lcs", "Kill", 0, ""},
		}
		suitspawner.InitialTrigger = false
		suitspawner.Filter = function(self, ent)
			if IsValid(ent) and ent:IsPlayer() and not ent:IsSuitEquipped() then
				return true
			end
			return false
		end
		suitspawner.Trigger = function(self, ent)
			ent:Give("item_suit")
			if self.InitialTrigger == false then
				self.InitialTrigger = true
				self:TriggerOutputs()
			end
		end
		suitspawner:SetModel("models/items/hevsuit.mdl")
		suitspawner:SetNoDraw(false)
		
		-- Avoid closing the door
		local start_first_teleport_01 = ents.FindByName("start_first_teleport_01")[1]
		local trigger = ents.Create("coop_triggeronce")
		trigger:SetEnabled(false)
		trigger:Replace(start_first_teleport_01)
		trigger.Outputs = {
			{"sounds_lab_1", "Kill", 0.1, ""},
			--{"lab_door", "Close", 0, ""},
			{"portroom_speaker", "Kill", 0, ""},
			{"Surveillance_monitor_1", "Disable", 0, ""},
			{"destination_monitor_1", "Enable", 6.0, ""},
			{"teleport_01_scene", "Start", 2.0, ""},
			--{"lab_door_clip", "Close", 0, ""},
			{"KleinerTPnag_Loop_Kleiner01_lcs", "Kill", 2.0, ""},
			{"BarneyTPnag_Loop_Barney01_lcs", "Kill", 2.0, ""},
			{"destination_monitor_static_1", "Enable", 5.0, ""},
			{"destination_monitor_static_1", "Disable", 6.5, ""},
			{"destination_monitor_static_1", "Enable", 12.0, ""},
			{"destination_monitor_1", "Enable", 13.0, ""},
			{"destination_monitor_static_1", "Disable", 14.0, ""},
			{"destination_monitor_1", "Enable", 15.0, ""},
			{"sounds_lab_1", "StopSound", 0, ""},
		}
		trigger.Trigger = function(self)
			
			local lab_door = ents.FindByName("lab_door")[1]
			if IsValid(lab_door) then
				lab_door:SetName("stopannoyingmewithallthetriggers")
				self:TriggerOutputs()
			end
			
		end
		
		local teleport_in = ents.FindByName("player_in_teleport")[1]		
		local tportnag_speaker = ents.FindByName("tportnag_speaker")[1]
		local teleport_starter = ents.FindByName("kleiner_teleport_player_starter_1")[1]
		
		local trigger = ents.Create("coop_triggerplayerall")
		trigger:Replace(teleport_in, 30)
		
		-- All players are in.
		trigger.OnCondition = function(self)
			self:DoTeleport()
		end
		
		-- On Timeout
		trigger.OnTimeout = function(self)
			for k, v in pairs(player.GetAll()) do
				if not self:HasPlayer(v)  then
					v:SetPos(Vector(-7186.4594726563, -1179.8493652344,57.583084106445))
				end
			end
			self:DoTeleport()
		end
		
		trigger.DoTeleport = function(self)
			-- Kill barneys complaining
			if IsValid(tportnag_speaker) then
				tportnag_speaker:Fire("Kill")
			end
			-- Fire up the teleporter
			teleport_starter:Fire("Trigger")
			-- We don't want it to trigger again.
			self:Remove()
			
			for k,v in pairs(player.GetAll()) do
				DbgPrint("Locking all players")
				v:LockPosition(true)
			end
		end
		
		-- Unlock players after they arrive.
		local secondary_spawn = ents.Create("info_player_start")
		secondary_spawn:SetPos(Vector(-10366.333984375, -4717.9291992188,320.03125))
		secondary_spawn:SetAngles(Angle(0, -180, 0))
		secondary_spawn:Spawn()
		secondary_spawn.Master = false
		
		local teleport_condition = ents.Create("coop_condition")
		teleport_condition:SetName("coop_teleport_players")
		teleport_condition:Spawn()
		teleport_condition.OnEnabled = function(self)
			DbgPrint("Locking all players")
			for k,v in pairs(player.GetAll()) do
				v:LockPosition(true)
			end
			secondary_spawn.Master = true -- Also set new spawnpoint for players that joined in the middle of the teleport event.
		end
		teleport_condition.OnDisabled = function(self)
			DbgPrint("Unlocking all players")
			for k,v in pairs(player.GetAll()) do
				v:LockPosition(false)
			end
		end
		
		local t1_gordon_teleport_rl_1 = ents.FindFirstByName("t1_gordon_teleport_rl_1")
		t1_gordon_teleport_rl_1:Fire("AddOutput", "OnTrigger coop_teleport_players,Enable")
		
		local fog_relay_outside = ents.FindFirstByName("fog_relay_outside")
		fog_relay_outside:Fire("AddOutput", "OnTrigger coop_teleport_players,Disable")
		
	end
end