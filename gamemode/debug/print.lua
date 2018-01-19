function DbgPrint(...)
	if SERVER then
		--print("[SERVER]", unpack({...}))
	else
		--print("[CLIENT]", unpack({...}))
	end
end

if not GM.Debug then
	DbgPrint = function(...) end
end
