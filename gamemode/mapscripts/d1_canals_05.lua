function GM:InitMapScript()
	if SERVER then

		self:SetupCheckpoint(
			Vector(4165.9208984375, 1970.4903564453,-474.60412597656), 
			Vector(-35, -5, 0), 
			Vector(35, 5, 100), 
			Vector(4165.9208984375, 1970.4903564453,-474.60412597656),
			Angle(0,-90,0),
			nil,
			nil,
			true
		)
		
	end
end
