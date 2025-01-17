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
			['t25'] = {0, 10},
			['t20'] = {10, 0},
			['t15'] = {0, 10},
			['t10'] = {0, 10},
		},
		--技能
		['Ability'] = {1,3,2,3,1,6,1,1,3,3,6,2,2,2,6},
		--装备
		['Buy'] = {
			sOutfit,
			"item_sange_and_yasha",
			"item_diffusal_blade",
			"item_black_king_bar",
			"item_abyssal_blade", 
			"item_monkey_king_bar",
		},
		--出售
		['Sell'] = {
			"item_sange_and_yasha",
			"item_quelling_blade",
			
			"item_abyssal_blade",
			"item_magic_wand",
		},
	},{
		--组合说明，不影响游戏
		['info'] = 'By Misunderstand',
		--天赋树
		['Talent'] = {
			['t25'] = {10, 0},
			['t20'] = {10, 0},
			['t15'] = {0, 10},
			['t10'] = {0, 10},
		},
		--技能
		['Ability'] = { 1, 3, 2, 3, 3, 6, 2, 3, 2, 2, 6, 1, 1, 1, 6 },
		--装备
		['Buy'] = {
			"item_tango",
			"item_flask",
			"item_stout_shield",
			"item_quelling_blade",
			"item_double_branches",
			"item_magic_stick",
			"item_wraith_band",
			"item_magic_wand",
			"item_phase_boots",
			"item_blade_mail",
			"item_sange_and_yasha",
			"item_radiance", 
			"item_black_king_bar",
			"item_basher",
			"item_butterfly",
			"item_abyssal_blade",
			"item_ultimate_scepter_2",
			"item_nullifier",
			"item_moon_shard"
		},
		--出售
		['Sell'] = {
			"item_blade_mail",     
			"item_quelling_blade",

			"item_sange_and_yasha",     
			"item_stout_shield",
					
			"item_radiance",  
			"item_wraith_band",

			"item_black_king_bar",
			"item_magic_wand",	     

			"item_butterfly",
			"item_blade_mail",

			"item_nullifier", 
			"item_sange_and_yasha"
		},
	},{
		--组合说明，不影响游戏
		['info'] = 'By 铅笔会有猫的w',
		--天赋树
		['Talent'] = {
			['t25'] = {0, 10},
			['t20'] = {10, 0},
			['t15'] = {10, 0},
			['t10'] = {10, 0},
		},
		--技能
		['Ability'] = { 1, 2, 3, 2, 2, 6, 2, 3, 3, 3, 6, 1, 1, 1, 6 },
		--装备
		['Buy'] = {
			"item_tango",
			"item_flask",
			"item_stout_shield",
			"item_quelling_blade",
			"item_magic_stick",			
			"item_power_treads",
			"item_magic_wand",
			"item_maelstrom",
			"item_blade_mail",			
			"item_basher",
			"item_black_king_bar", 
			"item_mjollnir", 			
			"item_abyssal_blade",
			"item_butterfly",
			"item_silver_edge",
			"item_bloodthorn",
			"item_moon_shard",
			"item_ultimate_scepter",
			"item_ultimate_scepter_2",
		},
		--出售
		['Sell'] = {
			"item_bloodthorn",     
			"item_power_treads",

			"item_silver_edge",     
			"item_blade_mail",

			"item_basher",     
			"item_quelling_blade",

			"item_black_king_bar",     
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
	['Ability'] = {1,3,2,3,1,6,1,1,3,3,6,2,2,2,6},
	--装备
	['Buy'] = {
		sOutfit,
		"item_sange_and_yasha",
		"item_diffusal_blade",
		"item_black_king_bar",
		"item_abyssal_blade", 
		"item_monkey_king_bar",
	},
	--出售
	['Sell'] = {
		"item_sange_and_yasha",
		"item_quelling_blade",
		
		"item_abyssal_blade",
		"item_magic_wand",
	},
}

--根据组数据生成技能、天赋、装备
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
local abilityR = bot:GetAbilityByName( sAbilityList[6] );

local castQDesire, castQTarget   = 0;
local castWDesire, castWLocation = 0;
local castRDesire, castRTarget   = 0;

local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;


function X.SkillsComplement()

	
	
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
	
	
	
	nKeepMana = 300; 
	nMP = bot:GetMana()/bot:GetMaxMana();
	nHP = bot:GetHealth()/bot:GetMaxHealth();
	nLV = bot:GetLevel();
	hEnemyHeroList = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	
	
	
	
	castRDesire, castRTarget   = X.ConsiderR();
	if ( castRDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, false)
	
		bot:ActionQueue_UseAbilityOnEntity( abilityR, castRTarget)
		return;
	
	end
	
	castQDesire, castQTarget   = X.ConsiderQ();
	if ( castQDesire > 0 ) 
	then
	
		bot:Action_ClearActions(false);
	
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
	

end

function X.ConsiderQ()

	-- Make sure it's castable
	if  not abilityQ:IsFullyCastable() then return 0 end

	-- Get some of its values
	local nCastRange = abilityQ:GetCastRange();
	local nCastPoint = abilityQ:GetCastPoint();
	local nManaCost  = abilityQ:GetManaCost();
	local nDamage    = bot:GetAttackDamage()+ (( abilityQ:GetSpecialValueInt( 'damage_increase_pct' ) / 100 ) * bot:GetAttackDamage());
	
	local npcTarget = J.GetProperTarget(bot);
	
	--对线期提高补刀
	if   bot:GetActiveMode() == BOT_MODE_LANING  
	     and not bot:HasModifier('modifier_bloodseeker_bloodrage')
	then
		local tableNearbyEnemyCreeps = bot:GetNearbyLaneCreeps( 1000, true );
		local tableNearbyAllyCreeps  = bot:GetNearbyLaneCreeps( 1000, false );
		for _,ECreep in pairs(tableNearbyEnemyCreeps)
		do
			if  J.IsValid(ECreep) and J.CanKillTarget(ECreep, nDamage *1.38, DAMAGE_TYPE_PHYSICAL) then
				return BOT_ACTION_DESIRE_HIGH, bot;
			end
		end
		for _,ACreep in pairs(tableNearbyAllyCreeps)
		do
			if  J.IsValid(ACreep) and J.CanKillTarget(ACreep, nDamage *1.18, DAMAGE_TYPE_PHYSICAL) then
				return BOT_ACTION_DESIRE_HIGH, bot;
			end
		end
	end	
	
	--打野时吸血
	if  J.IsValid(npcTarget) and npcTarget:GetTeam() == TEAM_NEUTRAL 
	    and not bot:HasModifier('modifier_bloodseeker_bloodrage')
	then
		local tableNearbyCreeps = bot:GetNearbyCreeps( 1000, true );
		for _,ECreep in pairs(tableNearbyCreeps)
		do
			if J.IsValid(ECreep) and J.CanKillTarget(ECreep, nDamage, DAMAGE_TYPE_PHYSICAL) then
				return BOT_ACTION_DESIRE_HIGH, bot;
			end
		end
	end	
	

	--打野时提高输出
	if J.IsFarming(bot) 
		and #hEnemyHeroList == 0
		and bot:GetHealth() > 300
	then
	
		if not bot:HasModifier('modifier_bloodseeker_bloodrage')
		then
			return BOT_ACTION_DESIRE_HIGH, bot;
		end
		
		if J.IsValid(npcTarget)
			and npcTarget:GetTeam() == TEAM_NEUTRAL
			and not J.CanKillTarget(npcTarget, nDamage * 2.18, DAMAGE_TYPE_PHYSICAL)
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	--打肉时破林肯
	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		if not bot:HasModifier('modifier_bloodseeker_bloodrage')
		then
			return BOT_ACTION_DESIRE_HIGH, bot;
		end	
	
		local npcTarget = J.GetProperTarget(bot);
		if ( J.IsRoshan(npcTarget) 
		     and J.IsInRange(npcTarget, bot, nCastRange) 
		     and not npcTarget:HasModifier('modifier_bloodseeker_bloodrage')  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget;
		end
	end

	--团战时辅助
	if J.IsInTeamFight(bot, 1200) or J.IsPushing(bot) or J.IsDefending(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
	    
		if  #tableNearbyEnemyHeroes >= 1 then
			local tableNearbyAllyHeroes = bot:GetNearbyHeroes( nCastRange + 200, false, BOT_MODE_NONE );
			local highesAD = 0;
			local highesADUnit = nil;
			
			for _,npcAlly in pairs( tableNearbyAllyHeroes )
			do
				local AllyAD = npcAlly:GetAttackDamage();
				if ( J.IsValid(npcAlly) 
					 and npcAlly:GetAttackTarget() ~= nil
				     and J.CanCastOnNonMagicImmune(npcAlly) 
					 and ( J.GetHPR(npcAlly) > 0.18 or J.GetHPR(npcAlly:GetAttackTarget()) < 0.18 )
					 and not npcAlly:HasModifier('modifier_bloodseeker_bloodrage')
					 and AllyAD > highesAD ) 
				then
					highesAD = AllyAD;
					highesADUnit = npcAlly;
				end
			end
			
			if highesADUnit ~= nil then
				return BOT_ACTION_DESIRE_HIGH, highesADUnit;
			end
		
		end	
		
	end
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = J.GetProperTarget(bot);
		if J.IsValidHero(npcTarget) 
		   and J.CanCastOnNonMagicImmune(npcTarget) 
		   and J.IsInRange(npcTarget, bot, nCastRange + 150) 
		then
		    if J.IsDisabled(true, npcTarget) 
			   and J.GetHPR(npcTarget) < 0.62
			   and J.GetProperTarget(npcTarget) == nil
			   and not npcTarget:HasModifier('modifier_bloodseeker_bloodrage')
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			elseif not bot:HasModifier('modifier_bloodseeker_bloodrage') 
			    then 
				    return BOT_ACTION_DESIRE_HIGH, bot;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function X.ConsiderW()

	-- Make sure it's castable
	if not abilityW:IsFullyCastable()  then return 0 end

	-- Get some of its values
	local nRadius    = 600;
	local nCastRange = abilityW:GetCastRange();
	local nCastPoint = abilityW:GetCastPoint();
	local nDelay	 = abilityW:GetSpecialValueFloat( 'delay' );
	local nManaCost  = abilityW:GetManaCost();
	local nDamage    = abilityW:GetSpecialValueInt('damage');
	
	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	local tableNearbyAllyHeroes = bot:GetNearbyHeroes( 800, false, BOT_MODE_NONE );
	
	--if we can kill any enemies
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if  J.IsValid(npcEnemy) and J.CanCastOnNonMagicImmune(npcEnemy) and J.CanKillTarget(npcEnemy, nDamage, DAMAGE_TYPE_PURE)
		then
			if  npcEnemy:GetMovementDirectionStability() >= 0.75 then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetExtrapolatedLocation(nDelay);
			else
				return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation();
			end
		end
	end
	
	--对线期补兵
	if bot:GetActiveMode() == BOT_MODE_LANING and J.IsAllowedToSpam(bot, nManaCost) 
	then
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), 1000, nRadius/2, nCastPoint, nDamage );
		if ( locationAoE.count >= 4 ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc;
		end
	end	
	
	--推进带线
	if ( J.IsPushing(bot) or J.IsDefending(bot) ) and J.IsAllowedToSpam(bot, nManaCost) 
		 and tableNearbyEnemyHeroes == nil or #tableNearbyEnemyHeroes == 0 
		 and #tableNearbyAllyHeroes <= 2
	then
		local lanecreeps = bot:GetNearbyLaneCreeps(1000, true);
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), 1000, nRadius/2, nCastPoint, nDamage );
		if ( locationAoE.count >= 4 and #lanecreeps >= 4 ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc;
		end
	end	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot)
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( J.IsValid(npcEnemy) and bot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) and J.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, bot:GetLocation();
			end
		end
	end

	--团战
	if J.IsInTeamFight(bot, 1200)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange - 200, nRadius/2, nCastPoint, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			local nInvUnit = J.GetInvUnitInLocCount(bot, nCastRange, nRadius/2, locationAoE.targetloc, false);
			if nInvUnit >= locationAoE.count then
				return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc;
			end
		end
	end
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = J.GetProperTarget(bot);
		if J.IsValidHero(npcTarget) 
		   and J.CanCastOnNonMagicImmune(npcTarget) 
		   and J.IsInRange(npcTarget, bot, nCastRange + nRadius) 
		then
			local nCastLoc = J.GetDelayCastLocation(bot,npcTarget,nCastRange,nRadius,2.0)
			if nCastLoc ~= nil 
			then
				return BOT_ACTION_DESIRE_HIGH, nCastLoc;
			end
		end
	end
	
	--特殊用法
	local skThere, skLoc = J.IsSandKingThere(bot, nCastRange, 2.0);
	if skThere then
		return BOT_ACTION_DESIRE_MODERATE, skLoc;
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function X.ConsiderR()

	-- Make sure it's castable
	if not abilityR:IsFullyCastable() then 	return 0 end

	-- Get some of its values
	local nCastRange   = abilityR:GetCastRange();
	local nCastPoint   = abilityR:GetCastPoint();
	local nManaCost    = abilityR:GetManaCost();
	
	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange +200, true, BOT_MODE_NONE );
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot) 
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if bot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) 
			   and J.CanCastOnMagicImmune( npcEnemy )
			   and J.CanCastOnTargetAdvanced(npcEnemy)
			   and not npcEnemy:HasModifier('modifier_bloodseeker_bloodrage')
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
			end
		end
	end

	if J.IsInTeamFight(bot, 1200)
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if J.CanCastOnMagicImmune(npcEnemy) 
			   and J.CanCastOnTargetAdvanced(npcEnemy)
			   and J.Role.IsCarry(npcEnemy:GetUnitName()) 
			   and not npcEnemy:HasModifier('modifier_bloodseeker_bloodrage')
			   and not J.IsDisabled(true, npcEnemy) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = J.GetProperTarget(bot);
		if J.IsValidHero(npcTarget) 
		   and J.CanCastOnMagicImmune(npcTarget)
		   and J.CanCastOnTargetAdvanced(npcTarget)
		   and J.IsInRange(npcTarget, bot, nCastRange +100)
		   and not npcTarget:HasModifier('modifier_bloodseeker_bloodrage')
		   and not J.IsDisabled(true, npcTarget)
		then
			local allies = npcTarget:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
			if ( allies ~= nil and #allies >= 2 )
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end


return X
-- dota2jmz@163.com QQ:2462331592
