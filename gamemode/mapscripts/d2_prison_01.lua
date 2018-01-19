function GM:InitMapScript()
	if SERVER then
	
		-- Wall collapse at the end
		ents.RemoveByPos(Vector(1064,-1536,1664))
		
	end
end
