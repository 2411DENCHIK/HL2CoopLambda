DEFINE_BASECLASS( "gamemode_base" )

include( 'shared.lua' )
include( 'cl_taunts.lua' )
include( 'cl_hudpickup.lua' )
include( 'cl_drawing.lua' )
include( 'teams.lua' )
include( 'playerindicators.lua' )

if file.Exists('gamemodes/'..GM.FolderName..'/gamemode/mapscripts/' .. game.GetMap() .. '.lua','MOD') then
	include("mapscripts/" .. game.GetMap() .. ".lua")
end

function GM:AddResourceCaptions()

	language.Add("HL2_Chapter1_Title", "POINT INSERTION")
	language.Add("HL2_Chapter2_Title", "\"A RED LETTER DAY\"")
	language.Add("HL2_Chapter3_Title", "ROUTE KANAL")
	language.Add("HL2_Chapter4_Title", "WATER HAZARD")
	language.Add("HL2_Chapter5_Title", "BLACK MESA EAST")
	language.Add("HL2_Chapter6_Title", "\"WE DON'T GO TO RAVENHOLM...\"")
	language.Add("HL2_Chapter7_Title", "HIGHWAY 17")
	language.Add("HL2_Chapter8_Title", "SANDTRAPS")
	language.Add("HL2_Chapter9_Title", "NOVA PROSPEKT")
	language.Add("HL2_Chapter9a_Title", "ENTANGLEMENT")
	language.Add("HL2_Chapter10_Title", "ANTICITIZEN ONE")
	language.Add("HL2_Chapter11_Title", "\"FOLLOW FREEMAN!\"")
	language.Add("HL2_Chapter12_Title", "OUR BENEFACTORS")
	language.Add("HL2_Chapter13_Title", "DARK ENERGY")
	language.Add("HL2_Chapter14_Title", "CREDITS")

	language.Add("hl2_AmmoFull", "FULL")

	language.Add("HL2_GameOver_Object", "ASSIGNMENT: TERMINATED\nSUBJECT: FREEMAN\nREASON: FAILURE TO PRESERVE MISSION-CRITICAL RESOURCES")
	language.Add("HL2_GameOver_Ally", "ASSIGNMENT: TERMINATED\nSUBJECT: FREEMAN\nREASON: FAILURE TO PRESERVE MISSION-CRITICAL PERSONNEL")
	language.Add("HL2_GameOver_Timer", "ASSIGNMENT: TERMINATED\nSUBJECT: FREEMAN\nREASON: FAILURE TO PREVENT TIME-CRITICAL SEQUENCE")
	language.Add("HL2_GameOver_Stuck", "ASSIGNMENT: TERMINATED\nSUBJECT: FREEMAN\nREASON: DEMONSTRATION OF EXCEEDINGLY POOR JUDGMENT")

	language.Add("HL2_357Handgun", ".357 MAGNUM")
	language.Add("HL2_Pulse_Rifle", "PULSE-RIFLE")
	language.Add("HL2_Bugbait", "BUGBAIT")
	language.Add("HL2_Crossbow", "CROSSBOW")
	language.Add("HL2_Crowbar", "CROWBAR")
	language.Add("HL2_Grenade", "GRENADE")
	language.Add("HL2_GravityGun", "GRAVITY GUN")
	language.Add("HL2_Pistol", "9MM PISTOL")
	language.Add("HL2_RPG", "RPG")
	language.Add("HL2_Shotgun", "SHOTGUN")
	language.Add("HL2_SMG1", "SMG")

	language.Add("HL2_Saved", "Saved...")

	language.Add("HL2_Credits_VoicesTitle", "Voices:")
	language.Add("HL2_Credits_Eli", "Robert Guillaume - Dr. Eli Vance")
	language.Add("HL2_Credits_Breen", "Robert Culp - Dr. Wallace Breen")
	language.Add("HL2_Credits_Vortigaunt", "Lou Gossett, Jr. - Vortigaunt")
	language.Add("HL2_Credits_Mossman", "Michelle Forbes - Dr. Judith Mossman")
	language.Add("HL2_Credits_Alyx", "Merle Dandridge - Alyx Vance")
	language.Add("HL2_Credits_Barney", "Mike Shapiro - Barney Calhoun")
	language.Add("HL2_Credits_Gman", "Mike Shapiro - Gman")
	language.Add("HL2_Credits_Kleiner", "Harry S. Robins - Dr. Isaac Kleiner")
	language.Add("HL2_Credits_Grigori", "Jim French - Father Grigori")
	language.Add("HL2_Credits_Misc1", "John Patrick Lowrie - Citizens\\Misc. characters")
	language.Add("HL2_Credits_Misc2", "Mary Kae Irvin - Citizens\\Misc. characters")
	language.Add("HL2_Credits_Overwatch", "Ellen McLain - Overwatch")

	language.Add("HL2_Credits_VoiceCastingTitle", "Voice Casting:")
	language.Add("HL2_Credits_VoiceCastingText", "Shana Landsburg\\Teri Fiddleman")

	language.Add("HL2_Credits_VoiceRecordingTitle", "Voice Recording:")
	language.Add("HL2_Credits_VoiceRecordingText1", "Pure Audio, Seattle, WA")
	language.Add("HL2_Credits_VoiceRecordingText2", "LA Studios, LA, CA")

	language.Add("HL2_Credits_VoiceSchedulingTitle", "Voice recording scheduling and logistics:")
	language.Add("HL2_Credits_VoiceSchedulingText", "Pat Cockburn, Pure Audio")

	language.Add("HL2_Credits_LegalTeam", "Crack Legal Team:")
	language.Add("HL2_Credits_FacesThanks", "Thanks to the following for the use of their faces:")
	language.Add("HL2_Credits_SpecialThanks", "Special thanks to everyone at:")

	language.Add("HL2_HIT_CANCOP_WITHCAN_NAME", "Defiant")
	language.Add("HL2_HIT_CANCOP_WITHCAN_DESC", "Hit the trashcan cop with the can.")
	language.Add("HL2_PUT_CANINTRASH_NAME", "Submissive")
	language.Add("HL2_PUT_CANINTRASH_DESC", "Put the can in the trash.")
	language.Add("HL2_ESCAPE_APARTMENTRAID_NAME", "Malcontent")
	language.Add("HL2_ESCAPE_APARTMENTRAID_DESC", "Escape the apartment block raid.")
	language.Add("HL2_BREAK_MINITELEPORTER_NAME", "What cat?")
	language.Add("HL2_BREAK_MINITELEPORTER_DESC", "Break the mini-teleporter in Kleiner's lab.")
	language.Add("HL2_GET_CROWBAR_NAME", "Trusty Hardware")
	language.Add("HL2_GET_CROWBAR_DESC", "Get the crowbar.")
	language.Add("HL2_KILL_BARNACLESWITHBARREL_NAME", "Barnacle Bowling")
	language.Add("HL2_KILL_BARNACLESWITHBARREL_DESC", "Kill five barnacles with one barrel.")
	language.Add("HL2_GET_AIRBOAT_NAME", "Anchor's Aweigh!")
	language.Add("HL2_GET_AIRBOAT_DESC", "Get the airboat.")
	language.Add("HL2_FLOAT_WITHAIRBOAT_NAME", "Catching Air")
	language.Add("HL2_FLOAT_WITHAIRBOAT_DESC", "Float five seconds in the air with the airboat.")
	language.Add("HL2_GET_AIRBOATGUN_NAME", "Heavy Weapons")
	language.Add("HL2_GET_AIRBOATGUN_DESC", "Get the airboat's mounted gun.")
	language.Add("HL2_FIND_VORTIGAUNTCAVE_NAME", "Vorticough")
	language.Add("HL2_FIND_VORTIGAUNTCAVE_DESC", "Discover the hidden singing vortigaunt cave in chapter Water Hazard.")
	language.Add("HL2_KILL_CHOPPER_NAME", "Revenge!")
	language.Add("HL2_KILL_CHOPPER_DESC", "Destroy the hunter-chopper in Half-Life 2.")
	language.Add("HL2_FIND_HEVFACEPLATE_NAME", "Blast from the Past")
	language.Add("HL2_FIND_HEVFACEPLATE_DESC", "Find the HEV Suit Charger faceplate in Eli's scrapyard.")
	language.Add("HL2_GET_GRAVITYGUN_NAME", "Zero-Point Energy")
	language.Add("HL2_GET_GRAVITYGUN_DESC", "Get the Gravity Gun in Black Mesa East.")
	language.Add("HL2_MAKEABASKET_NAME", "Two Points")
	language.Add("HL2_MAKEABASKET_DESC", "Use DOG's ball to make a basket in Eli's scrapyard.")
	language.Add("HL2_BEAT_RAVENHOLM_NOWEAPONS_NAME", "Zombie Chopper")
	language.Add("HL2_BEAT_RAVENHOLM_NOWEAPONS_DESC", "Play through Ravenholm using only the Gravity Gun.")
	language.Add("HL2_BEAT_CEMETERY_NAME", "Hallowed Ground")
	language.Add("HL2_BEAT_CEMETERY_DESC", "Escort Grigori safely through the church cemetery.")
	language.Add("HL2_KILL_ENEMIES_WITHCRANE_NAME", "OSHA Violation")
	language.Add("HL2_KILL_ENEMIES_WITHCRANE_DESC", "Kill 3 enemies using the crane.")
	language.Add("HL2_PIN_SOLDIER_TOBILLBOARD_NAME", "Targetted Advertising")
	language.Add("HL2_PIN_SOLDIER_TOBILLBOARD_DESC", "Pin a soldier to the billboard in chapter Highway 17.")
	language.Add("HL2_KILL_ODESSAGUNSHIP_NAME", "Where Cubbage Fears to Tread")
	language.Add("HL2_KILL_ODESSAGUNSHIP_DESC", "Defend Little Odessa from the gunship attack.")
	language.Add("HL2_KILL_THREEGUNSHIPS_NAME", "One Man Army")
	language.Add("HL2_KILL_THREEGUNSHIPS_DESC", "Destroy six gunships in Half-Life 2.")
	language.Add("HL2_BEAT_DONTTOUCHSAND_NAME", "Keep Off the Sand!")
	language.Add("HL2_BEAT_DONTTOUCHSAND_DESC", "Cross the antlion beach in chapter Sandtraps without touching the sand.")
	language.Add("HL2_KILL_BOTHPRISONGUNSHIPS_NAME", "Uninvited Guest")
	language.Add("HL2_KILL_BOTHPRISONGUNSHIPS_DESC", "Kill both gunships in the Nova Prospekt courtyard.")
	language.Add("HL2_KILL_ENEMIES_WITHANTLIONS_NAME", "Bug Hunt")
	language.Add("HL2_KILL_ENEMIES_WITHANTLIONS_DESC", "Use the antlions to kill 50 enemies.")
	language.Add("HL2_KILL_ENEMY_WITHTOILET_NAME", "Flushed")
	language.Add("HL2_KILL_ENEMY_WITHTOILET_DESC", "Kill an enemy with a toilet.")
	language.Add("HL2_BEAT_TURRETSTANDOFF2_NAME", "Warden Freeman")
	language.Add("HL2_BEAT_TURRETSTANDOFF2_DESC", "Survive the second turret standoff in Nova Prospekt.")
	language.Add("HL2_FOLLOWFREEMAN_NAME", "Follow Freeman")
	language.Add("HL2_FOLLOWFREEMAN_DESC", "Gain command of a squad of rebels in the uprising.")
	language.Add("HL2_BEAT_TOXICTUNNEL_NAME", "Radiation Levels Detected")
	language.Add("HL2_BEAT_TOXICTUNNEL_DESC", "Get through the toxic tunnel under City 17 in Half-Life 2.")
	language.Add("HL2_BEAT_PLAZASTANDOFF_NAME", "Plaza Defender")
	language.Add("HL2_BEAT_PLAZASTANDOFF_DESC", "Survive the generator plaza standoff in chapter Anticitizen One.")
	language.Add("HL2_KILL_ALLC1709SNIPERS_NAME", "Counter-Sniper")
	language.Add("HL2_KILL_ALLC1709SNIPERS_DESC", "Kill all of the snipers in City 17.")
	language.Add("HL2_BEAT_SUPRESSIONDEVICE_NAME", "Fight the Power")
	language.Add("HL2_BEAT_SUPRESSIONDEVICE_DESC", "Shut down the supression device by disabling its generators.")
	language.Add("HL2_BEAT_C1713STRIDERSTANDOFF_NAME", "Giant Killer")
	language.Add("HL2_BEAT_C1713STRIDERSTANDOFF_DESC", "Survive the rooftop strider battle in the ruins of City 17.")
	language.Add("HL2_DISINTEGRATE_SOLDIERSINFIELD_NAME", "Atomizer")
	language.Add("HL2_DISINTEGRATE_SOLDIERSINFIELD_DESC", "Disintegrate 15 soldiers by throwing them into a Combine ball field.")
	language.Add("HL2_BEAT_GAME_NAME", "Singularity Collapse")
	language.Add("HL2_BEAT_GAME_DESC", "Destroy the Citadel's reactor core.")
	language.Add("HL2_FIND_ALLLAMBDAS_NAME", "Lambda Locator")
	language.Add("HL2_FIND_ALLLAMBDAS_DESC", "Find all lambda caches in Half-Life 2.")

	language.Add("World", "Cruel World")
end

function GM:OnGamemodeLoaded()

	self:AddResourceCaptions()
	self:SetupTeams()
	
end

function GM:CreateMove(cmd)

	local ply = LocalPlayer()
	if IsValid(ply) and ply:IsLockedPosition() then		
		cmd:ClearMovement()
		cmd:ClearButtons()
	else
		return BaseClass:CreateMove(cmd)
	end
		
end

function GM:PostDrawViewModel( vm, ply, weapon )

	if ( weapon.UseHands || !weapon:IsScripted() ) then

		local hands = LocalPlayer():GetHands()
		if ( IsValid( hands ) ) then hands:DrawModel() end

	end

end

function GM:PostCleanupMap()

	self.RoundRestarting = nil
	
end

function GM:HUDShouldDraw(name)

	local ply = LocalPlayer()
	
	if name == "CHudDamageIndicator" then
		return ply:Alive()
	end
	
	return BaseClass.HUDShouldDraw(self, name)
	
end

function GM:HUDPaint()

	if self.RoundRestarting ~= nil and self.RoundRestarting == true then
		self:DrawRoundRestart()
	end

	return BaseClass.HUDPaint()
	
end