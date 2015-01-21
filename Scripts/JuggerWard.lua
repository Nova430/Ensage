--<<Juggernaut HAX(Not really)>>
--
--
--
--
--                                             ●▬▬▬▬ஜ۩۞۩ஜ▬▬▬▬●
--
-- Welcome to one of my various (4) DOTO scripts, if you enjoy it please leave a thanks on my thread :) 
--       Will Automagically move Juggernaut Healing Ward underneath you so enemy can't attack it.
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


local registered	= false
local range 		= 1500
local target	    = nil

--When you start the game
function onLoad()
	if PlayingGame() then
		local me = entityList:GetMyHero()
		if not me or me.classId ~= CDOTA_Unit_Hero_Juggernaut then 
			script:Disable()
		else
			registered = true
			script:RegisterEvent(EVENT_TICK,Main)
			script:UnregisterEvent(onLoad)
		end
	end
end


function Main(tick)
	if not SleepCheck() then return end

	local me = entityList:GetMyHero()
	mp = entityList:GetMyPlayer()
	if not me then return end
	local distance = GetDistance2D(me,ward)
	local heal = me:GetAbility(2)
	
	FindTarget()
    	if heal and heal.state == LuaEntityAbility.STATE_COOLDOWN and target then
	        MoveWard()
    	end

	
end

function MoveWard()
	local me = entityList:GetMyHero()
    local ward = entityList:FindEntities({team=me.team,alive=true,visible=true})
    for i,v in ipairs(ward) do
        if (v.name=="npc_dota_juggernaut_healing_ward") and (v.position ~= me.position) then
            v:Move(me.position)
		elseif (v.name=="npc_dota_juggernaut_healing_ward") and (v.position == me.position) then
		    return
        end 
    end
end

function FindTarget()
	local me = entityList:GetMyHero()
	local enemies = entityList:FindEntities({type=LuaEntity.TYPE_HERO,team = me:GetEnemyTeam(),alive=true,visible=true})
	local inrangetarget
	for i,v in ipairs(enemies) do
		distance = GetDistance2D(v,me)
		if distance <= range then 
			if inrangetarget == nil then
		        inrangetarget = v
			elseif distance > range then
			    inrangetarget = nil
		    end
		end
	end
	target = inrangetarget
end

function onClose()
	collectgarbage("collect")
	if registered then
		script:UnregisterEvent(Main)
		script:UnregisterEvent(Key)
		registered = false
	end
end

script:RegisterEvent(EVENT_CLOSE,onClose)
script:RegisterEvent(EVENT_TICK,onLoad)
