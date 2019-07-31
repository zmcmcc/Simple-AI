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
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{3,1,1,2,1,6,1,3,3,6,2,2,2,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)

X['skills'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)

X['items'] = {
				sOutfit,
				"item_dragon_lance",
				"item_desolator",
				"item_black_king_bar",
				"item_hurricane_pike",
				"item_satanic",
				"item_lesser_crit",
				"item_bloodthorn",
}

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = true

function X.MinionThink(hMinionUnit)

	if minion.IsValidUnit(hMinionUnit) 
	then
		if hMinionUnit:IsIllusion() 
		then 
			minion.IllusionThink(hMinionUnit)	
		end
	end

end

local abilityQ = npcBot:GetAbilityByName( sAbilityList[1] )
local abilityW = npcBot:GetAbilityByName( sAbilityList[2] )
local abilityE = npcBot:GetAbilityByName( sAbilityList[3] )
local abilityD = npcBot:GetAbilityByName( sAbilityList[4] )
local abilityR = npcBot:GetAbilityByName( sAbilityList[6] )

local castQDesire,castQLocation = 0;
local castWDesire,castWTarget = 0;
local castEDesire,castETarget = 0;
local castDDesire,castDTarget = 0;
local castRDesire,castRTarget = 0;

local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;


function X.SkillsComplement()
	
	
	if J.CanNotUseAbility(npcBot) or npcBot:IsInvisible() then return end
	
	
	
	nKeepMana = 400
	nMP = npcBot:GetMana()/npcBot:GetMaxMana();
	nHP = npcBot:GetHealth()/npcBot:GetMaxHealth();
	nLV = npcBot:GetLevel();
	hEnemyHeroList = npcBot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	
		
	castRDesire, castRTarget = X.ConsiderR();
	if castRDesire > 0
	then
	
		J.SetQueuePtToINT(npcBot, false)
	
		npcBot:ActionQueue_UseAbilityOnEntity( abilityR, castRTarget )

		return;
	end
	
	castQDesire, castQLocation = X.ConsiderQ();
	if ( castQDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, false)
	
		npcBot:ActionQueue_UseAbilityOnLocation( abilityQ, castQLocation )
		return;
	end

	castWDesire, castWTarget = X.ConsiderW();
	if ( castWDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, false)
	
		npcBot:ActionQueue_UseAbilityOnEntity( abilityW, castWTarget )
		return;
	end

	castDDesire, castDTarget = X.ConsiderD();
	if ( castDDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, true)
	
		npcBot:ActionQueue_UseAbilityOnEntity( abilityD, castDTarget )
		return;
	end

	castEDesire, castETarget = X.ConsiderE();
	if ( castEDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, false)
	
		npcBot:ActionQueue_UseAbilityOnEntity( abilityE, castETarget )
		return;
	end

end


function X.ConsiderQ()
	
	-- Make sure it's castable
	if ( not abilityQ:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nRadius    = abilityQ:GetAOERadius();
	local nCastRange = abilityQ:GetCastRange() - 50;
	local nCastPoint = abilityQ:GetCastPoint();
	local nManaCost  = abilityQ:GetManaCost();
	local nDamage    = abilityQ:GetAbilityDamage();
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 150, true, BOT_MODE_NONE );
	local nEnemysHeroesInView = npcBot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE );
	
	
	--if we can kill any enemies
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if J.CanCastOnNonMagicImmune(npcEnemy) and J.CanKillTarget(npcEnemy, nDamage, DAMAGE_TYPE_MAGICAL) then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation();
		end
	end
	 
	if J.IsFarming(npcBot) and npcBot:GetMana() > 150
	then
		local npcTarget = J.GetProperTarget(npcBot);
		if J.IsValid(npcTarget)
		   and npcTarget:GetTeam() == TEAM_NEUTRAL
		   and npcTarget:GetMagicResist() < 0.4
		then
			local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
			if ( locationAoE.count >= 2 ) 
			then
				return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
			end
		end
	end	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(npcBot)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange - 100, nRadius, 0, 0 );
		if ( locationAoE.count >= 2  ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
		if J.IsValidHero(tableNearbyEnemyHeroes[1]) 
			and J.CanCastOnNonMagicImmune(tableNearbyEnemyHeroes[1])
			and J.IsInRange(npcBot,tableNearbyEnemyHeroes[1],nCastRange - 100)
		then
			return BOT_ACTION_DESIRE_HIGH, tableNearbyEnemyHeroes[1]:GetLocation();
		end
	end
	
	if ( J.IsPushing(npcBot) or J.IsDefending(npcBot) or J.IsFarming(npcBot)) 
	    and J.IsAllowedToSpam(npcBot, nManaCost *0.3)
		and npcBot:GetLevel() >= 6 
		and #nEnemysHeroesInView == 0
	then
		local lanecreeps = npcBot:GetNearbyLaneCreeps(nCastRange+200, true);
		local allyHeroes  = npcBot:GetNearbyHeroes(1000,true,BOT_MODE_NONE);
		if #lanecreeps >= 2 
		   and #allyHeroes <= 2 
		   and J.IsValid(lanecreeps[1])
		then
			local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, nDamage );
			if ( locationAoE.count >= 2 and #lanecreeps >= 2  and npcBot:GetLevel() < 25 and #allyHeroes == 1) 
			then
				return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
			end
			local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
			if ( locationAoE.count >= 4 and #lanecreeps >= 4  ) 
			then
				return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
			end
		end
	end
	
	if J.IsInTeamFight(npcBot, 1200)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius - 30, 0, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
		end
		
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;				
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if  J.IsValid(npcEnemy)
				and J.IsInRange(npcTarget, npcBot, nCastRange) 
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
			then
				local npcEnemyDamage = npcEnemy:GetEstimatedDamageToTarget( false, npcBot, 3.0, DAMAGE_TYPE_PHYSICAL );
				if ( npcEnemyDamage > nMostDangerousDamage )
				then
					nMostDangerousDamage = npcEnemyDamage;
					npcMostDangerousEnemy = npcEnemy;
				end
			end
		end
		
		if ( npcMostDangerousEnemy ~= nil )
		then
			return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy:GetExtrapolatedLocation(nCastPoint);
		end		
	end

	-- If we're going after someone
	if J.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = J.GetProperTarget(npcBot);
		if J.IsValidHero(npcTarget) 
		   and J.CanCastOnNonMagicImmune(npcTarget) 
		   and J.IsInRange(npcTarget, npcBot, nCastRange - 100) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
	if npcBot:GetLevel() < 18
	then
		local lanecreeps = npcBot:GetNearbyLaneCreeps(nCastRange+200, true);
		local allyHeroes  = npcBot:GetNearbyHeroes(1000,true,BOT_MODE_NONE);
		if #lanecreeps >= 3 
		   and #allyHeroes < 3
		   and J.IsValid(lanecreeps[1])
		then
			local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, nDamage );
			if ( locationAoE.count >= 3 and #lanecreeps >= 3  ) 
			then
				return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end


function X.ConsiderW()

	if not abilityW:IsFullyCastable() then return 0 end
	
	local nSkillLV    = abilityW:GetLevel()
	local nCastRange  = abilityW:GetCastRange()
	local nCastPoint  = abilityW:GetCastPoint()
	local nManaCost   = abilityW:GetManaCost()
	local nDamage     = abilityW:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyHeroList = npcBot:GetNearbyHeroes(nCastRange +50, true, BOT_MODE_NONE);
           

	for _,npcEnemy in pairs(nInRangeEnemyHeroList)
	do
		if ( npcEnemy:IsCastingAbility() or npcEnemy:IsChanneling() )
		   and not npcEnemy:HasModifier("modifier_teleporting") 
		   and not npcEnemy:HasModifier("modifier_boots_of_travel_incoming")
		   and J.CanCastOnNonMagicImmune(npcEnemy)
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end	
	end
		   
	
	if J.IsInTeamFight(npcBot, 1200)
	then
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;
		
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 100, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if  J.IsValidHero(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and not J.IsDisabled(true, npcEnemy)
			then
				local npcEnemyDamage = npcEnemy:GetEstimatedDamageToTarget( false, npcBot, 3.0, DAMAGE_TYPE_MAGICAL );
				if ( npcEnemyDamage > nMostDangerousDamage )
				then
					nMostDangerousDamage = npcEnemyDamage;
					npcMostDangerousEnemy = npcEnemy;
				end
			end
		end
		
		if ( npcMostDangerousEnemy ~= nil )
		then
			return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy;
		end
		
	end
	
	
	if npcBot:WasRecentlyDamagedByAnyHero(3.0) 
		and nInRangeEnemyHeroList[1] ~= nil
		and #nInRangeEnemyHeroList >= 1
	then
		for _,npcEnemy in pairs( nInRangeEnemyHeroList )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and not J.IsDisabled(true, npcEnemy) 
				and npcBot:IsFacingLocation(npcEnemy:GetLocation(),40)
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	
	if J.IsGoingOnSomeone(npcBot)
	then
		if J.IsValidHero(hBotTarget) 
			and J.CanCastOnNonMagicImmune(hBotTarget) 
			and J.IsInRange(hBotTarget, npcBot, nCastRange) 
			and not J.IsDisabled(true, hBotTarget)
		then
			return BOT_ACTION_DESIRE_HIGH, hBotTarget;
		end
	end
	
	
	if J.IsRetreating(npcBot) 
	then
		for _,npcEnemy in pairs( nInRangeEnemyHeroList )
		do
			if J.IsValid(npcEnemy)
			    and npcBot:WasRecentlyDamagedByHero( npcEnemy, 3.1 ) 
				and J.CanCastOnNonMagicImmune(npcEnemy) 
				and not J.IsDisabled(true, npcEnemy) 
				and J.IsInRange(npcEnemy, npcBot, nCastRange) 
				and ( not J.IsInRange(npcEnemy, npcBot, 450) or npcBot:IsFacingLocation(npcEnemy:GetLocation(), 45) )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	
	if  npcBot:GetActiveMode() == BOT_MODE_ROSHAN 
	    and npcBot:GetMana() >= 1200
		and abilityW:GetLevel() >= 3
	then
		if  J.IsRoshan(hBotTarget) 
			and J.IsInRange(hBotTarget, npcBot, nCastRange)
		then
			return BOT_ACTION_DESIRE_HIGH, hBotTarget;
		end
	end
	
	
	return BOT_ACTION_DESIRE_NONE;
	
end

function X.ConsiderE()

	if not abilityE:IsFullyCastable() then return 0 end

    local nRadius = 300
	local castRange = abilityE:GetCastRange() 
	local target  = J.GetProperTarget(npcBot);
    local aTarget = npcBot:GetAttackTarget(); 
	local enemies = npcBot:GetNearbyHeroes(castRange, true, BOT_MODE_NONE);
	
	if J.IsInTeamFight(npcBot, 1200)
	then
		local npcMostAoeEnemy = nil;
		local nMostAoeECount  = 1;
		local nEnemysHerosInRange = npcBot:GetNearbyHeroes(castRange + 43,true,BOT_MODE_NONE);
		local nEmemysCreepsInRange = npcBot:GetNearbyCreeps(castRange + 43,true);
		local nAllEnemyUnits = J.CombineTwoTable(nEnemysHerosInRange,nEmemysCreepsInRange);
		
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;		
		
		for _,npcEnemy in pairs( nAllEnemyUnits )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
			then
				
				local nEnemyHeroCount = J.GetAroundTargetEnemyHeroCount(npcEnemy, nRadius);
				if ( nEnemyHeroCount > nMostAoeECount )
				then
					nMostAoeECount = nEnemyHeroCount;
					npcMostAoeEnemy = npcEnemy;
				end
				
				if npcEnemy:IsHero()
				then
					local npcEnemyDamage = npcEnemy:GetEstimatedDamageToTarget( false, npcBot, 3.0, DAMAGE_TYPE_MAGICAL );
					if ( npcEnemyDamage > nMostDangerousDamage )
					then
						nMostDangerousDamage = npcEnemyDamage;
						npcMostDangerousEnemy = npcEnemy;
					end
				end
			end
		end
		
		if ( npcMostAoeEnemy ~= nil )
		then
			for _,npcAlly in pairs( npcMostAoeEnemy:GetNearbyHeroes(castRange, true, BOT_MODE_NONE) )
			do
				if  J.IsValid(npcAlly)
					and J.CanCastOnNonMagicImmune(npcAlly) 
				then
					return BOT_MODE_DESIRE_MODERATE, npcAlly;
				end
			end
		end	

		if ( npcMostDangerousEnemy ~= nil )
		then
			for _,npcAlly in pairs( npcMostDangerousEnemy:GetNearbyHeroes(castRange, true, BOT_MODE_NONE) )
			do
				if  J.IsValid(npcAlly)
					and J.CanCastOnNonMagicImmune(npcAlly) 
				then
					return BOT_MODE_DESIRE_MODERATE, npcAlly;
				end
			end
		end	
	end

	--对线期间对敌方英雄使用
	if npcBot:GetActiveMode() == BOT_MODE_LANING
	then
		for _,npcEnemy in pairs( enemies )
		do
			if  J.IsValid(npcEnemy)
				and J.CanCastOnNonMagicImmune(npcEnemy) 
				and not J.IsDisabled(true, npcEnemy)
				and J.GetEnemyUnitCountAroundTarget(npcEnemy, 600) >= 4
			then
				for _,npcAlly in pairs( npcEnemy:GetNearbyHeroes(castRange, true, BOT_MODE_NONE) )
				do
					if  J.IsValid(npcAlly)
						and J.CanCastOnNonMagicImmune(npcAlly) 
					then
						return BOT_ACTION_DESIRE_HIGH, npcAlly;
					end
				end
			end
		end
	end
	
	if ( J.IsPushing(npcBot) or J.IsDefending(npcBot) ) 
	then
		local creeps = npcBot:GetNearbyLaneCreeps(castRange, true);
		if #creeps >= 4 and creeps[1] ~= nil
		then
			local creep = creeps[1]:GetNearbyHeroes(castRange, true, BOT_MODE_NONE) 
			if creep ~= nil then
				for _,npcAlly in pairs( creep )
				do
					if  J.IsValid(npcAlly)
						and J.CanCastOnNonMagicImmune(npcAlly) 
					then
						return BOT_MODE_DESIRE_MODERATE, npcAlly;
					end
				end
			end
		end
	end

	
	if J.IsGoingOnSomeone(npcBot)
	then
		if J.IsValidHero(target) 
		   and J.CanCastOnNonMagicImmune(target) 
		   and J.IsInRange(target, npcBot, castRange) 
		then
			for _,npcAlly in pairs( target:GetNearbyHeroes(castRange, true, BOT_MODE_NONE) )
			do
				if  J.IsValid(npcAlly)
					and J.CanCastOnNonMagicImmune(npcAlly) 
				then
					return BOT_ACTION_DESIRE_HIGH, npcAlly;
				end
			end
		end	
	end
	
	return BOT_ACTION_DESIRE_NONE
	
end

function X.ConsiderD()
	
	if not npcBot:HasScepter() 
	   or not abilityD:IsFullyCastable() 
	   or npcBot:IsInvisible() 
	then
		return BOT_ACTION_DESIRE_NONE, nil;
	end

	--获取一些参数
	local nCastRange = abilityD:GetCastRange();		--施法范围
	local nCastPoint = abilityD:GetCastPoint();		--施法点
	local nManaCost   = abilityD:GetManaCost();		--魔法消耗
	local nSkillLV    = abilityD:GetLevel();    	--技能等级 

	local nEnemysHerosInRange = npcBot:GetNearbyHeroes(nCastRange ,true,BOT_MODE_NONE); --获得施法范围内敌人
	
	
	--团战中对战力最高的敌人使用
	if J.IsInTeamFight(npcBot, 1200)
	then
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;		
		
		for _,npcEnemy in pairs( nEnemysHerosInRange )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and not J.IsDisabled(true, npcEnemy)
				and not npcEnemy:IsDisarmed()
			then
				local npcEnemyDamage = npcEnemy:GetEstimatedDamageToTarget( false, npcBot, 3.0, DAMAGE_TYPE_PHYSICAL );
				if ( npcEnemyDamage > nMostDangerousDamage )
				then
					nMostDangerousDamage = npcEnemyDamage;
					npcMostDangerousEnemy = npcEnemy;
				end
			end
		end
		
		if ( npcMostDangerousEnemy ~= nil )
		then
			return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy;
		end		
	end

	--对线期间对敌方英雄使用
	if npcBot:GetActiveMode() == BOT_MODE_LANING
	then
		for _,npcEnemy in pairs( nEnemysHerosInRange )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and not J.IsDisabled(true, npcEnemy)
				and J.GetAttackTargetEnemyCreepCount(npcEnemy, 600) >= 4
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end	
	end

	--打架时先手	
	if J.IsGoingOnSomeone(npcBot)
	then
	    local npcTarget = J.GetProperTarget(npcBot);
		if J.IsValidHero(npcTarget) 
			and J.CanCastOnNonMagicImmune(npcTarget) 
			and J.IsInRange(npcTarget, npcBot, nCastRange +80) 
			and not J.IsDisabled(true, npcTarget)
			and not npcTarget:IsDisarmed()
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end


	return BOT_ACTION_DESIRE_NONE, nil;
end

function X.ConsiderR()

	if not abilityR:IsFullyCastable() then return 0 end

	-- Get some of its values
	local nRadius    = 550;
	local nCastRange = abilityR:GetCastRange();
	local nCastPoint = abilityR:GetCastPoint();
	local nManaCost  = abilityR:GetManaCost();
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );

	--有把握在困住后击杀
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		local tableEnemyAllyHeroes = npcEnemy:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE );
		if  J.IsValid(npcEnemy) and J.CanCastOnNonMagicImmune(npcEnemy) and J.IsOtherAllyCanKillTarget(npcBot, npcEnemy) and #tableEnemyAllyHeroes >= 2
		then
			return BOT_MODE_DESIRE_MODERATE, npcEnemy;
		end
	end

	--团战
	if J.IsInTeamFight(npcBot, 1200)
	then
		for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
		do
			local tableEnemyAllyHeroes = npcEnemy:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE );
			if  J.IsValid(npcEnemy) and J.CanCastOnNonMagicImmune(npcEnemy) and #tableEnemyAllyHeroes >= 2
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end

return X
