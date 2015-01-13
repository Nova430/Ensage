--<<Batrider AutoNapalm and Firefly ➟ Blink ➟ Napalm ➟ Lasso Combo >>

--Libraries
require("libs.Utils")
require("libs.ScriptConfig")
require("libs.TargetFind")

--Config
config = ScriptConfig.new()
config:SetParameter("toggleKey", "F", config.TYPE_HOTKEY)
config:SetParameter("BlinkComboKey", "D", config.TYPE_HOTKEY)
config:Load()

local toggleKey     = config.toggleKey
local BlinkComboKey = config.BlinkComboKey
local registered	= false
local range 		= 1200

local target	    = nil
local active	    = false
local BlinkActive = false

--Text on your screen
local x,y = 1150, 50
local monitor = client.screenSize.x/1600
local F14 = drawMgr:CreateFont("F14","Verdana",16*monitor,550*monitor) 
local statusText = drawMgr:CreateText(x*monitor,y*monitor,-1,"Batrider - Disabled, PRESS (" .. string.char(toggleKey) .. ")",F14) statusText.visible = false

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

function Key(msg,code)
	if client.chat or client.console or client.loading then return end
	
    if IsKeyDown(toggleKey) then
		active = not active
		if active then
			statusText.text = "Batrider - AutoNapalm Activated! - " .. string.char(toggleKey) .. "   AutoBlinkCombo - HOLD " .. string.char(BlinkComboKey) .. " "
		else
			statusText.text = "Batrider - AutoNapalm Disabled! - " .. string.char(toggleKey) .. "   AutoBlinkCombo - HOLD " .. string.char(BlinkComboKey) .. " "
		end
	end	
	
	if code == BlinkComboKey then
		BlinkActive = (msg == KEY_DOWN)
	end
	
end

function Main(tick)
	if not SleepCheck() then return end

	local me = entityList:GetMyHero()
	if not me then return end
	local Napalm = me:GetAbility(1)
	
	FindTarget()
	
	if target and me.alive and active and not me:IsChanneling() then
	    if Napalm and Napalm:CanBeCasted() and not BlinkActive then
		    CastSpell(Napalm,target.position)
		    return
		end
		Sleep(200)
		return
	end
	
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
		end
		Sleep(200)
	    return
	else
	    return
	end
	    
end

function CastSpell(spell,victim)
	if spell.state == LuaEntityAbility.STATE_READY then
		entityList:GetMyPlayer():UseAbility(spell,victim)
	end
end

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
