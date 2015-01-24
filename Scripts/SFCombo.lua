--<<ShadowFiend Combo >>
--
--
--
--
--                                             ●▬▬▬▬ஜ۩۞۩ஜ▬▬▬▬●
--
-- Welcome to one of my various (5) DOTO scripts, if you enjoy it please leave a thanks on my thread :) 
--                      Perfectly timed ShadowFiend Combo, Eul's ➪ Blink ➪ Ult
--
--                                           Target = Closest to mouse
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
config:Load()

local Hotkey     = config.Hotkey
local registered	= false
local target	    = nil
local active	    = false

--Text on your screen
local x,y = 1420, 50
local monitor = client.screenSize.x/1600
local F14 = drawMgr:CreateFont("F14","Verdana",15*monitor,550*monitor) 
local statusText = drawMgr:CreateText(x*monitor,y*monitor,-1,"SFCOMBO - HOLD: ''"..string.char(Hotkey).."''",F14) statusText.visible = false

function onLoad()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me or me.classId ~= CDOTA_Unit_Hero_Nevermore then
			script:Disable()
		else
			registered = true
			statusText.visible = true
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
end

function Main(tick)
	if not SleepCheck() then return end

	local me = entityList:GetMyHero()
	if not (me and active) then return end
	
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
	
	--It's that simple ;)
end

function onClose()
	collectgarbage("collect")
	if registered then
	    statusText.visible = false
		script:UnregisterEvent(Main)
		script:UnregisterEvent(Key)
		registered = false
	end
end

script:RegisterEvent(EVENT_CLOSE,onClose)
script:RegisterEvent(EVENT_TICK,onLoad)
