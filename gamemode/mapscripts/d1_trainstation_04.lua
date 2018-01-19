GM.SkyboxOverride = "turquoise"

function GM:InitMapScript()
	if SERVER then
				
		ents.RemoveByName("door_inside_secret")
		ents.RemoveByName("window_player_clip")

		-- Prevent going back
		local ent = ents.Create("coop_blockade")
		ent:SetPos(Vector(-3099.0998535156, -3520.8740234375, 438.38677978516))
		ent:SetAngles(Angle(0, -90, 0))
		ent:SetModel("models/props_c17/door01_left.mdl")
		ent:Spawn()
			
		-- The first cops are are able to kill newly spawned players, we don't want that
		ents.RemoveByPos(Vector(-3464, -3584, 624))
		
		-- Allow everyone to see alyx her face.
		ents.WaitForEntityByName("blackout_viewcontroller", function(ent)
			ent:SetKeyValue("spawnflags", "156")
		end)
		
		local tracktrain_elevator	= ents.FindFirstByName("tracktrain_elevator")
		
		local checkpoint = ents.Create("info_player_start")
		checkpoint:SetPos(Vector(-7734.7016601563, -3957.0302734375,388.03125))
		checkpoint:SetKeyValue("StartDisabled", "1")
		checkpoint:SetAngles(Angle(0,0,0))
		checkpoint:Spawn()
		checkpoint:SetParent(tracktrain_elevator)
		checkpoint.Master = false
		
		local door_elevator_R = ents.FindByName("door_elevator_R")[1]
		local door_elevator_L = ents.FindByName("door_elevator_L")[1]
		local door_elevator_topsliding = ents.FindByName("door_elevator_topsliding")[1]
		local speaker_alyxfollow1 = ents.FindByName("speaker_alyxfollow1")[1]
		local lcs_alyxgreet02 = ents.FindByName("lcs_alyxgreet02")[1]
		local prop_elevatordoor = ents.FindByName("prop_elevatordoor")[1]
		
		local elevator_trigger = ents.FindByName("trigger_elevator_go_down")[1]
		local trigger = ents.Create("coop_triggerplayerall")
		trigger:Replace(elevator_trigger, 10)
		
		-- Replace knockout scene.
		ents.RemoveByName("relay_knockout_start")
		ents.RemoveByName("ss_alyx_intro_bendover")
		ents.RemoveByName("trigger_knockout_teleport")
		
		local door_knockout_1 = ents.FindFirstByName("door_knockout_1")
		door_knockout_1:Fire("Lock")
		door_knockout_1:SetKeyValue("speed", "100")
		door_knockout_1:SetKeyValue("opendir", "1")
		
		local alyx_pos_fix = ents.Create("coop_condition")
		alyx_pos_fix:SetName("alyx_pos_fix")
		alyx_pos_fix:Spawn()
		alyx_pos_fix.OnTrigger = function(self)
			DbgPrint("YEP this is working")
			local alyx = ents.FindFirstByName("alyx")
			alyx:SetPos(Vector(-7457.6474609375, -3999.1748046875,384.03125))
			alyx:SetAngles(Angle(0,0,0))
		end
		
		local relay_knockout_start = ents.Create("coop_condition")
		relay_knockout_start:SetName("relay_knockout_start")
		relay_knockout_start:Spawn()
		relay_knockout_start.OnTrigger = function(self)
			self:TriggerOutputs()
		end
		relay_knockout_start.Outputs = {
			{"breakable_alyxwindow", "Break", 0.5, ""},
			{"template_alyx", "ForceSpawn", 0.2, ""},
			{"lcs_alyxgreet00", "Start", 0.4, ""},
			{"logic_kill_cops", "Trigger", 0.2, ""},
			{"relay_knockout_alyxrescue", "Trigger", 0.5, ""},
			{"door_knockout_1", "Unlock", 8.5, ""},
			{"door_knockout_1", "Open", 8.5, ""},
			{"alyx_pos_fix", "Trigger", 8.5, ""},
			{"door_knockout_2", "Lock", 1.0, ""},
			{"door_knockout_2", "Close", 1.1, ""},
			{"global_gordon_invulnerable", "TurnOff", 0.3, ""},
			{"relationship_cops_hate_player", "RevertRelationship", 0, ""},
			{"sound_knockout_copspeech_done", "PlaySound", 2.0, ""},
			--{"logic_fade_view", "Trigger", 0.1, ""},
			{"npc_knockout_cop_upstairs", "Kill", 3.0, ""},
			{"mic_alyx", "Enable", 0, ""},
		}
		
		-- All players are in.
		trigger.OnCondition = function(self)
			self:GoDown()
		end
		
		-- On Timeout
		trigger.OnTimeout = function(self)
			for k, v in pairs(player.GetAll()) do
				if not self:HasPlayer(v)  then
					v:SetPos(self:GetPos())
					v:SetEyeAngles(Angle(0, -90, 0))
				end
			end
			self:GoDown()
		end
		
		trigger.GoDown = function(self)		
			-- Set new spawn
			checkpoint.Master = true
			
			-- Do the outputs.
			if IsValid(speaker_alyxfollow1) then
				speaker_alyxfollow1:Fire("Kill", "", 0.1)
				speaker_alyxfollow1:Fire("TurnOff")
			end
			lcs_alyxgreet02:Fire("Start", "", 0.5)
			door_elevator_topsliding:Fire("Close")
			door_elevator_R:Fire("Close")
			door_elevator_L:Fire("Close")
			prop_elevatordoor:Fire("SetAnimation", "close")
			
			-- We don't need this anymore
			self:Remove()
		end
		
	end
end