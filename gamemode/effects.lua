if CLIENT then

	CreateConVar( "cl_coop_effects", "1", { FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD }, "Draw more rendering effects" )

	ColorModify = {}
	ColorModify[ "$pp_colour_addr" ] 		= 0
	ColorModify[ "$pp_colour_addg" ] 		= 0
	ColorModify[ "$pp_colour_addb" ] 		= 0
	ColorModify[ "$pp_colour_brightness" ] 	= 0
	ColorModify[ "$pp_colour_contrast" ] 	= 0.8
	ColorModify[ "$pp_colour_colour" ] 		= 0.8
	ColorModify[ "$pp_colour_mulr" ] 		= 0.0
	ColorModify[ "$pp_colour_mulg" ] 		= 0.0
	ColorModify[ "$pp_colour_mulb" ] 		= 0.0

	local matDOF = Material( "pp/dof" )
	local matDOF2 = Material( "pp/bokehblur" )

	local function DrawDOF()

		local ply = LocalPlayer()
		local pos = ply:GetPos()
		local ang = ply:EyeAngles()
		local fwd = ang:Forward()
		local SpriteSize = ScrH() * ScrW()

		cam.Start3D( EyePos(), EyeAngles() )
			--cam.IgnoreZ(true)
			render.SetMaterial( matDOF )

			local offset = 3096
			local spacing = 512

			for i = 0, 16 do

				local drawPos = pos + (fwd * offset) + (i * (fwd * spacing))

				--render.UpdateRefractTexture()
				render.DrawSprite( drawPos, SpriteSize, SpriteSize, Color(255, 255, 255, 255) )

			end
			cam.IgnoreZ(false)
		cam.End3D()

		render.UpdateScreenEffectTexture()

	end

	hook.Add("PostDrawEffects", "COOP_2DSkybox", function()
		--DrawDOF()
	end)

	local function DrawBokehDOF()

		render.UpdateScreenEffectTexture()

		matDOF2:SetTexture( "$BASETEXTURE", render.GetScreenEffectTexture() )
		matDOF2:SetTexture( "$DEPTHTEXTURE", render.GetResolvedFullFrameDepth() )
		--matDOF2:SetTexture( "$DEPTHTEXTURE", render.GetFullScreenDepthTexture() )
		--matDOF2:SetTexture( "$DEPTHTEXTURE", render.GetSmallTex0() )

		matDOF2:SetFloat( "$size", 0.2 )
		matDOF2:SetFloat( "$focus", 1.10 )
		matDOF2:SetFloat( "$focusradius", 10.0 )

		render.SetMaterial( matDOF2 )
		render.DrawScreenQuad()

	end

	local lastPlayerPos = Vector(0,0,0)

	local function DrawInternal()

		if GetConVarNumber("cl_coop_effects") == 0 then
			return
		end

		--DrawBloom( 0.1, 0.1, 1, 1, 1, 1, 1, 1, 1 )
		DrawColorModify( ColorModify )
		--DrawStuff()
		DrawBokehDOF()
		--DrawMotionBlur( 0.9 - alpha, 0.8, 0.01)

	end
	hook.Add( "RenderScreenspaceEffects", "RenderPostProcessing", DrawInternal )

	function GM:CalcView(ply, pos, ang, fov)

		if not ply:Alive() then

			if ply.Zombie and IsValid(ply.Zombie) then
				pos = ply.Zombie:EyePos() - (ang:Forward() * 100)
			else
				local ragdoll = ply:GetNWEntity("Ragdoll")
				if IsValid(ragdoll) then
					pos = ragdoll:GetPos() - (ang:Forward() * 100)
				end
			end

		else

			local vel = ply:GetVelocity()
			local viewang = ply:EyeAngles()

			ang.roll = ang.roll + viewang:Right():DotProduct(vel) * 0.008

		end

		return self.BaseClass:CalcView(ply, pos, ang, fov)

	end

	RunConsoleCommand("mat_motion_blur_forward_enabled", "1")
	RunConsoleCommand("cl_detaildist", "4000")

	hook.Add( "SetupWorldFog", "COOP_WorldFog", function()

		local distance = 200
		local r = 20

		render.FogMode(1)
		render.FogStart(distance)
		render.FogEnd(distance + 2000)
		render.FogColor( 0, 0, 0 )
		render.FogMaxDensity(0.5)

		--return true

	end)

	local SourceSkyname = GetConVar("sv_skyname"):GetString() --We need the source of the maps original skybox texture so we can manipulate it.
	print("Current Skybox: ", SourceSkyname)

	local SourceSkyPre  = {"lf","ft","rt","bk","dn","up",}
	local SourceSkyMat  = {
		Material("skybox/"..SourceSkyname.."lf"),
		Material("skybox/"..SourceSkyname.."ft"),
		Material("skybox/"..SourceSkyname.."rt"),
		Material("skybox/"..SourceSkyname.."bk"),
		Material("skybox/"..SourceSkyname.."dn"),
		Material("skybox/"..SourceSkyname.."up"),
	}

	function GM:ChangeSkybox(skyboxname)

		do
			return
		end
		
		for i = 1,6 do

			local basetexture = Material("skybox/"..skyboxname..SourceSkyPre[i]):GetTexture("$basetexture")
			local hdrbase = Material("skybox/"..skyboxname..SourceSkyPre[i]):GetTexture("$hdrbasetexture")
			local hdrcompressedtexture = Material("skybox/"..skyboxname..SourceSkyPre[i]):GetTexture("$hdrcompressedtexture")

			if basetexture ~= nil then
				SourceSkyMat[i]:SetTexture("$basetexture", basetexture)
			end
			if hdrbase ~= nil then
				SourceSkyMat[i]:SetTexture("$hdrbase", hdrbase)
			end
			if hdrcompressedtexture ~= nil then
				SourceSkyMat[i]:SetTexture("$hdrcompressedtexture", hdrcompressedtexture)
			end

		end
	end

	hook.Add("OnEntityCreated", "COOP_SkyboxOverride", function(ent)

		if ent == LocalPlayer() then
			DbgPrint("Found LocalPlayer")

			if GAMEMODE.SkyboxOverride then
				DbgPrint("Changing Skybox")
				GAMEMODE:ChangeSkybox(GAMEMODE.SkyboxOverride)
			end
		end

	end)


else

	hook.Add("EntityKeyValue", "COOP_EffectsKeyValue", function(ent, key, value)

		if ent:GetClass() == "light_environment" and key == "pitch" then
			DbgPrint("Found light_environment")
			ent:SetName("coop_light")
			--ent:Fire("setpattern", "c")
			return "0"
		end

	end)

end
