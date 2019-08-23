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
			['t25'] = {0, 10},
			['t20'] = {10, 0},
			['t15'] = {0, 10},
			['t10'] = {0, 10},
		},
		--技能
		['Ability'] = {2,3,1,2,2,6,2,3,3,3,6,1,1,1,6},
		--装备
		['Buy'] = {
			sOutfit,
			"item_crimson_guard",
			"item_heavens_halberd",
			"item_lotus_orb",
			"item_assault", 
		},
		--出售
		['Sell'] = {
			"item_crimson_guard",
			"item_quelling_blade",
			
			"item_lotus_orb",
			"item_magic_wand",
		},
	},{
		--组合说明，不影响游戏
		['info'] = 'By Misunderstand',
		--天赋树
		['Talent'] = {
			['t25'] = {10, 0},
			['t20'] = {0, 10},
			['t15'] = {10, 0},
			['t10'] = {10, 0},
		},
		--技能
		['Ability'] = { 2, 3, 2, 3, 2, 6, 1, 2, 3, 3, 6, 1, 1, 1, 6},
		--装备
		['Buy'] = {
			"item_tango",
			"item_flask",
			"item_stout_shield",
			"item_enchanted_mango",
			"item_double_branches",
			"item_magic_stick",
			"item_double_enchanted_mango",
			"item_bracer",
			"item_phase_boots",
			"item_magic_wand",
			"item_vanguard",
			"item_hood_of_defiance",
			"item_blade_mail",
			"item_lotus_orb",  
			"item_pipe",
			"item_crimson_guard",
			"item_heavens_halberd",
			"item_ultimate_scepter_2",
			"item_travel_boots_2",
			"item_octarine_core"
		},
		--出售
		['Sell'] = {
			"item_blade_mail",
			"item_bracer",

			"item_lotus_orb",
			"item_magic_wand",

			"item_heavens_halberd",
			"item_blade_mail",
					
			"item_travel_boots_2",
			"item_phase_boots",

			"item_octarine_core",
			"item_heavens_halberd",
		},
	},{
		--组合说明，不影响游戏
		['info'] = 'By 铅笔会有猫的w',
		--天赋树
		['Talent'] = {
			['t25'] = {10, 0},
			['t20'] = {0, 10},
			['t15'] = {10, 0},
			['t10'] = {10, 0},
		},
		--技能
		['Ability'] = { 1, 2, 3, 2, 2, 6, 2, 3, 3, 3, 6, 1, 1, 1, 6 },
		--装备
		['Buy'] = {
			"item_tango",
			"item_flask",
			"item_double_enchanted_mango",
			"item_stout_shield",
			"item_magic_stick",
			"item_phase_boots",
			"item_magic_wand",
			"item_bracer",
			"item_vanguard",
			"item_blade_mail", 
			"item_lotus_orb", 
			"item_crimson_guard", 	
			"item_black_king_bar", 
			"item_heart", 		
			"item_ultimate_scepter",			
			"item_ultimate_scepter_2",		
			"item_travel_boots",	
			"item_moon_shard", 		
			"item_travel_boots_2",	
		},
		--出售
		['Sell'] = {
			"item_travel_boots",     
			"item_magic_wand",

			"item_travel_boots",
			"item_phase_boots", 

			"item_black_king_bar",
			"item_bracer", 

			"item_heart",
			"item_magic_wand", 
		},
	},
}
--默认数据
local tDefaultGroupedData = {
	--天赋树
	['Talent'] = {
		['t25'] = {0, 10},
		['t20'] = {10, 0},
		['t15'] = {0, 10},
		['t10'] = {0, 10},
	},
	--技能
	['Ability'] = {2,3,1,2,2,6,2,3,3,3,6,1,1,1,6},
	--装备
	['Buy'] = {
		sOutfit,
		"item_crimson_guard",
		"item_heavens_halberd",
		"item_lotus_orb",
		"item_assault", 
	},
	--出售
	['Sell'] = {
		"item_crimson_guard",
		"item_quelling_blade",
		
		"item_lotus_orb",
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


local castQDesire, castQTarget
local castWDesire

local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;


function X.SkillsComplement()

	
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end

	
	
	nKeepMana = 180
	nMP = bot:GetMana()/bot:GetMaxMana();
	nHP = bot:GetHealth()/bot:GetMaxHealth();
	nLV = bot:GetLevel();
	hEnemyHeroList = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	
	
	
	
	castQDesire, castQTarget   = X.ConsiderQ();
	if ( castQDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, true)
		
		if bot:HasScepter() 
		then
			bot:ActionQueue_UseAbility( abilityQ )
		else
			bot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget )
		end
		return;
	end
	
	castWDesire = X.ConsiderW();
	if ( castWDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, true)
	
		bot:ActionQueue_UseAbility( abilityW )
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
	
	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
	local nEnemyHeroes = bot:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot) and nHP > 0.3
	then
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
	
	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = bot:GetAttackTarget();
		if ( J.IsRoshan(npcTarget) and J.CanCastOnMagicImmune(npcTarget) and J.IsInRange(npcTarget, bot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget;
		end
	end

	if J.IsInTeamFight(bot, 1400) and bot:HasScepter()
	then
		if tableNearbyEnemyHeroes ~= nil 
		   and #tableNearbyEnemyHeroes >= 1 
		   and J.IsValidHero(tableNearbyEnemyHeroes[1])
		   and J.CanCastOnNonMagicImmune(tableNearbyEnemyHeroes[1])
		then
			return BOT_ACTION_DESIRE_LOW, tableNearbyEnemyHeroes[1];
		end
	end
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = J.GetProperTarget(bot);
		if J.IsValidHero(npcTarget) 
		   and J.CanCastOnNonMagicImmune(npcTarget) 
		   and J.IsInRange(npcTarget, bot, nRadius) 
		   and J.CanCastOnTargetAdvanced(npcTarget)
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
		
		if J.IsValid(npcTarget) and #hEnemyHeroList == 0
		   and J.IsAllowedToSpam(bot, nManaCost) 
		   and J.CanCastOnNonMagicImmune(npcTarget) 
		   and J.CanCastOnTargetAdvanced(npcTarget)
		   and J.IsInRange(npcTarget, bot, nRadius) 
		   and not J.CanKillTarget(npcTarget,bot:GetAttackDamage() *1.48,DAMAGE_TYPE_PHYSICAL)
		then
			local nCreeps = bot:GetNearbyCreeps(800,true);
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
				or npcEnemy:HasModifier("modifier_bristleback_quill_spray")
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
	
	-- If Roshan
	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = bot:GetAttackTarget();
		if ( J.IsRoshan(npcTarget) and J.CanCastOnMagicImmune(npcTarget) and J.IsInRange(bot, npcTarget, nRadius)  )
		then
			return BOT_ACTION_DESIRE_MODERATE;
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

return X
-- dota2jmz@163.com QQ:2462331592
