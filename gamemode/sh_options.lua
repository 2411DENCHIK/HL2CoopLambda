
-- ConVars
--------------------
if SERVER then

	CreateConVar( "sv_coop_doorsonlyopen", "1", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD }, "Allow players to only open doors but not close them" )

else

	CreateClientConVar("coop_drawtriggers", 1, true, false)

end