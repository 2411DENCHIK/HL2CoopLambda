EFFECT.Speed = 250
EFFECT.RefractScale = 0.16

local matPinch = Material("Effects/strider_pinch_dudv")
local matBlueFlash = Material("Effects/blueblackflash")
local matBlueBeam = Material("Effects/blueblacklargebeam")

function EFFECT:Init( data )
	
	DbgPrint("Effect:Init")
	
	local ent = data:GetEntity()
		
	self.Scale = data:GetScale()
	self:SetPos(data:GetOrigin())
	self.Size = 0
	self.MaxSize = (32 * self.Scale) * 2
	self.Ent = ent
	self.Counter = 0
	self.Mins = self.Ent:OBBMins() * 1.2
	self.Maxs = self.Ent:OBBMaxs() * 1.2
	self.Center = self.Ent:OBBCenter()
	self:SetPos(ent:GetPos())
	self:SetParent(ent)
	self.Delta = 100
			
	self:SetCollisionBounds( Vector( -self.MaxSize, -self.MaxSize, -self.MaxSize ), Vector( self.MaxSize, self.MaxSize, self.MaxSize ) )
	self:SetRenderBoundsWS( self:GetPos() + Vector( -self.MaxSize, -self.MaxSize, -self.MaxSize ), self:GetPos() + Vector( self.MaxSize, self.MaxSize, self.MaxSize )  )
	
	self:EmitSound("hl2coop/teleport.mp3", 100, 100 + math.random(0, 10))
	
end


--[[---------------------------------------------------------
   THINK
-----------------------------------------------------------]]
function EFFECT:Think( )

	if not IsValid(self.Ent) then
		self:Remove()
		return
	end
		
	local ent = self.Ent
	
	if self.EffectStart == nil then

		self.EffectStart = true
		if ent.EffectStart then
			ent:EffectStart()
		end

	end
	
	if self.Size < self.MaxSize then
	
		self.Size = self.Size + (self.Speed * FrameTime())
			
		self.Mins = ent:OBBMins()
		self.Maxs = ent:OBBMaxs()
		self.Center = ent:OBBCenter()
		self.Delta = 1 - (self.Size / self.MaxSize)
		self:SetCollisionBounds( self.Mins, self.Maxs )
		self.Counter = self.Counter + (self.Speed * FrameTime())
		
		local alpha = math.Clamp(self.Size / self.MaxSize * 255, 0, 255)
		print(alpha)
		local col = Color(255, 255, 255, alpha)
		ent:SetColor(col)
		
		local wep = ent:GetNWEntity("Weapon")
		if IsValid(wep) then
			wep:SetColor(col)
		end
		
		return true
		
	else
	
		ent:SetColor(Color(255, 255, 255, 255))
		
		local wep = ent:GetNWEntity("Weapon")
		if IsValid(wep) then
			wep:SetColor(Color(255, 255, 255, 255))
		end
		
		self:Remove()
		
	end
		
end

--[[---------------------------------------------------------
   Draw the effect
-----------------------------------------------------------]]
function EFFECT:Render()

	-- Note: UpdateScreenEffectTexture fucks up the water, RefractTexture is lower quality
	if not IsValid(self.Ent) then
		return
	end
	
	local ripple = 1 + math.sin(self.Counter) * 1
	local ripple2 = 1 + math.cos(self.Counter) * 5
	local pos = self:GetPos()
	local ang = LocalPlayer():EyeAngles()
	local size = self.Size
		
	local maxLightnings = 10
	local maxSteps = 5
	local beamSize = 0.3 * (1 - self.Delta)
	local colors = 
	{
		Color(200, 0, 0, 255),
		Color(100, 0, 0, 255),
		Color(100, 100, 0, 255),
		Color(0, 0, 0, 255),
	}
		
	for i=1, maxLightnings do
		
		local lastPos = pos + self.Center
		local gainedSize = 0
		
		for x=1, maxSteps do
		
			local stepSize = (math.random(0, 50))
			if gainedSize >= size then
				stepSize = 0
			end
			
			local ang = Angle(math.random(0, 360), math.random(0, 360), math.random(0, 360))
			local dst = ang:Forward() * stepSize
			gainedSize = gainedSize + stepSize
			
			local color = colors[math.random(1, #colors)]
			color.a = 250 --* self.Delta
			
			render.SetMaterial( matBlueBeam )
			render.DrawBeam(lastPos, lastPos + dst, beamSize, 1, 1, color)
			
			lastPos = lastPos + dst
		end
		
	end
	
	local intrplt = 1
		
	render.DrawSphere( pos + self.Center, (size * 1.3) + ripple2 , 100, 100, Color(0, 0, 0, 255 * self.Delta) )
	
	matPinch:SetFloat("$refractamount", math.sin(1.5*intrplt*math.pi)*self.RefractScale)
	render.SetMaterial( matPinch )
	render.UpdateRefractTexture()
	render.DrawSphere( pos + self.Center, (size * 1.1) + ripple , 10, 10, Color(0, 0, 0, 255 * self.Delta) )
	
	render.SetMaterial( matBlueFlash )
	render.DrawSphere( pos + self.Center, (self.MaxSize - size * 1.1) + ripple2 , 10, 10, Color(0, 0, 0, 255 * self.Delta) )
	--render.DrawBox( pos, self:GetAngles(), self.Mins * (self.Delta + ripple), self.Maxs * self.Delta, Color(100, 100, 0, 10 * self.Delta), true )
	
end
