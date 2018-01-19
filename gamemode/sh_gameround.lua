if SERVER then

	AddCSLuaFile()

	util.AddNetworkString("COOPRestartRound")

	function GM:CheckRoundStatus()

		local players = player.GetAll()
		if #players == 0 then
			return true
		end

		local alive = 0

		for k, v in pairs(players) do

			if IsValid(v) and v:Alive() == true and not IsValid(v.Zombie) then
				alive = alive + 1
			end

		end

		if alive == 0 then
			DbgPrint("Restarting Round")
			self:RestartRound()
		end

	end

	function GM:RestartRound(delay)

		if self.RestartingRound == true then
			return
		end

		self.RestartingRound = true
		delay = delay or 11

		local startTime = RealTime()
		local restartTime = startTime + delay

		net.Start("COOPRestartRound")
			net.WriteFloat(startTime)
			net.WriteFloat(delay)
		net.Broadcast()

		game.SetTimeScale(0.2)

		for k,v in pairs(player.GetAll()) do
			v:LockPosition(true)
		end

		local self = self

		hook.Add("Think", "HL2COOP_RoundRestart", function()

			if RealTime() >= restartTime then

				DbgPrint("-- Restarting Round --")
				game.CleanUpMap(false, {"npc_zombie", "npc_fastzombie", "npc_headcrab"})
				game.SetTimeScale(1)

				for k,v in pairs(player.GetAll()) do
					v:LockPosition(false)
				end

				-- HACKHACK: We have to do this to not destroy the logic in d1_town_02
				--[[
				local prevmap = self.PrevMap
				file.Write("hl2coop/curmap.txt", prevmap)

				local curmap = game.GetMap()
				game.ConsoleCommand("changelevel " .. curmap .. "\n")
				]]
				hook.Remove("Think", "HL2COOP_RoundRestart")
				return

			end

		end)

	end

else

	function GM:SetRoundRestarting(start, counter)

		start = start or RealTime()
		counter = counter or 11

		self.RoundRestarting = true
		self.RoundRestartTime = start
		self.RoundRestartCounter = counter
		self.RoundRestartTicks = 0

		local ply = LocalPlayer()
		if IsValid(ply) then
			EmitSound(Sound("music/stingers/industrial_suspense2.wav"), ply:GetPos(), ply:EntIndex(), CHAN_AUTO, 1, 100, 0, 100)
		end

	end

	local FlickerMaterial = Material("effects/flicker_256.vtf")
	local NoiseMaterial = Material("effects/filmscan256.vtf")
	local RenderTargetCopy = GetRenderTarget("HL2CoopRoundOver", ScrW() * 1.3, ScrH() * 1.3)
	local MatScreen = Material("models/weapons/v_toolgun/screen")

	function GM:DrawRoundRestart()

		local remain = self.RoundRestartCounter - (RealTime() - self.RoundRestartTime)
		remain = math.Clamp(remain, 0, self.RoundRestartTime)

		local progress = remain / self.RoundRestartCounter
		local invprogress = 1 - progress

		if remain <= 0 then
			self.RoundRestarting = false
			return
		end

		self.RoundRestartTicks = self.RoundRestartTicks + (0.5 * FrameTime())

		local grey = {}
		grey[ "$pp_colour_colour" ] = math.Clamp(0.8 - (invprogress * 0.8), 0, 0.8)
		grey[ "$pp_colour_contrast" ] = math.Clamp(1.1 - (invprogress * 1.1), 0, 1.1)

		self.LastPictureFlash = self.LastPictureFlash or RealTime()
		self.NextPictureFlash = self.NextPictureFlash or math.random(0.5, 1.0)

		DrawToyTown(math.Clamp(self.RoundRestartTicks, 0, 5), ScrH() )

		if CurTime() - self.LastPictureFlash > self.NextPictureFlash then

			self.PictureFlashStart = self.PictureFlashStart or RealTime()
			self.PictureFlashScale = self.PictureFlashScale or math.random(1.20, 2.81)
			self.PictureFlashPos = self.PictureFlashPos or VectorRand() * (math.sin(CurTime()) * math.cos(CurTime()) * 1.0)
			self.PictureFlashAlpha = self.PictureFlashAlpha or 0.15 - (0.13 * invprogress)
			self.PictureFlashTime = self.PictureFlashTime or math.random(0.4, 0.6)

			local scaleFactor = Vector(ScrH(), ScrW(), 0) * self.PictureFlashScale

			if RealTime() - self.PictureFlashStart < self.PictureFlashTime then

				local elapsed = RealTime() - self.PictureFlashStart
				local progress = elapsed / self.PictureFlashTime

				grey[ "$pp_colour_colour" ] = 0.5
				grey[ "$pp_colour_contrast" ] = 0.6
				grey[ "$pp_colour_contrast" ] = 0.6
				grey[ "$pp_colour_addr" ] = 0.1
				--DrawColorModify( grey )

				render.CopyRenderTargetToTexture(RenderTargetCopy)

				grey[ "$pp_colour_colour" ] = math.Clamp(2 - (invprogress * 1.8), 0, 0.8)
				grey[ "$pp_colour_contrast" ] = math.Clamp(1 - (invprogress * 0.8), 0, 1.1)
				DrawColorModify( grey )

				render.PushRenderTarget(RenderTargetCopy)

				DrawMotionBlur( 10.0, 10.0, 2.2 )

				render.PopRenderTarget()

				MatScreen:SetTexture("$basetexture", RenderTargetCopy)
				MatScreen:SetFloat("$alpha", self.PictureFlashAlpha - (self.PictureFlashAlpha * progress))

				local mat = Matrix()

				mat:SetTranslation(self.PictureFlashPos)
				mat:Scale(Vector(1,1,1) * self.PictureFlashScale)

				cam.PushModelMatrix(mat)

					local x = math.random(1, 5) --math.sin(CurTime() * 10) * 2
					local y = math.random(1, 5) --math.cos(CurTime() * 10) * 2

					surface.SetMaterial(MatScreen)
					surface.DrawTexturedRectUV(-200 + x, -200 + y, ScrW() + 100, ScrH() + 100, 0, 0, 1, 1)

				cam.PopModelMatrix()

			else

				self.NextPictureFlash = math.random(1, 2)
				self.LastPictureFlash = RealTime()
				self.PictureFlashStart = nil
				self.PictureFlashScale = nil
				self.PictureFlashAlpha = nil
				self.PictureFlashTime = nil

				DrawColorModify( grey )

			end

		else

			DrawColorModify( grey )

		end

		surface.SetDrawColor(invprogress * 10, 0, 0, 100)

		surface.SetMaterial(FlickerMaterial)
		surface.DrawTexturedRectUV(0, 0, ScrW(), ScrH(), 0, 0, 1, 1)

		surface.SetMaterial(NoiseMaterial)

		-- Basic Noise
		NoiseMaterial:SetFloat("$alpha", 0.05 - (0.05 * invprogress))
		local x = math.random(-100, 100)
		local y = math.random(-100, 100)
		surface.DrawTexturedRectUV(-100 + x, -100 + y, ScrW() + 200, ScrH() + 200, 0, 0, math.random(1, 3), math.random(1, 3))

		local noiseX = math.random(-2, 2)
		local noiseY = math.random(-2, 2)
		local text = "Mission failed, restarting round in " .. string.format("%.1f", remain) .. " seconds ..."
		draw.SimpleText(text, "COOP_FONT_HUD_1", ScrW() * 0.5 + noiseX, ScrH() * 0.5 + noiseY, Color(255, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(text, "COOP_FONT_HUD_1", ScrW() * 0.5 + noiseX, ScrH() * 0.5 + noiseY, Color(255, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(text, "COOP_FONT_HUD_2", ScrW() * 0.5 + noiseX, ScrH() * 0.5 + noiseY, Color(0, 0, 0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText(text, "COOP_FONT_HUD_3", ScrW() * 0.5, ScrH() * 0.5, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	end

	net.Receive("COOPRestartRound", function(length)

		local start = net.ReadFloat()
		local counter = net.ReadFloat()

		GAMEMODE:SetRoundRestarting(start, counter)

	end)

end
