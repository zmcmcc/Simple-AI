-----------------
--英雄：幻影刺客
--技能：魅影无形
--键位：E
--类型：无目标
--作者：决明子
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('phantom_assassin_blur')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange, abilityAhg;

nKeepMana = 400 --魔法储量
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
    local nEnemyTowers = bot:GetNearbyTowers(878,true);

	-- 确保技能可以使用
    if ability == nil
	   or ability:IsNull()
       or not ability:IsFullyCastable()
       or bot:IsInvisible() 
	   or #nEnemyTowers >= 1 
	   or bot:DistanceFromFountain() < 600
	then 
		return BOT_ACTION_DESIRE_NONE; --没欲望
	end
    
    -- 撤退逃跑
	if J.IsRetreating(bot) 
        and bot:WasRecentlyDamagedByAnyHero(3.1)
        and ( nLV >= 6 or nHP <= 0.3 )
    then
        local nEnemysHerosInRange = bot:GetNearbyHeroes(740,true,BOT_MODE_NONE);
        if #nEnemysHerosInRange == 0
        then
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    -- 过河道接近敌方基地
    if J.IsInEnemyArea(bot) and nLV >= 7
    then
        local nEnemies = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
        local nAllies  = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
        local nEnemyTowers = bot:GetNearbyTowers(1600,true);
        if #nEnemies == 0 and #nAllies <= 2 and nEnemyTowers == 0
        then
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    --低血量打远古
    if J.IsFarming(bot)
    then
        local nTarget = J.GetProperTarget(bot);
        if  J.IsValid(nTarget)
            and ( nTarget:IsAncientCreep() or nHP < 0.28 )
            and nHP <= 0.58 
        then
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

	return BOT_ACTION_DESIRE_NONE;

end

return X;