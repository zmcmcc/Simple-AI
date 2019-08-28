-----------------
--英雄：小小
--技能：抓树
--键位：E
--类型：指向树木
--作者：Halcyon
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('tiny_craggy_exterior')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;

nKeepMana = 180 --魔法储量
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
        bot:ActionQueue_UseAbilityOnTree(ability, castTarget) --使用技能
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
       or ability:IsHidden()
	then
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end
	
	-- Get some of its values
	local nCastRange = ability:GetCastRange();
    local nSkillLV   = ability:GetLevel();
    
    local nearbyTrees = NearbyTrees(nCastRange + 600);
    if not J.IsInTeamFight(bot, 1600)
       and not J.IsGoingOnSomeone(bot)
       and not J.IsRetreating(bot)
       and nearbyTrees ~= nil
       and nearbyTrees
    then
        return BOT_ACTION_DESIRE_MODERATE, nearbyTrees
    end
    nearbyTrees = NearbyTrees(nCastRange);
    if not J.IsRetreating(bot)
       and nearbyTrees ~= nil
       and nearbyTrees
    then
        return BOT_ACTION_DESIRE_HIGH, nearbyTrees
    end

	return BOT_ACTION_DESIRE_NONE, 0;
	
end

--获取最近的树
function NearbyTrees(Range)
    local nearbyTreesList = bot:GetNearbyTrees(Range)
    local nearestTree = nil

    for _,tree in pairs(nearbyTreesList) do
        if nearestTree == nil 
           or GetUnitToLocationDistance(bot, GetTreeLocation(tree)) < GetUnitToLocationDistance(bot, GetTreeLocation(nearestTree))
        then
            nearestTree = tree
        end
    end

    if nearestTree ~= nil then
        return nearestTree
    end

    return false
end

return X;