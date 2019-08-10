----------------------------------------------------------------------------------------------------
--- The Creation Come From: BOT EXPERIMENT Credit:FURIOUSPUPPY
--- BOT EXPERIMENT Author: Arizona Fauzie 2018.11.21
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=837040016
--- Update by: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
----------------------------------------------------------------------------------------------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local Minion = dofile( GetScriptDirectory()..'/FunLib/Minion')
local sTalentList = J.Skill.GetTalentList(bot)
local sAbilityList = J.Skill.GetAbilityList(bot)
local sOutfit = J.Skill.GetOutfitName(bot)

local tTalentTreeList = {
						['t25'] = {0, 10},
						['t20'] = {0, 10},
						['t15'] = {0, 10},
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{1,3,3,1,3,6,3,1,1,2,6,2,2,2,6},
						{1,3,1,3,1,6,1,3,3,2,6,2,2,2,6},
						{1,3,3,2,1,6,1,3,1,3,6,2,2,2,6}
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)


X['sBuyList'] = {
				sOutfit,
				"item_yasha",
				"item_mjollnir",
				"item_black_king_bar",
				"item_silver_edge",
				"item_manta", 
				"item_ultimate_scepter",
}

X['sSellList'] = {
	"item_monkey_king_bar",
	"item_yasha",
}

nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList'] = J.SetUserHeroInit(nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList']);

X['sSkillList'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)

X['bDeafaultAbility'] = true
X['bDeafaultItem'] = true

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit(hMinionUnit) 
	then
		Minion.IllusionThink(hMinionUnit)
	end

end

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )


local castQDesire, castQLocation
local castWDesire
local castRDesire, castRLocation

local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;


function X.SkillsComplement()

	
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end

	
	
	nKeepMana = 180
	nMP = bot:GetMana()/bot:GetMaxMana();
	nHP = bot:GetHealth()/bot:GetMaxHealth();
	nLV = bot:GetLevel();
	hEnemyHeroList = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	
	
	
	
	castQDesire, castQLocation   = X.ConsiderQ();
	if ( castQDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, true)
		
		bot:Action_UseAbilityOnLocation( abilityQ, castQLocation )
		return;
	end

	castRDesire, castRLocation   = X.ConsiderR();
	if ( castRDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, true)
		
		bot:Action_UseAbilityOnLocation( abilityR, castRLocation )
		return;
	end
	
	castWDesire = X.ConsiderW();
	if ( castWDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, true)
	
		bot:ActionQueue_UseAbility( abilityW )
		return;
	end
	

end


function X.ConsiderQ()

	-- Make sure it's castable
	if not abilityQ:IsFullyCastable() or
	   bot:IsRooted() or
	   bot:HasModifier("modifier_faceless_void_chronosphere_speed")
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityQ:GetSpecialValueInt("range");
	local nCastPoint = abilityQ:GetCastPoint( );
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
--
	return BOT_ACTION_DESIRE_NONE, 0;

end


function X.ConsiderW()

	-- Make sure it's castable
	if ( not abilityW:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	-- Get some of its values
	local nRadius = abilityW:GetSpecialValueInt("radius");

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	if J.IsInTeamFight(bot, 1200)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nRadius - 200, true, BOT_MODE_NONE );
		if (tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2) then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		if J.IsValidHero(npcTarget) and J.CanCastOnNonMagicImmune(npcTarget) and J.IsInRange(npcTarget, bot, nRadius)
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;

end


function X.ConsiderR()

	-- Make sure it's castable
	if ( not abilityR:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nRadius = abilityR:GetSpecialValueInt("radius");
	local nCastRange = abilityR:GetCastRange();

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange+(nRadius/2), true, BOT_MODE_NONE );
		local tableNearbyAllyHeroes = bot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
		if tableNearbyAllyHeroes ~= nil and  #tableNearbyAllyHeroes >= 2 then
			for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
			do
				if bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) 
				then
					local allies = J.GetAlliesNearLoc(npcEnemy:GetLocation(), nRadius);
					if #allies <= 2 then
						return BOT_ACTION_DESIRE_LOW, npcEnemy:GetLocation();
					end	
				end
			end
		end
	end
	
	if J.IsInTeamFight(bot, 1200)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius/2, 0, 0 );
		if ( locationAoE.count >= 2 ) then
			local nInvUnit = J.GetInvUnitInLocCount(bot, nCastRange, nRadius/2, locationAoE.targetloc, true);
			if nInvUnit >= locationAoE.count then
				local allies = J.GetAlliesNearLoc(locationAoE.targetloc, nRadius);
				if #allies <= 2 then
					return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
				end
			end
		end
	end
	
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if ( J.IsValidHero(npcTarget) and J.CanCastOnMagicImmune(npcTarget) and J.IsInRange(npcTarget, bot, nCastRange+(nRadius/2)) )   
		then
			local tableNearbyEnemyHeroes = npcTarget:GetNearbyHeroes( nRadius/2, false, BOT_MODE_NONE );
			local nInvUnit = J.GetInvUnitCount(true, tableNearbyEnemyHeroes);
			if nInvUnit >= 2 then
				local allies = J.GetAlliesNearLoc(npcTarget:GetLocation(), nRadius);
				if #allies <= 2 then
					return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation();
				end
			end
		end
	end
	
--
	return BOT_ACTION_DESIRE_NONE;
end

return X
-- dota2jmz@163.com QQ:2462331592
