function GM:InitMapScript()
	if SERVER then
	
		-- Leave monitors on.
		ents.RemoveByPos(Vector(-1408, 2056, 448))
		ents.RemoveByPos(Vector(-1408, 2120, 448))
		
		local monitor_1 = ents.FindFirstByName("monitor_1")
		monitor_1:Fire("Enable")
		
		local closet_door = ents.FindFirstByName("closet_door")
		closet_door:SetKeyValue("spawnflags", "2048")
		
	end
end
