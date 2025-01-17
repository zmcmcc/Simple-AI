----------------------------------------------------------------------------------------------------
--- The Creation Come From: BOT EXPERIMENT Credit:FURIOUSPUPPY
--- BOT EXPERIMENT Author: Arizona Fauzie 2018.11.21
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=837040016
--- Update by: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
----------------------------------------------------------------------------------------------------
local X = {}
local bDebugMode = false
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
			['t15'] = {0, 10},
			['t10'] = {10, 0},
		},
		--技能
		['Ability'] = {2,1,1,3,3,6,3,3,1,2,6,1,2,2,6},
		--装备
		['Buy'] = {
			sOutfit,
			"item_mask_of_madness",
			"item_sange_and_yasha",
			"item_ultimate_scepter",
			"item_black_king_bar",
			"item_broken_satanic",	
			"item_monkey_king_bar",
		},
		--出售
		['Sell'] = {
			"item_ultimate_scepter",
			"item_urn_of_shadows",
				
			"item_black_king_bar",
			"item_magic_wand",
		},
	},{
		--组合说明，不影响游戏
		['info'] = 'By Misunderstand',
		--天赋树
		['Talent'] = {
			['t25'] = {10, 0},
			['t20'] = {10, 0},
			['t15'] = {10, 0},
			['t10'] = {10, 0},
		},
		--技能
		['Ability'] = { 2, 1, 2, 3, 1, 6, 1, 1, 3, 2, 6, 3, 3, 2, 6 },
		--装备
		['Buy'] = {
			"item_faerie_fire",
			"item_double_slippers",
			"item_wind_lace",
			"item_tango",
			"item_magic_stick",
			"item_magic_wand",
			"item_double_wraith_band",
			"item_enchanted_mango",
			"item_phase_boots",
			"item_cyclone",
			"item_black_king_bar", 
			"item_sange_and_yasha",
			"item_shivas_guard", 
			"item_ultimate_scepter",
			"item_travel_boots",
			"item_ultimate_scepter_2",
			"item_heart", 
			"item_moon_shard",
			"item_travel_boots_2"
		},
		--出售
		['Sell'] = {
			"item_cyclone",
			"item_faerie_fire",

			"item_sange_and_yasha",
			"item_magic_wand",
					
			"item_shivas_guard",   
			"item_wraith_band",  

			"item_travel_boots",
			"item_phase_boots",
		},
	},{
		--组合说明，不影响游戏
		['info'] = 'By 铅笔会有猫的w',
		--天赋树
		['Talent'] = {
			['t25'] = {10, 0},
			['t20'] = {10, 0},
			['t15'] = {0, 10},
			['t10'] = {0, 10},
		},
		--技能
		['Ability'] = { 2, 1, 2, 1, 2, 6, 3, 3, 3, 3, 6, 1, 1, 2, 6 },
		--装备
		['Buy'] = {
			"item_flask",
			"item_circlet"	,
			"item_gauntlets",
			"item_double_tango",
			"item_bracer",
			"item_magic_stick",			
			"item_arcane_boots",
			"item_magic_wand",		
			"item_kaya",
			"item_veil_of_discord",			
			"item_ultimate_scepter",
			"item_black_king_bar",
			"item_shivas_guard",
			"item_kaya_and_sange",			
			"item_ultimate_scepter_2",
			"item_refresher",
			"item_guardian_greaves",
			"item_pipe",
			"item_moon_shard",
		},
		--出售
		['Sell'] = {
			"item_travel_boots_2",
			"item_power_treads",

			"item_pipe",
			"item_veil_of_discord",

			"item_shivas_guard",
			"item_bracer",

			"item_black_king_bar",
			"item_magic_wand",	
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
		['t10'] = {10, 0},
	},
	--技能
	['Ability'] = {2,1,1,3,3,6,3,3,1,2,6,1,2,2,6},
	--装备
	['Buy'] = {
		sOutfit,
		"item_mask_of_madness",
		"item_sange_and_yasha",
		"item_ultimate_scepter",
		"item_black_king_bar",
		"item_broken_satanic",	
		"item_monkey_king_bar",
	},
	--出售
	['Sell'] = {
		"item_ultimate_scepter",
		"item_urn_of_shadows",
		
		"item_black_king_bar",
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

npc_dota_hero_razor

"Ability1"		"razor_plasma_field"
"Ability2"		"razor_static_link"
"Ability3"		"razor_unstable_current"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"razor_eye_of_the_storm"
"Ability10"		"special_bonus_hp_200"
"Ability11"		"special_bonus_agility_15"
"Ability12"		"special_bonus_unique_razor"
"Ability13"		"special_bonus_unique_razor_3"
"Ability14"		"special_bonus_armor_10"
"Ability15"		"special_bonus_unique_razor_2"
"Ability16"		"special_bonus_attack_speed_100"
"Ability17"		"special_bonus_unique_razor_4"

modifier_razor_plasma_field_thinker
modifier_razor_static_link
modifier_razor_static_link_buff
modifier_razor_static_link_debuff
modifier_razor_link_vision
modifier_razor_unstable_current
modifier_razor_unstablecurrent_slow
modifier_razor_eye_of_the_storm
modifier_razor_eye_of_the_storm_armor
]]--


local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )


local castQDesire
local castWDesire, castWTarget
local castRDesire

local nKeepMana,nMP,nHP,nLV,hEnemyList,hAllyList,botTarget,sMotive;

local aetherRange = 0

function X.SkillsComplement()


	J.ConsiderForMkbDisassembleMask(bot);

	
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
	
	
	nKeepMana = 280
	aetherRange = 0
	nLV = bot:GetLevel();
	nMP = bot:GetMana()/bot:GetMaxMana();
	nHP = bot:GetHealth()/bot:GetMaxHealth();
	botTarget = J.GetProperTarget(bot);
	hEnemyList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	hAllyList = J.GetAlliesNearLoc(bot:GetLocation(), 1600);
	local aether = J.IsItemAvailable("item_aether_lens");
	if aether ~= nil then aetherRange = 250 end	
	if #hEnemyList <= 1 then aetherRange = aetherRange + 200 end
	
	
	castRDesire, sMotive = X.ConsiderR();
	if ( castRDesire > 0 ) 
	then
		J.SetReportMotive(bDebugMode,sMotive);
	
		J.SetQueuePtToINT(bot, true)
	
		bot:ActionQueue_UseAbility( abilityR )
		return;
	
	end
	
	
	castWDesire, castWTarget, sMotive = X.ConsiderW();
	if ( castWDesire > 0 ) 
	then
		J.SetReportMotive(bDebugMode,sMotive);
	
		J.SetQueuePtToINT(bot, false)
	
		bot:ActionQueue_UseAbilityOnEntity( abilityW, castWTarget )
		return;
	end
	
	
	castQDesire, sMotive = X.ConsiderQ();
	if ( castQDesire > 0 ) 
	then
		J.SetReportMotive(bDebugMode, sMotive);		
	
		J.SetQueuePtToINT(bot, true)
	
		bot:ActionQueue_UseAbility( abilityQ )
		return;
	end

end


function X.ConsiderQ()


	if not abilityQ:IsFullyCastable() then return 0 end
	
	local nSkillLV    = abilityQ:GetLevel(); 
	local nCastRange  = 777
	local nCastPoint  = abilityQ:GetCastPoint()
	local nManaCost   = abilityQ:GetManaCost()
	local nDamage     = abilityQ:GetAbilityDamage()
	local nDamageMin  = abilityQ:GetSpecialValueInt('damage_min')
	local nDamageMax  = abilityQ:GetSpecialValueInt('damage_max')
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
	
	--团战和击杀
	for _,npcEnemy in pairs(nInRangeEnemyList)
	do
		if J.IsValidHero(npcEnemy)
		   and J.CanCastOnMagicImmune(npcEnemy)
		then
		
			--击杀
			local nDist = GetUnitToUnitDistance(bot,npcEnemy)
			local nDamage = RemapValClamped(nDist, 0, nCastRange, nDamageMin, nDamageMax) *2;
			if J.WillMagicKillTarget(bot,npcEnemy,nDamage,nCastPoint + nDist /636)
			then
				return BOT_ACTION_DESIRE_HIGH,'Q击杀'..J.Chat.GetNormName(npcEnemy);
			end
			
			--打断大药
			if npcEnemy:HasModifier("modifier_flask_healing") 
			   and J.GetModifierTime(npcEnemy,'modifier_flask_healing') > 3.0
			then
				return BOT_ACTION_DESIRE_HIGH,'Q断药'..J.Chat.GetNormName(npcEnemy);
			end
			
			--撤退
			if J.IsRetreating(bot)
			   and ( bot:WasRecentlyDamagedByHero(npcEnemy,2.0) or bot:GetActiveModeDesire() > BOT_MODE_DESIRE_VERYHIGH )
			then
				return BOT_ACTION_DESIRE_HIGH,'Q撤退'..J.Chat.GetNormName(npcEnemy);
			end
			
			--打架
			if J.IsGoingOnSomeone(bot)
			   and J.IsValidHero(botTarget)
			   and J.IsInRange(bot,botTarget,nCastRange)
			then
				return BOT_ACTION_DESIRE_HIGH,'Q打架'..J.Chat.GetNormName(botTarget);
			end
						
		end
	end
	
	--推线
	if ( J.IsPushing(bot) or J.IsDefending(bot) or J.IsFarming(bot) ) 
	   and #hAllyList < 3 and nLV > 7
	   and J.IsAllowedToSpam(bot, nManaCost)
	then
		local nCanKillCount = 0;
		local nCanHurtCount = 0;
		local hLaneCreepList = bot:GetNearbyLaneCreeps(nCastRange +100,true);
		for _,creep in pairs(hLaneCreepList)
		do
			if J.IsValid(creep)
				and not creep:HasModifier("modifier_fountain_glyph")
			then
				nCanHurtCount = nCanHurtCount +1;
				local nDist = GetUnitToUnitDistance(bot,creep)
				local nDamage = RemapValClamped(nDist, 0, nCastRange, nDamageMin, nDamageMax) *2;
				if J.WillKillTarget(creep,nDamage,nDamageType,nDist/636)
				then
					nCanKillCount = nCanKillCount +1;
				end				
			end
		end
		
		if nCanKillCount >= 3 or nCanHurtCount >= 5
		then
			return BOT_ACTION_DESIRE_HIGH, 'Q推进'..nCanHurtCount;
		end
	end
	
	--打钱
	if J.IsFarming(bot) and nLV > 7 and bot:GetMana() > nKeepMana
	then
		local nCreepList = bot:GetNearbyNeutralCreeps(nCastRange +200);
		local nNearCreepList = bot:GetNearbyNeutralCreeps(400);
		if (#nCreepList >= 3 and #nNearCreepList <= 2)
		    or #nCreepList >= 5
		then
			return BOT_ACTION_DESIRE_HIGH, 'Q打野'..(#nCreepList);
		end
	
	end
	
	--对线
	if J.IsLaning(bot)
	then
		local nCanKillMeleeCount = 0;
		local nCanKillRangedCount = 0;
		local hLaneCreepList = bot:GetNearbyLaneCreeps(nCastRange +100,true);
		for _,creep in pairs(hLaneCreepList)
		do
			if J.IsValid(creep)
				and not creep:HasModifier("modifier_fountain_glyph")
			then
				local nDist = GetUnitToUnitDistance(bot,creep)
				local nDamage = RemapValClamped(nDist, 0, nCastRange, nDamageMin, nDamageMax) *2;
				if J.WillKillTarget(creep,nDamage,nDamageType,nDist*0.9/636)
				then
					if J.IsKeyWordUnit('ranged',creep)
					then
						nCanKillRangedCount = nCanKillRangedCount +1;
						if not J.IsInRange(bot,creep,bot:GetAttackRange() +50)
						then
							return BOT_ACTION_DESIRE_HIGH, 'Q对线1';
						end
					end
					
					if J.IsKeyWordUnit('melee',creep)
					then
						nCanKillMeleeCount = nCanKillMeleeCount +1;
					end
					
				end				
			end
		end
		
		if nCanKillMeleeCount + nCanKillRangedCount >= 3
		then
			return BOT_ACTION_DESIRE_HIGH, 'Q对线2';
		end
		
		if nCanKillRangedCount >= 1 and nCanKillMeleeCount >= 1
		then
			return BOT_ACTION_DESIRE_HIGH, 'Q对线3';
		end
	
	
	end
	
	--通用
	if (#hEnemyList > 0 or bot:WasRecentlyDamagedByAnyHero(3.0)) 
		and ( bot:GetActiveMode() ~= BOT_MODE_RETREAT or #hAllyList >= 2 )
		and #nInRangeEnemyList >= 1
		and nLV >= 15
	then
		for _,npcEnemy in pairs( nInRangeEnemyList )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 			
			then
				return BOT_ACTION_DESIRE_HIGH,'Q通用'..J.Chat.GetNormName(npcEnemy)
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
	
	
end


function X.ConsiderW()


	if not abilityW:IsFullyCastable() then return 0 end
	
	local nSkillLV    = abilityW:GetLevel()
	local nCastRange  = abilityW:GetCastRange()	+ aetherRange
	local nCastPoint  = abilityW:GetCastPoint()
	local nManaCost   = abilityW:GetManaCost()
	local nDamage     = abilityW:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
	
	
	local nInRangeEnemyCount = 0;
	local nCastTarget = nil
	local nAttackDamageMax = 0
	for _,npcEnemy in pairs(nInRangeEnemyList)
	do
		if J.IsValidHero(npcEnemy)
		   and J.CanCastOnMagicImmune(npcEnemy)
		   and J.CanCastOnTargetAdvanced(npcEnemy)
		then
			nInRangeEnemyCount = nInRangeEnemyCount +1;
			if npcEnemy:GetAttackDamage() > nAttackDamageMax
			then
				nCastTarget = npcEnemy;
				nAttackDamageMax = npcEnemy:GetAttackDamage();
			end			
		end
	end	
	if nInRangeEnemyCount >= 2 
	   and nCastTarget ~= nil
	then
		return BOT_ACTION_DESIRE_HIGH,nCastTarget,'W择优'..J.Chat.GetNormName(nCastTarget)
	end
	
	
	if J.IsLaning(bot)
	then
		nCastTarget = nInRangeEnemyList[1];
		if J.IsValidHero(nCastTarget)
		   and J.CanCastOnNonMagicImmune(nCastTarget)
		   and J.CanCastOnTargetAdvanced(nCastTarget)
		   and J.IsInRange(bot,nCastTarget,nCastRange *0.93)
		then
			bot:SetTarget(nCastTarget);
			return BOT_ACTION_DESIRE_HIGH,nCastTarget,'W对线'..J.Chat.GetNormName(nCastTarget)
		end
	end
	
	
	if J.IsGoingOnSomeone(bot)
	   and J.IsValidHero(botTarget)
	   and J.CanCastOnNonMagicImmune(botTarget)
	   and J.CanCastOnTargetAdvanced(botTarget)
	   and J.IsInRange(bot,botTarget,nCastRange)
	   and J.GetAllyCount(bot,1200) - J.GetEnemyCount(bot,1600) < 3
	then	
		return BOT_ACTION_DESIRE_HIGH,botTarget,'W进攻'..J.Chat.GetNormName(botTarget)
	end
	
	
	if J.IsRetreating(bot)
	then
		for _,npcEnemy in pairs(nInRangeEnemyList)
		do
			if J.IsValidHero(npcEnemy)
			   and J.CanCastOnMagicImmune(npcEnemy)
			   and J.CanCastOnTargetAdvanced(npcEnemy)
			   and ( bot:WasRecentlyDamagedByHero(npcEnemy,3.0) or bot:GetActiveModeDesire() > BOT_MODE_DESIRE_VERYHIGH )
			then
				return BOT_ACTION_DESIRE_HIGH,npcEnemy,"W撤退"..J.Chat.GetNormName(npcEnemy)
			end
		end
	end
	
	--通用
	if (#hEnemyList > 0 or bot:WasRecentlyDamagedByAnyHero(3.0)) 
		and ( bot:GetActiveMode() ~= BOT_MODE_RETREAT or #hAllyList >= 2 )
		and #nInRangeEnemyList >= 1
		and nLV >= 15
	then
		for _,npcEnemy in pairs( nInRangeEnemyList )
		do
			if  J.IsValid(npcEnemy)
				and J.IsInRange(bot,npcEnemy,nCastRange - 100)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and J.CanCastOnTargetAdvanced(npcEnemy)				
			then
				return BOT_ACTION_DESIRE_HIGH,npcEnemy,'W通用'..J.Chat.GetNormName(npcEnemy)
			end
		end
	end
	
	
	return BOT_ACTION_DESIRE_NONE;
	
	
end


function X.ConsiderR()


	if not abilityR:IsFullyCastable()
		or bot:HasModifier('modifier_razor_eye_of_the_storm')
	then return 0 end
	
	local nSkillLV    = abilityR:GetLevel(); 
	local nCastRange  = 500
	local nCastPoint  = abilityR:GetCastPoint();
	local nManaCost   = abilityR:GetManaCost();
	local nDamage     = abilityR:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_PHYSICAL
	local nInRangeEnemyList = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
	local nDamageCount = 0;
	
	for _,npcEnemy in pairs(nInRangeEnemyList)
	do
		if J.IsValidHero(npcEnemy)
		   and J.CanCastOnMagicImmune(npcEnemy)
		then
			nDamageCount = nDamageCount +1;
		end
	end
	
	
	if nDamageCount >= 2 
	then
	    return BOT_ACTION_DESIRE_HIGH,"R两人"
	end	
	
	
	if J.IsGoingOnSomeone(bot)
	   and J.IsValidHero(botTarget)
	   and J.IsInRange(bot,botTarget,nCastRange)
	   and J.CanCastOnMagicImmune(botTarget)
	   and ( J.GetProperTarget(botTarget) ~= nil or J.IsInRange(bot,botTarget,nCastRange *0.6) )
	   and J.GetAllyCount(bot,1600) - J.GetEnemyCount(bot,1600) < 2
	then
		return BOT_ACTION_DESIRE_HIGH,"R进攻"..J.Chat.GetNormName(botTarget)
	end
	
	
	if J.IsRetreating(bot)
	then
		for _,npcEnemy in pairs(nInRangeEnemyList)
		do
			if J.IsValidHero(npcEnemy)
			   and J.CanCastOnMagicImmune(npcEnemy)
			   and ( bot:WasRecentlyDamagedByHero(npcEnemy,2.0) or bot:GetActiveModeDesire() > BOT_MODE_DESIRE_VERYHIGH )
			then
				return BOT_ACTION_DESIRE_HIGH,"R撤退"..J.Chat.GetNormName(npcEnemy)
			end
		end
	end
	
	
	return BOT_ACTION_DESIRE_NONE;
	
	
end


return X
-- dota2jmz@163.com QQ:2462331592

