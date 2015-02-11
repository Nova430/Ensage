--<<ShadowFiend Combo >>
--
--
--
--
--                                               ●▬▬▬▬ஜ۩۞۩ஜ▬▬▬▬●
--
-- Welcome to one of my various (5) DOTO scripts, if you enjoy it please leave a thanks on my thread :) 
--              Perfectly timed ShadowFiend Combo, Eul's ➪ Blink ➪ Ult || NOW WITH EBLADE :D
--
--                                           Target = Closest to mouse
--
--                                     And again, thanks for using my script!
--
--                                               ●▬▬▬▬ஜ۩۞۩ஜ▬▬▬▬● 
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
local active	    = false
local Ractive     = false
local me = entityList:GetMyHero()

--Text on your screen
local x,y = config:GetParameter("TextPositionX"), config:GetParameter("TextPositionY")
local monitor = client.screenSize.x/1600
local F14 = drawMgr:CreateFont("F14","Tahoma",16*monitor,750*monitor) 
local F15 = drawMgr:CreateFont("F14","Tahoma",15*monitor,550*monitor) 
local statusText = drawMgr:CreateText(x*monitor,y*monitor,0xC92828FF,"ShadowFiend Script",F14) statusText.visible = false
local statusText2 = drawMgr:CreateText((x)*monitor,(y+17)*monitor,0xF5AE33FF,"HOLD: ''"..string.char(Hotkey).."'' for Ult Combo",F15) statusText2.visible = false
local statusText3 = drawMgr:CreateText((x)*monitor,(y+32)*monitor,0xF5AE33FF,"HOLD: ''"..string.char(RazeKey).."'' for Auto Raze",F15) statusText3.visible = false
local statusText4 = drawMgr:CreateText((x)*monitor,(y+47)*monitor,0xFFFFFFFFF,"Press:  ''"..string.char(HideKey).."'' to hide this message for the rest of the game.",F15) statusText4.visible = false

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

	--Stuff we need for combo
	local eul = me:FindItem("item_cyclone")
	local eblade = me:FindItem("item_ethereal_blade")
	local blink = me:FindItem("item_blink")
	local phase = me:FindItem("item_phase_boots")
	local ult = me:GetAbility(6)

	if not (active or Ractive) then
	    target = nil
	    return
	end
	
	--Combo
	if active then
        if target == nil then	
			target = targetFind:GetClosestToMouse(100)
		else
		local blademodif = target:FindModifier("modifier_item_ethereal_blade_slow")
		    if eblade then
			    if blademodif then
				    if eul and eul:CanBeCasted() and blademodif and not eulmodif then
	                    me:CastAbility(eul, target)
		    	        Sleep(600)
			            return
                    end	
				else
			        me:SafeCastAbility(eblade,target)
				    Sleep(100)
				    return
			    end
			elseif eul and eul:CanBeCasted() and not eulmodif then
	            me:CastAbility(eul, target)
		    	Sleep(600)
			    return
            end	
			
			local eulmodif = target:FindModifier("modifier_eul_cyclone")
            if eulmodif then
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
		end
	end
	
-- AUTORAZE ST00F

    if Ractive then
	    target = targetFind:GetClosestToMouse(100)
		local Raze1 = me:GetAbility(1)
		local Raze2 = me:GetAbility(2)
		local Raze3 = me:GetAbility(3)
		local distance = GetDistance2D(me,target)
	    if distance <= 400 and distance >= 0 and Raze1 and Raze1:CanBeCasted() then
		    CastRaze1()
            Sleep(500)	
		end
		
	    if distance <= 650 and distance >= 250 and Raze2 and Raze2:CanBeCasted() then
		    CastRaze2()	
            Sleep(500)				
		end
		
	    if distance <= 900 and distance >= 500 and Raze3 and Raze3:CanBeCasted() then
		    CastRaze3()	
            Sleep(500)			
		end
    end
	   
	--It's that simple ;)
end

function CastRaze1()
	local me = entityList:GetMyHero()
	local target = targetFind:GetClosestToMouse(100)
	local Raze1 = me:GetAbility(1)
	    if target then
		    me:Attack(target,false)
			me:Stop(true)
			me:CastAbility(Raze1)
		end
end

function CastRaze2()
	local me = entityList:GetMyHero()
	local target = targetFind:GetClosestToMouse(100)
	local Raze2 = me:GetAbility(2)
	    if target then
		    me:Attack(target,false)
			me:Stop(true)
			me:CastAbility(Raze2)
		end
end

function CastRaze3()
	local me = entityList:GetMyHero()
	local target = targetFind:GetClosestToMouse(100)
	local Raze3 = me:GetAbility(3)
	    if target then
		    me:Attack(target,false)
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
