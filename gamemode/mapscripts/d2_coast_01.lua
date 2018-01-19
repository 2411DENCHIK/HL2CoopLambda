GM.SkyboxOverride = "turquoise"

function PickupNextCar()
	local cranedriver = ents.FindByName("cranedriver")[1]
	
	if cranedriver.IsBusy then
		DbgPrint("Cranedriver is currently busy, delaying for next pickup")
		cranedriver.NextPickup = true
		return
	end
	
	cranedriver.NextPickup = false
		
	local spos = Vector(-7868.03515625, -8634.2783203125,949.10400390625)
	local range = Vector(10, 10, 10)
		
	-- Search jeeps on dock.
	for k,v in pairs(ents.FindInBox(spos-range,spos+range)) do
	
		if v:IsVehicle() then
			
			cranedriver.IsBusy = true
			cranedriver.Vehicle = v
			
			local jeep = v
			-- Temporary name.
			jeep:SetName("jeep2")
			jeep:Fire("LockExit")
			
			timer.Simple(0, function()
				DbgPrint("Picking up next jeep")
				cranedriver:Fire("ForcePickup", "jeep2")
			end)
			
			return true 
			
		end
		
	end
end

function GM:InitMapScript()
	if SERVER then	

		local push_car_superjump_01 = ents.FindByName("push_car_superjump_01")[1]
		push_car_superjump_01:Fire("Enable")
		-- Avoid other triggers disabling this.
		push_car_superjump_01:SetName("")
				
		-- Annoying
		ents.RemoveByName("logic_jeepflipped")
		
		local cranedriver = ents.FindByName("cranedriver")[1]
		cranedriver:Fire("AddOutput", "OnPickedUpObject logic_drop2,Trigger", 0)
		cranedriver.IsBusy = true
		
		-- logic_drop
		local logic_drop = ents.Create("base_anim")
		logic_drop:SetName("logic_drop2")
		logic_drop:Spawn()
		function logic_drop:AcceptInput(name, activator, caller, data)
		
			if activator:IsVehicle() then				
				-- Restore name.
				activator.Locked = false 
				activator:Fire("TurnOn")
				activator:Fire("HandBrakeOff")
				activator.OnCrane = true
				
				-- Move vehicle to target and drop.
				cranedriver:Fire("ForceDrop", "jeep_target")
			end
						
			return true
		end
		
		cranedriver:Fire("AddOutput", "OnDroppedObject logic_ondrop,Trigger", 0)
		
		-- logic_ondrop.
		local logic_ondrop = ents.Create("base_anim")
		logic_ondrop:SetName("logic_ondrop")
		logic_ondrop:Spawn()
		function logic_ondrop:AcceptInput(name, activator, caller, data)
		
			print("Crane is no longer busy: "..tostring(caller) )
			cranedriver.IsBusy = false
			
			if cranedriver.Vehicle and IsValid(cranedriver.Vehicle) then
				cranedriver.Vehicle:SetName("jeep")
			end
			cranedriver.Vehicle = nil
			
			if cranedriver.NextPickup == true then
				PickupNextCar()
			end

			-- Steady position.
			cranedriver:Fire("ForcePickup", "null")
			
			return true
			
		end
		
		hook.Add("PlayerEnteredVehicle", "HL2Coop", function(ply, vehicle)
			
			if vehicle:GetClass() == "prop_vehicle_jeep" and not vehicle.IsMaster and vehicle.Locked then
				PickupNextCar()
			end
			
		end)
		
		hook.Add("VehicleSpawned", "HL2Coop", function(vehicle)		
			vehicle:Fire("TurnOff")
			vehicle:Fire("HandBrakeOn")
			vehicle.Locked = true
		end)
		
		hook.Add("VehicleRemoved", "HL2Coop", function(vehicle)
			local cranedriver = ents.FindByName("cranedriver")[1]
			if cranedriver.Vehicle == vehicle then
				DbgPrint("Cranedriver is no longer busy, vehicle was removed")
				cranedriver.IsBusy = false
				cranedriver:Fire("ForcePickup", "null")
				cranedriver.Vehicle = nil
			end
		end)
		
		hook.Add("OnEntityRemoved", "HL2Coop", function(vehicle)
			if vehicle:IsVehicle() then
				local cranedriver = ents.FindByName("cranedriver")[1]
				if cranedriver.Vehicle == vehicle then
					DbgPrint("Cranedriver is no longer busy, vehicle was forcefully removed")
					cranedriver.IsBusy = false
					cranedriver:Fire("ForcePickup", "null")
					cranedriver.Vehicle = nil
				end
			end
		end)
		
	end
end
