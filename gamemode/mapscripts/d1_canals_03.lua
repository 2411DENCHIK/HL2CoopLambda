function GM:InitMapScript()
	if SERVER then
	
		self:SetupCheckpoint(
			Vector(-1795.9107666016, -962.22979736328,-895.96875), 
			Vector(-5, -35, 0), 
			Vector(5, 35, 100), 
			Vector(-1885.4741210938, -811.83453369141,-895.96875),
			Angle(0,-90,0)
		)
		
	end
end
