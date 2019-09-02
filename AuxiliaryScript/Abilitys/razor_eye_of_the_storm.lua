-----------------
--英雄：剃刀
--技能：风暴之眼
--键位：R
--类型：无目标
--作者：决明子
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('razor_eye_of_the_storm')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange, abilityAhg;

nKeepMana = 280 --魔法储量
nLV = bot:GetLevel(); --当前英雄等级
nMP = bot:GetMana()/bot:GetMaxMana(); --目前法力值/最大法力值（魔法剩余比）
nHP = bot:GetHealth()/bot:GetMaxHealth();--目前生命值/最大生命值（生命剩余比）
hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内敌人
hAlleyHeroList = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);--1600范围内队友

--是否拥有蓝杖
abilityAhg = J.IsItemAvailable("item_ultimate_scepter"); 

--获取以太棱镜施法距离加成
local aether = J.IsItemAvailable("item_aether_lens");
if aether ~= nil then aetherRange = 250 else aetherRange = 0 end
    
--初始化函数库
U.init(nLV, nMP, nHP, bot);

--技能释放功能
function X.Release(castTarget)
	bot:ActionQueue_UseAbility( ability ) --使用技能
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
		return BOT_ACTION_DESIRE_NONE; --没欲望
	end
    
    local nSkillLV    = ability:GetLevel(); 
	local nCastRange  = 500
	local nCastPoint  = ability:GetCastPoint();
	local nManaCost   = ability:GetManaCost();
	local nDamage     = ability:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_PHYSICAL
	local nInRangeEnemyList = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
	local nDamageCount = 0;
	
	for _,npcEnemy in pairs(nInRangeEnemyList)
	do
		if J.IsValidHero(npcEnemy)
		   and J.CanCastOnMagicImmune(npcEnemy)
		then
			nDamageCount = nDamageCount +1;
		end
	end
	
	
	if nDamageCount >= 2 
	then
	    return BOT_ACTION_DESIRE_HIGH
	end	
	
	
	if J.IsGoingOnSomeone(bot)
	   and J.IsValidHero(botTarget)
	   and J.IsInRange(bot,botTarget,nCastRange)
	   and J.CanCastOnMagicImmune(botTarget)
	   and ( J.GetProperTarget(botTarget) ~= nil or J.IsInRange(bot,botTarget,nCastRange *0.6) )
	   and J.GetAllyCount(bot,1600) - J.GetEnemyCount(bot,1600) < 2
	then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	
	if J.IsRetreating(bot)
	then
		for _,npcEnemy in pairs(nInRangeEnemyList)
		do
			if J.IsValidHero(npcEnemy)
			   and J.CanCastOnMagicImmune(npcEnemy)
			   and ( bot:WasRecentlyDamagedByHero(npcEnemy,2.0) or bot:GetActiveModeDesire() > BOT_MODE_DESIRE_VERYHIGH )
			then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end

return X;