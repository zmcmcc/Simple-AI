-----------------
--英雄：殁境神蚀者
--技能：星体禁锢
--键位：W
--类型：指向目标
--作者：Halcyon
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('obsidian_destroyer_astral_imprisonment')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;

nKeepMana = 400 --魔法储量
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
       or not ability:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end
	
	-- Get some of its values
    local nCastRange = ability:GetCastRange();
    local nDamage = ability:GetSpecialValueInt("damage");
    --------------------------------------
    -- Mode based usage
    --------------------------------------
    -- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
    if J.IsRetreating(bot) 
    then
        local tableNearbyAllyHeroes = bot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
        if tableNearbyAllyHeroes ~= nil and #tableNearbyAllyHeroes == 2 
        then
            return BOT_ACTION_DESIRE_HIGH, bot;
        else
            local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange+200, true, BOT_MODE_NONE );
            for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
            do
                if ( bot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) and J.CanCastOnNonMagicImmune(npcEnemy) ) 
                then
                    return BOT_ACTION_DESIRE_HIGH, npcEnemy;
                end
            end
        end
    end

    local tableNearbyFriendlyHeroes = bot:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
    for _,myFriend in pairs(tableNearbyFriendlyHeroes) 
    do
        if  myFriend:GetUnitName() ~= bot:GetUnitName() and J.IsRetreating(myFriend) and
            myFriend:WasRecentlyDamagedByAnyHero(2.0) and J.CanCastOnNonMagicImmune(myFriend)
        then
            return BOT_ACTION_DESIRE_MODERATE, myFriend;
        end
    end	

    -- Check for a channeling enemy
    local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
    for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
    do
        if ( J.CanKillTarget(npcEnemy, nDamage, DAMAGE_TYPE_MAGICAL) or npcEnemy:IsChanneling() ) and J.CanCastOnNonMagicImmune( npcEnemy ) 
            and not J.IsDisabled(true, npcEnemy) 
        then
            return BOT_ACTION_DESIRE_HIGH, npcEnemy;
        end
    end

    if J.IsInTeamFight(bot, 1200)
    then
        local npcMostDangerousEnemy = nil;
        local nMostDangerousDamage = 0;
        local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
        for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
        do
            if J.CanCastOnNonMagicImmune( npcEnemy ) and not J.IsDisabled(true, npcEnemy) 
            then
                local nDamage = npcEnemy:GetEstimatedDamageToTarget( false, bot, 3.0, DAMAGE_TYPE_ALL );
                if ( nDamage > nMostDangerousDamage )
                then
                    nMostDangerousDamage = nDamage;
                    npcMostDangerousEnemy = npcEnemy;
                end
            end
        end

        if ( npcMostDangerousEnemy ~= nil )
        then
            return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy;
        end
    end

    -- If we're going after someone
    if J.IsGoingOnSomeone(bot)
    then
        local npcTarget = bot:GetTarget();
        if J.IsValidHero(npcTarget) and J.CanCastOnNonMagicImmune(npcTarget) and not J.IsInRange(npcTarget, bot, (nCastRange+200)/2) and J.IsInRange(npcTarget, bot, nCastRange+200) and
            not J.IsDisabled(true, npcTarget) 
        then
            local allies = npcTarget:GetNearbyHeroes(450, true, BOT_MODE_NONE);
            if #allies <= 1 then
                return BOT_ACTION_DESIRE_HIGH, npcTarget;
            end	
        end
    end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X;