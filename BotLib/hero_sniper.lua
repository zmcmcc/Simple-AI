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
			['t15'] = {10, 0},
			['t10'] = {10, 0},
		},
		--技能
		['Ability'] = {1,2,1,3,1,6,1,2,2,2,6,3,3,3,6},
		--装备
		['Buy'] = {
			sOutfit,
			"item_dragon_lance",
			'item_mask_of_madness',
			"item_maelstrom",
			"item_hurricane_pike",
			"item_skadi",
			"item_broken_satanic",	
			"item_monkey_king_bar",
			"item_mjollnir",
		},
		--出售
		['Sell'] = {
			"item_ultimate_scepter",
			"item_magic_wand",
			
			"item_sheepstick",
			"item_arcane_boots",
		},
	},{
		--组合说明，不影响游戏
		['info'] = 'By 决明子2',
		--天赋树
		['Talent'] = {
			['t25'] = {0, 10},
			['t20'] = {10, 0},
			['t15'] = {10, 0},
			['t10'] = {10, 0},
		},
		--技能
		['Ability'] = {1,2,1,3,1,6,1,2,2,2,6,3,3,3,6},
		--装备
		['Buy'] = {
			sOutfit,
			"item_dragon_lance",
			'item_hand_of_midas',
			"item_maelstrom",
			"item_hurricane_pike",
			"item_skadi",
			"item_black_king_bar",	
			"item_monkey_king_bar",
			"item_mjollnir",
		},
		--出售
		['Sell'] = {
			"item_ultimate_scepter",
			"item_magic_wand",
			
			"item_sheepstick",
			"item_arcane_boots",
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
		['Ability'] = { 1, 2, 2, 1, 3, 6, 1, 1, 3, 3, 6, 2, 3, 2, 6 },
		--装备
		['Buy'] = {
			"item_double_mantle",
			"item_double_circlet",
			"item_magic_stick",
			"item_double_tango",
			"item_double_null_talisman",
			"item_double_enchanted_mango",
			"item_bottle",
			"item_double_clarity",
			"item_boots",
			"item_kaya",
			"item_arcane_boots",
			"item_rod_of_atos",
			"item_blink",
			"item_veil_of_discord",
			"item_ultimate_scepter",
			"item_aether_lens",
			"item_ultimate_scepter_2",
			"item_sheepstick",
			"item_cyclone",
			"item_travel_boots",
			"item_kaya_and_sange",
			"item_travel_boots_2",
		},
		--出售
		['Sell'] = {
			"item_rod_of_atos",
			"item_magic_stick",

			"item_blink",
			"item_bottle",
					
			"item_ultimate_scepter",
			"item_null_talisman",

			"item_cyclone",
			"item_blink",

			"item_travel_boots",
			"item_arcane_boots"
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
		['Ability'] = { 1, 2, 3, 1, 1, 6, 1, 2, 2, 2, 6, 3, 3, 3, 6 },
		--装备
		['Buy'] = {
			"item_double_tango",
			"item_double_flask",
			"item_clarity",
			"item_enchanted_mango",
			"item_magic_wand",
			"item_boots",
			"item_double_null_talisman",
			"item_arcane_boots",
			"item_rod_of_atos",
			"item_glimmer_cape",
			"item_ultimate_scepter",			
			"item_kaya",
			"item_sheepstick", 
			"item_kaya_and_sange",
			"item_guardian_greaves",
			"item_ultimate_scepter_2",
			"item_lotus_orb",
			"item_shivas_guard", 
		},
		--出售
		['Sell'] = {
			"item_shivas_guard",     
			"item_rod_of_atos",

			"item_sheepstick",     
			"item_magic_wand",
					
			"item_ultimate_scepter",  
			"item_null_talisman",	 
		},
	},
}
--默认数据
local tDefaultGroupedData = {
	--天赋树
	['Talent'] = {
		['t25'] = {0, 10},
		['t20'] = {10, 0},
		['t15'] = {10, 0},
		['t10'] = {10, 0},
	},
	--技能
	['Ability'] = {1,2,1,3,1,6,1,2,2,2,6,3,3,3,6},
	--装备
	['Buy'] = {
		sOutfit,
		--"item_soul_ring",
		"item_rod_of_atos",
		"item_pipe",
		"item_glimmer_cape",
		"item_cyclone",
		"item_ultimate_scepter",
		"item_sheepstick",
	},
	--出售
	['Sell'] = {
		"item_ultimate_scepter",
		"item_magic_wand",
		
		"item_sheepstick",
		"item_arcane_boots",
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

local abilityQ = bot:GetAbilityByName( sAbilityList[1] );
local abilityE = bot:GetAbilityByName( sAbilityList[3] );
local abilityR = bot:GetAbilityByName( sAbilityList[6] );


local castQDesire,castQLocation = 0;
local castEDesire = 0;
local castRDesire,castRTarget = 0;


local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;
local lastAbilityQTime = 0
local lastAbilityQLocation = Vector(0,0)

function X.SkillsComplement()

	
	X.ConsiderTarget();
	J.ConsiderForMkbDisassembleMask(bot);
	
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
	
	nKeepMana = 280; 
	nMP = bot:GetMana()/bot:GetMaxMana();
	nHP = bot:GetHealth()/bot:GetMaxHealth();
	nLV = bot:GetLevel();
	hEnemyHeroList = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	
	castRDesire, castRTarget   = X.ConsiderR();
	if ( castRDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, true)
		
		if bot:HasScepter() 
		then
			bot:ActionQueue_UseAbilityOnLocation( abilityR, castRTarget:GetLocation() )
			return;
		else		
			bot:ActionQueue_UseAbilityOnEntity( abilityR, castRTarget )
			return;
		end
	end
	
	castEDesire = X.ConsiderE();
	if ( castEDesire > 0 ) 
	then
	
		bot:Action_ClearActions(false);
	
		bot:ActionQueue_UseAbility( abilityE )
		return;
	
	end
	
	castQDesire, castQLocation = X.ConsiderQ();
	if ( castQDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, false)
	
		bot:ActionQueue_UseAbilityOnLocation( abilityQ, castQLocation )
		lastAbilityQTime = DotaTime();
		lastAbilityQLocation = castQLocation;
		return;
	end
	

end

function X.ConsiderTarget()
	if not J.IsRunning(bot) 
	   or bot:HasModifier("modifier_item_hurricane_pike_range")
	then return  end

	local nAttackRange = bot:GetAttackRange() + 60;	
	if nAttackRange > 1600 then nAttackRange = 1600 end
	local nInAttackRangeWeakestEnemyHero = J.GetAttackableWeakestUnit(true, true, nAttackRange, bot);
	
	local npcTarget = J.GetProperTarget(bot);
	local nTargetUint = nil;

	if J.IsValidHero(npcTarget)
		and GetUnitToUnitDistance(npcTarget,bot) >  nAttackRange 
		and J.IsValidHero(nInAttackRangeWeakestEnemyHero)
	then
		nTargetUint = nInAttackRangeWeakestEnemyHero;
		bot:SetTarget(nTargetUint);
		return;
	end

end

function X.ConsiderQ()
	
	if not abilityQ:IsFullyCastable() 
	   or lastAbilityQTime > DotaTime() - 0.5
	then return 0 end
	
	local nCastRange = 1600;   --abilityQ:GetCastRange();
	local nSkillLV   = abilityQ:GetLevel();
	local nDamage = (15 +20*(nSkillLV -1)) *11;
	local nRadius = abilityQ:GetAOERadius();
	local nCastPoint = abilityQ:GetCastPoint();
	local botLocation = bot:GetLocation();
	
	local nEnemysLaneCreepsInSkillRange = bot:GetNearbyLaneCreeps(1600,true)
	local nEnemysHeroesInSkillRange = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE)
	
	local nCanHurtCreepsLocationAoE = bot:FindAoELocation( true, false, botLocation, nCastRange, nRadius, 0.8, 0);
	local nCanHurtCreepCount = nCanHurtCreepsLocationAoE.count;
	if nCanHurtCreepsLocationAoE == nil
       or J.GetInLocLaneCreepCount(bot, 1600, nRadius, nCanHurtCreepsLocationAoE.targetloc) <= 2   --检查半径内是否真的有小兵
	then
	     nCanHurtCreepCount = 0
	end
	local nCanHurtHeroLocationAoE = bot:FindAoELocation( true, true, botLocation, nCastRange, nRadius-30, 0.8, 0);
	
	local npcTarget = J.GetProperTarget(bot)
	
	--对多个敌方英雄使用
	if #nEnemysHeroesInSkillRange >= 2
		and (nCanHurtHeroLocationAoE.cout ~= nil and nCanHurtHeroLocationAoE.cout >= 2)
		and bot:GetActiveMode( ) ~= BOT_MODE_LANING
		and (bot:GetActiveMode() ~= BOT_MODE_RETREAT or (bot:GetActiveMode() == BOT_MODE_RETREAT and bot:GetActiveModeDesire( ) < 0.6))
		and not X.IsAbiltyQCastedHere(nCanHurtHeroLocationAoE.targetloc,nRadius)
    then
		J.SetReport("对多个敌人使用技能,伤害人数",nCanHurtHeroLocationAoE.cout);
		return BOT_ACTION_DESIRE_HIGH,nCanHurtHeroLocationAoE.targetloc;
	end
	
	--对当前目标英雄使用	
	if J.IsValidHero(npcTarget)
	   and not npcTarget:HasModifier("modifier_sniper_shrapnel_slow")
	   and J.CanCastOnNonMagicImmune(npcTarget) 
	   and J.IsInRange(npcTarget, bot, nCastRange +300)
	   and (nSkillLV >= 3 or bot:GetMana() >= nKeepMana)
	   and not X.IsAbiltyQCastedHere(npcTarget:GetLocation(),nRadius)
	then
		
		if npcTarget:IsFacingLocation(J.GetEnemyFountain(),30)
			and J.GetHPR(npcTarget) < 0.4
			and J.IsRunning(npcTarget)
		then
			for i=0,800,200
			do
				local nCastLocation = J.GetLocationTowardDistanceLocation(npcTarget,J.GetEnemyFountain(),nRadius + 800 - i);
				if GetUnitToLocationDistance(bot,nCastLocation) <= nCastRange + 200
				then
					J.SetReport("追击减速当前目标,目标是",npcTarget:GetUnitName());
					return BOT_ACTION_DESIRE_HIGH,nCastLocation;
				end
			end
		end	
	
		local npcTargetLocInFuture = J.GetCorrectLoc(npcTarget, nCastPoint +1.8);
	    if J.GetLocationToLocationDistance(npcTarget:GetLocation(),npcTargetLocInFuture) > 300
			and npcTarget:GetMovementDirectionStability() > 0.4
	    then
			J.SetReport("对当前目标使用技能,目标是",npcTarget:GetUnitName());
		    return BOT_ACTION_DESIRE_HIGH,npcTargetLocInFuture;
		end
		
		local castDistance = GetUnitToUnitDistance(bot,npcTarget);
		if npcTarget:IsFacingLocation(botLocation, 30) and J.IsMoving(npcTarget)
		then
			if castDistance > 400 
			then   
			    castDistance = castDistance - 200;
			end
			J.SetReport("近处预测将到近处来的目标:",npcTarget:GetUnitName());
		    return BOT_ACTION_DESIRE_HIGH,J.GetUnitTowardDistanceLocation(bot,npcTarget,castDistance);
		end		
		
		if bot:IsFacingLocation(npcTarget:GetLocation(), 30)
		then
		    if castDistance <= nCastRange - 200
			then
			    castDistance = castDistance + 400;
			else
			    castDistance = nCastRange+ 300;
			end
			J.SetReport("远处预测将到远处去的目标:",npcTarget:GetUnitName());
		    return BOT_ACTION_DESIRE_HIGH,J.GetUnitTowardDistanceLocation(bot,npcTarget,castDistance);
		end
		
		J.SetReport("目标位置无规律,目标是",npcTarget:GetUnitName());
		return BOT_ACTION_DESIRE_HIGH,J.GetLocationTowardDistanceLocation(npcTarget,J.GetEnemyFountain(),nRadius/2);
		
	end
	
	--撤退时减速
	if J.IsRetreating(bot)
	   and not bot:IsInvisible()  
	then
		local nCanHurtHeroLocationAoENearby = bot:FindAoELocation( true, true, botLocation, nCastRange - 400, nRadius, 1.5, 0);
		if nCanHurtHeroLocationAoENearby.count >= 2 
		   and not X.IsAbiltyQCastedHere(nCanHurtHeroLocationAoENearby.targetloc,nRadius)
		then
			J.SetReport("撤退使用技能",nCanHurtHeroLocationAoENearby.count);
			return BOT_ACTION_DESIRE_HIGH, nCanHurtHeroLocationAoENearby.targetloc;
		end
		
		if bot:GetActiveModeDesire() > 0.8 
		then
			local nEnemyNearby = bot:GetNearbyHeroes(800,true,BOT_MODE_NONE);
			for _,npcEnemy in pairs( nEnemyNearby )
			do
				if J.IsValid(npcEnemy)
					and bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) 
					and J.CanCastOnNonMagicImmune(npcEnemy)				
				then
					local nCastLocation = ( botLocation + npcEnemy:GetLocation() )/2;
					if not X.IsAbiltyQCastedHere(nCastLocation,nRadius) 
					then
						J.SetReport("对特定位置使用技能",npcEnemy:GetUnitName());
						return BOT_ACTION_DESIRE_HIGH, nCastLocation;
					end
				end
			end
		end
	end
	
	if #hEnemyHeroList == 0
		and nSkillLV >= 3
		and bot:GetActiveMode( ) ~= BOT_MODE_ATTACK
		and bot:GetActiveMode( ) ~= BOT_MODE_LANING
		and bot:GetMana() >= nKeepMana
		and #nEnemysLaneCreepsInSkillRange >= 2
		and nCanHurtCreepCount >= 5
		and ( nLV < 25 or nCanHurtCreepCount >= 7 )
		and ( nLV < 20 or GetUnitToLocationDistance(bot,nCanHurtCreepsLocationAoE.targetloc) >= 1100 )
		and not X.IsAbiltyQCastedHere(nCanHurtCreepsLocationAoE.targetloc,nRadius)
	then
		return BOT_ACTION_DESIRE_HIGH,nCanHurtCreepsLocationAoE.targetloc;
	end
	
	if J.IsFarming(bot) and bot:GetMana() >= nKeepMana
	then
		local nNeutralCreeps = bot:GetNearbyNeutralCreeps(800);
		if #nNeutralCreeps >= 4 
		   and J.IsValid(npcTarget)
		   and not J.CanKillTarget(npcTarget, bot:GetAttackDamage() * 3.88 , DAMAGE_TYPE_PHYSICAL)
		then
			local nAoE = bot:FindAoELocation( true, false, botLocation, nCastRange, nRadius, 0.8, 0);
			if nAoE.count >= 5 
			then
				return BOT_ACTION_DESIRE_HIGH,nAoE.targetloc;
			end
		end	
	end
	
	if  bot:GetActiveMode() == BOT_MODE_ROSHAN  
	then
	    local nAttackTarget = bot:GetAttackTarget();
		if  J.IsValid(nAttackTarget)
			and J.GetHPR(nAttackTarget) > 0.5
			and J.IsInRange(nAttackTarget,bot,600)
			and not nAttackTarget:HasModifier("modifier_sniper_shrapnel_slow")
		    and not X.IsAbiltyQCastedHere(nAttackTarget:GetLocation(),nRadius)
		then
			local nAllies = bot:GetNearbyHeroes(800,false,BOT_MODE_ROSHAN);
			if #nAllies >= 4 
			then
				return BOT_ACTION_DESIRE_HIGH,nAttackTarget:GetLocation();
			end
		end
	end	

	return 0;
end

function X.ConsiderE()
	if not abilityE:IsFullyCastable() or bot:HasModifier("modifier_sniper_take_aim_bonus")  then return 0 end
	
	local nAttackRange = bot:GetAttackRange();
	local nSkillLV  = abilityE:GetLevel();
	local nSkillRange = nSkillLV *100;
	local nDamage = bot:GetAttackDamage();
	
	local npcTarget = J.GetProperTarget(bot);
	
	if J.IsValid(npcTarget)
		and (npcTarget:IsHero() or J.CanKillTarget(npcTarget, nDamage *2.28, DAMAGE_TYPE_PHYSICAL))
		and GetUnitToUnitDistance(bot,npcTarget) > nAttackRange + 50
		and GetUnitToUnitDistance(bot,npcTarget) < nAttackRange + nSkillRange + 50
	then
		return BOT_ACTION_DESIRE_HIGH;
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

function X.ConsiderR()
	
	if not abilityR:IsFullyCastable() then return 0 end
	
	local nCastRange   = abilityR:GetCastRange();
	local nCastPoint   = abilityR:GetCastPoint();
	local nAttackRange = bot:GetAttackRange();
	if nAttackRange > 1550 then nAttackRange = 1550 end
	local nDamage      = abilityR:GetAbilityDamage();
	local nDamageType  = DAMAGE_TYPE_MAGICAL;
	
	local nEnemysHerosCanSeen = GetUnitList(UNIT_LIST_ENEMY_HEROES);
	local nEnemysHerosInAttackRange = bot:GetNearbyHeroes(nAttackRange +50,true,BOT_MODE_NONE);
	
	local nTempTarget = nEnemysHerosInAttackRange[1];
	local nAttackTarget = J.GetProperTarget(bot)
	if J.IsValidHero(nAttackTarget)
	   and J.IsInRange(bot,nAttackTarget,nAttackRange +50)
	then nTempTarget = nAttackTarget end
	
	local nWeakestEnemyHeroInCastRange = X.GetWeakestUnitInRangeExRadius(nEnemysHerosCanSeen,nCastRange,nAttackRange -300,bot);
	local nChannelingEnemyHeroInCastRange = X.GetChannelingUnitInRange(nEnemysHerosCanSeen,nCastRange,bot);
	local castRTarget = nil;
	
	if J.IsValid(nWeakestEnemyHeroInCastRange)
	   and ( J.WillMagicKillTarget(bot, nWeakestEnemyHeroInCastRange, nDamage, nCastPoint)
			 or ( X.ShouldUseR(nTempTarget,nWeakestEnemyHeroInCastRange,nDamage) and (nLV >= 20 or bot:GetMana() > nKeepMana *1.28) ))
	then
		castRTarget = nWeakestEnemyHeroInCastRange;
		return BOT_ACTION_DESIRE_HIGH,castRTarget;
	end
	
	if J.IsValid(nChannelingEnemyHeroInCastRange)
		and not bot:IsInvisible()
		and not J.IsRetreating(bot)
	then
		castRTarget = nChannelingEnemyHeroInCastRange;
		return BOT_ACTION_DESIRE_HIGH,castRTarget;
	end	
	
	return 0;
end

function X.GetWeakestUnitInRangeExRadius(nUnits,nRange,nRadius,bot) 
	if nUnits[1] == nil then return nil end;
	
	local nAttackRange = bot:GetAttackRange();
	local nAttackDamage = bot:GetAttackDamage();
	local weakestUnit = nil;
	local weakestHealth = 9999;
	for _,unit in pairs(nUnits)
	do
		if  J.IsInRange(unit, bot, nRange)
			and not J.IsInRange(unit, bot, nRadius)
			and J.CanCastOnNonMagicImmune(unit)
			and not J.IsOtherAllyCanKillTarget(bot, unit)
			and unit:GetHealth() < weakestHealth
			and not unit:HasModifier("modifier_teleporting")
			and not ( J.IsInRange(unit, bot, nAttackRange) 
			          and J.CanKillTarget(unit,nAttackDamage,DAMAGE_TYPE_PHYSICAL))
		then
			weakestUnit = unit;
			weakestHealth = unit:GetHealth();
		end
	end
	
	return weakestUnit;
end

function X.GetChannelingUnitInRange(nUnits,nRange,bot)
	if nUnits[1] == nil then return nil end;
	
	local channelingUnit = nil;
	for _,unit in pairs(nUnits)
	do
		if  J.IsInRange(unit, bot, nRange)
			and not unit:IsMagicImmune()
			and unit:IsChanneling()
			and not ( unit:HasModifier("modifier_teleporting") 
			          and X.GetCastPoint(unit,bot) > J.GetModifierTime(unit,"modifier_teleporting"))
		then
			channelingUnit = unit;
			break;
		end
	end
	
	return channelingUnit;
end

function X.GetCastPoint(unit,bot)
		
		local nCastTime = abilityR:GetCastPoint();
		
		local nDist = GetUnitToUnitDistance(bot,unit);
		local nDistTime = nDist/2500;
		
		return nCastTime + nDistTime;
		
end

function X.IsAbiltyQCastedHere(nLoc,nRadius)

    if lastAbilityQTime < DotaTime() -10 
	   or J.GetLocationToLocationDistance(lastAbilityQLocation,nLoc) > nRadius *1.14
	then
		return false;
	end

	return true;
end

function X.ShouldUseR(nAttackTarget,nEnemy,nDamage)
	if J.IsRetreating(bot)
	   or ( J.IsValidHero(nAttackTarget) and J.CanBeAttacked(nAttackTarget)
			 and ( GetUnitToUnitDistance(bot,nAttackTarget) <= bot:GetAttackRange() -300 
					or J.CanKillTarget(nAttackTarget,bot:GetAttackDamage(),DAMAGE_TYPE_PHYSICAL) ) )
	then
		return false;
	end
	
	if J.IsValid(nEnemy)
	then
		local numPlayer =  GetTeamPlayers(GetTeam());
		for i = 1, #numPlayer
		do
			local member =  GetTeamMember(i);
			if J.IsValid(member) 
				and member ~= bot
				and GetUnitToUnitDistance(member,nEnemy) <= 600
				and ( member:IsFacingLocation(nEnemy:GetLocation(),20)
						or not (J.IsValidHero(nAttackTarget) and GetUnitToUnitDistance(bot,nAttackTarget) <= bot:GetAttackRange()))
			then
				return true;
			end
			
			if J.IsValid(member)
				and member:GetUnitName() == "npc_dota_hero_zuus"
				and not J.CanNotUseAbility(member)
			then
				local zAbility = member:GetAbilityByName("zuus_thundergods_wrath");
				if zAbility:IsFullyCastable()
				then
					local zAbilityDamage = zAbility:GetAbilityDamage();
					if nEnemy:GetHealth() +66 < nEnemy:GetActualIncomingDamage(zAbilityDamage + nDamage, DAMAGE_TYPE_MAGICAL)
					then
						return true;
					end
				end
			end
		end
	end
	
	return false;
end


return X
-- dota2jmz@163.com QQ:2462331592
