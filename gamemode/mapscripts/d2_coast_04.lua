function GM:InitMapScript()
	if SERVER then		
	
		local push_car_superjump_01 = ents.FindByName("push_car_superjump_01")[1]
		push_car_superjump_01:Fire("Enable")
		-- Avoid other triggers disabling this.
		push_car_superjump_01:SetName("")
		
		--Vector(5502.9145507813, -2899.482421875,384.03125)	
		self:SetupCheckpoint(
			Vector(5502.9145507813, -2899.482421875,384.03125)	, 
			Vector(-230, -230, 0), 
			Vector(230, 230, 100), 
			Vector(5191.6616210938, -2943.7700195313,384.03125),
			Angle(0, 90, 0),
			Vector(5695.2094726563, -2742.7211914063,384.03125),
			Angle(0,180,0)
		)

	end
end
