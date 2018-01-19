function GM:InitMapScript()
	if SERVER then	
			
		local pos = Vector(-3644.3081054688, -337.35818481445,-3583.96875)	
		local rng = Vector(100, 100, 100)
		local triggers = ents.FindInBox(pos - rng, pos + rng)
		
		for k,v in pairs(triggers) do
			print("Found: "..v:GetClass())
			
			if v:GetClass() == "trigger_changelevel" then
				-- Make solid instead?
				-- v:Remove()
				v:SetCollisionGroup(COLLISION_GROUP_PLAYER)
				v:SetNotSolid(false)
				v:SetSolid(SOLID_OBB)
			end
		end
			
	end
end
