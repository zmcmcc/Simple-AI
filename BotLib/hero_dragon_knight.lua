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
local ConversionMode = dofile( GetScriptDirectory()..'/AuxiliaryScript/BotlibConversion') --引入技能文件
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
			['t15'] = {10, 0},
			['t10'] = {10, 0},
		},
		--技能
		['Ability'] = {2,3,1,1,1,6,1,3,3,3,6,2,2,2,6},
		--装备
		['Buy'] = {
			sOutfit,
			"item_crimson_guard",
			"item_heavens_halberd",
			"item_assault",
			"item_heart",
		},
		--出售
		['Sell'] = {
			"item_crimson_guard",
			"item_quelling_blade",
			
			"item_assault",
			"item_magic_wand",
		},
	},{
		--组合说明，不影响游戏
		['info'] = 'By Misunderstand',
		--天赋树
		['Talent'] = {
			['t25'] = {0, 10},
			['t20'] = {10, 0},
			['t15'] = {0, 10},
			['t10'] = {0, 10},
		},
		--技能
		['Ability'] = { 1, 3, 3, 1, 2, 6, 1, 1, 3, 2, 6, 3, 2, 2, 6 },
		--装备
		['Buy'] = {
			"item_tango",
			"item_flask",
			"item_stout_shield",
			"item_quelling_blade",
			"item_double_enchanted_mango",
			"item_soul_ring",
			"item_hand_of_midas", 
			"item_power_treads",
			"item_invis_sword",
			"item_hood_of_defiance",			
			"item_black_king_bar",
			"item_ultimate_scepter",
			"item_mjollnir",
			"item_greater_crit",
			"item_ultimate_scepter_2",
			"item_silver_edge",
			"item_heavens_halberd",
			"item_travel_boots",
			"item_moon_shard",
			"item_travel_boots_2"
		},
		--出售
		['Sell'] = {
			"item_power_treads",     
			"item_quelling_blade",

			"item_invis_sword",     
			"item_stout_shield",
					
			"item_ultimate_scepter",  
			"item_soul_ring",	 

			"item_greater_crit",
			"item_hood_of_defiance",   

			"item_silver_edge",
			"item_hand_of_midas",

			"item_travel_boots",
			"item_power_treads"
		},
	},{
		--组合说明，不影响游戏
		['info'] = 'By 铅笔会有猫的w',
		--天赋树
		['Talent'] = {
			['t25'] = {10, 0},
			['t20'] = {10, 0},
			['t15'] = {0, 10},
			['t10'] = {10, 0},
		},
		--技能
		['Ability'] = { 1, 3, 2, 3, 3, 6, 3, 1, 1, 1, 6, 2, 2, 2, 6 },
		--装备
		['Buy'] = {
			"item_tango",
			"item_flask",
			"item_stout_shield",
			"item_quelling_blade",
			"item_boots",
			"item_magic_stick",
			"item_hand_of_midas", 
			"item_magic_wand",
			"item_bracer",
			"item_power_treads",
			"item_maelstrom",
			"item_lesser_crit",
			"item_black_king_bar",
			"item_mjollnir",					
			"item_satanic",
			"item_bloodthorn", 			
			"item_travel_boots",	
			"item_assault",
			"item_moon_shard",
			"item_ultimate_scepter",
			"item_ultimate_scepter_2",		
			"item_travel_boots_2",	
		},
		--出售
		['Sell'] = {
			"item_travel_boots",
			"item_power_treads",

			"item_maelstrom",     
			"item_stout_shield",

			"item_assault",     
			"item_hand_of_midas",

			"item_satanic",     
			"item_magic_wand",

			"item_lesser_crit",     
			"item_quelling_blade",
					
			"item_black_king_bar",  
			"item_bracer",	     
		},
	},
}
--默认数据
local tDefaultGroupedData = {
	--天赋树
	['Talent'] = {
		['t25'] = {10, 0},
		['t20'] = {0, 10},
		['t15'] = {10, 0},
		['t10'] = {10, 0},
	},
	--技能
	['Ability'] = {2,3,1,1,1,6,1,3,3,3,6,2,2,2,6},
	--装备
	['Buy'] = {
		sOutfit,
		"item_crimson_guard",
		"item_heavens_halberd",
		"item_assault",
		"item_heart",
	},
	--出售
	['Sell'] = {
		"item_crimson_guard",
		"item_quelling_blade",
		
		"item_assault",
		"item_magic_wand",
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
	end

end

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )


local castQDesire, castQLocation
local castWDesire, castWTarget
local castRDesire

local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;


function X.SkillsComplement()

	
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
	
	--J.Skill.AbilityReadinessReminder(abilityR, 5);
	
	nKeepMana = 400
	nMP = bot:GetMana()/bot:GetMaxMana();
	nHP = bot:GetHealth()/bot:GetMaxHealth();
	nLV = bot:GetLevel();
	hEnemyHeroList = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
		
	
	castRDesire  = X.ConsiderR();
	if ( castRDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, false)
	
		bot:ActionQueue_UseAbility( abilityR )
		return;
	
	end
	
	castQDesire, castQLocation   = X.ConsiderQ();
	if ( castQDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, true)
	
		bot:ActionQueue_UseAbilityOnLocation( abilityQ, castQLocation )
		return;
	end
	
	castWDesire, castWTarget = X.ConsiderW();
	if ( castWDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, true)
	
		bot:ActionQueue_UseAbilityOnEntity( abilityW, castWTarget )
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
	
	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange + 150, true, BOT_MODE_NONE );
	local nEnemysHeroesInView = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE );
	
	
	--if we can kill any enemies
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if J.CanCastOnNonMagicImmune(npcEnemy) 
		   and J.CanKillTarget(npcEnemy, nDamage, DAMAGE_TYPE_MAGICAL) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation();
		end
	end
	 
	if J.IsFarming(bot) and bot:GetMana() > 150
	then
		local npcTarget = J.GetProperTarget(bot);
		if J.IsValid(npcTarget)
		   and npcTarget:GetTeam() == TEAM_NEUTRAL
		   and npcTarget:GetMagicResist() < 0.4
		then
			local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
			if ( locationAoE.count >= 2 ) 
			then
				return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
			end
		end
	end	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange - 100, nRadius, 0, 0 );
		if ( locationAoE.count >= 2  ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
		if J.IsValidHero(tableNearbyEnemyHeroes[1]) 
			and J.CanCastOnNonMagicImmune(tableNearbyEnemyHeroes[1])
			and J.IsInRange(bot,tableNearbyEnemyHeroes[1],nCastRange - 100)
		then
			return BOT_ACTION_DESIRE_HIGH, tableNearbyEnemyHeroes[1]:GetLocation();
		end
	end
	
	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = bot:GetAttackTarget();
		if ( J.IsRoshan(npcTarget) and J.IsInRange(npcTarget, bot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation();
		end
	end
	
	if ( J.IsPushing(bot) or J.IsDefending(bot) or J.IsFarming(bot)) 
	    and J.IsAllowedToSpam(bot, nManaCost *0.3)
		and bot:GetLevel() >= 6 
		and #nEnemysHeroesInView == 0
	then
		local laneCreepList = bot:GetNearbyLaneCreeps(nCastRange+200, true);
		local allyHeroes  = bot:GetNearbyHeroes(1000,true,BOT_MODE_NONE);
		if #laneCreepList >= 2 
		   and #allyHeroes <= 2 
		   and J.IsValid(laneCreepList[1])
		   and not laneCreepList[1]:HasModifier("modifier_fountain_glyph")
		then
			local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, nDamage );
			if ( locationAoE.count >= 2 and #laneCreepList >= 2  and bot:GetLevel() < 25 and #allyHeroes == 1) 
			then
				return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
			end
			local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
			if ( locationAoE.count >= 4 and #laneCreepList >= 4  ) 
			then
				return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
			end
		end
	end
	
	if J.IsInTeamFight(bot, 1200)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius - 30, 0, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
		end
		
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;				
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if  J.IsValid(npcEnemy)
				and J.IsInRange(npcTarget, bot, nCastRange) 
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
			then
				local npcEnemyDamage = npcEnemy:GetEstimatedDamageToTarget( false, bot, 3.0, DAMAGE_TYPE_PHYSICAL );
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
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = J.GetProperTarget(bot);
		if J.IsValidHero(npcTarget) 
		   and J.CanCastOnNonMagicImmune(npcTarget) 
		   and J.IsInRange(npcTarget, bot, nCastRange - 100) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
	if bot:GetLevel() < 18
	then
		local laneCreepList = bot:GetNearbyLaneCreeps(nCastRange+200, true);
		local allyHeroes  = bot:GetNearbyHeroes(1000,true,BOT_MODE_NONE);
		if #laneCreepList >= 3 
		   and #allyHeroes < 3
		   and J.IsValid(laneCreepList[1])
		   and not laneCreepList[1]:HasModifier("modifier_fountain_glyph")
		then
			local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, nDamage );
			if ( locationAoE.count >= 3 and #laneCreepList >= 3  ) 
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
	
	if bot:GetAttackRange() > 300
	then
		nCastRange = 400;
	end
		
	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange + 100, true, BOT_MODE_NONE );
	
	--if we can kill any enemies
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if J.CanCastOnNonMagicImmune(npcEnemy) 
		   and J.CanCastOnTargetAdvanced(npcEnemy)
		   and ( J.CanKillTarget(npcEnemy, nDamage, DAMAGE_TYPE_MAGICAL) or npcEnemy:IsChanneling() ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	
	--if enemy is channeling
	local nEnemysHeroesInView = bot:GetNearbyHeroes(800,true,BOT_MODE_NONE);
	if #nEnemysHeroesInView > 0 then
		for i=1, #nEnemysHeroesInView do
			if J.IsValid(nEnemysHeroesInView[i])
			   and J.CanCastOnNonMagicImmune(nEnemysHeroesInView[i]) 
			   and J.CanCastOnTargetAdvanced(nEnemysHeroesInView[i])
			   and nEnemysHeroesInView[i]:IsChanneling()
			then
				return BOT_ACTION_DESIRE_HIGH, nEnemysHeroesInView[i];
			end
		end
	end
	
	if J.IsInTeamFight(bot, 1200)
	then
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;		
		
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and J.CanCastOnTargetAdvanced(npcEnemy)
				and not J.IsDisabled(true, npcEnemy)
				and not npcEnemy:IsDisarmed()
			then
				local npcEnemyDamage = npcEnemy:GetEstimatedDamageToTarget( false, bot, 3.0, DAMAGE_TYPE_PHYSICAL );
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
	if J.IsRetreating(bot)
	then
		if tableNearbyEnemyHeroes ~= nil 
		   and #tableNearbyEnemyHeroes >= 1 
		   and J.CanCastOnNonMagicImmune(tableNearbyEnemyHeroes[1]) 
		then
			return BOT_ACTION_DESIRE_HIGH, tableNearbyEnemyHeroes[1];
		end
	end
	
	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = bot:GetAttackTarget();
		if ( J.IsRoshan(npcTarget) 
			 and J.IsInRange(npcTarget, bot, nCastRange + 150) 
             and not J.IsDisabled(true, npcTarget) )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget;
		end
	end
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = J.GetProperTarget(bot);
		if J.IsValidHero(npcTarget) 
		    and J.CanCastOnNonMagicImmune(npcTarget) 
			and J.CanCastOnTargetAdvanced(npcTarget)
			and J.IsInRange(npcTarget, bot, nCastRange + 200) 
            and not J.IsDisabled(true, npcTarget) 		
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function X.ConsiderR()

	-- Make sure it's castable
	if ( not abilityR:IsFullyCastable() or J.GetHPR(bot) < 0.25 ) then 
		return BOT_ACTION_DESIRE_NONE;
	end

	-- Get some of its values
	local nCastPoint = abilityR:GetCastPoint( );
	local nManaCost  = abilityR:GetManaCost( );

	-- If We're pushing or defending
	if ( J.IsPushing(bot) or J.IsFarming(bot) or J.IsDefending(bot) ) 
	then
		local tableNearbyEnemyCreeps = bot:GetNearbyCreeps( 800, true );
		local tableNearbyTowers = bot:GetNearbyTowers( 800, true );
		if #tableNearbyEnemyCreeps >= 2 or #tableNearbyTowers >= 1 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = J.GetProperTarget(bot);
		if J.IsValidHero(npcTarget) 
		   and J.IsInRange(npcTarget, bot, 800)
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end

return X
-- dota2jmz@163.com QQ:2462331592
