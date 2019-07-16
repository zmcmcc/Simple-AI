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
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{2,1,2,3,2,6,2,1,1,1,6,3,3,3,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)

X['skills'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)

X['items'] = {
				sOutfit,
				"item_soul_ring",
				"item_pipe",
				"item_glimmer_cape",
				"item_veil_of_discord",
				"item_cyclone",
				"item_ultimate_scepter",
				"item_sheepstick",
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

local abilityQ = npcBot:GetAbilityByName( sAbilityList[1] )
local abilityW = npcBot:GetAbilityByName( sAbilityList[2] )
local abilityE = npcBot:GetAbilityByName( sAbilityList[3] )
local abilityD = npcBot:GetAbilityByName( sAbilityList[4] )
local abilityR = npcBot:GetAbilityByName( sAbilityList[6] )
local talent4 = npcBot:GetAbilityByName( sTalentList[4] )
local talent7 = npcBot:GetAbilityByName( sTalentList[7] )
local talent8 = npcBot:GetAbilityByName( sTalentList[8] )

local castQDesire, castQTarget
local castWDesire, castWTarget
local castW2Desire,castWLocation
local castDDesire, castDLocation
local castRDesire


local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;
local aetherRange = 0
local talentDamage = 0


local abilityEBonus = 0;


function X.SkillsComplement()
	
	
	if J.CanNotUseAbility(npcBot) or npcBot:IsInvisible() then return end
	
	
	nKeepMana = 400
	aetherRange = 0
	talentDamage = 0
	abilityEBonus = 0
	nLV = npcBot:GetLevel();
	nMP = npcBot:GetMana()/npcBot:GetMaxMana();
	nHP = npcBot:GetHealth()/npcBot:GetMaxHealth();
	nManaPercentage = npcBot:GetMana()/npcBot:GetMaxMana();
	nHealthPercentage = npcBot:GetHealth()/npcBot:GetMaxHealth();
	hEnemyHeroList = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	
	
	
	local aether = J.IsItemAvailable("item_aether_lens");
	if aether ~= nil then aetherRange = 250 end	
	if talent7:IsTrained() then aetherRange = aetherRange + talent7:GetSpecialValueInt("value") end
	if abilityE:IsTrained() then abilityEBonus = abilityE:GetSpecialValueInt("damage_health_pct")/100 end
	if talent4:IsTrained() then abilityEBonus = abilityEBonus + talent4:GetSpecialValueInt("value")/100 end
	if talent8:IsTrained() then talentDamage = talentDamage + talent8:GetSpecialValueInt("value") end
	
	
	
	
	castRDesire = X.ConsiderR();
	if ( castRDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, true)
	
		npcBot:ActionQueue_UseAbility( abilityR )
		return;
	
	end
	
	
	castWDesire, castWTarget = X.ConsiderW();
	if ( castWDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, true)
	
		npcBot:ActionQueue_UseAbilityOnEntity( abilityW, castWTarget )
		return;
	end
	
	
	castW2Desire, castWLocation = X.ConsiderW2();
	if ( castW2Desire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, true)
	
		npcBot:ActionQueue_UseAbilityOnLocation( abilityW, castWLocation )
		return;
	end
	
	
	castQDesire, castQTarget = X.ConsiderQ();
	if ( castQDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, true)
	
		npcBot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget )
		return;
	end
	

end

function X.ConsiderQ()

	if not abilityQ:IsFullyCastable() then	return BOT_ACTION_DESIRE_NONE, nil;	end
	
	local nCastRange = abilityQ:GetCastRange();
	local nCastPoint = abilityQ:GetCastPoint();
	local manaCost  = abilityQ:GetManaCost();
	local nRadius   = abilityQ:GetSpecialValueInt( "radius" );
	local nDamage   = abilityQ:GetSpecialValueInt( "arc_damage" );
	local nEnemyHeroesInSkillRange = npcBot:GetNearbyHeroes(nCastRange,true,BOT_MODE_NONE);
	
	for _,enemy in pairs(nEnemyHeroesInSkillRange)
	do
		if J.IsValidHero(enemy)
			and J.CanCastOnNonMagicImmune(enemy)
			and J.GetHPR(enemy) <= 0.2
		then
			return BOT_ACTION_DESIRE_HIGH, enemy;
		end
	end
	
	
	--对线期的使用
	if npcBot:GetActiveMode() == BOT_MODE_LANING 
	then
		local hLaneCreepList = npcBot:GetNearbyLaneCreeps(nCastRange +50,true);
		for _,creep in pairs(hLaneCreepList)
		do
			if J.IsValid(creep)
				and not creep:HasModifier("modifier_fountain_glyph")
		        and J.IsEnemyTargetUnit(1400,creep)
				and J.WillKillTarget(creep,nDamage,DAMAGE_TYPE_MAGICAL,nCastPoint)
			then
				return BOT_ACTION_DESIRE_HIGH, creep;
			end
		end
	
	end
	
	
	if J.IsRetreating(npcBot) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
	then
		local target = J.GetVulnerableWeakestUnit(true, true, nCastRange, npcBot);
		if target ~= nil and npcBot:IsFacingLocation(target:GetLocation(),45) then
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	
	if J.IsInTeamFight(npcBot, 1300)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2 ) then
			local target = J.GetVulnerableUnitNearLoc(true, true, nCastRange, nRadius, locationAoE.targetloc, npcBot);
			if target ~= nil then
				return BOT_ACTION_DESIRE_HIGH, target;
			end
		end
	end
	
	if ( J.IsPushing(npcBot) or J.IsDefending(npcBot) ) and J.IsAllowedToSpam(npcBot, manaCost)
	then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 3 ) then
			local target = J.GetVulnerableUnitNearLoc(false, true, nCastRange, nRadius, locationAoE.targetloc, npcBot);
			if target ~= nil then
				return BOT_ACTION_DESIRE_HIGH, target;
			end
		end
	end
	
	if J.IsGoingOnSomeone(npcBot)
	then
		local target = J.GetProperTarget(npcBot);
		if J.IsValidHero(target) 
		   and J.CanCastOnNonMagicImmune(target) 
		   and J.IsInRange(target, npcBot, nCastRange)
		then
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end

function X.ConsiderW()
	
	if not abilityW:IsFullyCastable() then	return BOT_ACTION_DESIRE_NONE, nil end
	
	local nCastRange = abilityW:GetCastRange();
	local nCastPoint = abilityW:GetCastPoint();
	local manaCost  = abilityW:GetManaCost();
	local nDamage   = abilityW:GetAbilityDamage() * ( 1 + npcBot:GetSpellAmp() );
		
	if J.IsRetreating(npcBot) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
	then
		local target = J.GetVulnerableWeakestUnit(true, true, nCastRange, npcBot);
		if target ~= nil then
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	
	if J.IsGoingOnSomeone(npcBot)
	then
		local target = J.GetProperTarget(npcBot);
		if J.IsValidHero(target) 
		   and J.CanCastOnNonMagicImmune(target) 
		   and J.IsInRange(target, npcBot, nCastRange)
		then
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	
	local targetRanged = X.GetRanged(npcBot,nCastRange);
	if targetRanged ~= nil
		and targetRanged:GetHealth() > npcBot:GetAttackDamage()
		and targetRanged:GetHealth() < targetRanged:GetActualIncomingDamage(nDamage + targetRanged:GetHealth() * abilityEBonus , DAMAGE_TYPE_MAGICAL)
	then
		return BOT_ACTION_DESIRE_HIGH, targetRanged;
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end

function X.ConsiderW2()

	if not abilityW:IsFullyCastable() then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = abilityW:GetCastRange();
	local nCastPoint = abilityW:GetCastPoint();
	local manaCost  = abilityW:GetManaCost();
	local nDamage   = abilityW:GetAbilityDamage();
	local nRadius   = 325;
	
	local nAllies = npcBot:GetNearbyHeroes(800,false,BOT_MODE_NONE);
	
	local nEnemyHeroesInSkillRange  = npcBot:GetNearbyHeroes(nCastRange + nRadius,true,BOT_MODE_NONE);
	local nWeakestEnemyHeroInSkillRange = J.GetVulnerableWeakestUnit(true, true, nCastRange + nRadius, npcBot);
	local nCanKillHeroLocationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius , 0.3, nDamage);
	
	if nCanKillHeroLocationAoE.count >= 1
	then 
		if J.IsValid(nWeakestEnemyHeroInSkillRange) 
		then
		    local nTargetLocation = J.GetCastLocation(npcBot,nWeakestEnemyHeroInSkillRange,nCastRange,nRadius);
			if nTargetLocation ~= nil
			then
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation;
			end
		end
	end
	
	for _,enemy in pairs(nEnemyHeroesInSkillRange)
	do
		if J.IsValid(enemy)
			and enemy:IsChanneling()
			and not enemy:IsMagicImmune()
		then
			local nTargetLocation = J.GetCastLocation(npcBot,enemy,nCastRange,nRadius);
			if nTargetLocation ~= nil
			then
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation;
			end
		end
	end
	
	if  npcBot:GetActiveMode() == BOT_MODE_RETREAT 
	    and not npcBot:IsInvisible() 
		and (npcBot:WasRecentlyDamagedByAnyHero(2.0) or #nAllies >= 3)
	then
		local nCanHurtHeroLocationAoENearby = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange -200, nRadius -20, 0.8, 0);
		if nCanHurtHeroLocationAoENearby.count >= 1 
		then
			return BOT_ACTION_DESIRE_HIGH, nCanHurtHeroLocationAoENearby.targetloc;
		end
	end
	
	
	if npcBot:GetActiveMode() ~= BOT_MODE_RETREAT 
	   and not npcBot:IsInvisible()
	then
		local npcEnemy = J.GetProperTarget(npcBot)
		if  J.IsValidHero(npcEnemy)
            and J.CanCastOnNonMagicImmune(npcEnemy) 
			and GetUnitToUnitDistance(npcEnemy,npcBot) <= nRadius + nCastRange		
		then
			
			if nManaPercentage > 0.65 
			   or npcBot:GetMana() > nKeepMana *2
			then
				local nTargetLocation = J.GetCastLocation(npcBot,npcEnemy,nCastRange,nRadius);
				if nTargetLocation ~= nil
				then
					return BOT_ACTION_DESIRE_HIGH, nTargetLocation;
				end
			end
			
			if npcEnemy:GetHealth()/npcEnemy:GetMaxHealth() < 0.45 or #nAllies >= 3             
		    then
			    local nTargetLocation = J.GetCastLocation(npcBot,npcEnemy,nCastRange,nRadius);
				if nTargetLocation ~= nil
				then
					return BOT_ACTION_DESIRE_HIGH, nTargetLocation;
				end			   
			end
			
		end	
		
		local npcEnemy = nWeakestEnemyHeroInSkillRange;
		if  J.IsValid(npcEnemy) and DotaTime() > 0
			and (npcEnemy:GetHealth()/npcEnemy:GetMaxHealth() < 0.4 or npcBot:GetMana() > nKeepMana * 2.3 or #nAllies >= 3)
			and GetUnitToUnitDistance(npcEnemy,npcBot) <= nRadius + nCastRange
		then
			local nTargetLocation = J.GetCastLocation(npcBot,npcEnemy,nCastRange,nRadius);
			if nTargetLocation ~= nil
			then
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation;
			end			   
		end 
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end

function X.ConsiderD()
	
	if not npcBot:HasScepter() 
	   or not abilityD:IsFullyCastable() 
	   or npcBot:IsInvisible() 
	then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local numPlayer =  GetTeamPlayers(GetTeam());
	for i = 1, #numPlayer
	do
		local member =  GetTeamMember(i);
		if J.IsValid(member)
			and J.IsGoingOnSomeone(member)
		then
			local target = J.GetProperTarget(member);
			if J.IsValidHero(target) 
			   and J.IsInRange(member, target, 1200)
			   and J.CanCastOnNonMagicImmune(target)
			then
				return BOT_ACTION_DESIRE_HIGH, target:GetExtrapolatedLocation(1.0);
			end
		end
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes(1200,true,BOT_MODE_NONE);
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( J.IsValid(npcEnemy) and npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) and J.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcBot:GetLocation();
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end

function X.ConsiderR()
	
	if not abilityR:IsFullyCastable() then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nCastRange = 1600;
	local nCastPoint = abilityR:GetCastPoint();
	local manaCost  = abilityR:GetManaCost();
	local nDamage  = abilityR:GetSpecialValueInt('damage');
	local nDamageType  = DAMAGE_TYPE_MAGICAL
	
	
	if J.IsRetreating(npcBot) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
	then		
		if npcBot:GetRespawnTime() > abilityR:GetCooldown()
		   and nHealthPercentage <= 0.28
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	if J.IsInTeamFight(npcBot, 1400)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1400, true, BOT_MODE_NONE );
		local nInvUnit = J.GetInvUnitCount(false, tableNearbyEnemyHeroes);
		if nInvUnit >= 5 then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	-- modifier_warlock_fatal_bonds
	local lowHPCount = 0;
	local fatalCount = 0;	
	local fatalBonus = false;
	local gEnemies = GetUnitList(UNIT_LIST_ENEMY_HEROES);
	for _,e in pairs (gEnemies) 
	do
		if e ~= nil 
		   and J.CanCastOnNonMagicImmune(e) 
		then
			local nEstDamage = nDamage + e:GetHealth() * abilityEBonus ;
			if J.WillMagicKillTarget(npcBot, e, nEstDamage, nCastPoint)
			   and not J.IsOtherAllyCanKillTarget(npcBot, e)
			then
				lowHPCount = lowHPCount + 1;
			end
			
			if e:HasModifier("modifier_warlock_fatal_bonds") 
			then
				fatalCount = fatalCount + 1;
				if e:GetHealth() <= e:GetActualIncomingDamage(nEstDamage * 2.28, nDamageType) 
				then
					fatalBonus = true;
				end
			end
		end
	end	
	if lowHPCount >= 1 
	   or ( fatalCount >= 3 and fatalBonus == true )
	then
		return BOT_ACTION_DESIRE_MODERATE;
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

function X.GetRanged(npcBot,nRadius)
	local mode = npcBot:GetActiveMode();
	local enemys = npcBot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	local allies = npcBot:GetNearbyHeroes(800,false,BOT_MODE_NONE);
	
	if  mode == BOT_MODE_TEAM_ROAM 
		or mode == BOT_MODE_ATTACK 
		or mode == BOT_MODE_DEFEND_ALLY
		or mode == BOT_MODE_RETREAT
		or #enemys >= 1
		or #allies >= 3
		or nManaPercentage <= 0.15
		or npcBot:WasRecentlyDamagedByAnyHero(2.0)
	then
		return nil;
	end
	
	if mode == BOT_MODE_LANING or nManaPercentage >= 0.56
	then
		local nTowers = npcBot:GetNearbyTowers(1600,false);
		if nTowers[1] ~= nil
		then
			local nTowerTarget = nTowers[1]:GetAttackTarget();
			if J.IsValid(nTowerTarget)
				and GetUnitToUnitDistance(nTowerTarget,npcBot) <= 1400
				and J.IsKeyWordUnit("ranged",nTowerTarget)
				and not nTowerTarget:WasRecentlyDamagedByAnyHero(1.0)
			then
				return nTowerTarget;
			end
		end
		
		if nManaPercentage > 0.7 and npcBot:GetMana() > 500
		then
			local nLaneCreeps = npcBot:GetNearbyLaneCreeps(800,true);
			for _,creep in pairs(nLaneCreeps)
			do
				if J.IsValid(creep)
					and J.IsKeyWordUnit("ranged",creep)
					and not creep:WasRecentlyDamagedByAnyHero(1.0)
				then
					return creep;
				end
			
			end
		end
		
	end

	return nil;

end

return X
-- dota2jmz@163.com QQ:2462331592.
