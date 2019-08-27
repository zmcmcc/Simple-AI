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
			['t10'] = {10, 0},
		},
		--技能
		['Ability'] = {1,3,1,3,1,6,1,2,2,2,6,2,3,3,6},
		--装备
		['Buy'] = {
			sOutfit,
			"item_dragon_lance",
			"item_desolator",
			"item_black_king_bar",
			"item_hurricane_pike",
			"item_satanic",
			"item_lesser_crit",
			"item_bloodthorn",
		},
		--出售
		['Sell'] = {
			"item_black_king_bar",
			"item_urn_of_shadows",
			
			'item_satanic',
			'item_magic_wand',
		},
	},{
		--组合说明，不影响游戏
		['info'] = 'By Misunderstand',
		--天赋树
		['Talent'] = {
			['t25'] = {0, 10},
			['t20'] = {0, 10},
			['t15'] = {10, 0},
			['t10'] = {10, 0},
		},
		--技能
		['Ability'] = { 3, 1, 1, 3, 2, 6, 1, 1, 2, 2, 6, 3, 2, 3, 6 },
		--装备
		['Buy'] = {
			"item_faerie_fire",
			"item_double_slippers",
			"item_double_circlet",
			"item_tango",
			"item_bottle",
			"item_double_wraith_band",
			"item_power_treads",
			"item_desolator",
			"item_blink",
			"item_black_king_bar", 
			"item_nullifier",
			"item_monkey_king_bar",
			"item_ultimate_scepter",
			"item_greater_crit",
			"item_ultimate_scepter_2",
			"item_moon_shard",
			"item_travel_boots",
			"item_travel_boots_2"
		},
		--出售
		['Sell'] = {
			"item_black_king_bar",
			"item_wraith_band",
					
			"item_nullifier",
			"item_bottle",

			"item_ultimate_scepter",
			"item_blink",

			"item_travel_boots",
			"item_power_treads"
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
		['Ability'] = { 1, 3, 1, 3, 1, 2, 1, 6, 3, 2, 6, 2, 2, 3, 6 },
		--装备
		['Buy'] = {
			"item_circlet",
			"item_slippers",
			"item_double_branches",
			"item_double_tango",
			"item_double_flask",
			"item_wraith_band",
			"item_power_treads",
			"item_magic_wand",
			"item_bottle", 
			"item_desolator",
			"item_dragon_lance",
			"item_black_king_bar",
			"item_butterfly",
			"item_monkey_king_bar",
			"item_bloodthorn", 
			"item_travel_boots",
			"item_moon_shard",
			"item_ultimate_scepter",
			"item_ultimate_scepter_2",
			"item_travel_boots_2",
		},
		--出售
		['Sell'] = {
			"item_travel_boots",
			"item_power_treads",

			"item_monkey_king_bar",
			"item_dragon_lance",

			"item_butterfly",
			"item_bottle",

			"item_lesser_crit",
			"item_magic_wand",
					
			"item_black_king_bar",
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
		['t10'] = {10, 0},
	},
	--技能
	['Ability'] = {1,3,1,3,1,6,1,2,2,2,6,2,3,3,6},
	--装备
	['Buy'] = {
		sOutfit,
		"item_dragon_lance",
		"item_desolator",
		"item_black_king_bar",
		"item_hurricane_pike",
		"item_satanic",
		"item_lesser_crit",
		"item_bloodthorn",
	},
	--出售
	['Sell'] = {
		"item_black_king_bar",
		"item_urn_of_shadows",
		
		'item_satanic',
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
		if hMinionUnit:GetUnitName() ~=  "npc_dota_templar_assassin_psionic_trap" 
		then
			Minion.IllusionThink(hMinionUnit)
			return;
		else
			local abilitySTP = hMinionUnit:GetAbilityByName( "templar_assassin_self_trap" );
			local abilityTP = bot:GetAbilityByName( "templar_assassin_trap" );
			local nRadius = abilitySTP:GetSpecialValueInt("trap_radius");
			local nRange = bot:GetAttackRange();
			local nEnemies = hMinionUnit:GetNearbyHeroes(nRadius - 12, true, BOT_MODE_NONE);
			local nEnemyLaneCreepsNear = hMinionUnit:GetNearbyLaneCreeps(nRadius - 88, true);
			local nAllies = hMinionUnit:GetNearbyHeroes(800, false, BOT_MODE_NONE);
			local nEnemyNearby = hMinionUnit:GetNearbyHeroes(1200, true, BOT_MODE_NONE);
			local distance = GetUnitToUnitDistance(bot, hMinionUnit);
			if not bot:IsAlive() then distance = 9999 end;
			
			if abilitySTP:IsFullyCastable() 
			then
				if ( #nEnemies >= 1 ) 
				   and ( distance < 1200 or #nAllies >= 1 or X.IsEnemyRegenning(nEnemies)) 			   
				then
					hMinionUnit:Action_UseAbility( abilitySTP );
					return; 
				end
				
				if hMinionUnit:GetHealth()/hMinionUnit:GetMaxHealth() < 0.6
					or ( nEnemyNearby[1] ~= nil	and nEnemyNearby[1]:IsAlive() and nEnemyNearby[1]:GetAttackTarget() == hMinionUnit )
				then
					hMinionUnit:Action_UseAbility( abilitySTP );
					return; 
				end
				
				if #nEnemyLaneCreepsNear >= 4
					and #nAllies == 0
				then
					for _,creep in pairs(nEnemyLaneCreepsNear)
					do
						if creep:IsAlive()
						   and string.find(creep:GetUnitName(), "ranged") ~= nil 
						then
							hMinionUnit:Action_UseAbility( abilitySTP );
							return; 
						end
					end
				end
				
				local incProj = hMinionUnit:GetIncomingTrackingProjectiles()
				for _,p in pairs(incProj)
				do
					if p.is_attack
					   and GetUnitToLocationDistance(hMinionUnit, p.location) < nRadius
					then
						hMinionUnit:Action_UseAbility( abilitySTP );
						return; 
					end
				end
				
			end
		end

	end

end

function X.IsEnemyRegenning(nEnemies)

	for _,enemy in pairs(nEnemies)
	do
		if enemy ~= nil and enemy:CanBeSeen() and enemy:IsAlive()
			and ( 	enemy:GetHealth() < 240
					or enemy:HasModifier("modifier_clarity_potion")
					or enemy:HasModifier("modifier_bottle_regeneration")
					or enemy:HasModifier("modifier_rune_regen")
					or enemy:HasModifier("modifier_item_urn_heal")
					or enemy:HasModifier("modifier_item_spirit_vessel_heal") )
		then
			return true;
		end
	end

	return false;

end

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )

local castQDesire
local castWDesire
local castRDesire,castRLocation
local roshanLoc = nil;
local midLoc = nil;
local topLoc = nil;
local botLoc = nil;
local ListRune = {
	RUNE_BOUNTY_1,
	RUNE_BOUNTY_2,
	RUNE_BOUNTY_3,
	RUNE_BOUNTY_4,
	RUNE_POWERUP_1,
	RUNE_POWERUP_2
}
local runeLocCheckTime = 0;
local ListRuneLoc = {};
local ListCampLoc = {};

local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;


function X.SkillsComplement()

	
	
	X.TAConsiderTarget();
	
	
	
	if J.CanNotUseAbility(bot) or bot:HasModifier('modifier_templar_assassin_meld') then return end
	
	
	
	nKeepMana = 300
	nLV = bot:GetLevel();
	nMP = bot:GetMana()/bot:GetMaxMana();
	nHP = bot:GetHealth()/bot:GetMaxHealth();
	hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	if midLoc == nil 
	then 
		local opMidTower1 = GetTower(GetOpposingTeam(),TOWER_MID_1);
		local myMidTower1 = GetTower(GetTeam(),TOWER_MID_1);
		midLoc = J.GetUnitTowardDistanceLocation(opMidTower1,myMidTower1,928);
		topLoc = GetTower(GetTeam(),TOWER_TOP_1):GetLocation();
		botLoc = GetTower(GetTeam(),TOWER_BOT_1):GetLocation();
	end
	
	
	
		
	castRDesire, castRLocation = X.ConsiderR();
	if ( castRDesire > 0 )
	then
		J.SetQueuePtToINT(bot, false)
	
		bot:ActionQueue_UseAbilityOnLocation( abilityR, castRLocation );
		return;	
	end
	
	castQDesire = X.ConsiderQ();
	if ( castQDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, false)
	
		bot:ActionQueue_UseAbility( abilityQ );
		return;	
		
	end
	
	castWDesire = X.ConsiderW();
	if ( castWDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, false)
	
		bot:ActionQueue_UseAbility( abilityW );
		return;	

	end	

end


function X.ConsiderQ()

	-- Make sure it's castable
	if ( not abilityQ:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end

	-- Get some of its values
	local nRange = bot:GetAttackRange();
	local nAttackDamage = bot:GetAttackDamage();
	local nDamage = abilityQ:GetSpecialValueInt( "bonus_damage" );
	local nTotalDamage = nAttackDamage + nDamage;
	local nDamageType  = DAMAGE_TYPE_PHYSICAL;
	local nSkillLV = abilityQ:GetLevel();
	local nManaCost = abilityQ:GetManaCost();

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( bot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) and ( nLV > 10 or npcEnemy:GetUnitName() ~= "npc_dota_hero_necrolyte" ) )
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	if nHP < 0.11 and not bot:IsInvisible()
	   and ( bot:WasRecentlyDamagedByAnyHero(4.0) 
	         or bot:WasRecentlyDamagedByCreep(2.0)
			 or bot:WasRecentlyDamagedByTower(2.0) )			 
	then
		return BOT_ACTION_DESIRE_MODERATE;
	end
	
	--对线期间的使用
	if bot:GetActiveMode() == BOT_MODE_LANING or nLV <= 7
	then
		local nLaneCreeps = bot:GetNearbyLaneCreeps(800,true);
		if nMP > 0.28 and #nLaneCreeps >= 4
		then
			for _,creep in pairs(nLaneCreeps)
			do
				if J.IsValid(creep)
					and not creep:HasModifier("modifier_fountain_glyph")
					and J.IsInRange(bot,creep,nRange + 300)
					and J.CanKillTarget(creep,nTotalDamage,nDamageType)
				then
					return BOT_ACTION_DESIRE_MODERATE;
				end		
			end	
		end				
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot)
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) or nHP < 0.25 ) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	--格挡弹道
	if J.IsNotAttackProjectileIncoming(bot, 1600)
		or J.GetAttackProjectileDamageByRange(bot, 1600) >= 110
	then
		return BOT_ACTION_DESIRE_MODERATE;
	end
	
	--推进时对小兵输出
	if  (J.IsPushing(bot) or J.IsDefending(bot) or J.IsFarming(bot))
	    and J.IsAllowedToSpam(bot, nManaCost)
		and nSkillLV >= 3
	then
		local nLaneCreeps = bot:GetNearbyLaneCreeps(1600,true);
		if #nLaneCreeps >= 2
		then
			local targetCreep = J.GetMostHpUnit(nLaneCreeps);
			if J.IsValid(targetCreep)
				and ( targetCreep:GetHealth() >= 400 or #nLaneCreeps >= 5)
				and not targetCreep:HasModifier("modifier_fountain_glyph")
			then
				return BOT_ACTION_DESIRE_HIGH;
			end					
		end
	end
	
	--发育时对野怪输出
	if J.IsFarming(bot) and nSkillLV >= 2
	   and (bot:GetAttackDamage() < 200 or nMP > 0.49)
	   and nMP > 0.3
	then
		local nNeutralCreeps = bot:GetNearbyNeutralCreeps(800);
		if #nNeutralCreeps >= 2
		then
			local targetCreep = J.GetMostHpUnit(nNeutralCreeps);
			if J.IsValid(targetCreep)
				and ( targetCreep:GetHealth() >= 400 or #nNeutralCreeps >= 3 )
				and J.IsInRange(targetCreep,bot,nRange +50)
			then
				return BOT_ACTION_DESIRE_HIGH;
			end					
		end
	end
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot) and nSkillLV >= 2
	then
		local npcTarget = J.GetProperTarget(bot);
		if J.IsValidHero(npcTarget) 
		   and J.CanBeAttacked(npcTarget) 
		   and J.IsInRange(npcTarget, bot, 2000)
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end

		
	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = bot:GetAttackTarget();
		if ( J.IsRoshan(npcTarget) and J.GetHPR(npcTarget) > 0.3 and J.IsInRange(npcTarget, bot, nRange)  )
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	--通用的
	if nLV >= 12 and bot:GetMana() > 325
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes(800,true,BOT_MODE_NONE);
		local tableNearbyEnemyCreeps = bot:GetNearbyLaneCreeps(1600,true);
		local tableNearbyEnemyTowers = bot:GetNearbyTowers(1600,true);
		if #tableNearbyEnemyHeroes > 0 
			or #tableNearbyEnemyTowers > 0
			or #tableNearbyEnemyCreeps > 1
			or ( J.IsInEnemyArea(bot) and nMP > 0.95 )
		then
			return  BOT_ACTION_DESIRE_LOW;
		end		
	end
	
	return BOT_ACTION_DESIRE_NONE;

end


function X.ConsiderW()

	-- Make sure it's castable
	local nEnemyTowers = bot:GetNearbyTowers(888,true);
	if not abilityW:IsFullyCastable() 
	   or #nEnemyTowers > 0 
	   or bot:HasModifier("modifier_item_dustofappearance")
	then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	local proDmg = J.GetAttackProjectileDamageByRange(bot, 1600)
	if proDmg > bot:GetAttackDamage() * ( nLV % 10 + 1 )
	   or proDmg > bot:GetHealth() * 0.38 
	   or ( bot:IsDisarmed() and bot:GetActiveMode() ~= BOT_MODE_RETREAT )
	   or bot:IsRooted()
	then
		if not bot:IsInvisible()
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if J.IsRunning(bot) then return BOT_ACTION_DESIRE_NONE;	end

	-- Get some of its values
	local nSkillLV   = abilityW:GetLevel();
	local nManaCost  = abilityW:GetManaCost();
	local nCastRange = bot:GetAttackRange();
	local nAttackDamage = bot:GetAttackDamage();
	local nDamage = abilityW:GetSpecialValueInt( "bonus_damage" );
	local nDamageType = DAMAGE_TYPE_PHYSICAL;
	local nTotalDamage = nAttackDamage + nDamage;
	local nEnemyHeroInView = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = bot:GetAttackTarget();
		if ( J.IsRoshan(npcTarget) and J.IsInRange(npcTarget, bot, nCastRange + 40)  )
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetAttackTarget();
		if J.IsValidHero(npcTarget) 
		   and J.CanBeAttacked(npcTarget)
		   and J.IsInRange(npcTarget, bot, nCastRange + 64)
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
		npcTarget = bot:GetTarget();
		if J.IsValidHero(npcTarget) 
		   and J.CanBeAttacked(npcTarget)
		   and J.IsInRange(npcTarget, bot, nCastRange + 24)
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	--发育时对野怪输出
	if J.IsFarming(bot) 
	   and #nEnemyHeroInView == 0
	   and nMP > 0.28 + (4 - nSkillLV)/20
	then		
		local nCreeps = bot:GetNearbyNeutralCreeps(800);
		local targetCreep = bot:GetAttackTarget();
		if J.IsValid(targetCreep)
			and J.IsInRange(targetCreep,bot,nCastRange + 50)
			and targetCreep:GetHealth() >= ( nAttackDamage * 1.18 + nDamage ) 
			and ( #nCreeps > 1 or targetCreep:GetHealth() > nAttackDamage * 2.28 )
		then
			return BOT_ACTION_DESIRE_HIGH;
		end	
	end
	
	--推进时对小兵输出 待优化
	if  ( J.IsPushing(bot) or J.IsDefending(bot) or J.IsFarming(bot))
	    and J.IsAllowedToSpam(bot, nManaCost)
		and nSkillLV >= 3 and #nEnemyHeroInView == 0
	then
		local nLaneCreeps = bot:GetNearbyLaneCreeps(1200,true);
		local nAllyLaneCreeps = bot:GetNearbyLaneCreeps(800,false);
		if #nLaneCreeps >= 3
		then
			local targetCreep = bot:GetAttackTarget();
			if J.IsValid(targetCreep)
				and J.IsInRange(targetCreep,bot,nCastRange + 50)
				and not targetCreep:HasModifier("modifier_fountain_glyph")
				and not J.CanKillTarget(targetCreep,nAttackDamage * 1.2,nDamageType)
				and ( J.CanKillTarget(targetCreep,nTotalDamage * 1.2,nDamageType)
					  or #nAllyLaneCreeps <= 1 )
			then
				return BOT_ACTION_DESIRE_HIGH;
			end					
		end
	end
	
	--特殊用法之针对远程小兵
	local targetCreep = bot:GetAttackTarget()
	if J.IsValid(targetCreep)
	   and J.IsKeyWordUnit("ranged",targetCreep)
	   and not targetCreep:HasModifier("modifier_fountain_glyph")
	   and J.GetHPR(targetCreep) > 0.48
	   and J.IsInRange(targetCreep,bot,nCastRange + 40)
	   and not J.CanKillTarget(targetCreep,nAttackDamage * 1.2,nDamageType)
	   and J.CanKillTarget(targetCreep,nTotalDamage * 1.2,nDamageType)
	then
		return BOT_ACTION_DESIRE_HIGH;
	end	
	
	--通用的用法
	if nLV > 11 and bot:GetMana() > 280
	then
		local nAttackTarget = bot:GetAttackTarget();
		if J.IsValid(nAttackTarget)
			and J.IsInRange(nAttackTarget,bot,nCastRange + 50)
			and not J.CanKillTarget(nAttackTarget,nAttackDamage * 3.28,nDamageType)
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end


function X.ConsiderR()

	-- Make sure it's castable
	if ( not abilityR:IsFullyCastable() )
	then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	if #ListRuneLoc == 0
	then
		for i,r in pairs(ListRune)
		do
			local rLoc = GetRuneSpawnLocation(r);
			ListRuneLoc[i] = rLoc;
		end		
	end
	
	if #ListCampLoc == 0
	then
		local camps = GetNeutralSpawners();
		
		for i,camp in pairs(camps) 
		do			
			if camp.team == GetTeam() 
			   and camp.type ~= "small"
			   and camp.type ~= "medium"
			then
				ListCampLoc[i] = camp;
			end			
		end		
	end

	local nCastRange = abilityR:GetCastRange();
	local nCastPoint = abilityR:GetCastPoint();
	local nSkillLV   = abilityR:GetLevel();

	local creeps = bot:GetNearbyCreeps(1000, true)
	local enemyHeroes = bot:GetNearbyHeroes(600, true, BOT_MODE_NONE)
	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if  J.IsMoving(npcEnemy)
				and bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) 
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetExtrapolatedLocation(1.0);
			end
		end
	end

	-- If we're going after someone
	local numPlayer = GetTeamPlayers(GetTeam());
	for i = 1, #numPlayer
	do
		local member = GetTeamMember(i);
		if J.IsValid(member)
		   and J.IsGoingOnSomeone(member)
		then
			local npcTarget = J.GetProperTarget(member);
			if J.IsValidHero(npcTarget) 
			   and J.IsRunning(npcTarget)
			   and J.IsInRange(npcTarget, bot, nCastRange + 800) 
			   and not J.IsInRange(npcTarget, bot, bot:GetAttackRange()) 
			   and J.CanCastOnNonMagicImmune(npcTarget) 
			then
				
				local targetFutureLoc = npcTarget:GetExtrapolatedLocation(1.8);
				if GetUnitToLocationDistance(bot,targetFutureLoc) <= nCastRange + 50
					and npcTarget:GetMovementDirectionStability() > 0.95
					and IsLocationPassable(targetFutureLoc)
				then
					return BOT_ACTION_DESIRE_HIGH, targetFutureLoc;
				end
				
				targetFutureLoc = npcTarget:GetExtrapolatedLocation(0.8);
				if GetUnitToLocationDistance(bot,targetFutureLoc) <= nCastRange + 50
				   and npcTarget:GetMovementDirectionStability() > 0.9
				   and IsLocationPassable(targetFutureLoc)
				then
					return BOT_ACTION_DESIRE_HIGH, targetFutureLoc;
				end
				
				local targetLoc = npcTarget:GetLocation();
				if GetUnitToLocationDistance(bot,targetLoc) <= nCastRange + 50
				then
					return BOT_ACTION_DESIRE_HIGH, targetLoc;
				end
				
			end
		end
	end
	
	-- if near Special Location 
	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	if runeLocCheckTime < DotaTime() - 1.0
	   and #tableNearbyEnemyHeroes == 0 
	   and not bot:WasRecentlyDamagedByAnyHero(3.0)
	   and bot:GetActiveMode() ~= BOT_MODE_RETREAT
	then
		for i,loc in pairs(ListRuneLoc)
		do
			if GetUnitToLocationDistance(bot, loc) < nCastRange
			then
				if not IsLocationVisible(loc)
				then
					return BOT_ACTION_DESIRE_HIGH,loc;
				end			
			end
		end
		
		for i,loc in pairs(ListCampLoc)
		do
			if GetUnitToLocationDistance(bot, loc.location) < nCastRange
			   and nSkillLV >= 2
			   and ( loc.type ~= 'ancient' or nLV >= 15 )
			then
				if not IsLocationVisible(loc.location)
				then
					return BOT_ACTION_DESIRE_HIGH,loc.location;
				end			
			end
		end
		
		if midLoc ~= nil and nSkillLV >= 2
		then
			if GetUnitToLocationDistance(bot, midLoc) < nCastRange
				and not IsLocationVisible(midLoc)
			then
				return BOT_ACTION_DESIRE_HIGH,midLoc;
			end
		end
		
		if nSkillLV >= 3
		then
			-- if roshanLoc ~= nil 
			-- then
				-- if GetUnitToLocationDistance(bot, roshanLoc) < nCastRange
					-- and not IsLocationVisible(roshanLoc)
				-- then
					-- return BOT_ACTION_DESIRE_HIGH,roshanLoc;
				-- end
			-- end
			
			if topLoc ~= nil
			then
				if GetUnitToLocationDistance(bot, topLoc) < nCastRange
					and not IsLocationVisible(topLoc)
				then
					return BOT_ACTION_DESIRE_HIGH,topLoc;
				end
			end
			
			if botLoc ~= nil
			then
				if GetUnitToLocationDistance(bot, botLoc) < nCastRange
					and not IsLocationVisible(botLoc)
				then
					return BOT_ACTION_DESIRE_HIGH,botLoc;
				end
			end
		end
		
		runeLocCheckTime = DotaTime();
	end
	
	
	-- if roshan
	if bot:GetActiveMode() == BOT_MODE_ROSHAN and roshanLoc == nil
	then
		local npcTarget = J.GetProperTarget(bot);
		if J.IsRoshan(npcTarget) 
		then
			roshanLoc = npcTarget:GetLocation();
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end


function X.TAConsiderTarget()

	local bot = GetBot();
	
	if not J.IsRunning(bot) 
	   or bot:HasModifier("modifier_item_hurricane_pike_range")
	then return end
	
	local npcTarget = bot:GetAttackTarget();
	if not J.IsValidHero(npcTarget) then return end

	local nAttackRange = bot:GetAttackRange() + 40;	
	local nEnemyHeroInRange = bot:GetNearbyHeroes(nAttackRange,true,BOT_MODE_NONE);
	
	local nInAttackRangeNearestEnemyHero = nEnemyHeroInRange[1];

	if  J.IsValidHero(nInAttackRangeWeakestEnemyHero)
		and J.CanBeAttacked(nInAttackRangeWeakestEnemyHero)
		and ( GetUnitToUnitDistance(npcTarget,bot) > nAttackRange or J.HasForbiddenModifier(npcTarget) )		
	then
		bot:SetTarget(nInAttackRangeWeakestEnemyHero);
		return;
	end

end


return X
-- dota2jmz@163.com QQ:2462331592
