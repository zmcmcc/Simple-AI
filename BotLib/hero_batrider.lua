local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local Minion = dofile( GetScriptDirectory()..'/FunLib/Minion')
local sTalentList = J.Skill.GetTalentList(bot)
local sAbilityList = J.Skill.GetAbilityList(bot)
local sOutfit = J.Skill.GetOutfitName(bot)

local tTalentTreeList = {
						['t25'] = {10, 0},
						['t20'] = {10, 0},
						['t15'] = {10, 0},
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{1,3,1,2,1,6,1,3,3,3,6,2,2,2,6},
						{1,3,1,3,3,6,3,1,1,2,6,2,2,2,6},
						{1,3,3,2,3,6,3,2,2,2,6,1,1,1,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)


X['sBuyList'] = {
				sOutfit,
				"item_blink",
				"item_force_staff",
				"item_black_king_bar",
				"item_cyclone",
				"item_ultimate_scepter",
				"item_hurricane_pike",
				"item_octarine_core",
}

X['sSellList'] = {
	"item_cyclone",
	"item_magic_wand",
}

nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList'] = J.SetUserHeroInit(nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList']);

X['sSkillList'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = true

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit(hMinionUnit) 
	then
		Minion.IllusionThink(hMinionUnit)
	end

end

local abilityQ = bot:GetAbilityByName( sAbilityList[1] );
local abilityW = bot:GetAbilityByName( sAbilityList[2] );
local abilityE = bot:GetAbilityByName( sAbilityList[3] );
local abilityR = bot:GetAbilityByName( sAbilityList[6] );


local castQDesire, castQLocation
local castWDesire, castWLocation
local castEDesire
local castRDesire, castRTarget
local castBlinkDesire, itemBlink, castBlinkLocation
local castForceDesire, itemForce, castForceTarget

local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;

function X.SkillsComplement()
	
	
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
	
	
	nKeepMana = 400; 
	nLV = bot:GetLevel();
	nMP = bot:GetMana()/bot:GetMaxMana();
	nHP = bot:GetHealth()/bot:GetMaxHealth();
	hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	
	
	castForceDesire, itemForce, castForceTarget = X.ConsiderF()
	if ( castForceDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, true)
	
		bot:ActionQueue_UseAbilityOnEntity( itemForce, castForceTarget )
		return;
	end

	castBlinkDesire, itemBlink, castBlinkLocation = X.ConsiderB()
	if ( castBlinkDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, true)
	
		bot:ActionQueue_UseAbilityOnLocation( itemBlink, castBlinkLocation )
		return;
	end

	castRDesire, moveRLocation, castRTarget = X.ConsiderR()
	if ( castRDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, true)
	
		bot:ActionQueue_UseAbilityOnEntity( abilityR, castRTarget )
		if moveRLocation ~= nil then
			bot:ActionQueue_MoveDirectly( moveRLocation )
		end
		return;
	end
	
	
	castEDesire = X.ConsiderE()
	if ( castEDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, true)
	
		bot:ActionQueue_UseAbility( abilityE )
		return;
	end
	
	
	castWDesire, castWLocation = X.ConsiderW()
	if ( castWDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, true)
	
		bot:ActionQueue_UseAbilityOnLocation( abilityW, castWLocation )
		return;
	end
	
	castQDesire, castQLocation = X.ConsiderQ()
	if ( castQDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, true)
	
		bot:ActionQueue_UseAbilityOnLocation( abilityQ, castQLocation )
		
		return;
	end
	

end

function X.ConsiderQ()

	if not abilityQ:IsFullyCastable() then return 0 end

	-- Get some of its values
	local nRadius = abilityQ:GetSpecialValueInt( "radius" );
	local nCastRange = abilityQ:GetCastRange();
	local nCastPoint = abilityQ:GetCastPoint( );

	--------------------------------------
	-- Mode based usage
	---------------------
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if bot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
			end
		end
	end
	
	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = bot:GetAttackTarget();
		if J.IsRoshan(npcTarget) and
		   J.CanCastOnMagicImmune(npcTarget) and
		   J.IsInRange(npcTarget, bot, nCastRange)
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetLocation();
		end
	end
	
	-- If we're pushing or defending a lane and can hit 6+ creeps, go for it
	if  ( bot:GetActiveMode() == BOT_MODE_LANING or
		  J.IsDefending(bot) or J.IsPushing(bot) )
		and nMP > 0.75
	then
		local lanecreeps = bot:GetNearbyLaneCreeps(nCastRange+200, true);
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if locationAoE.count >= 6 and
		   #lanecreeps >= 6
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end

	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if J.IsValidHero(npcTarget) and
		   J.CanCastOnNonMagicImmune(npcTarget) and
		   J.IsInRange(npcTarget, bot, nCastRange+200)
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nCastPoint );
		end
	end
	
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

function X.ConsiderW()

	if not abilityW:IsFullyCastable() then return 0 end

	-- Get some of its values
	local nRadius = abilityW:GetSpecialValueInt("explosion_radius");
	local nSpeed = abilityW:GetSpecialValueInt("speed");
	local nCastRange = abilityW:GetCastRange();
	local nCastPoint = abilityW:GetCastPoint();

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if bot:WasRecentlyDamagedByHero( npcEnemy, 1.0 )
			then
				if GetUnitToUnitDistance(npcEnemy, bot) < nRadius then
					return BOT_ACTION_DESIRE_LOW, bot:GetLocation()
				else
					return BOT_ACTION_DESIRE_LOW, npcEnemy:GetExtrapolatedLocation(nCastPoint)
				end
			end
		end
	end
	
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if J.IsValidHero(npcTarget) and
		   J.CanCastOnNonMagicImmune(npcTarget) and
		   J.IsInRange(npcTarget, bot, 1000)
		then
			local nDelay = ( GetUnitToUnitDistance( npcTarget, bot ) / nSpeed ) + nCastPoint
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation(nDelay);
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;

end


function X.ConsiderE()

	if not abilityE:IsFullyCastable() then return 0 end

	local nRadius = abilityE:GetSpecialValueInt( "radius" );
	
	if J.IsStuck(bot)
	then
		return BOT_ACTION_DESIRE_HIGH;
	end
	
	if bot:HasModifier('modifier_batrider_flaming_lasso_self') then
		return BOT_ACTION_DESIRE_HIGH;
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if bot:WasRecentlyDamagedByHero( npcEnemy, 1.0 )
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	if J.IsInTeamFight(bot, 1200)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE  );
		if tableNearbyEnemyHeroes ~= nil and
		   #tableNearbyEnemyHeroes >= 2
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if J.IsValidHero(npcTarget) and
		   J.CanCastOnNonMagicImmune(npcTarget) and
		   J.IsInRange(npcTarget, bot, 1000)
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE

end


function X.ConsiderR()

	if not abilityR:IsFullyCastable() then return 0 end

	-- Get some of its values
	local nCastRange = abilityR:GetCastRange();

	local tableAllyHeroes = bot:GetNearbyHeroes( 1600, false, BOT_MODE_NONE );
	local AllyLocation = nil
	if tableAllyHeroes ~= nil and #tableAllyHeroes >= 2 and tableAllyHeroes[1] ~= nil then AllyLocation = tableAllyHeroes[1]:GetLocation()
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if J.IsValidHero(npcTarget) and
		   J.CanCastOnMagicImmune(npcTarget) and
		   J.IsInRange(npcTarget, bot, nCastRange+200)
		then
			return BOT_ACTION_DESIRE_HIGH, AllyLocation, npcTarget;
		end
	end
	
	-- If we're in a teamfight, use it on the scariest enemy
	if J.IsInTeamFight(bot, 1200)
	then
		local npcToKill = nil;
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if J.CanCastOnMagicImmune(npcEnemy) and
			   J.IsInRange(npcEnemy, bot, nCastRange+200)
			then
				npcToKill = npcEnemy;
			end
		end
		if ( npcToKill ~= nil  )
		then
			return BOT_ACTION_DESIRE_HIGH, AllyLocation, npcToKill;
		end
	end
	
	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if J.CanCastOnMagicImmune(npcEnemy)
		then
			return BOT_ACTION_DESIRE_HIGH, AllyLocation, npcEnemy;
		end
	end

	
	return BOT_ACTION_DESIRE_NONE

end

function X.ConsiderB()
	local blink = nil;
	
	for i=0,5 do
		local item = bot:GetItemInSlot(i)
		if item ~= nil and item:GetName() == 'item_blink' then
			blink = item;
			break
		end
	end
	
	if J.IsGoingOnSomeone(bot) and blink ~= nil and blink:IsFullyCastable() and abilityFL:IsFullyCastable()
	then
		local npcTarget = bot:GetTarget();
		if ( J.IsValidHero(npcTarget) and J.CanCastOnNonMagicImmune(npcTarget) and not J.IsInRange(npcTarget, bot, 600) and J.IsInRange(npcTarget, bot, 1000) ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, blink, npcTarget:GetExtrapolatedLocation(0.1);
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil, nil;
end

function X.ConsiderF()
	local force = nil;
	
	for i=0,5 do
		local item = bot:GetItemInSlot(i)
		if item ~= nil and item:GetName() == 'item_force_staff' then
			force = item;
			break
		end
	end
	
	if force ~= nil and force:IsFullyCastable() and bot:HasModifier('modifier_batrider_flaming_lasso_self') and bot:IsFacingLocation(J.GetTeamFountain(),10)
	then
		return BOT_ACTION_DESIRE_MODERATE, force, bot
	end
	
	return BOT_ACTION_DESIRE_NONE, nil, nil;
end

return X
-- dota2jmz@163.com QQ:2462331592
