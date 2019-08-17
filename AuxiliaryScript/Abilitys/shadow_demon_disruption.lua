-----------------
--技能：崩裂禁锢
--键位：Q
--类型：指向目标
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('shadow_demon_disruption')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;

nKeepMana = 300 --魔法储量
nLV = bot:GetLevel(); --当前英雄等级
nMP = bot:GetMana()/bot:GetMaxMana(); --目前法力值/最大法力值（魔法剩余比）
nHP = bot:GetHealth()/bot:GetMaxHealth();--目前生命值/最大生命值（生命剩余比）
hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内敌人
hAlleyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内队友

--获取以太棱镜施法距离加成
local aether = J.IsItemAvailable("item_aether_lens");
if aether ~= nil then aetherRange = 250 else aetherRange = 0 end

--初始化函数库
U.init(nLV, nMP, nHP, bot);

--技能释放功能
function X.Release(castTarget,compensation)
    if castTarget ~= nil then
        if compensation then X.Compensation() end
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
    if ability ~= nil
       and not ability:IsFullyCastable()
	then 
		return BOT_ACTION_DESIRE_NONE, 0, 0; --没欲望
	end
	
	local nSkillLV    = ability:GetLevel(); 
	local nCastRange  = ability:GetCastRange() + aetherRange

	local nInRangeEnemyHeroList = bot:GetNearbyHeroes(nCastRange + 200, true, BOT_MODE_NONE);
	local hAllyList = bot:GetNearbyHeroes(nCastRange + 200,false,BOT_MODE_NONE)
	
    --逃跑时对受到伤害的队友释放
    -- 待补充：
    -- 针对可以安全逃脱的队友，不应该强行留住，需增加判断
    for _,myFriend in pairs(hAllyList) do
		if ( J.IsRetreating(bot) and myFriend:WasRecentlyDamagedByAnyHero(2.0) and J.CanCastOnNonMagicImmune(myFriend) ) or J.IsDisabled(false, myFriend)
		then
			return BOT_ACTION_DESIRE_MODERATE, myFriend;
		end
	end	
	
    --打断敌人施法
    for _,npcEnemy in pairs( nInRangeEnemyHeroList )
	do
		if ( npcEnemy:IsChanneling() and J.CanCastOnNonMagicImmune(npcEnemy) ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	
    -- 逃跑时困住追击的敌人
	if J.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE ); --技能范围内的敌人
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and J.CanCastOnNonMagicImmune(npcEnemy) ) --如果这个敌人在2秒内打过我并且可以被控制 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end

    -- 在团战中，如果敌方在技能可触及范围（技能范围 + 200）内有高伤害英雄，尝试关他
    if J.IsInTeamFight(bot, 1200)
	then
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;

		for _,npcEnemy in pairs( nInRangeEnemyHeroList )
		do
			if ( J.CanCastOnNonMagicImmune(npcEnemy) and not J.IsDisabled(true, npcEnemy) )
			then
				local nDamage = npcEnemy:GetEstimatedDamageToTarget( false, bot, 3.0, DAMAGE_TYPE_ALL );
				if ( nDamage > nMostDangerousDamage )
				then
					nMostDangerousDamage = nDamage;
					npcMostDangerousEnemy = npcEnemy;
				end
			end
		end

		if ( npcMostDangerousEnemy ~= nil  )
		then
			return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy;
		end
	end

    -- 追杀时
	if  J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if J.IsValidHero(npcTarget) and J.CanCastOnNonMagicImmune(npcTarget) and J.IsInRange(npcTarget, bot, nCastRange + 200) and
		   not J.IsDisabled(true, npcTarget)
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X;