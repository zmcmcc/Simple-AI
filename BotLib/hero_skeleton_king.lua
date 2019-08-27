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

local tTalentTree20 = {10,10}
if J.Skill.IsHeroInEnemyTeam("npc_dota_hero_antimage") 
   or J.Skill.IsHeroInEnemyTeam("npc_dota_hero_phantom_lancer")
then  
	tTalentTree20[1] = 0; 
else
	tTalentTree20[2] = 0; 
end

--编组技能、天赋、装备
local tGroupedDataList = {
	{
		--组合说明，不影响游戏
		['info'] = 'By 决明子',
		--天赋树
		['Talent'] = {
			['t25'] = {10, 0},
			['t20'] = tTalentTree20,
			['t15'] = {0, 10},
			['t10'] = {0, 10},
		},
		--技能
		['Ability'] = {1,3,1,2,1,6,1,3,3,3,6,2,2,2,6},
		--装备
		['Buy'] = {
			sOutfit,
				"item_crimson_guard",
				"item_echo_sabre",
				"item_heavens_halberd",
				"item_assault",
				"item_heart",
		},
		--出售
		['Sell'] = {
			"item_crimson_guard",
			"item_quelling_blade",
			
			"item_assault",
			"item_echo_sabre",
			
			"item_heavens_halberd",
			"item_magic_wand",
		},
	},{
		--组合说明，不影响游戏
		['info'] = 'By Misunderstand',
		--天赋树
		['Talent'] = {
			['t25'] = {0, 10},
			['t20'] = {10, 0},
			['t15'] = {10, 0},
			['t10'] = {0, 10},
		},
		--技能
		['Ability'] = { 1, 3, 2, 1, 1, 6, 3, 3, 1, 3, 6, 2, 2, 2, 6 },
		--装备
		['Buy'] = {
			"item_tango",
			"item_gauntlets",
			"item_double_branches",
			"item_stout_shield",
			"item_quelling_blade",
			"item_magic_stick",
			"item_magic_wand",
			"item_bracer",
			"item_enchanted_mango",
			"item_phase_boots",
			"item_ancient_janggo",
			"item_blade_mail",
			"item_blink",
			"item_black_king_bar", 
			"item_basher",
			"item_mjollnir",
			"item_ultimate_scepter_2",
			"item_assault",
			"item_travel_boots",
			"item_abyssal_blade",
			"item_moon_shard",
			"item_travel_boots_2"
		},
		--出售
		['Sell'] = {
			"item_ancient_janggo",     
			"item_quelling_blade",

			"item_blade_mail",     
			"item_stout_shield",
					
			"item_black_king_bar",  
			"item_bracer",	  

			"item_basher",
			"item_ancient_janggo",

			"item_mjollnir",
			"item_magic_wand",

			"item_assault",
			"item_blade_mail",

			"item_travel_boots",
			"item_phase_boots"
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
		['Ability'] = { 1, 3, 2, 1, 1, 6, 1, 3, 3, 2, 6, 3, 2, 2, 6 },
		--装备
		['Buy'] = {
			"item_stout_shield",
			"item_quelling_blade",
			"item_tango",
			"item_flask",			
			"item_magic_stick",
			"item_power_treads",
			"item_magic_wand",
			"item_hand_of_midas",
			"item_basher", 
			"item_assault", 
			"item_lotus_orb",
			"item_abyssal_blade",
			"item_ultimate_scepter", 
			"item_desolator", 
			"item_ultimate_scepter_2",
			"item_moon_shard",
			"item_heart",
			"item_travel_boots",
			"item_travel_boots_2",
		},
		--出售
		['Sell'] = {
			"item_travel_boots",     
			"item_power_treads",

			"item_desolator",     
			"item_hand_of_midas",

			"item_assault",     
			"item_quelling_blade", 

			"item_lotus_orb",     
			"item_magic_wand", 
		},
	},
}
--默认数据
local tDefaultGroupedData = {
	--天赋树
	['Talent'] = {
		['t25'] = {10, 0},
		['t20'] = tTalentTree20,
		['t15'] = {0, 10},
		['t10'] = {0, 10},
	},
	--技能
	['Ability'] = {1,3,1,2,1,6,1,3,3,3,6,2,2,2,6},
	--装备
	['Buy'] = {
		sOutfit,
			"item_crimson_guard",
			"item_echo_sabre",
			"item_heavens_halberd",
			"item_assault",
			"item_heart",
	},
	--出售
	['Sell'] = {
		"item_crimson_guard",
		"item_quelling_blade",
		
		"item_assault",
		"item_echo_sabre",
		
		"item_heavens_halberd",
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
	   and hMinionUnit:GetUnitName() ~= "npc_dota_wraith_king_skeleton_warrior" 
	then
		Minion.IllusionThink(hMinionUnit)
	end

end

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )
local talent5 = bot:GetAbilityByName( sTalentList[5] );

local castQDesire, castQTarget
local castWDesire
local castEDesire

local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;

function X.SkillsComplement()

	
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
	
	
	nKeepMana = 160
	nLV = bot:GetLevel();
	nMP = bot:GetMana()/bot:GetMaxMana();
	nHP = bot:GetHealth()/bot:GetMaxHealth();
	hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	
	
	
	
	castQDesire, castQTarget = X.ConsiderQ();
	if ( castQDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, false)
	
		bot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget )
		return;
	end
	
	castEDesire  = X.ConsiderE();
	if ( castEDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, false)
	
		bot:ActionQueue_UseAbility( abilityE )
		return;
	
	end

end

function X.ConsiderQ()

	-- Make sure it's castable
	if not abilityQ:IsFullyCastable() 
	   or X.ShouldSaveMana(abilityQ)
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange  = abilityQ:GetCastRange();
	local nCastPoint  = abilityQ:GetCastPoint();
	local nManaCost   = abilityQ:GetManaCost();
	local nSkillLV    = abilityQ:GetLevel();                             
	local nDamage     = 40 * ( nSkillLV - 1) + 100;
	local nDamageType = DAMAGE_TYPE_MAGICAL;
	
	local nAlleys =  bot:GetNearbyHeroes(1200,false,BOT_MODE_NONE);
	
	local nEnemysHerosInView  = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	
	if #nEnemysHerosInView == 1 
	   and J.IsValidHero(nEnemysHerosInView[1])
	   and J.IsInRange(nEnemysHerosInView[1],bot,nCastRange + 350)
	   and nEnemysHerosInView[1]:IsFacingLocation(bot:GetLocation(),30)
	   and nEnemysHerosInView[1]:GetAttackRange() > nCastRange
	   and nEnemysHerosInView[1]:GetAttackRange() < 1250
	then
		nCastRange = nCastRange + 260;
	end
	
	local nEnemysHerosInRange = bot:GetNearbyHeroes(nCastRange + 43,true,BOT_MODE_NONE);
	local nEnemysHerosInBonus = bot:GetNearbyHeroes(nCastRange + 330,true,BOT_MODE_NONE);		
	
	--打断和击杀
	for _,npcEnemy in pairs( nEnemysHerosInBonus )
	do
		if J.IsValid(npcEnemy)
		   and J.CanCastOnNonMagicImmune(npcEnemy)
		   and J.CanCastOnTargetAdvanced(npcEnemy)
		then
			if npcEnemy:IsChanneling()
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
			
			if  GetUnitToUnitDistance(bot,npcEnemy) <= nCastRange + 80
				and J.CanKillTarget(npcEnemy,nDamage *1.68,nDamageType)
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
			
		end
	end
	
	--团战中对战力最高的敌人使用
	if J.IsInTeamFight(bot, 1200)
	then
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;		
		
		for _,npcEnemy in pairs( nEnemysHerosInRange )
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
	
	--对线期间对敌方英雄使用
	if bot:GetActiveMode() == BOT_MODE_LANING or nLV <= 5
	then
		for _,npcEnemy in pairs( nEnemysHerosInBonus )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and J.CanCastOnTargetAdvanced(npcEnemy)
				and not J.IsDisabled(true, npcEnemy)
				and J.GetAttackTargetEnemyCreepCount(npcEnemy, 1400) >= 4
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end	
	end
	
	
	--打架时先手	
	if J.IsGoingOnSomeone(bot)
	then
	    local npcTarget = J.GetProperTarget(bot);
		if J.IsValidHero(npcTarget) 
			and J.CanCastOnNonMagicImmune(npcTarget) 
			and J.CanCastOnTargetAdvanced(npcTarget)
			and J.IsInRange(npcTarget, bot, nCastRange +80) 
			and not J.IsDisabled(true, npcTarget)
			and not npcTarget:IsDisarmed()
		then
			if nSkillLV >= 3 or nMP > 0.68 or J.GetHPR(npcTarget) < 0.38 or nHP < 0.25
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	
	--撤退时保护自己
	if J.IsRetreating(bot) 
		and not bot:IsInvisible()
	then
		for _,npcEnemy in pairs( nEnemysHerosInRange )
		do
			if J.IsValid(npcEnemy)
			    and ( bot:WasRecentlyDamagedByHero( npcEnemy, 5.0 ) 
						or nMP > 0.8
						or GetUnitToUnitDistance(bot,npcEnemy) <= 400 )
				and J.CanCastOnNonMagicImmune(npcEnemy) 
				and J.CanCastOnTargetAdvanced(npcEnemy)
				and not J.IsDisabled(true, npcEnemy) 
				and not npcEnemy:IsDisarmed()
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	if  J.IsFarming(bot) 
		and nSkillLV >= 3
		and (bot:GetAttackDamage() < 200 or nMP > 0.88)
		and nMP > 0.71
	then
		local nCreeps = bot:GetNearbyNeutralCreeps(nCastRange +100);
		
		local targetCreep = J.GetMostHpUnit(nCreeps);
		
		if J.IsValid(targetCreep)
			and ( #nCreeps >= 2 or GetUnitToUnitDistance(targetCreep,bot) <= 400 )
			and not J.IsRoshan(targetCreep)
			and not J.IsOtherAllysTarget(targetCreep)
			and targetCreep:GetMagicResist() < 0.3
			and not J.CanKillTarget(targetCreep,bot:GetAttackDamage() *1.68,DAMAGE_TYPE_PHYSICAL)
			and not J.CanKillTarget(targetCreep,nDamage,nDamageType)
		then
			return BOT_ACTION_DESIRE_HIGH, targetCreep;
	    end
	end
	
	--打肉的时候输出
	if  bot:GetActiveMode() == BOT_MODE_ROSHAN 
		and bot:GetMana() >= 600
	then
		local npcTarget = bot:GetAttackTarget();
		if  J.IsRoshan(npcTarget) 
			and not J.IsDisabled(true, npcTarget)
			and not npcTarget:IsDisarmed()
			and J.IsInRange(npcTarget, bot, nCastRange)  
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	--受到伤害时保护自己
	if bot:WasRecentlyDamagedByAnyHero(3.0) 
		and bot:GetActiveMode() ~= BOT_MODE_RETREAT
		and not bot:IsInvisible()
		and #nEnemysHerosInRange >= 1
		and nLV >= 6
	then
		for _,npcEnemy in pairs( nEnemysHerosInRange )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and J.CanCastOnTargetAdvanced(npcEnemy)
				and not J.IsDisabled(true, npcEnemy)
                and not npcEnemy:IsDisarmed()				
				and bot:IsFacingLocation(npcEnemy:GetLocation(),45)
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end
	
	--通用消耗敌人或受到伤害时保护自己
	if (#nEnemysHerosInView > 0 or bot:WasRecentlyDamagedByAnyHero(3.0)) 
		and ( bot:GetActiveMode() ~= BOT_MODE_RETREAT or #nAlleys >= 2 )
		and #nEnemysHerosInRange >= 1
		and nLV >= 7
	then
		for _,npcEnemy in pairs( nEnemysHerosInRange )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and J.CanCastOnTargetAdvanced(npcEnemy)
				and not J.IsDisabled(true, npcEnemy)			
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end
	
	--其他特殊用途
	
	return 0;

end

function X.ConsiderE()

	-- Make sure it's castable
	if  not abilityE:IsFullyCastable() 
	    or not bot:HasModifier("modifier_skeleton_king_mortal_strike")
		or X.ShouldSaveMana(abilityE)
	then return 0; end
	
	local nStack = 0;
	local modIdx = bot:GetModifierByName("modifier_skeleton_king_mortal_strike");
	if modIdx > -1 then
		nStack = bot:GetModifierStackCount(modIdx);
	end
	local maxStack = abilityE:GetSpecialValueInt("max_skeleton_charges");
	
	local nEnemysHerosInView  = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	local npcTarget = J.GetProperTarget(bot);
	
	--辅助进攻
	if J.IsValidHero(npcTarget) 
		and #nEnemysHerosInView == 1
	    and J.IsInRange(npcTarget, bot, 650)
		and nStack / maxStack >= 0.6
	then
		return BOT_ACTION_DESIRE_HIGH;
	end	
	
	--buff叠满了靠近兵线的时候
	if nStack == maxStack
		and nLV >= 4
		and ( X.IsNearLaneFront(bot) or J.IsFarming(bot))
	then
		return BOT_ACTION_DESIRE_HIGH;
	end
		
	return 0;
end

function X.IsNearLaneFront( bot )
	local testDist = 600;
	local lanes = {LANE_TOP, LANE_MID, LANE_BOT};
	for _,lane in pairs(lanes)
	do
		local tFLoc = GetLaneFrontLocation(GetTeam(), lane, 0);
		if GetUnitToLocationDistance(bot,tFLoc) <= testDist
		then
		    return true;
		end		
	end
	return false;
end

function X.ShouldSaveMana(nAbility)
	
	if talent5:IsTrained() then return false end;

	if  nLV >= 6
	    and abilityR:GetCooldownTimeRemaining() <= 3.0
		and ( bot:GetMana() - nAbility:GetManaCost() < abilityR:GetManaCost())
	then
		return true;
	end
	
	return false;
end


return X
-- dota2jmz@163.com QQ:2462331592
