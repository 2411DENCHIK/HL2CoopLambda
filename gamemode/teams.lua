COOP_TEAM_BASE = 100
COOP_TEAM_DEAD = COOP_TEAM_BASE + 1
COOP_TEAM_ALIVE = COOP_TEAM_BASE + 2
COOP_TEAM_TRIGGER = COOP_TEAM_BASE + 3

GM.Teams = {
	{COOP_TEAM_DEAD, "Dead", Color(255,0,0)},
	{COOP_TEAM_ALIVE, "Alive", Color(0,0,255)},
	{COOP_TEAM_TRIGGER, "Trigger", Color(128,128,0)},
}

if CLIENT then

	function GM:SetupTeams()

		for k,v in pairs(self.Teams) do
			team.SetUp(v[1], v[2], v[3], false)
		end
		
	end

end