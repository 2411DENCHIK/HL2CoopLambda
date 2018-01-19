local DelayedEntIds = {}
local DelayedEntNames = {}
local Cached = {}

function ents.WaitForEntity(id, func)

	local ent = Entity(id)
	if IsValid(ent) then
		func(ent)
	else
		DelayedEntIds[id] = func
	end
	
end

function ents.WaitForEntityByName(name, func)

	local ent = ents.FindFirstByName(name)
	if IsValid(ent) then
		func(ent)
	else
		DelayedEntNames[name] = func
	end
	
end

function ents.GetCachedClassByName(name)
	
	local cache = Cached[name]
	if cache ~= nil then
		return cache.Class
	end

	return nil
end

hook.Add("EntityKeyValue", "HL2CoopCreationEntities", function(ent, key, val)
	
	if key == "targetname" then
	
		if Cached[val] == nil then
		
			local data = {
				Class = ent:GetClass(),
			}
			
			Cached[val] = data
		
		end
				
		local fnName = DelayedEntNames[val]
		if fnName then
			print("Dispatching for entity waiter")
			DelayedEntNames[val] = nil
			fnName(ent)
		end
		
	end
	
	if ent.DidSpawn == nil then
		
		ent.DidSpawn = true
		
		local id = ent:EntIndex()
		local fnId = DelayedEntIds[id]
		
		if fnId then
			fnId(ent)
			DelayedEntIds[id] = nil
		end
		
	end
	
end)

hook.Add("OnEntityCreated", "HL2CoopDelayedEntIds", function(ent)

	if ent.DidSpawn == nil then
	
		local id = ent:EntIndex()
		local fnId = DelayedEntIds[id]
		
		if fnId then
			fnId(ent)
			DelayedEntIds[id] = nil
		end
		
	end
	
	ent.DidSpawn = true
		
end)

function ents.RemoveByName(name)
	for k, v in pairs(ents.FindByName(name)) do
		v:Remove()
	end
end

function ents.RemoveByClass(class)
	for k,v in pairs(ents.FindByClass(class)) do
		v:Remove()
	end
end

function ents.FindByTargetName(name)
	local tbl = {}
	for k,v in pairs(ents.GetAll()) do
		if v:GetKeyValue("targetname") == name then
			table.insert(tbl, v)
		end
	end
	return tbl
end

function ents.RemoveInBox(mins, maxs, class)

	for k,v in pairs(ents.FindInBox(mins, maxs)) do
		if class then
			if v:GetClass() == class then
				v:Remove()
			end
		else
			v:Remove()
		end
	end
	
end

function ents.RemoveByPos(pos, class)
	for k,v in pairs(ents.GetAll()) do
		if v:GetPos() == pos then
			if class then
				if v:GetClass() == class then
					v:Remove()
				end
			else
				v:Remove()
			end
		end
	end
end

function ents.FindByPos(pos, class)

	for k,v in pairs(ents.GetAll()) do
		if v:GetPos() == pos then
			if class then
				if v:GetClass() == class then
					return v
				end
			else
				return v
			end
		end
	end
	
end

function ents.FindFirstByName(name)
	return ents.FindByName(name)[1]
end

function ents.FindFirstByClass(name)
	return ents.FindByClass(name)[1]
end