AddCSLuaFile()
DEFINE_BASECLASS( "coop_triggerplayerall" )

ENT.PrintName		= ""
ENT.Author			= ""
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.Spawnable		= false
ENT.AdminSpawnable	= false

function ENT:Initialize()
	
	return BaseClass.Initialize(self)
	
end

-- Call this after creating the entity.
function ENT:Replace(trigger, timeout)
	
	self.Map = trigger:GetKeyValue("map")
	self:SetName(trigger:GetName())
	
	local mins = trigger:OBBMins()
	local maxs = trigger:OBBMaxs()
	local pos = trigger:OBBCenter()
	local ang = trigger:GetAngles()
	
	-- Hacks for certain levels that use changelevel a little different.
	if game.GetMap() == "d1_canals_13" then
		pos = Vector(-1024, -6656, -1262.91)
		ang = Angle(0,0,0)
		mins = Vector(-1025, -2561, -274)
		maxs = Vector(1025, 2561, 239.90)
	end
			
	local w = (maxs.x - mins.x)
	local l = (maxs.y - mins.y)
	local h = (maxs.z - mins.z)

	mins = Vector(0 - (w / 2), 0 - (l / 2), 0 - (h / 2))
	maxs = Vector(w / 2, l / 2, h / 2)

	DbgPrint("Replacing Trigger at " .. tostring(pos) .. "\n\tMins: "..tostring(mins) .. "\n\tMaxs: " .. tostring(maxs).."\n\tSize: "..tostring(wh))
	trigger:Remove()
	
	-- Ignore player leaving.
	self.IgnoreLeave = true
	
	return BaseClass.Init(self, pos, ang, mins, maxs, timeout)
	
end

function ENT:AcceptInput(name, activator, caller, data)
	
	DbgPrint("Received Input ("..tostring(self).."): "..name)
	
	if name == "ChangeLevel" then
		--self:SetEnabled(true)
		self:OnCondition()
	end
	
	return true
	
end

function ENT:OnCounterStart()
	
	return false -- Override this function.
end

function ENT:OnReset()
	
	return false -- Override this function.
end

function ENT:OnPlayerEnter(ply)
	
	if ply:InVehicle() then
	
		local vehicle = ply:GetVehicle()
		vehicle:Remove()
		
	end
	
	BaseClass.OnPlayerEnter(self, ply)
	
end

function ENT:OnCondition()
	
	local nextmap = self.Map
	
	GAMEMODE:PreChangelevel(nextmap)
	
	game.ConsoleCommand("changelevel " .. nextmap .. "\n")
	
end

function ENT:OnTimeout()
	
	DbgPrint("On Timeout"..self.Map)
	
	GAMEMODE:PreChangelevel(nextmap)
	
	game.ConsoleCommand("changelevel " .. self.Map .. "\n")
	
end

function ENT:DrawStats()
	
	if not IsValid(LocalPlayer()) then
		return false
	end
	
	if self:GetCounterStart() > 0 and self:GetRunning() == true then
	
		local ply = LocalPlayer()
	
		if not self:HasPlayer(ply) then
			if self.playerTrace and self.playerTrace.Entity ~= self then
				return false
			end
		end
		
		local pos = self.playerTrace.HitPos
		local ang = self:GetAngles()
		local eyePos = ply:EyePos()
		local eyeAngles = ply:EyeAngles()
		
		local distance = eyePos:Distance(pos)
		if(distance < 90) then
			local deltaDistance = math.Clamp(90 - distance, 0, 90)
			pos = pos + (eyeAngles:Forward() *deltaDistance)
		end
		
		if self:HasPlayer(ply) then
			pos = eyePos + (eyeAngles:Forward() * 90)
		end
		
		local diff = eyePos - pos
		ang = diff:Angle()
		
		ang:RotateAroundAxis(ang:Up(), 90)
		ang:RotateAroundAxis(ang:Forward(), 90)
				
		local w,h = 0,0
		local text = ""		
		local spos = pos:ToScreen()
		
		cam.Start3D2D(pos, ang, 0.1)
			surface.SetFont("HL2COOP_2")
			
			text = "Waiting for players: " .. self:GetPlayerCount() .. " / " .. #player.GetAll()
			draw.DrawText( text, "HL2COOP_2", 0, 0, Color( 255,255,255,255 ), TEXT_ALIGN_CENTER )
			w,h = surface.GetTextSize( text )
			spos.y = spos.y + h + 10
			
			text = "Changing level in " .. string.format("%.2f", math.Round(self:GetTimeRemaining(), 2)) .. " seconds"
			draw.DrawText( text, "HL2COOP_2", 0, 50, Color( 255,255,255,255 ), TEXT_ALIGN_CENTER )
		cam.End3D2D()
		
	end
	
end