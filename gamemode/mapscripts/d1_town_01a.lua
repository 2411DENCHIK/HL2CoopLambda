function GM:InitMapScript()
	if SERVER then
	
		local portalwindow_03_portal = ents.FindByName("portalwindow_03_portal")[1]
		portalwindow_03_portal:Fire("Open")
		
	end
end
