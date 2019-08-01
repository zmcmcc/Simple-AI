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
						['t20'] = {10,10},
						['t15'] = {0, 10},
						['t10'] = {0, 10},
}

if J.Skill.IsHeroInEnemyTeam("npc_dota_hero_antimage") 
then  
	tTalentTreeList['t20'][1] = 0; 
else
	tTalentTreeList['t20'][2] = 0; 
end

local tAllAbilityBuildList = {
						{1,3,1,2,1,6,1,3,3,3,6,2,2,2,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)



X['sBuyList'] = {
				sOutfit,
				"item_crimson_guard",
				"item_echo_sabre",
				"item_heavens_halberd",
				"item_assault",
--				"item_heart",
}

X['sSellList'] = {
	"item_crimson_guard",
	"item_quelling_blade",
}

nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList'] = J.SetUserHeroInit(nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList']);

X['sSkillList'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)


X['bDeafaultAbility'] = true
X['bDeafaultItem'] = true

function X.MinionThink(hMinionUnit)

	if minion.IsValidUnit(hMinionUnit) 
	   and hMinionUnit:GetUnitName() ~= "npc_dota_wraith_king_skeleton_warrior" 
	then
		minion.IllusionThink(hMinionUnit)
	end

end

local abilityQ = npcBot:GetAbilityByName( sAbilityList[1] )
local abilityW = npcBot:GetAbilityByName( sAbilityList[2] )
local abilityE = npcBot:GetAbilityByName( sAbilityList[3] )
local abilityR = npcBot:GetAbilityByName( sAbilityList[6] )
local talent5 = npcBot:GetAbilityByName( sTalentList[5] );

local castQDesire, castQTarget
local castWDesire
local castEDesire

local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;

function X.SkillsComplement()

	
	if J.CanNotUseAbility(npcBot) or npcBot:IsInvisible() then return end
	
	
	nKeepMana = 160
	nLV = npcBot:GetLevel();
	nMP = npcBot:GetMana()/npcBot:GetMaxMana();
	nHP = npcBot:GetHealth()/npcBot:GetMaxHealth();
	hEnemyHeroList = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	
	
	
	
	castQDesire, castQTarget = X.ConsiderQ();
	if ( castQDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, false)
	
		npcBot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget )
		return;
	end
	
	castEDesire  = X.ConsiderE();
	if ( castEDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, false)
	
		npcBot:ActionQueue_UseAbility( abilityE )
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
	
	local nAlleys =  npcBot:GetNearbyHeroes(1200,false,BOT_MODE_NONE);
	
	local nEnemysHerosInView  = npcBot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	
	if #nEnemysHerosInView == 1 
	   and J.IsValidHero(nEnemysHerosInView[1])
	   and J.IsInRange(nEnemysHerosInView[1],npcBot,nCastRange + 350)
	   and nEnemysHerosInView[1]:IsFacingLocation(npcBot:GetLocation(),30)
	   and nEnemysHerosInView[1]:GetAttackRange() > nCastRange
	   and nEnemysHerosInView[1]:GetAttackRange() < 1250
	then
		nCastRange = nCastRange + 260;
	end
	
	local nEnemysHerosInRange = npcBot:GetNearbyHeroes(nCastRange + 43,true,BOT_MODE_NONE);
	local nEnemysHerosInBonus = npcBot:GetNearbyHeroes(nCastRange + 330,true,BOT_MODE_NONE);		
	
	--打断和击杀
	for _,npcEnemy in pairs( nEnemysHerosInBonus )
	do
		if J.IsValid(npcEnemy)
		   and J.CanCastOnNonMagicImmune(npcEnemy)
		then
			if npcEnemy:IsChanneling()
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
			
			if  GetUnitToUnitDistance(npcBot,npcEnemy) <= nCastRange + 80
				and J.CanKillTarget(npcEnemy,nDamage *1.68,nDamageType)
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
			
		end
	end
	
	--团战中对战力最高的敌人使用
	if J.IsInTeamFight(npcBot, 1200)
	then
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;		
		
		for _,npcEnemy in pairs( nEnemysHerosInRange )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and not J.IsDisabled(true, npcEnemy)
				and not npcEnemy:IsDisarmed()
			then
				local npcEnemyDamage = npcEnemy:GetEstimatedDamageToTarget( false, npcBot, 3.0, DAMAGE_TYPE_PHYSICAL );
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
	if npcBot:GetActiveMode() == BOT_MODE_LANING or nLV <= 5
	then
		for _,npcEnemy in pairs( nEnemysHerosInBonus )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and not J.IsDisabled(true, npcEnemy)
				and J.GetAttackTargetEnemyCreepCount(npcEnemy, 1400) >= 4
			then
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
			and J.IsInRange(npcTarget, npcBot, nCastRange +80) 
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
	if J.IsRetreating(npcBot) 
		and not npcBot:IsInvisible()
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
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	if  J.IsFarming(npcBot) 
		and nSkillLV >= 3
		and (npcBot:GetAttackDamage() < 200 or nMP > 0.88)
		and nMP > 0.71
	then
		local nCreeps = npcBot:GetNearbyNeutralCreeps(nCastRange +100);
		
		local targetCreep = J.GetMostHpUnit(nCreeps);
		
		if J.IsValid(targetCreep)
			and ( #nCreeps >= 2 or GetUnitToUnitDistance(targetCreep,npcBot) <= 400 )
			and not J.IsRoshan(targetCreep)
			and not J.IsOtherAllysTarget(targetCreep)
			and targetCreep:GetMagicResist() < 0.3
			and not J.CanKillTarget(targetCreep,npcBot:GetAttackDamage() *1.68,DAMAGE_TYPE_PHYSICAL)
			and not J.CanKillTarget(targetCreep,nDamage,nDamageType)
		then
			return BOT_ACTION_DESIRE_HIGH, targetCreep;
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
	
	--受到伤害时保护自己
	if npcBot:WasRecentlyDamagedByAnyHero(3.0) 
		and npcBot:GetActiveMode() ~= BOT_MODE_RETREAT
		and not npcBot:IsInvisible()
		and #nEnemysHerosInRange >= 1
		and nLV >= 6
	then
		for _,npcEnemy in pairs( nEnemysHerosInRange )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and not J.IsDisabled(true, npcEnemy)
                and not npcEnemy:IsDisarmed()				
				and npcBot:IsFacingLocation(npcEnemy:GetLocation(),45)
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end
	
	--通用消耗敌人或受到伤害时保护自己
	if (#nEnemysHerosInView > 0 or npcBot:WasRecentlyDamagedByAnyHero(3.0)) 
		and ( npcBot:GetActiveMode() ~= BOT_MODE_RETREAT or #nAlleys >= 2 )
		and #nEnemysHerosInRange >= 1
		and nLV >= 7
	then
		for _,npcEnemy in pairs( nEnemysHerosInRange )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
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
	    or not npcBot:HasModifier("modifier_skeleton_king_mortal_strike")
		or X.ShouldSaveMana(abilityE)
	then return 0; end
	
	local nStack = 0;
	local modIdx = npcBot:GetModifierByName("modifier_skeleton_king_mortal_strike");
	if modIdx > -1 then
		nStack = npcBot:GetModifierStackCount(modIdx);
	end
	local maxStack = abilityE:GetSpecialValueInt("max_skeleton_charges");
	
	local nEnemysHerosInView  = npcBot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	local npcTarget = J.GetProperTarget(npcBot);
	
	--辅助进攻
	if J.IsValidHero(npcTarget) 
		and #nEnemysHerosInView == 1
	    and J.IsInRange(npcTarget, npcBot, 650)
		and nStack / maxStack >= 0.6
	then
		return BOT_ACTION_DESIRE_HIGH;
	end	
	
	--buff叠满了靠近兵线的时候
	if nStack == maxStack
		and nLV >= 4
		and ( X.IsNearLaneFront(npcBot) or J.IsFarming(npcBot))
	then
		return BOT_ACTION_DESIRE_HIGH;
	end
		
	return 0;
end

function X.IsNearLaneFront( npcBot )
	local testDist = 600;
	local lanes = {LANE_TOP, LANE_MID, LANE_BOT};
	for _,lane in pairs(lanes)
	do
		local tFLoc = GetLaneFrontLocation(GetTeam(), lane, 0);
		if GetUnitToLocationDistance(npcBot,tFLoc) <= testDist
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
		and ( npcBot:GetMana() - nAbility:GetManaCost() < abilityR:GetManaCost())
	then
		return true;
	end
	
	return false;
end


return X
-- dota2jmz@163.com QQ:2462331592
