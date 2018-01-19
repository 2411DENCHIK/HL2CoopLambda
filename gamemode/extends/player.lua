local player = FindMetaTable("Player")

if SERVER then

	function player:LockPosition(state)
		if not IsValid(self) then
			return
		end
		if state then
			DbgPrint("Locking player position")
		else
			DbgPrint("Unlocking player position")
		end
		self:SetNWBool("Locked", state)
		self:SetMoveType(MOVETYPE_WALK)
	end
	
	function player:Give2(class)
	
		if class == nil then 
			error("Specify a classname you moron") 
		end
		
		local ent=ents.Create(class)
		ent.RealGive=true
		ent.ForPlayer=self
		ent:SetPos(self:GetPos())
		ent:Spawn()
		
		return ent
		
	end
	
end

function player:IsLockedPosition()
	return self:GetNWBool("Locked", false)
end

function player:IsDeveloper()

	if self:SteamID() == "STEAM_0:0:18930125" or 
		self:SteamID() == "STEAM_0:0:35720085" or 
		self:SteamID() == "STEAM_0:1:16769374" or 
		self:SteamID() == "STEAM_0:1:30490065" or
		self:SteamID() == "STEAM_0:0:13073749" then
		return true
	end
	
	return false
	
end

function player:GetGender()

	local mdl = self:GetModel()
	
	if string.find(mdl, "female") or string.find(mdl, "alyx") or string.find(mdl, "mossman") then
		return "female"
	elseif string.find(mdl, "male") or string.find(mdl, "breen") or string.find(mdl, "gman") or string.find(mdl, "kleiner") then
		return "male"		
	end
	
	return "male" -- Lets stick with male for now.
	
end