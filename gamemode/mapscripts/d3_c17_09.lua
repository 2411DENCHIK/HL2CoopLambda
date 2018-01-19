function GM:InitMapScript()
	if SERVER then
		
		local barney_lead = ents.FindFirstByName("barney_lead")
		local coop_goal = ents.Create("coop_goal_lead")
		coop_goal:Replace(barney_lead)
		
		-- Make sure snipers don't get disabled.
		local sniper1 = ents.FindFirstByName("sniper1")
		sniper1:SetName("coop_sniper1")
		
		local sniper2 = ents.FindFirstByName("sniper2")
		sniper1:SetName("coop_sniper2")
		
		local sniper3 = ents.FindFirstByName("sniper3")
		sniper1:SetName("coop_sniper3")
		
		local sniper4 = ents.FindFirstByName("sniper4")
		sniper1:SetName("coop_sniper4")
		
		local sniper5 = ents.FindFirstByName("sniper5")
		sniper1:SetName("coop_sniper5")
		
	end
end
