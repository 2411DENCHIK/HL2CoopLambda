function GM:InitMapScript()
	if SERVER then
	
		ents.RemoveByName("fall_trigger")
		ents.RemoveByName("train_pusher")
		
		if self:GetPreviousMap() == "d2_coast_08" then
			
			local playerstart = ents.Create("info_player_start")
			playerstart:SetPos(Vector(2988, 5209, 1562))
			playerstart:SetAngles(Angle(0, 180, 0))
			playerstart:Spawn()
			playerstart.Master = true
		
			local bridge_door_1 = ents.FindByName("bridge_door_1")[1]
			bridge_door_1:Fire("lock") -- No returning back
			
			for k,v in pairs(ents.FindByName("bridge_field_02")) do
				v:Fire("Disable")
			end
			
			for k,v in pairs(ents.FindByName("field_wall_poles")) do
				v:SetSkin(1)
			end
			
			for k,v in pairs(ents.FindByName("dropship")) do
				v:Fire("Enable")
				v:Fire("Activate")
			end
			
			hook.Add("MasterVehicleSpawn", "HL2Coop", function(vehicle)
				
				self.MasterVehicles["prop_vehicle_jeep"].Pos = Vector(1979.2606201172, 6294.158203125,1554.2152099609)	
				self.MasterVehicles["prop_vehicle_jeep"].Ang = Angle(-0.075029715895653, -40.673664093018, 1.2814202308655)	
												
			end)
			
		else
		
			for k,v in pairs(ents.FindByName("bridge_field_02")) do
				v:Fire("Enable")
			end
			
		end
		
	end
end
