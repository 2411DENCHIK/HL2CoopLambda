function GM:InitMapScript()
	if SERVER then

		ents.RemoveByPos(Vector(-440, -2908, -172))
				
		self:SetupCheckpoint(
			Vector(-421.58666992188, -2789.0786132813,-239.96875), 
			Vector(-35, -5, 0), 
			Vector(35, 5, 100), 
			Vector(-439.96649169922, -2897.9150390625,-239.96875),
			Angle(0,-90,0)
		)
		
		self:SetupCheckpoint(
			Vector(4148.4501953125, -3972.2956542969,-543.96875),
			Vector(-150, -100, 0), 
			Vector(150, 100, 100), 
			Vector(4148.4501953125, -3972.2956542969,-543.96875),
			Angle(0,-90,0)
		)
		-- For the slow people we setup a teleport, just to be safe.
		local teleport_1 = ents.Create("coop_triggermultiple")
		teleport_1:Init(
			Vector(-443.05804443359, -2693.2751464844,-239.96875),
			Angle(0,0,0),
			Vector(-90, -90, 0), 
			Vector(90, 90, 100)
		)
		teleport_1:SetEnabled(false)
		teleport_1.Filter = function(self, ent) return IsValid(ent) and ent:IsPlayer() end
		teleport_1.Trigger = function(self, ent)
			ent:SetPos(Vector(-439.96649169922, -2897.9150390625,-239.96875))
			ent:SetEyeAngles(Angle(0, -90, 0))
		end
		
		-- Extend the button
		local button = ents.FindByPos(Vector(-570, -3342, -115.5))
		button:Fire("AddOutput", "OnPressed coop_startwave1,Trigger", 0)
		
		-- We shall close the door but also make sure players will get teleported then.
		local condition_1 = ents.Create("coop_condition")
		condition_1:SetName("coop_startwave1")
		condition_1:Spawn()
		condition_1.OnTrigger = function(self)
			local door_croom2_gate = ents.FindFirstByName("door_croom2_gate")
			door_croom2_gate:Fire("Close")
			teleport_1:SetEnabled(true)
		end
		
		-- Another broken ai_goal_lead
		local lead_alyx_room5_exit = ents.FindFirstByName("lead_alyx_room5_exit")
		local coop_goal = ents.Create("coop_goal_lead")
		coop_goal:Replace(lead_alyx_room5_exit)
		
	end
end
