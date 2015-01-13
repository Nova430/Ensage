--<<Batrider AutoNapalm and Firefly ➪ Blink ➪ Napalm ➪ Lasso Combo>>
--
--
--
--
--                                             ●▬▬▬▬ஜ۩۞۩ஜ▬▬▬▬●
--
-- Welcome to one of my various (2) DOTO scripts, if you enjoy it please leave a thanks on my thread :) 
--
--   Useful Information
--   ➦ AutoNapalm will target closest enemy within range
--   ➦ AutoBlinkCombo will target enemy hero closest to mouse position
--   ➦ AutoBlinkCombo will temporarily disable AutoNapalm until it finishes the combo
--   ➦ Change Hotkeys in the script-config of Ensage
--   
--   ➦ If you are here to change the text location ingame, just scroll down to line 47 and it will explain :)
--
--                                   And again, thanks for using my script!
--
--                                             ●▬▬▬▬ஜ۩۞۩ஜ▬▬▬▬● 
--
--
--
--
--
--Libraries (Utils (Should be self explanatory), ScriptConfig for the.. well.. Script Config, and TargetFind so I can use the term "GetClosestToMouse")  
require("libs.Utils")
require("libs.ScriptConfig")
require("libs.TargetFind")

--Config (Setting Parameters like a BEAST)
config = ScriptConfig.new()
config:SetParameter("toggleKey", "D", config.TYPE_HOTKEY)
config:SetParameter("BlinkComboKey", "F", config.TYPE_HOTKEY)
config:Load()

--Some variables we gotta set (Well we don't have to, just makes our lives easier) 
local toggleKey     = config.toggleKey
local BlinkComboKey = config.BlinkComboKey
local registered	= false
local range 		= 1200
--random space
local target	    = nil
local active	    = false
local BlinkActive = false

--Text ingame (If you wanna set the location of the text then change the numbers on the line under this one)
local x,y = 1150, 50
local monitor = client.screenSize.x/1600
local F14 = drawMgr:CreateFont("F14","Franklin Gothic Medium",17,800) 
local statusText = drawMgr:CreateText(x*monitor,y*monitor,-1,"Batrider - AutoNapalm Disabled! - (" .. string.char(toggleKey) .. ")   AutoBlinkCombo - (" .. string.char(BlinkComboKey) .. ")",F14) statusText.visible = false

--When you start the game
function onLoad()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me or me.classId ~= CDOTA_Unit_Hero_Batrider then 
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

--What pressing a key does
function Key(msg,code)
	if client.chat or client.console or client.loading then return end
	
    if IsKeyDown(toggleKey) then
		active = not active
		if active then
			statusText.text = "Batrider - AutoNapalm Activated! - (" .. string.char(toggleKey) .. ")   AutoBlinkCombo - (" .. string.char(BlinkComboKey) .. ") "
		else
			statusText.text = "Batrider - AutoNapalm Disabled! - (" .. string.char(toggleKey) .. ")   AutoBlinkCombo - (" .. string.char(BlinkComboKey) .. ") "
		end
	end	
	
	if code == BlinkComboKey then
		BlinkActive = true
	end
	
end

--Where everything pretty much is (It just AutoMagically works, take my word for it)
function Main(tick)
	if not SleepCheck() then return end

	local me = entityList:GetMyHero()
	if not me then return end
	local Napalm = me:GetAbility(1)
	
--AutoNapalm (FindTarget is further down, this casts the spell once target is found)
	FindTarget()
    	if target and me.alive and active and not me:IsChanneling() and not BlinkActive then
	        if Napalm and Napalm:CanBeCasted() then
		        CastSpell(Napalm,target.position)
		        Sleep(500)
				return
		    end
     	end

--Gets the victim then initiates the Blink Combo
	local victim = targetFind:GetClosestToMouse(100)
        local blink = me:FindItem("item_blink")
	local firefly = me:GetAbility(3)
	local lasso = me:GetAbility(4)
	local distance = GetDistance2D(me,victim)
	if victim and BlinkActive and me.alive and distance < range then
        if blink and blink:CanBeCasted() then
		    me:CastAbility(firefly)
	    	me:CastAbility(blink,victim.position)
		    me:CastAbility(Napalm,victim.position)
		    me:CastAbility(lasso,victim)
			BlinkActive = false
		end
		Sleep(200)
	    return
	else
	    return
	end
	    
end

--Some random function which I never actually needed to use
function CastSpell(spell,victim)
	if spell.state == LuaEntityAbility.STATE_READY then
		entityList:GetMyPlayer():UseAbility(spell,victim)
	end
end

--Find Targets for AutoNapalm 
function FindTarget()
	local me = entityList:GetMyHero()
	local enemies = entityList:FindEntities({type=LuaEntity.TYPE_HERO,team = me:GetEnemyTeam(),alive=true,visible=true})
	local napalmenemy
	for i,v in ipairs(enemies) do
		distance = GetDistance2D(v,me)
		if distance <= 700 then 
			if napalmenemy == nil then
		        napalmenemy = v
			elseif distance < GetDistance2D(napalmenemy,me) then
			    napalmenemy = v
		    end
		end
	end
	target = napalmenemy
end

--When the game ends 
function onClose()
	collectgarbage("collect")
	if registered then
	    statusText.visible = false
		script:UnregisterEvent(Main)
		script:UnregisterEvent(Key)
		registered = false
	end
end

--No idea, everyone else just had it (I'm kidding, these just register the events as their names suggest)
script:RegisterEvent(EVENT_CLOSE,onClose)
script:RegisterEvent(EVENT_TICK,onLoad)
