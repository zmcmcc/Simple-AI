-----------------
--英雄：帕克
--技能：新月之痕
--键位：W
--类型：无目标
--作者：Halcyon
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('puck_waning_rift')
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
		return BOT_ACTION_DESIRE_NONE; --没欲望
	end
	
	-- Get some of its values
	local nRadius    = ability:GetSpecialValueInt( "radius" );
	local nCastPoint = ability:GetCastPoint( );
	local nManaCost  = ability:GetManaCost( );
	
	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );

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
	
	-- If We're pushing or defending
	if J.IsPushing(bot) 
	   or J.IsDefending(bot) 
	   or ( J.IsGoingOnSomeone(bot) and nLV >= 6 ) 
	then
		local tableNearbyEnemyCreeps = bot:GetNearbyLaneCreeps( nRadius, true );
		if ( tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 1 and J.IsAllowedToSpam(bot, nManaCost) ) then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if J.IsFarming(bot) and nLV > 5
	   and J.IsAllowedToSpam(bot, nManaCost)
	then
		local npcTarget = J.GetProperTarget(bot);
		if J.IsValid(npcTarget)
		   and npcTarget:GetTeam() == TEAM_NEUTRAL
		then
			if npcTarget:GetHealth() > bot:GetAttackDamage() * 2.28
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		
			local nCreeps = bot:GetNearbyCreeps(nRadius, true);
			if ( #nCreeps >= 2 ) 
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	if J.IsInTeamFight(bot, 1200)
	then
		if #tableNearbyEnemyHeroes >= 1 
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = J.GetProperTarget(bot);
		if J.IsValidHero(npcTarget) 
		   and J.CanCastOnMagicImmune(npcTarget) 
		   and J.IsInRange(npcTarget, bot, nRadius-100)
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
		
		if J.IsValidHero(npcTarget) 
		   and J.IsAllowedToSpam(bot, nManaCost) 
		   and J.CanCastOnNonMagicImmune(npcTarget) 
		   and J.IsInRange(npcTarget, bot, nRadius) 
		then
			local nCreeps = bot:GetNearbyCreeps(800,true);
			if #nCreeps >= 1
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
    
	return BOT_ACTION_DESIRE_NONE;

end

return X;