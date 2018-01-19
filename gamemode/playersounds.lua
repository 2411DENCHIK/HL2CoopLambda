include("extends/player.lua")

local HurtSounds = {}

-- Male
HurtSounds["male"] = {}
HurtSounds["male"][HITGROUP_LEFTARM] = {
	"vo/npc/male01/myarm01.wav", 
	"vo/npc/male01/myarm02.wav"
}
HurtSounds["male"][HITGROUP_RIGHTARM] = {
	"vo/npc/male01/myarm01.wav", 
	"vo/npc/male01/myarm02.wav"
}
HurtSounds["male"][HITGROUP_LEFTLEG] = {
	"vo/npc/male01/myleg01.wav", 
	"vo/npc/male01/myleg02.wav"
}
HurtSounds["male"][HITGROUP_RIGHTLEG] = {
	"vo/npc/male01/myleg01.wav", 
	"vo/npc/male01/myleg02.wav"
}
HurtSounds["male"][HITGROUP_STOMACH] = {
	"vo/npc/male01/hitingut01.wav", 
	"vo/npc/male01/hitingut02.wav", 
	"vo/npc/male01/mygut02.wav"
}
HurtSounds["male"][HITGROUP_GENERIC] = {
	"vo/npc/male01/pain01.wav", 
	"vo/npc/male01/pain02.wav", 
	"vo/npc/male01/pain03.wav",
	"vo/npc/male01/pain04.wav",
	"vo/npc/male01/pain04.wav",
	"vo/npc/male01/pain05.wav",
	"vo/npc/male01/pain06.wav",
	"vo/npc/male01/pain07.wav",
	"vo/npc/male01/pain08.wav",
	"vo/npc/male01/pain09.wav"
}
HurtSounds["male"][HITGROUP_CHEST] = {
	"vo/npc/male01/pain01.wav", 
	"vo/npc/male01/pain02.wav", 
	"vo/npc/male01/pain03.wav",
	"vo/npc/male01/pain04.wav",
	"vo/npc/male01/pain04.wav",
	"vo/npc/male01/pain05.wav",
	"vo/npc/male01/pain06.wav",
	"vo/npc/male01/pain07.wav",
	"vo/npc/male01/pain08.wav",
	"vo/npc/male01/pain09.wav"
}
HurtSounds["male"][HITGROUP_GEAR] = {
	"vo/npc/male01/pain01.wav", 
	"vo/npc/male01/pain02.wav", 
	"vo/npc/male01/pain03.wav",
	"vo/npc/male01/pain04.wav",
	"vo/npc/male01/pain04.wav",
	"vo/npc/male01/pain05.wav",
	"vo/npc/male01/pain06.wav",
	"vo/npc/male01/pain07.wav",
	"vo/npc/male01/pain08.wav",
	"vo/npc/male01/pain09.wav"
}

-- Female
HurtSounds["female"] = {}
HurtSounds["female"][HITGROUP_LEFTARM] = {
	"vo/npc/female01/myarm01.wav", 
	"vo/npc/female01/myarm02.wav"
}
HurtSounds["female"][HITGROUP_RIGHTARM] = {
	"vo/npc/female01/myarm01.wav", 
	"vo/npc/female01/myarm02.wav"
}
HurtSounds["female"][HITGROUP_LEFTLEG] = {
	"vo/npc/female01/myleg01.wav", 
	"vo/npc/female01/myleg02.wav"
}
HurtSounds["female"][HITGROUP_RIGHTLEG] = {
	"vo/npc/female01/myleg01.wav", 
	"vo/npc/female01/myleg02.wav"
}
HurtSounds["female"][HITGROUP_STOMACH] = {
	"vo/npc/female01/hitingut01.wav", 
	"vo/npc/female01/hitingut02.wav", 
	"vo/npc/female01/mygut02.wav"
}
HurtSounds["female"][HITGROUP_GENERIC] = {
	"vo/npc/female01/pain01.wav", 
	"vo/npc/female01/pain02.wav", 
	"vo/npc/female01/pain03.wav",
	"vo/npc/female01/pain04.wav",
	"vo/npc/female01/pain04.wav",
	"vo/npc/female01/pain05.wav",
	"vo/npc/female01/pain06.wav",
	"vo/npc/female01/pain07.wav",
	"vo/npc/female01/pain08.wav",
	"vo/npc/female01/pain09.wav"
}
HurtSounds["female"][HITGROUP_CHEST] = {
	"vo/npc/female01/pain01.wav", 
	"vo/npc/female01/pain02.wav", 
	"vo/npc/female01/pain03.wav",
	"vo/npc/female01/pain04.wav",
	"vo/npc/female01/pain04.wav",
	"vo/npc/female01/pain05.wav",
	"vo/npc/female01/pain06.wav",
	"vo/npc/female01/pain07.wav",
	"vo/npc/female01/pain08.wav",
	"vo/npc/female01/pain09.wav"
}
HurtSounds["female"][HITGROUP_GEAR] = {
	"vo/npc/female01/pain01.wav", 
	"vo/npc/female01/pain02.wav", 
	"vo/npc/female01/pain03.wav",
	"vo/npc/female01/pain04.wav",
	"vo/npc/female01/pain04.wav",
	"vo/npc/female01/pain05.wav",
	"vo/npc/female01/pain06.wav",
	"vo/npc/female01/pain07.wav",
	"vo/npc/female01/pain08.wav",
	"vo/npc/female01/pain09.wav"
}

local NPCKillSounds = {}

NPCKillSounds["male"] = 
{
	"vo/npc/male01/gotone01.wav",
	"vo/npc/male01/gotone02.wav",
}

NPCKillSounds["female"] = 
{
	"vo/npc/male01/gotone01.wav",
	"vo/npc/male01/gotone02.wav",
}

local PlayerKillSounds = {}

PlayerKillSounds["male"] = {
	"vo/npc/male01/gordead_ans01.wav",
	"vo/npc/male01/gordead_ans02.wav",
	"vo/npc/male01/gordead_ans03.wav",
	"vo/npc/male01/gordead_ans04.wav",
	"vo/npc/male01/gordead_ans05.wav",
	"vo/npc/male01/gordead_ans06.wav",
	"vo/npc/male01/gordead_ans07.wav",
	"vo/npc/male01/gordead_ans08.wav",
	"vo/npc/male01/gordead_ans09.wav",
	"vo/npc/male01/gordead_ans10.wav",
	"vo/npc/male01/gordead_ans11.wav",
	"vo/npc/male01/gordead_ans12.wav",
	"vo/npc/male01/gordead_ans13.wav",
	"vo/npc/male01/gordead_ans14.wav",
	"vo/npc/male01/gordead_ans15.wav",
	"vo/npc/male01/gordead_ans16.wav",
	"vo/npc/male01/gordead_ans17.wav",
	"vo/npc/male01/gordead_ans18.wav",
	"vo/npc/male01/gordead_ans19.wav",
	"vo/npc/male01/gordead_ans20.wav",
}
PlayerKillSounds["female"] = {
	"vo/npc/female01/gordead_ans01.wav",
	"vo/npc/female01/gordead_ans02.wav",
	"vo/npc/female01/gordead_ans03.wav",
	"vo/npc/female01/gordead_ans04.wav",
	"vo/npc/female01/gordead_ans05.wav",
	"vo/npc/female01/gordead_ans06.wav",
	"vo/npc/female01/gordead_ans07.wav",
	"vo/npc/female01/gordead_ans08.wav",
	"vo/npc/female01/gordead_ans09.wav",
	"vo/npc/female01/gordead_ans10.wav",
	"vo/npc/female01/gordead_ans11.wav",
	"vo/npc/female01/gordead_ans12.wav",
	"vo/npc/female01/gordead_ans13.wav",
	"vo/npc/female01/gordead_ans14.wav",
	"vo/npc/female01/gordead_ans15.wav",
	"vo/npc/female01/gordead_ans16.wav",
	"vo/npc/female01/gordead_ans17.wav",
	"vo/npc/female01/gordead_ans18.wav",
	"vo/npc/female01/gordead_ans19.wav",
	"vo/npc/female01/gordead_ans20.wav",
}

function GM:EmitPlayerHurt(ply, hitgroup)
	-- Lets emit some pain.
	local gender = ply:GetGender()
	
	ply.LastPainEmit = ply.LastPainEmit or (RealTime() - 3)
	
	local sounds = HurtSounds[gender]
	if sounds then
	
		local hitcat = sounds[hitgroup]
		if hitcat then
		
			local snd = table.Random(hitcat)
			if RealTime() - ply.LastPainEmit >= 3.0 and ply:Alive() then
				ply:EmitSound(snd)
				ply.LastPainEmit = RealTime()
			end
			
		end
		
	end
end

function GM:EmitPlayerNPCKill(ply, npc)
	
	local gender = ply:GetGender()
	
	ply.LastKillEmit = ply.LastKillEmit or (RealTime() - 5)
	
	if math.random(10) == 1 then
		local sounds = NPCKillSounds[gender]
		if sounds then
		
			if RealTime() - ply.LastKillEmit >= 5 then
			
				local snd = table.Random(sounds)
				timer.Simple(1, function()
					if IsValid(ply) and ply:Alive() then
						ply:EmitSound(snd)
					end
				end)
				
				ply.LastKillEmit = RealTime()
				
			end
			
		end
	end
	
end

function GM:EmitPlayerDeath(ply)

	local nearbyEnts = ents.FindInBox(ply:GetPos() - Vector(1000, 1000, 500), ply:GetPos() + Vector(1000, 1000, 500))

	local nearbyPlayer = {}
	for k,v in pairs(nearbyEnts) do
		if IsValid(v) and v:IsPlayer() and v ~= ply and v:Alive() then
			table.insert(nearbyPlayer, v)
		end
	end
	
	if #nearbyPlayer == 0 then
		return
	end
	
	for k,v in pairs(nearbyPlayer) do
	
		if math.random(1, #nearbyPlayer) == 1 and IsValid(v) and v:IsPlayer() then
		
			local randomPly = v
			randomPly.LastDeathEmit = randomPly.LastDeathEmit or (RealTime() - 2)
			
			if RealTime() - randomPly.LastDeathEmit >= 2 then
				
				print("Player Speak: "..tostring(v))
				local gender = v:GetGender()
				local snd = table.Random(PlayerKillSounds[gender])
				
				timer.Simple(math.random(0.5, 1.5), function()
					if IsValid(randomPly) and randomPly:Alive() then
						randomPly:EmitSound(snd)
					end
				end)
				
				randomPly.LastDeathEmit = RealTime()
			
			end
			
		end
		
	end
	
	
end
