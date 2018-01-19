include( "dependencies/von.lua" )
local ammotypes={
'AR2', -- Ammunition of the AR2/Pulse Rifle
'AR2AltFire', -- (name in-game "5.7mm Ammo")
'Pistol', -- Ammunition of the 9MM Pistol 
'SMG1', -- Ammunition of the SMG/MP7
'357', -- Ammunition of the .357 Magnum
'XBowBolt', -- Ammunition of the Crossbow
'Buckshot', -- Ammunition of the Shotgun
'RPG_Round', -- Ammunition of the RPG/Rocket Launcher
'SMG1_Grenade', -- Ammunition for the SMG/MP7 grenade launcher (secondary fire)
'Grenade',
'slam', -- (name in-game ".45 Ammo")
'SniperRound', -- Note you must be given the grenade weapon (weapon_frag) before you can throw grenades.
'Thumper', -- Ammunition cannot exceed 2 (name in-game "Explosive C4 Ammo")
'Gravity', -- (name in-game "4.6MM Ammo")
'Battery', -- (name in-game "9MM Ammo")
'GaussEnergy',
'CombineCannon', -- (name in-game ".50 Ammo")
'AirboatGun', -- (name in-game "5.56MM Ammo")
'StriderMinigun', -- (name in-game "7.62MM Ammo")
'HelicopterGun',
'AlyxGun', -- Ammunition of the AR2/Pulse Rifle 'combine ball' (secondary fire)
'SniperPenetratedRound'
}
function GM:GetSaveData()
local t={} 
	for k,v in pairs(player.GetAll()) do 
		local n=tostring(v:UniqueID())
		t[n]={} 
		t[n]['weapons']={} 
		for kk,vv in pairs(v:GetWeapons()) do 
			t[n]['weapons'][kk]=vv:GetClass() 
		end 
		local h=v:Health()
		if h==0 then h=100 end
		t[n]['health']=h
		t[n]['armor']=v:Armor()
		t[n]['ammo']={}
		local delete=true
		for _,name in pairs(ammotypes) do
			if v:GetAmmoCount(name)!=0 then
				delete=false t[n]['ammo'][name]=v:GetAmmoCount(name)
			end
		end
		for _,weapon in pairs(v:GetWeapons()) do
			if weapon:GetClass()=='weapon_slam' then continue end
			if weapon:Clip1()>0 then
				if (t[n]['ammo'][ammotypes[weapon:GetPrimaryAmmoType()]]!=nil) then 
					t[n]['ammo'][ammotypes[weapon:GetPrimaryAmmoType()]]=t[n]['ammo'][ammotypes[weapon:GetPrimaryAmmoType()]]+weapon:Clip1()
					delete=false
				else 
					t[n]['ammo'][ammotypes[weapon:GetPrimaryAmmoType()]]=weapon:Clip1() 
					delete=false
				end 
			end
			if weapon:Clip2()>0 then 
				if (t[n]['ammo'][ammotypes[weapon:GetSecondaryAmmoType()]]!=nil) then 
						t[n]['ammo'][ammotypes[weapon:GetSecondaryAmmoType()]]=t[n]['ammo'][ammotypes[weapon:GetSecondaryAmmoType()]]+weapon:Clip2() 
						delete=false
					else
					t[n]['ammo'][ammotypes[weapon:GetPrimaryAmmoType()]]=weapon:Clip2() 
					delete=false
				end 
			end
		end

		if delete then t[n]['ammo']=nil end
	end
	return t
end

function GM:WriteSaveData(time_to_live)
	local nextmap=self:GetNextMap()
	local savefile = 'hl2coop/transition_'..nextmap..'.txt'
	print(nextmap)
	print(savefile)
	if nextmap==nil then return end
	if file.Exists(savefile,'DATA') then file.Delete(savefile) print('Removed',savefile) end -- sorry there's room only for one of us
	local tab={}
	tab['time']=math.ceil(CurTime())
	tab['timetolive']=(time_to_live or 60*15)
	tab['data']=self:GetSaveData()
	file.Write(savefile,von.serialize(tab))
	tab=nil
	nextmap=nil
end

function GM:LoadSaveData()
	local map=game.GetMap()
	if !map then return end
	
	local savefile = 'hl2coop/transition_'..map..'.txt'
	if file.Exists(savefile,'DATA') then savedata=von.deserialize(file.Read(savefile,'DATA'))
	else
		print('ERROR','Save data not present for map ('..savefile..')',map)
		return
	end
	if CurTime()>savedata['timetolive']+savedata['time'] then print('ERROR','Save data expired') return end
	savedata=savedata['data']
	return savedata
end

function GM:HasSaveData(ply) -- true = save data for player ply found, false = exact opposite
	local n=tostring(ply:UniqueID())
	if self.SaveData==nil then return false end
	if self.SaveData[n]==nil then return false end
	return true
end

function GM:LoadSave(ply)
	if !self:HasSaveData(ply) then return false end
	ply:StripWeapons()
	ply:StripAmmo()
	local n=tostring(ply:UniqueID())
	for k,v in pairs(self.SaveData[n]['weapons']) do
		ply:Give2(v)
	end
	for k,v in pairs(ply:GetWeapons()) do
		if v:Clip1()>0 then v:SetClip1(0) end
		if v:Clip2()>0 then v:SetClip2(0) end
	end
	if type(self.SaveData[n]['ammo'])=='table' then
		for k,v in pairs(self.SaveData[n]['ammo']) do
			ply:SetAmmo(v,k)
		end
	end
	ply:SetHealth(self.SaveData[n]['health'])
	ply:SetArmor(self.SaveData[n]['armor'])
	self.SaveData[n]=nil
	return true
end