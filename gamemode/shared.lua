DEFINE_BASECLASS( "gamemode_base" )

GM.Name 	= "HL2 Coop"
GM.Author 	= ""
GM.Email 	= ""
GM.Website 	= ""
GM.Debug 	= true

include("extends/entity.lua")
include("extends/ents.lua")
include("extends/player.lua")

include("debug/print.lua")
include("debug/showents.lua")

include('sh_options.lua')
include("changelevel.lua")
include("vehicles.lua")
include("sh_death.lua")
include("effects.lua")
include("weapon_system.lua")
include("player_class/player_coop.lua")
include('sh_gameround.lua')


function GM:PlayerNoClip(ply, inNoClip)
	if ply:IsAdmin() or ply:IsDeveloper() then
		return true
	end
end

function GM:ShouldCollide(ent1, ent2)
	if ent1.IsPlayer and ent1:IsPlayer() and ent2.IsPlayer and ent2:IsPlayer() then
		return false
	end
	return true
end

function GM:CanPlayerSuicide(ply)
	if ply:IsLockedPosition() or ply:IsFrozen() then
		return false
	end
	return true
end

function GM:Move(ply, data)

	if not ply:Alive() then
		data:SetVelocity(Vector(0,0,0))
		--return
	end

	if ply:IsLockedPosition() then
		local vel = ply:GetVelocity()
		vel.x = 0
		vel.y = 0
		data:SetVelocity(vel)
	end

	return BaseClass:Move(ply, data)

end

function GM:VehicleMove(ply, vehicle, data)
	if ply:IsLockedPosition() then
		local vel = vehicle:GetVelocity()
		vel.x = 0
		vel.y = 0
		data:SetVelocity(vel)
	end
end

function GM:EntityKeyValue(ent, key, val)

	ent.KeyValues = ent.KeyValues or {}
	ent.KeyValues[key] = val

	--DbgPrint("Entity KeyValue (" .. tostring(id) .. ", " .. ent:GetClass() .. "): " .. tostring(key) .. " - " .. tostring(val))

	if key == "EnableGun" then

		if self.MasterVehicles[ent:GetClass()] then
			self.MasterVehicles[ent:GetClass()].EnableGun = key
		end

		for k,v in pairs(self.Vehicles) do
			if IsValid(v) and v:GetClass() == ent:GetClass() then
				v:SetKeyValue(key, val)
			end
		end
					
	end

end

function GM:OnEntityCreated(ent)

	if SERVER then
		if ent:IsVehicle() == true then
			-- We do this next frame
			timer.Simple(0, function()
				self:CheckVehicleMaster(ent)
			end)
		end
	end

	if ent.OnInit then
		ent:OnInit()
	end

	local class = ent:GetClass()
	local name = "CLIENT"
	local id = ent:EntIndex()
	if ent.GetName then
		name = ent:GetName()
	end
	--DbgPrint("Created Entity (" .. tostring(id) .. "): " .. class .. ", Name: " .. name)

end
