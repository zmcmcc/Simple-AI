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
						{2,3,3,1,3,6,3,1,1,1,6,2,2,2,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)

X['skills'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)

X['items'] = {
				sOutfit,
				"item_dragon_lance",
				'item_mask_of_madness',
				"item_maelstrom",
				"item_hurricane_pike",
				"item_skadi",
				"item_broken_satanic",	
				"item_monkey_king_bar",
				"item_mjollnir",
}

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = true

function X.MinionThink(hMinionUnit)

	if minion.IsValidUnit(hMinionUnit) 
	then
		if hMinionUnit:IsIllusion() 
		then 
			minion.IllusionThink(hMinionUnit)	
		end
	end

end

local abilityQ = npcBot:GetAbilityByName( sAbilityList[1] );
local abilityE = npcBot:GetAbilityByName( sAbilityList[3] );
local abilityR = npcBot:GetAbilityByName( sAbilityList[6] );


local castQDesire,castQLocation = 0;
local castEDesire = 0;
local castRDesire,castRTarget = 0;


local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;
local lastAbilityQTime = 0
local lastAbilityQLocation = Vector(0,0)

function X.SkillsComplement()

	
	X.ConsiderTarget();
	J.ConsiderForMkbDisassembleMask(npcBot);
	
	
	
	if J.CanNotUseAbility(npcBot) or npcBot:IsInvisible() then return end
	
	
	
	nKeepMana = 280; 
	nMP = npcBot:GetMana()/npcBot:GetMaxMana();
	nHP = npcBot:GetHealth()/npcBot:GetMaxHealth();
	nLV = npcBot:GetLevel();
	hEnemyHeroList = npcBot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	
	
	
	
	castRDesire, castRTarget   = X.ConsiderR();
	if ( castRDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, false)
	
		npcBot:ActionQueue_UseAbilityOnEntity( abilityR, castRTarget )
		return;
	end
	
	castEDesire = X.ConsiderE();
	if ( castEDesire > 0 ) 
	then
	
		npcBot:Action_ClearActions(false);
	
		npcBot:ActionQueue_UseAbility( abilityE )
		return;
	
	end
	
	castQDesire, castQLocation = X.ConsiderQ();
	if ( castQDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, false)
	
		npcBot:ActionQueue_UseAbilityOnLocation( abilityQ, castQLocation )
		lastAbilityQTime = DotaTime();
		lastAbilityQLocation = castQLocation;
		return;
	end
	

end

function X.ConsiderTarget()
	if not J.IsRunning(npcBot) 
	   or npcBot:HasModifier("modifier_item_hurricane_pike_range")
	then return  end

	local nAttackRange = npcBot:GetAttackRange() + 60;	
	if nAttackRange > 1600 then nAttackRange = 1600 end
	local nInAttackRangeWeakestEnemyHero = J.GetAttackableWeakestUnit(true, true, nAttackRange, npcBot);
	
	local npcTarget = J.GetProperTarget(npcBot);
	local nTargetUint = nil;

	if J.IsValidHero(npcTarget)
		and GetUnitToUnitDistance(npcTarget,npcBot) >  nAttackRange 
		and J.IsValidHero(nInAttackRangeWeakestEnemyHero)
	then
		nTargetUint = nInAttackRangeWeakestEnemyHero;
		npcBot:SetTarget(nTargetUint);
		return;
	end

end

function X.ConsiderQ()
	
	if not abilityQ:IsFullyCastable() then return 0 end
	
	local nCastRange = 1600;   --abilityQ:GetCastRange();
	local nSkillLV   = abilityQ:GetLevel();
	local nDamage = (15 +20*(nSkillLV -1)) *11;
	local nRadius = abilityQ:GetAOERadius();
	local nCastPoint = abilityQ:GetCastPoint();
	local botLocation = npcBot:GetLocation();
	
	local nEnemysLaneCreepsInSkillRange = npcBot:GetNearbyLaneCreeps(1600,true)
	local nEnemysHeroesInSkillRange = npcBot:GetNearbyHeroes(1600,true,BOT_MODE_NONE)
	
	local nCanHurtCreepsLocationAoE = npcBot:FindAoELocation( true, false, botLocation, nCastRange, nRadius, 0.8, 0);
	local nCanHurtCreepCount = nCanHurtCreepsLocationAoE.count;
	if nCanHurtCreepsLocationAoE == nil
       or  J.GetInLocLaneCreepCount(npcBot, 1600, nRadius, nCanHurtCreepsLocationAoE.targetloc) <= 2        --检查半径内是否真的有小兵
	then
	     nCanHurtCreepCount = 0
	end
	local nCanHurtHeroLocationAoE = npcBot:FindAoELocation( true, true, botLocation, nCastRange, nRadius-30, 0.8, 0);
	
	local npcTarget = J.GetProperTarget(npcBot)
	
	--对多个敌方英雄使用
	if #nEnemysHeroesInSkillRange >= 2
		and (nCanHurtHeroLocationAoE.cout ~= nil and nCanHurtHeroLocationAoE.cout >= 2)
		and npcBot:GetActiveMode( ) ~= BOT_MODE_LANING
		and (npcBot:GetActiveMode() ~= BOT_MODE_RETREAT or (npcBot:GetActiveMode() == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire( ) < 0.6))
		and not X.IsAbiltyQCastedHere(nCanHurtHeroLocationAoE.targetloc,nRadius)
    then
		J.SetReport("对多个敌人使用技能,伤害人数",nCanHurtHeroLocationAoE.cout);
		return BOT_ACTION_DESIRE_HIGH,nCanHurtHeroLocationAoE.targetloc;
	end
	
	--对当前目标英雄使用	
	if J.IsValidHero(npcTarget)
	   and not npcTarget:HasModifier("modifier_sniper_shrapnel_slow")
	   and J.CanCastOnNonMagicImmune(npcTarget) 
	   and J.IsInRange(npcTarget, npcBot, nCastRange +300)
	   and (nSkillLV >= 3 or npcBot:GetMana() >= nKeepMana)
	   and not X.IsAbiltyQCastedHere(npcTarget:GetLocation(),nRadius)
	then
		
		if npcTarget:IsFacingLocation(J.GetEnemyFountain(),30)
			and J.GetHPR(npcTarget) < 0.4
			and J.IsRunning(npcTarget)
		then
			for i=0,800,200
			do
				local nCastLocation = J.GetLocationTowardDistanceLocation(npcTarget,J.GetEnemyFountain(),nRadius + 800 - i);
				if GetUnitToLocationDistance(npcBot,nCastLocation) <= nCastRange + 200
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
		
		local castDistance = GetUnitToUnitDistance(npcBot,npcTarget);
		if npcTarget:IsFacingLocation(botLocation, 30) and J.IsMoving(npcTarget)
		then
			if castDistance > 400 
			then   
			    castDistance = castDistance - 200;
			end
			J.SetReport("近处预测将到近处来的目标:",npcTarget:GetUnitName());
		    return BOT_ACTION_DESIRE_HIGH,J.GetUnitTowardDistanceLocation(npcBot,npcTarget,castDistance);
		end		
		
		if npcBot:IsFacingLocation(npcTarget:GetLocation(), 30)
		then
		    if castDistance <= nCastRange - 200
			then
			    castDistance = castDistance + 400;
			else
			    castDistance = nCastRange+ 300;
			end
			J.SetReport("远处预测将到远处去的目标:",npcTarget:GetUnitName());
		    return BOT_ACTION_DESIRE_HIGH,J.GetUnitTowardDistanceLocation(npcBot,npcTarget,castDistance);
		end
		
		J.SetReport("目标位置无规律,目标是",npcTarget:GetUnitName());
		return BOT_ACTION_DESIRE_HIGH,J.GetLocationTowardDistanceLocation(npcTarget,J.GetEnemyFountain(),nRadius/2);
		
	end
	
	--撤退时减速
	if J.IsRetreating(npcBot)
	   and not npcBot:IsInvisible()  
	then
		local nCanHurtHeroLocationAoENearby = npcBot:FindAoELocation( true, true, botLocation, nCastRange - 400, nRadius, 1.5, 0);
		if nCanHurtHeroLocationAoENearby.count >= 2 
		   and not X.IsAbiltyQCastedHere(nCanHurtHeroLocationAoENearby.targetloc,nRadius)
		then
			J.SetReport("撤退使用技能",nCanHurtHeroLocationAoENearby.count);
			return BOT_ACTION_DESIRE_HIGH, nCanHurtHeroLocationAoENearby.targetloc;
		end
		
		if npcBot:GetActiveModeDesire() > 0.8 
		then
			local nEnemyNearby = npcBot:GetNearbyHeroes(800,true,BOT_MODE_NONE);
			for _,npcEnemy in pairs( nEnemyNearby )
			do
				if J.IsValid(npcEnemy)
					and npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) 
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
		and npcBot:GetActiveMode( ) ~= BOT_MODE_ATTACK
		and npcBot:GetActiveMode( ) ~= BOT_MODE_LANING
		and npcBot:GetMana() >= nKeepMana
		and #nEnemysLaneCreepsInSkillRange >= 2
		and nCanHurtCreepCount >= 6
		and ( nLV < 25 or nCanHurtCreepCount >= 8 )
		and ( nLV < 20 or GetUnitToLocationDistance(npcBot,nCanHurtCreepsLocationAoE.targetloc) >= 1300 )
		and not X.IsAbiltyQCastedHere(nCanHurtCreepsLocationAoE.targetloc,nRadius)
	then
		return BOT_ACTION_DESIRE_HIGH,nCanHurtCreepsLocationAoE.targetloc;
	end
	
	if J.IsFarming(npcBot) and npcBot:GetMana() >= nKeepMana
	then
		local nNeutralCreeps = npcBot:GetNearbyNeutralCreeps(800);
		if #nNeutralCreeps >= 4 
		   and J.IsValid(npcTarget)
		   and not J.CanKillTarget(npcTarget, npcBot:GetAttackDamage() * 3.88 , DAMAGE_TYPE_PHYSICAL)
		then
			local nAoE = npcBot:FindAoELocation( true, false, botLocation, nCastRange, nRadius, 0.8, 0);
			if nAoE.count >= 5 
			then
				return BOT_ACTION_DESIRE_HIGH,nAoE.targetloc;
			end
		end	
	end
	
	if  npcBot:GetActiveMode() == BOT_MODE_ROSHAN  
	then
	    local nAttackTarget = npcBot:GetAttackTarget();
		if  J.IsValid(nAttackTarget)
			and J.GetHPR(nAttackTarget) > 0.5
			and J.IsInRange(nAttackTarget,npcBot,600)
			and not nAttackTarget:HasModifier("modifier_sniper_shrapnel_slow")
		    and not X.IsAbiltyQCastedHere(nAttackTarget:GetLocation(),nRadius)
		then
			local nAllies = npcBot:GetNearbyHeroes(800,false,BOT_MODE_ROSHAN);
			if #nAllies >= 4 
			then
				return BOT_ACTION_DESIRE_HIGH,nAttackTarget:GetLocation();
			end
		end
	end	

	return 0;
end

function X.ConsiderE()
	if not abilityE:IsFullyCastable() or npcBot:HasModifier("modifier_sniper_take_aim_bonus")  then return 0 end
	
	local nAttackRange = npcBot:GetAttackRange();
	local nSkillLV  = abilityE:GetLevel();
	local nSkillRange = nSkillLV *100;
	local nDamage = npcBot:GetAttackDamage();
	
	local npcTarget = J.GetProperTarget(npcBot);
	
	if J.IsValid(npcTarget)
		and (npcTarget:IsHero() or J.CanKillTarget(npcTarget, nDamage *2.28, DAMAGE_TYPE_PHYSICAL))
		and GetUnitToUnitDistance(npcBot,npcTarget) > nAttackRange + 50
		and GetUnitToUnitDistance(npcBot,npcTarget) < nAttackRange + nSkillRange + 50
	then
		return BOT_ACTION_DESIRE_HIGH;
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

function X.ConsiderR()
	
	if not abilityR:IsFullyCastable() then return 0 end
	
	local nCastRange   = abilityR:GetCastRange();
	local nCastPoint   = abilityR:GetCastPoint();
	local nAttackRange = npcBot:GetAttackRange();
	if nAttackRange > 1550 then nAttackRange = 1550 end
	local nDamage      = abilityR:GetAbilityDamage();
	local nDamageType  = DAMAGE_TYPE_MAGICAL;
	
	local nEnemysHerosCanSeen = GetUnitList(UNIT_LIST_ENEMY_HEROES);
	local nEnemysHerosInAttackRange = npcBot:GetNearbyHeroes(nAttackRange +50,true,BOT_MODE_NONE);
	
	local nTempTarget = nEnemysHerosInAttackRange[1];
	local nAttackTarget = J.GetProperTarget(npcBot)
	if J.IsValidHero(nAttackTarget)
	   and J.IsInRange(npcBot,nAttackTarget,nAttackRange +50)
	then nTempTarget = nAttackTarget end
	
	local nWeakestEnemyHeroInCastRange = X.GetWeakestUnitInRangeExRadius(nEnemysHerosCanSeen,nCastRange,nAttackRange -300,npcBot);
	local nChannelingEnemyHeroInCastRange = X.GetChannelingUnitInRange(nEnemysHerosCanSeen,nCastRange,npcBot);
	local castRTarget = nil;
	
	if J.IsValid(nWeakestEnemyHeroInCastRange)
	   and ( J.WillMagicKillTarget(npcBot, nWeakestEnemyHeroInCastRange, nDamage, nCastPoint)
			 or ( X.ShouldUseR(nTempTarget,nWeakestEnemyHeroInCastRange,nDamage) and (nLV >= 20 or npcBot:GetMana() > nKeepMana *1.28) ))
	then
		castRTarget = nWeakestEnemyHeroInCastRange;
		return BOT_ACTION_DESIRE_HIGH,castRTarget;
	end
	
	if J.IsValid(nChannelingEnemyHeroInCastRange)
		and not npcBot:IsInvisible()
		and not J.IsRetreating(npcBot)
	then
		castRTarget = nChannelingEnemyHeroInCastRange;
		return BOT_ACTION_DESIRE_HIGH,castRTarget;
	end	
	
	return 0;
end

function X.GetWeakestUnitInRangeExRadius(nUnits,nRange,nRadius,npcBot) 
	if nUnits[1] == nil then return nil end;
	
	local nAttackRange = npcBot:GetAttackRange();
	local nAttackDamage = npcBot:GetAttackDamage();
	local weakestUnit = nil;
	local weakestHealth = 9999;
	for _,unit in pairs(nUnits)
	do
		if  J.IsInRange(unit, npcBot, nRange)
			and not J.IsInRange(unit, npcBot, nRadius)
			and J.CanCastOnNonMagicImmune(unit)
			and not J.IsOtherAllyCanKillTarget(npcBot, unit)
			and unit:GetHealth() < weakestHealth
			and not unit:HasModifier("modifier_teleporting")
			and not ( J.IsInRange(unit, npcBot, nAttackRange) 
			          and J.CanKillTarget(unit,nAttackDamage,DAMAGE_TYPE_PHYSICAL))
		then
			weakestUnit = unit;
			weakestHealth = unit:GetHealth();
		end
	end
	
	return weakestUnit;
end

function X.GetChannelingUnitInRange(nUnits,nRange,npcBot)
	if nUnits[1] == nil then return nil end;
	
	local channelingUnit = nil;
	for _,unit in pairs(nUnits)
	do
		if  J.IsInRange(unit, npcBot, nRange)
			and not unit:IsMagicImmune()
			and unit:IsChanneling()
			and not ( unit:HasModifier("modifier_teleporting") 
			          and X.GetCastPoint(unit,npcBot) > J.GetModifierTime(unit,"modifier_teleporting"))
		then
			channelingUnit = unit;
			break;
		end
	end
	
	return channelingUnit;
end

function X.GetCastPoint(unit,npcBot)
		
		local nCastTime = abilityR:GetCastPoint();
		
		local nDist = GetUnitToUnitDistance(npcBot,unit);
		local nDistTime = nDist/2500;
		
		return nCastTime + nDistTime;
		
end

function X.IsAbiltyQCastedHere(nLoc,nRadius)

    if lastAbilityQTime < DotaTime() -10 
	   or J.GetLocationToLocationDistance(lastAbilityQLocation,nLoc) > nRadius *1.28
	then
		return false;
	end

	return true;
end

function X.ShouldUseR(nAttackTarget,nEnemy,nDamage)
	if J.IsRetreating(npcBot)
	   or ( J.IsValidHero(nAttackTarget) and J.CanBeAttacked(nAttackTarget)
			 and ( GetUnitToUnitDistance(npcBot,nAttackTarget) <= npcBot:GetAttackRange() -300 
					or J.CanKillTarget(nAttackTarget,npcBot:GetAttackDamage(),DAMAGE_TYPE_PHYSICAL) ) )
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
				and member ~= npcBot
				and GetUnitToUnitDistance(member,nEnemy) <= 600
				and ( member:IsFacingLocation(nEnemy:GetLocation(),20)
						or not (J.IsValidHero(nAttackTarget) and GetUnitToUnitDistance(npcBot,nAttackTarget) <= npcBot:GetAttackRange()))
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
-- dota2jmz@163.com QQ:2462331592.
