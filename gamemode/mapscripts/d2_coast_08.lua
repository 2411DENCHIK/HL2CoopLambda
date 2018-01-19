function GM:InitMapScript()
	if SERVER then
				
		local playerstart = ents.Create("info_player_start")
		playerstart:SetPos(Vector(3328, 1408, 1573))
		playerstart:SetAngles(Angle(0, 270, 0))
		playerstart:Spawn()
		playerstart.Master = true
		
		local command_physcannon = ents.FindByName("button_press")[1]
		local commands = ents.Create("coop_commands")
		commands:Replace(command_physcannon)
		commands.Outputs = {
			{"screen_warning", "Disable", 0, ""},
			{"screen_warning2", "Enable", 0, ""},
			{"window_bullseye_killtrigger", "Enable", 0, ""},
			{"ground_breadcrumbs_spawn", "ForceSpawn", 3.0, ""},
			{"bridge_field_02", "Disable", 0, ""},
			{"transition_hack_spawner", "Spawn", 0, ""},
			{"gunship_trigger_2", "Enable", 0, ""},
			{"bridge_gate_global", "TurnOn", 0, ""},
			{"return_trip_autosave", "Enable", 0, ""},
			{"gunship", "Activate", 2.0, ""},
			{"gunship_getem", "StartSchedule", 5.0, ""},
			{"switch_sound", "PlaySound", 0, ""},
			{"gunship_support_attack", "Enable", 3.0, ""},
			{"shoot_windows", "ApplyRelationship", 3.0, ""},
			{"breadcrumbs_assault", "Activate", 8.0, ""},
		}
		commands.OnInput = function(self, name, activator, caller, data)
		
			print("Button pressed")
			
			-- Enable changelevel trigger.
			for k,v in pairs(ents.FindByClass("coop_changelevel")) do
				v:SetEnabled(true)
				v:SetCollisionGroup(COLLISION_GROUP_WORLD)
			end
			
			-- Normal outputs
			self:TriggerOutputs()
			
		end
		

	end
end

function GM:PostInitMapScript()

	-- Disable changelevel triggers
	for k,v in pairs(ents.FindByClass("coop_changelevel")) do
		v:SetEnabled(false)
		v:SetCollisionGroup(COLLISION_GROUP_PLAYER)
		v:SetDisplayGoal(true)
	end
		
end
