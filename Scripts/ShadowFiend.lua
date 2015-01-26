--<<ShadowFiend AutoRaze + Eul's ➪ Blink Combo>>
--
--
--
--
--                                             ●▬▬▬▬ஜ۩۞۩ஜ▬▬▬▬●
--
-- Welcome to one of my various (5) DOTO scripts, if you enjoy it please leave a thanks on my thread :) 
--                       -Perfectly timed ShadowFiend Combo, Eul's ➪ Blink ➪ Ult
--                                        -Auto Raze enemies [BETA]
--
--                                        Target = Closest to mouse
--
--                                   And again, thanks for using my script!
--
--                                             ●▬▬▬▬ஜ۩۞۩ஜ▬▬▬▬● 
--
--
--
--
--
--Libraries
require("libs.Utils")
require("libs.ScriptConfig")
require("libs.TargetFind")

--Config
config = ScriptConfig.new()
config:SetParameter("Hotkey", "D", config.TYPE_HOTKEY)
config:SetParameter("RazeKey", "F", config.TYPE_HOTKEY)
config:SetParameter("HideKey", "G", config.TYPE_HOTKEY)
config:SetParameter("TextPositionX", 5)
config:SetParameter("TextPositionY", 40)
config:Load()

local Hotkey     = config.Hotkey
local RazeKey  = config.RazeKey
local HideKey   = config.HideKey
local registered	= false
local target	    = nil
local active	    = false
local Ractive     = false

--Text on your screen
local x,y = config:GetParameter("TextPositionX"), config:GetParameter("TextPositionY")
local monitor = client.screenSize.x/1600
local F14 = drawMgr:CreateFont("F14","Tahoma",16*monitor,750*monitor) 
local F15 = drawMgr:CreateFont("F14","Tahoma",15*monitor,550*monitor) 
local statusText = drawMgr:CreateText(x*monitor,y*monitor,0xC92828FF,"ShadowFiend Script",F14) statusText.visible = false
local statusText2 = drawMgr:CreateText((x)*monitor,(y+17)*monitor,0xF5AE33FF,"HOLD: ''"..string.char(Hotkey).."'' for Ult Combo",F15) statusText2.visible = false
local statusText3 = drawMgr:CreateText((x)*monitor,(y+32)*monitor,0xF5AE33FF,"HOLD: ''"..string.char(RazeKey).."'' for Auto Raze",F15) statusText3.visible = false
local statusText4 = drawMgr:CreateText((x)*monitor,(y+47)*monitor,0xFFFFFFFFF,"Press:  ''"..string.char(HideKey).."'' to hide this message for the rest of game.",F15) statusText4.visible = false

function onLoad()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me or me.classId ~= CDOTA_Unit_Hero_Nevermore then
			script:Disable()
		else
			registered = true
			statusText.visible = true
			statusText2.visible = true
			statusText3.visible = true
			statusText4.visible = true
			script:RegisterEvent(EVENT_TICK,Main)
			script:RegisterEvent(EVENT_KEY,Key)
			script:UnregisterEvent(onLoad)
		end
	end
end

function Key(msg,code)
	if client.chat or client.console or client.loading then return end
	if code == Hotkey then
		active = (msg == KEY_DOWN)
	end
	if code == RazeKey then
		Ractive = (msg == KEY_DOWN)
	end
	if code == HideKey and statusText.visible == true then
	    statusText.visible = false
	    statusText2.visible = false
	    statusText3.visible = false
	    statusText4.visible = false
	end
end

function Main(tick)
	if not SleepCheck() then return end

	local me = entityList:GetMyHero()
	if not (me and (active or Ractive)) then return end
	
	--Stuff we need for combo
	local eul = me:FindItem("item_cyclone")
	local blink = me:FindItem("item_blink")
	local phase = me:FindItem("item_phase_boots")
	local ult = me:GetAbility(6)
	local target = targetFind:GetClosestToMouse(100)
	local distance = GetDistance2D(me,target)
	local eulmodif = target:FindModifier("modifier_eul_cyclone")
	
	--Combo
	if target and me.alive and active and not eulmodif then
        if eul and eul:CanBeCasted() then	
	        me:CastAbility(eul, target, true)
			Sleep(600)
			return
        end	
	end
	
	if target and eulmodif then
 		if blink and blink:CanBeCasted() and (eulmodif.remainingTime < 1.80) then
		    me:CastAbility(blink, target.position)
			Sleep(100)
			return
		end
	
		if ult and ult:CanBeCasted() and (eulmodif.remainingTime < 1.67) then
		    me:CastAbility(ult)
			Sleep(2000)
			return
		end
	end
	
-- AUTORAZE ST00F

    if target and Ractive then
	    if distance <= 400 and distance >= 0 then
		    CastRaze1()
            Sleep(350)	
		end
		
	    if distance <= 650 and distance >= 250 then
		    CastRaze2()	
            Sleep(350)				
		end
		
	    if distance <= 900 and distance >= 500 then
		    CastRaze3()	
            Sleep(350)			
		end
    end
	   
	--It's that simple ;)
end

function CastRaze1()
	local me = entityList:GetMyHero()
	local target = targetFind:GetClosestToMouse(100)
	local Raze1 = me:GetAbility(1)
	    if target and Raze1 and Raze1:CanBeCasted() then
		    me:Attack(target)
			me:Stop(true)
			me:CastAbility(Raze1)
		end
end

function CastRaze2()
	local me = entityList:GetMyHero()
	local target = targetFind:GetClosestToMouse(100)
	local Raze2 = me:GetAbility(2)
	    if target and Raze2 and Raze2:CanBeCasted() then
		    me:Attack(target)
			me:Stop(true)
			me:CastAbility(Raze2)
		end
end

function CastRaze3()
	local me = entityList:GetMyHero()
	local target = targetFind:GetClosestToMouse(100)
	local Raze3 = me:GetAbility(3)
	    if target and Raze3 and Raze3:CanBeCasted() then
		    me:Attack(target)
			me:Stop(true)
			me:CastAbility(Raze3)
		end
end

function onClose()
	collectgarbage("collect")
	if registered then
	    statusText.visible = false
		statusText2.visible = false
		statusText3.visible = false
		statusText4.visible = false
		script:UnregisterEvent(Main)
		script:UnregisterEvent(Key)
		registered = false
	end
end

script:RegisterEvent(EVENT_CLOSE,onClose)
script:RegisterEvent(EVENT_TICK,onLoad)
