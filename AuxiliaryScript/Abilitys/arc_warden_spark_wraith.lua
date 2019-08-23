-----------------
--英雄：天穹守望者
--技能：磁场
--键位：E
--类型：闪光幽魂
--作者：决明子
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('arc_warden_spark_wraith')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;

nKeepMana = 300 --魔法储量
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
    
    local nRadius = ability:GetSpecialValueInt( "radius" );
	local nCastRange = ability:GetCastRange();
	local nDamage = ability:GetSpecialValueInt("spark_damage");
	local nDelay = ability:GetSpecialValueInt("activation_delay");

	
	-- If a mode has set a target, and we can kill them, do it
	local npcTarget = J.GetProperTarget(bot);
	if J.IsValidHero(npcTarget) 
	   and J.CanCastOnNonMagicImmune(npcTarget)
	then
		if J.CanKillTarget(npcTarget, nDamage, DAMAGE_TYPE_MAGICAL) 
		   and J.IsInRange(npcTarget, bot, nCastRange) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nDelay - 0.3 )
		end
	end

	
	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = bot:GetAttackTarget();
		if J.IsRoshan(npcTarget) 
		   and J.IsInRange(npcTarget, bot, nCastRange) 
		   and J.GetHPR(npcTarget) > 0.2
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetLocation();
		end
	end
	
	
	if J.IsInTeamFight(bot, 1200)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), 1000, nRadius, 0, 0 );
		if locationAoE.count >= 2
		then
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
		end
	end
	
	
	if J.IsGoingOnSomeone(bot)
	then
	
		if J.IsValidHero(npcTarget) 
		   and J.CanCastOnNonMagicImmune(npcTarget) 
		   and J.IsInRange(npcTarget, bot, nCastRange)
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nDelay - 0.3 );
		end
		
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), 1400, nRadius, 2.0, 0 );
		if locationAoE.count >= 1 
		   and not bot:HasModifier("modifier_silencer_curse_of_the_silent")
		then
			local nCreep = J.GetVulnerableUnitNearLoc(false, true, 1600, nRadius, locationAoE.targetloc, bot);
			if nCreep == nil 
			   or bot:HasModifier("modifier_arc_warden_tempest_double")
			then
				return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
			end
		end
		
	end	
	
	-- if we're Retreat
	if J.IsRetreating(bot) 
	   and bot:GetActiveModeDesire() > BOT_ACTION_DESIRE_HIGH
	   and not bot:HasModifier("modifier_silencer_curse_of_the_silent")
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes(800,true,BOT_MODE_NONE);
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( J.IsValid(npcEnemy) and bot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) and J.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, bot:GetLocation();
			end
		end
	end
	
	-- if we're farming
	if bot:GetActiveMode() == BOT_MODE_FARM
	   or J.IsPushing(bot)
	   or J.IsDefending(bot)
	then
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), 1400, nRadius, 2.0, 0 );
		if locationAoE.count > 2
			and not bot:HasModifier("modifier_silencer_curse_of_the_silent")
		then
			if bot:HasModifier("modifier_arc_warden_tempest_double")
			then
				return BOT_ACTION_DESIRE_HIGH,locationAoE.targetloc;
			end
			
			local nLaneCreeps = bot:GetNearbyLaneCreeps(1400,true);
			if #nLaneCreeps >= 2
			then
				if J.GetMPR(bot) > 0.62
				then
					return BOT_ACTION_DESIRE_HIGH,locationAoE.targetloc;
				end
			else
				if J.GetMPR(bot) > 0.75
				then
					return BOT_ACTION_DESIRE_HIGH,locationAoE.targetloc;
				end
			end
		end
	
	end
	
	
	if ability:GetLevel() >= 3 and bot:GetActiveMode() ~= BOT_MODE_LANING and J.IsAllowedToSpam(bot, 80) 
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), 1400, nRadius, 2.0, 0 );
		if locationAoE.count >= 2 then
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
		end	
	end
	
	
	if bot:GetLevel() >= 10
		and ( J.IsAllowedToSpam(bot,80) or bot:HasModifier("modifier_arc_warden_tempest_double"))
		and DotaTime() > 6 *60
	then
	
		local nEnemysHerosCanSeen = GetUnitList(UNIT_LIST_ENEMY_HEROES);
		local nTargetHero = nil;
		local nTargetHeroHealth = 99999;
		for _,enemy in pairs(nEnemysHerosCanSeen)
		do
			if J.IsValidHero(enemy)
				and GetUnitToUnitDistance(bot,enemy) <= nCastRange
				and enemy:GetHealth() < nTargetHeroHealth
			then
				nTargetHero = enemy;
				nTargetHeroHealth = enemy:GetHealth();
			end
		end
		if nTargetHero ~= nil
		then
			for i=0,350,50
			do
				local castLocation = J.GetLocationTowardDistanceLocation(nTargetHero,J.GetEnemyFountain(),350 - i);
				if GetUnitToLocationDistance(bot,castLocation) <= nCastRange
				then
					return BOT_ACTION_DESIRE_MODERATE, castLocation;
				end
			end
		end
		
		
		local nLaneCreeps = bot:GetNearbyLaneCreeps(1600,true);
		if #nLaneCreeps >= 3
		then
			local targetCreep = nLaneCreeps[#nLaneCreeps];
			if J.IsValid(targetCreep)
			then
				local castLocation = J.GetFaceTowardDistanceLocation(targetCreep,375);
				return BOT_ACTION_DESIRE_MODERATE ,castLocation;
			end
		end
		
		local nEnemyHeroesInView = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
		local nEnemyLaneFront = J.GetNearestLaneFrontLocation(bot:GetLocation(),true,nRadius/2);
		if #nEnemyHeroesInView == 0 and nEnemyLaneFront ~= nil
		   and GetUnitToLocationDistance(bot,nEnemyLaneFront) <= nCastRange + nRadius
		   and GetUnitToLocationDistance(bot,nEnemyLaneFront) >= 800
		then
			local castLocation = J.GetLocationTowardDistanceLocation(bot,nEnemyLaneFront,nCastRange)
			if GetUnitToLocationDistance(bot,nEnemyLaneFront) < nCastRange
			then
				castLocation = nEnemyLaneFront
			end			
			return BOT_ACTION_DESIRE_MODERATE ,castLocation;
		end
	end
	
	
	local castLocation = J.GetLocationTowardDistanceLocation(bot,J.GetEnemyFountain(),nCastRange)
	if  bot:HasModifier("modifier_arc_warden_tempest_double")
		or ( J.GetMPR(bot) > 0.92 and bot:GetLevel() > 11 and not IsLocationVisible(castLocation) )
		or ( J.GetMPR(bot) > 0.38 and J.GetDistanceFromEnemyFountain(bot) < 4300 )
	then
		if IsLocationPassable(castLocation)
		   and not bot:HasModifier("modifier_silencer_curse_of_the_silent")
		then
			return BOT_ACTION_DESIRE_MODERATE, castLocation;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X;