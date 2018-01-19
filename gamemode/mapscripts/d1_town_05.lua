function GM:InitMapScript()
	if SERVER then
	
		ents.RemoveByName("trigger_close_door")
		
		local aisc_attentiontoradio = ents.FindByName("aisc_attentiontoradio")[1]
		aisc_attentiontoradio:Fire("Enable")
		
		local radio_trigger = ents.Create("coop_triggeronce")
		radio_trigger:Init(Vector(-1320.0582275391, 10801,939.34436035156), Angle(0,0,0), Vector(-100, -100, -100), Vector(100, 100, 100))
		radio_trigger.Outputs = {
			{"lcs_leon_radios3", "Start", 0, ""},
			{"radio_nag", "Kill", 0, ""},
			{"lcs_leon_nag", "Kill", 0, ""},
			{"alyx_camera", "SetOn", 0, ""},
		}
		radio_trigger.Trigger = function(self)
			self:TriggerOutputs()
			self:Remove()
		end
		
	end
end

function GM:PostInitMapScript()

	for k,v in pairs(ents.FindByClass("coop_changelevel")) do
		DbgPrint("Disabling trigger")
		v:SetEnabled(false)
	end
	
end