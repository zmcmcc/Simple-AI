-----------------
--英雄：剃刀
--技能：静电连接
--键位：W
--类型：指向目标
--作者：决明子
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('razor_static_link')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;

nKeepMana = 280 --魔法储量
nLV = bot:GetLevel(); --当前英雄等级
nMP = bot:GetMana()/bot:GetMaxMana(); --目前法力值/最大法力值（魔法剩余比）
nHP = bot:GetHealth()/bot:GetMaxHealth();--目前生命值/最大生命值（生命剩余比）
hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内敌人
hAlleyHeroList = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);--1600范围内队友

--获取以太棱镜施法距离加成
local aether = J.IsItemAvailable("item_aether_lens");
if aether ~= nil then aetherRange = 250 else aetherRange = 0 end
    
--初始化函数库
U.init(nLV, nMP, nHP, bot);

--技能释放功能
function X.Release(castTarget)
    if castTarget ~= nil then
        X.Compensation()
        bot:ActionQueue_UseAbilityOnEntity( ability, castTarget ) --使用技能
    end
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
    
	local nSkillLV    = ability:GetLevel()
	local nCastRange  = ability:GetCastRange()	+ aetherRange
	local nCastPoint  = ability:GetCastPoint()
	local nManaCost   = ability:GetManaCost()
	local nDamage     = ability:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
	
	
	local nInRangeEnemyCount = 0;
	local nCastTarget = nil
	local nAttackDamageMax = 0
	for _,npcEnemy in pairs(nInRangeEnemyList)
	do
		if J.IsValidHero(npcEnemy)
		   and J.CanCastOnMagicImmune(npcEnemy)
		   and J.CanCastOnTargetAdvanced(npcEnemy)
		then
			nInRangeEnemyCount = nInRangeEnemyCount +1;
			if npcEnemy:GetAttackDamage() > nAttackDamageMax
			then
				nCastTarget = npcEnemy;
				nAttackDamageMax = npcEnemy:GetAttackDamage();
			end			
		end
	end	
	if nInRangeEnemyCount >= 2 
	   and nCastTarget ~= nil
	then
		return BOT_ACTION_DESIRE_HIGH,nCastTarget
	end
	
	
	if J.IsLaning(bot)
	then
		nCastTarget = nInRangeEnemyList[1];
		if J.IsValidHero(nCastTarget)
		   and J.CanCastOnNonMagicImmune(nCastTarget)
		   and J.CanCastOnTargetAdvanced(nCastTarget)
		   and J.IsInRange(bot,nCastTarget,nCastRange *0.93)
		then
			bot:SetTarget(nCastTarget);
			return BOT_ACTION_DESIRE_HIGH,nCastTarget
		end
	end
	
	
	if J.IsGoingOnSomeone(bot)
	   and J.IsValidHero(botTarget)
	   and J.CanCastOnNonMagicImmune(botTarget)
	   and J.CanCastOnTargetAdvanced(botTarget)
	   and J.IsInRange(bot,botTarget,nCastRange)
	   and J.GetAllyCount(bot,1200) - J.GetEnemyCount(bot,1600) < 3
	then	
		return BOT_ACTION_DESIRE_HIGH,botTarget
	end
	
	
	if J.IsRetreating(bot)
	then
		for _,npcEnemy in pairs(nInRangeEnemyList)
		do
			if J.IsValidHero(npcEnemy)
			   and J.CanCastOnMagicImmune(npcEnemy)
			   and J.CanCastOnTargetAdvanced(npcEnemy)
			   and ( bot:WasRecentlyDamagedByHero(npcEnemy,3.0) or bot:GetActiveModeDesire() > BOT_MODE_DESIRE_VERYHIGH )
			then
				return BOT_ACTION_DESIRE_HIGH,npcEnemy
			end
		end
	end
	
	--通用
	if (#hEnemyList > 0 or bot:WasRecentlyDamagedByAnyHero(3.0)) 
		and ( bot:GetActiveMode() ~= BOT_MODE_RETREAT or #hAllyList >= 2 )
		and #nInRangeEnemyList >= 1
		and nLV >= 15
	then
		for _,npcEnemy in pairs( nInRangeEnemyList )
		do
			if  J.IsValid(npcEnemy)
				and J.IsInRange(bot,npcEnemy,nCastRange - 100)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and J.CanCastOnTargetAdvanced(npcEnemy)				
			then
				return BOT_ACTION_DESIRE_HIGH,npcEnemy
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X;