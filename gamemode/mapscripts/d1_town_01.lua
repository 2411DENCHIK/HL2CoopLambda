function GM:InitMapScript()
	if SERVER then		
	
		self:SetupCheckpoint(
			Vector(1921.8452148438, -1431.8277587891,-3775.96875), 
			Vector(-50, -50, 0), 
			Vector(50, 50, 50), 
			Vector(2021.4479980469, -1441.0190429688,-3839.96875),
			Angle(0, 90, 0),
			nil,
			nil,
			true
		)
		
	end
end
