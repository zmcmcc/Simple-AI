local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local ConversionMode = dofile( GetScriptDirectory()..'/AuxiliaryScript/BotlibConversion') --引入技能文件
local Minion = dofile( GetScriptDirectory()..'/FunLib/Minion')
local sTalentList = J.Skill.GetTalentList(bot)
local sAbilityList = J.Skill.GetAbilityList(bot)
local illuOrbLoc = nil

local tGroupedDataList = {
	{
		--组合说明，不影响游戏
		['info'] = 'Misunderstand锦囊内容',
		--天赋树
		['Talent'] = {
			['t25'] = {0, 10},
			['t20'] = {10,10},
			['t15'] = {10,10},
			['t10'] = {0, 10},
		},
		--技能
		['Ability'] = { 1, 3, 1, 2, 1, 6, 1, 2, 2, 2, 6, 3, 3, 3, 6 },
		--装备
		['Buy'] = {
			"item_mantle",
			"item_double_circlet",
			"item_enchanted_mango",
			"item_tango",
			"item_bottle",
			"item_null_talisman",
			"item_double_enchanted_mango",
			"item_clarity",
			"item_blink",
			"item_clarity",
			"item_cyclone",
			"item_dagon",
			"item_sphere",
			"item_ultimate_scepter",
			"item_dagon_2",
			"item_maelstrom",
			"item_ultimate_scepter_2",
			"item_mjollnir",
			"item_dagon_3",
			"item_dagon_5",
			"item_travel_boots_2",
			"item_moon_shard",
		},
		--出售
		['Sell'] = {
			"item_blink",
			"item_circlet",

			"item_sphere",
			"item_bottle",
			
			"item_ultimate_scepter",
			"item_null_talisman",

			"item_travel_boots",
			"item_power_treads",
		}
	}
}
--默认数据
local tDefaultGroupedData = {
	['Talent'] = {
		['t25'] = {10, 0},
		['t20'] = {0, 10},
		['t15'] = {0, 10},
		['t10'] = {10, 0},
	},
	['Ability'] = {1,3,1,2,2,6,1,2,1,2,6,3,3,3,6},
	['Buy'] = {
		"item_tango",
		"item_flask",
		"item_double_branches",
		"item_enchanted_mango",
		"item_clarity",
		"item_magic_wand" ,
		"item_boots",
		"item_veil_of_discord",
		"item_blink",
		"item_cyclone",
		"item_ultimate_scepter",
		"item_sheepstick",
		"item_octarine_core",
	},
	['Sell'] = {
		"item_travel_boots_1",
		"item_boots",
	}
}

local nAbilityBuildList, nTalentBuildList;

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = ConversionMode.Combination(tGroupedDataList, tDefaultGroupedData)

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

local abilityQ = bot:GetAbilityByName( sAbilityList[1] );
local abilityW = bot:GetAbilityByName( sAbilityList[2] );
local abilityE = bot:GetAbilityByName( sAbilityList[3] );
local abilityQ2 = bot:GetAbilityByName( sAbilityList[4] );
local abilityR = bot:GetAbilityByName( sAbilityList[6] );

local itemForce = "item_force_staff";
local itemBlink = "item_blink";

local castQDesire,castQLocation = 0;
local castWDesire = 0;
local castEDesire = 0;
local castRDesire,castRLocation = 0;
local castQ2Desire = 0;

local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;

function X.SkillsComplement()

	if X.ConsiderStop() == true 
	then 
		bot:Action_ClearActions(true);
		return; 
	end
	
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
	
	
	nKeepMana = 400; 
	nMP = bot:GetMana()/bot:GetMaxMana();
	nHP = bot:GetHealth()/bot:GetMaxHealth();
	nLV = bot:GetLevel();
	hEnemyHeroList = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	
	castQDesire, castQLocation   = X.ConsiderQ();
	if ( castQDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, false)
		illuOrbLoc = castQLocation
		bot:ActionQueue_UseAbilityOnLocation( abilityQ, castQLocation )
		return;
	end

	castQ2Desire = X.ConsiderQ2();
	if ( castQ2Desire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, false)
	
		bot:ActionQueue_UseAbility(abilityQ2)
		return;
	end
	
	castRDesire, castRLocation   = X.ConsiderR();
	if ( castRDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, false)
	
		bot:ActionQueue_UseAbilityOnLocation( abilityR, castRLocation )
		return;
	end
	
	castWDesire = X.ConsiderW();
	if ( castWDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, false)
	
		bot:ActionQueue_UseAbility( abilityW )
		return;
	end
	
	castEDesire   = X.ConsiderE();
	if ( castEDesire > 0 ) 
	then
	
		bot:Action_ClearActions(false);
	
		bot:ActionQueue_UseAbility( abilityE )
		return;
		
	end

	castForceDesire, castForceTarget = X.ConsiderF()
	if ( castForceDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, true)
	
		performForceEnemy(castForceTarget)
		return;
	end

	castBlinkDesire, castBlinkLocation = X.ConsiderB()
	if ( castBlinkDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, true)
	
		performBlinkInit(castBlinkLocation)
		return;
	end


end

function X.ConsiderStop()
	
	if bot:HasModifier("modifier_puck_phase_shift")
	then
		local tableEnemyHeroes = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
		local tableAllyHeroes  = bot:GetNearbyHeroes(1600,false,BOT_MODE_NONE);
		if #tableEnemyHeroes >= 0
		then
			return true;
		end

		local incProj = bot:GetIncomingTrackingProjectiles()
		for _,p in pairs(incProj)
		do
			if GetUnitToLocationDistance(bot, p.location) >= 0 and ( p.is_attack or p.is_dodgeable ) then
				return true;
			end
		end
	end
	return false;
end

function X.ConsiderQ()
	
	-- Make sure it's castable
	if ( not abilityQ:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- If we want to cast Phase Shift at all, bail
	if ( castEDesire > 0 or castRDesire > 50 ) 
	then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local RB = Vector(-7200,-6666)
	local DB = Vector(7137,6548)
	
	-- Get some of its values
	local nRadius = abilityQ:GetSpecialValueInt( "radius" );
	local nCastRange = abilityQ:GetCastRange();
	local nDamage = abilityQ:GetAbilityDamage();
	
	nCastRange = 1600;
	
	if ( bot:GetActiveMode() == BOT_MODE_RETREAT and bot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				local loc = J.GetEscapeLoc();
				if bot:IsFacingLocation( loc, nCastRange ) then
					return BOT_ACTION_DESIRE_HIGH, loc;
				end
			end
		end
	end
	
	-- If we're going after someone
	if ( bot:GetActiveMode() == BOT_MODE_ROAM or
		 bot:GetActiveMode() == BOT_MODE_ATTACK or
		 bot:GetActiveMode() == BOT_MODE_GANK or
		 bot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcTarget;

		if ( npcTarget ~= nil and npcTarget:IsHero() and J.CanCastOnMagicImmune( npcTarget ) and GetUnitToUnitDistance( bot, npcTarget ) < nCastRange ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation();
		end
	end

	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if ( bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT or
		 bot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 bot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 bot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT ) 
	then
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange/2, nRadius, 0, 0 );
		if ( locationAoE.count >= 4 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end

	-- If mana is full and we're laning just hit hero
	if ( bot:GetActiveMode() == BOT_MODE_LANING and 
		bot:GetMana() == bot:GetMaxMana() ) 
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
		if(tableNearbyEnemyHeroes[1] ~= nil) then
			return BOT_ACTION_DESIRE_LOW, tableNearbyEnemyHeroes[1]:GetLocation();
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;

end

function X.ConsiderQ2()

	-- Make sure it's castable
	if ( not abilityQ2:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	if ( bot:GetActiveMode() == BOT_MODE_ROAM or
		 bot:GetActiveMode() == BOT_MODE_ATTACK or
		 bot:GetActiveMode() == BOT_MODE_GANK or
		 bot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcTarget;
		if ( npcTarget ~= nil ) then
			local pro = GetLinearProjectiles();
			for _,pr in pairs(pro)
			do
				if pr.ability:GetName() == "puck_illusory_orb" then
					local ProjDist = GetUnitToLocationDistance(npcTarget, pr.location);
					if ProjDist < pr.radius then
						return BOT_ACTION_DESIRE_MODERATE;
					end
				end	
			end
		end
		
	end
	
	if ( bot:GetActiveMode() == BOT_MODE_RETREAT and bot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local pro = GetLinearProjectiles();
		for _,pr in pairs(pro)
		do
			if pr.ability:GetName() == "puck_illusory_orb" then
				local ProjDist = GetDistance(illuOrbLoc, pr.location);
				if ProjDist < 100 then
					return BOT_ACTION_DESIRE_MODERATE;
				end
			end	
		end	
	end
	
	return BOT_ACTION_DESIRE_NONE;

end

function X.ConsiderW()
	-- Make sure it's castable
	if not abilityW:IsFullyCastable()  then 
		return BOT_ACTION_DESIRE_NONE;
	end

	-- Get some of its values
	local nRadius    = abilityW:GetSpecialValueInt( "radius" );
	local nCastPoint = abilityW:GetCastPoint( );
	local nManaCost  = abilityW:GetManaCost( );
	
	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot) and #tableNearbyEnemyHeroes > 0
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if bot:WasRecentlyDamagedByHero( npcEnemy, 1.0 )
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	-- If We're pushing or defending
	if J.IsPushing(bot) 
	   or J.IsDefending(bot) 
	   or ( J.IsGoingOnSomeone(bot) and nLV >= 6 ) 
	then
		local tableNearbyEnemyCreeps = bot:GetNearbyLaneCreeps( nRadius, true );
		if ( tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 1 and J.IsAllowedToSpam(bot, nManaCost) ) then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if J.IsFarming(bot) and nLV > 5
	   and J.IsAllowedToSpam(bot, nManaCost)
	then
		local npcTarget = J.GetProperTarget(bot);
		if J.IsValid(npcTarget)
		   and npcTarget:GetTeam() == TEAM_NEUTRAL
		then
			if npcTarget:GetHealth() > bot:GetAttackDamage() * 2.28
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		
			local nCreeps = bot:GetNearbyCreeps(nRadius, true);
			if ( #nCreeps >= 2 ) 
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	if J.IsInTeamFight(bot, 1200)
	then
		if #tableNearbyEnemyHeroes >= 1 
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = J.GetProperTarget(bot);
		if J.IsValidHero(npcTarget) 
		   and J.CanCastOnMagicImmune(npcTarget) 
		   and J.IsInRange(npcTarget, bot, nRadius-100)
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
		
		if J.IsValidHero(npcTarget) 
		   and J.IsAllowedToSpam(bot, nManaCost) 
		   and J.CanCastOnNonMagicImmune(npcTarget) 
		   and J.IsInRange(npcTarget, bot, nRadius) 
		then
			local nCreeps = bot:GetNearbyCreeps(800,true);
			if #nCreeps >= 1
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end

	-- If mana is too much
	if nMP > 0.95
		and nLV >= 6
		and bot:DistanceFromFountain() > 2400
		and J.IsAllowedToSpam(bot, nManaCost) 
	then
		return BOT_ACTION_DESIRE_LOW;
	end
	
	return BOT_ACTION_DESIRE_NONE;

end

function X.ConsiderE()
	-- Make sure it's castable
	if ( not abilityE:IsFullyCastable() and not bot:HasModifier("modifier_puck_phase_shift") ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	if J.IsUnitTargetProjectileIncoming(bot, 1)
	then
		return BOT_ACTION_DESIRE_HIGH;
	end
	
	if J.IsAttackProjectileIncoming(bot, 1)
	then
		return BOT_ACTION_DESIRE_LOW;
	end
	if not bot:HasModifier("modifier_puck_phase_shift") 
		and not bot:IsMagicImmune() 
	then
		if J.IsWillBeCastUnitTargetAndLocationSpell(bot,1400)
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	local incProj = bot:GetIncomingTrackingProjectiles()
	for _,p in pairs(incProj)
	do
		if GetUnitToLocationDistance(bot, p.location) <= 100 and ( p.is_attack or p.is_dodgeable ) then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end

function X.ConsiderR()

	-- Make sure it's castable
	if ( not abilityR:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityR:GetCastRange();
	local nInitDamage = abilityR:GetSpecialValueInt( "coil_init_damage_tooltip" );
	local nBreakDamage = abilityR:GetSpecialValueInt( "coil_break_damage" );
	local nRadius = abilityR:GetSpecialValueInt( "coil_radius" );

	-- If enemy is channeling cancel it
	local npcTarget = npcTarget;
	if (npcTarget ~= nil and npcTarget:IsChanneling() and GetUnitToUnitDistance( npcTarget, bot ) < ( nCastRange + nRadius ))
	then
		return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation();
	end
	-- If a mode has set a target, and we can kill them, do it
	if ( npcTarget ~= nil and J.CanCastOnNonMagicImmune( npcTarget ) )
	then
		if ( npcTarget:GetActualIncomingDamage( nInitDamage + nBreakDamage, 2 ) > npcTarget:GetHealth() and GetUnitToUnitDistance( npcTarget, bot ) < ( nCastRange + nRadius ) )
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation();
		end
	end

	-- If we're in a teamfight, use it on the scariest enemy
	local tableNearbyAttackingAlliedHeroes = bot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then

		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 );

		if ( locationAoE.count >= 2 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end

	-- If an enemy is under our tower...
	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange + nRadius, true, BOT_MODE_NONE );
	local tableNearbyFriendlyTowers = bot:GetNearbyTowers( 1300, false );
	if tower ~= nil then
		for _,npcTarget in pairs(tableNearbyEnemyHeroes) do
			if ( GetUnitToUnitDistance( npcTarget, tower ) < 1100 ) 
			then
				if(npcTarget:IsFacingUnit( tower, 15 ) and npcTarget:HasModifier("modifier_puck_coiled") ) then
					return BOT_ACTION_DESIRE_MODERATE, bot:IsFacingLocation( npcTarget:GetLocation(), nCastRange - 1);
				end
			end
		end
	end


	return BOT_ACTION_DESIRE_NONE, 0;
end

function X.ConsiderB()

	-- Make sure it's castable
	if ( not abilityQ:IsFullyCastable() or
		not abilityW:IsFullyCastable() or
		not abilityE:IsFullyCastable()) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityQ:GetCastRange();
	local nRadius = abilityW:GetSpecialValueInt( "radius" );

	-- Find a big group to nuke

	local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), 1300, nRadius, 0, 0 );
	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
	local npcTarget = tableNearbyEnemyHeroes[1];	
	if npcTarget ~= nil then
		if ( locationAoE.count >= 3 and GetUnitToLocationDistance( npcTarget, locationAoE.targetloc ) < nRadius ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc;
		end
	end
	return BOT_ACTION_DESIRE_NONE, 0;

end

function X.ConsiderF()

	-- Make sure it's castable
	if ( itemForce == "item_force_staff" or not itemForce:IsFullyCastable()) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = 800;
	local nPushRange = 600;

	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1300, true, BOT_MODE_NONE );
	local tableNearbyFriendlyTowers = bot:GetNearbyTowers( 1300, false );
	if tower ~= nil then
		for _,npcTarget in pairs(tableNearbyEnemyHeroes) do
			if ( GetUnitToUnitDistance( npcTarget, tower ) < 1100 ) 
			then
				if(npcTarget:IsFacingEntity( tower, 15 ) and npcTarget:HasModifier("modifier_puck_coiled") ) then
					return BOT_ACTION_DESIRE_MODERATE, npcTarget;
				end
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;

end

function performForceEnemy( castForceEnemyTarget )
	bot:Action_UseAbilityOnEntity( itemForce, castForceEnemyTarget );
end

function performBlinkInit( castBlinkInitTarget )
	local orbTarget = bot:GetLocation();

	if( itemBlink ~= "item_blink" and itemBlink:IsFullyCastable()) then
		bot:Action_UseAbilityOnLocation( itemBlink, castBlinkInitTarget);
	end
end

function GetDistance(s, t)
    return math.sqrt((s[1]-t[1])*(s[1]-t[1]) + (s[2]-t[2])*(s[2]-t[2]));
end

return X
-- dota2jmz@163.com QQ:2462331592
