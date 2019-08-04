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
						['t25'] = {0, 10},
						['t20'] = {10, 0},
						['t15'] = {0, 10},
						['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
						{1,2,2,3,2,6,2,3,3,3,1,1,1,6,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)


X['sBuyList'] = {
				sOutfit,
				"item_dragon_lance",
--				"item_mask_of_madness",
				"item_yasha",
				"item_manta",
				"item_maelstrom",
				"item_skadi",
				"item_black_king_bar",
				"item_satanic",
				"item_mjollnir",
				--"item_lesser_crit",
				--"item_orchid",
				--"item_bloodthorn",
}

X['sSellList'] = {
	"item_manta",
	"item_urn_of_shadows",
	"item_black_king_bar",
	"item_dragon_lance",
}

nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList'] = J.SetUserHeroInit(nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList']);

X['sSkillList'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)


X['bDeafaultAbility'] = false
X['bDeafaultItem'] = true


function X.MinionThink(hMinionUnit)

	if minion.IsValidUnit(hMinionUnit) 
	then
		minion.IllusionThink(hMinionUnit)
	end

end

local abilityQ  = npcBot:GetAbilityByName( sAbilityList[1] )
local abilityW = npcBot:GetAbilityByName( sAbilityList[2] )
local abilityE = npcBot:GetAbilityByName( sAbilityList[3] )
local abilityR = npcBot:GetAbilityByName( sAbilityList[6] )


local castQDesire, castQLocation
local castWDesire
local castEDesire,castETarget
local castRDesire


local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;
local lastToggleTime = 0;


function X.SkillsComplement()

	
	J.ConsiderForMkbDisassembleMask(npcBot);
	J.ConsiderTarget();
	
	
	
	if J.CanNotUseAbility(npcBot) or npcBot:IsInvisible() then return end
	
	
	
	nKeepMana = 400; 
	aetherRange = 0
	nLV = npcBot:GetLevel();
	nMP = npcBot:GetMana()/npcBot:GetMaxMana();
	nHP = npcBot:GetHealth()/npcBot:GetMaxHealth();
	hEnemyHeroList = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	
	
	--计算各个技能	

	castQDesire, castQLocation = X.ConsiderQ();
	if ( castQDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, true)
	
		npcBot:ActionQueue_UseAbilityOnLocation(abilityQ, castQLocation);
		return;
	end
	
	castWDesire = X.ConsiderW()
	if ( castWDesire > 0 ) 
	then
	
		npcBot:ActionQueue_UseAbility( abilityW )
		return;
	
	end
	
	
	castEDesire, castETarget = X.ConsiderE();
	if ( castEDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, false)
	
		npcBot:ActionQueue_UseAbilityOnEntity( abilityE, castETarget )
		return;
	end
	
	
	castRDesire  = X.ConsiderR();
	if ( castRDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, false)
	
		npcBot:ActionQueue_UseAbility( abilityR )
		return;
	
	end

end


function X.ConsiderQ()
	
	if not abilityQ:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastPoint = abilityQ:GetCastPoint();
	local nDelay = abilityQ:GetSpecialValueFloat("delay");
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( J.IsRoshan(npcTarget) and J.CanCastOnMagicImmune(npcTarget) and J.IsInRange(npcTarget, npcBot, 600)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetLocation();
		end
	end
	
	if abilityE:GetLevel() >= 3
	   and abilityE:IsFullyCastable()
	   and npcBot:GetMana() > 160
	then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if (npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetExtrapolatedLocation((nDelay + nCastPoint) *0.68);
			end
		end
	end
	
	--打断持续施法
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
		end
	end
	
	
	if J.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( J.IsValidHero(npcTarget) 
			 and not J.IsRunning(npcTarget)
			 and not J.IsMoving(npcTarget)
		     and J.CanCastOnNonMagicImmune(npcTarget) 
			 and GetUnitToUnitDistance(npcTarget, npcBot) < 700 ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget:GetExtrapolatedLocation((nDelay + nCastPoint) *0.68);
		end
	end
	
	
	local skThere, skLoc = J.IsSandKingThere(npcBot, 1000, 2.0);
	if skThere then
		return BOT_ACTION_DESIRE_MODERATE, skLoc;
	end	
	
	return BOT_ACTION_DESIRE_NONE, 0;
end

function X.ConsiderR()

	if not abilityR:IsFullyCastable() then return 0 end

	local nCastRange = 450


	if J.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) 
			    and J.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				if not abilityR:GetToggleState() 
				then
					return BOT_ACTION_DESIRE_HIGH
				end
			else
				if abilityR:GetToggleState() 
				then			   
					return BOT_ACTION_DESIRE_HIGH
				end
			end
		end
	end

	if J.IsInTeamFight(npcBot, 1200)
	then
		
		local npcMaxManaEnemy = 0;
		local nEnemyMaxMana = 0;

		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 150, true, BOT_MODE_NONE );

		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 2)
		then
			if not abilityR:GetToggleState() 
			then
				return BOT_ACTION_DESIRE_HIGH
			end
		else
			if abilityR:GetToggleState() 
			then			   
				return BOT_ACTION_DESIRE_HIGH
			end
		end
		
	end
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 50, true, BOT_MODE_NONE );

		if ( tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 and nMP > 0.4)
		then
			if not abilityR:GetToggleState() 
			then
				return BOT_ACTION_DESIRE_HIGH
			end
		else
			if abilityR:GetToggleState() 
			then			   
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;

end

function X.ConsiderW()

	-- Make sure it's castable
	if  not abilityW:IsFullyCastable() 
	   or ( npcBot:WasRecentlyDamagedByAnyHero(1.5) and  nHP < 0.38)
	   or npcBot:DistanceFromFountain() < 600
	then return 0; end

	-- Get some of its values
	local nRadius = 500;                          
	
	local nEnemysHerosInSkillRange = npcBot:GetNearbyHeroes(500,true,BOT_MODE_NONE);
	local nEnemysHerosNearby       = npcBot:GetNearbyHeroes(300,true,BOT_MODE_NONE);
	

	if #nEnemysHerosInSkillRange >= 3
		or (#nEnemysHerosNearby >= 1 and #nEnemysHerosInSkillRange >= 2)
	then
		return BOT_ACTION_DESIRE_HIGH;
	end		
	
	local nAoe = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), 100, 600, 0.8, 0 );
	if nAoe.count >= 3
	then
		return BOT_ACTION_DESIRE_HIGH;
	end	
	
	local npcTarget = J.GetProperTarget(npcBot);		
	if J.IsValidHero(npcTarget) 
		and J.CanCastOnNonMagicImmune(npcTarget) 
		and ( GetUnitToUnitDistance(npcTarget,npcBot) <= 350
				or ( J.GetHPR(npcTarget) < 0.38 and  GetUnitToUnitDistance(npcTarget,npcBot) <= 650 ) )
		and npcTarget:GetHealth() > 600
	then
		return BOT_ACTION_DESIRE_HIGH;
	end
	
	--推塔
	if ( J.IsPushing(npcBot) or J.IsDefending(npcBot) ) 
	then
		local towers = npcBot:GetNearbyTowers(nRadius, true);
		local creeps = npcBot:GetNearbyLaneCreeps(nRadius, true);
		local barracks = npcBot:GetNearbyBarracks(nRadius, true);
		if towers[1] ~= nil and not towers[1]:IsInvulnerable() and #creeps < 3
		then
			return BOT_ACTION_DESIRE_HIGH, towers[1];
		end
		if barracks[1] ~= nil and not barracks[1]:IsInvulnerable() and #creeps < 3
		then
			return BOT_ACTION_DESIRE_HIGH, barracks[1];
		end
		if #creeps >= 4 and creeps[1] ~= nil
		then
			return BOT_ACTION_DESIRE_HIGH, creeps[1];
		end
	end
				
	return BOT_ACTION_DESIRE_NONE;

end

function X.ConsiderE()

	if not abilityE:IsFullyCastable() then	return BOT_ACTION_DESIRE_NONE, nil;	end
	
	local nCastRange = abilityE:GetCastRange();
	local nCastPoint = abilityE:GetCastPoint();
	local manaCost  = abilityE:GetManaCost();
	local nRadius   = abilityE:GetSpecialValueInt( "radius" );
	local nDamage   = abilityE:GetSpecialValueInt( "arc_damage" );
	local nEnemyHeroesInSkillRange = npcBot:GetNearbyHeroes(nCastRange,true,BOT_MODE_NONE);
	
	for _,enemy in pairs(nEnemyHeroesInSkillRange)
	do
		if J.IsValidHero(enemy)
			and J.CanCastOnNonMagicImmune(enemy)
			and J.GetHPR(enemy) <= 0.2
		then
			return BOT_ACTION_DESIRE_HIGH, enemy;
		end
	end
	
	
	--对线期的使用
	if npcBot:GetActiveMode() == BOT_MODE_LANING 
	then
		local hLaneCreepList = npcBot:GetNearbyLaneCreeps(nCastRange +50,true);
		for _,creep in pairs(hLaneCreepList)
		do
			if J.IsValid(creep)
		        and J.IsEnemyTargetUnit(1400,creep)
				and J.WillKillTarget(creep,nDamage,DAMAGE_TYPE_MAGICAL,nCastPoint)
			then
				return BOT_ACTION_DESIRE_HIGH, creep;
			end
		end
	
	end
	
	
	if J.IsRetreating(npcBot) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
	then
		local target = J.GetVulnerableWeakestUnit(true, true, nCastRange, npcBot);
		if target ~= nil and npcBot:IsFacingLocation(target:GetLocation(),45) then
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	
	if J.IsInTeamFight(npcBot, 1300)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2 ) then
			local target = J.GetVulnerableUnitNearLoc(true, true, nCastRange, nRadius, locationAoE.targetloc, npcBot);
			if target ~= nil then
				return BOT_ACTION_DESIRE_HIGH, target;
			end
		end
	end
	
	if ( J.IsPushing(npcBot) or J.IsDefending(npcBot) ) and J.IsAllowedToSpam(npcBot, manaCost)
	then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 3 ) then
			local target = J.GetVulnerableUnitNearLoc(false, true, nCastRange, nRadius, locationAoE.targetloc, npcBot);
			if target ~= nil then
				return BOT_ACTION_DESIRE_HIGH, target;
			end
		end
	end
	
	if J.IsGoingOnSomeone(npcBot)
	then
		local target = J.GetProperTarget(npcBot);
		if J.IsValidHero(target) 
		   and J.CanCastOnNonMagicImmune(target) 
		   and J.IsInRange(target, npcBot, nCastRange)
		then
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end

return X
-- dota2jmz@163.com QQ:2462331592
