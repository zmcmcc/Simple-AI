----------------------------------------------------------------------------------------------------
--- The Creation Come From: BOT EXPERIMENT Credit:FURIOUSPUPPY
--- BOT EXPERIMENT Author: Arizona Fauzie 2018.11.21
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=837040016
--- Update by: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
----------------------------------------------------------------------------------------------------
local X = {}
local bDebugMode = false;
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local ConversionMode = dofile( GetScriptDirectory()..'/AuxiliaryScript/BotlibConversion') --引入技能文件
local Minion = dofile( GetScriptDirectory()..'/FunLib/Minion')
local sTalentList = J.Skill.GetTalentList(bot)
local sAbilityList = J.Skill.GetAbilityList(bot)
local sOutfit = J.Skill.GetOutfitName(bot)

--编组技能、天赋、装备
local tGroupedDataList = {
}
--默认数据
local tDefaultGroupedData = {
	--天赋树
	['Talent'] = {
		['t25'] = {0, 10},
		['t20'] = {10, 0},
		['t15'] = {10, 0},
		['t10'] = {0, 10},
	},
	--技能
	['Ability'] = {1,2,1,2,1,6,1,3,2,2,6,3,3,3,6},
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
		"item_shivas_guard",
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

X['bDeafaultAbility'] = true
X['bDeafaultItem'] = true

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit(hMinionUnit) 
	then
		Minion.IllusionThink(hMinionUnit)	
	end

end


--[[

"npc_dota_hero_lich"

"Ability1"		"lich_frost_nova"
"Ability2"		"lich_frost_shield"
"Ability3"		"lich_sinister_gaze"
"Ability4"		"generic_hidden"
"Ability5"		"generic_hidden"
"Ability6"		"lich_chain_frost"
"Ability10"		"special_bonus_hp_200"
"Ability11"		"special_bonus_movement_speed_20"
"Ability12"		"special_bonus_attack_damage_120"
"Ability13"		"special_bonus_unique_lich_3"
"Ability14"		"special_bonus_cast_range_150"
"Ability15"		"special_bonus_unique_lich_4"
"Ability16"		"special_bonus_unique_lich_1"
"Ability17"		"special_bonus_unique_lich_2"


modifier_lich_attack_slow
modifier_lich_attack_slow_debuff
modifier_lich_frostnova_slow
modifier_lich_sinister_gaze
modifier_lich_dark_sorcery_buff
modifier_lich_frost_aura_aura
modifier_lich_frost_aura
modifier_lich_frost_aura_slow
modifier_lich_chainfrost_slow
modifier_lich_frost_armor_autocast
modifier_lich_frost_armor
modifier_lich_frostarmor_slow
modifier_lich_frost_shield
modifier_lich_frost_shield_slow
modifier_lich_chain_frost_thinker

--]]


local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )
local talent5 = bot:GetAbilityByName( sTalentList[5] )
local talent7 = bot:GetAbilityByName( sTalentList[7] )

local castQDesire, castQTarget
local castWDesire, castWTarget
local castEDesire, castETarget
local castRDesire, castRTarget


local nKeepMana,nMP,nHP,nLV,hEnemyList,hAllyList,botTarget,sMotive;
local aetherRange = 0

local talentDamage = 0

function X.SkillsComplement()

	
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
	
	
	nKeepMana = 400
	aetherRange = 0
	talentDamage = 0
	nLV = bot:GetLevel();
	nMP = bot:GetMana()/bot:GetMaxMana();
	nHP = bot:GetHealth()/bot:GetMaxHealth();
	botTarget = J.GetProperTarget(bot);
	hEnemyList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	hAllyList = J.GetAlliesNearLoc(bot:GetLocation(), 1200);
	
	
	local aether = J.IsItemAvailable("item_aether_lens");
	if aether ~= nil then aetherRange = 250 end	
	if talent5:IsTrained() then aetherRange = aetherRange + talent5:GetSpecialValueInt("value") end
	
	
	castRDesire, castRTarget, sMotive = X.ConsiderR();
	if ( castRDesire > 0 ) 
	then
		J.SetReportMotive(bDebugMode,sMotive);
	
		J.SetQueuePtToINT(bot, true)
	
		bot:ActionQueue_UseAbilityOnEntity( abilityR, castRTarget )
		return;
	
	end
	
	castQDesire, castQTarget, sMotive = X.ConsiderQ();
	if ( castQDesire > 0 ) 
	then
		J.SetReportMotive(bDebugMode,sMotive);		
	
		J.SetQueuePtToINT(bot, true)
	
		bot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget )
		return;
	end
	
	castWDesire, castWTarget, sMotive = X.ConsiderW();
	if ( castWDesire > 0 ) 
	then
		J.SetReportMotive(bDebugMode,sMotive);
	
		J.SetQueuePtToINT(bot, true)
	
		bot:ActionQueue_UseAbilityOnEntity( abilityW, castWTarget )
		return;
	end
	
	castEDesire, castETarget, sMotive = X.ConsiderE();
	if ( castEDesire > 0 ) 
	then
		J.SetReportMotive(bDebugMode,sMotive);
	
		J.SetQueuePtToINT(bot, true)
	
		bot:ActionQueue_UseAbilityOnEntity( abilityE, castETarget )
		return;
	end
	

end


function X.ConsiderQ()


	if not abilityQ:IsFullyCastable() then return 0 end
	
	local nSkillLV    = abilityQ:GetLevel(); 
	local nCastRange  = abilityQ:GetCastRange() + aetherRange
	local nRealRange  = nCastRange
	
	if #hEnemyList <= 2 and nCastRange < 700 then nCastRange = nCastRange + 100 end
	
	local nCastPoint  = abilityQ:GetCastPoint()
	local nManaCost   = abilityQ:GetManaCost()
	local nMainDamage = nSkillLV * 50
	local nAoeDamage  = abilityQ:GetSpecialValueInt("aoe_damage")
	local nDamage     = nMainDamage + nAoeDamage
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nRadius = abilityQ:GetSpecialValueInt("radius")
	
		
	local nInRangeEnemyList = bot:GetNearbyHeroes(nCastRange + 32, true, BOT_MODE_NONE);
	local nInBonusEnemyList = bot:GetNearbyHeroes(nCastRange + 150,true,BOT_MODE_NONE);
	local nEmemysCreepsInRange = bot:GetNearbyCreeps(nCastRange + 43,true);
	
	
	--击杀 
	for _,npcEnemy in pairs( nInBonusEnemyList )
	do
		if J.IsValid(npcEnemy)
		   and J.CanCastOnNonMagicImmune(npcEnemy)
		   and J.CanCastOnTargetAdvanced(npcEnemy)
		   and J.WillMagicKillTarget(bot,npcEnemy,nDamage,nCastPoint)
		then
			if J.WillMagicKillTarget(bot,npcEnemy,nAoeDamage,nCastPoint)
			then
				local nBetterTarget = nil;
				local nAllEnemyUnits = J.CombineTwoTable(nInRangeEnemyList,nEmemysCreepsInRange);
				for _,enemy in pairs(nAllEnemyUnits)
				do
					if J.IsValid(enemy)
						and J.IsInRange(npcEnemy,enemy,nRadius)
						and J.CanCastOnNonMagicImmune(enemy)
						and J.CanCastOnTargetAdvanced(enemy)
					then
						nBetterTarget = enemy;
						break;
					end
				end
				
				if nBetterTarget ~= nil
				then
					return BOT_ACTION_DESIRE_HIGH,nBetterTarget,"Q-KillBetter:"..J.Chat.GetNormName(nBetterTarget);
				end				
			end
			
			return BOT_ACTION_DESIRE_HIGH,npcEnemy,"Q-Kill:"..J.Chat.GetNormName(npcEnemy);
		end
	end
	
	--团战
	if J.IsInTeamFight(bot, 1200)
	then
		local npcMostAoeEnemy = nil;
		local nMostAoeECount  = 1;		
		local nAllEnemyUnits = J.CombineTwoTable(nInRangeEnemyList,nEmemysCreepsInRange);
		
		local nWeakestEnemy = nil;
		local nWeakestEnemyHealth = 9999;		
		
		for _,npcEnemy in pairs( nAllEnemyUnits )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and J.CanCastOnTargetAdvanced(npcEnemy)
			then
				
				local nEnemyHeroCount = J.GetAroundTargetEnemyHeroCount(npcEnemy, nRadius);
				if ( nEnemyHeroCount > nMostAoeECount )
				then
					nMostAoeECount = nEnemyHeroCount;
					npcMostAoeEnemy = npcEnemy;
				end
				
				if npcEnemy:IsHero()
				then
					local npcEnemyHealth = npcEnemy:GetHealth();
					if ( npcEnemyHealth < nWeakestEnemyHealth )
					then
						nWeakestEnemyHealth = npcEnemyHealth;
						nWeakestEnemy = npcEnemy;
					end
				end
			end
		end
		
		if ( npcMostAoeEnemy ~= nil )
		then
			return BOT_ACTION_DESIRE_HIGH, npcMostAoeEnemy,"Q-Battle-Most:"..nMostAoeECount;
		end	

		if ( nWeakestEnemy ~= nil )
		then
			return BOT_ACTION_DESIRE_HIGH, nWeakestEnemy,"Q-Battle-Weakest:"..J.Chat.GetNormName(nWeakestEnemy);
		end	
	end
	
	--对线
	if J.IsLaning(bot)
	then
	
		if nMP > 0.5
		then	
			for _,npcEnemy in pairs( nInRangeEnemyList )
			do
				if  J.IsValid(npcEnemy)
					and J.CanCastOnNonMagicImmune(npcEnemy) 
					and J.CanCastOnTargetAdvanced(npcEnemy)
					and J.GetAttackTargetEnemyCreepCount(npcEnemy, 1400) >= 3
				then
					return BOT_ACTION_DESIRE_HIGH, npcEnemy,"Q-Laning:"..J.Chat.GetNormName(npcEnemy);
				end
			end	
		end
		
		local nEnemyCreeps = bot:GetNearbyLaneCreeps(800,true);
		for _,creep in pairs(nEnemyCreeps)
		do 
			if J.IsValid(creep)
				and not creep:HasModifier('modifier_fountain_glyph')
			then
				if J.IsKeyWordUnit('ranged',creep)
					and J.WillKillTarget(creep,nDamage,nDamageType,nCastPoint)
					and not J.IsAllysTarget(creep)
				then
					return BOT_ACTION_DESIRE_HIGH, creep, "Q-LaneRanged";
				end
				
				if  #hAllyList <= 1 and bot:GetMana() > 320
					and J.IsKeyWordUnit('melee',creep)
					and J.WillKillTarget(creep,nDamage,nDamageType,nCastPoint)
					and not J.WillKillTarget(creep,nDamage *0.5,nDamageType,nCastPoint)
				then
					return BOT_ACTION_DESIRE_HIGH, creep, "Q-LaneMelee";
				end
			end
		end
		
		
	end
	
	--打架时先手	
	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidHero(botTarget) 
			and J.IsInRange(bot, botTarget, nCastRange +30)
			and J.CanCastOnNonMagicImmune(botTarget) 
			and J.CanCastOnTargetAdvanced(botTarget)
		then
			if nSkillLV >= 2 or nMP > 0.68 or J.GetHPR(botTarget) < 0.48 or nHP < 0.28
			then
				return BOT_ACTION_DESIRE_HIGH, botTarget,"Q-Attack:"..J.Chat.GetNormName(botTarget);
			end
		end
	end
	
	
	--撤退时保护自己
	if J.IsRetreating(bot) 
	then
		for _,npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValidHero(npcEnemy)
				and J.IsInRange(bot,npcEnemy,nRealRange)
			    and ( bot:WasRecentlyDamagedByHero( npcEnemy, 4.0 ) or nMP > 0.68
						or GetUnitToUnitDistance(bot,npcEnemy) <= 400 )
				and J.CanCastOnNonMagicImmune(npcEnemy) 
				and J.CanCastOnTargetAdvanced(npcEnemy)
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy,"Q-Retreat:"..J.Chat.GetNormName(npcEnemy);
			end
		end
	end
	
	--打钱
	if J.IsFarming(bot) and nSkillLV >= 3
	   and J.IsAllowedToSpam(bot,nManaCost)
	   and #hEnemyList == 0
	   and #hAllyList <= 2
	   and not ( J.IsPushing(bot) or J.IsDefending(bot) )
	then
		local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nCastRange + 100);
		if #nNeutralCreeps >= 3
		then
			for _,creep in pairs(nNeutralCreeps)
			do
				if J.IsValid(creep)
					and bot:IsFacingLocation(creep:GetLocation(),30)
					and creep:GetHealth() >= 600
					and creep:GetMagicResist() < 0.3
					and J.GetAroundTargetEnemyUnitCount(creep, nRadius) >= 3
				then
					return BOT_ACTION_DESIRE_HIGH, creep, "Q-Farm:"..(#nNeutralCreeps);
				end			
			end
		end
	end
	
	
	--推进
	if  (J.IsPushing(bot) or J.IsDefending(bot) or J.IsFarming(bot))
	    and J.IsAllowedToSpam(bot,30)
		and nSkillLV >= 3 
		and #hEnemyList == 0
		and #hAllyList <= 2
	then
		local nEnemyCreeps = bot:GetNearbyLaneCreeps(999,true);
		local nAllyCreeps = bot:GetNearbyLaneCreeps(888,false);
		
		for _,creep in pairs(nEnemyCreeps)
		do
			if J.IsValid(creep)
				and not creep:HasModifier("modifier_fountain_glyph")
				and J.IsInRange(creep,bot,nCastRange + 300)
			then
			
				if #nAllyCreeps == 0
					and J.GetAroundTargetEnemyUnitCount(creep, nRadius) >= 4
				then
					return BOT_ACTION_DESIRE_HIGH, creep, "Q-PushAoe";
				end
			
				if J.IsKeyWordUnit('ranged',creep)
					and J.WillKillTarget(creep,nDamage,nDamageType,nCastPoint)
				then
					return BOT_ACTION_DESIRE_HIGH, creep, "Q-PushRanged";
				end
				
				if J.IsKeyWordUnit('melee',creep)
					and J.WillKillTarget(creep,nDamage,nDamageType,nCastPoint)
					and ( J.GetAroundTargetEnemyUnitCount(creep, nRadius) >= 2 or nMP > 0.8 )
				then
					return BOT_ACTION_DESIRE_HIGH, creep, "Q-PushMelee";
				end
				
			end			
		end
		
	end
	
	--打肉的时候输出
	if  bot:GetActiveMode() == BOT_MODE_ROSHAN 
		and bot:GetMana() >= 600
	then
		if J.IsRoshan(botTarget) and J.GetHPR(botTarget) > 0.2
			and J.IsInRange(bot, botTarget, nRealRange)  
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget;
		end
	end
	
	--通用受到伤害时保护自己
	if bot:WasRecentlyDamagedByAnyHero(3.0) 
		and bot:GetActiveMode() ~= BOT_MODE_RETREAT
		and #nInRangeEnemyList >= 1
		and nSkillLV >= 4
	then
		for _,npcEnemy in pairs( nInRangeEnemyList )
		do
			if  J.IsValidHero(npcEnemy)
				and J.IsInRange(bot,npcEnemy,nRealRange)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and J.CanCastOnTargetAdvanced(npcEnemy)		
				and bot:IsFacingLocation(npcEnemy:GetLocation(),45)
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy,"Q-protectSelf:"..J.Chat.GetNormName(npcEnemy)
			end
		end
	end
	
	--通用消耗敌人
	if (#hEnemyList > 0 or bot:WasRecentlyDamagedByAnyHero(3.0)) 
		and ( bot:GetActiveMode() ~= BOT_MODE_RETREAT or #hAllyList >= 2 )
		and #nInRangeEnemyList >= 1
		and nSkillLV >= 4 and bot:GetMana() > nKeepMana
	then
		for _,npcEnemy in pairs( nInRangeEnemyList )
		do
			if  J.IsValidHero(npcEnemy)
				and J.IsInRange(bot,npcEnemy,nRealRange)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and J.CanCastOnTargetAdvanced(npcEnemy)		
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy,"Q-Consume:"..J.Chat.GetNormName(npcEnemy)
			end
		end
	end
	
	
	return BOT_ACTION_DESIRE_NONE;
	
	
end

function X.ConsiderW()


	if not abilityW:IsFullyCastable() then return 0 end
	
	local nSkillLV    = abilityW:GetLevel(); 
	local nCastRange  = abilityW:GetCastRange() + aetherRange
	local nCastPoint  = abilityW:GetCastPoint()
	local nManaCost   = abilityW:GetManaCost()
	local nDamage     = abilityW:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeAllyList = J.GetAlliesNearLoc(bot:GetLocation(),nCastRange +50);
	
	local nRadius = abilityW:GetSpecialValueInt("radius")
	
	--团战保护
	if J.IsInTeamFight(bot,900)
	then
		local nTargetAlly = nil
		local nMostScore = 39
		
		for _,npcAlly in pairs(nInRangeAllyList)
		do 
			local nEnemyHeroList = npcAlly:GetNearbyHeroes(1600,true,BOT_MODE_NONE)
			local nEnemyCreepList = npcAlly:GetNearbyCreeps(1000,true)
			local nAllyScore = 0;		
		
			for _,npcEnemy in pairs(nEnemyHeroList)
			do 
				if npcEnemy:GetAttackTarget() == npcAlly
					or npcEnemy:IsFacingLocation(npcAlly:GetLocation(),12)
				then
					nAllyScore = nAllyScore + 30;
				end
			end
			
			for _,nCreep in pairs(nEnemyCreepList)
			do 
				if nCreep:GetAttackTarget() == npcAlly
				then
					nAllyScore = nAllyScore + 10;
				end
			end
			
			if nAllyScore > nMostScore
			then
				nTargetAlly = npcAlly;
				nMostScore = nAllyScore;
			end
		
		end
		
		if nTargetAlly ~= nil
		then
			return BOT_ACTION_DESIRE_HIGH,nTargetAlly,"W-Battle:"..nMostScore;
		end
	
	end
	
	
	--修塔兵营基地
	if talent7:IsTrained()
	then
		local nTowerList = bot:GetNearbyTowers(nCastRange +50,false);
		for _,target in pairs(nTowerList)
		do 
			if J.IsValidBuilding(target)
				and target:GetMaxHealth() - target:GetHealth() > 600
				and ( #hEnemyList == 0 or hEnemyList[1]:GetAttackTarget() == target )
			then
				return BOT_ACTION_DESIRE_HIGH,target,"W-Tower";
			end
		end
		
		local nBarrackList = bot:GetNearbyBarracks(nCastRange +50,false);
		for _,target in pairs(nBarrackList)
		do 
			if J.IsValidBuilding(target)
				and target:GetMaxHealth() - target:GetHealth() > 800
				and ( #hEnemyList == 0 or hEnemyList[1]:GetAttackTarget() == target )
			then
				return BOT_ACTION_DESIRE_HIGH,target,"W-Barrack";
			end
		end
		
		local nAncient = GetAncient(GetTeam());
		if J.IsInRange(bot,nAncient,nCastRange)
			and nAncient:GetMaxHealth() - nAncient:GetHealth() > 1000
		then
			return BOT_ACTION_DESIRE_HIGH,nAncient,"W-Ancient";
		end
	end
	
	
	--肉山
	if J.IsDoingRoshan(bot)
	then
		if J.IsRoshan(botTarget)
			and botTarget:GetAttackTarget() ~= nil
		then
			local nRoshanTarget = botTarget:GetAttackTarget();
			for _,npcAlly in pairs(nInRangeAllyList)
			do 
				if nRoshanTarget == npcAlly
				then
					return BOT_ACTION_DESIRE_HIGH,npcAlly,"W-Roshan";
				end
			end
		end
	end
	
	
	--对每个友军
	for _,npcAlly in pairs(nInRangeAllyList)
	do	
		--Aoe
		local nEnemyHeroList = npcAlly:GetNearbyHeroes(nRadius -20,true,BOT_MODE_NONE)
		if #nEnemyHeroList >= 3 
		then
			return BOT_ACTION_DESIRE_HIGH,npcAlly,"W-Aoe:"..(#nEnemyHeroList);
		end
		
		--撤退
		if J.IsRetreating(npcAlly)
		then
			for _,npcEnemy in pairs(nEnemyHeroList)
			do 
				if J.IsValidHero(npcEnemy)
					and J.CanCastOnMagicImmune(npcEnemy)
					and ( npcAlly == npcEnemy:GetAttackTarget() 
						   or npcAlly:GetActiveModeDesire() > 0.85
						   or npcAlly:WasRecentlyDamagedByHero(npcEnemy,4.0))
				then
					return BOT_ACTION_DESIRE_HIGH,npcAlly,"W-Retreat:"..J.Chat.GetNormName(npcEnemy);
				end
			end
		end
		
		
		--进攻
		if J.IsGoingOnSomeone(npcAlly)
		then
			local allyTarget = J.GetProperTarget(npcAlly);
			if J.IsValidHero(allyTarget)
				and J.CanCastOnNonMagicImmune(allyTarget)
				and J.IsInRange(npcAlly,allyTarget,nRadius)
			then
				--protect
				if allyTarget:GetAttackTarget() == npcAlly
				then
					return BOT_ACTION_DESIRE_HIGH,npcAlly,"W-Attack1"..J.Chat.GetNormName(allyTarget);
				end
				
				--assist
				if npcAlly:IsFacingLocation(allyTarget:GetLocation(), 20)
					and not allyTarget:IsFacingLocation(npcAlly:GetLocation(), 120)
					and J.IsRunning(allyTarget)
				then
					return BOT_ACTION_DESIRE_HIGH,npcAlly,"W-Attack2"..J.Chat.GetNormName(allyTarget);
				end			
			end		
		end
		
		
		--推进
		if J.IsPushing(npcAlly) and nSkillLV >= 4 and J.IsAllowedToSpam(bot,nManaCost)
			and #hAllyList <= 2 and #hEnemyList == 0
		then
			local nCreeps = npcAlly:GetNearbyLaneCreeps(nRadius,true);
			if #nCreeps >= 4
				and not nCreeps[1]:HasModifier("modifier_fountain_glyph")
			then
				return BOT_ACTION_DESIRE_HIGH, npcAlly, "W-Pushing"..(#nCreeps);
			end
		end
		
		
		--打野
		if J.IsFarming(npcAlly) and nSkillLV >= 4 and J.IsAllowedToSpam(bot,nManaCost)
			and #hAllyList <= 3 and #hEnemyList == 0
		then
			local nCreeps = npcAlly:GetNearbyNeutralCreeps(nRadius);
			if #nCreeps >= 4
				and nCreeps[1]:GetMagicResist() < 0.3
			then
				return BOT_ACTION_DESIRE_HIGH, npcAlly, "W-Farming"..(#nCreeps);
			end
		end
		
		if talent7:IsTrained() 
			and J.IsAllowedToSpam(bot,nManaCost)
			and #hEnemyList == 0
		then
			if J.GetHPR(npcAlly) < 0.38
			then
				return BOT_ACTION_DESIRE_HIGH, npcAlly, "W-Heal:"..J.Chat.GetNormName(npcAlly);
			end
		end
	
	end
	
	return BOT_ACTION_DESIRE_NONE;
	
	
end

function X.ConsiderE()


	if not abilityE:IsFullyCastable() then return 0 end
	
	local nSkillLV    = abilityE:GetLevel(); 
	local nCastRange  = abilityE:GetCastRange() + aetherRange;
	
	if #hEnemyList <= 2 and nCastRange < 630 then nCastRange = nCastRange + 150 end
	
	local nCastPoint  = abilityE:GetCastPoint();
	local nManaCost   = abilityE:GetManaCost();
	local nDamage     = abilityE:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = bot:GetNearbyHeroes(nCastRange +50, true, BOT_MODE_NONE);
	
	
	--打断
	for _,npcEnemy in pairs(nInRangeEnemyList)
	do
		if J.IsValidHero(npcEnemy)
		then
			if npcEnemy:IsChanneling()
				and J.CanCastOnNonMagicImmune(npcEnemy)
			then
				return BOT_ACTION_DESIRE_HIGH,npcEnemy,'E-Check1:'..J.Chat.GetNormName(npcEnemy)
			end
			
			if J.IsCastingUltimateAbility(npcEnemy)
				and J.CanCastOnNonMagicImmune(npcEnemy)
			then
				return BOT_ACTION_DESIRE_HIGH,npcEnemy,'E-Check2:'..J.Chat.GetNormName(npcEnemy)
			end		
		end
	end
	
	
	--团战中对输出最强的敌人使用
	if J.IsInTeamFight(bot,900)
	then
		local nInBonusEnemyList = J.GetEnemyList(bot,nCastRange +420);
		if #nInBonusEnemyList >= 2 or #hAllyList >= 3
		then
			local npcMostDangerousEnemy = nil;
			local nMostDangerousDamage = 0;
			
			for _,npcEnemy in pairs( nInBonusEnemyList )
			do
				if  J.IsValid(npcEnemy)
					and J.CanCastOnNonMagicImmune(npcEnemy) 
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
			
			if npcMostDangerousEnemy ~= nil
				and J.IsInRange(bot,npcMostDangerousEnemy,nCastRange +50)
			then
				return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy,'E-Battle:'..J.Chat.GetNormName(npcMostDangerousEnemy)
			end
		
		end
	end
	
	
	--牵引
	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidHero(botTarget)
			and J.CanCastOnNonMagicImmune(botTarget)
			and J.IsInRange(bot,botTarget,nCastRange +32)
			and not J.IsInRange(bot,botTarget,nCastRange -200)
			and bot:IsFacingLocation(botTarget:GetLocation(),30)
			and not botTarget:IsFacingLocation(bot:GetLocation(),100)
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget,'E-Attack:'..J.Chat.GetNormName(botTarget)
		end	
	end
	
	
	--肉山
	if J.IsDoingRoshan(bot) and nMP > 0.6
	then
		if J.IsRoshan(botTarget)
			and J.IsInRange(bot,botTarget,nCastRange)
			and not J.IsDisabled(true,botTarget)
			and not botTarget:IsDisarmed()
		then
			return BOT_ACTION_DESIRE_HIGH,botTarget,"E-Roshan"
		end	
	end
	
	
	return BOT_ACTION_DESIRE_NONE;
	
	
end

function X.ConsiderR()


	if not abilityR:IsFullyCastable() then return 0 end
	
	local nSkillLV    = abilityR:GetLevel(); 
	local nCastRange  = abilityR:GetCastRange() + aetherRange
	local nCastPoint  = abilityR:GetCastPoint();
	local nManaCost   = abilityR:GetManaCost();
	local nDamage     = abilityR:GetSpecialValueInt('damage')
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = bot:GetNearbyHeroes(nCastRange +50, true, BOT_MODE_NONE);
	
	local nRadius = abilityR:GetSpecialValueInt('jump_range')/2
	
	--击杀
	for _,npcEnemy in pairs(nInRangeEnemyList)
	do 
		if J.IsValidHero(npcEnemy)
			and J.CanCastOnNonMagicImmune(npcEnemy)
			and J.CanCastOnTargetAdvanced(npcEnemy)
		then
			local nDelayTime = nCastPoint + GetUnitToUnitDistance(bot,npcEnemy)/850;
			if J.WillMagicKillTarget(bot,npcEnemy,nDamage,nDelayTime)
			then	
				return BOT_ACTION_DESIRE_HIGH,npcEnemy,'R-Kill:'..J.Chat.GetNormName(npcEnemy)
			end
		end
	end
	
	
	--Aoe
	if #nInRangeEnemyList >= 1
	then
		local nAoeLoc = J.GetAoeEnemyHeroLocation(bot, nCastRange, nRadius, 2);
		if nAoeLoc ~= nil
		then
			for _,npcEnemy in pairs(nInRangeEnemyList)
			do 
				if J.IsValidHero(npcEnemy)
					and J.CanCastOnNonMagicImmune(npcEnemy)
					and J.CanCastOnTargetAdvanced(npcEnemy)
					and J.IsInLocRange(npcEnemy,nAoeLoc,nRadius)
				then
					return BOT_ACTION_DESIRE_HIGH,npcEnemy,'R-Aoe:'..J.Chat.GetNormName(npcEnemy)
				end
			end
		end	
	end
	
	
	--进攻
	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidHero(botTarget)
			and J.CanCastOnNonMagicImmune(botTarget)
			and J.CanCastOnTargetAdvanced(botTarget)
			and J.IsInRange(bot,botTarget,nCastRange)
		then
			local nEnemyCreepList = botTarget:GetNearbyCreeps(nRadius *1.9,false);
			local nEnemyHeroList = botTarget:GetNearbyHeroes(nRadius *1.9,false,BOT_MODE_NONE);
			if #nEnemyCreepList >= 2 or #nEnemyHeroList >= 2 or nHP < 0.28
			then
				return BOT_ACTION_DESIRE_HIGH,botTarget,'R-Attack:'..J.Chat.GetNormName(botTarget)
			end
		end	
	end
	
	
	--撤退
	if J.IsRetreating(bot)
	then
		for _,npcEnemy in pairs(nInRangeEnemyList)
		do 
			if J.IsValidHero(npcEnemy)
				and J.CanCastOnNonMagicImmune(npcEnemy)
				and J.CanCastOnTargetAdvanced(npcEnemy)
				and bot:WasRecentlyDamagedByHero(npcEnemy,4.0)
			then
				local nEnemyCreepList = npcEnemy:GetNearbyCreeps(nRadius *1.9,false);
				local nEnemyHeroList = npcEnemy:GetNearbyHeroes(nRadius *1.9,false,BOT_MODE_NONE);
				if #nEnemyCreepList + #nEnemyHeroList >= 2 or nHP < 0.38
				then
					return BOT_ACTION_DESIRE_HIGH,npcEnemy,'R-Retreat:'..J.Chat.GetNormName(npcEnemy)
				end
			end
		end	
	end
	
	return BOT_ACTION_DESIRE_NONE;
	
	
end


return X
-- dota2jmz@163.com QQ:2462331592


