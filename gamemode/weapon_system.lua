if CLIENT then

	net.Receive( "SetObjectVisibility", function( length, client )

		local state = net.ReadBit()
		local objs = net.ReadTable()

		if state == 1 then
			-- Show Object
			print("Showing objects")
			for k,v in pairs(objs) do
				ents.WaitForEntity(v, function(ent)
					ent:SetNoDraw(false)
				end)
			end
		else
			-- Hide Object
			print("Hiding objects")
			for k,v in pairs(objs) do
				ents.WaitForEntity(v, function(ent)
					ent:SetNoDraw(true)
				end)
			end
		end

	end )

else

	util.AddNetworkString("SetObjectVisibility")

	function GM:PlayerCanPickupWeapon(ply, wep)

		self.ItemTable = self.ItemTable or {}
		wep.PlayerTable = wep.PlayerTable or {}

		-- This has to be the first check.
		if wep.ForPlayer then
			if wep.ForPlayer == ply then
				--DbgPrint("Weapon was made for player")
				return true
			else
				return false
			end
		end

		-- Lets see if the weapon is nearby our spawnpoint.
		local spawnpoint = self:PlayerSelectSpawn(ply)
		local range = Vector(5, 5, 15)
		local pos = spawnpoint:GetPos()

		local weps = ents.FindInBox(pos - range, pos + range)
		for k,v in pairs(weps) do
			if v == wep then
				--DbgPrint("Entity was in spawnpoint")
				return true
			end
		end

		if table.HasValue(wep.PlayerTable, ply) then
			--DbgPrint("Player has already received this weapon")
			return false
		end

		local weps = ply:GetWeapons()
		local switch = true
		for k,v in pairs(weps) do
			if v:GetClass() == wep:GetClass() then
				switch = false
				break
			end
		end

		table.insert(wep.PlayerTable, ply)
		local playertable = wep.PlayerTable

		-- Lets make a copy now.
		local copy = ents.Create(wep:GetClass())
		copy:SetPos(wep:GetPos())
		copy:SetAngles(wep:GetAngles())
		copy.PlayerTable = playertable

		timer.Simple(0, function()
			copy:Spawn()

			if switch then
				ply:SelectWeapon(copy:GetClass())
			end

			ply:EmitSound("Player.PickupWeapon")

			-- Add new object to item list.
			table.insert(self.ItemTable, copy)

			-- Hide object from player
			net.Start("SetObjectVisibility")
				net.WriteBit(false)
				net.WriteTable({copy:EntIndex()})
			net.Send(playertable)
		end)

		-- Remove old object from item list.
		for k,v in pairs(self.ItemTable) do
			if v == wep then
				self.ItemTable[k] = nil
			end
		end

		DbgPrint("Giving new weapon: "..tostring(wep))
		return true

	end

	function GM:PlayerCanPickupItem(ply, ent)

		self.ItemTable = self.ItemTable or {}
		ent.PlayerTable = ent.PlayerTable or {}

		if ent:GetClass() == "item_suit" then
			return true
		end

		if ent:GetClass() == "item_healthkit" then
			if ply:Health() >= 100 then
				-- Its not worth picking up.
				return false
			end
		end

		if table.HasValue(ent.PlayerTable, ply) then
			return false
		end

		-- Insert into table.
		table.insert(ent.PlayerTable, ply)
		local playertable = ent.PlayerTable

		-- Make copy.
		local copy = ents.Create(ent:GetClass())
		copy:SetPos(ent:GetPos())
		copy:SetAngles(ent:GetAngles())
		copy.PlayerTable = playertable

		-- Spawn next frame.
		timer.Simple(0, function()
			copy:Spawn()

			-- Add new object to item list.
			table.insert(self.ItemTable, copy)

			-- Hide object from player
			net.Start("SetObjectVisibility")
				net.WriteBit(false)
				net.WriteTable({copy:EntIndex()})
			net.Send(playertable)
		end)

		-- Remove old object from item list.
		for k,v in pairs(self.ItemTable) do
			if v == ent then
				self.ItemTable[k] = nil
			end
		end

		return true

	end

	function GM:RemovePlayerFromItemList(ply)

		self.ItemTable = self.ItemTable or {}
		PrintTable(self.ItemTable)

		local objs = {}
		for k1,v in pairs(self.ItemTable) do
			if IsValid(v) and v.PlayerTable then
				for k, v2 in pairs(v.PlayerTable) do
					if v2 == ply then
						v.PlayerTable[k] = nil
						table.insert(objs, v:EntIndex())
					end
				end
			else
				-- Remove the useless object.
				self.ItemTable[k1] = nil
			end
		end

		if #objs > 0 then
			-- Show object to player.
			net.Start("SetObjectVisibility")
				net.WriteBit(true)
				net.WriteTable(objs)
			net.Send(ply)
		end

	end

	function GM:AvoidItemPushing()

		for k,v in pairs(ents.FindByClass("item_*")) do
			if v:GetClass() ~= "item_item_crate" then
				local phys = v:GetPhysicsObject()
				if IsValid(phys) then
					--phys:EnableMotion(false)
				end
			end
		end

		for k,v in pairs(ents.FindByClass("weapon_*")) do
			local phys = v:GetPhysicsObject()
			if IsValid(phys) then
				--phys:EnableMotion(false)
			end
		end

	end

	function GM:GravGunPunt(ply, ent)
		if not IsValid(ent) then
			return false
		end
		local class = ent:GetClass()
		if class == "item_item_crate" then
			return true
		end
		if #class >= 4 and string.sub(class, 1, 4) == "item" then
			print("Disallowed")
			return false
		end
		return true
	end

	function GM:GravGunPickupAllowed(ply, ent)
		if not IsValid(ent) then
			return false
		end
		local class = ent:GetClass()
		if class == "item_item_crate" then
			return true
		end
		if #class >= 4 and string.sub(class, 1, 4) == "item" then
			print("Disallowed")
			return false
		end
		return true
	end

end
