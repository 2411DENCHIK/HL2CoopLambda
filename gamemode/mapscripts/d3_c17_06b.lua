function GM:InitMapScript()
	if SERVER then
				
		-- prevent players messing with this.
		local wench_1_lever_1 = ents.FindFirstByName("wench_1_lever_1")
		wench_1_lever_1:SetKeyValue("spawnflags", "122")
		
		-- lock this once down.
		local wench_2_lever_1 = ents.FindFirstByName("wench_2_lever_1")
		wench_2_lever_1:Fire("AddOutput", "OnOpen wench_2_lever_1,Lock", 0)
		
		-- Block players jumping over the fence
		local push_trigger = ents.Create("trigger_push")
		push_trigger:SetModel("*61")
		push_trigger:SetKeyValue("origin", "3800 1555 138")
		push_trigger:SetKeyValue("spawnflags", "1")
		push_trigger:SetKeyValue("speed", "500")
		push_trigger:SetKeyValue("pushdir", "0 180 0")
		push_trigger:Spawn()
		push_trigger:Activate()
		
		local push_trigger = ents.Create("trigger_push")
		push_trigger:SetModel("*46")
		push_trigger:SetKeyValue("origin", "3800 1555 138")
		push_trigger:SetKeyValue("spawnflags", "1")
		push_trigger:SetKeyValue("speed", "500")
		push_trigger:SetKeyValue("pushdir", "0 270 0")
		push_trigger:Spawn()
		push_trigger:Activate()
		

	end
end
