function GM:InitMapScript()
	if SERVER then
	
		for k,v in pairs(ents.FindByClass("info_player_start")) do
			v:SetPos(Vector(11885.544921875, -12234.153320313,-526.42785644531))
		end
				
		self:SetupCheckpoint(
			Vector(6426.4150390625, 8717.08984375,-377.20062255859), 
			Vector(-100, -700, 0), 
			Vector(100, 700, 1000), 
			Vector(3992.4348144531, 9775.123046875,-127.96875),
			Angle(0, -90, 0),
			Vector(4326.3110351563, 9658.8994140625,-127.96875),
			Angle(0,-90,0)
		)
		
	end
end
