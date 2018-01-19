local ent = FindMetaTable("Entity")

function ent:GetKeyValue(key)
	
	if self.KeyValues then
		local v = self.KeyValues[key]
		if v == nil then
			return self:GetKeyValues()[key]
		end
		return v
	end
	return self:GetKeyValues()[key]
	
end

function ent:GetRealKeyValues()

	return self.KeyValues or {}
	
end

function ent:GetGender()

	local mdl = self:GetModel()
	
	if string.find(mdl, "female") or string.find(mdl, "alyx") or string.find(mdl, "mossman") then
		return "female"
	elseif string.find(mdl, "male") or string.find(mdl, "breen") or string.find(mdl, "gman") or string.find(mdl, "kleiner") then
		return "male"		
	end
	
	return "male" -- Lets stick with male for now.
	
end