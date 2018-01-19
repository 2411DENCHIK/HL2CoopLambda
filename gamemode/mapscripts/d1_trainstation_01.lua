function GM:InitMapScript()
	if SERVER then
			
		ents.RemoveByName("cage_playerclip")
		ents.RemoveByName("train_door_2_counter")
		ents.RemoveByName("barney_room_blocker")
		ents.RemoveByName("barney_room_blocker_2")
		--ents.RemoveByName("security_04")
		ents.RemoveByName("barney_hallway_clip")
		ents.RemoveByName("trigger_barney_close_exitdoor")
		ents.RemoveByName("trigger_cop_close_door_1")
		ents.RemoveByName("logic_kill_citizens")
		
		ents.RemoveByPos(Vector(-4051,-515,28))
		--ents.RemoveByName("teleport_to_start")
		
		local coop_spawn_fix = ents.Create("coop_condition")
		coop_spawn_fix:SetName("coop_spawn_fix")
		coop_spawn_fix:Spawn()
		coop_spawn_fix.OnActivate = function(self, activator)
			DbgPrint("Triggered shit", activator)
		end
		
		local teleport_to_start = ents.FindFirstByName("teleport_to_start")
		teleport_to_start:Fire("AddOutput", "OnStartTouch coop_spawn_fix,Activate")
		--OnTrigger
		
		for k,v in pairs(ents.FindByClass("point_viewcontrol")) do
			DbgPrint("YUP Viewcontrol Fix!")
			v:SetKeyValue("spawnflags", "128")
		end
		
		for k,v in pairs(ents.FindByClass("info_player_start")) do
			v:SetPos(Vector(-14576, -14208,-1292))
		end
		
		local playerstart1 = ents.Create("info_player_start")
		--playerstart1:SetKeyValue("StartDisabled", "1")
		playerstart1:SetName("player_start_1")
		playerstart1:SetAngles(Angle(0, 90, 0))
		playerstart1:SetPos(Vector(-14576, -14208,-1292))
		playerstart1:Spawn()
		playerstart1.Master = true
		
		local mark_cop_security_room_leave = ents.FindFirstByName("mark_cop_security_room_leave")
		mark_cop_security_room_leave:SetPos(Vector(-4289.6083984375, -757.52783203125,-31.968746185303))

		local barney_door_1 = ents.FindFirstByName("barney_door_1")
				
		local cop_move_target = ents.Create("info_target")
		cop_move_target:SetPos(Vector(-4286.7163085938, -625.09686279297,-31.96875))
		cop_move_target:SetName("cop_move_target")
		cop_move_target:Spawn()
		
		local mark_barneyroom_comblock_4 = ents.FindFirstByName("mark_barneyroom_comblock_4")
		mark_barneyroom_comblock_4:SetPos(Vector(-3327.5656738281, -54.626640319824,-31.96875))
			
		local move_gate_cop = ents.Create("coop_condition")
		move_gate_cop:SetName("move_gate_cop")
		move_gate_cop.OnActivate = function(self)
			local razortrain_gate_cop_2 = ents.FindFirstByName("razortrain_gate_cop_2")
			razortrain_gate_cop_2:ClearSchedule()
			razortrain_gate_cop_2:SetLastPosition(cop_move_target:GetPos())
			razortrain_gate_cop_2:SetTarget(cop_move_target)
			razortrain_gate_cop_2:SetSchedule(SCHED_FORCED_GO)
			razortrain_gate_cop_2:SetName("coop_razortrain_gate_cop_2")
			barney_door_1:Fire("Close")
			barney_door_1:Fire("AddOutput", "OnFullyOpen barny_door_1_fix,Activate", 0)
		end
		
		timer.Create("WaitForCop", 1, 0, function()
			local razortrain_gate_cop_2 = ents.FindFirstByName("razortrain_gate_cop_2")
			if IsValid(razortrain_gate_cop_2) then
				razortrain_gate_cop_2:SetPos(Vector(-4224, -644, -23))
				local customs_takeaway_vcd = ents.FindFirstByName("customs_takeaway_vcd")
				customs_takeaway_vcd:Fire("AddOutput", "OnCompletion move_gate_cop,Activate")
				timer.Destroy("WaitForCop")
			end
		end)
		
		local barny_door_1_fix = ents.Create("coop_condition")
		barny_door_1_fix:SetName("barny_door_1_fix")
		barny_door_1_fix.OnActivate = function(self)
			barney_door_1:SetName("coop_barney_door_1")
		end
											
		hook.Add("PlayerSpawn", "COOP_IntroSpawn", function(ply)
			timer.Simple(0, function()
				DbgPrint("PlayerSpawn Fix")
				-- Failsafe
				ply:SetPos(playerstart1:GetPos())
				
				DbgPrint("PlayerPos:", ply:GetPos())
				ply.OriginalFOV = ply:GetFOV()
				ply:SetFOV(55, 0)
				ply:SetFOV(10, 80)
				ply:Freeze(true)
				ply:SetNoDraw(true)
			end)
		end)
		
		hook.Add("PlayerDeath", "COOP_IntroSpawn", function(ply)
			
		end)
		
		local spawnchange = ents.Create("coop_condition")
		spawnchange:SetName("coop_spawnchange")
		spawnchange:Spawn()
		spawnchange.OnActivate = function(self)
			DbgPrint("Activated SpawnChange")
			hook.Remove("PlayerSpawn", "COOP_IntroSpawn")
			timer.Simple(0.1, function()
				for k,v in pairs(player.GetAll()) do
					v:Freeze(false)
					v:SetPos(Vector(-9278.39453125, -2421.1555175781,16.03125))
					v:SetEyeAngles(Angle(0,0,0))
					if v.OriginalFOV ~= nil then
						v:SetFOV(v.OriginalFOV, 0)
						v.OriginalFOV = nil
					end
					v:SetNoDraw(false)
				end
				
				local intro_train_2 = ents.FindFirstByName("intro_train_2")
				
				playerstart1:SetPos(Vector(-9459.548828125, -2489.2687988281,16.03125))
				playerstart1:SetParent(intro_train_2)
				playerstart1:SetAngles(Angle(0, 180, 0))
				playerstart1.Master = true
				
			end)
		end
				
		local logic_start_train = ents.FindByName("logic_start_train")[1]
		logic_start_train:Fire("AddOutput", "OnTrigger coop_spawnchange,Activate", 0)

		
		timer.Create("RemoveQueue", 1, 0, function()
		
			ents.RemoveByName("citizen_queue_start_3")
			ents.RemoveByName("citizen_queue_start_2")
			ents.RemoveByName("citizen_queue_start_1")
			
		end)
				
		-- Block players from escaping control gate.
		local cage_playerclip = ents.Create("func_brush")
		cage_playerclip:SetPos(Vector(-4226.9350585938, -417.03271484375,-31.96875))
		cage_playerclip:SetModel("*68")
		cage_playerclip:SetKeyValue("spawnflags", "2")
		cage_playerclip:Spawn()
		
		-- Fix scene not playing.
		local Breencastwatch_disable = ents.FindFirstByName("Breencastwatch_disable")
		Breencastwatch_disable:Fire("AddOutput", "OnStartTouch luggage_citizen_idle,CancelSequence", 0)
		Breencastwatch_disable:Fire("AddOutput", "OnStartTouch luggage_citizen_idle,Kill", 0.1)
		Breencastwatch_disable:Fire("AddOutput", "OnStartTouch luggage_shove_scene,Start", 0.1)
		
		-- Additional Stuff
		local coop_supersoldier1 = ents.Create("npc_coop_supersoldier")
		coop_supersoldier1:SetPos(Vector(-3741.373046875, -2685.7375488281,-31.968746185303))
		coop_supersoldier1:Spawn()
			
		local trigger_supersoldier = ents.Create("coop_triggeronce")
		trigger_supersoldier:Init(Vector(-4018, -2548,-31), Angle(0, -90, 0), Vector(-100, -100, -20), Vector(100, 100, 20))
		trigger_supersoldier.Trigger = function()
			coop_supersoldier1:Teleport(Vector(-3929.8786621094, -2743.3569335938,-31.96875), Angle(0, 110, 0))
		end
				
	end
end
