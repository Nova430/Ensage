--<<                  Earth Spirit Tools v1.2 ¬ Rework By Nova >> 

require("libs.Utils")
require("libs.TargetFind")
require("libs.ScriptConfig")
require("libs.SkillShot")

--[[
 0 1 0 1 0 0 1 1    
 0 1 1 0 1 1 1 1        ____          __        __           |     _  __             
 0 1 1 1 0 0 0 0       / __/__  ___  / /  __ __/ /__ ___ __  |    / |/ /__ _  _____ _  
 0 1 1 0 1 0 0 0      _\ \/ _ \/ _ \/ _ \/ // / / _ `/\ \ /  |   /    / _ \ |/ / _ `/  (was bored so put my name here too xb)
 0 1 1 1 1 0 0 1     /___/\___/ .__/_//_/\_, /_/\_,_//_\_\   |  /_/|_/\___/___/\_,_/ 
 0 1 1 0 1 1 0 0             /_/        /___/                |
 0 1 1 0 0 0 0 1    
 0 1 1 1 1 0 0 0 
			Earth Spirit Tools  v1.2
		3 Combos in one key, skipping to other combo if spells for one isn't ready:
			Remnant - Boulder Smash - Geomagnetic Grip - Rolling Boulder
			Remnant - Geomagnetic Grip - Rolling Boulder
			Remnant - Boudler Smash - Geomagnetic Grip
		Instant remnant and spell cast to desired mouse location
			Remnant Smash
			Rolling Remnant
			Remnant Grip
		Smash Navigator: Hovering mouse on a nearby unit will show where the target will go with the Boulder Smash
		Auto Magnetize: A remnant will refresh an enemy's Magnetize debuff if it is about to end
		Changelog:
			v1.0:
			 - Release
			v1.1:
			 - Rework by Nova
			 - Slight changes to fix bugs
			v1.2
			 - Smart Text GUI
			 - Updated and Improved SmashNav (Fixed main displaying bug, changed display effect, update to accuracy)
]]

config = ScriptConfig.new()
config:SetParameter("PushKey", "Z", config.TYPE_HOTKEY)
config:SetParameter("RollKey", "X", config.TYPE_HOTKEY)
config:SetParameter("PullKey", "C", config.TYPE_HOTKEY)
config:SetParameter("ComboKey","32", config.TYPE_HOTKEY)
config:SetParameter("NavReset", "T", config.TYPE_HOTKEY)
config:SetParameter("SmashNavigator", true, config.TYPE_BOOL)
config:SetParameter("PingCheck", true, config.TYPE_BOOL)
config:SetParameter("AutoMagnetize", true, config.TYPE_BOOL)
config:SetParameter("Text X", 5)
config:SetParameter("Text Y", 45)
config:Load()

remnants = {}
effs = {}
init = false
stage = {combo = 0, push = 0, pull = 0, roll = 0}
itemSleep = 75
castSleep = 75
bat = 100
remnant = nil
push = nil
pull = nil
roll = nil
magnetize = nil

local PushKey = config.PushKey
local PullKey = config.PullKey
local RollKey = config.RollKey
local ComboKey = config.ComboKey

local pushactive = false
local pullactive = false
local rollactive = false
local comboactive = false

local nav = config.SmashNavigator
local ping = config.PingCheck
local ult = config.AutoMagnetize
local NavReset = config.NavReset

local dirty = false
local ResetNav = false
local timeremain = 1
local cooldown = false
local manatick = false

--___/\___/ TEXT \___/\___--
local x,y = config:GetParameter("Text X"), config:GetParameter("Text Y")
local TitleFont = drawMgr:CreateFont("Title","Segoe UI",18,580) 
local ControlFont = drawMgr:CreateFont("Title","Segoe UI",14,500)
local text = drawMgr:CreateText(x,y,0x6CF58CFF,"Earth Spirit Tools v1.2",TitleFont) text.visible = false
local controls0 = drawMgr:CreateText(x,y+16,0x6CF58CFF," >  " .. string.char(PushKey) .." is Smash to mouse position",ControlFont) controls0.visible = false
local controls1 = drawMgr:CreateText(x,y+30,0x6CF58CFF," >  " .. string.char(RollKey) .." is Boulder to mouse position",ControlFont) controls1.visible = false
local controls2 = drawMgr:CreateText(x,y+44,0x6CF58CFF," >  " .. string.char(PullKey) .." is Grip to mouse position",ControlFont) controls2.visible = false
local controls3 = drawMgr:CreateText(x,y+58,0x6CF58CFF,"" .. string.char(ComboKey) .."is combo on target nearest to mouse",ControlFont) controls3.visible = false
local message = drawMgr:CreateText(x,y+80,0xED5153FF,"These messages will disappear in seconds",ControlFont) message.visible = false
local status = drawMgr:CreateText(x,y,0x2CFA02FF,"Script Status : Ready to rock!",ControlFont) status.visible = false
local NavWarning = drawMgr:CreateText(x,y+14,0xED5153FF,"SmashNav is currently active, if it bugs just click T to reset :)",ControlFont) NavWarning.visible = false
local manawarning = drawMgr:CreateText(x,y+14,0xED5153FF,"",ControlFont) manawarning.visible = false
local partialwarning = drawMgr:CreateText(x,y+28,0x6CF58CFF,"             You have enough mana for a partial combo!",ControlFont) partialwarning.visible = false


function Load()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me or me.classId ~= CDOTA_Unit_Hero_EarthSpirit then 
			script:Disable()
		else
		    print("\\__| Earth Spirit Tools v1.1 initiated! |__/")
			if ComboKey == 32 then 
			    controls3.text = "Space is combo on target nearest to mouse"
			end
			script:RegisterEvent(EVENT_TICK,Tick)
			script:RegisterEvent(EVENT_KEY,Key)
			script:UnregisterEvent(Load)
		end
	end
end

function Close()
	collectgarbage("collect")
	if init then
		effs = {}
		init = false
		remnant = nil
		push = nil
		pull = nil
		roll = nil
		magnetize = nil
	        mouseOver = nil
		timeremain = nil
		text.visible = false
                controls0.visible = false
		controls1.visible = false
		controls2.visible = false
		controls3.visible = false
		message.visible = false
		status.visible = false
		manawarning.visible = false
		partialwarning.visible = false
		script:UnregisterEvent(Tick)
		script:UnregisterEvent(Key)
		script:RegisterEvent(EVENT_TICK,Load)
	end
end

function Key(msg,code)
	if client.chat or client.console or client.loading then return end

	if code == PushKey then
		pushactive = (msg == KEY_DOWN)
		status.text = "Script Status : Pushing!"
		status.color = 0xED9A09FF
	end
	
        if code == PullKey then
		pullactive = (msg == KEY_DOWN)
		status.text = "Script Status : Pulling!"
		status.color = 0xED9A09FF
	end
	
        if code == RollKey then
		rollactive = (msg == KEY_DOWN)
		status.text = "Script Status : Escaping!"
		status.color = 0xED9A09FF
	end
	
        if code == ComboKey then
		comboactive = (msg == KEY_DOWN)
		status.text = "Script Status : Combo-ing!"
		status.color = 0xED9A09FF
        end
	
	if code == NavReset then
	    ResetNav = true
        end
	
	if code == 2 and not (cooldown or manatick) and text.visible == false then
                status.text = "Script Status : Ready to rock!"
		status.color = 0x2CFA02FF
	end
	
end

function Tick(tick)

    local me = entityList:GetMyHero()
	if not me then return end

	Init()
	
	TrackRemnants()

	SmashNav()

	Combo()

	RemnantSmash()

	RollingRemnant()

	RemnantGrip()

	ExtendMagnetize()
	
	
	if client.gameTime < 30  and text.visible == false  then
	    text.visible = true
		controls0.visible = true
		controls1.visible = true
		controls2.visible = true
		controls3.visible = true
		message.visible = true
	elseif client.gameTime > 30 then
	        status.visible = true
		text.visible = false
                controls0.visible = false
		controls1.visible = false
		controls2.visible = false
		controls3.visible = false
		message.visible = false
	end
	
	if client.gameTime < 30 then 
		timeremain = math.ceil(30 - client.gameTime)
	        message.text = "These messages will disappear in " .. (timeremain) .. " seconds"
	end
	
	if roll.cd > 0 and (push.cd > 0 or pull.cd > 0) then
	        status.text = "Script Status : Cooling Down!"
		status.color = 0xED5153FF
		cooldown = true
	elseif roll.cd == 0 and (push.cd == 0 or pull.cd == 0) then
	        cooldown = false
	end
		
	if me.mana <  225 and not cooldown then 
	        manareq = (225 - math.ceil(me.mana)) 
	        manawarning.visible = true
		manawarning.text = "WARNING: You don't have enough mana for a full combo, you need " .. (manareq) .. " more mana"
	        status.text = "Script Status : Not enough mana!"
		status.color = 0x5178EDFF
		manatick = true
	end
	
	if me.mana > 125 and manatick then
	    partialwarning.visible = true
	else 
	    partialwarning.visible = false
	end
	
	if me.mana > 225 and manatick then
	    manawarning.visible = false
		partialwarning.visible = false
		manatick = false
	end
	
	if NavWarning.visible == true and manatick then
	    NavWarning.y = y+56
	else 
	    NavWarning.y = y+14
	end
	
end

function Init()
    local me = entityList:GetMyHero()
	if not init then
                for i=1,40 do
			effs[i] = Effect(Vector(0,0,-1250),"espirit_boouldersmash_groundsmoketrail")
		end
		
		remnant = me:FindSpell("earth_spirit_stone_caller")
	        push = me:FindSpell("earth_spirit_boulder_smash")
	        pull = me:FindSpell("earth_spirit_geomagnetic_grip")
	        roll = me:FindSpell("earth_spirit_rolling_boulder")
	        magnetize = me:FindSpell("earth_spirit_magnetize")
		
		init = true
	end
end

function SmashNav()
    local me = entityList:GetMyHero()
	local latest = GetLatestRemnant()
	local mouseOver = nil
	
	local allRemnants = entityList:FindEntities({classId = CDOTA_Unit_Earth_Spirit_Stone, team = me.team})
	if #allRemnants > 0 and mouseOver == nil then
		table.sort(allRemnants, function(a,b) return GetDistance2D(a, client.mousePosition) < GetDistance2D(b, client.mousePosition) end)
		if GetDistance2D(allRemnants[1].position,client.mousePosition) < 100 then
			mouseOver = allRemnants[1].position
		end
	end
	
	if nav and me:CanCast() and push:CanBeCasted() and mouseOver then
	    local limit = 20
	   	for i=1,limit do
	    	local xyz = (((mouseOver - me.position) / me:GetDistance2D(mouseOver) * 70 * i) + mouseOver)
		   	local vec = Vector((xyz.x),(xyz.y),(me.position.z))
            effs[i]:SetVector(0,vec)
	    end
		NavWarning.visible = true
		dirty = true
	elseif (push.cd > 0 or dirty) then
		for i=1,20 do
			effs[i]:SetVector(0,Vector(0,0,-1250))
		end
		dirty = false
		mouseOver = nil
		NavWarning.visible = false
	end
	
	if ResetNav and dirty then
		for i=1,20 do
			effs[i]:SetVector(0,Vector(0,0,-1250))
		end
		mouseOver = nil
		dirty = false
		ResetNav = false
		NavWarning.visible = false
	end
end

function Combo()
    local me = entityList:GetMyHero()
	if comboactive and SleepCheck("c") then
		local target = targetFind:GetClosestToMouse(100)
		local latest = GetLatestRemnant()
		if target then
			if stage.combo == 0 then
				stage.combo = 1
				if me.activity == 422 and ping then
					me:Stop()
					Sleep(client.latency + 25,"c")
				end
			elseif stage.combo == 1 and remnant:CanBeCasted() then
				if push:CanBeCasted() and pull:CanBeCasted() and me:CanCast() then
					local xyz = SkillShot.SkillShotXYZ(me,target,375,1200)
					if xyz then
						me:SafeCastAbility(remnant,(xyz - me.position) * 150 / GetDistance2D(xyz,me) + me.position)
						me:SafeCastAbility(push,((xyz - me.position) * 150 / GetDistance2D(xyz,me) + me.position), true)
						stage.combo = 2
						Sleep(castSleep*2 + 250,"c")
					end
				elseif pull:CanBeCasted() and me:CanCast() and roll:CanBeCasted() then
					me:SafeCastAbility(remnant,target.position)
					me:SafeCastAbility(pull,target.position, true)
					me:SafeCastAbility(roll,target.position, true)
					stage.combo = 3
					Sleep(castSleep*3 + 250,"c")
				end
			elseif stage.combo == 2 then
				if latest and target:IsStunned() then
					me:CastAbility(pull,(((latest.position - me.position) * 100 / GetDistance2D(latest,me)) + latest.position))
						if roll:CanBeCasted() then
							me:SafeCastAbility(roll,target.position)
						end
						stage.combo = 3
						Sleep(castSleep*3 + 250,"c")
				end
			elseif stage.combo == 3 then
				me:Attack(target,true)
				stage.combo = 4
				Sleep(castSleep + 158,"c")
			end
		end
	elseif SleepCheck("c") then
		stage.combo = 0
	end
end

function RemnantSmash( ... )
    local me = entityList:GetMyHero()
	if (pushactive or (stage.push > 0 and stage.push < 2)) and SleepCheck("push") then
		local target = client.mousePosition
		if me:GetDistance2D(target) < 2000 and GetDistance2D(target,Vector(0,0,0)) > 1 then
			if remnant:CanBeCasted() and push:CanBeCasted() and me:CanCast() then
				if stage.push == 0 then
					stage.push = 1
					if me.activity == 422 and  ping then
						me:Stop()
						Sleep(client.latency + 25,"push")
					end
				elseif stage.push == 1 then
					me:SafeCastAbility(remnant,(target - me.position) * 150 / GetDistance2D(target,me) + me.position)
					me:SafeCastAbility(push,(target - me.position) * 150 / GetDistance2D(target,me) + me.position, true)
					stage.push = 2
					Sleep(1000,"push")
				end
			end
		end
	elseif SleepCheck("push") then
		stage.push = 0
	end
end

function RollingRemnant( ... )
    local me = entityList:GetMyHero()
	if (rollactive or (stage.roll > 0 and stage.roll < 1)) and SleepCheck("roll") then
		local target = client.mousePosition
		if me:GetDistance2D(target) < 3000 and GetDistance2D(target,Vector(0,0,0)) > 1 then
			if remnant:CanBeCasted() and roll:CanBeCasted() and me:CanCast() then
				if stage.roll == 0 then
					me:SafeCastAbility(remnant,(target - me.position) * 150 / GetDistance2D(target,me) + me.position)
					me:SafeCastAbility(roll,target, true)
					stage.roll = 1
					Sleep(1000,"roll")
				end
			end
		end
	elseif SleepCheck("roll") then
		stage.roll = 0
	end
end

function RemnantGrip()
    local me = entityList:GetMyHero()
	if (pullactive or (stage.pull > 0 and stage.pull < 1)) and SleepCheck("pull") then
		local target = client.mousePosition
		if me:GetDistance2D(target) < 1100 and GetDistance2D(target,Vector(0,0,0)) > 1 then
			if remnant:CanBeCasted() and pull:CanBeCasted() and me:CanCast() then
				if stage.pull == 0 then
					me:SafeCastAbility(remnant,target)
					me:SafeCastAbility(pull,target, true)
					stage.pull = 1
					Sleep(1000,"pull")
				end
			end
		end
	elseif SleepCheck("pull") then
		stage.pull = 0
	end
end

function ExtendMagnetize()
    local me = entityList:GetMyHero()
	if ult and SleepCheck("ult") and me:CanCast() and remnant:CanBeCasted() then
        local enemies = entityList:FindEntities({type=LuaEntity.TYPE_HERO,team = me:GetEnemyTeam()})
		for i,v in ipairs(enemies) do
			if v.visible and v.alive and not v.illusion and v:GetDistance2D(me) < (remnant.castRange - 50) then
				local mod = v:FindModifier("modifier_earth_spirit_magnetize")
				if mod and mod.remainingTime < 0.4 then
					me:SafeCastAbility(remnant,v.position)
					Sleep(450, "ult")
				end
			end
		end
	end
end

function GetLatestRemnant()
    local me = entityList:GetMyHero()
	local allRemnants = entityList:FindEntities({classId = CDOTA_Unit_Earth_Spirit_Stone, team = me.team})
	if #allRemnants > 0 then
		table.sort(allRemnants, function(a,b) return remnants[a.handle]>remnants[b.handle] end)
		return allRemnants[1]
	end
end

function TrackRemnants()
    local me = entityList:GetMyHero()
	local allRemnants = entityList:FindEntities({classId = CDOTA_Unit_Earth_Spirit_Stone, team = me.team})
	for i,v in ipairs(allRemnants) do
		if not remnants[v.handle] then
			remnants[v.handle] = client.totalGameTime
		end
	end
end

script:RegisterEvent(EVENT_TICK,Load)
script:RegisterEvent(EVENT_CLOSE,Close)
