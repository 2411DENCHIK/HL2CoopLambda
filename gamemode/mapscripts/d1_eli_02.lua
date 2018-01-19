function GM:InitMapScript()
	if SERVER then	

		local trigger_scrapyard_start = ents.FindByName("trigger_scrapyard_start")[1]
		local trigger = ents.Create("coop_triggeronce")
		trigger:Replace(trigger_scrapyard_start)
		trigger.Outputs = {
			{"brush_doorAirlock_opened_PClip", "Enable"},
			--{"airlock_south_door_exitb", "Close"},
			--{"airlock_south_door_exit", "Close"},
			{"lcs_gravgun01", "Start", 2.0},
			--{"brush_doorAirlock_PClip_2", "Enable"},
		}
		trigger.Trigger = function(self)
			self:TriggerOutputs()
		end
		
		-- Handle the command to give the gravity gun.
		local command_physcannon = ents.FindByName("command_physcannon")[1]
		local commands = ents.Create("coop_commands")
		commands:Replace(command_physcannon)
		commands.OnInput = function(self, name, activator, caller, data)
			if data then
				data = string.Split(data, " ")
				if data[1] == "give" then
					for k,v in pairs(player.GetAll()) do
						v:Give(data[2])
					end
				end
			end
		end
		
		-- Don't close the doors.
		local trigger_attack02 = ents.FindByName("trigger_attack02")[1]
		local trigger = ents.Create("coop_triggeronce")
		trigger:SetEnabled(false)
		trigger:Replace(trigger_attack02)
		trigger.Outputs = {
			{"chopper_flyby_04", "FlyToSpecificTrackViaPath", 0, "fly2_4"},
			{"chopper_flyby_04", "StartPatrol", 0, ""},
			{"soundscape_eli_02_lower_corridor_1", "Enable", 0, ""},
			{"speaker_GoBackAirNag", "TurnOff", 0, ""},
			{"logic_kill_scanners", "Trigger", 0, ""},
			{"logic_battlefx_start_1", "Trigger", 0, ""},
			{"ambient_attack_start_1", "PlaySound", 1.5, ""},
			{"logic_turnon_airlockB_1", "Trigger", 3.0, ""},
			--{"airlock_south_door_exit", "Close", 0, ""},
			{"lcs_attack02", "Start", 0.1, ""},
			--{"airlock_south_door_exitb", "Close", 0, ""},
			{"lcs_attack01", "Cancel", 0, ""},
		}
		trigger.Trigger = function(self)
			self:TriggerOutputs()
		end
		
		-- Ravenholm doors, don't close em :(
		--
		local trigger_RavenDoor_Drop = ents.FindByName("trigger_RavenDoor_Drop")[1]
		local trigger = ents.Create("coop_triggeronce")
		trigger:SetEnabled(false)
		trigger:Replace(trigger_RavenDoor_Drop)
		trigger.Outputs = {
			{"ambient_attack_battle_2", "StopSound", 0.7, ""},
			{"remove_trigger", "Enable", 0, ""},
			--{"SS_Dog_RavenDoor_Drop", "BeginSequence", 0, ""},
			{"ambient_attack_battle_2", "StopSound", 0.5, ""},
			{"ambient_attack_battle_2", "Kill", 1.0, ""},
		}
		trigger.Trigger = function(self)
			self:TriggerOutputs()
		end
		
	end
end
