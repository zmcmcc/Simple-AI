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

--编组技能、天赋、装备
local tGroupedDataList = {
	{
		--组合说明，不影响游戏
		['info'] = 'By 决明子',
		--天赋树
		['Talent'] = {
			['t25'] = {10, 0},
			['t20'] = {0, 10},
			['t15'] = {0, 10},
			['t10'] = {0, 10},
		},
		--技能
		['Ability'] = {3,1,3,1,3,6,3,2,1,1,6,2,2,2,6},
		--装备
		['Buy'] = {
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
		},
		--出售
		['Sell'] = {
			"item_bloodthorn",
			"item_diffusal_blade",
			
			"item_mjollnir",
			"item_hand_of_midas",
			
			'item_sheepstick',
			'item_magic_wand',
		},
	},{
		--组合说明，不影响游戏
		['info'] = 'By Misunderstand',
		--天赋树
		['Talent'] = {
			['t25'] = {10, 0},
			['t20'] = {0, 10},
			['t15'] = {10, 0},
			['t10'] = {0, 10},
		},
		--技能
		['Ability'] = { 3, 1, 3, 1, 2, 6, 1, 1, 3, 3, 6, 2, 2, 2, 6 },
		--装备
		['Buy'] = {
			"item_double_slippers",
			"item_enchanted_mango",
			"item_circlet",
			"item_double_branches",
			"item_double_enchanted_mango",
			"item_magic_wand",
			"item_wraith_band",
			"item_hand_of_midas", 
			"item_travel_boots",
			"item_maelstrom",
			"item_orchid",
			"item_manta",
			"item_sheepstick",
			"item_mjollnir",
			"item_bloodthorn",
			"item_black_king_bar",
			"item_ethereal_blade",
			"item_travel_boots_2",
			"item_necronomicon_3",
			"item_moon_shard"
		},
		--出售
		['Sell'] = {
			"item_travel_boots",     
			"item_slippers",

			"item_orchid",     
			"item_magic_wand",
					
			"item_manta",  
			"item_wraith_band",	     

			"item_ethereal_blade",
			"item_manta",

			"item_travel_boots_2",
			"item_black_king_bar",

			"item_dagon_5",
			"item_hand_of_midas"
		},
	},{
		--组合说明，不影响游戏
		['info'] = 'By 铅笔会有猫的w',
		--天赋树
		['Talent'] = {
			['t25'] = {10, 0},
			['t20'] = {0, 10},
			['t15'] = {0, 10},
			['t10'] = {0, 10},
		},
		--技能
		['Ability'] = { 3, 1, 3, 2, 3, 6, 3, 1, 1, 1, 6, 2, 2, 2, 6 },
		--装备
		['Buy'] = {
			"item_circlet",
			"item_enchanted_mango",
			"item_clarity",
			"item_double_branches",
			"item_double_enchanted_mango",
			"item_boots", 
			"item_flask",
			"item_magic_wand",	
			"item_double_wraith_band",	
			"item_hand_of_midas", 
			"item_travel_boots",
			"item_dragon_lance", 									
			"item_mjollnir",
			"item_sheepstick", 
			"item_black_king_bar",
			"item_bloodthorn", 
			"item_ultimate_scepter",
			"item_ultimate_scepter_2",
			"item_moon_shard",
		},
		--出售
		['Sell'] = {
			"item_black_king_bar",     
			"item_dragon_lance",

			"item_mjollnir",     
			"item_magic_wand",
					
			"item_sheepstick",  
			"item_wraith_band",	     

			"item_bloodthorn", 
			"item_hand_of_midas",
		},
	},
}
--默认数据
local tDefaultGroupedData = {
	--天赋树
	['Talent'] = {
		['t25'] = {10, 0},
		['t20'] = {0, 10},
		['t15'] = {0, 10},
		['t10'] = {0, 10},
	},
	--技能
	['Ability'] = {3,1,3,1,3,6,3,2,1,1,6,2,2,2,6},
	--装备
	['Buy'] = {
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
	},
	--出售
	['Sell'] = {
		"item_bloodthorn",
		"item_diffusal_blade",
		
		"item_mjollnir",
		"item_hand_of_midas",
		
		'item_sheepstick',
		'item_magic_wand',
	},
}

--根据组数据生成技能、天赋、装备
local nAbilityBuildList, nTalentBuildList;

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = ConversionMode.Combination(tGroupedDataList, tDefaultGroupedData)

nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList'] = J.SetUserHeroInit(nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList']);

X['sSkillList'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = true

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit(hMinionUnit) 
	then
		Minion.IllusionThink(hMinionUnit)
		--待补充死灵书的逻辑
	end

end

local abilityQ = bot:GetAbilityByName( sAbilityList[1] );
local abilityW = bot:GetAbilityByName( sAbilityList[2] );
local abilityE = bot:GetAbilityByName( sAbilityList[3] );
local abilityR = bot:GetAbilityByName( sAbilityList[6] );


local castQDesire,castQTarget
local castWDesire,castWLocation
local castEDesire,castELocation
local castRDesire


local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;
local npcDouble = nil; 


function X.SkillsComplement()
	
	
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
	
	
	nKeepMana = 300
	nMP = bot:GetMana()/bot:GetMaxMana();
	nHP = bot:GetHealth()/bot:GetMaxHealth();
	nLV = bot:GetLevel();
	hEnemyHeroList = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	
	
	
	
	castQDesire, castQTarget = X.ConsiderQ();
	if ( castQDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, false)
	
		bot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget )
		return;
	end
	
	castWDesire, castWLocation = X.ConsiderW();
	if ( castWDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, false)
	
		bot:ActionQueue_UseAbilityOnLocation( abilityW, castWLocation )
		return;
	end
	
	
	castEDesire, castELocation = X.ConsiderE();
	if ( castEDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, false)
	
		bot:ActionQueue_UseAbilityOnLocation( abilityE, castELocation )
		return;
	end
	
	
	castRDesire = X.ConsiderR();
	if ( castRDesire > 0 ) 
	then
		
		bot:ActionQueue_UseAbility( abilityR )
		return;
	
	end

	--技能检查顺序
	local order = {'D'}
	--委托技能处理函数接管
	if ConversionMode.Skills(order) then return; end

end


function X.ConsiderE()


	if not abilityE:IsFullyCastable() then	return 0 end 

	local nRadius = abilityE:GetSpecialValueInt( "radius" );
	local nCastRange = abilityE:GetCastRange();
	local nDamage = abilityE:GetSpecialValueInt("spark_damage");
	local nDelay = abilityE:GetSpecialValueInt("activation_delay");

	
	-- If a mode has set a target, and we can kill them, do it
	local npcTarget = J.GetProperTarget(bot);
	if J.IsValidHero(npcTarget) 
	   and J.CanCastOnNonMagicImmune(npcTarget)
	then
		if J.CanKillTarget(npcTarget, nDamage, DAMAGE_TYPE_MAGICAL) 
		   and J.IsInRange(npcTarget, bot, nCastRange) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nDelay - 0.3 )
		end
	end

	
	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = bot:GetAttackTarget();
		if J.IsRoshan(npcTarget) 
		   and J.IsInRange(npcTarget, bot, nCastRange) 
		   and J.GetHPR(npcTarget) > 0.2
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetLocation();
		end
	end
	
	
	if J.IsInTeamFight(bot, 1200)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), 1000, nRadius, 0, 0 );
		if locationAoE.count >= 2
		then
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
		end
	end
	
	
	if J.IsGoingOnSomeone(bot)
	then
	
		if J.IsValidHero(npcTarget) 
		   and J.CanCastOnNonMagicImmune(npcTarget) 
		   and J.IsInRange(npcTarget, bot, nCastRange)
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( nDelay - 0.3 );
		end
		
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), 1400, nRadius, 2.0, 0 );
		if locationAoE.count >= 1 
		   and not bot:HasModifier("modifier_silencer_curse_of_the_silent")
		then
			local nCreep = J.GetVulnerableUnitNearLoc(false, true, 1600, nRadius, locationAoE.targetloc, bot);
			if nCreep == nil 
			   or bot:HasModifier("modifier_arc_warden_tempest_double")
			then
				return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
			end
		end
		
	end	
	
	-- if we're Retreat
	if J.IsRetreating(bot) 
	   and bot:GetActiveModeDesire() > BOT_ACTION_DESIRE_HIGH
	   and not bot:HasModifier("modifier_silencer_curse_of_the_silent")
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes(800,true,BOT_MODE_NONE);
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( J.IsValid(npcEnemy) and bot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) and J.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, bot:GetLocation();
			end
		end
	end
	
	-- if we're farming
	if bot:GetActiveMode() == BOT_MODE_FARM
	   or J.IsPushing(bot)
	   or J.IsDefending(bot)
	then
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), 1400, nRadius, 2.0, 0 );
		if locationAoE.count > 2
			and not bot:HasModifier("modifier_silencer_curse_of_the_silent")
		then
			if bot:HasModifier("modifier_arc_warden_tempest_double")
			then
				return BOT_ACTION_DESIRE_HIGH,locationAoE.targetloc;
			end
			
			local nLaneCreeps = bot:GetNearbyLaneCreeps(1400,true);
			if #nLaneCreeps >= 2
			then
				if J.GetMPR(bot) > 0.62
				then
					return BOT_ACTION_DESIRE_HIGH,locationAoE.targetloc;
				end
			else
				if J.GetMPR(bot) > 0.75
				then
					return BOT_ACTION_DESIRE_HIGH,locationAoE.targetloc;
				end
			end
		end
	
	end
	
	
	if abilityE:GetLevel() >= 3 and bot:GetActiveMode() ~= BOT_MODE_LANING and J.IsAllowedToSpam(bot, 80) 
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), 1400, nRadius, 2.0, 0 );
		if locationAoE.count >= 2 then
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
		end	
	end
	
	
	if bot:GetLevel() >= 10
		and ( J.IsAllowedToSpam(bot,80) or bot:HasModifier("modifier_arc_warden_tempest_double"))
		and DotaTime() > 6 *60
	then
	
		local nEnemysHerosCanSeen = GetUnitList(UNIT_LIST_ENEMY_HEROES);
		local nTargetHero = nil;
		local nTargetHeroHealth = 99999;
		for _,enemy in pairs(nEnemysHerosCanSeen)
		do
			if J.IsValidHero(enemy)
				and GetUnitToUnitDistance(bot,enemy) <= nCastRange
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
				if GetUnitToLocationDistance(bot,castLocation) <= nCastRange
				then
					return BOT_ACTION_DESIRE_MODERATE, castLocation;
				end
			end
		end
		
		
		local nLaneCreeps = bot:GetNearbyLaneCreeps(1600,true);
		if #nLaneCreeps >= 3
		then
			local targetCreep = nLaneCreeps[#nLaneCreeps];
			if J.IsValid(targetCreep)
			then
				local castLocation = J.GetFaceTowardDistanceLocation(targetCreep,375);
				return BOT_ACTION_DESIRE_MODERATE ,castLocation;
			end
		end
		
		local nEnemyHeroesInView = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
		local nEnemyLaneFront = J.GetNearestLaneFrontLocation(bot:GetLocation(),true,nRadius/2);
		if #nEnemyHeroesInView == 0 and nEnemyLaneFront ~= nil
		   and GetUnitToLocationDistance(bot,nEnemyLaneFront) <= nCastRange + nRadius
		   and GetUnitToLocationDistance(bot,nEnemyLaneFront) >= 800
		then
			local castLocation = J.GetLocationTowardDistanceLocation(bot,nEnemyLaneFront,nCastRange)
			if GetUnitToLocationDistance(bot,nEnemyLaneFront) < nCastRange
			then
				castLocation = nEnemyLaneFront
			end			
			return BOT_ACTION_DESIRE_MODERATE ,castLocation;
		end
	end
	
	
	local castLocation = J.GetLocationTowardDistanceLocation(bot,J.GetEnemyFountain(),nCastRange)
	if  bot:HasModifier("modifier_arc_warden_tempest_double")
		or ( J.GetMPR(bot) > 0.92 and bot:GetLevel() > 11 and not IsLocationVisible(castLocation) )
		or ( J.GetMPR(bot) > 0.38 and J.GetDistanceFromEnemyFountain(bot) < 4300 )
	then
		if IsLocationPassable(castLocation)
		   and not bot:HasModifier("modifier_silencer_curse_of_the_silent")
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
	if J.IsRetreating(bot) 
	   and not bot:HasModifier("modifier_arc_warden_magnetic_field") 
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( J.IsValid(npcEnemy) and bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, bot:GetLocation();
			end
		end
	end

	if bot:GetActiveMode() == BOT_MODE_ROSHAN
	   and not bot:HasModifier("modifier_arc_warden_magnetic_field") 
	then
		local npcTarget = bot:GetAttackTarget();
		if ( J.IsRoshan(npcTarget) and J.CanCastOnMagicImmune(npcTarget) and J.IsInRange(npcTarget, bot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, bot:GetLocation();
		end
	end
	
	-- If we're farming and can kill 3+ creeps with LSA
	if bot:GetActiveMode() == BOT_MODE_FARM 
	   and not bot:HasModifier("modifier_arc_warden_magnetic_field") 
	then
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), 600, nRadius, 0, 0 );
		if ( locationAoE.count >= 3  ) then
			return BOT_ACTION_DESIRE_HIGH, bot:GetLocation();
		end
	end

	if J.IsInTeamFight(bot, 1200)
	then
		local locationAoE = bot:FindAoELocation( false, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
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
	if J.IsDefending(bot) or J.IsPushing(bot) and not bot:HasModifier("modifier_arc_warden_magnetic_field")
	then
		local tableNearbyEnemyCreeps = bot:GetNearbyLaneCreeps( 800, true );
		local tableNearbyEnemyTowers = bot:GetNearbyTowers( 800, true );
		if ( tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 3 ) 
		   or ( tableNearbyEnemyTowers ~= nil and #tableNearbyEnemyTowers >= 1 ) 
		then
			return BOT_ACTION_DESIRE_LOW, bot:GetLocation();
		end
	end
	
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if J.IsValidHero(npcTarget) and  J.IsInRange(npcTarget, bot, nCastRange)  
		then
			local tableNearbyAttackingAlliedHeroes = bot:GetNearbyHeroes( nCastRange, false, BOT_MODE_ATTACK );
			for _,npcAlly in pairs( tableNearbyAttackingAlliedHeroes )
			do
				if J.IsValid(npcAlly) 
				    and ( J.IsInRange(npcAlly, bot, nCastRange) and not npcAlly:HasModifier("modifier_arc_warden_magnetic_field") ) 
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
	local npcTarget = J.GetProperTarget(bot);
	
	-- If a mode has set a target, and we can kill them, do it
	if J.IsValidHero(npcTarget) 
	   and J.CanCastOnNonMagicImmune(npcTarget) 
	   and J.CanCastOnTargetAdvanced(npcTarget)
	   and J.CanKillTarget(npcTarget, nDamage, DAMAGE_TYPE_MAGICAL) 
	   and J.IsInRange(npcTarget, bot, nCastRange)
	then
		return BOT_ACTION_DESIRE_HIGH, npcTarget;
	end
	
	
	-- If we're in a teamfight, use it on the scariest enemy
	if J.IsInTeamFight(bot, 1200)
	then
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;

		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE  );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if J.IsValid(npcEnemy) 
			   and J.CanCastOnNonMagicImmune(npcEnemy) 
			   and J.CanCastOnTargetAdvanced(npcEnemy)
			then
				local nDamage = npcEnemy:GetEstimatedDamageToTarget( false, bot, 3.0, DAMAGE_TYPE_ALL );
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

	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		if J.IsRoshan(npcTarget) 
		   and J.CanCastOnMagicImmune(npcTarget) 
		   and J.IsInRange(npcTarget, bot, nCastRange)  
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget;
		end
	end
	
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidHero(npcTarget) 
		   and J.CanCastOnNonMagicImmune(npcTarget) 
		   and J.CanCastOnTargetAdvanced(npcTarget)
		   and J.IsInRange(npcTarget, bot, nCastRange +40)
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	
	if J.IsRetreating(bot) 
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE  );
		local nEnemyHeroes   = bot:GetNearbyHeroes( 800, true, BOT_MODE_NONE  );
		local npcEnemy = tableNearbyEnemyHeroes[1];
		if J.IsValid(npcEnemy) 
			and (bot:IsFacingLocation(npcEnemy:GetLocation(),10) or #nEnemyHeroes <= 1)
			and bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) 
			and J.CanCastOnNonMagicImmune(npcEnemy)
			and J.CanCastOnTargetAdvanced(npcEnemy)
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
	if  J.IsDefending(bot) or J.IsPushing(bot) or J.IsGoingOnSomeone(bot) or bot:GetActiveMode() == BOT_MODE_FARM
	then
		local tableNearbyEnemyCreeps = bot:GetNearbyLaneCreeps( 800, true );
		local tableNearbyEnemyTowers = bot:GetNearbyTowers( 800, true );
		local tableNaturalCreeps     = bot:GetNearbyCreeps(800,true);
		if ( tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 2 ) 
		    or ( tableNearbyEnemyTowers ~= nil and #tableNearbyEnemyTowers >= 1 ) 
			or ( tableNaturalCreeps ~= nil and #tableNaturalCreeps >= 2 ) 
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end


	if J.IsInTeamFight(bot, 1200)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if J.IsValid(npcEnemy) and J.IsInRange(npcEnemy, bot, 1000)
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	
	if J.IsRetreating(bot) 
	then
		local nEnemyHeroes   = bot:GetNearbyHeroes( 800, true, BOT_MODE_NONE  );
		local npcEnemy = nEnemyHeroes[1];
		if J.IsValid(npcEnemy) 
			and (J.GetHPR(bot) > 0.35 or #nEnemyHeroes <= 1)
			and bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) 
			and J.GetHPR(bot) > 0.25
			and #nEnemyHeroes <= 2
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end  
	end
	
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if J.IsValidHero(npcTarget) and J.IsInRange(npcTarget, bot, 1000) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	local midas = J.GetComboItem(bot, "item_hand_of_midas")
	if midas ~= nil
	   and X.IsDoubleMidasCooldown()
	   and bot:DistanceFromFountain() > 600
	then
		local nCreeps = bot:GetNearbyCreeps(1600,true);
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
		and bot:GetLevel() >= 6
	then
		local nHeroes = bot:GetNearbyHeroes(1600,false,BOT_MODE_NONE);
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

	local nAlly = bot:GetNearbyHeroes(1200,false,BOT_MODE_NONE);
	for _,ally in pairs(nAlly)
	do
		if J.IsValid(ally)
			and ally ~= bot
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
