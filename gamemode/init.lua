-- Server
--

AddCSLuaFile( 'cl_init.lua' )
AddCSLuaFile( 'shared.lua' )
AddCSLuaFile( 'changelevel.lua' )
AddCSLuaFile( 'debug/showents.lua' )
AddCSLuaFile( 'debug/print.lua')
AddCSLuaFile( 'extends/entity.lua')
AddCSLuaFile( 'extends/ents.lua')
AddCSLuaFile( 'extends/player.lua' )
AddCSLuaFile( 'vehicles.lua' )
AddCSLuaFile( 'sh_death.lua' )
AddCSLuaFile( 'effects.lua' )
AddCSLuaFile( 'weapon_system.lua' )
AddCSLuaFile( 'cl_taunts.lua' )
AddCSLuaFile( 'teams.lua' )
AddCSLuaFile( 'cl_hudpickup.lua' )
AddCSLuaFile( 'playerindicators.lua' )
AddCSLuaFile( 'cl_drawing.lua' )
AddCSLuaFile(' sh_options.lua' )

if file.Exists('gamemodes/'..GM.FolderName..'/gamemode/mapscripts/' .. game.GetMap() .. '.lua','MOD') then
	AddCSLuaFile( "mapscripts/" .. game.GetMap() .. ".lua" )
end

local sv_coop_friendlyfire = CreateConVar("sv_coop_friendlyfire", "0", FCVAR_ARCHIVE, "Enable/Disable friendly fire")

DEFINE_BASECLASS( "gamemode_base" )

include('save.lua')
include('shared.lua')
include('weapons_per_map.lua')
include('playerdamage.lua')
include('taunts.lua')
include('teams.lua')
include('sv_resources.lua')

-- Should be always the last one.
if file.Exists('gamemodes/'..GM.FolderName..'/gamemode/mapscripts/' .. game.GetMap() .. '.lua','MOD') then
	include("mapscripts/" .. game.GetMap() .. ".lua")
end

function GM:Initialize()
	DbgPrint("-- GM:Initialize --")

	self.InitialFrame = false
	self.MapStarted = false
	self.MapScriptInitialized = false
	self.MasterVehicles = {}
end

function GM:SetupEntryEntity()

	local coop_autostart_entity = ents.Create("coop_condition")
	coop_autostart_entity:SetName("coop_autostart_entity")
	coop_autostart_entity:Spawn()
	coop_autostart_entity.OnTrigger = function(self)
		DbgPrint("Autostart Entity Triggered")
	end

	local coop_entry_entity = ents.Create("logic_auto")
	coop_entry_entity:SetKeyValue("spawnflags", "1")
	coop_entry_entity:Spawn()
	coop_entry_entity:Fire("AddOutput", "OnNewGame coop_autostart_entity,Trigger")


end

function GM:OnGamemodeLoaded()

	DbgPrint("OnGamemodeLoaded")

	local curmap = game.GetMap()

	-- Make sure this directory also exists.
	file.CreateDir("hl2coop")

	-- Lets check if we have reached our destinated map from the last change.
	-- This ensures in case of a crash between changelevel that it won't start at the map given in the start parameters.
	local changemap = file.Read("hl2coop/changelevel.txt", "DATA")
	if changemap ~= nil and #changemap > 0 then
		if curmap ~= changemap then
			-- Changelevel to the required map.
			game.ConsoleCommand("changelevel " .. changemap .. "\n")
			return
		else
			-- Wipe content.
			file.Write("hl2coop/changelevel.txt", "")
		end
	end

	-- We require the previous map to properly index our next map.
	local oldmap = file.Read("hl2coop/curmap.txt", "DATA")
	if oldmap then
		if oldmap ~= curmap then
			self.PrevMap = oldmap
			file.Write("hl2coop/prevmap.txt", oldmap)
		end
	end
	file.Write("hl2coop/curmap.txt", curmap)

end

-- Called by coop_changelevel trigger, makes sure the map we want to change to is stored.
function GM:PreChangelevel(map)

	self:WriteSaveData()

	file.Write("hl2coop/changelevel.txt", map)

end

function GM:PlayerInitialSpawn( ply )
	DbgPrint("PlayerInitialSpawn",ply)
	ply.FirstLoadout=true
	ply.InitialSpawn = true

	if self.MapStarted == false then
		hook.Call("MapStart", GAMEMODE)
		self.MapStarted = true
	end

end

function GM:PlayerLoadout(player)
	DbgPrint("PlayerLoadout")

	local map = game.GetMap()
	if map == "d1_trainstation_01" or
	   map == "d1_trainstation_02" or
	   map == "d1_trainstation_03" or
	   map == "d1_trainstation_04" or
	   map == "d1_trainstation_05" then
		player:RemoveSuit()
	else
		player:EquipSuit()
	end

	if player.FirstLoadout then
		if self:HasSaveData(player) then
			print("Saved loadout")
			self:LoadSave(player)
		else
			print("Default loadout")
			self:GiveDefaultWeapons(player)
		end
		player.FirstLoadout=false
		return
	end

	print("Default loadout")
	self:GiveDefaultWeapons(player)
end

function GM:PlayerSpawn(ply)

	DbgPrint("PlayerSpawn", ply)

	if ply.InitialSpawn == nil or ply.InitialSpawn == false then
		ply.InitialSpawn = true
		if self.MapStarted == false then
			hook.Call("MapStart", GAMEMODE)
			self.MapStarted = true
		end
	end

	player_manager.SetPlayerClass( ply, "player_coop" )

	self:RemovePlayerVehicle(ply)
	self:CheckVehicles()

	ply:SetName("!player")

	local oldhands = ply:GetHands()
	if ( IsValid( oldhands ) ) then oldhands:Remove() end

	local hands = ents.Create( "gmod_hands" )
	if ( IsValid( hands ) ) then
		ply:SetHands( hands )
		hands:SetOwner( ply )

		-- Which hands should we use?
		local cl_playermodel = ply:GetInfo( "cl_playermodel" )
		local info = player_manager.TranslatePlayerHands( cl_playermodel )
		if ( info ) then
			hands:SetModel( info.model )
			hands:SetSkin( info.skin )
			hands:SetBodyGroups( info.body )
		end

		-- Attach them to the viewmodel
		local vm = ply:GetViewModel( 0 )
		hands:AttachToViewmodel( vm )

		vm:DeleteOnRemove( hands )
		ply:DeleteOnRemove( hands )

		hands:Spawn()
	end

	ply:SetShouldServerRagdoll(true)
	ply:SetCustomCollisionCheck(true)
	ply:SetNoCollideWithTeammates(true)

	-- Assign Team.
	ply:SetTeam(COOP_TEAM_ALIVE)

	return BaseClass.PlayerSpawn(self, ply)

end

function GM:RunMapScript()

	print("-- Run Map Script --")

	-- Transition data.
	self.SaveData = GAMEMODE:LoadSaveData()

	local current = self:GetCurrentMapIndex()
	DbgPrint("Current Map Index: " .. current)

	if self.InitMapScript then
		DbgPrint("InitMapScript")
		self:InitMapScript()
	end

	-- Changelevel Triggers
	self:ReplaceChangelevelTriggers()
	self:AvoidItemPushing()

	-- Open all area portals and rename them.
	for k,v in pairs(ents.FindByClass("func_areaportal")) do
		v:Fire("Open")
		v:SetName("foobar")
	end

	-- Annoying
	for k,v in pairs(ents.FindByClass("func_areaportalwindow")) do
		v:Fire("SetFadeStartDistance", "0")
		v:Fire("SetFadeEndDistance", "999999999")
		v:Fire("Open")
		v:SetName("foobar")
	end

	for k,v in pairs(ents.FindByClass("func_illusionary")) do
		v:Fire("Open")
	end

	-- Doors
	if GetConVarNumber("sv_coop_doorsonlyopen") == 1 then
		for k,v in pairs(ents.FindByClass("prop_door_rotating")) do
			v:SetKeyValue("spawnflags", "0")
		end
	end

	-- After everything is setup we call PostInitMapScript
	if self.PostInitMapScript then
		self:PostInitMapScript()
	end

	-- Reload system means round restart.
	for k,v in pairs(ents.FindByClass("player_loadsaved")) do
		local load_save = ents.Create("coop_condition")
		load_save:Replace(v)
		load_save.OnReload = function(self)
			DbgPrint("Round restart")
			GAMEMODE:RestartRound()
		end
	end

	-- Fix for specific sight on conditions.
	-- Breaks more stuff than fixing.
	--[[
	for k,v in pairs(ents.FindByClass("ai_script_conditions")) do
		v:SetKeyValue("PlayerActorFOV", "-1")
		v:SetKeyValue("PlayerTargetLOS", "3")
	end
	]]

	self.MapScriptInitialized = true

end

function GM:MapLoaded()
	DbgPrint("MapLoaded")
	--self:RunMapScript()
	--self:SetupEntryEntity()
end

function GM:PreCleanupMap()
	DbgPrint("PreCleanupMap")

	self.RestartingRound = true
	self.MapScriptInitialized = false
	self.InitialFrame = false

	for k,v in pairs(player.GetAll()) do
		if IsValid(v) then
			v:StripWeapons()
			v:KillSilent()
		end
	end

	self.MasterVehicles = {}
	self.MapStarted = false

end

function GM:PostCleanupMap()
	DbgPrint("PostCleanupMap")

	self:SetupEntryEntity()

	local self = self
	timer.Simple(0.1, function()
		self:RunMapScript(true)
		for k,v in pairs(player.GetAll()) do
			v:Spawn()
		end
		self.RestartingRound = false
	end)

end

function GM:PlayerSwitchFlashlight( player, state )
	if state then return player:IsSuitEquipped() else return true end
end

function GM:PlayerSelectSpawn(ply)
	DbgPrint("PlayerSelectSpawn")

	local checkpoints = ents.FindByClass("coop_checkpoint")
	if checkpoints and #checkpoints > 0 then
		return checkpoints[1]
	end

	local spawns = ents.FindByClass("info_player_start")
	for k,v in pairs(spawns) do
		if v.Master then
			DbgPrint("Spawn has Master override")
			ply.InitialPos = v:GetPos()
			return v
		end
	end

	for k,v in pairs(spawns) do
		if v:HasSpawnFlags(1) then
			ply.InitialPos = v:GetPos()
			return v -- Master flag
		end
	end

	-- Fallback.
	--DbgPrint("Failed to find spawn for player: "..tostring(ply))
	ply.InitialPos = spawns[1]:GetPos()
	return spawns[1]

end

-- Called before Player is actually dead.
function GM:PlayerDeath(ply, attacker, dmginfo)

	if not IsValid(ply) then
		return false
	end

	if self.RoundRestarting == false then
		--self:CheckRoundStatus()
	end

	-- Assign Team to dead.
	ply:SetTeam(COOP_TEAM_DEAD)

	ply.DeathTime = CurTime()
	ply:LockPosition(false)
	ply.InitialDeathThink = nil
	ply:AddDeaths(1)
	ply:Freeze(false)

	self:EmitPlayerDeath(ply)

	if ply.OnDeath then
		ply:OnDeath(attacker, dmginfo)
	end

	if IsValid(attacker) then
		if attacker:IsNPC() and attacker:GetClass() == "npc_headcrab" then
			ply:SetShouldServerRagdoll(false)
			hook.Call("PlayerShouldBecomeZombie", self, ply, attacker)
		elseif attacker:IsPlayer() then
			if ply.Zombie == nil then
				attacker:AddFrags(-1)
			end
		else
			ply:SetShouldServerRagdoll(true)
			ply.Zombie = nil
			BaseClass.PlayerDeath(self, ply, attacker, dmginfo)
		end
	end

end

function GM:PlayerDeathSound()
	return true
end

function GM:DoPlayerDeath(ply, attacker, dmginfo)

	self:RemovePlayerFromItemList(ply)

	if ply.OnDoPlayerDeath then
		ply:OnDoPlayerDeath(attacker, dmginfo)
	end

end

function GM:PlayerDeathThink(ply)

	if self.MapScriptInitialized == false then
		return false
	end

	ply.InitialDeathThink = true
	ply.DeathTime = ply.DeathTime or CurTime()

	if IsValid(ply.Zombie) then
		return false
	end

	if self.RestartingRound ~= nil and self.RestartingRound == true then
		return false
	end

	if CurTime() - ply.DeathTime > 5 then
		ply:Spawn()
	end

	self:CheckRoundStatus()

	return false

end

-- Fixes the damage types.
function GM:EntityTakeDamage(ent, dmginfo)

	local inflictor = dmginfo:GetInflictor()
	local dmgtype = dmginfo:GetDamageType()
	local ammotype = dmginfo:GetAmmoType()
	local attacker = dmginfo:GetAttacker()

	--print("Damage Type", dmgtype)
	--print("Damage", dmginfo:GetDamage())

	--[[
	if inflictor:IsVehicle() and inflictor:GetClass() == "prop_vehicle_airboat" then
		-- "sk_npc_dmg_airboat" = "3"
		dmginfo:SetDamage(3)
	elseif inflictor:IsVehicle() and inflictor:GetClass() == "prop_vehicle_jeep" then
		-- "sk_jeep_gauss_damage" = "15"
		dmginfo:SetDamage(15)
	elseif inflictor:GetClass() == "weapon_crowbar" or inflictor:IsPlayer()  then
		-- "sk_npc_dmg_crowbar" = "5"
		dmginfo:SetDamage(5)
	end
	]]

	-- Attacked by headcrabs?
	local attacker = dmginfo:GetAttacker()

	if IsValid(ent) and IsValid(attacker) then

		if ent:IsPlayer() and IsValid(attacker) and attacker:GetClass() == "npc_headcrab" then
			dmginfo:ScaleDamage(2)
		end

		if ent:IsPlayer() and attacker:IsPlayer() then
			if sv_coop_friendlyfire:GetBool() == false then
				dmginfo:ScaleDamage(0)
			end
		end

		if ent:IsNPC() then

			local mdl = ent:GetModel()
			if mdl == "models/odessa.mdl" then
				dmginfo:SetDamage(0)
				return true
			elseif mdl == "models/alyx.mdl" then
				dmginfo:SetDamage(0)
				return true
			elseif mdl == "models/kleiner.mdl" then
				dmginfo:SetDamage(0)
				return true
			elseif mdl == "models/barney.mdl" then
				DbgPrint("Protecting Barney from death!")
				dmginfo:SetDamage(0)
				return true
			elseif mdl == "models/vortigaunt.mdl" then
				dmginfo:SetDamage(0)
				return true
			end

			local name = ent:GetName()
			if attacker:IsPlayer() then
				-- Case where only players should be not able to kill.
				if name == "boxcar_human" or name == "boxcar_vort" then
					dmginfo:SetDamage(0)
					return true
				elseif name == "citizen_greeter" then
					dmginfo:SetDamage(0)
					return true
				elseif name == "mary" then
					dmginfo:SetDamage(0)
					return true
				elseif name == "matt" then
					dmginfo:SetDamage(0)
					return true
				elseif name == "Al" then
					dmginfo:SetDamage(0)
					return true
				elseif name == "Arlene" then
					dmginfo:SetDamage(0)
					return true
				elseif name == "citizen_b_regular_original" then
					dmginfo:SetDamage(0)
					return true
				elseif name == "gatekeeper" then
					dmginfo:SetDamage(0)
					return true
				elseif name == "Chester" then
					dmginfo:SetDamage(0)
					return true
				elseif name == "citizen_greeter" then
					dmginfo:SetDamage(0)
					return true
				elseif name == "lamarr_jumper" then
					dmginfo:SetDamage(0)
					return true
				end
			end
			-- Generic god npcs.
			if name == "stanley" then
				dmginfo:SetDamage(0)
				return true
			elseif name == "warehouse_citizen_jacobs" or name == "warehouse_citizen" or name == "warehouse_citizen_leon" or name == "winston" then
				dmginfo:SetDamage(0)
				return true
			end

		elseif ent:IsPlayer() then

			if ent:IsLockedPosition() then
				dmginfo:SetDamage(0)
				return true
			end

		end

	end

	BaseClass.EntityTakeDamage(ent, dmginfo)

end

function GM:Think()

	if self.InitialFrame == false then
		self.InitialFrame = true
		if self.MapLoaded then
			self:MapLoaded()
		end
	end

	self:CheckVehicles()

	if self.RestartingRound == false then
		self:CheckRoundStatus()
	end

	-- Fix: We are going to remove all env_laserdot's owned by Entity prop_vehicle_apc
	for _,v in pairs(ents.FindByClass("env_laserdot")) do
		local owner = v:GetOwner()
		if IsValid(owner) and owner:GetClass() == "prop_vehicle_apc" then
			v:Remove()
		end
	end

end

function GM:PlayerSwitchFlashlight( ply, state )
	return ply:IsSuitEquipped()
end

function GM:GetFallDamage( ply, speed )
	return ( speed / 10 )
end

function GM:SetupCheckpoint(triggerpos, mins, maxs, checkpointpos, ang, vehicle_pos, vehicle_ang, ignorevehicles)

	local trigger_checkpoint = ents.Create("coop_triggeronce")
	trigger_checkpoint:Init(triggerpos, Angle(0,0,0), mins, maxs)
	trigger_checkpoint.Filter = function(self, ent)
		if IsValid(ent) and ent:IsPlayer() then
			return true
		end
		return false
	end
	trigger_checkpoint.Trigger = function(self, ply)

		DbgPrint("Passed checkpoint trigger")

		ply:PrintMessage(HUD_PRINTCENTER, "Checkpoint reached, new spawnpoint set.")

		-- Remove previous checkpoints
		ents.RemoveByClass("coop_checkpoint")

		local checkpoint = ents.Create("coop_checkpoint")
		checkpoint:SetPos(checkpointpos)
		checkpoint:SetAngles(ang or Angle(0,0,0))
		checkpoint:Spawn()

		-- Place the new vehicles on the checkpoint.
		if GAMEMODE.MasterVehicles and not ignorevehicles then

			for k,v in pairs(GAMEMODE.MasterVehicles) do
				v.Pos = vehicle_pos or checkpointpos
				v.Ang = vehicle_ang or Angle(0,0,0)

				for _,vehicle in pairs(ents.FindByClass(k)) do
					if not IsValid(vehicle.AssignedPlayer) then
						vehicle:Remove()
					end
				end

			end

		end

	end

end

function GM:PlayerTriggerEnter(ply)

	ply:SetTeam(COOP_TEAM_TRIGGER)

end

function GM:PlayerTriggerLeave(ply)

	ply:SetTeam(COOP_TEAM_ALIVE)

end

function GM:InitPostEntity()

	DbgPrint("InitPostEntity")

	timer.Simple(0, function()
		self:RunMapScript(true)
	end)

end

-- Ragdolls should have the same name as the owner.
hook.Add("CreateEntityRagdoll", "HL2CoopRagdollsFix", function(ent, ragdoll)
	if IsValid(ent) and IsValid(ragdoll) then
		ragdoll:SetName(ent:GetName())
	end
end)

hook.Add("OnEntityCreated", "HL2CoopLagdoll", function(ent)
	if ent:IsNPC() then
		ent:SetLagCompensated(true)
	end
end)
