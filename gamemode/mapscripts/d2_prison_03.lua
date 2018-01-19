function GM:InitMapScript()
	if SERVER then
	
		ents.RemoveByName("playerclip_shower_dropdown")
				
		self:SetupCheckpoint(
			Vector(-3925.7639160156, 4599.650390625,0.03125), 
			Vector(-2, -35, 0), 
			Vector(2, 35, 100), 
			Vector(-4081.2841796875, 4542.3295898438,0.03125),
			Angle(0,0,0)
		)
		
	end
end
