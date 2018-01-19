GM.MapList = 
{
	"d1_trainstation_01",
	"d1_trainstation_02",
	"d1_trainstation_03",
	"d1_trainstation_04",
	"d1_trainstation_05",
	"d1_trainstation_06",
	"d1_canals_01",
	"d1_canals_01a",
	"d1_canals_02",
	"d1_canals_03",
	"d1_canals_05",
	"d1_canals_06",
	"d1_canals_07",
	"d1_canals_08",
	"d1_canals_09",
	"d1_canals_10",
	"d1_canals_11",
	"d1_canals_12",
	"d1_canals_13",
	"d1_eli_01",
	"d1_eli_02",
	"d1_town_01",
	"d1_town_01a", 
	"d1_town_02",
	"d1_town_03",
	"d1_town_02",
	"d1_town_02a",
	"d1_town_04",
	"d1_town_05",
	"d2_coast_01",
	"d2_coast_03",
	"d2_coast_04",
	"d2_coast_05",
	"d2_coast_07",
	"d2_coast_08",
	"d2_coast_07",
	"d2_coast_09",
	"d2_coast_10",
	"d2_coast_11",
	"d2_coast_12",
	"d2_prison_01",
	"d2_prison_02",
	"d2_prison_03",
	"d2_prison_04",
	"d2_prison_05",
	"d2_prison_06",
	"d2_prison_07",
	"d2_prison_08",
	"d3_c17_01",
	"d3_c17_02",
	"d3_c17_03",
	"d3_c17_04",
	"d3_c17_05",
	"d3_c17_06a",
	"d3_c17_06b",
	"d3_c17_07",
	"d3_c17_08",
	"d3_c17_09",
	"d3_c17_10a",
	"d3_c17_10b",
	"d3_c17_11",
	"d3_c17_12",
	"d3_c17_12b",
	"d3_c17_13",
	"d3_citadel_01",
	"d3_citadel_02",
	"d3_citadel_03",
	"d3_citadel_04",
	"d3_citadel_05",
	"d3_breen_01"
}

function GM:FindByLandmark(landmark)
	for k,v in pairs(ents.FindByClass("trigger_changelevel")) do
		if v:GetKeyValue("landmark") == landmark then
			return v
		end
	end
	return nil
end

-- Called after all the entities are initialized.
function GM:ReplaceChangelevelTriggers()

	if CLIENT then
		return
	end
	
	-- I believe this is the cause for some crashes.
	ents.RemoveByClass("trigger_transitions")
	
	DbgPrint("Replacing triggers")
	
	local curmap = string.lower(game.GetMap())
	local nextmap = self:GetNextMap()
	local prevmap = self:GetPreviousMap()
	DbgPrint("Next map is: "..nextmap)
	
	for k,v in pairs(ents.FindByClass("trigger_transition")) do
		v:Remove()
	end
	
	for k, v in pairs(ents.FindByClass("trigger_changelevel")) do
		local map = v:GetKeyValue("map")
		if map == nextmap and v:GetCollisionGroup() ~= COLLISION_GROUP_PLAYER then			
			local ent = ents.Create("coop_changelevel")
			ent:Replace(v, 60)
		elseif map == prevmap then
			v:Remove()
		end
	end

end

-- Get index by map name.
function GM:GetMapIndex(prevmap, curmap)
	local foundprev = false
	local lastindex = 0
	for k, v in pairs(self.MapList) do
		if foundprev then
			if v == curmap then
				return k
			end
			foundprev = false
		end
		if v == curmap then
			lastindex = k -- In case there was a huge jump due a manual changelevel by user.
		end
		if v == prevmap then
			foundprev = true
		elseif prevmap == nil and v == curmap then
			return k
		end
	end
	return lastindex
end

-- Get the index of the current map.
function GM:GetCurrentMapIndex()
	local curmap = string.lower(game.GetMap())
	return self:GetMapIndex( self.PrevMap, curmap )
end

function GM:GetNextMap()

	local current = self:GetCurrentMapIndex()

	if current + 1 > #self.MapList then
		return nil
	end
	return self.MapList[current + 1]
	
end

function GM:GetPreviousMap()

	local current = self:GetCurrentMapIndex()
	if current - 1 < 0 then
		return nil
	end
	return self.MapList[current - 1]
	
end