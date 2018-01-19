-- Checkpoint: Vector(672.78369140625, -6398.236328125,540.03125)	
-- Trigger: Vector(620.33471679688, -6510.076171875,540.03125)	

function GM:InitMapScript()
	if SERVER then
	
		self:SetupCheckpoint(
			Vector(620.33471679688, -6510.076171875,540.03125), 
			Vector(-5, -35, 0), 
			Vector(5, 35, 100), 
			Vector(508.10037231445, -6763.2377929688,540.03125), 
			Angle(0,0,0)
		)
		
		ents.RemoveByName("boxcar_door_close")
		
	end
end
