local SCR_W = ScrW()
local SCR_H = ScrH()

local avatar_panels = {}

local function get_avatar(ply)
	if ply ~= LocalPlayer() then
		local sid64 = ply:SteamID64()
		if sid64 and not avatar_panels[sid64] then
			local panel = vgui.Create('AvatarImage')
			avatar_panels[sid64] = panel
			panel:SetPaintedManually(true)
			panel:SetSize(32, 32)
			panel:SetSteamID(sid64, 32)
			return panel
		elseif sid64 then
			return avatar_panels[sid64]
		end
	end
end

local last_seen = {}

local function CanSee(ent)
	do
		local screenpos = ent:GetPos():ToScreen()
		if screenpos.x < 0 or screenpos.x > SCR_W
			or screenpos.y < 0 or screenpos.y > SCR_H then
				return false
		end
	end
	
	local ply = LocalPlayer()
	local pos = ply:GetShootPos()
	local pos2 = ent:GetShootPos()
	 
	local tracedata = {}
	tracedata.filter = ply
	tracedata.start = pos
	tracedata.endpos = pos2
	
	local trace = util.TraceHull(tracedata)
	
	if trace.Entity == ent then
		last_seen[ent] = RealTime()
		return true
	end
end

local function LastSeen(ent)
	return math.max(RealTime() - (last_seen[ent] or RealTime()), 0)
end

local MID = Vector(SCR_W/2, SCR_H/2)
local DOMDIM = math.max(SCR_W, SCR_H)
local SUBDIM = math.min(SCR_W, SCR_H)
local RADIUS = DOMDIM/2


hook.Add("HUDPaint", "PlayerAvatarIndicators", function()
	for _, player in next, player.GetAll() do
		avatar = get_avatar(player)
		if IsValid(player) and avatar and not CanSee(player) then
			local pos = player:EyePos():ToScreen()
			avatar:SetPaintedManually(false)
			
			local m = (pos.y - MID.y) / (pos.x - MID.X)
			local invert = pos.x > MID.x and 1 or -1
			local dist = math.sqrt(math.pow(pos.x-MID.x, 2) + math.pow(pos.y-MID.y, 2))
			local vec = Vector(invert, invert*m)
			vec:Normalize()
			vec = vec*(dist < RADIUS and dist or RADIUS)
			vec = MID+vec
			
			vec.x = math.Clamp(vec.x-16, 0, SCR_W - 32)
			vec.y = math.Clamp(vec.y-16, 0, SCR_H - 32)
			
			avatar:SetPos(vec.x, vec.y)
			avatar:PaintManual()
			avatar:SetPaintedManually(true)
		end
	end
end)