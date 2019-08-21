-----------------
--英雄：虚空假面
--技能：时间漫游
--键位：Q
--类型：指向地点
--作者：Halcyon
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('faceless_void_time_walk')
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
       or bot:IsRooted()
       or bot:HasModifier("modifier_faceless_void_chronosphere_speed")
	then 
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end
	
	-- Get some of its values
	local nCastRange = ability:GetSpecialValueInt("range");
	local nCastPoint = ability:GetCastPoint();
	local nAttackPoint = bot:GetAttackPoint();

	local nAllies = J.GetAllyList(bot,1200);

	local nEnemysHerosInView  = hEnemyHeroList;
	local nEnemysHerosInRange = bot:GetNearbyHeroes(nCastRange + 50,true,BOT_MODE_NONE);
	local nEnemysHerosInBonus = bot:GetNearbyHeroes(nCastRange + 150,true,BOT_MODE_NONE);

	local nEnemysTowers   = bot:GetNearbyTowers(1000, true);
	local aliveEnemyCount = J.GetNumOfAliveHeroes(true);

	local npcTarget = J.GetProperTarget(bot);

	if J.IsStuck(bot)
	then
		local loc = J.GetEscapeLoc();
		return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, loc, nCastRange );
	end
	
	if J.IsRetreating(bot) or ( bot:GetActiveMode() == BOT_MODE_RETREAT and nHP < 0.16 and bot:DistanceFromFountain() > 600 )
	then
		if J.ShouldEscape(bot) or ( bot:DistanceFromFountain() > 600 and  bot:DistanceFromFountain() < 3800 )
		then
			local loc = J.GetEscapeLoc();
			local location = J.Site.GetXUnitsTowardsLocation(bot, loc, nCastRange );
			return BOT_ACTION_DESIRE_MODERATE, location;
		end
	end

	if J.IsGoingOnSomeone(bot) and nLV >= 3 
	   and ( #nAllies >= 2 or #nEnemysHerosInView <= 1 )
	then
		if J.IsValidHero(npcTarget) 
			and not npcTarget:IsAttackImmune()
			and J.CanCastOnMagicImmune(npcTarget) 
			and not J.IsInRange(npcTarget, bot, 400) 
			and J.IsInRange(npcTarget, bot, nCastRange + 200) 
		then
			local tableNearbyEnemyHeroes = npcTarget:GetNearbyHeroes( 800, false, BOT_MODE_NONE );
			local tableNearbyAllysHeroes = npcTarget:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
			local tableAllEnemyHeroes    = J.GetAllyList(npcTarget,1600);				
			if  ( J.WillKillTarget(npcTarget, bot:GetAttackDamage() * 3, DAMAGE_TYPE_PHYSICAL, 2.0) )
				or ( #tableNearbyEnemyHeroes <= #tableNearbyAllysHeroes )
				or ( #tableAllEnemyHeroes <= 1 )
				or ( aliveEnemyCount <= 2 )
			then
				local fLocation = npcTarget:GetExtrapolatedLocation( nAttackPoint + nCastPoint );
				local bLocation = npcTarget:GetExtrapolatedLocation( nCastPoint  );
				if GetUnitToLocationDistance(bot,bLocation) < GetUnitToLocationDistance(bot,fLocation)
				then
					bLocation = fLocation;
				end
				if GetUnitToLocationDistance(bot,bLocation) < nCastRange + 150
				then
					bot:SetTarget(npcTarget);
					return BOT_ACTION_DESIRE_HIGH, bLocation;
				end
			end
		end
	end

	if J.IsInTeamFight(bot, 1200) and nHP > 0.2
	   and ( npcTarget == nil or GetUnitToUnitDistance(bot,npcTarget) > 1400 )
	then
		local npcWeakestEnemy = nil;
		local npcWeakestEnemyHealth = 10000;		
		
		for _,npcEnemy in pairs( nEnemysHerosInRange )
		do
			if  J.IsValid(npcEnemy)
				and not npcEnemy:IsAttackImmune()
			    and J.CanCastOnMagicImmune(npcEnemy)  
				and not J.IsInRange(npcEnemy, bot, 700) 
			then
				local npcEnemyHealth = npcEnemy:GetHealth();
				local tableNearbyAllysHeroes = npcEnemy:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
				if npcEnemyHealth < npcWeakestEnemyHealth 
					and ( #tableNearbyAllysHeroes >= 1 or aliveEnemyCount <= 2 )
				then
					npcWeakestEnemyHealth = npcEnemyHealth;
					npcWeakestEnemy = npcEnemy;
				end
			end
		end
		
		if ( npcWeakestEnemy ~= nil )
		then
			local fLocation = npcWeakestEnemy:GetExtrapolatedLocation( nAttackPoint + nCastPoint  );
			local bLocation = npcWeakestEnemy:GetExtrapolatedLocation( nCastPoint  );
			if GetUnitToLocationDistance(bot,bLocation) < GetUnitToLocationDistance(bot,fLocation)
			then
				bLocation = fLocation;
			end
		
			if GetUnitToLocationDistance(bot,bLocation) < nCastRange + 150
			then
				bot:SetTarget(npcWeakestEnemy);
				return BOT_ACTION_DESIRE_HIGH, bLocation;
			end
		end		
	end

	if ( bot:GetActiveMode() == BOT_MODE_LANING or nLV <= 7 )
	   and #nEnemysHerosInView == 0 and #nEnemysTowers == 0
	then
		local nLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange +80,true);
		local keyWord = "ranged";
		for _,creep in pairs(nLaneCreeps)
		do
			if J.IsValid(creep)
				and not creep:HasModifier("modifier_fountain_glyph")
				and J.IsKeyWordUnit(keyWord,creep)
				and GetUnitToUnitDistance(creep,bot) > 500
			then
				local nTime = nCastPoint + bot:GetAttackPoint() ;
				local nDamage = bot:GetAttackDamage() + 38;
				if J.WillKillTarget(creep,nDamage,DAMAGE_TYPE_PHYSICAL,nTime *0.9)
				then
					bot:SetTarget(creep);
					return BOT_ACTION_DESIRE_HIGH, creep:GetLocation();
				end				
			end
		end
		
		if nMP > 0.96
		   and bot:DistanceFromFountain() > 60 
		   and bot:DistanceFromFountain() < 6000 
		   and bot:GetAttackTarget() == nil
		   and bot:GetActiveMode() == BOT_MODE_LANING 
		then
			local nLane = bot:GetAssignedLane();
			local nLaneFrontLocation = GetLaneFrontLocation(GetTeam(),nLane,0);
			local nDist = GetUnitToLocationDistance(bot,nLaneFrontLocation);
			
			if nDist > 2000
			then
				local location = J.Site.GetXUnitsTowardsLocation(bot, nLaneFrontLocation, nCastRange );
				if IsLocationPassable(location)
				then
					return BOT_ACTION_DESIRE_HIGH, location;
				end
			end			
		end
	end	
	
	if J.IsFarming(bot)
	then
		if npcTarget ~= nil and npcTarget:IsAlive()
		   and GetUnitToUnitDistance(bot,npcTarget) > 550
		   and ( nLV > 9 or not npcTarget:IsAncientCreep() )
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation();
		end
	end	
		

	local nAttackAllys  = bot:GetNearbyHeroes(1600,false,BOT_MODE_ATTACK);
	if #nEnemysHerosInView == 0 and not bot:WasRecentlyDamagedByAnyHero(3.0) and nLV >= 10
	   and #nAttackAllys == 0 and ( npcTarget == nil or not npcTarget:IsHero())
	then
		local nAOELocation = bot:FindAoELocation(true,false,bot:GetLocation(),1600,400,0,0);
		local nLaneCreeps  = bot:GetNearbyLaneCreeps(1600,true);
		if nAOELocation.count >= 3 
		   and #nLaneCreeps >= 3
		then
			local bCenter = J.GetCenterOfUnits(nLaneCreeps);
			local bDist = GetUnitToLocationDistance(bot,bCenter);
			local vLocation = J.Site.GetXUnitsTowardsLocation(bot, bCenter, bDist + 550);
			local bLocation = J.Site.GetXUnitsTowardsLocation(bot, bCenter, bDist - 350);
			if bDist >= 1500 then bLocation = J.Site.GetXUnitsTowardsLocation(bot, bCenter, 1150); end
			
			if IsLocationPassable(bLocation) 
			   and IsLocationVisible(vLocation)
			   and GetUnitToLocationDistance(bot,bLocation) > 600
			then
				return BOT_ACTION_DESIRE_HIGH, bLocation;
			end
		end				
    end
    
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X;