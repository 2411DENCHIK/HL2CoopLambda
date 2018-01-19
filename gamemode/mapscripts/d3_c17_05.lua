function GM:InitMapScript()
	if SERVER then
		
		local gate_button = ents.FindByPos(Vector(1938.27, -4100.3, 256), "func_door")
		gate_button:SetName("coop_gate_button")
		gate_button:Fire("AddOutput", "OnOpen coop_gate_button,Lock", 0)
		
	end
end
