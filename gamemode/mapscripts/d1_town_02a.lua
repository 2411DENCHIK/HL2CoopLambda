function GM:InitMapScript()
	if SERVER then		
	
		ents.RemoveByName("graveyard_exit_door")
		
		local g_dead_fade = ents.FindFirstByName("g_dead_fade")
		
		
		local load_save = ents.Create("coop_condition")
		load_save:Replace(g_dead_fade)
		load_save.OnReload = function(self)
			DbgPrint("Round restart")
			GAMEMODE:RestartRound()
		end
		
	end
end
