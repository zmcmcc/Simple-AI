-----------------
--英雄：撼地者
--技能：强化图腾
--键位：W
--类型：无目标
--作者：Halcyon
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('earthshaker_enchant_totem')
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
        if castTarget[1] == "loc" then
			bot:Action_UseAbilityOnLocation(ability, castTarget[2]);
		elseif castTarget[1] == "unit" then
            bot:Action_UseAbilityOnEntity(ability, castTarget[2]);
        end
    else
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
		return BOT_ACTION_DESIRE_NONE; --没欲望
	end

    local nCastRange = 0;
    if bot:HasScepter() == true then
        nCastRange = ability:GetSpecialValueInt("distance_scepter");
    end
    local nCastPoint = ability:GetCastPoint();
    local manaCost   = ability:GetManaCost();
    local nRadius    = ability:GetSpecialValueInt( "aftershock_range" );
    local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );

    if bot:HasScepter() and J.IsStuck(bot)
    then
        local loc = J.GetEscapeLoc();
        return BOT_ACTION_DESIRE_HIGH, {"loc", GetXUnitsTowardsLocation( loc, nCastRange )};
    end
    
    if J.IsRetreating(bot)
    then
        if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes > 0 then
            if bot:HasScepter() then
                local loc = J.GetEscapeLoc();
                return BOT_ACTION_DESIRE_HIGH, {"loc", GetXUnitsTowardsLocation( loc, nCastRange )};
            else
                for i=1,#tableNearbyEnemyHeroes do
                    if IsValidObject(tableNearbyEnemyHeroes[i]) and GetUnitToUnitDistance(bot, tableNearbyEnemyHeroes[i]) < nRadius then
                        return BOT_ACTION_DESIRE_HIGH;
                    end
                end
            end
        end
    end
    
    if J.IsInTeamFight(bot) and GetUnitCountWithinRadius(tableNearbyEnemyHeroes, nRadius) >= 2
    then
        if bot:HasScepter() then
            return BOT_ACTION_DESIRE_HIGH, {"unit", bot};
        else
            return BOT_ACTION_DESIRE_HIGH;
        end	
    end
    
    if ( J.IsDefending(bot) or J.IsPushing(bot) )
       and CanSpamSpell(manaCost) 
       and bot:HasModifier("modifier_earthshaker_enchant_totem") == false
       and GetUnitCountWithinRadius(bot, nRadius) >= 3 
    then
        if bot:HasScepter() then
            return BOT_ACTION_DESIRE_HIGH, {"unit", bot};
        else
            return BOT_ACTION_DESIRE_HIGH;
        end	
    end
    
    if J.IsGoingOnSomeone(bot) and bot:HasModifier("modifier_earthshaker_enchant_totem") == false
    then
        local npcTarget = bot:GetTarget();
        if J.IsValidHero(npcTarget) and J.CanCastOnNonMagicImmune(npcTarget) 
        then
            if bot:HasScepter() == false and J.IsInRange(npcTarget, bot, nRadius) then
                return BOT_ACTION_DESIRE_HIGH;
            else
                if J.IsInRange(npcTarget, bot, nRadius) == false and J.IsInRange(npcTarget, bot, nCastRange) then
                    return BOT_ACTION_DESIRE_HIGH, {"loc", npcTarget:GetLocation()};
                elseif J.IsInRange(npcTarget, bot, nRadius) then
                    return BOT_ACTION_DESIRE_HIGH, {"unit", bot};
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE;
    
end

function CanSpamSpell(manaCost)
	local initialRatio = 1.0;
	if manaCost < 100 then
		initialRatio = 0.6;
	end
	return ( bot:GetMana() - manaCost ) / bot:GetMaxMana() >= ( initialRatio - bot:GetLevel()/(2*25) );
end

function GetUnitCountWithinRadius(tUnits, radius)
	local count = 0;
	if tUnits ~= nil and #tUnits > 0 then
		for i=1,#tUnits do
			if IsValidObject(tUnits[i]) and GetUnitToUnitDistance(bot, tUnits[i]) <= radius then
				count = count + 1;
			end
		end	
	end
	return count;
end

function IsValidObject(object)
	return object ~= nil and object:IsNull() == false and object:CanBeSeen() == true;
end

function GetXUnitsTowardsLocation( vLocation, nUnits)
    local direction = Normalized((vLocation - bot:GetLocation()))
    return bot:GetLocation() + direction * nUnits
end

function Normalized(vector)
	local mod = ( vector.x ^ 2 + vector.y ^ 2 ) ^ 0.5
	return Vector(vector.x / mod, vector.y / mod)
end

return X;
