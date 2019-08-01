----------------------------------------------------------------------------------------------------
--- The Creation Come From: BOT EXPERIMENT Credit:FURIOUSPUPPY
--- BOT EXPERIMENT Author: Arizona Fauzie 2018.11.21
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=837040016
--- Update by: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
----------------------------------------------------------------------------------------------------
local X = {}
local npcBot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local minion = dofile( GetScriptDirectory()..'/FunLib/Minion')
local sTalentList = J.Skill.GetTalentList(npcBot)
local sAbilityList = J.Skill.GetAbilityList(npcBot)
local sOutfit = J.Skill.GetOutfitName(npcBot)

local tTalentTreeList = {
						['t25'] = {10, 0},
						['t20'] = {10, 0},
						['t15'] = {0, 10},
						['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
						{1,3,1,2,2,6,2,2,1,1,6,3,3,3,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)



X['sBuyList'] = {
				sOutfit,
				"item_mask_of_madness",
				"item_echo_sabre",
				"item_blink",
				"item_black_king_bar",
				"item_broken_satanic", 
				"item_orchid",
				"item_bloodthorn",
				"item_heart",
}

X['sSellList'] = {
	"item_phase_boots",
	"item_stout_shield",
	"item_echo_sabre",
	"item_quelling_blade",
	"item_bloodthorn",
	"item_phase_boots",
}

nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList'] = J.SetUserHeroInit(nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList']);

X['sSkillList'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = true

function X.MinionThink(hMinionUnit)

	if minion.IsValidUnit(hMinionUnit) 
	then
		minion.IllusionThink(hMinionUnit)
	end

end

local abilityQ = npcBot:GetAbilityByName( sAbilityList[1] )
local abilityE = npcBot:GetAbilityByName( sAbilityList[3] )
local abilityR = npcBot:GetAbilityByName( sAbilityList[6] )


local castQDesire, castQTarget
local castEDesire
local castRDesire

local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;


function X.SkillsComplement()

	
	J.ConsiderForBtDisassembleMask(npcBot);
	X.SvenConsiderTarget();
	
	
	
	if J.CanNotUseAbility(npcBot) or npcBot:IsInvisible() then return end
	
	
	
	nKeepMana = 400
	aetherRange = 0
	talentDamage = 0
	nLV = npcBot:GetLevel();
	nMP = npcBot:GetMana()/npcBot:GetMaxMana();
	nHP = npcBot:GetHealth()/npcBot:GetMaxHealth();
	hEnemyHeroList = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);

	
	
	
		
	castRDesire = X.ConsiderR();
	if ( castRDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, true)
	
		npcBot:ActionQueue_UseAbility( abilityR );
		return;
	
	end
	
	castQDesire, castQTarget = X.ConsiderQ();
	if ( castQDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, true)
	
		npcBot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget );
		return;
		
	end
	
	castEDesire = X.ConsiderE();
	if ( castEDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, false)
	
		npcBot:ActionQueue_UseAbility( abilityE );
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
	
	local nAllies =  npcBot:GetNearbyHeroes(1200,false,BOT_MODE_NONE);
	
	if #hEnemyHeroList == 1 
	   and J.IsValidHero(hEnemyHeroList[1])
	   and J.IsInRange(hEnemyHeroList[1],npcBot,nCastRange + 350)
	   and hEnemyHeroList[1]:IsFacingLocation(npcBot:GetLocation(),30)
	   and hEnemyHeroList[1]:GetAttackRange() > nCastRange
	   and hEnemyHeroList[1]:GetAttackRange() < 1250
	then
		nCastRange = nCastRange + 260;
	end
	
	local nEnemysHerosInRange = npcBot:GetNearbyHeroes(nCastRange + 43,true,BOT_MODE_NONE);
	local nEnemysHerosInBonus = npcBot:GetNearbyHeroes(nCastRange + 350,true,BOT_MODE_NONE);
		
	local nEmemysCreepsInRange = npcBot:GetNearbyCreeps(nCastRange + 43,true);
	
	--打断和击杀 
	for _,npcEnemy in pairs( nEnemysHerosInBonus )
	do
		if J.IsValid(npcEnemy)
		   and J.CanCastOnNonMagicImmune(npcEnemy)
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
					then
						nBetterTarget = enemy;
						break;
					end
				end
			
				if nBetterTarget ~= nil
				   and not J.IsInRange(npcEnemy,npcBot,nCastRange) 
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
	if J.IsInTeamFight(npcBot, 1200)
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
					local npcEnemyDamage = npcEnemy:GetEstimatedDamageToTarget( false, npcBot, 3.0, DAMAGE_TYPE_PHYSICAL );
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
	if npcBot:GetActiveMode() == BOT_MODE_LANING or nLV <= 5
	then
		for _,npcEnemy in pairs( nEnemysHerosInRange )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and not J.IsDisabled(true, npcEnemy)
				and J.GetAttackTargetEnemyCreepCount(npcEnemy, 1400) >= 5
			then
				J.SetReport("对线期间使用:",npcEnemy:GetUnitName());
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end	
	end
	
	--打架时先手	
	if J.IsGoingOnSomeone(npcBot)
	then
	    local npcTarget = J.GetProperTarget(npcBot);
		if J.IsValidHero(npcTarget) 
			and J.CanCastOnNonMagicImmune(npcTarget) 
			and J.IsInRange(npcTarget, npcBot, nCastRange +60) 
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
	if J.IsRetreating(npcBot) 
	then
		for _,npcEnemy in pairs( nEnemysHerosInRange )
		do
			if J.IsValid(npcEnemy)
			    and ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 5.0 ) 
						or nMP > 0.8
						or GetUnitToUnitDistance(npcBot,npcEnemy) <= 400 )
				and J.CanCastOnNonMagicImmune(npcEnemy) 
				and not J.IsDisabled(true, npcEnemy) 
				and not npcEnemy:IsDisarmed()
			then
				J.SetReport("撤退了保护自己:",npcEnemy:GetUnitName());
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	--发育时对野怪输出
	if J.IsFarming(npcBot) and nSkillLV >= 3
	   and (npcBot:GetAttackDamage() < 200 or nMP > 0.88)
	   and nMP > 0.78
	then
		local nNeutralCreeps = npcBot:GetNearbyNeutralCreeps(700);
		if #nNeutralCreeps >= 3
		then
			for _,creep in pairs(nNeutralCreeps)
			do
				if J.IsValid(creep)
					and creep:GetHealth() >= 900
					and creep:GetMagicResist() < 0.3
					and J.IsInRange(creep,npcBot,350)
					and J.GetAroundTargetEnemyUnitCount(creep, nRadius) >= 3
				then
					J.SetReport("打野时野怪数量:",#nNeutralCreeps);
					return BOT_ACTION_DESIRE_HIGH, creep;
				end			
			end
		end
	end
	
	
	--推进时对小兵用
	if  (J.IsPushing(npcBot) or J.IsDefending(npcBot) or J.IsFarming(npcBot))
	    and (npcBot:GetAttackDamage() < 200 or nMP > 0.9)
		and nSkillLV >= 4 and #hEnemyHeroList == 0 and nMP > 0.68
		and not J.IsInEnemyArea(npcBot)
	then
		local nLaneCreeps = npcBot:GetNearbyLaneCreeps(1000,true);
		if #nLaneCreeps >= 5
		then
			for _,creep in pairs(nLaneCreeps)
			do
				if J.IsValid(creep)
					and creep:GetHealth() >= 500
					and not creep:HasModifier("modifier_fountain_glyph")
					and J.IsInRange(creep,npcBot,nCastRange + 100)
					and J.GetAroundTargetEnemyUnitCount(creep, nRadius) >= 5
				then
					J.SetReport("推进时小兵数量:",#nLaneCreeps);
					return BOT_ACTION_DESIRE_HIGH, creep;
				end			
			end
		end
	end
	
	--打肉的时候输出
	if  npcBot:GetActiveMode() == BOT_MODE_ROSHAN 
		and npcBot:GetMana() >= 600
	then
		local npcTarget = npcBot:GetAttackTarget();
		if  J.IsRoshan(npcTarget) 
			and not J.IsDisabled(true, npcTarget)
			and not npcTarget:IsDisarmed()
			and J.IsInRange(npcTarget, npcBot, nCastRange)  
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	--通用受到伤害时保护自己
	if npcBot:WasRecentlyDamagedByAnyHero(3.0) 
		and npcBot:GetActiveMode() ~= BOT_MODE_RETREAT
		and not npcBot:IsInvisible()
		and #nEnemysHerosInRange >= 1
		and nLV >= 7
	then
		for _,npcEnemy in pairs( nEnemysHerosInRange )
		do
			if  J.IsValidHero(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and not J.IsDisabled(true, npcEnemy)
                and not npcEnemy:IsDisarmed()				
				and npcBot:IsFacingLocation(npcEnemy:GetLocation(),45)
			then
				J.SetReport("保护我自己:",npcEnemy:GetUnitName());
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end
	
	--通用消耗敌人或保护自己
	if (#hEnemyHeroList > 0 or npcBot:WasRecentlyDamagedByAnyHero(3.0)) 
		and ( npcBot:GetActiveMode() ~= BOT_MODE_RETREAT or #nAllies >= 2 )
		and #nEnemysHerosInRange >= 1
		and nLV >= 7
	then
		for _,npcEnemy in pairs( nEnemysHerosInRange )
		do
			if  J.IsValidHero(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
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
	
	local nAllies = J.GetAllyList(npcBot,nSkillRange);
	local nAlliesCount = #nAllies;
	local nWeakestAlly = J.GetLeastHpUnit(nAllies);
	if nWeakestAlly == nil then nWeakestAlly = npcBot; end
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
	if J.IsGoingOnSomeone(npcBot)
	then
	    local npcTarget = J.GetProperTarget(npcBot);
		if J.IsValidHero(npcTarget) 
		   and not J.IsInRange(npcTarget,npcBot,300)
		   and J.IsInRange(npcTarget,npcBot,600)
		   and npcBot:IsFacingLocation(npcTarget:GetLocation(),15)
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
	
	local nEnemysHerosInBonus = npcBot:GetNearbyHeroes(1200,true,BOT_MODE_NONE);	
	
	--打架时先手	
	if J.IsGoingOnSomeone(npcBot)
	then
	    local npcTarget = J.GetProperTarget(npcBot);
		if J.IsValidHero(npcTarget) 
		   and ( J.GetHPR(npcTarget) > 0.25 or #nEnemysHerosInBonus >= 2 )
		   and ( J.IsInRange(npcTarget,npcBot,700)
				 or J.IsInRange(npcTarget,npcBot,npcTarget:GetAttackRange() + 80) )				  
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	--撤退时保护自己
	if npcBot:GetActiveMode() == BOT_MODE_RETREAT 
		and npcBot:DistanceFromFountain() > 800
		and nHP > 0.5
		and npcBot:WasRecentlyDamagedByAnyHero(3.0)
		and #nEnemysHerosInBonus >= 1
	then
		return BOT_ACTION_DESIRE_HIGH;
	end

	return 0;
end

function X.SvenConsiderTarget()

	local npcBot = GetBot();
	
	if not J.IsRunning(npcBot) 
	then return end
	
	local npcTarget = npcBot:GetAttackTarget();
	if not J.IsValidHero(npcTarget) then return end

	local nAttackRange = npcBot:GetAttackRange() + 50;	
	local nEnemyHeroInRange = npcBot:GetNearbyHeroes(nAttackRange,true,BOT_MODE_NONE);
	
	local nInAttackRangeNearestEnemyHero = nEnemyHeroInRange[1];

	if  J.IsValidHero(nInAttackRangeWeakestEnemyHero)
		and J.CanBeAttacked(nInAttackRangeWeakestEnemyHero)
		and ( GetUnitToUnitDistance(npcTarget,npcBot) >  350 or U.HasForbiddenModifier(npcTarget) )		
	then
		J.SetReport("更改目标为:",nInAttackRangeWeakestEnemyHero:GetUnitName());
		npcBot:SetTarget(nInAttackRangeWeakestEnemyHero);
		return;
	end

end

return X
-- dota2jmz@163.com QQ:2462331592
