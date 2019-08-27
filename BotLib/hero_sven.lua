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
			['t15'] = {0, 10},
			['t10'] = {0, 10},
		},
		--技能
		['Ability'] = {1,3,1,2,2,6,2,2,1,1,6,3,3,3,6},
		--装备
		['Buy'] = {
			sOutfit,
			"item_mask_of_madness",
			"item_echo_sabre",
			"item_blink",
			"item_black_king_bar",
			"item_broken_satanic", 
			"item_orchid",
			"item_bloodthorn",
			"item_heart",
		},
		--出售
		['Sell'] = {
			"item_phase_boots",
			"item_stout_shield",
			
			"item_echo_sabre",
			"item_quelling_blade",
			
			"item_bloodthorn",
			"item_phase_boots",
			
			'item_black_king_bar',
			'item_magic_wand',
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
		['Ability'] = { 1, 3, 2, 1, 2, 6, 2, 2, 3, 3, 6, 3, 1, 1, 6 },
		--装备
		['Buy'] = {
			"item_tango",
			"item_flask",
			"item_stout_shield",
			"item_quelling_blade",
			"item_magic_stick",
			"item_bracer",
			"item_phase_boots",
			"item_echo_sabre",
			"item_blink",
			"item_black_king_bar",
			"item_greater_crit", 
			"item_assault",
			"item_travel_boots",
			"item_satanic",
			"item_ultimate_scepter",
			"item_moon_shard",
			"item_silver_edge"
		},
		--出售
		['Sell'] = {
			"item_echo_sabre",     
			"item_quelling_blade",

			"item_blink",
			"item_stout_shield",

			"item_black_king_bar",
			"item_magic_stick",

			"item_black_king_bar",     
			"item_magic_wand",
					
			"item_greater_crit", 
			"item_bracer",    

			"item_silver_edge",
			"item_blink"
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
		['Ability'] = { 1, 3, 1, 2, 1, 6, 1, 2, 2, 2, 6, 3, 3, 3, 6 },
		--装备
		['Buy'] = {
			"item_double_tango",
			"item_stout_shield",
			"item_boots",
			"item_magic_wand",
			"item_enchanted_mango",
			"item_double_flask",
			"item_hand_of_midas", 
			"item_echo_sabre",
			"item_phase_boots",
			"item_magic_wand",
			"item_blink",
			"item_black_king_bar",			
			"item_bloodthorn", 			
			"item_assault",
			"item_satanic",
			"item_moon_shard",
			"item_heart",
			"item_travel_boots",
			"item_ultimate_scepter",
			"item_ultimate_scepter_2",
			"item_travel_boots_2",
		},
		--出售
		['Sell'] = {
			"item_travel_boots",
			"item_phase_boots",

			"item_satanic",     
			"item_hand_of_midas",

			"item_assault",     
			"item_echo_sabre",

			"item_heart",     
			"item_blink",

			"item_bloodthorn",     
			"item_magic_wand",
					
			"item_black_king_bar",
			"item_stout_shield",	     
		},
	},
}
--默认数据
local tDefaultGroupedData = {
	--天赋树
	['Talent'] = {
		['t25'] = {10, 0},
		['t20'] = {10, 0},
		['t15'] = {0, 10},
		['t10'] = {0, 10},
	},
	--技能
	['Ability'] = {1,3,1,2,2,6,2,2,1,1,6,3,3,3,6},
	--装备
	['Buy'] = {
		sOutfit,
		"item_mask_of_madness",
		"item_echo_sabre",
		"item_blink",
		"item_black_king_bar",
		"item_broken_satanic", 
		"item_orchid",
		"item_bloodthorn",
		"item_heart",
	},
	--出售
	['Sell'] = {
		"item_phase_boots",
		"item_stout_shield",
		
		"item_echo_sabre",
		"item_quelling_blade",
		
		"item_bloodthorn",
		"item_phase_boots",
		
		'item_black_king_bar',
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
	end

end

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )


local castQDesire, castQTarget
local castEDesire
local castRDesire

local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;


function X.SkillsComplement()

	
	J.ConsiderForMkbDisassembleMask(bot);
	X.SvenConsiderTarget();
	
	
	
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
	
	
	
	nKeepMana = 400
	aetherRange = 0
	talentDamage = 0
	nLV = bot:GetLevel();
	nMP = bot:GetMana()/bot:GetMaxMana();
	nHP = bot:GetHealth()/bot:GetMaxHealth();
	hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);

	
	
	
		
	castRDesire = X.ConsiderR();
	if ( castRDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, true)
	
		bot:ActionQueue_UseAbility( abilityR );
		return;
	
	end
	
	castQDesire, castQTarget = X.ConsiderQ();
	if ( castQDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, true)
	
		bot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget );
		return;
		
	end
	
	castEDesire = X.ConsiderE();
	if ( castEDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, false)
	
		bot:ActionQueue_UseAbility( abilityE );
		return;
	
	end

end

function X.ConsiderQ()
	
	if not abilityQ:IsFullyCastable() then return 0 end
	
	-- Get some of its values
	local nCastRange  = abilityQ:GetCastRange();
	local nCastPoint  = abilityQ:GetCastPoint();
	local nManaCost   = abilityQ:GetManaCost();
	local nSkillLV    = abilityQ:GetLevel();                             
	local nDamage     = 80 * nSkillLV;
	local nRadius     = 255;
	local nDamageType = DAMAGE_TYPE_MAGICAL;
	
	local nAllies =  bot:GetNearbyHeroes(1200,false,BOT_MODE_NONE);
	
	if #hEnemyHeroList == 1 
	   and J.IsValidHero(hEnemyHeroList[1])
	   and J.IsInRange(hEnemyHeroList[1],bot,nCastRange + 350)
	   and hEnemyHeroList[1]:IsFacingLocation(bot:GetLocation(),30)
	   and hEnemyHeroList[1]:GetAttackRange() > nCastRange
	   and hEnemyHeroList[1]:GetAttackRange() < 1250
	then
		nCastRange = nCastRange + 260;
	end
	
	local nEnemysHerosInRange = bot:GetNearbyHeroes(nCastRange + 43,true,BOT_MODE_NONE);
	local nEnemysHerosInBonus = bot:GetNearbyHeroes(nCastRange + 350,true,BOT_MODE_NONE);
		
	local nEmemysCreepsInRange = bot:GetNearbyCreeps(nCastRange + 43,true);
	
	--打断和击杀 
	for _,npcEnemy in pairs( nEnemysHerosInBonus )
	do
		if J.IsValid(npcEnemy)
		   and J.CanCastOnNonMagicImmune(npcEnemy)
		   and J.CanCastOnTargetAdvanced(npcEnemy)
		   and not J.IsDisabled(true,npcEnemy)
		then
			if npcEnemy:IsChanneling()
				or J.CanKillTarget(npcEnemy,nDamage,nDamageType)
			then
			
				--隔空打断击杀目标
				local nBetterTarget = nil;
				local nAllEnemyUnits = J.CombineTwoTable(nEnemysHerosInRange,nEmemysCreepsInRange);
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
				   and not J.IsInRange(npcEnemy,bot,nCastRange) 
				then
					J.SetReport("打断或击杀Better:",nBetterTarget:GetUnitName());
					return BOT_ACTION_DESIRE_HIGH, nBetterTarget;
				else
					J.SetReport("打断或击杀目标:",npcEnemy:GetUnitName());
					return BOT_ACTION_DESIRE_HIGH, npcEnemy;
				end
			end			
		end
	end
	
	--团战中对作用数量最多或物理输出最强的敌人使用
	if J.IsInTeamFight(bot, 1200)
	then
		local npcMostAoeEnemy = nil;
		local nMostAoeECount  = 1;		
		local nAllEnemyUnits = J.CombineTwoTable(nEnemysHerosInRange,nEmemysCreepsInRange);
		
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;		
		
		for _,npcEnemy in pairs( nAllEnemyUnits )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and J.CanCastOnTargetAdvanced(npcEnemy)
				and not J.IsDisabled(true, npcEnemy)
				and not npcEnemy:IsDisarmed()
			then
				
				local nEnemyHeroCount = J.GetAroundTargetEnemyHeroCount(npcEnemy, nRadius);
				if ( nEnemyHeroCount > nMostAoeECount )
				then
					nMostAoeECount = nEnemyHeroCount;
					npcMostAoeEnemy = npcEnemy;
				end
				
				if npcEnemy:IsHero()
				then
					local npcEnemyDamage = npcEnemy:GetEstimatedDamageToTarget( false, bot, 3.0, DAMAGE_TYPE_PHYSICAL );
					if ( npcEnemyDamage > nMostDangerousDamage )
					then
						nMostDangerousDamage = npcEnemyDamage;
						npcMostDangerousEnemy = npcEnemy;
					end
				end
			end
		end
		
		if ( npcMostAoeEnemy ~= nil )
		then
			J.SetReport("团战控制数量多:",npcMostAoeEnemy:GetUnitName());
			return BOT_ACTION_DESIRE_HIGH, npcMostAoeEnemy;
		end	

		if ( npcMostDangerousEnemy ~= nil )
		then
--			J.SetReport("团战控制战力最强:",npcMostDangerousEnemy:GetUnitName());
			return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy;
		end	
	end
	
	--对线期间对敌方英雄使用
	if bot:GetActiveMode() == BOT_MODE_LANING or nLV <= 5
	then
		for _,npcEnemy in pairs( nEnemysHerosInRange )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and J.CanCastOnTargetAdvanced(npcEnemy)
				and not J.IsDisabled(true, npcEnemy)
				and J.GetAttackTargetEnemyCreepCount(npcEnemy, 1400) >= 5
			then
				J.SetReport("对线期间使用:",npcEnemy:GetUnitName());
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
			and J.IsInRange(npcTarget, bot, nCastRange +60) 
			and not J.IsDisabled(true, npcTarget)
			and not npcTarget:IsDisarmed()
		then
			if nSkillLV >= 3 or nMP > 0.88 or J.GetHPR(npcTarget) < 0.38 or nHP < 0.25
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	
	--撤退时保护自己
	if J.IsRetreating(bot) 
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
				J.SetReport("撤退了保护自己:",npcEnemy:GetUnitName());
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	--发育时对野怪输出
	if J.IsFarming(bot) and nSkillLV >= 3
	   and (bot:GetAttackDamage() < 200 or nMP > 0.88)
	   and nMP > 0.78
	then
		local nNeutralCreeps = bot:GetNearbyNeutralCreeps(700);
		if #nNeutralCreeps >= 3
		then
			for _,creep in pairs(nNeutralCreeps)
			do
				if J.IsValid(creep)
					and creep:GetHealth() >= 900
					and creep:GetMagicResist() < 0.3
					and J.IsInRange(creep,bot,350)
					and J.GetAroundTargetEnemyUnitCount(creep, nRadius) >= 3
				then
					J.SetReport("打野时野怪数量:",#nNeutralCreeps);
					return BOT_ACTION_DESIRE_HIGH, creep;
				end			
			end
		end
	end
	
	
	--推进时对小兵用
	if  (J.IsPushing(bot) or J.IsDefending(bot) or J.IsFarming(bot))
	    and (bot:GetAttackDamage() < 200 or nMP > 0.9)
		and nSkillLV >= 4 and #hEnemyHeroList == 0 and nMP > 0.68
		and not J.IsInEnemyArea(bot)
	then
		local nLaneCreeps = bot:GetNearbyLaneCreeps(1000,true);
		if #nLaneCreeps >= 5
		then
			for _,creep in pairs(nLaneCreeps)
			do
				if J.IsValid(creep)
					and creep:GetHealth() >= 500
					and not creep:HasModifier("modifier_fountain_glyph")
					and J.IsInRange(creep,bot,nCastRange + 100)
					and J.GetAroundTargetEnemyUnitCount(creep, nRadius) >= 5
				then
					J.SetReport("推进时小兵数量:",#nLaneCreeps);
					return BOT_ACTION_DESIRE_HIGH, creep;
				end			
			end
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
	
	--通用受到伤害时保护自己
	if bot:WasRecentlyDamagedByAnyHero(3.0) 
		and bot:GetActiveMode() ~= BOT_MODE_RETREAT
		and #nEnemysHerosInRange >= 1
		and nLV >= 7
	then
		for _,npcEnemy in pairs( nEnemysHerosInRange )
		do
			if  J.IsValidHero(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and J.CanCastOnTargetAdvanced(npcEnemy)
				and not J.IsDisabled(true, npcEnemy)
                and not npcEnemy:IsDisarmed()				
				and bot:IsFacingLocation(npcEnemy:GetLocation(),45)
			then
				J.SetReport("保护我自己:",npcEnemy:GetUnitName());
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end
	
	--通用消耗敌人或保护自己
	if (#hEnemyHeroList > 0 or bot:WasRecentlyDamagedByAnyHero(3.0)) 
		and ( bot:GetActiveMode() ~= BOT_MODE_RETREAT or #nAllies >= 2 )
		and #nEnemysHerosInRange >= 1
		and nLV >= 7
	then
		for _,npcEnemy in pairs( nEnemysHerosInRange )
		do
			if  J.IsValidHero(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and J.CanCastOnTargetAdvanced(npcEnemy)
				and not J.IsDisabled(true, npcEnemy)			
			then
				J.SetReport("通用的情况:",npcEnemy:GetUnitName());
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end

	return 0,nil;
end

function X.ConsiderE()
	
	if not abilityE:IsFullyCastable() 
		or ( #hEnemyHeroList == 0 and nHP > 0.2 )
	then 
		return 0;
	end
	
	local nSkillRange = 700;	          
	
	local nAllies = J.GetAllyList(bot,nSkillRange);
	local nAlliesCount = #nAllies;
	local nWeakestAlly = J.GetLeastHpUnit(nAllies);
	if nWeakestAlly == nil then nWeakestAlly = bot; end
	local nWeakestAllyHP = J.GetHPR(nWeakestAlly);
	
	local nEnemysHerosNearby = nWeakestAlly:GetNearbyHeroes(800,true,BOT_MODE_NONE);
	
	local nBonusPer = (#nEnemysHerosNearby)/20;
	
	local nShouldBonusCount = 1;
	if nWeakestAllyHP > 0.35  + nBonusPer then nShouldBonusCount = nShouldBonusCount + 1 end;
	if nWeakestAllyHP > 0.50  + nBonusPer then nShouldBonusCount = nShouldBonusCount + 1 end;
	if nWeakestAllyHP > 0.65 + nBonusPer then nShouldBonusCount = nShouldBonusCount + 1 end;
	if nWeakestAllyHP > 0.9  + nBonusPer then nShouldBonusCount = nShouldBonusCount + 1 end;
	
	--根据血量决定作用人数
	if nAlliesCount >= nShouldBonusCount
		and #nEnemysHerosNearby >= 1
		and nWeakestAlly:WasRecentlyDamagedByAnyHero(4.0)
	then
--		J.SetReport("当前血量适合套盾",nShouldBonusCount);
		return BOT_ACTION_DESIRE_HIGH;
	end	
	
	--尝试救队友一命
	if J.IsRetreating(nWeakestAlly)
		and nWeakestAlly:GetHealth() < 150
	then
		J.SetReport("尝试救队友一命",nShouldBonusCount);
		return BOT_ACTION_DESIRE_HIGH;
	end		
	
	--打架时追杀	
	if J.IsGoingOnSomeone(bot)
	then
	    local npcTarget = J.GetProperTarget(bot);
		if J.IsValidHero(npcTarget) 
		   and not J.IsInRange(npcTarget,bot,300)
		   and J.IsInRange(npcTarget,bot,600)
		   and bot:IsFacingLocation(npcTarget:GetLocation(),15)
		   and npcTarget:IsFacingLocation(J.GetEnemyFountain(),20)
		then
--			J.SetReport("套盾打架:",npcTarget:GetUnitName());
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	return 0;
end

function X.ConsiderR()

	if not abilityR:IsFullyCastable() 
	then 
		return 0;
	end
	
	local nEnemysHerosInBonus = bot:GetNearbyHeroes(1200,true,BOT_MODE_NONE);	
	
	--打架时先手	
	if J.IsGoingOnSomeone(bot)
	then
	    local npcTarget = J.GetProperTarget(bot);
		if J.IsValidHero(npcTarget) 
		   and ( J.GetHPR(npcTarget) > 0.25 or #nEnemysHerosInBonus >= 2 )
		   and ( J.IsInRange(npcTarget,bot,700)
				 or J.IsInRange(npcTarget,bot,npcTarget:GetAttackRange() + 80) )				  
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	--撤退时保护自己
	if bot:GetActiveMode() == BOT_MODE_RETREAT 
		and bot:DistanceFromFountain() > 800
		and nHP > 0.5
		and bot:WasRecentlyDamagedByAnyHero(3.0)
		and #nEnemysHerosInBonus >= 1
	then
		return BOT_ACTION_DESIRE_HIGH;
	end

	return 0;
end

function X.SvenConsiderTarget()

	local bot = GetBot();
	
	if not J.IsRunning(bot) 
	then return end
	
	local npcTarget = bot:GetAttackTarget();
	if not J.IsValidHero(npcTarget) then return end

	local nAttackRange = bot:GetAttackRange() + 50;	
	local nEnemyHeroInRange = bot:GetNearbyHeroes(nAttackRange,true,BOT_MODE_NONE);
	
	local nInAttackRangeNearestEnemyHero = nEnemyHeroInRange[1];

	if  J.IsValidHero(nInAttackRangeWeakestEnemyHero)
		and J.CanBeAttacked(nInAttackRangeWeakestEnemyHero)
		and ( GetUnitToUnitDistance(npcTarget,bot) >  350 or U.HasForbiddenModifier(npcTarget) )		
	then
		J.SetReport("更改目标为:",nInAttackRangeWeakestEnemyHero:GetUnitName());
		bot:SetTarget(nInAttackRangeWeakestEnemyHero);
		return;
	end

end

return X
-- dota2jmz@163.com QQ:2462331592
