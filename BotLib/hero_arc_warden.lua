----------------------------------------------------------------------------------------------------
--- The Creation Come From: BOT EXPERIMENT Credit:FURIOUSPUPPY
--- BOT EXPERIMENT Author: Arizona Fauzie 2018.11.21
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=837040016
--- Update by: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
----------------------------------------------------------------------------------------------------
local X = {}
local npcBot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local minion = dofile( GetScriptDirectory()..'/FunLib/Minion')
local sTalentList = J.Skill.GetTalentList(npcBot)
local sAbilityList = J.Skill.GetAbilityList(npcBot)
local sOutfit = J.Skill.GetOutfitName(npcBot)

local tTalentTreeList = {
						['t25'] = {10, 0},
						['t20'] = {0, 10},
						['t15'] = {0, 10},
						['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
						{3,1,3,1,3,6,3,2,1,1,6,2,2,2,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)


X['sBuyList'] = {
				sOutfit,
				"item_hand_of_midas",
				"item_maelstrom",
				"item_diffusal_blade",
				"item_manta",
				"item_sheepstick",
				"item_mjollnir",
				"item_orchid",
				"item_bloodthorn",
				"item_black_king_bar",	
}

X['sSellList'] = {
	"item_bloodthorn",
	"item_diffusal_blade",
	"item_mjollnir",
	"item_hand_of_midas",
}

nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList'] = J.SetUserHeroInit(nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList']);

X['sSkillList'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = true

function X.MinionThink(hMinionUnit)

	if minion.IsValidUnit(hMinionUnit) 
	then
		minion.IllusionThink(hMinionUnit)
		--待补充死灵书的逻辑
	end

end

local abilityQ = npcBot:GetAbilityByName( sAbilityList[1] );
local abilityW = npcBot:GetAbilityByName( sAbilityList[2] );
local abilityE = npcBot:GetAbilityByName( sAbilityList[3] );
local abilityR = npcBot:GetAbilityByName( sAbilityList[6] );


local castQDesire,castQTarget
local castWDesire,castWLocation
local castEDesire,castELocation
local castRDesire


local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;
local npcDouble = nil; 


function X.SkillsComplement()
	
	
	if J.CanNotUseAbility(npcBot) or npcBot:IsInvisible() then return end
	
	
	nKeepMana = 300
	nMP = npcBot:GetMana()/npcBot:GetMaxMana();
	nHP = npcBot:GetHealth()/npcBot:GetMaxHealth();
	nLV = npcBot:GetLevel();
	hEnemyHeroList = npcBot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	
	
	
	
	castQDesire, castQTarget = X.ConsiderQ();
	if ( castQDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, false)
	
		npcBot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget )
		return;
	end
	
	castWDesire, castWLocation = X.ConsiderW();
	if ( castWDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, false)
	
		npcBot:ActionQueue_UseAbilityOnLocation( abilityW, castWLocation )
		return;
	end
	
	
	castEDesire, castELocation = X.ConsiderE();
	if ( castEDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, false)
	
		npcBot:ActionQueue_UseAbilityOnLocation( abilityE, castELocation )
		return;
	end
	
	
	castRDesire = X.ConsiderR();
	if ( castRDesire > 0 ) 
	then
		
		npcBot:ActionQueue_UseAbility( abilityR )
		return;
	
	end

end


function X.ConsiderE()


	if not abilityE:IsFullyCastable() then	return 0 end 

	local nRadius = abilityE:GetSpecialValueInt( "radius" );
	local nCastRange = abilityE:GetCastRange();
	local nDamage = abilityE:GetSpecialValueInt("spark_damage");
	local nDelay = abilityE:GetSpecialValueInt("activation_delay");

	
	-- If a mode has set a target, and we can kill them, do it
	local npcTarget = J.GetProperTarget(npcBot);
	if J.IsValidHero(npcTarget) 
	   and J.CanCastOnNonMagicImmune(npcTarget)
	then
		if J.CanKillTarget(npcTarget, nDamage, DAMAGE_TYPE_MAGICAL) 
		   and J.IsInRange(npcTarget, npcBot, nCastRange) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nDelay - 0.3 )
		end
	end

	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if J.IsRoshan(npcTarget) 
		   and J.IsInRange(npcTarget, npcBot, nCastRange) 
		   and J.GetHPR(npcTarget) > 0.2
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetLocation();
		end
	end
	
	
	if J.IsInTeamFight(npcBot, 1200)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), 1000, nRadius, 0, 0 );
		if locationAoE.count >= 2
		then
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
		end
	end
	
	
	if J.IsGoingOnSomeone(npcBot)
	then
	
		if J.IsValidHero(npcTarget) 
		   and J.CanCastOnNonMagicImmune(npcTarget) 
		   and J.IsInRange(npcTarget, npcBot, nCastRange)
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nDelay - 0.3 );
		end
		
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), 1400, nRadius, 2.0, 0 );
		if locationAoE.count >= 1 
		   and not npcBot:HasModifier("modifier_silencer_curse_of_the_silent")
		then
			local nCreep = J.GetVulnerableUnitNearLoc(false, true, 1600, nRadius, locationAoE.targetloc, npcBot);
			if nCreep == nil 
			   or npcBot:HasModifier("modifier_arc_warden_tempest_double")
			then
				return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
			end
		end
		
	end	
	
	-- if we're Retreat
	if J.IsRetreating(npcBot) 
	   and npcBot:GetActiveModeDesire() > BOT_ACTION_DESIRE_HIGH
	   and not npcBot:HasModifier("modifier_silencer_curse_of_the_silent")
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes(800,true,BOT_MODE_NONE);
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( J.IsValid(npcEnemy) and npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) and J.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcBot:GetLocation();
			end
		end
	end
	
	-- if we're farming
	if npcBot:GetActiveMode() == BOT_MODE_FARM
	   or J.IsPushing(npcBot)
	   or J.IsDefending(npcBot)
	then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), 1400, nRadius, 2.0, 0 );
		if locationAoE.count > 2
			and not npcBot:HasModifier("modifier_silencer_curse_of_the_silent")
		then
			if npcBot:HasModifier("modifier_arc_warden_tempest_double")
			then
				return BOT_ACTION_DESIRE_HIGH,locationAoE.targetloc;
			end
			
			local nLaneCreeps = npcBot:GetNearbyLaneCreeps(1400,true);
			if #nLaneCreeps >= 2
			then
				if J.GetMPR(npcBot) > 0.62
				then
					return BOT_ACTION_DESIRE_HIGH,locationAoE.targetloc;
				end
			else
				if J.GetMPR(npcBot) > 0.75
				then
					return BOT_ACTION_DESIRE_HIGH,locationAoE.targetloc;
				end
			end
		end
	
	end
	
	
	if abilityE:GetLevel() >= 3 and npcBot:GetActiveMode() ~= BOT_MODE_LANING and J.IsAllowedToSpam(npcBot, 80) 
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), 1400, nRadius, 2.0, 0 );
		if locationAoE.count >= 2 then
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
		end	
	end
	
	
	if npcBot:GetLevel() >= 10
		and ( J.IsAllowedToSpam(npcBot,80) or npcBot:HasModifier("modifier_arc_warden_tempest_double"))
		and DotaTime() > 6 *60
	then
	
		local nEnemysHerosCanSeen = GetUnitList(UNIT_LIST_ENEMY_HEROES);
		local nTargetHero = nil;
		local nTargetHeroHealth = 99999;
		for _,enemy in pairs(nEnemysHerosCanSeen)
		do
			if J.IsValidHero(enemy)
				and GetUnitToUnitDistance(npcBot,enemy) <= nCastRange
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
				if GetUnitToLocationDistance(npcBot,castLocation) <= nCastRange
				then
					return BOT_ACTION_DESIRE_MODERATE, castLocation;
				end
			end
		end
		
		
		local nLaneCreeps = npcBot:GetNearbyLaneCreeps(1600,true);
		if #nLaneCreeps >= 3
		then
			local targetCreep = nLaneCreeps[#nLaneCreeps];
			if J.IsValid(targetCreep)
			then
				local castLocation = J.GetFaceTowardDistanceLocation(targetCreep,375);
				return BOT_ACTION_DESIRE_MODERATE ,castLocation;
			end
		end
		
		local nEnemyHeroesInView = npcBot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
		local nEnemyLaneFront = J.GetNearestLaneFrontLocation(npcBot:GetLocation(),true,nRadius/2);
		if #nEnemyHeroesInView == 0 and nEnemyLaneFront ~= nil
		   and GetUnitToLocationDistance(npcBot,nEnemyLaneFront) <= nCastRange + nRadius
		   and GetUnitToLocationDistance(npcBot,nEnemyLaneFront) >= 800
		then
			local castLocation = J.GetLocationTowardDistanceLocation(npcBot,nEnemyLaneFront,nCastRange)
			if GetUnitToLocationDistance(npcBot,nEnemyLaneFront) < nCastRange
			then
				castLocation = nEnemyLaneFront
			end			
			return BOT_ACTION_DESIRE_MODERATE ,castLocation;
		end
	end
	
	
	local castLocation = J.GetLocationTowardDistanceLocation(npcBot,J.GetEnemyFountain(),nCastRange)
	if  npcBot:HasModifier("modifier_arc_warden_tempest_double")
		or ( J.GetMPR(npcBot) > 0.92 and npcBot:GetLevel() > 11 and not IsLocationVisible(castLocation) )
		or ( J.GetMPR(npcBot) > 0.38 and J.GetDistanceFromEnemyFountain(npcBot) < 4300 )
	then
		if IsLocationPassable(castLocation)
		   and not npcBot:HasModifier("modifier_silencer_curse_of_the_silent")
		then
			return BOT_ACTION_DESIRE_MODERATE, castLocation;
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end


function X.ConsiderW()
	
	if not abilityW:IsFullyCastable() 
	   or X.IsDoubleCasting()
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nRadius = abilityW:GetSpecialValueInt( "radius" );
	local nCastRange = abilityW:GetCastRange();

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(npcBot) 
	   and not npcBot:HasModifier("modifier_arc_warden_magnetic_field") 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( J.IsValid(npcEnemy) and npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcBot:GetLocation();
			end
		end
	end

	if npcBot:GetActiveMode() == BOT_MODE_ROSHAN
	   and not npcBot:HasModifier("modifier_arc_warden_magnetic_field") 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( J.IsRoshan(npcTarget) and J.CanCastOnMagicImmune(npcTarget) and J.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcBot:GetLocation();
		end
	end
	
	-- If we're farming and can kill 3+ creeps with LSA
	if npcBot:GetActiveMode() == BOT_MODE_FARM 
	   and not npcBot:HasModifier("modifier_arc_warden_magnetic_field") 
	then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), 600, nRadius, 0, 0 );
		if ( locationAoE.count >= 3  ) then
			return BOT_ACTION_DESIRE_HIGH, npcBot:GetLocation();
		end
	end

	if J.IsInTeamFight(npcBot, 1200)
	then
		local locationAoE = npcBot:FindAoELocation( false, true, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2 ) then
			local targetAllies = J.GetAlliesNearLoc(locationAoE.targetloc, nRadius);
			if J.IsValidHero(targetAllies[1]) 
				and not targetAllies[1]:HasModifier("modifier_arc_warden_magnetic_field")
				and targetAllies[1]:GetAttackTarget() ~= nil
				and GetUnitToUnitDistance(targetAllies[1],targetAllies[1]:GetAttackTarget()) <= targetAllies[1]:GetAttackRange() +50
			then
				return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
			end
		end
	end

	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if J.IsDefending(npcBot) or J.IsPushing(npcBot) and not npcBot:HasModifier("modifier_arc_warden_magnetic_field")
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps( 800, true );
		local tableNearbyEnemyTowers = npcBot:GetNearbyTowers( 800, true );
		if ( tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 3 ) 
		   or ( tableNearbyEnemyTowers ~= nil and #tableNearbyEnemyTowers >= 1 ) 
		then
			return BOT_ACTION_DESIRE_LOW, npcBot:GetLocation();
		end
	end
	
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if J.IsValidHero(npcTarget) and  J.IsInRange(npcTarget, npcBot, nCastRange)  
		then
			local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( nCastRange, false, BOT_MODE_ATTACK );
			for _,npcAlly in pairs( tableNearbyAttackingAlliedHeroes )
			do
				if J.IsValid(npcAlly) 
				    and ( J.IsInRange(npcAlly, npcBot, nCastRange) and not npcAlly:HasModifier("modifier_arc_warden_magnetic_field") ) 
					and ( J.IsValid(npcAlly:GetAttackTarget()) and GetUnitToUnitDistance(npcAlly,npcAlly:GetAttackTarget()) <= npcAlly:GetAttackRange() )
				then
					return BOT_ACTION_DESIRE_MODERATE, npcAlly:GetLocation();
				end
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end


function X.ConsiderQ()

	-- Make sure it's castable
	if not abilityQ:IsFullyCastable() then return 0	end

	-- Get some of its values
	local nCastRange = abilityQ:GetCastRange() +60;
	local nDot = abilityQ:GetSpecialValueInt( "damage_per_second" );
	local nDuration = abilityQ:GetSpecialValueInt( "duration" );
	local nDamage = nDot * nDuration;
	local npcTarget = J.GetProperTarget(npcBot);
	
	-- If a mode has set a target, and we can kill them, do it
	if J.IsValidHero(npcTarget) 
	   and J.CanCastOnNonMagicImmune(npcTarget) 
	   and J.CanKillTarget(npcTarget, nDamage, DAMAGE_TYPE_MAGICAL) 
	   and J.IsInRange(npcTarget, npcBot, nCastRange)
	then
		return BOT_ACTION_DESIRE_HIGH, npcTarget;
	end
	
	
	-- If we're in a teamfight, use it on the scariest enemy
	if J.IsInTeamFight(npcBot, 1200)
	then
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;

		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE  );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if J.IsValid(npcEnemy) 
			   and  J.CanCastOnNonMagicImmune(npcEnemy) 
			then
				local nDamage = npcEnemy:GetEstimatedDamageToTarget( false, npcBot, 3.0, DAMAGE_TYPE_ALL );
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

	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		if ( J.IsRoshan(npcTarget) and J.CanCastOnMagicImmune(npcTarget) and J.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget;
		end
	end
	
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(npcBot)
	then
		if J.IsValidHero(npcTarget) 
		   and J.CanCastOnNonMagicImmune(npcTarget) 
		   and J.IsInRange(npcTarget, npcBot, nCastRange +40)
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	
	if J.IsRetreating(npcBot) 
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE  );
		local nEnemyHeroes   = npcBot:GetNearbyHeroes( 800, true, BOT_MODE_NONE  );
		local npcEnemy = tableNearbyEnemyHeroes[1];
		if J.IsValid(npcEnemy) 
			and (npcBot:IsFacingLocation(npcEnemy:GetLocation(),10) or #nEnemyHeroes <= 1)
			and npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) 
			and J.CanCastOnNonMagicImmune(npcEnemy)
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end  
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end


function X.ConsiderR()

	X.UpdateDoubleStatus();
	
	-- Make sure it's castable
	if ( not abilityR:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if  J.IsDefending(npcBot) or J.IsPushing(npcBot) or J.IsGoingOnSomeone(npcBot) or npcBot:GetActiveMode() == BOT_MODE_FARM
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps( 800, true );
		local tableNearbyEnemyTowers = npcBot:GetNearbyTowers( 800, true );
		local tableNaturalCreeps     = npcBot:GetNearbyCreeps(800,true);
		if ( tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 2 ) 
		    or ( tableNearbyEnemyTowers ~= nil and #tableNearbyEnemyTowers >= 1 ) 
			or ( tableNaturalCreeps ~= nil and #tableNaturalCreeps >= 2 ) 
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end


	if J.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if J.IsValid(npcEnemy) and J.IsInRange(npcEnemy, npcBot, 1000)
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	
	if J.IsRetreating(npcBot) 
	then
		local nEnemyHeroes   = npcBot:GetNearbyHeroes( 800, true, BOT_MODE_NONE  );
		local npcEnemy = nEnemyHeroes[1];
		if J.IsValid(npcEnemy) 
			and (J.GetHPR(npcBot) > 0.35 or #nEnemyHeroes <= 1)
			and npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) 
			and J.GetHPR(npcBot) > 0.25
			and #nEnemyHeroes <= 2
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end  
	end
	
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if J.IsValidHero(npcTarget) and J.IsInRange(npcTarget, npcBot, 1000) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	local midas = J.GetComboItem(npcBot, "item_hand_of_midas")
	if midas ~= nil
	   and X.IsDoubleMidasCooldown()
	   and npcBot:DistanceFromFountain() > 600
	then
		local nCreeps = npcBot:GetNearbyCreeps(1600,true);
		if #nCreeps >= 1 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end


function X.IsDoubleMidasCooldown()
	
	if npcDouble == nil then X.UpdateDoubleStatus() end
	
	if npcDouble ~= nil
	then
		local midas = J.GetComboItem(npcDouble, "item_hand_of_midas")
		if midas ~= nil 
			and (midas:IsFullyCastable() or midas:GetCooldownTimeRemaining() <= 3.0 ) 
		then
			return true;
		end
	end

	return false;
end


function X.UpdateDoubleStatus()
	if npcDouble == nil 
		and npcBot:GetLevel() >= 6
	then
		local nHeroes = npcBot:GetNearbyHeroes(1600,false,BOT_MODE_NONE);
		for _,hero in pairs(nHeroes)
		do
			if hero ~= nil and hero:IsAlive()
			   and hero:HasModifier("modifier_arc_warden_tempest_double")
			then
				npcDouble = hero;
			end
		end
	end
end


function X.IsDoubleCasting()
	if npcDouble == nil 
		or not npcDouble:IsAlive()
	then
		return false;
	end

	local nAlly = npcBot:GetNearbyHeroes(1200,false,BOT_MODE_NONE);
	for _,ally in pairs(nAlly)
	do
		if J.IsValid(ally)
			and ally ~= npcBot
			and ally:GetUnitName() == "npc_dota_hero_arc_warden"
			and (ally:IsCastingAbility() or ally:IsUsingAbility())
		then
			return true;
		end
	end	

	return false;
end


return X
-- dota2jmz@163.com QQ:2462331592
