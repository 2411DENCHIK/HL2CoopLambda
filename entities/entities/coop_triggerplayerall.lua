AddCSLuaFile()
DEFINE_BASECLASS( "base_anim" )

ENT.PrintName		= ""
ENT.Author			= ""
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.Spawnable		= false
ENT.AdminSpawnable	= false

ENT.Players 		= {}
ENT.IgnoreLeave		= false

if CLIENT then
	
	surface.CreateFont( "HL2COOP_1", 
		{
			font = "Arial",
			size = 43,
			weight = 600,
			blursize = 0,
			scanlines = 0,
			antialias = true,
			underline = false,
			italic = false,
			strikeout = false,
			symbol = false,
			rotary = false,
			shadow = false,
			additive = true,
			outline = false
		} 
	)

	surface.CreateFont( "HL2COOP_2", 
		{
			font = "Arial",
			size = 33,
			weight = 600,
			blursize = 0,
			scanlines = 0,
			antialias = true,
			underline = false,
			italic = false,
			strikeout = false,
			symbol = false,
			rotary = false,
			shadow = false,
			additive = true,
			outline = false
		} 
	)
	
	ENT.DebugMat = Material("models/wireframe")
else
	util.AddNetworkString("triggerplayerall_update")
end

function ENT:Initialize()
	
	DbgPrint("Initialize")
	
	if CLIENT then 
		--hook.Add("HUDPaint", self, self.DrawStats)
		hook.Add("PostDrawOpaqueRenderables", self, self.DrawStats)
		--hook.Add("PostDrawOpaqueRenderables", self, self.DrawDebugBox)
	end
	
	self:Reset()	
	self:SetEnabled(true)
	
end

function ENT:AcceptInput(input, activator, called, data)
	
	DbgPrint("Received Input: "..input)
	
	if input == "Enable" then
		self.Enabled = true
	elseif input == "Disable" then
		self.Enabled = false
	end
	
	return true
	
end

function ENT:OnRemove()
	
	if CLIENT then 
		hook.Remove("HUDPaint", self)
	end
end

-- Call this after creating the entity.
function ENT:Replace(trigger, timeout)
	
	self:SetName(trigger:GetName())
	
	local mins = trigger:OBBMins()
	local maxs = trigger:OBBMaxs()
	local pos = trigger:GetPos()
	local ang = trigger:GetAngles()
	
	trigger:Remove()	
		
	local w = (maxs.x - mins.x)
	local l = (maxs.y - mins.y)
	local h = (maxs.z - mins.z)

	mins = Vector(0 - (w / 2), 0 - (l / 2), 0 - (h / 2))
	maxs = Vector(w / 2, l / 2, h / 2)
	
	return self:Init(pos, ang, mins, maxs, timeout)
	
end

-- Call this after creating the entity.
function ENT:Init(pos, ang, mins, maxs, timeout)
	
	DbgPrint("Init")
	DbgPrint("Creating Trigger at " .. tostring(pos) .. "\n\tMins: "..tostring(mins) .. "\n\tMaxs: " .. tostring(maxs))
			
	self:Spawn()
	self:SetTimeout(timeout)
	self:SetPos(pos)
	self:DrawShadow(false)
	self:SetCollisionBounds(mins, maxs)
	self:SetSolid(SOLID_BBOX)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	self:SetMoveType(0)
	self:SetTrigger(true)
	
end

-- This should be called in case the timer has to be reset for some reason.
function ENT:Reset()
	
	if SERVER then
		self.Players = {}
		self:SetCounterStart(0)
		self:SetPlayerCount(0)
		self:SetRunning(true)
		self:OnReset()
	end
	
end

function ENT:SetupDataTables()
	
	DbgPrint("Setup Data Table")
	
	self:NetworkVar( "Float", 0, "CounterStart" )
	self:NetworkVar( "Int", 1, "PlayerCount" )
	self:NetworkVar( "Bool", 2, "Running" )
	self:NetworkVar( "Float", 3, "Timeout" )
	
end

function ENT:CheckPlayerCount()
	
	local playerCount = #self.Players
	self:SetPlayerCount(playerCount)
	
	if playerCount == 0 then
		DbgPrint("Player count 0, resetting. ")
		self:Reset()
	end
	
end

function ENT:testConditions()

	if self:CheckCondition() then
		self:OnCondition()
		self:SetRunning(false)
		self:UnlockPlayers()
		
		if GAMEMODE.PlayerTriggerLeave then
			for k, v in pairs(self.Players) do
				if IsValid(v) then
					GAMEMODE:PlayerTriggerLeave(v)
				end
			end	
		end
	end
	
end

function ENT:SetEnabled(enabled)
	self.Enabled = enabled
end

function ENT:SetDisplayGoal(display)
	self.DisplayGoal = display
end

function ENT:StartTouch( ent )
	--
	if self:GetRunning() == false then
		return
	end
	
	if IsValid(ent) and ent:IsPlayer() and not table.HasValue(self.Players, ent) then
		
		DbgPrint("Player entered trigger: " .. tostring(ent), "State: "..tostring(self.Enabled))
		
		local isRunning = true
		if #self.Players == 0 then
			isRunning = false
		end
		
		self:OnPlayerEnter(ent)
		
		if self.Enabled == true then
		
			table.insert(self.Players, ent)
			self:CheckPlayerCount()
			
			self:testConditions()
			
		end
		
		if #self.Players == 0 and self.Enabled == true then
			-- Initial start
			self:SetCounterStart(CurTime())
		end
								
	end
		
end

function ENT:Touch(ent)
	--
	self:StartTouch(ent)
end

function ENT:EndTouch( ent )
	--
	if self.IgnoreLeave then
		return
	end
	
	for k, v in pairs(self.Players) do
	
		local valid = IsValid(v)
		if v == ent or valid == false then
			
			DbgPrint("Player left trigger: " .. tostring(ent))
			
			self:OnPlayerLeave(ent)
			
			table.remove(self.Players, k)
			self:CheckPlayerCount()
			
			if valid then
				return
			end
			
		end
		
	end

end

function ENT:OnPlayerEnter(ply)
	
	DbgPrint("OnPlayerEnter state: "..tostring(self.Enabled))
	if self.Enabled == true then
	
		DbgPrint("New player in trigger: "..tostring(ply))
		ply:LockPosition(true)	
		
		if GAMEMODE.PlayerTriggerEnter then
			GAMEMODE:PlayerTriggerEnter(ply)
		end
		
	else
	
		if self.DisplayGoal then
			DbgPrint("Sending notification")
			ply:PrintMessage(HUD_PRINTCENTER, "Map goal not reached yet, come back when goal achieved.")
		end
		
	end
	
	if IsValid(ply) then
	
		net.Start("triggerplayerall_update")
			net.WriteEntity(self)
			net.WriteUInt(1, 16)
			net.WriteEntity(ply)
		net.Send(ply)
		
	end
	
end

function ENT:OnPlayerLeave(ply)
	
	if IsValid(ply) then
	
		ply:LockPosition(false)

		net.Start("triggerplayerall_update")
			net.WriteEntity(self)
			net.WriteUInt(2, 16)
			net.WriteEntity(ply)
		net.Send(ply)
	
	end
	
	if GAMEMODE.PlayerTriggerLeave then
		GAMEMODE:PlayerTriggerLeave(ply)
	end
	
end

function ENT:LockPlayers()
	
	for k,v in pairs(self.Players) do
		v:LockPosition(true)
	end
	
end

function ENT:UnlockPlayers()
	
	for k,v in pairs(self.Players) do
		v:LockPosition(false)
	end
	
end

function ENT:Think()
	--
	if self:GetRunning() == false then
		return
	end
	
	if SERVER then
			
		if( #player.GetAll() == 0 ) then
			return false
		end
	
		local counterStart = self:GetCounterStart()
		if counterStart > 0 then
		
			if (CurTime() - counterStart) > self:GetTimeout() then
				DbgPrint("Timeout!")
				self:OnTimeout()
				self:SetRunning(false)
				self:UnlockPlayers()
			end
			
			self:testConditions()
			
		else
			if self.Enabled == true and #self.Players > 0 then
				self:LockPlayers()
				self:SetCounterStart(CurTime())
			end
		end
		
	else -- CLIENT
		
		local ply = LocalPlayer()
		local eyePos = ply:EyePos()
		local eyeAngles = ply:EyeAngles()
		local self = self
		
		local tr = util.TraceLine( {
			start = eyePos,
			endpos = eyePos + eyeAngles:Forward() * 1000,
			filter = function(ent)
				if ent == self then
					return true
				end
			end
		} )
		self.playerTrace = tr
		--DbgPrint("Player Trace")
		
	end
	
	for k, v in pairs(self.Players) do
		if IsValid(v) == false or v:Alive() == false then
			table.remove(self.Players, k)
			self:CheckPlayerCount()
		end
	end	
	
end

function ENT:GetTimeRemaining()
	
	local counterStart = self:GetCounterStart()
	if counterStart == 0 then
		return 0
	end
	
	return math.Clamp(self:GetTimeout() - (CurTime() - counterStart), 0, self:GetTimeout())

end

function ENT:HasTimerStarted()

	return self:GetCounterStart() ~= 0
	
end

function ENT:CheckCondition()
	
	local playerCount = #player.GetAll()
	
	if self.Enabled == false then
		return false
	end
	
	if( playerCount == 0 ) then
		return false
	end
	
	-- For debug purpose I have + 0 so I can sometimes simulate more than 1 players.
	return self:GetPlayerCount() >= (playerCount + 0)
	
end

function ENT:OnCounterStart()
	return false -- Override this function.
end

function ENT:OnReset()
	return false -- Override this function.
end

function ENT:OnCondition()
	return false -- Override this function.
end

function ENT:OnTimeout()
	return false -- Override this function.
end

function ENT:HasPlayer(ply)
	return table.HasValue(self.Players or {}, ply)
end

function ENT:Draw()	
	self:DrawDebugBox()
	--self:DrawStats()
end

function ENT:DrawDebugBox()
		
	if GetConVarNumber("coop_drawtriggers") == 1 then
		
		if not IsValid(LocalPlayer()) then
			return false
		end
	
		local mins = self:OBBMins()
		local maxs = self:OBBMaxs()
		local pos = self:GetPos() 
		local ang = self:GetAngles()
				
		render.SuppressEngineLighting( true )
		render.SetColorModulation( 1, 1, 1 )
		render.SetMaterial(self.DebugMat)
		render.DrawBox(pos, ang, mins, maxs, Color(255, 255, 255, 155))
		render.SuppressEngineLighting( false )
		
	end
	
end

function ENT:TriggerOutputs()
	
	for _, out in pairs(self.Outputs) do
		local entname = out[1]
		local cmd = out[2]
		local delay = out[3] or 0
		local param = out[4] or ""
		
		local ent = ents.FindByName(entname)[1]
		if not IsValid(ent) then 
			continue 
		end
		ent:Fire(cmd, param, delay)
	end
	
end

function ENT:DrawStats()

	if not IsValid(LocalPlayer()) then
		return false
	end
		
	if --[[ self:GetCounterStart() > 0 and ]] self.playerTrace ~= nil then
		
		--DbgPrint("Drawing")
		local ply = LocalPlayer()
		local pos = self.playerTrace.HitPos
		local ang = ply:EyeAngles()
		local eyepos = ply:EyePos()
		
		pos = pos + (eyepos + ang:Forward() * 10)
		
		if( self:HasPlayer(ply) ) then			
			--pos = ply:EyePos() + (ang:Forward() * 100)
			pos.z = eyepos.z
		end
		
		local w,h = 0,0
		local text = ""		
		local spos = pos:ToScreen()
		
		cam.Start3D(pos, ang, 1)
			surface.SetFont("HL2COOP_2")
		
			text = "Waiting for players: " .. self:GetPlayerCount() .. " / " .. #player.GetAll()
			draw.DrawText( text, "HL2COOP_2", spos.x, spos.y, Color( 255,255,255,255 ), TEXT_ALIGN_CENTER )
			w,h = surface.GetTextSize( text )
			spos.y = spos.y + h + 10
		
			text = "Progressing in " .. string.format("%.2f", math.Round(self:GetTimeRemaining(), 2)) .. " seconds"
			draw.DrawText( text, "HL2COOP_2", spos.x, spos.y, Color( 255,255,255,255 ), TEXT_ALIGN_CENTER )
		cam.End3D()
		
	else
		DbgPrint("PlayerTrace is nil")
	end
	
end

if CLIENT then
	net.Receive("triggerplayerall_update", function(len)
		local ent = net.ReadEntity()
		local cmd = net.ReadUInt(16)
		local ply = net.ReadEntity()
		
		ent.Players = ent.Players or {}
		if cmd == 1 then
			-- Add Player
			DbgPrint("New client in list")
			table.insert(ent.Players, ply)
		elseif cmd == 2 then
			-- Remove player
			DbgPrint("Removed client in list")
			table.RemoveByValue(ent.Players, ply)
		end
	end)
end