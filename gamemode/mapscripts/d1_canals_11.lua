function GM:InitMapScript()
	if SERVER then		
		--ents.RemoveByName("door_guncave_entrance")
		-- We don't want the door closed after the first player passes by.
		ents.RemoveByName("relay_guncave_gate_exit_close")
		ents.RemoveByName("brush_maproom_PCLIP")
		ents.RemoveByName("gate1")
		--ents.RemoveByName("gate2")
		--ents.RemoveByName("lever_door1")
	
		self:SetupCheckpoint(
			Vector(6602.68359375, 4872.2807617188,-994.53912353516), 
			Vector(-130, -130, 0), 
			Vector(130, 130, 100), 
			Vector(6177.5244140625, 5133.494140625,-895.96875),
			Angle(0, -90, 0),
			Vector(6201.1098632813, 4830.3159179688,-1010.1605224609),
			Angle(0,90,0)
		)
		
	end
end
