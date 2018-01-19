-- Shared
--

include("sh_headcrabs.lua")

local RagdollSounds = 
{
	"physics/body/body_medium_break2.wav",
	"physics/body/body_medium_break3.wav",
	"physics/body/body_medium_break4.wav",
	"physics/body/body_medium_impact_hard1.wav",
	"physics/body/body_medium_impact_hard2.wav",
	"physics/body/body_medium_impact_hard3.wav",
	"physics/body/body_medium_impact_hard4.wav",
	"physics/body/body_medium_impact_hard5.wav",
	"physics/body/body_medium_impact_hard6.wav",
	"physics/body/body_medium_impact_soft1.wav",
	"physics/body/body_medium_impact_soft2.wav",
	"physics/body/body_medium_impact_soft3.wav",
	"physics/body/body_medium_impact_soft4.wav",
	"physics/body/body_medium_impact_soft5.wav",
	"physics/body/body_medium_impact_soft6.wav",
	"physics/body/body_medium_impact_soft7.wav",
}

function GM:RagdollCrush(ent, data)

	if( data.Speed >= 220 ) then
	
		ent.LastCrushSound = ent.LastCrushSound or (RealTime() - 0.1)
		
		-- Emit sound
		if RealTime() - ent.LastCrushSound > 0.1 then
		
			local snd = RagdollSounds[ math.random(#RagdollSounds) ]
			ent:EmitSound(snd)
		
		end
		
		local bloodeffect = "BloodImpact"
		local blooddecal = "Blood"
		local mdl = ent:GetModel()
		if mdl == "models/combine_strider.mdl" then
			bloodeffect = "StriderBlood"
			blooddecal = "YellowBlood"
		end
		-- Blood
		local effectdata = EffectData()
		effectdata:SetNormal(data.HitPos - data.HitNormal)
		effectdata:SetOrigin(data.HitPos)
		effectdata:SetScale(1)
		util.Effect( bloodeffect, effectdata )
		
		local maxs = data.HitPos + data.HitNormal
		local mins = data.HitPos - data.HitNormal
		util.Decal(blooddecal, maxs, mins)
	end
	
end

function GM:CreateEntityRagdoll( owner, ragdoll )
	
	DbgPrint("CreateEntityRagdoll")
	
	if IsValid(owner) and owner:IsPlayer() and IsValid(owner.Zombie) then
	
		DbgPrint("Player will become a Zombie")
		
		if IsValid(ragdoll) then
			owner.RagdollModel = ragdoll:GetModel()
		end
		
		ragdoll:Remove()
		
		return false
		
	elseif IsValid(owner) and IsValid(ragdoll) then
	
		DbgPrint("Created new ragdoll: " .. tostring(owner) .. ":" .. tostring(ragdoll))
	
		owner:SetNWEntity("Ragdoll", ragdoll)
		
		ragdoll.LastCrushSound = 0
		ragdoll:AddCallback("PhysicsCollide", function(ent, data) GAMEMODE:RagdollCrush(ent, data) end)
		ragdoll:SetCollisionGroup(COLLISION_GROUP_DISSOLVING)
		
		hook.Add("PlayerSpawn", ragdoll, function(ragdoll, ply)
			if ply == owner then
				hook.Remove("PlayerSpawn", ragdoll)
				timer.Simple(10, function()
					if IsValid(ragdoll) then
						ragdoll:Remove()
					end
				end)
			end
		end)
		
		if owner.VehicleDeath == true then
			owner.VehicleDeath = nil
			local phys = ragdoll:GetPhysicsObject()
			if IsValid(phys) then
				phys:AddVelocity(owner.RagdollForce)
			end
			DbgPrint("Vehicle Death")
		end
				
	else
		DbgPrint("Unknown case")
	end
	
end
