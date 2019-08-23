-----------------
--英雄：斧王
--技能：狂战士之吼
--键位：Q
--类型：无目标
--作者：Halcyon
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('axe_berserkers_call')
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
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end

    -- Get some of its values
	local nRadius    = ability:GetSpecialValueInt( "radius" );
	local nCastPoint = ability:GetCastPoint( );
	local nManaCost  = ability:GetManaCost( );
	local nSkillLV   = ability:GetLevel();
	
	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nRadius - 80, true, BOT_MODE_NONE );

	if J.IsRetreating(bot)
	then
		local tableEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableEnemyHeroes )
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

	
	--打断TP
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if J.IsValid(npcEnemy)
		   and npcEnemy:IsChanneling()
		   and npcEnemy:HasModifier('modifier_teleporting')
		   and J.CanCastOnNonMagicImmune(npcEnemy)
		   and J.CanCastOnTargetAdvanced(npcEnemy)
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
    return BOT_ACTION_DESIRE_NONE;
    
end

return X;