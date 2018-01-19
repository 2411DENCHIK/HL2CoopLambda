if SERVER then
util.AddNetworkString('picker_get_ents')
net.Receive('picker_get_ents',function(length,player)
	if player and IsValid(player) and player:IsPlayer() then
		local class=net.ReadString()
		if type(class)=='string' then
			local ents=ents.FindByClass(class)
			local ents2={}
			for k,v in pairs(ents) do
				if !v or !IsValid(v) then continue end
				if v:GetClass()=='trigger_transition'||v:GetClass()=='trigger_changelevel' then print('GetLocalPos',v:GetLocalPos(),'GetPos',v:GetPos(),'OBBCenter',v:OBBCenter()) pos=v:OBBCenter() else pos=v:GetPos() end
				ents2[#ents2+1]={v:GetClass(),v:EntIndex(),pos,v:GetAngles(),v:GetModel(), v:OBBMins(), v:OBBMaxs()}
			end
			net.Start('picker_get_ents')
			net.WriteTable(ents2)
			net.Send(player)
		end
	end
end)
util.AddNetworkString('picker_remove_nodraw')
net.Receive('picker_remove_nodraw',function(length,player)
	if player and IsValid(player) and player:IsPlayer() then
		local class=net.ReadString()
		if type(class)=='string' then
			local ents=ents.FindByClass(class)
			for k,v in pairs(ents) do
				v:RemoveEffects(EF_NODRAW)
			end
		end
	end
end)
util.AddNetworkString('picker_get_keyvalues')
net.Receive('picker_get_keyvalues',function(length,player)
	if player and IsValid(player) and player:IsPlayer() then
		local entindex=net.ReadInt(32)
		if type(entindex)=='number' then
			print(entindex)
			local ent=Entity(entindex)
			local keyvalues=ent:GetKeyValues()
			net.Start('picker_get_keyvalues')
			net.WriteTable(keyvalues)
			net.Send(player)
		end
		
	end
end)
end
if CLIENT then
local enttable={}
local DebugMat = Material("models/wireframe")
net.Receive('picker_get_ents',function(length)
	local tab=net.ReadTable()
	enttable=tab
end)
net.Receive('picker_get_keyvalues',function(length)
	local tab=net.ReadTable()
	PrintTable(tab)
end)
concommand.Add('picker2_get_ents',function(p,c,a)
	local class
	if #a==0 then print('Usage: picker2_get_ents <classname> -- it gets all the ents according to server yeah')
	elseif #a>1 then class=table.concat(a,' ')
	else class=a[1] end
	if class then print(class) end
	net.Start('picker_get_ents')
	net.WriteString(class)
	net.SendToServer()
end)
concommand.Add('picker2_remove_nodraw',function(p,c,a)
	local class
	if #a==0 then print('Usage: picker2_remove_nodraw <classname> -- removes nodraw effect from entity, useful for triggers')
	elseif #a>1 then class=table.concat(a,' ')
	else class=a[1] end
	if class then print(class) end
	net.Start('picker_remove_nodraw')
	net.WriteString(class)
	net.SendToServer()
end)

concommand.Add('picker2_get_keyvalues',function(p,c,a)
	local class
	if #a==0 then print('Usage: picker2_get_keyvalues <ent index> -- gets keyvalues of entity, useful for triggers')
	else class=tonumber(a[1]) end
	if class then 
	net.Start('picker_get_keyvalues')
	print(class)
	net.WriteInt(class,32)
	net.SendToServer()
	end
end)

local mode=0

local Round = math.Round
local abs = math.abs
local table_insert = table.insert
local sprintf = string.format

local vecformat = "%.2f, %.2f, %.2f"
local function FormatVector(value)
	return sprintf(vecformat, value.x, value.y, value.z)
end

local function FormatAngle(value)
	return sprintf(vecformat, value.p, value.y, value.r)
end

function DrawBox(pos, ang, mins, maxs)	
	render.SuppressEngineLighting( true )
	render.SetColorModulation( 1, 1, 1 )
	render.SetMaterial(DebugMat)
	render.SetBlend(1)
	render.DrawBox(pos, ang, mins, maxs, Color(255, 255, 255, 155))
	render.SuppressEngineLighting( false )
end

local maxdistance = 1000

function DoBoxes()
	local ply = LocalPlayer()
	local localpos = ply:GetPos()
	
	for i=1,#enttable do
		local worldpos=enttable[i][3]		
		if localpos:Distance(worldpos) > maxdistance then
			continue
		end
		-- v:GetClass(), v:EntIndex(), pos, v:GetAngles(), v:GetModel(), v:OBBMins(), v:OBBMaxs()
		local mins = enttable[i][6]
		local maxs = enttable[i][7]
		local pos = enttable[i][3]
		local ang = enttable[i][4]
		DrawBox(pos, ang, mins, maxs)
	end
end

local function DoPaint()
	local ply = LocalPlayer()
	local localpos = ply:GetPos()
	
	for i=1,#enttable do
		local text="Entity: ("..enttable[i][2] ..") ".. enttable[i][1]
		local worldpos=enttable[i][3]
		if localpos:Distance(worldpos) > maxdistance then
			continue
		end
		
		local screenpos=worldpos:ToScreen()
		surface.SetFont("BudgetLabel")
		draw.DrawText(text, "BudgetLabel", screenpos.x, screenpos.y, Color(255,255,255,255), TEXT_ALIGN_LEFT)
		local w,h=surface.GetTextSize( text )
		screenpos.y=screenpos.y+h
		local text="Position: " .. FormatVector(enttable[i][3])
		draw.DrawText(text, "BudgetLabel", screenpos.x, screenpos.y, Color(255,255,255,255), TEXT_ALIGN_LEFT)
		local w,h=surface.GetTextSize( text )
		screenpos.y=screenpos.y+h
		local text="Angles: " .. FormatAngle(enttable[i][4])
		draw.DrawText(text, "BudgetLabel", screenpos.x, screenpos.y, Color(255,255,255,255), TEXT_ALIGN_LEFT)
		local w,h=surface.GetTextSize( text )
		screenpos.y=screenpos.y+h
		local text="Model: " .. (enttable[i][5] or "No idea")
		draw.DrawText(text, "BudgetLabel", screenpos.x, screenpos.y, Color(255,255,255,255), TEXT_ALIGN_LEFT)
		local w,h=surface.GetTextSize( text )
		screenpos.y=screenpos.y+h
		local text="OBBMins: " .. (tostring(enttable[i][6]) or "No idea")
		draw.DrawText(text, "BudgetLabel", screenpos.x, screenpos.y, Color(255,255,255,255), TEXT_ALIGN_LEFT)
		local w,h=surface.GetTextSize( text )
		screenpos.y=screenpos.y+h
		local text="OBBMaxs: " .. (tostring(enttable[i][7]) or "No idea")
		draw.DrawText(text, "BudgetLabel", screenpos.x, screenpos.y, Color(255,255,255,255), TEXT_ALIGN_LEFT)
	end
end

concommand.Add('picker2_ents',function(p,c,a)
	mode=(mode+1)%2
	if mode==0 then
		hook.Remove( "PostDrawOpaqueRenderables", "picker2_ents" )
		hook.Remove('HUDPaint','picker2_ents')
		print('Picker2_ents disabled')
	elseif mode==1 then
		hook.Add( "PostDrawOpaqueRenderables", "picker2_ents", DoBoxes )
		hook.Add('HUDPaint','picker2_ents',DoPaint)
		print('Picker2_ents enabled')
	end
end)

end