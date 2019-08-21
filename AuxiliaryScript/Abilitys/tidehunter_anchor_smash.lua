-----------------
--英雄：潮汐猎人
--技能：锚击
--键位：E
--类型：无目标
--作者：Halcyon
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('tidehunter_anchor_smash')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList;

nKeepMana = 180 --魔法储量
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

    local abilityR = bot:GetAbilityByName('tidehunter_ravage') 
    if abilityR == nil 
       or U.ManaR(abilityR ,ability:GetManaCost())
    then
        bot:ActionQueue_UseAbility( ability ) --使用技能
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

    -- Get some of its values
    local nRadius    = ability:GetSpecialValueInt( "radius" );
    local nCastPoint = ability:GetCastPoint( );
    local nManaCost  = ability:GetManaCost( );
    local nSkillLV   = ability:GetLevel();
    local nDamage    = 15 + 40 * nSkillLV;

    local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nRadius - 80, true, BOT_MODE_NONE );

    -- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
    if J.IsRetreating(bot) and #tableNearbyEnemyHeroes > 0
    then
        for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
        do
            if bot:WasRecentlyDamagedByHero( npcEnemy, 1.0 )
            then
                return BOT_ACTION_DESIRE_MODERATE;
            end
        end
    end

    -- If we're doing Roshan
    if ( bot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
    then
        local npcTarget = bot:GetAttackTarget();
        if ( J.IsRoshan(npcTarget) and J.CanCastOnMagicImmune(npcTarget) and J.IsInRange(bot, npcTarget, nRadius - 80)  )
        then
            return BOT_ACTION_DESIRE_MODERATE;
        end
    end

    -- If We're pushing or defending
    if J.IsPushing(bot) or J.IsDefending(bot) or J.IsGoingOnSomeone(bot)
    then
        local tableNearbyEnemyCreeps = bot:GetNearbyLaneCreeps( nRadius - 80, true );
        if ( tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 1 and J.IsAllowedToSpam(bot, nManaCost) ) then
            for _,npcEnemyCreeps in pairs( tableNearbyEnemyCreeps )
            do
                if npcEnemyCreeps:GetHealth() <= nDamage or #tableNearbyEnemyCreeps >= 5 then
                    return BOT_ACTION_DESIRE_MODERATE;
                end
            end
        end
    end

    if J.IsInTeamFight(bot, 1200)
    then
        if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 then
            return BOT_ACTION_DESIRE_LOW;
        end
    end

    -- If we're going after someone
    if J.IsGoingOnSomeone(bot)
    then
        local npcTarget = J.GetProperTarget(bot);
        if J.IsValidHero(npcTarget) and J.CanCastOnMagicImmune(npcTarget) and J.IsInRange(npcTarget, bot, nRadius-100)
        then
            return BOT_ACTION_DESIRE_MODERATE;
        end
    end
	
    return BOT_ACTION_DESIRE_NONE;
    
end

return X;