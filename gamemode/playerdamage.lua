DEFINE_BASECLASS( "gamemode_base" )

include("playersounds.lua")

function GM:GetDifficultyScale(reverse)

	return 1.3

	--[[
	reverse = reverse or false
	local players = #player.GetAll() + 5
	-- Listen server returns 0 in this case.
	local maxplayers = math.Clamp(game.MaxPlayers( ), 1, 64)
	local difficulty = 1.2 - (players / maxplayers)

	if reverse then
		difficulty = 1.5 - difficulty
	end

	return difficulty
	]]

end

function GM:ScalePlayerDamage(ply, hitgroup, dmginfo)

	if ( hitgroup == HITGROUP_HEAD ) then
		dmginfo:ScaleDamage( 2 )
	end

	if ( hitgroup == HITGROUP_LEFTARM or
		hitgroup == HITGROUP_RIGHTARM or
		hitgroup == HITGROUP_LEFTLEG or
		hitgroup == HITGROUP_RIGHTLEG or
		hitgroup == HITGROUP_GEAR )
	then
		dmginfo:ScaleDamage( 0.50 )
	end

	local difficultyTable =
	{
		[0] = 1.0,
		[1] = 1.2,
		[2] = 1.25,
		[3] = 1.30,
		[4] = 1.35,
		[5] = 1.40,
		[6] = 1.45,
		[7] = 1.50,
		[8] = 1.55,
		[9] = 1.60,
		[10] = 1.65,
		[11] = 1.70,
		[12] = 1.75,
	}

	local scale = difficultyTable[#player.GetAll()] or 1.75
	DbgPrint("Player Damage Scale: " .. tostring(scale))
	dmginfo:ScaleDamage(scale)

	self:EmitPlayerHurt(ply, hitgroup)

	return dmginfo

end

function GM:ScaleNPCDamage(npc, hitgroup, dmginfo)

	local ammotype = dmginfo:GetAmmoType()
	--print(ammotype)
	--[[
	if ammotype == 7 then
		--print("Shotgun Damage")
		-- "sk_plr_dmg_buckshot" = "8"
		dmginfo:SetDamage(12)
	elseif ammotype == 3 then
		--print("Pistol Damage")
		-- "sk_plr_dmg_pistol" = "5"
		dmginfo:SetDamage(5)
	elseif ammotype == 5 then
		--print("357 Damage")
		-- "sk_plr_dmg_357" = "40"
		dmginfo:SetDamage(40)
	elseif ammotype == 1 then
		--print("AR2 Damage")
		-- "sk_plr_dmg_ar2" = "8"
		dmginfo:SetDamage(8)
	elseif ammotype == 4 then
		--print("SMG1 Damage")
		-- "sk_plr_dmg_smg1" = "4"
		dmginfo:SetDamage(4)
	end
	]]

	if ( hitgroup == HITGROUP_HEAD ) then
		dmginfo:ScaleDamage(2)
	elseif ( hitgroup == HITGROUP_LEFTARM or
		hitgroup == HITGROUP_RIGHTARM or
		hitgroup == HITGROUP_LEFTLEG or
		hitgroup == HITGROUP_RIGHTLEG or
		hitgroup == HITGROUP_GEAR )
	then
		dmginfo:ScaleDamage( 0.50 )
	end

	local difficultyTable =
	{
		[0] = 1.0,
		[1] = 1.0,
		[2] = 0.95,
		[3] = 0.90,
		[4] = 0.85,
		[5] = 0.80,
		[6] = 0.75,
		[7] = 0.70,
		[8] = 0.65,
		[9] = 0.60,
		[10] = 0.55,
		[11] = 0.50,
		[12] = 0.45,
	}

	local scale = difficultyTable[#player.GetAll()] or 1.75
	DbgPrint("NPC Damage Scale: " .. tostring(scale))
	dmginfo:ScaleDamage(scale)

	--print("Difficulty", difficulty)
	--dmginfo:ScaleDamage(difficulty)

	return dmginfo

end

function GM:OnNPCKilled(npc, attacker, weapon)

	if npc and npc.OnDeath then
		npc:OnDeath(attacker, weapon)
	end

	if IsValid(attacker) and attacker:IsPlayer() then
		self:EmitPlayerNPCKill(attacker, npc)
		attacker:AddFrags(1)
	end

	BaseClass.OnNPCKilled(self, npc, attacker, weapon)

end
