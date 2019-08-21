-----------------
--英雄：痛苦女王
--技能：超声冲击波
--键位：R
--类型：指向地点
--作者：Halcyon
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('queenofpain_sonic_wave')
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
	if castTarget ~= nil then
		X.Compensation() 
		bot:ActionQueue_UseAbilityOnLocation( ability, castTarget ) --使用技能
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

    -- 获取一些必要参数
	local nCastRange  = ability:GetCastRange() - 40;	--施法范围
	local nCastPoint  = ability:GetCastPoint();	--施法点
	local nManaCost   = ability:GetManaCost();		--魔法消耗
    local nSkillLV    = ability:GetLevel();    	--技能等级
    local nRadius     = ability:GetSpecialValueInt("area_of_effect");
    local nDamage     = 250 + (90 * nSkillLV);	--技能伤害

	local nEnemysHerosInRange = bot:GetNearbyHeroes(nCastRange,true,BOT_MODE_NONE);--获得施法范围内敌人

    local target  = J.GetProperTarget(bot);

    -----------
    --策略部分
    -----------

    --撤退时保护自己
    if J.IsRetreating(bot) 
        and #nEnemysHerosInRange > 0
        and bot:WasRecentlyDamagedByAnyHero(2.0)
    then
        --获取最佳释放点
        local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius * 1.2, nCastPoint, 0 );
        if locationAoE.count >= 1 and #nEnemysHerosInRange >= 1
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
    end

    --对线守塔
    if J.IsPushing(bot) or J.IsDefending(bot)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0 );
		if locationAoE.count >= 2
		then
			local hTrueHeroList = J.GetEnemyList(bot,1200);
			if #hTrueHeroList >= 2
			then
				return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
			end
		end
    end

    --团战
    if J.IsInTeamFight(bot, 1300)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0 );
		if locationAoE.count >= 1
		then
			local hTrueHeroList = J.GetEnemyList(bot,1300);
			if #hTrueHeroList >= 1
			then
				return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
			end
		end
	end
    
    --打架时先手	
    if J.IsGoingOnSomeone(bot)
    then
        if J.IsValidHero(target) 
		   and target:GetHealth() > 600
		   and J.IsInRange(target, bot, nCastRange -100) 
		then
			local targetAllies = target:GetNearbyHeroes(2 * nRadius, false, BOT_MODE_NONE);
			if #targetAllies >= 2 or J.IsInRange(target, bot, 600) 
			then
				return BOT_ACTION_DESIRE_HIGH, target:GetExtrapolatedLocation(nCastPoint);
			end
		end
    end
	
	return 0;
end

return X;