-----------------
--英雄：斯温
--技能：神之力量
--键位：R
--类型：无目标
--作者：决明子
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('sven_gods_strength')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList;

nKeepMana = 400 --魔法储量
nLV = bot:GetLevel(); --当前英雄等级
nMP = bot:GetMana()/bot:GetMaxMana(); --目前法力值/最大法力值（魔法剩余比）
nHP = bot:GetHealth()/bot:GetMaxHealth();--目前生命值/最大生命值（生命剩余比）
hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内敌人
hAlleyHeroList = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);--1600范围内队友

--初始化函数库
U.init(nLV, nMP, nHP, bot);

--技能释放功能
function X.Release(castTarget)
    X.Compensation()
    bot:ActionQueue_UseAbility( ability )
end

--补偿功能
function X.Compensation()
    J.SetQueuePtToINT(bot, true)--临时补充魔法，使用魂戒
end

--技能释放欲望
function X.Consider()
	-- 确保技能可以使用
    if ability == nil
	   or ability:IsNull()
       or not ability:IsFullyCastable()
	then 
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end
    
    local nEnemysHerosInBonus = bot:GetNearbyHeroes(1200,true,BOT_MODE_NONE);	
	
	--打架时先手	
	if J.IsGoingOnSomeone(bot)
	then
	    local npcTarget = J.GetProperTarget(bot);
		if J.IsValidHero(npcTarget) 
		   and ( J.GetHPR(npcTarget) > 0.25 or #nEnemysHerosInBonus >= 2 )
		   and ( J.IsInRange(npcTarget,bot,700)
				 or J.IsInRange(npcTarget,bot,npcTarget:GetAttackRange() + 80) )				  
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	--撤退时保护自己
	if bot:GetActiveMode() == BOT_MODE_RETREAT 
		and bot:DistanceFromFountain() > 800
		and nHP > 0.5
		and bot:WasRecentlyDamagedByAnyHero(3.0)
		and #nEnemysHerosInBonus >= 1
	then
		return BOT_ACTION_DESIRE_HIGH;
	end
	
    return BOT_ACTION_DESIRE_NONE;
    
end

return X;