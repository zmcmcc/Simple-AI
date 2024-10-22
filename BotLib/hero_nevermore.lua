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
			['t20'] = {10, 0},
			['t15'] = {10, 0},
			['t10'] = {0, 10},
		},
		--技能
		['Ability'] = {4,1,1,4,1,4,1,4,5,6,6,5,5,5,6},
		--装备
		['Buy'] = {
			sOutfit,
			"item_yasha",
			"item_black_king_bar",
			"item_manta",
			"item_skadi",
			"item_sphere",
			"item_sheepstick",
		},
		--出售
		['Sell'] = {
			"item_skadi",
			"item_urn_of_shadows",
			
			"item_sphere",
			"item_magic_wand",
		},
	},{
		--组合说明，不影响游戏
		['info'] = 'By Misunderstand',
		--天赋树
		['Talent'] = {
			['t25'] = {0, 10},
			['t20'] = {0, 10},
			['t15'] = {0, 10},
			['t10'] = {0, 10},
		},
		--技能
		['Ability'] = { 1, 4, 1, 4, 1, 6, 4, 1, 4, 5, 6, 5, 5, 5, 6 },
		--装备
		['Buy'] = {
			"item_faerie_fire",
			"item_double_slippers",
			"item_circlet",
			"item_double_enchanted_mango",
			"item_wraith_band",
			"item_bottle",
			"item_power_treads",
			"item_enchanted_mango",
			"item_cyclone", 
			"item_invis_sword",
			"item_black_king_bar",
			"item_ethereal_blade", 
			"item_travel_boots",
			"item_ultimate_scepter_2",
			"item_sheepstick",
			"item_silver_edge",
			"item_satanic",
			"item_travel_boots_2"
		},
		--出售
		['Sell'] = {
			"item_cyclone",
			"item_slippers",

			"item_invis_sword",
			"item_faerie_fire",
					
			"item_black_king_bar",
			"item_wraith_band",

			"item_ethereal_blade",
			"item_bottle",
					
			"item_travel_boots",
			"item_power_treads",
		},
	},{
		--组合说明，不影响游戏
		['info'] = 'By 铅笔会有猫的w',
		--天赋树
		['Talent'] = {
			['t25'] = {0, 10},
			['t20'] = {0, 10},
			['t15'] = {0, 10},
			['t10'] = {10, 0},
		},
		--技能
		['Ability'] = { 4, 1, 1, 4, 1, 4, 1, 4, 5, 6, 6, 5, 5, 5, 6 },
		--装备
		['Buy'] = {
			"item_flask",
			"item_double_circlet"	,
			"item_double_branches",
			"item_double_tango",
			"item_magic_wand",
			"item_bottle",
			"item_boots",
			"item_wraith_band",
			"item_power_treads",
			"item_dragon_lance",
			"item_invis_sword",
			"item_black_king_bar",
			"item_manta",
			"item_butterfly",
			"item_silver_edge",
			"item_satanic",
			"item_ultimate_scepter",
			"item_ultimate_scepter_2",
			"item_moon_shard",
			"item_travel_boots",
			"item_travel_boots",

		},
		--出售
		['Sell'] = {
			"item_travel_boots",
			"item_power_treads",

			"item_manta",
			"item_magic_wand",
					
			"item_butterfly",
			"item_bottle",
					
			"item_dragon_lance",
			"item_wraith_band",
		},
	},
}
--默认数据
local tDefaultGroupedData = {
	--天赋树
	['Talent'] = {
		['t25'] = {10, 0},
		['t20'] = {10, 0},
		['t15'] = {10, 0},
		['t10'] = {0, 10},
	},
	--技能
	['Ability'] = {4,1,1,4,1,4,1,4,5,6,6,5,5,5,6},
	--装备
	['Buy'] = {
		sOutfit,
		"item_yasha",
		"item_black_king_bar",
		"item_manta",
		"item_skadi",
		"item_sphere",
		"item_sheepstick",
	},
	--出售
	['Sell'] = {
		"item_skadi",
		"item_urn_of_shadows",
		
		"item_sphere",
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

local abilityZ = bot:GetAbilityByName( sAbilityList[1] )
local abilityX = bot:GetAbilityByName( sAbilityList[2] )
local abilityC = bot:GetAbilityByName( sAbilityList[3] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )
local talent6 = bot:GetAbilityByName( sTalentList[6] )

local castZDesire
local castXDesire
local castCDesire
local castRDesire

local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;
local talentDamage = 0


function X.SkillsComplement()

	
	J.ConsiderTarget();
	
	
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
	
	
	nKeepMana = 340
	talentDamage = 0
	nLV = bot:GetLevel();
	nMP = bot:GetMana()/bot:GetMaxMana();
	nHP = bot:GetHealth()/bot:GetMaxHealth();
	hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	
	
	if talent6:IsTrained() then talentDamage = talentDamage + talent6:GetSpecialValueInt("value") end
		
	
	castCDesire   = X.Consider(abilityC, 700)
	if castCDesire > 0
	then
				
		J.SetQueuePtToINT(bot, false)
				
		bot:ActionQueue_UseAbility( abilityC );
		return;
	end
	
	castXDesire  = X.Consider(abilityX,450);	
	if castXDesire > 0
	then
			
		J.SetQueuePtToINT(bot, false)
				
		bot:ActionQueue_UseAbility( abilityX );
		return;
	end
	
	castZDesire  = X.Consider(abilityZ,200);	
	if castZDesire > 0
	then
				
		J.SetQueuePtToINT(bot, false)
	
		bot:ActionQueue_UseAbility( abilityZ );
		return;	

	end
		
	castRDesire  = X.ConsiderR();	
	if castRDesire > 0
	then
	
		J.SetQueuePtToINT(bot, false)
	
		bot:ActionQueue_UseAbility ( abilityR );
		return;	
							
	end
end


function X.ConsiderR()

	-- Make sure it's castable
	if  not abilityR:IsFullyCastable() 
	   or ( bot:WasRecentlyDamagedByAnyHero(1.5) and not bot:HasModifier("modifier_black_king_bar_immune") and nHP < 0.62)
	then return 0; end

	-- Get some of its values 
	local nRadius = 1000;                          
	
	local nEnemysHerosInLong       = J.GetEnemyList(bot,1400); 
	local nEnemysHerosInSkillRange = J.GetEnemyList(bot,850); 
	local nEnemysHerosNearby       = J.GetEnemyList(bot,400); 
	
	for _,enemy in pairs(nEnemysHerosNearby)
	do
		if J.IsValidHero(enemy)
		   and enemy:HasModifier("modifier_brewmaster_storm_cyclone")
		   and J.GetModifierTime(enemy,"modifier_brewmaster_storm_cyclone") < 1.66
		   and enemy:GetHealth() > 800
		then
			return BOT_ACTION_DESIRE_HIGH;
		end			
	end
	
	if J.IsInTeamFight(bot,1200) or J.IsGoingOnSomeone(bot)
	then
		if #nEnemysHerosInSkillRange >= 3
			or (#nEnemysHerosNearby >= 1 and #nEnemysHerosInSkillRange >= 2)
			or (#nEnemysHerosInLong >= 3 and #nEnemysHerosInSkillRange >= 2)
			or (#nEnemysHerosInLong >= 4 and #nEnemysHerosNearby >= 1)
		then
			return BOT_ACTION_DESIRE_HIGH;
		end		
		
		local nAoe = bot:FindAoELocation( true, true, bot:GetLocation(), 100, 800, 1.67, 0 );
		if nAoe.count >= 3
		then
			return BOT_ACTION_DESIRE_HIGH;
		end	
		
		local npcTarget = J.GetProperTarget(bot);		
		if J.IsValidHero(npcTarget) 
			and J.CanCastOnNonMagicImmune(npcTarget) 
			and not J.IsDisabled(true, npcTarget)
			and GetUnitToUnitDistance(npcTarget,bot) <= 400
			and npcTarget:GetHealth() > 800
			and nHP > 0.38
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
		
	end
	
	return 0;
end


function X.Consider(nAbility,nDistance)
	
	-- Make sure it's castable
	if  not nAbility:IsFullyCastable() then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nRadius       = 248;
	local nCastLocation = J.GetFaceTowardDistanceLocation(bot,nDistance);					
	local nCastPoint    = nAbility:GetCastPoint();			    
	local nDamageType   = DAMAGE_TYPE_MAGICAL;
	local nSkillLV      = nAbility:GetLevel();
	local nDamage       = nAbility:GetSpecialValueInt('shadowraze_damage') + talentDamage;
	local nBonus        = nAbility:GetSpecialValueInt('stack_bonus_damage');
	local keyWord       = "ranged";
	local nEnemyHeroes  = bot:GetNearbyHeroes(1000,true,BOT_MODE_NONE);
	local npcTarget     = J.GetProperTarget(bot);
	
		
	if J.IsValidHero(npcTarget)
		and J.CanCastOnNonMagicImmune(npcTarget)
		and X.IsUnitNearLoc(npcTarget,nCastLocation,nRadius -20,nCastPoint)
		and not ( bot:GetMana() <= nKeepMana *(1 - nSkillLV/4) )
	then
		return BOT_ACTION_DESIRE_HIGH;
	end
	if J.IsValid(npcTarget)
	then
		for _,enemy in pairs(nEnemyHeroes)
		do
			if J.IsValidHero(enemy)
				and J.CanCastOnNonMagicImmune(enemy)
				and X.IsUnitNearLoc(enemy,nCastLocation,nRadius -30,nCastPoint)
				and (not ( bot:GetMana() <= nKeepMana *(1 - nSkillLV/4) ) 
					 or X.IsUnitCanBeKill(enemy,nDamage,nBonus,nCastPoint))
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	if nLV <= 12
	then
		local nLaneCreeps = bot:GetNearbyLaneCreeps(1000,true);
		local keyCount = 0;
		for _,creep in pairs(nLaneCreeps)
		do
			if J.IsValid(creep)
				and not creep:HasModifier("modifier_fountain_glyph")
				and J.IsKeyWordUnit(keyWord,creep)
				and X.IsUnitNearLoc(creep,nCastLocation,nRadius,nCastPoint)
				and X.IsUnitCanBeKill(creep,nDamage,nBonus,nCastPoint)			
			then
				keyCount = keyCount + 1;
			end
		end
		if keyCount >= 2
		then
			J.PrintAndReport("十二级下可击杀二远程:",keyCount);
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
		
	if not J.IsRetreating(bot) 
	then
		local nEnemysCreeps = bot:GetNearbyCreeps(1200,true);
		local tableLaneCreeps = bot:GetNearbyLaneCreeps(nDistance + nRadius * 1.5,true);
		local nCanHurtCount = 0;
		local nCanKillCount = 0;
		for _,creep in pairs(nEnemysCreeps)
		do
			if J.IsValid(creep)
				and not creep:HasModifier("modifier_fountain_glyph")
				and ( creep:GetMagicResist() < 0.4 or nMP > 0.9 )
				and X.IsUnitNearLoc(creep,nCastLocation,nRadius,nCastPoint)				
			then
				nCanHurtCount = nCanHurtCount +1;
				if X.IsUnitCanBeKill(creep,nDamage,nBonus,nCastPoint)
				then
					nCanKillCount = nCanKillCount +1;
				end
			end
		end
		
		if nLV >= 8 and nEnemyHeroes[1] == nil
		then
			if  (nCanHurtCount >= 4 and nMP > 0.6)
				or (nCanHurtCount >= 3 and bot:GetActiveMode() ~= BOT_MODE_LANING)
				or (nCanKillCount >= 2 and nCanHurtCount == #tableLaneCreeps )
				or (nCanHurtCount >= 2 and nMP > 0.8 and nLV > 10 and #nEnemysCreeps == 2)
				or (nCanHurtCount >= 2 and nLV > 24 and #nEnemysCreeps == 2 and J.IsAllowedToSpam(bot, 180))
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
		
		if nLV <= 10
		then
			if nCanKillCount >= 2 and ( nCanHurtCount == #tableLaneCreeps or nMP > 0.8 )
			then
				J.PrintAndReport("十级下可击杀二小兵:",nCanKillCount)
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
		
		if nCanKillCount >= 3
		then
			J.PrintAndReport("可击杀3小兵:",nCanKillCount)
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	return 0;
end


function X.IsUnitNearLoc(nUnit,vLoc,nRange,nDely)
	
	if GetUnitToLocationDistance(nUnit,vLoc) > 250
	then
		return false;
	end
	
	local nMoveSta = nUnit:GetMovementDirectionStability();
	if nMoveSta < 0.98 then nRange = nRange - 14; end
	if nMoveSta < 0.91 then nRange = nRange - 26; end
	if nMoveSta < 0.81 then nRange = nRange - 30; end
	
	local fLoc = J.GetCorrectLoc(nUnit, nDely);	
	if J.GetLocationToLocationDistance(fLoc,vLoc) < nRange
	then
		return true;
	end	
	
	return false;
	
end


function X.IsUnitCanBeKill(nUnit,nDamage,nBonus,nCastPoint)

	local nDamageType = DAMAGE_TYPE_MAGICAL;
	
	local nStack = 0;
	local nUnitModifier = nUnit:NumModifiers();
	
	if nUnitModifier >= 1
	then
		for i = 0, nUnitModifier 
		do
			if nUnit:GetModifierName(i) == "modifier_nevermore_shadowraze_debuff" 
			then
				nStack = nUnit:GetModifierStackCount(i);
				break;
			end
		end
	end
	
	local nRealDamage = nDamage + nStack * nBonus;
	

	return J.WillKillTarget(nUnit, nRealDamage, nDamageType, nCastPoint);
	
end


return X
-- dota2jmz@163.com QQ:2462331592
