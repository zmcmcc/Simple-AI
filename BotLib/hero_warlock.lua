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

local tTalentTree25 = {10,10}
if RandomInt(1,9) < 5
then  
	tTalentTree25[1] = 0; 
else
	tTalentTree25[2] = 0; 
end

--编组技能、天赋、装备
local tGroupedDataList = {
	{
		--组合说明，不影响游戏
		['info'] = 'By 决明子',
		--天赋树
		['Talent'] = {
			['t25'] = tTalentTree25,
			['t20'] = {0, 10},
			['t15'] = {0, 10},
			['t10'] = {0, 10},
		},
		--技能
		['Ability'] = {2,1,2,1,2,6,2,1,1,3,6,3,3,3,6},
		--装备
		['Buy'] = {
			sOutfit,
			"item_mekansm",
			"item_urn_of_shadows",
			"item_glimmer_cape",
			"item_rod_of_atos",
			"item_guardian_greaves",
			"item_spirit_vessel",
			"item_ultimate_scepter",
			"item_refresher",
		},
		--出售
		['Sell'] = {
			"item_ultimate_scepter",
			"item_magic_wand",
		},
	},
	{
		--组合说明，不影响游戏
		['info'] = 'By 决明子2',
		--天赋树
		['Talent'] = {
			['t25'] = tTalentTree25,
			['t20'] = {0, 10},
			['t15'] = {0, 10},
			['t10'] = {0, 10},
		},
		--技能
		['Ability'] = {2,1,2,1,2,6,1,2,1,3,6,3,3,3,6},
		--装备
		['Buy'] = {
			sOutfit,
			"item_mekansm",
			"item_urn_of_shadows",
			"item_glimmer_cape",
			"item_rod_of_atos",
			"item_guardian_greaves",
			"item_spirit_vessel",
			"item_ultimate_scepter",
			"item_refresher",
		},
		--出售
		['Sell'] = {
			"item_ultimate_scepter",
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
			['t10'] = {0, 10},
		},
		--技能
		['Ability'] = { 2, 1, 2, 1, 2, 6, 2, 1, 3, 1, 6, 3, 3, 3, 6 },
		--装备
		['Buy'] = {
			"item_tango",
			"item_flask",
			"item_double_clarity",
			"item_enchanted_mango",
			"item_double_branches",
			"item_magic_stick",
			"item_arcane_boots",
			"item_magic_wand",
			"item_hand_of_midas",
			"item_mekansm", 
			"item_ultimate_scepter",
			"item_pipe",
			"item_guardian_greaves",
			"item_refresher",
			"item_ultimate_scepter_2",
			"item_lotus_orb",
			"item_sheepstick"
		},
		--出售
		['Sell'] = {
			"item_lotus_orb",     
			"item_hand_of_midas",
		},
	},{
		--组合说明，不影响游戏
		['info'] = 'By 铅笔会有猫的w',
		--天赋树
		['Talent'] = {
			['t25'] = {0, 10},
			['t20'] = {0, 10},
			['t15'] = {0, 10},
			['t10'] = {0, 10},
		},
		--技能
		['Ability'] = { 2, 1, 2, 1, 2, 6, 2, 1, 1, 3, 6, 3, 3, 3, 6 },
		--装备
		['Buy'] = {
			"item_double_tango",
			"item_flask",
			"item_double_branches",
			"item_boots", 		
			"item_magic_stick",
			"item_hand_of_midas",
			"item_magic_wand",
			"item_bracer",
			"item_glimmer_cape", 
			"item_ultimate_scepter", 
			"item_arcane_boots", 
			"item_refresher", 
			"item_octarine_core", 
			"item_sheepstick",
			"item_ultimate_scepter_2", 		
			"item_force_staff", 
		},
		--出售
		['Sell'] = {
			"item_sheepstick",     
			"item_hand_of_midas",

			"item_refresher",     
			"item_magic_wand",

			"item_ultimate_scepter",     
			"item_bracer",
		},
	},
}
--默认数据
local tDefaultGroupedData = {
	--天赋树
	['Talent'] = {
		['t25'] = tTalentTree25,
		['t20'] = {0, 10},
		['t15'] = {0, 10},
		['t10'] = {0, 10},
	},
	--技能
	['Ability'] = {2,1,2,1,2,6,2,1,1,3,6,3,3,3,6},
	--装备
	['Buy'] = {
		sOutfit,
		"item_mekansm",
		"item_urn_of_shadows",
		"item_glimmer_cape",
		"item_rod_of_atos",
		"item_guardian_greaves",
		"item_spirit_vessel",
		"item_ultimate_scepter",
		"item_refresher",
	},
	--出售
	['Sell'] = {
		"item_ultimate_scepter",
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


--[[
modifier_warlock_fatal_bonds
modifier_warlock_shadow_word
modifier_warlock_upheaval
modifier_warlock_rain_of_chaos_death_trigger
modifier_warlock_rain_of_chaos_thinker
modifier_special_bonus_unique_warlock_1
modifier_special_bonus_unique_warlock_2
modifier_warlock_golem_flaming_fists
modifier_warlock_golem_permanent_immolation
modifier_warlock_golem_permanent_immolation_debuff
]]--


local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )
local talent2 = bot:GetAbilityByName( sTalentList[2] )
local talent6 = bot:GetAbilityByName( sTalentList[6] )


local castQDesire, castQTarget
local castWDesire, castWTarget
local castEDesire, castELocation
local castRDesire, castRLocation
local castRFRDesire, castRFRLocation


local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;
local aetherRange = 0



local abilityRef = nil

function X.SkillsComplement()

	
	if X.ConsiderStop() == true 
	then 
		bot:Action_ClearActions(true);
		return; 
	end
	
	
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
	
	--J.Skill.AbilityReadinessReminder(abilityR, 5);
	
	
	nKeepMana = 400
	aetherRange = 0
	nLV = bot:GetLevel();
	nMP = bot:GetMana()/bot:GetMaxMana();
	nHP = bot:GetHealth()/bot:GetMaxHealth();
	hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	abilityRef = J.IsItemAvailable("item_refresher");
	
	
	
	local aether = J.IsItemAvailable("item_aether_lens");
	if aether ~= nil then aetherRange = 250 end	
	if talent2:IsTrained() then aetherRange = aetherRange + talent2:GetSpecialValueInt("value") end
	
	
	
	
	castRFRDesire, castRFRLocation  = X.ConsiderRFR();
	if ( castRFRDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, true)
	
		bot:ActionQueue_UseAbilityOnLocation( abilityR, castRFRLocation + RandomVector(50) );
		bot:ActionQueue_UseAbility( abilityRef );
		bot:ActionQueue_UseAbilityOnLocation( abilityR, castRFRLocation + RandomVector(50) );
		bot:ActionImmediate_Chat("听从吾之召唤!来自深渊的地狱火啊!出来吧!!!", true);
		return;
	
	end	
	
	
	castRDesire, castRLocation = X.ConsiderR();
	if ( castRDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, true)
	
		bot:ActionQueue_UseAbilityOnLocation( abilityR, castRLocation );
		return;
	
	end	
	
	
	castQDesire, castQTarget   = X.ConsiderQ();
	if ( castQDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, true)
	
		bot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget )
		return;
	end
	
	
	castWDesire, castWTarget = X.ConsiderW();
	if ( castWDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, true)
		
		if talent6:IsTrained() 
		then
			bot:ActionQueue_UseAbilityOnLocation( abilityW, castWTarget )
		else
			bot:ActionQueue_UseAbilityOnEntity( abilityW, castWTarget )
		end
		return;
	end
	
	castEDesire, castELocation = X.ConsiderE();
	if ( castEDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, true)
	
		bot:ActionQueue_UseAbilityOnLocation( abilityE, castELocation )
		return;
	end
	

end

function X.ConsiderStop()
	
	if bot:IsChanneling()
	   and not bot:HasModifier("modifier_teleporting")
	then
		local tableEnemyHeroes = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
		local tableAllyHeroes  = bot:GetNearbyHeroes(1600,false,BOT_MODE_NONE);
		if abilityR:IsFullyCastable()
		   or abilityQ:IsFullyCastable() 
		   or abilityW:IsFullyCastable() 
		   or #tableEnemyHeroes == 0
		   or #tableAllyHeroes == 1
		then
			return true;
		end
	end


	return false;
end

function X.ConsiderR()
	
	if not abilityR:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE, nil;	end
	
	if abilityQ:IsFullyCastable() 
	   and bot:GetMana() >= ( abilityQ:GetManaCost() + abilityR:GetManaCost() )
	   and nHP > 0.5 
	then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = abilityR:GetCastRange() + aetherRange
	local nCastPoint = abilityR:GetCastPoint();
	local manaCost   = abilityR:GetManaCost();
	local nRadius    = abilityR:GetSpecialValueInt( "aoe" );
	local hTrueHeroList = J.GetEnemyList(bot,1400);
	
	
	local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
	if ( locationAoE.count >= 2 and #hTrueHeroList >= 2 )
		or locationAoE.count >= 3
	then
		return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
	end
	if locationAoE.count >= 1 and J.GetHPR(bot) < 0.38 and #hTrueHeroList >= 1
	then
		return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
	end
	
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = J.GetProperTarget(bot);
		if J.IsValidHero(npcTarget) 
		   and J.CanCastOnMagicImmune(npcTarget) 
		   and J.IsInRange(npcTarget, bot, nCastRange + 200) 
		then
			if #hTrueHeroList >= 2 then
				return BOT_ACTION_DESIRE_HIGH, npcTarget:GetExtrapolatedLocation(nCastPoint);
			end	
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end

function X.ConsiderRFR()
	
	if not abilityR:IsFullyCastable() 
	   or abilityRef == nil
	   or not abilityRef:IsFullyCastable()
	then return BOT_ACTION_DESIRE_NONE, nil; end
	
	if abilityQ:IsFullyCastable() 
	   and bot:GetMana() >= ( abilityQ:GetManaCost() + abilityR:GetManaCost() )
	   and nHP > 0.5 
	then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	if bot:GetMana() < abilityR:GetManaCost() *2 + abilityRef:GetManaCost()
	then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = abilityR:GetCastRange() + aetherRange
	local nCastPoint = abilityR:GetCastPoint();
	local manaCost   = abilityR:GetManaCost();
	local nRadius    = abilityR:GetSpecialValueInt( "aoe" );
	local hTrueHeroList = J.GetEnemyList(bot, 1600);
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = J.GetProperTarget(bot);
		if J.IsValidHero(npcTarget) 
		   and J.CanCastOnMagicImmune(npcTarget) 
		   and J.IsInRange(npcTarget, bot, nCastRange + 200) 
		then
			if #hTrueHeroList >= 3 then
				return BOT_ACTION_DESIRE_HIGH, npcTarget:GetExtrapolatedLocation(nCastPoint);
			end	
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end

function X.ConsiderE()

	if not abilityE:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE, nil end
	
	if abilityR:IsFullyCastable() 
	   or abilityQ:IsFullyCastable()
	   or abilityW:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = abilityE:GetCastRange() + 30 + aetherRange
	local nCastPoint = abilityE:GetCastPoint();
	local manaCost   = abilityE:GetManaCost();
	local nRadius    = abilityE:GetSpecialValueInt( "aoe" );
	
	if J.IsInTeamFight(bot, 1200)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius/2, 0, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end

	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = J.GetProperTarget(bot);
		if J.IsValidHero(npcTarget) 
		   and J.CanCastOnNonMagicImmune(npcTarget) 
		   and J.IsInRange(npcTarget, bot, nCastRange + 200) 
		then
			local enemies = npcTarget:GetNearbyHeroes(nRadius, false, BOT_MODE_NONE);
			if #enemies >= 2 then
				return BOT_ACTION_DESIRE_HIGH, npcTarget:GetExtrapolatedLocation(nCastPoint);
			end	
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end

local lastCheck = -90;
function X.ConsiderW()

	if not abilityW:IsFullyCastable() then	return BOT_ACTION_DESIRE_NONE, nil;	end
	
	local nCastRange = abilityW:GetCastRange() + 50 + aetherRange
	local nCastPoint = abilityW:GetCastPoint();
	local manaCost   = abilityW:GetManaCost();
	local nRadius    = 0;
	
	if talent6:IsTrained() then nRadius = 250 end
	
	if DotaTime() >= lastCheck + 0.5 then 
		local weakest = nil;
		local minHP = 100000;
		local allies = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE);
		if #allies > 0 then
			for i=1,#allies do
				if not allies[i]:HasModifier("modifier_warlock_shadow_word")
				   and J.CanCastOnNonMagicImmune(allies[i]) 
				   and allies[i]:GetHealth() <= minHP
     			   and allies[i]:GetHealth() <= 0.65 * allies[i]:GetMaxHealth()  
				then
					weakest = allies[i];
					minHP = allies[i]:GetHealth();
				end
			end
		end
		if weakest ~= nil then
			if talent6:IsTrained() then
				return BOT_ACTION_DESIRE_HIGH, weakest:GetLocation();
			else
				return BOT_ACTION_DESIRE_HIGH, weakest;
			end
		end
		lastCheck = DotaTime();
	end
	
	if J.IsInTeamFight(bot, 1200) 
	then	
		if talent6:IsTrained() 
		then
			local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
			if ( locationAoE.count >= 2 ) 
			then
				return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
			end
		else
			
			local npcWeakestEnemy = nil;
			local npcWeakestEnemyHealth = 10000;		
			local nEnemysHerosInRange = bot:GetNearbyHeroes(nCastRange,true,BOT_MODE_NONE);
			for _,npcEnemy in pairs( nEnemysHerosInRange )
			do
				if  J.IsValid(npcEnemy)
					and J.CanCastOnNonMagicImmune(npcEnemy) 
					and J.CanCastOnTargetAdvanced(npcEnemy)
					and not npcEnemy:HasModifier("modifier_warlock_shadow_word")
				then
					local npcEnemyHealth = npcEnemy:GetHealth();
					if ( npcEnemyHealth < npcWeakestEnemyHealth )
					then
						npcWeakestEnemyHealth = npcEnemyHealth;
						npcWeakestEnemy = npcEnemy;
					end
				end
			end
			
			if ( npcWeakestEnemy ~= nil )
			then
				return BOT_ACTION_DESIRE_HIGH, npcWeakestEnemy;
			end		
		
		end
	end
	
	if J.IsGoingOnSomeone(bot)
	then
		local target = J.GetProperTarget(bot);
		if J.IsValidHero(target) 
		   and J.CanCastOnNonMagicImmune(target) 
		   and J.CanCastOnTargetAdvanced(target)
		   and J.IsInRange(target, bot, nCastRange) 
		   and not target:HasModifier("modifier_warlock_shadow_word")
		then
			if talent6:IsTrained() then
				return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
			else
				return BOT_ACTION_DESIRE_HIGH, target;
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, nil;
end

function X.ConsiderQ()

	if not abilityQ:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE, nil; end
	
	local nCastRange = abilityQ:GetCastRange() + 50 + aetherRange; 
	local nCastPoint = abilityQ:GetCastPoint();
	local manaCost   = abilityQ:GetManaCost();
	local nRadius    = abilityQ:GetSpecialValueInt( "search_aoe" );
	local nCount     = abilityQ:GetSpecialValueInt( "count" );
	
	
	if J.IsInTeamFight(bot, 1000) 
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange,true,BOT_MODE_NONE);
			if J.IsValidHero(nEnemyHeroes[1])
				and J.CanCastOnNonMagicImmune(nEnemyHeroes[1])
				and J.CanCastOnTargetAdvanced(nEnemyHeroes[1])
			then
				return  BOT_ACTION_DESIRE_HIGH, nEnemyHeroes[1];
			end
		end
	end
	
	if J.IsRetreating(bot)
	then
		local target = J.GetVulnerableWeakestUnit(true, true, nCastRange - 100, bot);
		if target ~= nil and J.GetUnitAllyCountAroundEnemyTarget(target, nRadius) >= 3 then
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		local target = J.GetProperTarget(bot);
		if J.IsValidHero(target) 
		   and J.CanCastOnNonMagicImmune(target) 
		   and J.CanCastOnTargetAdvanced(target)
		   and J.IsInRange(target, bot, nCastRange) 
		then
			if J.GetAroundTargetEnemyUnitCount(target, nRadius) >= 3 then
				return BOT_ACTION_DESIRE_HIGH, target;
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, nil;
end

return X
-- dota2jmz@163.com QQ:2462331592
