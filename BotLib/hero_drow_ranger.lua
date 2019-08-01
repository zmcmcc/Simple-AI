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
						['t20'] = {10, 0},
						['t15'] = {0, 10},
						['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
						{1,3,2,1,1,6,1,2,2,2,6,3,3,3,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)


X['sBuyList'] = {
				sOutfit,
				'item_dragon_lance', 
				'item_yasha', 
				'item_mask_of_madness',
				"item_ultimate_scepter",
				"item_manta",
				"item_hurricane_pike",	
				"item_broken_satanic",
				"item_butterfly",
}

X['sSellList'] = {
	"item_hurricane_pike",
	"item_magic_wand",
}

nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList'] = J.SetUserHeroInit(nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList']);

X['sSkillList'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)

	if minion.IsValidUnit(hMinionUnit) 
	then
		minion.IllusionThink(hMinionUnit)
	end

end

local abilityQ = npcBot:GetAbilityByName( sAbilityList[1] )
local abilityW = npcBot:GetAbilityByName( sAbilityList[2] )
local abilityE = npcBot:GetAbilityByName( sAbilityList[3] )
local abilityM = nil


local castQDesire, castQTarget
local castWDesire, castWLocation
local castEDesire
local castMDesire
local castWMDesire,castWMLocation


local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;




function X.SkillsComplement()

	
	J.ConsiderForMkbDisassembleMask(npcBot);
	
	
	
	if J.CanNotUseAbility(npcBot) or npcBot:IsInvisible() then return end
	
	
	
	nKeepMana = 90
	aetherRange = 0
	talentDamage = 0
	nMP = npcBot:GetMana()/npcBot:GetMaxMana();
	nHP = npcBot:GetHealth()/npcBot:GetMaxHealth();
	nLV = npcBot:GetLevel();
	hEnemyHeroList = npcBot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	abilityM = J.IsItemAvailable("item_mask_of_madness");		

	
	
	
	castEDesire = X.ConsiderE();
	if castEDesire > 0
	then
		npcBot:Action_ClearActions(false);
	
	    npcBot:ActionQueue_UseAbility( abilityE );
		return ;
	end	
	
	
	castWMDesire,castWMLocation = X.ConsiderWM();
	if castWMDesire > 0
	then
	
		J.SetQueuePtToINT(npcBot, true)
	
		npcBot:ActionQueue_UseAbilityOnLocation( abilityW , castWMLocation);
		npcBot:ActionQueue_UseAbility( abilityM );
		return;
		
	end
	
	castWDesire, castWLocation = X.ConsiderW();
	if castWDesire > 0
	then
	
		J.SetQueuePtToINT(npcBot, true)
	
		npcBot:ActionQueue_UseAbilityOnLocation( abilityW , castWLocation);
		return;
	end
	
	castMDesire = X.ConsiderM();
	if castMDesire > 0
	then
		J.SetQueuePtToINT(npcBot, true)
	
	    npcBot:ActionQueue_UseAbility( abilityM );
		return ;
	end
	
	castQDesire, castQTarget = X.ConsiderQ();
	if castQDesire > 0
	then
	
		npcBot:Action_ClearActions(false);
	
		npcBot:ActionQueue_UseAbilityOnEntity( abilityQ , castQTarget);
		return 
		
	end	

end

function X.ConsiderE()
	if abilityE:IsFullyCastable() 
		and nLV >= 9
	then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return BOT_ACTION_DESIRE_NONE
end


function X.ConsiderWM()

	if nLV < 15
	   or abilityM == nil
	   or not abilityM:IsFullyCastable()
	   or not abilityW:IsFullyCastable() 
	   or not abilityQ:GetAutoCastState()
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local abilityWCost  = abilityW:GetManaCost();
	local abilityMCost  = abilityM:GetManaCost();
	
	if abilityMCost + abilityWCost > npcBot:GetMana() then return 0; end
	
	local nCastRange = abilityW:GetCastRange();
	local nCastPoint = abilityW:GetCastPoint();
	local nRadius 	 = abilityW:GetAOERadius();
	
	local nEnemysHeroesInView  = hEnemyHeroList;
	local nEnemysHeroesNearBy = npcBot:GetNearbyHeroes(500,true,BOT_MODE_NONE);
	
	local npcTarget = J.GetProperTarget(npcBot);
	
	if J.IsGoingOnSomeone(npcBot)
	   and #nEnemysHeroesNearBy == 0
	   and not J.IsEnemyTargetUnit(1600,npcBot)
	   and J.GetAllyCount(npcBot,1000) >= 3
	then
		
		if J.IsValidHero(npcTarget) 
			and not npcTarget:IsSilenced()
			and not J.IsDisabled(true, npcTarget)
			and J.CanCastOnNonMagicImmune(npcTarget) 
			and J.IsInRange(npcTarget, npcBot, nCastRange)
			and npcTarget:IsFacingLocation(npcBot:GetLocation(),150)
			and J.IsAllyHeroBetweenAllyAndEnemy(npcBot, npcTarget, npcTarget:GetLocation(), 500)
		then		
			nTargetLocation = npcTarget:GetExtrapolatedLocation( nCastPoint )
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation;
		end
		
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius, nCastPoint, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			nTargetLocation = locationAoE.targetloc;
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation;
		end
		
	end
	
	
	return BOT_ACTION_DESIRE_NONE;
	
end


function X.ConsiderW()

	if not abilityW:IsFullyCastable() 
	   or npcBot:IsInvisible()
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local nCastRange = abilityW:GetCastRange();
	local nRadius 	 = abilityW:GetAOERadius();
	local nDamage 	 = 0
	local nCastPoint = abilityW:GetCastPoint();
	local nTargetLocation = nil;
	
	local nEnemyHeroes = npcBot:GetNearbyHeroes(nCastRange +100,true,BOT_MODE_NONE)

	
	for _,npcEnemy in pairs( nEnemyHeroes )
	do
		if  J.IsValid(npcEnemy)
			and npcEnemy:IsChanneling()  
			and not npcEnemy:HasModifier("modifier_teleporting") 
			and not npcEnemy:HasModifier("modifier_boots_of_travel_incoming")
		then
			nTargetLocation = npcEnemy:GetLocation();
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation;
		end
	end
	
	
	local skThere, skLoc = J.IsSandKingThere(npcBot, nCastRange, 2.0);	
	if skThere and not npcBot:IsInvisible() then
		nTargetLocation = skLoc;
		return BOT_ACTION_DESIRE_HIGH, nTargetLocation;
	end	
	
	
	if npcBot:GetActiveMode() == BOT_MODE_RETREAT 
		and not npcBot:IsInvisible()
	then
	
		
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange-100, nRadius, nCastPoint, 0 );
		if locationAoE.count >= 2 
		   or (locationAoE.count >= 1 and npcBot:GetHealth()/npcBot:GetMaxHealth() < 0.5 ) 
		then
			nTargetLocation = locationAoE.targetloc;
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation;
		end
		
		
		for _,npcEnemy in pairs( nEnemyHeroes )
		do
			if  J.IsValid(npcEnemy)
			    and npcBot:WasRecentlyDamagedByHero( npcEnemy, 5.0 ) 
				and GetUnitToUnitDistance(npcBot,npcEnemy) <= 510 
			then
				nTargetLocation = npcEnemy:GetExtrapolatedLocation( nCastPoint );
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation;
			end
		end
	end
	
	
	if J.IsGoingOnSomeone(npcBot)
	   and not npcBot:IsInvisible()
	then
		local npcTarget = J.GetProperTarget(npcBot);
		if J.IsValidHero(npcTarget) 
			and J.CanCastOnNonMagicImmune(npcTarget) 
			and J.IsInRange(npcTarget, npcBot, nCastRange)
		    and not npcTarget:IsSilenced()
			and not J.IsDisabled(true, npcTarget)
			and ( npcTarget:IsFacingLocation(npcBot:GetLocation(),120) 
				  or npcTarget:GetAttackTarget() ~= nil )
		then		
			nTargetLocation = npcTarget:GetExtrapolatedLocation( nCastPoint )
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation;
		end
		
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius, nCastPoint, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			nTargetLocation = locationAoE.targetloc;
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation;
		end
		
	end
	
	return BOT_ACTION_DESIRE_NONE,nil
end


function X.ConsiderM()
	
	if abilityM == nil or not abilityM:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE end;

	-- Get some of its values
	local nCastRange = npcBot:GetAttackRange();
	local nAttackDamage = npcBot:GetAttackDamage();
	local nDamage = nAttackDamage;
	local nDamageType = DAMAGE_TYPE_PHYSICAL;
	local npcTarget = J.GetProperTarget(npcBot);
	--------------------------------------
	-- Mode based usage
	--------------------------------------	
	
	--If we're going after someone
	if J.IsGoingOnSomeone(npcBot) 
	   and #hEnemyHeroList == 1
	then
		if J.IsValidHero(npcTarget) 
		   and J.CanBeAttacked(npcTarget)
		   and J.CanCastOnNonMagicImmune(npcTarget) 
		   and not J.IsInRange(npcTarget, npcBot, 400)
		   and J.IsInRange(npcTarget, npcBot, nCastRange + 300)
		   and npcBot:IsFacingLocation(npcTarget:GetLocation(),30)
		   and not npcTarget:IsFacingLocation(npcBot:GetLocation(),30)
		   and abilityQ:GetAutoCastState() == true 
		   and abilityW:GetCooldownTimeRemaining() > 5.0 
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	--撤退时更快的跑路
	
	if J.IsRunning(npcBot) or #hEnemyHeroList > 0 then return BOT_ACTION_DESIRE_NONE; end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		if  J.IsRoshan(npcTarget) 
		    and J.IsInRange(npcTarget, npcBot, nCastRange + 99) 
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	if  J.IsValidBuilding(npcTarget) 
	    and J.IsInRange(npcTarget, npcBot, nCastRange + 199)  
	then
		return BOT_ACTION_DESIRE_LOW;
	end	
	
	if  ( J.IsPushing(npcBot) or J.IsDefending(npcBot) or J.IsFarming(npcBot))
	then
		local nCreeps = npcBot:GetNearbyCreeps(800,true);
		if J.IsValid(npcTarget)
			and J.IsInRange(npcTarget,npcBot,nCastRange + 99)
			and ( #nCreeps > 1 or npcTarget:GetHealth() > nAttackDamage * 2.28 )
		then
			return BOT_ACTION_DESIRE_HIGH;
		end	
	end
	
	return BOT_ACTION_DESIRE_NONE;
	
end


local lastAutoTime = 0;
function X.ConsiderQ()
	
	if not abilityQ:IsFullyCastable()
		or npcBot:IsInvisible()
		or npcBot:IsDisarmed()
		or J.GetDistanceFromEnemyFountain(npcBot) < 800
	then
		return BOT_ACTION_DESIRE_NONE,nil
	end
	
	local nAttackRange = npcBot:GetAttackRange() + 40;
	local nAttackDamage = npcBot:GetAttackDamage();
	
	local nTowers = npcBot:GetNearbyTowers(900,true)
	local nEnemysLaneCreepsInRange = npcBot:GetNearbyLaneCreeps(nAttackRange + 30,true)
	local nEnemysLaneCreepsNearby = npcBot:GetNearbyLaneCreeps(400,true)
	local nEnemysWeakestLaneCreepsInRange = J.GetAttackableWeakestUnit(false, true, nAttackRange + 30, npcBot)
	local nEnemysWeakestLaneCreepsInRangeHealth = 10000
	if(nEnemysWeakestLaneCreepsInRange ~= nil)
	then
	    nEnemysWeakestLaneCreepsInRangeHealth = nEnemysWeakestLaneCreepsInRange:GetHealth();
	end
	
	local nEnemysHeroesInAttackRange = npcBot:GetNearbyHeroes(nAttackRange,true,BOT_MODE_NONE);
	local nInAttackRangeWeakestEnemyHero = J.GetAttackableWeakestUnit(true, true, nAttackRange, npcBot);
	local nInViewWeakestEnemyHero = J.GetAttackableWeakestUnit(true, true, 800, npcBot);

	local nAlleyLaneCreeps = npcBot:GetNearbyLaneCreeps(330,false);
	local npcTarget = J.GetProperTarget(npcBot)
	local nTargetUint = nil;
	local npcMode = npcBot:GetActiveMode();
	
	
	if nLV >= 10 
	then
		if hEnemyHeroList[1] ~= nil
			and not abilityQ:GetAutoCastState()
		then
			lastAutoTime = DotaTime();
			abilityQ:ToggleAutoCast();
		elseif hEnemyHeroList[1] == nil
				and lastAutoTime + 3.0 < DotaTime()
				and abilityQ:GetAutoCastState()
			then
				abilityQ:ToggleAutoCast()
	    end
	else
		if  abilityQ:GetAutoCastState( ) 
		then
			abilityQ:ToggleAutoCast()
		end
	end	
	
	if nLV <= 9 
	   and not J.IsRunning(npcBot)
	   and nHP > 0.55
	then
		if  J.IsValidHero(npcTarget)
			and GetUnitToUnitDistance(npcBot,npcTarget) < nAttackRange + 99
		then
			nTargetUint = npcTarget;
			return BOT_ACTION_DESIRE_HIGH, nTargetUint;
		end	
	end
	
	
	if npcMode == BOT_MODE_LANING
		and #nTowers == 0
	then
		
		if J.IsValid(nInAttackRangeWeakestEnemyHero)
		then
			if nEnemysWeakestLaneCreepsInRangeHealth > 130
				and nHP >= 0.6 
				and #nEnemysLaneCreepsNearby <= 3 
				and #nAlleyLaneCreeps >= 2
				and not npcBot:WasRecentlyDamagedByCreep(1.5)
				and not npcBot:WasRecentlyDamagedByAnyHero(1.5)
			then
				nTargetUint = nInAttackRangeWeakestEnemyHero;
				return BOT_ACTION_DESIRE_HIGH, nTargetUint;
			end
		end
		
		
		if J.IsValid(nInViewWeakestEnemyHero)
		then
			if nEnemysWeakestLaneCreepsInRangeHealth > 180
				and nHP >= 0.7 
				and #nEnemysLaneCreepsNearby <= 2 
				and #nAlleyLaneCreeps >= 3
				and not npcBot:WasRecentlyDamagedByCreep(1.5)
				and not npcBot:WasRecentlyDamagedByAnyHero(1.5)
				and not npcBot:WasRecentlyDamagedByTower(1.5)
			then
				nTargetUint = nInViewWeakestEnemyHero;
				return BOT_ACTION_DESIRE_HIGH, nTargetUint;
			end
			
			if J.GetUnitAllyCountAroundEnemyTarget(nInViewWeakestEnemyHero , 500) >= 4
				and not npcBot:WasRecentlyDamagedByCreep(1.5)
				and not npcBot:WasRecentlyDamagedByAnyHero(1.5)
				and not npcBot:WasRecentlyDamagedByTower(1.5)
			    and nHP >= 0.6 
			then
				nTargetUint = nInViewWeakestEnemyHero;
				return BOT_ACTION_DESIRE_HIGH, nTargetUint;
			end			
		end		
	end
	
	
	if npcTarget ~= nil
		and npcTarget:IsHero()
		and GetUnitToUnitDistance(npcTarget,npcBot) >  nAttackRange + 160
		and J.IsValid(nInAttackRangeWeakestEnemyHero)
		and not nInAttackRangeWeakestEnemyHero:IsAttackImmune()
	then
		nTargetUint = nInAttackRangeWeakestEnemyHero;
		npcBot:SetTarget(nTargetUint);
		return BOT_ACTION_DESIRE_HIGH, nTargetUint;
	end
	
	
	if npcBot:HasModifier("modifier_item_hurricane_pike_range")
		and J.IsValid(npcTarget)
	then
		nTargetUint = npcTarget;
		return BOT_ACTION_DESIRE_HIGH, nTargetUint;	
	end
	
	
	if  npcBot:GetAttackTarget() == nil 
		and  npcBot:GetTarget() == nil
		and  #hEnemyHeroList == 0
		and  npcMode ~= BOT_MODE_RETREAT
		and  npcMode ~= BOT_MODE_ATTACK 
		and  npcMode ~= BOT_MODE_ASSEMBLE
		and  npcMode ~= BOT_MODE_FARM
		and  npcMode ~= BOT_MODE_TEAM_ROAM
		and  J.GetTeamFightAlliesCount(npcBot) < 3
		and  npcBot:GetMana() >= 180
		and  not npcBot:WasRecentlyDamagedByAnyHero(3.0) 
	then		
		
        if npcBot:HasScepter()
		then
			local nEnemysCreeps = npcBot:GetNearbyCreeps(1600,true)
			if J.IsValid(nEnemysCreeps[1])
			then
				nTargetUint = nEnemysCreeps[1];
				return BOT_ACTION_DESIRE_HIGH, nTargetUint;
			end
		end
			
		local nNeutralCreeps = npcBot:GetNearbyNeutralCreeps(1600)
		if npcMode ~= BOT_MODE_LANING
			and nLV >= 6  
			and nHP > 0.25
			and J.IsValid(nNeutralCreeps[1])
			and not J.IsRoshan(nNeutralCreeps[1])
			and (nNeutralCreeps[1]:IsAncientCreep() == false or nLV >= 12)
		then
			nTargetUint = nNeutralCreeps[1];
			return BOT_ACTION_DESIRE_HIGH, nTargetUint;
		end
		
		
		local nLaneCreeps = npcBot:GetNearbyLaneCreeps(1600,true)
		if npcMode ~= BOT_MODE_LANING
			and nLV >= 6  
			and nHP > 0.25
			and J.IsValid(nLaneCreeps[1])
			and npcBot:GetAttackDamage() > 130
		then
			nTargetUint = nLaneCreeps[1]; 
			return BOT_ACTION_DESIRE_HIGH, nTargetUint;
		end
	end
	
	
	if npcMode == BOT_MODE_RETREAT
	then
		
		nDistance = 999
		local nTargetUint = nil
	    for _,npcEnemy in pairs( nEnemysHeroesInAttackRange )
		do
			if  J.IsValid(npcEnemy)
				and npcEnemy:HasModifier("modifier_drowranger_wave_of_silence_knockback") 
				and GetUnitToUnitDistance(npcEnemy,npcBot) < nDistance
			then
				nTargetUint = npcEnemy;
				nDistance = GetUnitToUnitDistance(npcEnemy,npcBot);	
			end
		end		
		
		if nTargetUint ~= nil
		   and not nTargetUint:HasModifier("modifier_drow_ranger_frost_arrows_slow")
		then
			return BOT_ACTION_DESIRE_HIGH, nTargetUint;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end


return X
-- dota2jmz@163.com QQ:2462331592
