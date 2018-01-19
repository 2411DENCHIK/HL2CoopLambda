function GM:InitMapScript()
	if SERVER then
	
		ents.RemoveByName("trigger_closeTPDoor")
		
		local trigger_leave_dog_door = ents.FindFirstByName("trigger_leave_dog_door")
		local trigger = ents.Create("coop_triggeronce")
		trigger:Replace(trigger_leave_dog_door)
		trigger.Outputs = {
			{"global_friendly_encounter", "TurnOff", 1.0, ""},
			{"spark_elevator_shaft_light", "StartSpark", 0, ""},
			--{"doors_elevator_2", "Close", 0, ""},
			--{"doors_elevator_1", "Close", 0.4, ""},
			--{"timer_nag_leave_1", "Kill", 0, ""},
			--{"logic_nag_leave_1", "Kill", 0, ""},
		}
		trigger.Filter = function(self, ent) return IsValid(ent) and ent:IsPlayer() end
		trigger.OnTrigger = function(self)
			self:TriggerOutputs()
		end
		
	end
end
