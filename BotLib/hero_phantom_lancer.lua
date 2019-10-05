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
			['t25'] = {0, 10},
			['t20'] = {10, 0},
			['t15'] = {0, 10},
			['t10'] = {0, 10},
		},
		--技能
		['Ability'] = {1,3,2,3,3,6,3,1,1,1,6,2,2,2,6},
		--装备
		['Buy'] = {
			sOutfit,
			"item_diffusal_blade",
			"item_manta",
			"item_skadi",
			'item_sphere',
			"item_heart",
		},
		--出售
		['Sell'] = {
			"item_magic_wand",
			"item_stout_shield",
			
			"item_manta",
			"item_quelling_blade",
			
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
			['t10'] = {10, 0},
		},
		--技能
		['Ability'] = { 1, 3, 2, 3, 3, 6, 3, 2, 2, 2, 6, 1, 1, 1, 6 },
		--装备
		['Buy'] = {
			"item_faerie_fire",
			"item_slippers",
			"item_stout_shield",
			"item_tango",
			"item_flask",
			"item_magic_stick",
			"item_wraith_band",
			"item_power_treads",
			"item_diffusal_blade",
			"item_manta",
			"item_heart", 
			"item_skadi", 
			"item_butterfly",
			"item_ultimate_scepter_2",
			"item_moon_shard",
			"item_travel_boots_2"
		},
		--出售
		['Sell'] = {
			"item_manta",
			"item_faerie_fire",

			"item_heart", 
			"item_stout_shield",

			"item_skadi",     
			"item_magic_stick",

			"item_butterfly",
			"item_wraith_band" 
		},
	},{
		--组合说明，不影响游戏
		['info'] = 'By 铅笔会有猫的w',
		--天赋树
		['Talent'] = {
			['t25'] = {0, 10},
			['t20'] = {10, 0},
			['t15'] = {0, 10},
			['t10'] = {0, 10},
		},
		--技能
		['Ability'] = { 3, 1, 2, 1, 1, 6, 1, 3, 3, 3, 6, 2, 2, 2, 6 },
		--装备
		['Buy'] = {
			"item_tango",
			"item_flask",
			"item_stout_shield",
			"item_quelling_blade",
			"item_boots",
			"item_magic_wand",
			"item_wraith_band",
			"item_power_treads",
			"item_diffusal_blade",
			"item_manta",	
			"item_skadi",
			"item_satanic", 			
			"item_bloodthorn",
			"item_travel_boots", 
			"item_moon_shard",
			"item_travel_boots_2", 
			"item_ultimate_scepter",
			"item_ultimate_scepter_2",
		},
		--出售
		['Sell'] = {
			"item_travel_boots",
			"item_power_treads",

			"item_satanic",
			"item_wraith_band",

			"item_bloodthorn",
			"item_magic_wand",

			"item_skadi",
			"item_stout_shield",
				
			"item_manta",
			"item_quelling_blade",
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
	['Ability'] = {1,3,2,3,3,6,3,1,1,1,6,2,2,2,6},
	--装备
	['Buy'] = {
		sOutfit,
		"item_diffusal_blade",
		"item_manta",
		"item_skadi",
		'item_sphere',
		"item_heart",
	},
	--出售
	['Sell'] = {
		"item_magic_wand",
		"item_stout_shield",
		
		"item_manta",
		"item_quelling_blade",
		
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
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit(hMinionUnit) 
	then
		if hMinionUnit:HasModifier('modifier_phantom_lancer_phantom_edge_boost') then return end
		
		Minion.IllusionThink(hMinionUnit)	
	end

end

--[[

npc_dota_hero_phantom_lancer

phantom_lancer_spirit_lance
phantom_lancer_doppelwalk
phantom_lancer_phantom_edge
phantom_lancer_juxtapose
special_bonus_unique_phantom_lancer_2
special_bonus_attack_speed_20
special_bonus_all_stats_8
special_bonus_cooldown_reduction_15
special_bonus_magic_resistance_15
special_bonus_evasion_15
special_bonus_strength_20
special_bonus_unique_phantom_lancer

modifier_phantom_lancer_spirit_lance
modifier_phantomlancer_dopplewalk_phase
modifier_phantom_lancer_doppelwalk_illusion
modifier_phantom_lancer_juxtapose
modifier_phantom_lancer_phantom_edge
modifier_phantom_lancer_phantom_edge_boost
modifier_phantom_lancer_phantom_edge_agility
modifier_phantom_lancer_juxtapose_illusion

--]]


local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local talent4 = bot:GetAbilityByName( sTalentList[4] )
local talent5 = bot:GetAbilityByName( sTalentList[5] )


local castQDesire, castQTarget
local castWDesire, castWLocation


local nKeepMana,nMP,nHP,nLV,hEnemyList,hAllyList,botTarget,sMotive;
local talent4Damage = 0
local aetherRange = 0

local boostRange = 0


function X.SkillsComplement()
	
	
	if J.CanNotUseAbility(bot) 
	   or bot:IsInvisible()
	   or bot:HasModifier('modifier_phantom_lancer_phantom_edge_boost')
	then return end
	
	
	nKeepMana = 400
	talent4Damage = 0
	aetherRange = 0
	nLV = bot:GetLevel();
	nMP = bot:GetMana()/bot:GetMaxMana();
	nHP = bot:GetHealth()/bot:GetMaxHealth();
	botTarget = J.GetProperTarget(bot);
	hEnemyList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	hAllyList = J.GetAlliesNearLoc(bot:GetLocation(), 1600);
	
	
	if abilityE:IsTrained() then boostRange = abilityE:GetSpecialValueInt("max_distance") end
	if talent4:IsTrained() then talent4Damage = talent4:GetSpecialValueInt("value") end
	if talent5:IsTrained() then boostRange = boostRange + talent5:GetSpecialValueInt("value") end
	local aether = J.IsItemAvailable("item_aether_lens");
	if aether ~= nil then aetherRange = 250 end	
	
	
	castQDesire, castQTarget, sMotive = X.ConsiderQ();
	if ( castQDesire > 0 ) 
	then
		J.SetReportMotive(bDebugMode,sMotive);		
	
		J.SetQueuePtToINT(bot, true);
	
		bot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget )
		return;
	end
	
	castWDesire, castWLocation, sMotive = X.ConsiderW();
	if ( castWDesire > 0 ) 
	then
		J.SetReportMotive(bDebugMode,sMotive);
	
		J.SetQueuePtToINT(bot, false)
	
		bot:ActionQueue_UseAbilityOnLocation( abilityW, castWLocation )
		return;
	end

end


function X.ConsiderQ()


	if not abilityQ:IsFullyCastable() then return 0 end
	
	local nSkillLV    = abilityQ:GetLevel(); 
	local nCastRange  = abilityQ:GetCastRange() + aetherRange
	
	if #hEnemyList <= 1 then nCastRange = nCastRange + 200 end
	
	local nCastPoint  = abilityQ:GetCastPoint()
	local nManaCost   = abilityQ:GetManaCost()
	local nDamage     = abilityQ:GetSpecialValueInt('lance_damage') + talent4Damage
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = bot:GetNearbyHeroes(nCastRange +50, true, BOT_MODE_NONE);
	
	
	local nAttackDamage = bot:GetAttackDamage();
	
	--击杀
	if ( not J.IsValidHero(botTarget) or J.GetHPR(botTarget) > 0.2 )
	then
		for _,npcEnemy in pairs(nInRangeEnemyList)
		do
			if J.IsValidHero(npcEnemy)
				and J.CanCastOnNonMagicImmune(npcEnemy)
				and J.CanCastOnTargetAdvanced(npcEnemy)
				and J.WillMagicKillTarget(bot, npcEnemy, nDamage, nCastPoint)
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy, "Q击杀"..J.Chat.GetNormName(npcEnemy)
			end
		end
	end
	
	
	--对线
	if bot:GetActiveMode() == BOT_MODE_LANING 
	   and #hAllyList <= 2
	then
		local hLaneCreepList = bot:GetNearbyLaneCreeps(nCastRange +90,true);
		for _,creep in pairs(hLaneCreepList)
		do
			if J.IsValid(creep)
				and not creep:HasModifier("modifier_fountain_glyph")
		        and J.IsKeyWordUnit( "ranged", creep )
				and not J.IsAllysTarget(creep)
				and not J.IsInRange(bot,creep,350)
			then
				local nDelay = nCastPoint + GetUnitToUnitDistance(bot,creep)/1000;
				if J.WillKillTarget(creep, nDamage, nDamageType, nDelay *0.9)
				then
					return BOT_ACTION_DESIRE_HIGH, creep, 'Q对线'
				end
			end
		end
	end
	
	--撤退
	if J.IsRetreating(bot) 
	   and ( bot:WasRecentlyDamagedByAnyHero(2.0) or bot:GetActiveModeDesire() > BOT_MODE_DESIRE_VERYHIGH )
	then
		for _,npcEnemy in pairs(nInRangeEnemyList)
		do
			if J.IsValidHero(npcEnemy)
				and J.CanCastOnNonMagicImmune(npcEnemy)
				and J.CanCastOnTargetAdvanced(npcEnemy)
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy, "Q撤退"..npcEnemy:GetUnitName()
			end
		end
	end
	
	
	--打钱
	if J.IsFarming(bot) and nLV > 5
		and J.IsAllowedToSpam(bot, 30)
	then
		if J.IsValid(botTarget)
		   and J.IsInRange(bot,botTarget,nCastRange)
		   and botTarget:GetTeam() == TEAM_NEUTRAL
		   and (botTarget:GetMagicResist() < 0.3 or nMP > 0.9)
		   and not J.CanKillTarget(botTarget, nAttackDamage *1.38, DAMAGE_TYPE_PHYSICAL)
		   and not J.CanKillTarget(botTarget, nDamage -10,nDamageType)
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget, 'Q打野'
		end
	end
	
	--打架
	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidHero(botTarget) 
		   and J.CanCastOnNonMagicImmune(botTarget) 
		   and J.CanCastOnTargetAdvanced(botTarget)
		   and J.IsInRange(botTarget, bot, nCastRange +50)
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget, 'Q进攻'..J.Chat.GetNormName(botTarget)
		end
		
		--团战
		if J.IsInTeamFight(bot,900) and nLV > 5
		then	
			for _,npcEnemy in pairs(nInRangeEnemyList)
			do
				if J.IsValidHero(npcEnemy)
				   and J.CanCastOnNonMagicImmune(npcEnemy)
				   and J.CanCastOnTargetAdvanced(npcEnemy)
				then
					return BOT_ACTION_DESIRE_HIGH, npcEnemy, 'Q团战'..J.Chat.GetNormName(npcEnemy)
				end
			end
		end
	end
	
	
	--推线
	if ( J.IsPushing(bot) or J.IsDefending(bot) or J.IsFarming(bot) ) 
	   and #hAllyList < 3 and nLV > 7
	   and J.IsAllowedToSpam(bot, 30)
	then
		local hLaneCreepList = bot:GetNearbyLaneCreeps(nCastRange +150,true);
		for _,creep in pairs(hLaneCreepList)
		do
			if J.IsValid(creep)
				and not creep:HasModifier("modifier_fountain_glyph")
		        and ( J.IsKeyWordUnit( "ranged", creep ) 
					   or ( nMP > 0.5 and J.IsKeyWordUnit( "melee", creep )) )
				and not J.IsAllysTarget(creep)
				and creep:GetHealth() > nDamage * 0.68
			then
			
				local nDelay = nCastPoint + GetUnitToUnitDistance(bot,creep)/1000;
				if J.WillKillTarget(creep, nDamage, nDamageType, nDelay *0.8)
				   and not J.WillKillTarget(creep, nAttackDamage, DAMAGE_TYPE_PHYSICAL, nDelay )
				then
					return BOT_ACTION_DESIRE_HIGH, creep, 'Q推线1'
				end
				
				local hAllyCreepList = bot:GetNearbyLaneCreeps(1200,false);
				if #hAllyCreepList == 0
				then
					return BOT_ACTION_DESIRE_HIGH, creep, 'Q推线2'
				end				
				
			end
		end
	end
	
	
	--肉山
	if  bot:GetActiveMode() == BOT_MODE_ROSHAN 
		and nLV > 15 and nMP > 0.4
	then
		if J.IsRoshan(botTarget) 
		    and J.GetHPR(botTarget) > 0.2
			and J.IsInRange(botTarget, bot, nCastRange)  
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget, 'Q肉山'
		end
	end
	
	--通用

	
	return BOT_ACTION_DESIRE_NONE;
	
	
end


function X.ConsiderW()


	if not abilityW:IsFullyCastable() or bot:DistanceFromFountain() < 600 then return 0 end
	
	local nSkillLV    = abilityW:GetLevel()
	local nCastRange  = abilityW:GetCastRange() + aetherRange
	local nCastPoint  = abilityW:GetCastPoint()
	local nManaCost   = abilityW:GetManaCost()
	local nInRangeEnemyList = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
	
	local vEscapeLoc = J.GetLocationTowardDistanceLocation(bot, J.GetTeamFountain(), nCastRange)

	
	--躲避
	if J.IsNotAttackProjectileIncoming(bot, 460)
	   or ( J.IsWithoutTarget(bot) and J.GetAttackProjectileDamageByRange(bot, 1600) >= bot:GetHealth() )
	then
		return BOT_ACTION_DESIRE_HIGH, vEscapeLoc, 'W躲避'
	end
	
	--撤退
	if J.IsRetreating(bot)
		and ( bot:WasRecentlyDamagedByAnyHero(2.0) or bot:GetActiveModeDesire() > BOT_MODE_DESIRE_VERYHIGH )
	then
		return BOT_ACTION_DESIRE_HIGH, vEscapeLoc, 'W撤退'
	end
	
	--打架
	if J.IsGoingOnSomeone(bot)
	   and not bot:HasModifier('modifier_phantom_lancer_phantom_edge_agility')
	then
		if J.IsValidHero(botTarget)
		   and J.CanCastOnMagicImmune(botTarget)
		   and ( nSkillLV >= 3 or nMP > 0.6 or nHP < 0.4 or J.GetHPR(botTarget) < 0.4 or DotaTime() > 9 *60 )
		then
			
			--迷惑目标
			local vBestCastLoc = nil
			local nDistMin = 9999
			local vTargetLoc = J.GetCorrectLoc(botTarget,1.0);
			for i=30,nCastRange,30
			do
				local vFirstLoc = J.GetFaceTowardDistanceLocation(bot, i);
				local nDistance = J.GetLocationToLocationDistance(vTargetLoc,vFirstLoc);
				if nDistance > 300 
				   and ( nDistance < boostRange -300 or nDistance < 500 )
				   and nDistance < nDistMin
				then
					nDistMin = nDistance;
					vBestCastLoc = vFirstLoc;
				end				   
			end
			if vBestCastLoc ~= nil
			then
				return BOT_ACTION_DESIRE_HIGH, vBestCastLoc, 'W迷惑'..J.Chat.GetNormName(botTarget)
			end
			
			--追击目标
			local vSecondLoc = J.GetUnitTowardDistanceLocation(bot, botTarget, nCastRange);	
			if nSkillLV >= 4
			   and not J.IsInRange(bot,botTarget,boostRange +400)
			   and J.IsInRange(bot,botTarget,boostRange +1000)
			   and bot:IsFacingLocation(botTarget:GetLocation(),30)
			   and botTarget:IsFacingLocation(J.GetEnemyFountain(),30)
			then
				return BOT_ACTION_DESIRE_HIGH, vSecondLoc, 'W追击'..J.Chat.GetNormName(botTarget)
			end
			
		end
	end
	
	--打钱和推线
	if ( J.IsPushing(bot) or J.IsDefending(bot) or J.IsFarming(bot) ) 
	   and #hAllyList < 2 and nLV > 7
	   and J.IsAllowedToSpam(bot, 100)
	then	
		if J.IsValid(botTarget)
		   and not J.IsInRange(bot,botTarget,boostRange +400)
		   and J.IsInRange(bot,botTarget,boostRange +1200)
		then
		    return BOT_ACTION_DESIRE_HIGH, J.GetUnitTowardDistanceLocation(bot, botTarget, nCastRange), 'W打钱'
		end
	end
	
	--通用
	
	return BOT_ACTION_DESIRE_NONE;
	
	
end


return X
-- dota2jmz@163.com QQ:2462331592






