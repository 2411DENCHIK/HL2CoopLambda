--[[
hook.Add("EntityKeyValue", "MoreFun", function(ent, key, val)
	if ent:GetName() == "gunship_spawner_2" then
		if key == "MaxLiveChildren" then
			return "-1"
		elseif key == "MaxNPCCount" then
			return "3"
		elseif key == "SpawnFrequency" then
			return "3"
		end
	end
end)
]]

GM.SkyboxOverride = "turquoise"

function GM:InitMapScript()
	if SERVER then	
	
		local command_physcannon = ents.FindByName("spawner_rpg")[1]
		local commands = ents.Create("coop_commands")
		commands:Replace(command_physcannon)
		commands.OnInput = function(self, name, activator, caller, data)
		
			for k,v in pairs(player.GetAll()) do
				v:Give("weapon_rpg")
			end			
			
		end
		
		ents.RemoveByName("telescope_button")
		
		--[[
		local gunship_spawner_2 = ents.FindFirstByName("gunship_spawner_2")
		gunship_spawner_2:Fire("AddOutput", "OnSpawnNPC gunship_spawner_2,Enable", 1)
		]]
		
	end
end
