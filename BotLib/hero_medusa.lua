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
						['t20'] = {0, 10},
						['t15'] = {10, 0},
						['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
						{3,2,2,3,2,6,2,1,1,1,1,6,3,3,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)


X['sBuyList'] = {
				sOutfit,
				"item_dragon_lance",
--				"item_mask_of_madness",
				"item_yasha",
				"item_manta",
				"item_maelstrom",
				"item_skadi",
				"item_black_king_bar",
				"item_satanic",
				"item_mjollnir",
				--"item_lesser_crit",
				--"item_orchid",
				--"item_bloodthorn",
}

X['sSellList'] = {
	"item_manta",
	"item_urn_of_shadows",
	"item_black_king_bar",
	"item_dragon_lance",
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


local abilityW = npcBot:GetAbilityByName( sAbilityList[2] )
local abilityE = npcBot:GetAbilityByName( sAbilityList[3] )
local abilityR = npcBot:GetAbilityByName( sAbilityList[6] )
local abilityM = nil

local castWDesire,castWTarget
local castEDesire
local castRDesire


local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;
local lastToggleTime = 0;


function X.SkillsComplement()

	
	J.ConsiderForMkbDisassembleMask(npcBot);
	J.ConsiderTarget();
	
	
	
	if J.CanNotUseAbility(npcBot) or npcBot:IsInvisible() then return end
	
	
	
	nKeepMana = 400; 
	aetherRange = 0
	nLV = npcBot:GetLevel();
	nMP = npcBot:GetMana()/npcBot:GetMaxMana();
	nHP = npcBot:GetHealth()/npcBot:GetMaxHealth();
	hEnemyHeroList = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	
	
	--计算各个技能	
	
	castEDesire = X.ConsiderE()
	if ( castEDesire > 0 ) 
	then
	
		npcBot:ActionQueue_UseAbility( abilityE )
		return;
	
	end
	
	
	castWDesire, castWTarget = X.ConsiderW();
	if ( castWDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, false)
	
		npcBot:ActionQueue_UseAbilityOnEntity( abilityW, castWTarget )
		return;
	end
	
	
	castRDesire  = X.ConsiderR();
	if ( castRDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, false)
	
		npcBot:ActionQueue_UseAbility( abilityR )
		return;
	
	end

end

function X.ConsiderE()

	if not abilityE:IsFullyCastable() then return 0 end
	
	if nHP > 0.8 and nMP < 0.88 and nLV < 15
	  and J.GetEnemyCount(npcBot,1600) <= 1
	  and lastToggleTime + 3.0 < DotaTime()
	then
		if abilityE:GetToggleState() 
		then			   
		   return BOT_ACTION_DESIRE_HIGH
		end
	else
		if not abilityE:GetToggleState() 
		then
		   lastToggleTime = DotaTime();
		   return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	
	return BOT_ACTION_DESIRE_NONE;


end

function X.ConsiderW()

	-- Make sure it's castable
	if not abilityW:IsFullyCastable() then return 0 end

	-- Get some of its values
	local nCastRange = abilityW:GetCastRange() +20
	local nDamage    = abilityW:GetSpecialValueInt('snake_damage') * 2
	local nSkillLv   = abilityW:GetLevel()
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) 
			    and J.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
			end
		end
	end
	
	if J.IsInTeamFight(npcBot, 1200)
	then
		
		local npcMaxManaEnemy = nil;
		local nEnemyMaxMana = 0;

		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange +50, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if  J.IsValidHero(npcEnemy)
				and J.CanCastOnNonMagicImmune(npcEnemy) 
			then
				local nMaxMana = npcEnemy:GetMaxMana();
				if ( nMaxMana > nEnemyMaxMana )
				then
					nEnemyMaxMana = nMaxMana;
					npcMaxManaEnemy = npcEnemy;
				end
			end
		end

		if ( npcMaxManaEnemy ~= nil )
		then
			return BOT_ACTION_DESIRE_HIGH, npcMaxManaEnemy;
		end
		
	end
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = J.GetProperTarget(npcBot);
		if J.IsValidHero(npcTarget) 
		   and J.CanCastOnNonMagicImmune(npcTarget) 
		   and J.IsInRange(npcTarget, npcBot, nCastRange +90)
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	if nSkillLv >= 3 then
		local nAoe = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), 900, 500, 0, 0 )
		local nShouldAoeCount = 5;
		local nCreeps = npcBot:GetNearbyCreeps(nCastRange +80,true)
		local nLaneCreeps = npcBot:GetNearbyLaneCreeps(1600,true);
		
		if nSkillLv >= 3 then nShouldAoeCount = 4; end
		if npcBot:GetLevel() >= 20 or J.GetMPR(npcBot) > 0.88 then nShouldAoeCount = 3; end
		
		if nAoe.count >= nShouldAoeCount
		then
			if J.IsValid(nCreeps[1])
				and J.CanCastOnNonMagicImmune(nCreeps[1])
				and not (nCreeps[1]:GetTeam() == TEAM_NEUTRAL and #nLaneCreeps >= 1)
				and J.GetAroundTargetEnemyUnitCount(nCreeps[1],470) >= 2
			then
				return BOT_ACTION_DESIRE_HIGH,nCreeps[1];
			end
		end
		
		if #nCreeps >= 2 and nSkillLv >= 3
		then
			local creeps = npcBot:GetNearbyCreeps(1400,true);
			local heroes = npcBot:GetNearbyHeroes(1000,true,BOT_MODE_NONE);
			if J.IsValid(nCreeps[1])
			   and #creeps + #heroes >= 4
			   and J.CanCastOnNonMagicImmune(nCreeps[1])
			   and not (nCreeps[1]:GetTeam() == TEAM_NEUTRAL and #nLaneCreeps >= 1)
			   and J.GetAroundTargetEnemyUnitCount(nCreeps[1],470) >= 2
			then
				return BOT_ACTION_DESIRE_HIGH,nCreeps[1];
			end
		end
	end
				
	return BOT_ACTION_DESIRE_NONE, 0;

end


function X.ConsiderR()

	-- Make sure it's castable
	if not abilityR:IsFullyCastable() then return 0	end

	
	-- Get some of its values
	local nCastRange = abilityR:GetSpecialValueInt("radius");
	local nAttackRange = npcBot:GetAttackRange();
	
	
	if J.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and npcEnemy:IsFacingLocation(npcBot:GetLocation(),20)) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	
	if J.IsInTeamFight(npcBot, 1200) or J.IsGoingOnSomeone(npcBot)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nAttackRange, 400, 0, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			local nInvUnit = J.GetInvUnitInLocCount(npcBot, nAttackRange+200, 400, locationAoE.targetloc, true);
			if nInvUnit >= locationAoE.count then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
		
		local nEnemysHerosInSkillRange = npcBot:GetNearbyHeroes(800,true,BOT_MODE_NONE);
		if #nEnemysHerosInSkillRange >= 3
		then
			return BOT_ACTION_DESIRE_HIGH;
		end		
		
		local nAoe = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), 10, 700, 1.0, 0 );
		if nAoe.count >= 3
		then
			return BOT_ACTION_DESIRE_HIGH;
		end	
		
		local npcTarget = J.GetProperTarget(npcBot);		
		if J.IsValidHero(npcTarget) 
			and J.CanCastOnNonMagicImmune(npcTarget) 
			and not J.IsDisabled(true, npcTarget)
			and GetUnitToUnitDistance(npcTarget,npcBot) <= npcBot:GetAttackRange()
			and npcTarget:GetHealth() > 600
			and npcTarget:GetPrimaryAttribute() ~= ATTRIBUTE_INTELLECT
			and npcTarget:IsFacingLocation(npcBot:GetLocation(),30)
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
		
	end
	
	return BOT_ACTION_DESIRE_NONE;

end


function X.GetHurtCount(nUnit,nCount)

	local nHeroes = npcBot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	local nCreeps = npcBot:GetNearbyCreeps(1600,true,BOT_MODE_NONE);
	local nTable  = {};
	table.insert(nTable, nUnit);
	local nHurtCount = 1;
	
	for i=1,nCount 
	do
		local nNeastUnit = X.GetNearestUnit(nUnit,nHeroes,nCreeps,nTable);
		
		if nNeastUnit ~= nil
		   and GetUnitToUnitDistance(nUnit,nNeastUnit) <= 475
		then
			nHurtCount = nHurtCount + 1;
			table.insert(nTable, nNeastUnit);
		else
			break;
		end
	end
	
	
	return nHurtCount;

end

function X.GetNearestUnit(nUnit,nHeroes,nCreeps,nTable)
	
	local NearestUnit = nil;
	local NearestDist = 9999;
	for _,unit in pairs(nHeroes)
	do
		if unit ~= nil
			and unit:IsAlive()
			and not X.IsExistInTable(unit,nTable)
			and GetUnitToUnitDistance(nUnit,unit) < NearestDist
		then
			NearestUnit = unit;
			NearestDist = GetUnitToUnitDistance(nUnit,unit);
		end	
	end
	
	for _,unit in pairs(nCreeps)
	do
		if unit ~= nil
			and unit:IsAlive()
			and not X.IsExistInTable(unit,nTable)
			and GetUnitToUnitDistance(nUnit,unit) < NearestDist
		then
			NearestUnit = unit;
			NearestDist = GetUnitToUnitDistance(nUnit,unit);
		end	
	end
	
	return NearestUnit;

end

function X.IsExistInTable(u, tUnit)
	for _,t in pairs(tUnit) 
	do
		if t == u  
		then
			return true;
		end
	end
	return false;
end 

return X
-- dota2jmz@163.com QQ:2462331592
