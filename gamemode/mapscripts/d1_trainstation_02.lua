GM.SkyboxOverride = "turquoise"

function GM:InitMapScript()
	if SERVER then
	
		-- Why hide all the good things?
		ents.RemoveByPos(Vector(-3500, -808 ,288), "func_brush")
		local window = ents.FindByPos(Vector(-3508, -808 ,288), "func_brush")
		--window:SetColor(Color(255,255,255,100))
		window:Remove()
		
		local monkey = ents.FindFirstByName("monkey")
		monkey:SetKeyValue("spawnflags", "0")
		
		local monkey2 = ents.FindFirstByName("monkey2")
		monkey2:SetKeyValue("spawnflags", "0")
						
		ents.RemoveByName("knockout_trigger_2")
		ents.RemoveByName("npc_rush_cop7")
		ents.RemoveByName("npc_rush_cop8")
		ents.RemoveByName("knockout_fade")
		
		local trigger = ents.Create("coop_condition")
		trigger:Replace(ents.FindFirstByName("cupcop_fail_relay"))
		trigger.Outputs = {
			{"cupcop_nag_timer", "Kill", 0, ""},
			{"trashcan_trigger", "Kill", 0, ""},
			{"lcs_CupCop_Fail", "Start", 0, ""},
			{"throwcan_trigger", "Kill", 0, ""},
			{"player_escape_trigger", "Kill", 0, ""},
			{"cupcop_failsafe_timer", "Kill", 0, ""},
			{"cupcop_nag_timer_putin", "Kill", 0, ""},
			{"cupcop_can_pickup", "Kill", 0, ""},
		}				
		trigger.OnTrigger = function(self)
			self:TriggerOutputs()
		end
		
		local dead_cupcop = ents.Create("coop_condition")
		dead_cupcop:SetName("dead_cupcop")
		dead_cupcop:Spawn()
		dead_cupcop.OnTrigger = function(self)
			local cupcop = ents.FindFirstByName("cupcop")
			if IsValid(cupcop) then
				DbgPrint("Blowing him away")
				
				local dmginfo = DamageInfo()
				dmginfo:SetDamage( 1000 ) --50 damage
				dmginfo:SetDamageType( DMG_BULLET ) --Bullet damage
				dmginfo:SetAttacker( cupcop ) --First player found gets credit
				dmginfo:SetDamageForce( Angle(-9.8339977264404, -89.802444458008, 0):Forward() * 900000 ) --Launch upwards
				
				local pos = cupcop:GetPos()
				
				local effectdata = EffectData()
				effectdata:SetStart( pos )
				effectdata:SetOrigin( pos )
				effectdata:SetScale( 1 )
				util.Effect("Explosion", effectdata)
				
				cupcop:TakeDamageInfo(dmginfo)
			end
		end
		
		-- More fun stuff.
		local cupcop_can	 = ents.FindFirstByName("cupcop_can")
		cupcop_can:AddCallback("PhysicsCollide", function(ent, data, hit_ent)
			local cupcop = ents.FindFirstByName("cupcop")
			if IsValid(data.HitEntity) then
			
				local dmginfo = DamageInfo()
				dmginfo:SetDamage( 10000 ) --50 damage
				dmginfo:SetDamageType( DMG_BULLET ) --Bullet damage
				dmginfo:SetAttacker( ent ) --First player found gets credit
				dmginfo:SetDamageForce( data.OurOldVelocity * 90000 + Vector(0,0, 1000) ) --Launch upwards
				
				PrintTable(data)
				
				-- ent being super lolz
				data.HitEntity:TakeDamageInfo(dmginfo)
				
				GAMEMODE:RagdollCrush(ent, data)
				
			end
		end)
		
		local throwcan_trigger = ents.FindFirstByName("throwcan_trigger")
		throwcan_trigger:Fire("AddOutput", "OnTrigger dead_cupcop,Trigger")
		
		-- swing_seat_1
		-- -4674.464844 -3538.560059 25.073853
		-- models/nova/airboat_seat.mdl
		-- prop_vehicle_prisoner_pod
		local swing_seat_1 = ents.FindFirstByName("swing_seat_1")
		local seat_1 = ents.Create("prop_vehicle_prisoner_pod")
		seat_1:SetPos(Vector(-4674.464844, -3540, 25))
		seat_1:SetModel("models/nova/airboat_seat.mdl")
		seat_1:SetAngles(Angle(0, 180, 0))
		seat_1:SetCollisionGroup(COLLISION_GROUP_NONE)
		seat_1:SetParent(swing_seat_1)
		seat_1:SetNoDraw(true)
		seat_1:Spawn()
		
		local phys_seat_1 = seat_1:GetPhysicsObject()
		if IsValid(phys_seat_1) then
			phys_seat_1:SetMass(1)
		end
		
		-- swing_seat_2
		-- -4633.555664 -3542.251465 24.702568
		-- models/nova/airboat_seat.mdl
		-- prop_vehicle_prisoner_pod
		local swing_seat_2 = ents.FindFirstByName("swing_seat_2")
		local seat_2 = ents.Create("prop_vehicle_prisoner_pod")
		seat_2:SetPos(Vector(-4633.555664, -3540, 25))
		seat_2:SetModel("models/nova/airboat_seat.mdl")
		seat_2:SetCollisionGroup(COLLISION_GROUP_NONE)
		seat_2:SetAngles(Angle(0, 180, 0))
		seat_2:SetParent(swing_seat_2)
		seat_2:SetNoDraw(true)
		seat_2:Spawn()
		
		local phys_seat_2 = seat_2:GetPhysicsObject()
		if IsValid(phys_seat_2) then
			phys_seat_2:SetMass(1)
		end
		
		ents.RemoveByPos(Vector(-2103.94, -4806.22, 37.7), "trigger_multiple")
		ents.RemoveByPos(Vector(-3680, -5192, 76.69), "trigger_multiple")
		ents.RemoveByPos(Vector(-2307.78, -4758.91, 37.7), "trigger_multiple")
		ents.RemoveByPos(Vector(-3680, -5152, 37.39), "trigger_multiple")
		ents.RemoveByPos(Vector(-5432, -3824, 37.39), "trigger_multiple")
	end
end
