GM.SkyboxOverride = "turquoise"

function GM:InitMapScript()
	if SERVER then
	
		local scriptCond_seeBarney = ents.FindFirstByName("scriptCond_seeBarney")
		--scriptCond_seeBarney:SetKeyValue("ActorSeeTarget", "3")
		scriptCond_seeBarney:SetKeyValue("PlayerActorFOV", "-1")
		scriptCond_seeBarney:SetKeyValue("PlayerTargetLOS", "3")
		
		ents.RemoveByClass("item_battery")
		local spawns = ents.FindByClass("info_player_start")
		for k,v in pairs(spawns) do
			local pos = v:GetPos()
			v:SetPos(pos + Vector(0,0,5))
		end
		
	end
end