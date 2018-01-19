function GM:InitMapScript()
	if SERVER then
		ents.RemoveByPos(Vector(367, 70, -846.01397705078), "prop_physics") -- wooden plate shortcut
	end
end
