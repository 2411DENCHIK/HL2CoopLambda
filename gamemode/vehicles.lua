GM.Vehicles = {}
GM.MasterVehicles = {}

local CrushSounds = {
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

local function AddPassengerSeat(ent)

	if not IsValid(ent) then
		return
	end

	if ent:GetClass() ~= "prop_vehicle_jeep" then
		return
	end

	local pos = ent:GetPos()
	local ang = ent:GetAngles()

	local seat = ents.Create("prop_vehicle_prisoner_pod")
	local seatpos = ent:LocalToWorld(Vector(20.307026, -36.037380, 18.548361))

	seat:SetPos(seatpos)
	seat:SetAngles(ang)
	seat:SetModel("models/nova/jeep_seat.mdl")
	seat:SetParent(ent)
	seat:Spawn()
	seat.IsPassengerSeat = true
	seat.IsCustom = true
	seat.HandleAnimation = function( v, p )
		return p:SelectWeightedSequence( ACT_DRIVE_AIRBOAT )
	end

	ent.PassengerSeat = seat

end

-- Fixes passenger leaving at the top of the vehicle.
hook.Add("PlayerLeaveVehicle", "PassengerExitFix", function(ply, vehicle)

	if vehicle.IsPassengerSeat then

		local ang = vehicle:GetAngles()
		local pos = vehicle:GetPos()
		local exitpos = pos + (ang:Forward() * 50)

		-- Look towards the seat.
		local exitang = (pos - exitpos):Angle()

		ply:SetPos(exitpos)
		ply:SetEyeAngles(exitang)
		ply:SetAllowWeaponsInVehicle(false)

		vehicle:GetParent().Passenger = nil

	end

end)

hook.Add("PlayerEnteredVehicle", "PassengerEnterFix", function(ply, vehicle)

	if vehicle.IsPassengerSeat then

		vehicle:GetParent().Passenger = ply
		timer.Simple(0.3, function()
			ply:DrawViewModel(true)
		end)

	end

end)

hook.Add("CanPlayerEnterVehicle", "PassengerEnterFix", function(ply, vehicle)

	if vehicle.IsPassengerSeat then
		ply:SetAllowWeaponsInVehicle(true)
		ply:DrawViewModel(true)
		return true
	end

end)

-- Fixes using the ammo box on the back of the car, +use didn't do shit.
hook.Add("PlayerUse", "JeepAmmoFix", function(ply, ent)

	if ent:GetClass() == "prop_vehicle_jeep" and ply:GetEyeTrace().HitGroup == 5 then

		local ammo_open = ent:LookupSequence("ammo_open")
		local ammo_close = ent:LookupSequence("ammo_close")
		local seq = ent:GetSequence()

		if seq ~= ammo_open and seq ~= ammo_close then

			ply:GiveAmmo(300, "SMG1")

			ent:SetCycle(0)
			ent:ResetSequence(ammo_open)

			return true

		end

	end

end)

-- Fixes not showing up any weapon on the car.
hook.Add("OnEntityCreated", "JeepGunFix", function(ent)
	if ent:GetClass() == "prop_vehicle_jeep" then
		ent:SetKeyValue("EnableGun", "1")
	end
end)

-- Fixes the gravity gun punt being super strong.
hook.Add("GravGunPunt", "VehicleThrowFix", function(ply, ent)

	if ent:IsVehicle() then
		-- Take away the force next frame, only way to fix it atm.
		timer.Simple(0, function()

			local phys = ent:GetPhysicsObject()
			if IsValid(phys) then
				phys:SetVelocity( phys:GetVelocity() * 0.1 )
			end

		end)
	end

end)

function GM:CheckVehicles()

	if CLIENT then
		DbgPrint("This is not how its supposed to be called")
		return
	end

	local airboatdata = nil
	local jeepdata = nil
	local airboats = {}
	local jeeps = {}

	for k,v in pairs(self.Vehicles) do
		if not IsValid(v) then
			--table.remove(self.Vehicles, k)
			self.Vehicles[k] = nil
			return
		end
	end

	for k,v in pairs(self.MasterVehicles) do

		if k == "prop_vehicle_airboat" then
			airboatdata = v
		elseif k == "prop_vehicle_jeep" then
			jeepdata = v
		end

		local range = Vector(200, 200, 200)
		local startpos = v.Pos - range
		local endpos = v.Pos + range

		for _, ent in pairs( ents.FindInBox(startpos, endpos) ) do

			if ent:GetClass() == "prop_vehicle_airboat" then
				table.insert(airboats, ent)
			elseif ent:GetClass() == "prop_vehicle_jeep" then
				table.insert(jeeps, ent)
			end

		end

	end

	-- Do we require a new airboat?
	-- print( #self.Vehicles)
	if airboatdata and #self.Vehicles < (#player.GetAll() + 1) and #airboats == 0 then

		DbgPrint("Creating new airboat")

		local ent = ents.Create("prop_vehicle_airboat")
		local gun = "0"
		if self:AirboatShouldHaveGun() then
			gun = "1"
		end

		ent:SetPos(airboatdata.Pos + Vector(0, 0, 20))
		ent:SetAngles(airboatdata.Ang)
		ent:SetModel(airboatdata.Mdl)
		ent:SetKeyValue("vehiclescript", "scripts/vehicles/airboat.txt")
		ent:SetKeyValue("EnableGun",  gun)
		ent:SetName(airboatdata.Name)
		ent:Spawn()
		ent:Activate()
		ent.AssignedPlayer = false
		ent.IsCustom = true

		table.insert(self.Vehicles, ent)
		PrintTable(self.Vehicles)

	end

	-- Do we require a new jeep?
	if jeepdata and #self.Vehicles < (#player.GetAll() + 1) and #jeeps == 0 then

		DbgPrint("Creating new jeep")

		local ent = ents.Create("prop_vehicle_jeep")
		local gun = "0"
		if self:JeepShouldHaveGun() then
			gun = "1"
		end

		ent:SetPos(jeepdata.Pos + Vector(0,0,20))
		ent:SetAngles(jeepdata.Ang)
		ent:SetModel(jeepdata.Mdl)
		ent:SetKeyValue("vehiclescript", "scripts/vehicles/jeep.txt")
		ent:SetKeyValue("EnableGun", gun)
		ent:SetName(jeepdata.Name)
		ent:Spawn()
		ent:Activate()
		ent.AssignedPlayer = false
		ent.IsCustom = true

		-- We like to have a passenger seat.
		AddPassengerSeat(ent)

		hook.Call("VehicleSpawned", self, ent)

		table.insert(self.Vehicles, ent)
		PrintTable(self.Vehicles)

	end

end

function GM:AirboatShouldHaveGun()

	local map = game.GetMap()

	local master = self.MasterVehicles["prop_vehicle_airboat"]
	if master then
		if master.EnableGun and master.EnableGun == "1" then
			return true
		end
	end

	if map == "d1_canals_12" or map == "d1_canals_13" then
		return true
	end

	return false

end

function GM:JeepShouldHaveGun()
	return true -- I believe the jeep is never without
end

function GM:CheckVehicleMaster(ent)

	if SERVER then

		if IsValid(ent) then

			local class = ent:GetClass()

			if class ~= "prop_vehicle_airboat" and class ~= "prop_vehicle_jeep" then
				return
			end

			if self.MasterVehicles[class] ~= nil then
				return
			end

			DbgPrint("Master Vehicle found")

			if class == "prop_vehicle_jeep" then

				if ent:GetName() ~= "jeep" then
					DbgPrint("Master Vehicle name mismatch!")
					return
				end

				-- Not enabled by default, GARRY!
				ent:SetKeyValue("EnableGun", "1")

				-- We like to have a passenger seat.
				AddPassengerSeat(ent)
			end

			-- Master vehicle table.
			self.MasterVehicles[class] = {
				Name = ent:GetName(),
				Pos = ent:GetPos(),
				Ang = ent:GetAngles(),
				Mdl = ent:GetModel(),
				EnableGun = ent:GetKeyValue("EnableGun")
			}

			ent.IsMaster = true

			-- Call the hook next frame, so we can update the position and whatever not.
			timer.Simple(0, function()
				hook.Call("MasterVehicleSpawn", self, ent)

				if game.GetMap() ~= "d2_coast_01" then
					ent:Remove()
				end

			end)

		end

	end

end

function GM:RemovePlayerVehicle(ply)

	for k,v in pairs(ents.FindByClass("prop_vehicle_jeep")) do
		if v.AssignedPlayer == ply then
			print("Removing Vehicle")

			hook.Call("VehicleRemoved", self, v)

			if v.PassengerSeat then
				local passenger = v.PassengerSeat:GetDriver()
				if IsValid(passenger) then
					passenger:ExitVehicle()
				end
			end

			v:Remove()

			self.Vehicles[k] = nil

		end
	end

	for k,v in pairs(ents.FindByClass("prop_vehicle_airboat")) do
		if v.AssignedPlayer == ply then
			print("Removing Vehicle")

			hook.Call("VehicleRemoved", self, v)
			v:Remove()

			self.Vehicles[k] = nil
		end
	end

end

function GM:PlayerEnteredVehicle(ply, vehicle, role)

	if vehicle:GetClass() == "prop_vehicle_jeep" or vehicle:GetClass() == "prop_vehicle_airboat" then
		if not vehicle.AssignedPlayer then
			vehicle.AssignedPlayer = ply
		else
			return false
		end
	end

end

function GM:CanPlayerEnterVehicle(ply, vehicle, role)

	if vehicle.IsCustom == nil then
		return true
	end

	if not vehicle.AssignedPlayer or vehicle.AssignedPlayer == ply then
		return true
	end

	return false

end

local function LaunchVehiclePlayers(ply, force, jeep)

	if not IsValid(ply) or not ply:IsPlayer() and not ply.IsRagdoll == true then
		return false
	end

	if ply.ExitVehicle == nil then
		return false
	end

	local actualForce = force * 10 -- + (force:Angle():Up() * 10)
	print("Launching with force of: "..tostring(actualForce))

	local curPos = ply:GetPos()
	ply.VehicleDeath = true
	ply.RagdollForce = actualForce
	ply:Kill()

	--jeep:SetCollisionGroup(COLLISION_GROUP_NONE)

	-- Kill passenger too
	if jeep.PassengerSeat ~= nil then

		local passenger = jeep.PassengerSeat:GetDriver()
		if IsValid(passenger) then
			passenger.VehicleDeath = true
			passenger.RagdollForce = actualForce
			passenger:Kill()
		end

	end

end

hook.Add("EntityTakeDamage", "VehicleDamage", function(ent, dmginfo)

	local force = dmginfo:GetDamageForce()
	local damage = dmginfo:GetDamage()
	local attacker = dmginfo:GetInflictor()

	DbgPrint("Damage", damage)
	DbgPrint("Attacker", attacker)
	DbgPrint("Victim", ent)

	if( ent:IsPlayer() and damage >= 25 ) then

		local vehicle = ent:GetVehicle()

		if IsValid(attacker) and attacker:GetClass() == "prop_vehicle_jeep" and vehicle == attacker then
			--print("Launching players, vehicle: ", attacker)
			LaunchVehiclePlayers(ent, dmginfo:GetDamageForce(), attacker)
		end

	end

end)

hook.Add("EntityRemoved", "CrashDummyRemove", function(ent)
	if IsValid(ent) and ent:IsPlayer() and IsValid(ent.DummyRagdoll) then
		ent.DummyRagdoll:Remove()
	end
end)
