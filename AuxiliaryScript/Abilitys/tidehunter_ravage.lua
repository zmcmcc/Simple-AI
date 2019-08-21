-----------------
--英雄：潮汐猎人
--技能：毁灭
--键位：R
--类型：无目标
--作者：Halcyon
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('tidehunter_ravage')
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
    if castTarget ~= nil then
        local blink = IsItemAvailable("item_blink");
        if blink ~= nil and blink:IsFullyCastable() then
            bot:Action_UseAbilityOnLocation(blink, castTarget);
            bot:ActionQueue_UseAbility( ability )
        end
    else
        bot:ActionQueue_UseAbility( ability )
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
    
    local nCastPoint = ability:GetCastPoint();
    local manaCost   = ability:GetManaCost();
    local nRadius    = ability:GetAOERadius();
    local nCastRange = 1000;
    local hTrueHeroList = bot:GetNearbyHeroes(nRadius,true,BOT_MODE_NONE);

    -- If we're going after someone
    if J.IsGoingOnSomeone(bot)
    then
        local npcTarget = J.GetProperTarget(bot);
        if J.IsValidHero(npcTarget) 
        and J.CanCastOnMagicImmune(npcTarget) 
        and J.IsInRange(npcTarget, bot, nCastRange + 200) 
        then
            if #hTrueHeroList >= 2 then
                return BOT_ACTION_DESIRE_HIGH, nil;
            end	
        end
    end

    local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange + nRadius, nRadius, 0, 0 );
    local blink = IsItemAvailable("item_blink");
    if blink ~= nil and blink:IsFullyCastable() then
        if locationAoE.count >= 2
            or locationAoE.count >= 3
        then
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
        if locationAoE.count >= 1 and J.GetHPR(bot) < 0.38
        then
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
    end
    if #hTrueHeroList >= 3 then
        return BOT_ACTION_DESIRE_HIGH, nil;
    end	
	
    return BOT_ACTION_DESIRE_NONE;
    
end

function IsItemAvailable(item_name)
    local slot = bot:FindItemSlot(item_name)
	
	if slot >= 0 and slot <= 5 then
		return bot:GetItemInSlot(slot);
	end
	
    return nil;
end

return X;