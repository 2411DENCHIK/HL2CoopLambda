AddCSLuaFile()

ENT.Base = "base_nextbot"
ENT.Spawnable = false

util.PrecacheModel( "models/Combine_Super_Soldier.mdl" )

game.AddParticles( "particles/gmod_effects.pcf" )

PrecacheParticleSystem( "generic_smoke" )

local EnemyClasses = {}
EnemyClasses["npc_zombie"] = true
EnemyClasses["npc_fastzombie"] = true
EnemyClasses["npc_zombie"] = true
EnemyClasses["npc_headcrab"] = true

function ENT:Initialize()

	self:SetModel( "models/Combine_Super_Soldier.mdl" )
	self.Enemy = nil
	
	local mins,maxs = self:GetCollisionBounds()
	print(mins, maxs)
	
	local targetEnt = ents.Create("npc_bullseye")
	targetEnt:SetPos(self:EyePos() + Vector(0,0,20))
	targetEnt:Spawn()
	targetEnt:SetCollisionBounds(Vector(-14, -14, -10), Vector(14, 14, 10))
	
	--targetEnt:SetNotSolid(true)
	targetEnt:SetTrigger(true)
	targetEnt:UseTriggerBounds(true, 10)
	
	targetEnt:SetParent(self)
	targetEnt:SetOwner(self)
	targetEnt:SetKeyValue("spawnflags", "4096")
	--targetEnt:SetCollisionGroup(COLLISION_GROUP_NPC_ACTOR)
	--self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	
	constraint.NoCollide(self, targetEnt, 0, 0)
	
	self.TargetEnt = targetEnt
	self:SetNWEntity("TargetEnt", targetEnt)
	
	for k,v in pairs(ents.GetAll()) do
		
		if EnemyClasses[v:GetClass()] then
		
			print("Adding relationship to target:", self)
			v:AddEntityRelationship(self, D_HT, 99)
			print("Adding relationship to target:", targetEnt)
			v:AddEntityRelationship(targetEnt, D_HT, 99)
		
		end
		
	end
	
	self:CallOnRemove("RemoveBullsEye", function(ent)
	
		if IsValid(ent.TargetEnt) then
			print("Removing bullseye")
			ent.TargetEnt:Remove()
		end
		
	end)
			
end

function ENT:SetupDataTables()

	DbgPrint("SetupDataTables")

end

function ENT:GiveWeapon()

    local att = "anim_attachment_RH"
	local shootpos = self:GetAttachment(self:LookupAttachment(att))
	
	if shootpos then
		PrintTable(shootpos)
		
		local wep = ents.Create("weapon_ar2")
		wep:SetOwner(self)
		wep:SetPos(shootpos.Pos)
		wep:Spawn()
		wep:SetNotSolid(true)
		wep:SetTrigger(false)
		wep:SetParent(self)
		
		wep:Fire("setparentattachment", "anim_attachment_RH")
		wep:SetRenderMode(RENDERMODE_TRANSALPHA)
		wep:AddEffects(EF_BONEMERGE)
		wep:SetAngles(self:GetForward():Angle())
		
		self:SetNWEntity("Weapon", wep)
		self.Weapon = wep
	end
	
end

function ENT:SetEnemy( ent )

	self.Enemy = ent
	
end

function ENT:GetEnemy()

	return self.Enemy
	
end


function ENT:HaveEnemy()

	local enemy = self:GetEnemy()
	local loseTargetDist = 4000
	
	if IsValid(enemy) then
	
		if self:GetRangeTo(enemy:GetPos()) > loseTargetDist then
		
			return self:FindEnemy()
			
		end
	
		return true
		
	else
	
		return self:FindEnemy()
		
	end

	
end

function ENT:FindEnemy()

	local dist = 3000
	local nearby = ents.FindInSphere(self:GetPos(), dist)
	
	for k,v in pairs(nearby) do
		if v:IsNPC() and v ~= self and v ~= self.TargetEnt then
			self:SetEnemy(v)
			return true
		end
	end

	self:SetEnemy(nil)
	return false
	
end

function ENT:ChaseEnemy( options )

	local options = options or { }
	local enemy = self:GetEnemy()
	
	local dist = self:GetPos():Distance(enemy:GetPos())
	if dist <= 200 then
		return "ok"
	end
	
	local path = Path( "Follow" )
	path:SetMinLookAheadDistance( options.lookahead or 300 )
	path:SetGoalTolerance( options.tolerance or 20 )
	path:Compute( self, self:GetEnemy():GetPos() )		-- Compute the path towards the enemy's position

	if ( !path:IsValid() ) then return "failed" end

	local reached = false
	local fallback = false
	
	while ( path:IsValid() and self:HaveEnemy() and reached == false ) do
		
		local enemy = self:GetEnemy()
		local enemyPos = enemy:GetPos()
		
		if ( path:GetAge() > 0.1 ) then
			path:Compute(self, enemyPos)-- Compute the path towards the enemy's position again
		end
		
		path:Update( self )								-- This function moves the bot along the path
		
		local curPos = self:GetPos()
					
		if ( options.draw ) then path:Draw() end
		-- If we're stuck then call the HandleStuck function and abandon
		if ( self.loco:IsStuck() ) then
			self:HandleStuck()
			return "stuck"
		end
		
		local dist = self:GetPos():Distance(enemy:GetPos())
		local zdelta = enemyPos.z - curPos.z
		if(zdelta < 0) then zdelta = zdelta * -1 end
		
		if dist >= 600 and (zdelta < 100) then
		
			local dir = (enemy:GetPos() - self:GetPos()):Angle()
			self:Teleport(self:GetPos() + (dir:Forward() * (dist - 200)), dir)
			coroutine.wait(0.25)
			self:StartActivity( ACT_RUN_AIM_RIFLE )

		elseif dist <= 100 then
			reached = true
			fallback = true
			
		elseif dist <= 300 then
			reached = true
		end
		
		coroutine.yield()

	end

	return "ok"

end

function ENT:ShootEnemy()

	local enemy = self:GetEnemy()
	if not IsValid(enemy) then
		return
	end
	
	local wep = self.Weapon
	local bullet = { }

	local hitPos = enemy:GetPos()
	if enemy:IsNPC() then
		hitPos = enemy:EyePos()
	elseif enemy:IsPlayer() then
		hitPos = enemy:EyePos()
	end
	
	local muzzle = wep:LookupAttachment("muzzle")
	local obj = wep:GetAttachment(muzzle)
	local srcPos = obj.Pos
		
	bullet.Num 	= 1
	bullet.Src 	= self.Weapon:GetPos()
	bullet.Dir 	= hitPos - srcPos
	
	bullet.Spread 	= Vector( 1, 1, 0 )	 -- Aim Cone
	bullet.Tracer	= 5 -- Show a tracer on every x bullets 
	bullet.Force	= 1 -- Amount of force to give to phys objects
	bullet.Damage	= 1
	bullet.AmmoType = "Pistol"
	
	self:FireBullets( bullet )
	
	wep:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:MuzzleFlash()
	self:SetAnimation(PLAYER_ATTACK1)

	return true
	
end

function ENT:RunBehaviour()

	while ( true ) do

		local wep = self.Weapon	
		if not IsValid(wep) then
			self:GiveWeapon()
		end
						
		if self:HaveEnemy() then
		
			--print("Got enemy")
			
			local enemy = self:GetEnemy()
			self.loco:FaceTowards(enemy:GetPos())
								
			self:StartActivity( ACT_RUN_AIM_RIFLE )
			self.loco:SetDesiredSpeed(130)
			self:ChaseEnemy()
			self:StartActivity( ACT_RANGE_ATTACK_AR2 )
			self:ShootEnemy()
			
			coroutine.wait(0.15)
					
		else
				
			print("Wandering")
	
			-- Wander around
			self:StartActivity(ACT_WALK_AIM_RIFLE)
			self.loco:SetDesiredSpeed(80)
			self:MoveToPos(self:GetPos() + Vector(math.random(-1, 1), math.random(-1, 1), 0) * 100)
			self:StartActivity(ACT_IDLE)

			coroutine.wait(0.5)
					
		end
				
		--coroutine.yield()
		
	end

end

function ENT:FirePrimary()

	

end

function ENT:FireSecondary()

end

function ENT:TriggerTeleportEffect(desiredPos, posDir)

	local pos = self:GetPos()
	local ang = self:GetAngles()
	
	local effectdata = EffectData()
	effectdata:SetStart( pos  )
	effectdata:SetOrigin( pos )
	effectdata:SetEntity(self)
	effectdata:SetScale(1)
	effectdata:SetNormal(posDir)
	util.Effect( "coop_teleport_effect", effectdata )
	
	effectdata = EffectData()
	effectdata:SetStart( desiredPos)
	effectdata:SetOrigin( desiredPos )
	effectdata:SetScale( 1 )
	effectdata:SetNormal( posDir )
	effectdata:SetMagnitude( 100 )
	effectdata:SetAngles(ang)
	effectdata:SetAttachment(3)
	util.Effect( "StriderMuzzleFlash", effectdata )	
	
	local effectdata = EffectData()
		effectdata:SetOrigin( desiredPos )
		effectdata:SetNormal( posDir * 10 )
		effectdata:SetMagnitude( 100 )
		effectdata:SetScale( 1 * 60 )
		effectdata:SetAngles(ang)
		effectdata:SetRadius( 100 )
	util.Effect( "ThumperDust", effectdata, true, true )
	
end

function ENT:OnKilled(dmginfo)

	print("!!!!!! Killed !!!!!!")
	
	if IsValid(self.TargetEnt) then
	
		self.TargetEnt:Remove()
		self.TargetEnt = nil
		
	end
	
	hook.Call( "OnNPCKilled", GAMEMODE, self, dmginfo:GetAttacker(), dmginfo:GetInflictor() )

	local wep = self.Weapon
	if IsValid(wep) then
		wep:SetParent(nil)
	end
	
	self:BecomeRagdoll( dmginfo )

end

function ENT:Teleport(pos, ang)

	ang = ang or Angle(0,0,0)
	
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetColor(Color(255, 255, 255, 0))
	
	if self.Weapon then
		self.Weapon:SetRenderMode(RENDERMODE_TRANSALPHA)
		self.Weapon:SetColor(Color(255, 255, 255, 0))
	end
	
	self.State = STATE_TELEPORT
	self:StartActivity( ACT_WALK_RIFLE  )
	
	local posDir = (self:GetPos() - pos):GetNormal()
	local angDir = posDir:Angle()
	local vel = angDir:Forward() * 100
	
	self:TriggerTeleportEffect(pos, posDir)
			
	local self = self
	self:SetPos(pos)
	timer.Simple(0.2, function()
		self:SetVelocity(vel)
		self:SetPos(pos)
		self:SetAngles(ang)
		self:StartActivity( ACT_IDLE )
		self:SetColor(Color(255, 255, 255, 255))
		if self.Weapon then
			self.Weapon:SetRenderMode(RENDERMODE_TRANSALPHA)
			self.Weapon:SetColor(Color(255, 255, 255, 255))
		end
	end)
		
	timer.Simple(0.1, function()
		self:SetVelocity(Vector(0,0,-90))
	end)
	
end

function ENT:EffectStart()
	DbgPrint("Effect Started")
end

if SERVER then
	
	local SuperSoldiers = {}

	hook.Add("OnEntityCreated", "HL2COOP_Supersoldier_Create", function(ent)
		
		local class = ent:GetClass()
		if class == "npc_coop_supersoldier" then
		
			SuperSoldiers[ent] = true			
			print("Added soldier")
			
		elseif EnemyClasses[class] then
		
			print("Detected a enemy to supersoldier")
			
			for k,_ in pairs(SuperSoldiers) do
			
				--k:AddEntityRelationship(ent, D_HT, 99)
				ent:AddEntityRelationship(k, D_HT, 99)
				print("Adding relationship to target:", ent)
				
				local targetEnt = k.TargetEnt
				if IsValid(targetEnt) then
					ent:AddEntityRelationship(targetEnt, D_HT, 99)
					print("Adding relationship to target:", targetEnt)
				else
					print("No bullseye found, something is wrong:", targetEnt)
				end
				
			end			
			
		end

	end)

	hook.Add("EntityRemoved", "HL2COOP_Supersoldier_Remove", function(ent)

		if ent:GetClass() == "npc_coop_supersoldier" then
		
			if SuperSoldiers[ent] ~= nil then
				SuperSoldiers[ent] = nil
				print("Removed soldier")
			end
			
		end

	end)
	
	hook.Add("EntityTakeDamage", "HL2COOP_Supersolider_Damage", function(target, dmginfo)
	
		if target:GetClass() == "npc_bullseye" then
		
			local parent = target:GetParent()
			if IsValid(parent) and parent:GetClass() == "npc_coop_supersoldier" then
			
				-- Redirect this damage to the parent.
				if dmginfo:GetAttacker() == parent then
					return true
				else
					print("Redirecting damage")
					parent:TakeDamageInfo(dmginfo)
					return true
				end
				
			end
		
		end
	
	end)
	
end