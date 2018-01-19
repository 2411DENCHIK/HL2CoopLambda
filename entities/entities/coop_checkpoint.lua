AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

function ENT:KeyValue (k,v)
end

function ENT:Initialize ()
	self:SetNoDraw(true)
end

function ENT:StartTouch (ent)
end

function ENT:Draw()
end
