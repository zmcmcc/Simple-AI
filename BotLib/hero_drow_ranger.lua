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
		['Ability'] = {1,3,2,1,1,6,1,2,2,2,6,3,3,3,6},
		--装备
		['Buy'] = {
			sOutfit,
			'item_dragon_lance', 
			'item_yasha', 
			'item_mask_of_madness',
			"item_ultimate_scepter",
			"item_manta",
			"item_hurricane_pike",	
			"item_broken_satanic",
			"item_butterfly",
		},
		--出售
		['Sell'] = {
			"item_hurricane_pike",
			"item_magic_wand",
		},
	},{
		--组合说明，不影响游戏
		['info'] = 'By Misunderstand',
		--天赋树
		['Talent'] = {
			['t25'] = {0, 10},
			['t20'] = {10, 0},
			['t15'] = {10, 10},
			['t10'] = {10, 10},
		},
		--技能
		['Ability'] = { 3, 1, 3, 2, 3, 6, 3, 1, 1, 1, 6, 2, 2, 2, 6 },
		--装备
		['Buy'] = {
			"item_faerie_fire",
			"item_double_slippers",
			"item_circlet",
			"item_tango",
			"item_flask",
			"item_magic_stick",
			"item_double_wraith_band",
			"item_power_treads",
			"item_dragon_lance",
			"item_invis_sword",
			"item_lifesteal",
			"item_ultimate_scepter",
			"item_maelstrom",
			"item_black_king_bar",
			"item_mjollnir",
			"item_silver_edge",
			"item_hurricane_pike",
			"item_ultimate_scepter_2",
			"item_satanic",
			"item_butterfly",
			"item_moon_shard"
		},
		--出售
		['Sell'] = {
			"item_lifesteal",     
			"item_magic_stick",

			"item_black_king_bar",     
			"item_wraith_band",
						
			"item_butterfly",
			"item_black_king_bar"
		},
	},{
		--组合说明，不影响游戏
		['info'] = 'By 铅笔会有猫的w',
		--天赋树
		['Talent'] = {
			['t25'] = {0, 10},
			['t20'] = {0, 10},
			['t15'] = {10, 0},
			['t10'] = {10, 0},
		},
		--技能
		['Ability'] = { 1, 2, 1, 3, 1, 6, 1, 3, 2, 2, 6, 2, 3, 3, 6 },
		--装备
		['Buy'] = {
			"item_circlet",
			"item_double_branches",
			"item_double_tango",
			"item_flask",
			"item_magic_wand",
			"item_boots",
			"item_double_wraith_band",
			"item_power_treads",
			"item_dragon_lance",
			"item_invis_sword",
			"item_mask_of_madness",
			"item_manta",
			"item_butterfly",
			"item_satanic",
			"item_black_king_bar",
			"item_bloodthorn", 
			"item_ultimate_scepter",
			"item_ultimate_scepter_2",
			"item_moon_shard",
		},
		--出售
		['Sell'] = {
			"item_black_king_bar",    
			"item_power_treads",

			"item_bloodthorn",   
			"item_dragon_lance",

			"item_butterfly",   
			"item_magic_wand",
					
			"item_mask_of_madness",  
			"item_wraith_band",
					
			"item_manta",  
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
		['t15'] = {0, 10},
		['t10'] = {0, 10},
	},
	--技能
	['Ability'] = {1,3,2,1,1,6,1,2,2,2,6,3,3,3,6},
	--装备
	['Buy'] = {
		sOutfit,
		'item_dragon_lance', 
		'item_yasha', 
		'item_mask_of_madness',
		"item_ultimate_scepter",
		"item_manta",
		"item_hurricane_pike",	
		"item_broken_satanic",
		"item_butterfly",
	},
	--出售
	['Sell'] = {
		"item_hurricane_pike",
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
		Minion.IllusionThink(hMinionUnit)
	end

end

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityM = nil


local castQDesire, castQTarget
local castWDesire, castWLocation
local castEDesire
local castMDesire
local castWMDesire,castWMLocation


local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;



function X.SkillsComplement()

	
	J.ConsiderForMkbDisassembleMask(bot);
	
	
	
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
	
	
	
	nKeepMana = 90
	aetherRange = 0
	talentDamage = 0
	nMP = bot:GetMana()/bot:GetMaxMana();
	nHP = bot:GetHealth()/bot:GetMaxHealth();
	nLV = bot:GetLevel();
	hEnemyHeroList = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	abilityM = J.IsItemAvailable("item_mask_of_madness");		

	
	
	
	castEDesire = X.ConsiderE();
	if castEDesire > 0
	then
		bot:Action_ClearActions(false);
	
	    bot:ActionQueue_UseAbility( abilityE );
		return ;
	end	
	
	
	castWMDesire,castWMLocation = X.ConsiderWM();
	if castWMDesire > 0
	then
	
		J.SetQueuePtToINT(bot, true)
	
		bot:ActionQueue_UseAbilityOnLocation( abilityW , castWMLocation);
		bot:ActionQueue_UseAbility( abilityM );
		return;
		
	end
	
	castWDesire, castWLocation = X.ConsiderW();
	if castWDesire > 0
	then
	
		J.SetQueuePtToINT(bot, true)
	
		bot:ActionQueue_UseAbilityOnLocation( abilityW , castWLocation);
		return;
	end
	
	castMDesire = X.ConsiderM();
	if castMDesire > 0
	then
		J.SetQueuePtToINT(bot, true)
	
	    bot:ActionQueue_UseAbility( abilityM );
		return ;
	end
	
	castQDesire, castQTarget = X.ConsiderQ();
	if castQDesire > 0
	then
	
		bot:Action_ClearActions(false);
	
		bot:ActionQueue_UseAbilityOnEntity( abilityQ , castQTarget);
		return 
		
	end	

end

function X.ConsiderE()
	if abilityE:IsFullyCastable() 
		and nLV >= 9
	then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return BOT_ACTION_DESIRE_NONE
end


function X.ConsiderWM()

	if nLV < 15
	   or abilityM == nil
	   or not abilityM:IsFullyCastable()
	   or not abilityW:IsFullyCastable() 
	   or not abilityQ:GetAutoCastState()
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local abilityWCost  = abilityW:GetManaCost();
	local abilityMCost  = abilityM:GetManaCost();
	
	if abilityMCost + abilityWCost > bot:GetMana() then return 0; end
	
	local nCastRange = abilityW:GetCastRange();
	local nCastPoint = abilityW:GetCastPoint();
	local nRadius 	 = abilityW:GetAOERadius();
	
	local nEnemysHeroesInView  = hEnemyHeroList;
	local nEnemysHeroesNearBy = bot:GetNearbyHeroes(500,true,BOT_MODE_NONE);
	
	local npcTarget = J.GetProperTarget(bot);
	
	if J.IsGoingOnSomeone(bot)
	   and #nEnemysHeroesNearBy == 0
	   and not J.IsEnemyTargetUnit(1600,bot)
	   and J.GetAllyCount(bot,1000) >= 3
	then
		
		if J.IsValidHero(npcTarget) 
			and not npcTarget:IsSilenced()
			and not J.IsDisabled(true, npcTarget)
			and J.CanCastOnNonMagicImmune(npcTarget) 
			and J.IsInRange(npcTarget, bot, nCastRange)
			and npcTarget:IsFacingLocation(bot:GetLocation(),150)
			and J.IsAllyHeroBetweenAllyAndEnemy(bot, npcTarget, npcTarget:GetLocation(), 500)
		then		
			nTargetLocation = npcTarget:GetExtrapolatedLocation( nCastPoint )
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation;
		end
		
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			nTargetLocation = locationAoE.targetloc;
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation;
		end
		
	end
	
	
	return BOT_ACTION_DESIRE_NONE;
	
end


function X.ConsiderW()

	if not abilityW:IsFullyCastable() 
	   or bot:IsInvisible()
	then
		return BOT_ACTION_DESIRE_NONE
	end

	local nCastRange = abilityW:GetCastRange();
	local nRadius 	 = abilityW:GetAOERadius();
	local nDamage 	 = 0
	local nCastPoint = abilityW:GetCastPoint();
	local nTargetLocation = nil;
	
	local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange +100,true,BOT_MODE_NONE)

	
	for _,npcEnemy in pairs( nEnemyHeroes )
	do
		if  J.IsValid(npcEnemy)
			and npcEnemy:IsChanneling()  
			and not npcEnemy:HasModifier("modifier_teleporting") 
			and not npcEnemy:HasModifier("modifier_boots_of_travel_incoming")
		then
			nTargetLocation = npcEnemy:GetLocation();
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation;
		end
	end
	
	
	local skThere, skLoc = J.IsSandKingThere(bot, nCastRange, 2.0);	
	if skThere then
		nTargetLocation = skLoc;
		return BOT_ACTION_DESIRE_HIGH, nTargetLocation;
	end	
	
	
	if bot:GetActiveMode() == BOT_MODE_RETREAT 
	then
			
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange-100, nRadius, nCastPoint, 0 );
		if locationAoE.count >= 2 
		   or (locationAoE.count >= 1 and bot:GetHealth()/bot:GetMaxHealth() < 0.5 ) 
		then
			nTargetLocation = locationAoE.targetloc;
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation;
		end
		
		
		for _,npcEnemy in pairs( nEnemyHeroes )
		do
			if  J.IsValid(npcEnemy)
			    and bot:WasRecentlyDamagedByHero( npcEnemy, 5.0 ) 
				and GetUnitToUnitDistance(bot,npcEnemy) <= 510 
			then
				nTargetLocation = npcEnemy:GetExtrapolatedLocation( nCastPoint );
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation;
			end
		end
	end
	
	
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = J.GetProperTarget(bot);
		if J.IsValidHero(npcTarget) 
			and J.CanCastOnNonMagicImmune(npcTarget) 
			and J.IsInRange(npcTarget, bot, nCastRange)
		    and not npcTarget:IsSilenced()
			and not J.IsDisabled(true, npcTarget)
			and ( npcTarget:IsFacingLocation(bot:GetLocation(),120) 
				  or npcTarget:GetAttackTarget() ~= nil )
		then		
			nTargetLocation = npcTarget:GetExtrapolatedLocation( nCastPoint )
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation;
		end
		
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			nTargetLocation = locationAoE.targetloc;
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation;
		end
		
	end
	
	return BOT_ACTION_DESIRE_NONE,nil
end


function X.ConsiderM()
	
	if abilityM == nil or not abilityM:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE end;

	-- Get some of its values
	local nCastRange = bot:GetAttackRange();
	local nAttackDamage = bot:GetAttackDamage();
	local nDamage = nAttackDamage;
	local nDamageType = DAMAGE_TYPE_PHYSICAL;
	local npcTarget = J.GetProperTarget(bot);
	--------------------------------------
	-- Mode based usage
	--------------------------------------	
	
	--If we're going after someone
	if J.IsGoingOnSomeone(bot) 
	   and #hEnemyHeroList == 1
	then
		if J.IsValidHero(npcTarget) 
		   and J.CanBeAttacked(npcTarget)
		   and J.CanCastOnNonMagicImmune(npcTarget) 
		   and not J.IsInRange(npcTarget, bot, 400)
		   and J.IsInRange(npcTarget, bot, nCastRange + 300)
		   and bot:IsFacingLocation(npcTarget:GetLocation(),30)
		   and not npcTarget:IsFacingLocation(bot:GetLocation(),30)
		   and abilityQ:GetAutoCastState() == true 
		   and abilityW:GetCooldownTimeRemaining() > 5.0 
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	--撤退时更快的跑路
	
	if J.IsRunning(bot) or #hEnemyHeroList > 0 then return BOT_ACTION_DESIRE_NONE; end
	
	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		if  J.IsRoshan(npcTarget) 
		    and J.IsInRange(npcTarget, bot, nCastRange + 99) 
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	if  J.IsValidBuilding(npcTarget) 
	    and J.IsInRange(npcTarget, bot, nCastRange + 199)  
	then
		return BOT_ACTION_DESIRE_LOW;
	end	
	
	if  ( J.IsPushing(bot) or J.IsDefending(bot) or J.IsFarming(bot))
	then
		local nCreeps = bot:GetNearbyCreeps(800,true);
		if J.IsValid(npcTarget)
			and J.IsInRange(npcTarget,bot,nCastRange + 99)
			and ( #nCreeps > 1 or npcTarget:GetHealth() > nAttackDamage * 2.28 )
		then
			return BOT_ACTION_DESIRE_HIGH;
		end	
	end
	
	return BOT_ACTION_DESIRE_NONE;
	
end


local lastAutoTime = 0;
function X.ConsiderQ()
	
	if not abilityQ:IsFullyCastable()
		or bot:IsInvisible()
		or bot:IsDisarmed()
		or J.GetDistanceFromEnemyFountain(bot) < 800
	then
		return BOT_ACTION_DESIRE_NONE,nil
	end
	
	local nAttackRange = bot:GetAttackRange() + 40;
	local nAttackDamage = bot:GetAttackDamage();
	
	local nTowers = bot:GetNearbyTowers(900,true)
	local nEnemysLaneCreepsInRange = bot:GetNearbyLaneCreeps(nAttackRange + 30,true)
	local nEnemysLaneCreepsNearby = bot:GetNearbyLaneCreeps(400,true)
	local nEnemysWeakestLaneCreepsInRange = J.GetAttackableWeakestUnit(false, true, nAttackRange + 30, bot)
	local nEnemysWeakestLaneCreepsInRangeHealth = 10000
	if(nEnemysWeakestLaneCreepsInRange ~= nil)
	then
	    nEnemysWeakestLaneCreepsInRangeHealth = nEnemysWeakestLaneCreepsInRange:GetHealth();
	end
	
	local nEnemysHeroesInAttackRange = bot:GetNearbyHeroes(nAttackRange,true,BOT_MODE_NONE);
	local nInAttackRangeWeakestEnemyHero = J.GetAttackableWeakestUnit(true, true, nAttackRange, bot);
	local nInViewWeakestEnemyHero = J.GetAttackableWeakestUnit(true, true, 800, bot);

	local nAlleyLaneCreeps = bot:GetNearbyLaneCreeps(330,false);
	local npcTarget = J.GetProperTarget(bot)
	local nTargetUint = nil;
	local npcMode = bot:GetActiveMode();
	
	
	if nLV >= 10 
	then
		if hEnemyHeroList[1] ~= nil
			and not abilityQ:GetAutoCastState()
		then
			lastAutoTime = DotaTime();
			abilityQ:ToggleAutoCast();
		elseif hEnemyHeroList[1] == nil
				and lastAutoTime + 3.0 < DotaTime()
				and abilityQ:GetAutoCastState()
			then
				abilityQ:ToggleAutoCast()
	    end
	else
		if  abilityQ:GetAutoCastState( ) 
		then
			abilityQ:ToggleAutoCast()
		end
	end	
	
	if nLV <= 9 
	   and not J.IsRunning(bot)
	   and nHP > 0.55
	then
		if  J.IsValidHero(npcTarget)
			and GetUnitToUnitDistance(bot,npcTarget) < nAttackRange + 99
		then
			nTargetUint = npcTarget;
			return BOT_ACTION_DESIRE_HIGH, nTargetUint;
		end	
	end
	
	
	if npcMode == BOT_MODE_LANING
		and #nTowers == 0
	then
		
		if J.IsValid(nInAttackRangeWeakestEnemyHero)
		then
			if nEnemysWeakestLaneCreepsInRangeHealth > 130
				and nHP >= 0.6 
				and #nEnemysLaneCreepsNearby <= 3 
				and #nAlleyLaneCreeps >= 2
				and not bot:WasRecentlyDamagedByCreep(1.5)
				and not bot:WasRecentlyDamagedByAnyHero(1.5)
			then
				nTargetUint = nInAttackRangeWeakestEnemyHero;
				return BOT_ACTION_DESIRE_HIGH, nTargetUint;
			end
		end
		
		
		if J.IsValid(nInViewWeakestEnemyHero)
		then
			if nEnemysWeakestLaneCreepsInRangeHealth > 180
				and nHP >= 0.7 
				and #nEnemysLaneCreepsNearby <= 2 
				and #nAlleyLaneCreeps >= 3
				and not bot:WasRecentlyDamagedByCreep(1.5)
				and not bot:WasRecentlyDamagedByAnyHero(1.5)
				and not bot:WasRecentlyDamagedByTower(1.5)
			then
				nTargetUint = nInViewWeakestEnemyHero;
				return BOT_ACTION_DESIRE_HIGH, nTargetUint;
			end
			
			if J.GetUnitAllyCountAroundEnemyTarget(nInViewWeakestEnemyHero , 500) >= 4
				and not bot:WasRecentlyDamagedByCreep(1.5)
				and not bot:WasRecentlyDamagedByAnyHero(1.5)
				and not bot:WasRecentlyDamagedByTower(1.5)
			    and nHP >= 0.6 
			then
				nTargetUint = nInViewWeakestEnemyHero;
				return BOT_ACTION_DESIRE_HIGH, nTargetUint;
			end			
		end		
	end
	
	
	if npcTarget ~= nil
		and npcTarget:IsHero()
		and GetUnitToUnitDistance(npcTarget,bot) >  nAttackRange + 160
		and J.IsValid(nInAttackRangeWeakestEnemyHero)
		and not nInAttackRangeWeakestEnemyHero:IsAttackImmune()
	then
		nTargetUint = nInAttackRangeWeakestEnemyHero;
		bot:SetTarget(nTargetUint);
		return BOT_ACTION_DESIRE_HIGH, nTargetUint;
	end
	
	
	if bot:HasModifier("modifier_item_hurricane_pike_range")
		and J.IsValid(npcTarget)
	then
		nTargetUint = npcTarget;
		return BOT_ACTION_DESIRE_HIGH, nTargetUint;	
	end
	
	
	if  bot:GetAttackTarget() == nil 
		and  bot:GetTarget() == nil
		and  #hEnemyHeroList == 0
		and  npcMode ~= BOT_MODE_RETREAT
		and  npcMode ~= BOT_MODE_ATTACK 
		and  npcMode ~= BOT_MODE_ASSEMBLE
		and  npcMode ~= BOT_MODE_FARM
		and  npcMode ~= BOT_MODE_TEAM_ROAM
		and  J.GetTeamFightAlliesCount(bot) < 3
		and  bot:GetMana() >= 180
		and  not bot:WasRecentlyDamagedByAnyHero(3.0) 
	then		
		
        if bot:HasScepter()
		then
			local nEnemysCreeps = bot:GetNearbyCreeps(1600,true)
			if J.IsValid(nEnemysCreeps[1])
			then
				nTargetUint = nEnemysCreeps[1];
				return BOT_ACTION_DESIRE_HIGH, nTargetUint;
			end
		end
			
		local nNeutralCreeps = bot:GetNearbyNeutralCreeps(1600)
		if npcMode ~= BOT_MODE_LANING
			and nLV >= 6  
			and nHP > 0.25
			and J.IsValid(nNeutralCreeps[1])
			and not J.IsRoshan(nNeutralCreeps[1])
			and (nNeutralCreeps[1]:IsAncientCreep() == false or nLV >= 12)
		then
			nTargetUint = nNeutralCreeps[1];
			return BOT_ACTION_DESIRE_HIGH, nTargetUint;
		end
		
		
		local nLaneCreeps = bot:GetNearbyLaneCreeps(1600,true)
		if npcMode ~= BOT_MODE_LANING
			and nLV >= 6  
			and nHP > 0.25
			and J.IsValid(nLaneCreeps[1])
			and bot:GetAttackDamage() > 130
		then
			nTargetUint = nLaneCreeps[1]; 
			return BOT_ACTION_DESIRE_HIGH, nTargetUint;
		end
	end
	
	
	if npcMode == BOT_MODE_RETREAT
	then
		
		nDistance = 999
		local nTargetUint = nil
	    for _,npcEnemy in pairs( nEnemysHeroesInAttackRange )
		do
			if  J.IsValid(npcEnemy)
				and npcEnemy:HasModifier("modifier_drowranger_wave_of_silence_knockback") 
				and GetUnitToUnitDistance(npcEnemy,bot) < nDistance
			then
				nTargetUint = npcEnemy;
				nDistance = GetUnitToUnitDistance(npcEnemy,bot);	
			end
		end		
		
		if nTargetUint ~= nil
		   and not nTargetUint:HasModifier("modifier_drow_ranger_frost_arrows_slow")
		then
			return BOT_ACTION_DESIRE_HIGH, nTargetUint;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end


return X
-- dota2jmz@163.com QQ:2462331592
