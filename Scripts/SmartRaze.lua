--<<ShadowFiend SmartRaze, by Nova>>
--[[
                                                ●▬▬▬▬ஜ۩۞۩ஜ▬▬▬▬●
             ShadowFiend Smart Raze, HOLD the hotkey to automatically raze the enemy closes to your mouse.
                             Additional Features - Amazingly awesome range display :D
             
             CAUTION- This may have bugs, if you try this script please PM me, and tell me what you think
                                                ●▬▬▬▬ஜ۩۞۩ஜ▬▬▬▬● 


]]
--Libraries
require("libs.Utils")
require("libs.ScriptConfig")
require("libs.TargetFind")
require("libs.SkillShot")
require("libs.Animations")

--Config
config = ScriptConfig.new()
config:SetParameter("RazeKey", "F", config.TYPE_HOTKEY)
config:SetParameter("ToggleRange", "G", config.TYPE_HOTKEY)
config:SetParameter("TextPositionX", 5)
config:SetParameter("TextPositionY", 45)
config:Load()

local RazeKey  = config.RazeKey
local ToggleRange  = config.ToggleRange
local registered	= false
local active	    = false
local Ractive     = false
local command = 0
local mypos = nil
local init = false
local Awesome = true
local Default = false
local Off = false

R = {200, 450, 700}	
razes = {}

--Text on your screen
local x,y = config:GetParameter("TextPositionX"), config:GetParameter("TextPositionY")
local monitor = client.screenSize.x/1600 
local F15 = drawMgr:CreateFont("F14","Segue UI",15*monitor,550*monitor) 
local statusText3 = drawMgr:CreateText((x)*monitor,(y+32)*monitor,0xF5AE33FF,"HOLD: ''"..string.char(RazeKey).."'' for Auto Raze",F15) statusText3.visible = false
local statusText4 = drawMgr:CreateText((x)*monitor,(y+47)*monitor,0xFFFFFFFFF,"This is an early design. Currently incomplete. Sometimes it may get stuck, just press the  hotkey again.",F15) statusText4.visible = false
local statusText5 = drawMgr:CreateText((x)*monitor,(y+62)*monitor,0xFFFFFFFFF,"On your screen you have a cool range display, click "..string.char(ToggleRange).." to toggle it. (Awesome/Default/Off)",F15) statusText5.visible = false
local statusText6 = drawMgr:CreateText((x)*monitor,(y+77)*monitor,0xFFFFFFFFF,"Since this script is a beta, if you use it please PM me what you thought of it.",F15) statusText6.visible = false


function onLoad()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me or me.classId ~= CDOTA_Unit_Hero_Nevermore then
			script:Disable()
		else
			registered = true
			statusText3.visible = true
			statusText4.visible = true
			statusText5.visible = true
			statusText6.visible = true
			script:RegisterEvent(EVENT_TICK,Main)
			script:RegisterEvent(EVENT_KEY,Key)
			script:UnregisterEvent(onLoad)
		end
	end
end

function Key(msg,code)
	if client.chat or client.console or client.loading then return end
	if code == RazeKey then
		Ractive = (msg == KEY_DOWN)
	end
	if IsKeyDown(ToggleRange) then
	    if Awesome == true then 
		    Awesome = false
			Default = true
			for i=1,3 do
	            razes[i] = nil
		        collectgarbage("collect")
		    end
			return
		end
        if Default == true then 
		    Default = false
			Off = true
			for i=1,3 do
	            razes[i] = nil
		        collectgarbage("collect")
		    end
			return
		end
        if Off == true then 
		    Off = false
			Awesome = true
			for i=1,3 do
	            razes[i] = nil
		        collectgarbage("collect")
		    end
			return
		end
	end
	if msg == RBUTTON_DOWN then
	    rightclick = true
	else
	    rightclick = false
	end
end

function Main(tick)
	if not SleepCheck() then return end

	local me = entityList:GetMyHero()
	if not me then return end

	if not init then
	    Abilities = {me:GetAbility(1),me:GetAbility(2),me:GetAbility(3)}
	    init = true
	end
	
	if not Ractive then
	    target = nil
		command = 0
	    for i=1,3 do	
	    	local p = Vector(me.position.x + R[i] * math.cos(me.rotR), me.position.y + R[i] * math.sin(me.rotR), me.position.z)
				
	    	if not razes[i] then					
	    		if Abilities[i] and Abilities[i].state == -1 then
				    if Awesome then
	    			    razes[i] = Effect(p,  "aura_vlads")
	    			    razes[i]:SetVector(0, p )		
                    elseif Default then
	    			    razes[i] = Effect(p,  "range_display")
						razes[i]:SetVector(1,Vector(250,0,0) )
	    			    razes[i]:SetVector(0, p )	
                    end			
		    	end
	    	elseif not Off then
	         	if Abilities[i] and Abilities[i].state == -1 then
		    		razes[i]:SetVector(0, p )	
	    		else
		    		razes[i] = nil
		    		collectgarbage("collect")
		    	end			
		    end
	    end	
		if eff ~= nil then
			eff = nil
		    collectgarbage("collect")
		end
	    return
	else
	    for i=1,3 do
	        razes[i] = nil
		    collectgarbage("collect")
		end
	end
	
	target = targetFind:GetClosestToMouse(100)

-- AUTORAZE ST00F
    if Ractive and target then
		local Raze1 = me:GetAbility(1)
		local Raze2 = me:GetAbility(2)
		local Raze3 = me:GetAbility(3)
		
	    if command == 0 then
	        xyz1 = SkillShot.PredictedXYZ(target,(670 + client.latency +(me:GetTurnTime(target)*1000)))
			eff = Effect(xyz1,"aura_vlads")
	        eff:SetVector(0,xyz1)
			effect = true
			command = 1
	    end

		local distance = GetDistance2D(me,xyz1)
	    if distance <= 400 and distance >= 0 and Raze1 and Raze1:CanBeCasted() and SleepCheck("CastDelay") and SleepCheck("raze1cd") then
	        if command == 2 and rightclick then  
			    command = 0
			elseif command == 1 then  
			    me:Stop()
				mypos = nil
				me:Move(xyz1)
				command = 2
			elseif command == 2 and IsTurning() == false then
			    CastRaze(1)
				Sleep(1000,"CastCheck")
				command = 3
			elseif command == 3 and Animations.getDuration(Raze1) > 520 and SkillShot.PredictedXYZ(target,150):GetDistance2D(xyz1) > 250 then
			    me:Stop()
				command = 0
			elseif command == 3 and Animations.getDuration(Raze1) > 520 and SkillShot.PredictedXYZ(target,150):GetDistance2D(xyz1) <= 250 then
			    command = 0
				Sleep(9000,"raze1cd")
				Sleep(170,"CastDelay")
			elseif command == 3 and Raze1.cd >= 0 and SleepCheck("CastCheck") then
				command = 0
			end
		elseif distance <= 650 and distance >= 250 and Raze2 and Raze2:CanBeCasted() and SleepCheck("raze2cd") and SleepCheck("CastDelay") then
	        if command == 2 and rightclick then  
			    command = 0
			elseif command == 1 then
			    me:Stop()	
                mypos = nil			
				me:Move(xyz1)
				command = 2
			elseif command == 2 and IsTurning() == false then
			    CastRaze(2)
				Sleep(1000,"CastCheck")
				command = 3
			elseif command == 3 and Animations.getDuration(Raze2) > 520 and SkillShot.PredictedXYZ(target,150):GetDistance2D(xyz1) > 250 then
			    me:Stop()
				command = 0
			elseif command == 3 and Animations.getDuration(Raze2) > 520 and SkillShot.PredictedXYZ(target,150):GetDistance2D(xyz1) <= 250 then
			    command = 0
				Sleep(9000,"raze2cd")
				Sleep(170,"CastDelay")
			elseif command == 3 and Raze2.cd >= 0 and SleepCheck("CastCheck") then
				command = 0
			end
		elseif distance <= 900 and distance >= 500 and Raze3 and Raze3:CanBeCasted() and SleepCheck("raze3cd") and SleepCheck("CastDelay") then
	        if command == 2 and rightclick then  
			    command = 0
			elseif command == 1 then  
			    me:Stop()
				mypos = nil
				me:Move(xyz1)
				command = 2
			elseif command == 2 and IsTurning() == false then
			    CastRaze(3)
				Sleep(1000,"CastCheck")
				command = 3
			elseif command == 3 and Animations.getDuration(Raze3) > 520 and SkillShot.PredictedXYZ(target,150):GetDistance2D(xyz1) > 250 then
			    me:Stop()
				command = 0
			elseif command == 3 and Animations.getDuration(Raze3) > 520 and SkillShot.PredictedXYZ(target,150):GetDistance2D(xyz1) <= 250 then
			    command = 0
				Sleep(9000,"raze3cd")
				Sleep(170,"CastDelay")
			elseif command == 3 and Raze3.cd >= 0 and SleepCheck("CastCheck") then
				command = 0
			end
		elseif command == 1 then
		    command = 0
		end
    end

end
	
function IsTurning()
    local me = entityList:GetMyHero()
    if mypos == nil then
        mypos = me.position
	elseif me.position == mypos then
	    return true
	else
	    return false
	end
end
	
function CastRaze(number)
	local me = entityList:GetMyHero()
	local target = targetFind:GetClosestToMouse(100)
	local Raze = me:GetAbility((number))
	    if target then
			me:CastAbility(Raze)
		end
end

function onClose()
	collectgarbage("collect")
	if registered then
		statusText3.visible = false
		statusText4.visible = false
		statusText5.visible = false
		statusText6.visible = false
		effect = false
		command = 0
		mypos = nil
		init = false
                Awesome = true
                Default = false
                Off = false
		for i=1,3 do
	        razes[i] = nil
		end
		if eff ~= nil then
			eff = nil
		end
		script:UnregisterEvent(Main)
		script:UnregisterEvent(Key)
		registered = false
	end
end

script:RegisterEvent(EVENT_CLOSE,onClose)
script:RegisterEvent(EVENT_TICK,onLoad)
