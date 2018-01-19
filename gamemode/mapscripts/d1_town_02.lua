function GM:InitMapScript()
	if SERVER then	

		--ents.RemoveByPos(Vector(-4352, 1496,-3022))
		
		if self:GetPreviousMap() == "d1_town_03" then
		
			DbgPrint("Applying new spawnpoint position")
			
			-- We reposition the spawnpoint, only one should exist.
			local spawn = ents.FindByClass("info_player_start")[1]
			spawn:SetPos(Vector(-3758.723145, -47.452354 , -3391.968750))
			spawn:SetAngles(Angle(0, 90, 0))
			
			local churchyard_portal = ents.FindByName("churchyard_portal")[1]
			churchyard_portal:Fire("Open")
			
			local ent = ents.Create("coop_blockade")
			ent:SetPos(Vector(-3716, -219,-3530))
			ent:SetAngles(Angle(0, 0, 0))
			ent:SetModel("models/props_c17/door01_left.mdl")
			ent:Spawn()
			
			self:SetupCheckpoint(
				Vector(-4060.70703125, 1436.2723388672,-3263.96875), 
				Vector(-5, -35, 0), 
				Vector(5, 35, 100), 
				Vector(-4162.7182617188, 1594.3426513672,-3263.96875), 
				Angle(0,-90,0)
			)
						
			local churchtram_lever = ents.FindFirstByName("churchtram_lever")
			churchtram_lever:Fire("Lock")
			
			local shitty_trigger = ents.FindByPos(Vector(-4064, 1322, -2992))
			
			local good_trigger = ents.Create("coop_triggeronce")
			good_trigger:Replace(shitty_trigger)
			good_trigger.Outputs = {
				{"monk_rock_scene_a1", "Start", 0, ""},
				{"churchtram_lever", "Lock", 0, ""},
				{"church_monk_conditions", "Enable", 0, ""},
			}
			good_trigger.Filter = function(self, ent)
				if IsValid(ent) and ent:IsPlayer() and ent:Alive() then
					return true
				end
			end
			good_trigger.Trigger = function(self)
				self:TriggerOutputs()
			end
			
		end
		
	end
end
