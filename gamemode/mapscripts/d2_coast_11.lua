function GM:InitMapScript()
	if SERVER then		
	
		ents.RemoveByName("mc_both_in")
		
		-- Remove the trigger that closes the door
		for k,v in pairs(ents.FindInBox(Vector(584, 11544, 544.84),Vector(584, 11544, 544.84))) do
			if v:GetClass() == "trigger_once" then
				v:Remove()
			end
		end
		
		local aisc_vort_follow = ents.FindByName("aisc_vort_follow")[1]
		aisc_vort_follow:Fire("AddOutput", "OnConditionsSatisfied begin_extract,Enable", 0)
		
		local leadgoal_vortigaunt = ents.FindByName("leadgoal_vortigaunt")[1]
		
		local condition = ents.Create("coop_condition")
		condition:SetName("begin_extract")
		condition:SetEnabled(false)
		condition:Spawn()
		condition.OnEnabled = function(self)
			DbgPrint("Received begin extract")
			
			local vortiguant = ents.FindByName("vortigaunt_bugbait")[1]
			vortiguant:Fire("AddOutput", "OnFinishedExtractingBugbait end_extract,Enable", 0)
		
			vortiguant:Fire("ExtractBugbait", "citizen_ambush_guard")
		end
		
		local condition = ents.Create("coop_condition")
		condition:SetName("end_extract")
		condition:SetEnabled(false)
		condition:Spawn()
		condition.OnEnabled = function(self)
			DbgPrint("Received finished extract")
		end
		
		hook.Add("WeaponEquip", "HL2CoopVortiguantFix", function(wep)
		
			if wep:GetClass() == "weapon_bugbait" then
			
				local camp_setup = ents.FindByName("camp_setup")[1]
				camp_setup:Fire("Trigger")
				leadgoal_vortigaunt:Fire("Activate")
				
				hook.Remove("WeaponEquip", "HL2CoopVortiguantFix")
				
			end
			
		end)
		
	end
end
