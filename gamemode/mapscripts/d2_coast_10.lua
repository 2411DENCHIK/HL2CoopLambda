function GM:InitMapScript()
	if SERVER then
		ents.RemoveByName("fall_trigger")

		local jeep_filter = ents.FindByName("jeep_filter")
		if IsValid(jeep_filter) then
			jeep_filter:SetKeyValue("filterclass", "prop_vehicle_*")
		end
		
	end
end
