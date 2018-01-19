local matWhite = CreateMaterial( "WhiteMaterial", "VertexLitGeneric", {
    ["$basetexture"] = "color/white",
    ["$vertexalpha"] = "1",
    ["$model"] = "1",
} );

local matComposite = CreateMaterial( "CompositeMaterial", "UnlitGeneric", {
    ["$basetexture"] = "_rt_FullFrameFB",
    ["$additive"] = "0",
} );

local matDOF = Material("pp/dof")

EFFECT.FlickerTime = 0.01

function EFFECT:Init( data )
	
	DbgPrint("Effect:Init")
	
	local ent = data:GetEntity()
	self.Mins = ent:OBBMins()
	self.Maxs = ent:OBBMaxs() 
	ent:AddEffects(EF_NODRAW)
		
	self.Entity = ent
	self.RenderTarget = GetRenderTarget("COOP_TELEPORT", ScrW(), ScrH(), true)
	self:SetPos(ent:GetPos())
	self:SetAngles(ent:GetAngles())
	self:SetParent(ent)
	self.DrawOwner = false
	self.Counter = 0
	self.Normal = data:GetNormal()
	
	self.TimeStart = CurTime()
	self.LastFlicker = CurTime() - self.FlickerTime
	
	self:SetCollisionBounds( self.Mins, self.Maxs )
	self:SetRenderBoundsWS( self:GetPos() + self.Mins, self:GetPos() + self.Maxs  )
	
	self:EmitSound("hl2coop/teleport.mp3", 100, 100 + math.random(0, 10))
	
	hook.Add("RenderScreenspaceEffects", self, self.PostEffects)
	
end


--[[---------------------------------------------------------
   THINK
-----------------------------------------------------------]]
function EFFECT:Think( )

	local ent = self.Entity
	
	if CurTime() - self.TimeStart >3.6 or not IsValid(ent) then
	
		if IsValid(ent) then
			-- Testing
			ent:RemoveEffects(EF_NODRAW)
		end
		
		DbgPrint("Removing Effect")
		self:SetParent(nil)
		self:Remove()
		
	else
		
		if CurTime() - self.LastFlicker >= self.FlickerTime then
			self.DrawOwner = not self.DrawOwner
			self.LastFlicker = CurTime()
		end

		return true
		
	end
	
end

function EFFECT:PostEffects()

	DrawMotionBlur(0.3, 0.3, FrameTime())
	
end

--[[---------------------------------------------------------
   Draw the effect
-----------------------------------------------------------]]
function EFFECT:Render()

	if not IsValid(self.Entity) then
		return
	end
			
	render.PushRenderTarget(self.RenderTarget)
		render.Clear(0, 0, 0, 0, true, true)

		render.SetColorModulation( 1, 1, 1 )
		render.SetWriteDepthToDestAlpha(false)
		render.SuppressEngineLighting( false )

		if self.DrawOwner == true then
			self.Entity:DrawModel()
			self:RenderModelEffects()
		end

		render.SuppressEngineLighting( false )
		render.UpdateScreenEffectTexture()
	
	render.PopRenderTarget()
		
	matComposite:SetTexture("$basetexture", self.RenderTarget)
	
	--render.BlurRenderTarget(self.RenderTarget, ScrW(), ScrH(), 12)
	
	render.SetMaterial(matComposite)
	render.DrawScreenQuad()
						
end

function EFFECT:RenderModelEffects()

	self.Counter = self.Counter + 1
	
	local currentScale = self.Entity:GetModelScale()
	local pos = self.Entity:GetPos()
	local pumpScale = 1 + (math.sin(self.Counter) * 0.03)
	self.Entity:SetModelScale(pumpScale, 0)
	self.Entity:DrawModel()
	self.Entity:SetModelScale(currentScale, 0)
	render.SetMaterial(matDOF)
	
	for i = 0, 106 do
		local rand_x = math.Clamp(math.random(0, 1000), self.Mins.x, self.Maxs.x)
		local rand_y = math.Clamp(math.random(0, 1000), self.Mins.y, self.Maxs.y)
		local rand_z = math.Clamp(math.random(0, 1000), self.Mins.z, self.Maxs.z)
		local randPos = Vector(rand_x, rand_y, rand_z)
		render.DrawSphere( pos + randPos, 1, 10, 10, Color(0, 0, 0, 255) )
	end
				
end

