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
						['t15'] = {10, 0},
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{2,3,1,1,1,6,1,3,3,3,6,2,2,2,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)

X['skills'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)

X['items'] = {
				'item_stout_shield', 
				sOutfit,
				"item_crimson_guard",
				"item_heavens_halberd",
--				"item_black_king_bar",
				"item_assault",
				"item_heart",
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
local abilityR = npcBot:GetAbilityByName( sAbilityList[6] )


local castQDesire, castQLocation
local castWDesire, castWTarget
local castRDesire

local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;


function X.SkillsComplement()


	
	
	if J.CanNotUseAbility(npcBot) or npcBot:IsInvisible() then return end
	
	
	
	nKeepMana = 400
	nMP = npcBot:GetMana()/npcBot:GetMaxMana();
	nHP = npcBot:GetHealth()/npcBot:GetMaxHealth();
	nLV = npcBot:GetLevel();
	hEnemyHeroList = npcBot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
		
	
	
	
	castRDesire  = X.ConsiderR();
	if ( castRDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, false)
	
		npcBot:ActionQueue_UseAbility( abilityR )
		return;
	
	end
	
	castQDesire, castQLocation   = X.ConsiderQ();
	if ( castQDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, true)
	
		npcBot:ActionQueue_UseAbilityOnLocation( abilityQ, castQLocation )
		return;
	end
	
	castWDesire, castWTarget = X.ConsiderW();
	if ( castWDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, true)
	
		npcBot:ActionQueue_UseAbilityOnEntity( abilityW, castWTarget )
		return;
	end
	

end

function X.ConsiderQ()

	-- Make sure it's castable
	if ( not abilityQ:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nRadius    = abilityQ:GetSpecialValueInt('end_radius');
	local nCastRange = abilityQ:GetSpecialValueInt( 'range' );
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
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( J.IsRoshan(npcTarget) and J.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation();
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
		   and not lanecreeps[1]:HasModifier("modifier_fountain_glyph")
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
		   and not lanecreeps[1]:HasModifier("modifier_fountain_glyph")
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

	-- Make sure it's castable
	if ( not abilityW:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityW:GetCastRange( );
	local nCastPoint = abilityW:GetCastPoint( );
	local nManaCost  = abilityW:GetManaCost( );
	local nDamage    = abilityW:GetAbilityDamage( );
	
	if npcBot:GetAttackRange() > 300
	then
		nCastRange = 400;
	end
		
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 100, true, BOT_MODE_NONE );
	
	--if we can kill any enemies
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if J.CanCastOnNonMagicImmune(npcEnemy) and ( J.CanKillTarget(npcEnemy, nDamage, DAMAGE_TYPE_MAGICAL) or npcEnemy:IsChanneling() ) then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	
	--if enemy is channeling
	local nEnemysHeroesInView = npcBot:GetNearbyHeroes(800,true,BOT_MODE_NONE);
	if #nEnemysHeroesInView > 0 then
		for i=1, #nEnemysHeroesInView do
			if J.IsValid(nEnemysHeroesInView[i])
			   and J.CanCastOnNonMagicImmune(nEnemysHeroesInView[i]) 
			   and nEnemysHeroesInView[i]:IsChanneling()
			then
				return BOT_ACTION_DESIRE_HIGH, nEnemysHeroesInView[i];
			end
		end
	end
	
	if J.IsInTeamFight(npcBot, 1200)
	then
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;		
		
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
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
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(npcBot)
	then
		if tableNearbyEnemyHeroes ~= nil 
		   and #tableNearbyEnemyHeroes >= 1 
		   and J.CanCastOnNonMagicImmune(tableNearbyEnemyHeroes[1]) 
		then
			return BOT_ACTION_DESIRE_HIGH, tableNearbyEnemyHeroes[1];
		end
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( J.IsRoshan(npcTarget) 
			 and J.IsInRange(npcTarget, npcBot, nCastRange + 150) 
             and not J.IsDisabled(true, npcTarget) )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget;
		end
	end
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = J.GetProperTarget(npcBot);
		if J.IsValidHero(npcTarget) 
		    and J.CanCastOnNonMagicImmune(npcTarget) 
			and J.IsInRange(npcTarget, npcBot, nCastRange + 200) 
            and not J.IsDisabled(true, npcTarget) 		
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function X.ConsiderR()

	-- Make sure it's castable
	if ( not abilityR:IsFullyCastable() or J.GetHPR(npcBot) < 0.25 ) then 
		return BOT_ACTION_DESIRE_NONE;
	end

	-- Get some of its values
	local nCastPoint = abilityR:GetCastPoint( );
	local nManaCost  = abilityR:GetManaCost( );

	-- If We're pushing or defending
	if ( J.IsPushing(npcBot) or J.IsFarming(npcBot) or J.IsDefending(npcBot) ) 
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyCreeps( 800, true );
		local tableNearbyTowers = npcBot:GetNearbyTowers( 800, true );
		if #tableNearbyEnemyCreeps >= 2 or #tableNearbyTowers >= 1 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = J.GetProperTarget(npcBot);
		if J.IsValidHero(npcTarget) 
		   and J.IsInRange(npcTarget, npcBot, 800)
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end

return X
-- dota2jmz@163.com QQ:2462331592.
