--<< SpiritBreaker Auto Charge to Escape >>

--This is my first real script, please enjoy :)

--Libraries
require("libs.ScriptConfig")

--Config
config = ScriptConfig.new()
config:SetParameter("EscapeKey", "B", config.TYPE_HOTKEY)
config:Load()

local EscapeKey = config.EscapeKey
local registered	= false
local range 		= 50000

local target	    = nil
local active	    = false

--Text on your screen
local x,y = 1420, 50
local monitor = client.screenSize.x/1600
local F14 = drawMgr:CreateFont("F14","Verdana",15*monitor,550*monitor) 
local statusText = drawMgr:CreateText(x*monitor,y*monitor,-1,"AutoSBEscape - Hotkey: ''"..string.char(EscapeKey).."''",F14) statusText.visible = false

function onLoad()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me or me.classId ~= CDOTA_Unit_Hero_SpiritBreaker then
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
	if code == EscapeKey then
		active = (msg == KEY_DOWN)
	end
end

function Main(tick)
	if not SleepCheck() then return end

	local me = entityList:GetMyHero()
	local myPlayer = entityList:GetMyPlayer().selection[1]
	if not (me and active) then return end

	local Charge = me:GetAbility(1)
	local enemies = entityList:GetEntities({type=LuaEntity.TYPE_CREEP, visible = true, alive = true, team = me:GetEnemyTeam(), illusion=false})

	for i,v in ipairs(enemies) do
		local distance = GetDistance2D(v,me)

		if not target and distance < range then
			target = v
		elseif distance > range then
			target = nil
		end

		if target then
			if target.alive and target.visible and target.classId ~= CDOTA_BaseNPC_Creep_Siege then
				if distance > GetDistance2D(target,me) then
					target = v
				end
			else
				target = nil
			end
		end
	end

	if target and me.alive then
		if myPlayer and myPlayer.handle == me.handle then
			CastSpell(Charge,target)
		return
		end
	end
end

function CastSpell(spell,victim)
	if spell.state == LuaEntityAbility.STATE_READY then
		entityList:GetMyPlayer():UseAbility(spell,victim)
	end
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
