function GM:InitMapScript()
	if SERVER then		
	
		self:SetupCheckpoint(
			Vector(-487.51019287109, -63.214305877686,-575.96875), 
			Vector(-305, -305, 0), 
			Vector(305, 305, 100), 
			Vector(-467.10797119141, -242.32719421387,-591.96875),
			Angle(0, -90, 0),
			Vector(-306.29833984375, -403.85659790039,-671.96875),
			Angle(0,0,0),
			nil,
			nil,
			true
		)
		
		ents.RemoveByName("trigger_close_gates")
		
	end
end
