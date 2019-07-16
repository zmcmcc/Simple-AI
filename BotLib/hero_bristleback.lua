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
						{2,3,1,2,2,6,2,3,3,3,6,1,1,1,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)

X['skills'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)

X['items'] = {
				'item_stout_shield', 
				sOutfit,
				"item_crimson_guard",
				"item_heavens_halberd",
				"item_lotus_orb",
				"item_assault", 
--				"item_heart",
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


local castQDesire, castQTarget
local castWDesire

local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;


function X.SkillsComplement()

	
	if J.CanNotUseAbility(npcBot) or npcBot:IsInvisible() then return end

	
	
	nKeepMana = 180
	nMP = npcBot:GetMana()/npcBot:GetMaxMana();
	nHP = npcBot:GetHealth()/npcBot:GetMaxHealth();
	nLV = npcBot:GetLevel();
	hEnemyHeroList = npcBot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	
	
	
	
	castQDesire, castQTarget   = X.ConsiderQ();
	if ( castQDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, true)
		
		if npcBot:HasScepter() 
		then
			npcBot:ActionQueue_UseAbility( abilityQ )
		else
			npcBot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget )
		end
		return;
	end
	
	castWDesire = X.ConsiderW();
	if ( castWDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, true)
	
		npcBot:ActionQueue_UseAbility( abilityW )
		return;
	end
	

end


function X.ConsiderQ()

	-- Make sure it's castable
	if ( not abilityQ:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0; 
	end

	-- Get some of its values
	local nRadius    = abilityQ:GetSpecialValueInt('radius_scepter');
	local nCastRange = abilityQ:GetCastRange();
	local nCastPoint = abilityQ:GetCastPoint( );
	local nManaCost  = abilityQ:GetManaCost( );
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
	local nEnemyHeroes = npcBot:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(npcBot) and nHP > 0.3
	then
		local npcEnemy = tableNearbyEnemyHeroes[1];
		if J.IsValid(npcEnemy) 
			and (npcBot:IsFacingLocation(npcEnemy:GetLocation(),10) or #nEnemyHeroes <= 1)
			and npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) 
			and J.CanCastOnNonMagicImmune(npcEnemy)
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end  
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( J.IsRoshan(npcTarget) and J.CanCastOnMagicImmune(npcTarget) and J.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget;
		end
	end

	if J.IsInTeamFight(npcBot, 1200) and npcBot:HasScepter()
	then
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 then
			return BOT_ACTION_DESIRE_LOW, tableNearbyEnemyHeroes[1];
		end
	end
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = J.GetProperTarget(npcBot);
		if J.IsValidHero(npcTarget) and J.CanCastOnNonMagicImmune(npcTarget) and J.IsInRange(npcTarget, npcBot, nRadius) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
		
		if J.IsValid(npcTarget) 
		   and J.IsAllowedToSpam(npcBot, nManaCost) 
		   and J.CanCastOnNonMagicImmune(npcTarget) 
		   and J.IsInRange(npcTarget, npcBot, nRadius) 
		   and not J.CanKillTarget(npcTarget,npcBot:GetAttackDamage() *1.38,DAMAGE_TYPE_PHYSICAL)
		then
			local nCreeps = npcBot:GetNearbyCreeps(800,true);
			if #nCreeps >= 1
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
			 
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end


function X.ConsiderW()

	-- Make sure it's castable
	if ( not abilityW:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end

	-- Get some of its values
	local nRadius    = abilityW:GetSpecialValueInt( "radius" );
	local nCastPoint = abilityW:GetCastPoint( );
	local nManaCost  = abilityW:GetManaCost( );
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(npcBot) and #tableNearbyEnemyHeroes > 0
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) 
				or npcEnemy:HasModifier("modifier_bristleback_quill_spray")
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	-- If we're doing Roshan
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( J.IsRoshan(npcTarget) and J.CanCastOnMagicImmune(npcTarget) and J.IsInRange(npcBot, npcTarget, nRadius)  )
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	-- If We're pushing or defending
	if J.IsPushing(npcBot) or J.IsDefending(npcBot) or J.IsGoingOnSomeone(npcBot)
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps( nRadius, true );
		if ( tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 1 and J.IsAllowedToSpam(npcBot, nManaCost) ) then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if J.IsInTeamFight(npcBot, 1200)
	then
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = J.GetProperTarget(npcBot);
		if J.IsValidHero(npcTarget) and J.CanCastOnMagicImmune(npcTarget) and J.IsInRange(npcTarget, npcBot, nRadius-100)
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
		
		if J.IsValid(npcTarget) 
		   and J.IsAllowedToSpam(npcBot, nManaCost) 
		   and J.CanCastOnNonMagicImmune(npcTarget) 
		   and J.IsInRange(npcTarget, npcBot, nRadius) 
		then
			local nCreeps = npcBot:GetNearbyCreeps(800,true);
			if #nCreeps >= 1
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end

	-- If mana is too much
	if nMP > 0.95
		and nLV >= 6
		and npcBot:DistanceFromFountain() > 2400
	then
		return BOT_ACTION_DESIRE_LOW;
	end
	
	return BOT_ACTION_DESIRE_NONE;

end

return X
-- dota2jmz@163.com QQ:2462331592.
