----------------------------------------------------------------------------------------------------
--- The Creation Come From: BOT EXPERIMENT Credit:FURIOUSPUPPY
--- BOT EXPERIMENT Author: Arizona Fauzie 2018.11.21
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=837040016
--- Update by: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
----------------------------------------------------------------------------------------------------
local X = {}
local bDebugMode = false
local npcBot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local minion = dofile( GetScriptDirectory()..'/FunLib/Minion')
local sTalentList = J.Skill.GetTalentList(npcBot)
local sAbilityList = J.Skill.GetAbilityList(npcBot)
local sOutfit = J.Skill.GetOutfitName(npcBot)

local tTalentTreeList = {
						['t25'] = {0, 10},
						['t20'] = {10, 0},
						['t15'] = {10, 0},
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{1,2,1,3,1,6,1,2,2,2,6,3,3,3,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)

X['skills'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)

X['items'] = {
				sOutfit,
				"item_soul_ring",
				"item_force_staff",
				"item_pipe",
				"item_glimmer_cape",
				--"item_veil_of_discord",
				"item_cyclone",
				"item_ultimate_scepter",
				"item_hurricane_pike",
				"item_sheepstick",
}

X['bDeafaultAbility'] = true
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
local abilityR = npcBot:GetAbilityByName( sAbilityList[6] )


local castQDesire, castQTarget
local castWDesire
local castEDesire, castETarget 
local castRDesire, castRLocation


local nKeepMana,nMP,nHP,nLV,hEnemyHeroList,hBotTarget,sMotive;

local aetherRange = 0

function X.SkillsComplement()

	

	if J.CanNotUseAbility(npcBot) or npcBot:IsInvisible() then return end
	

	nKeepMana = 400
	nLV = npcBot:GetLevel();
	nMP = npcBot:GetMana()/npcBot:GetMaxMana();
	nHP = npcBot:GetHealth()/npcBot:GetMaxHealth();
	hBotTarget = J.GetProperTarget(npcBot);
	hEnemyHeroList = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	
	
	local aether = J.IsItemAvailable("item_aether_lens");
	if aether ~= nil then aetherRange = 250 end	
	
	
	castEDesire, castETarget, sMotive = X.ConsiderE();
	if ( castEDesire > 0 ) 
	then
		J.SetReportMotive(bDebugMode,sMotive);
	
		J.SetQueuePtToINT(npcBot, true)
	
		npcBot:ActionQueue_UseAbilityOnEntity( abilityE, castETarget )
		return;
	end
	
	castRDesire, castRLocation, sMotive = X.ConsiderR();
	if ( castRDesire > 0 ) 
	then
		J.SetReportMotive(bDebugMode,sMotive);
	
		J.SetQueuePtToINT(npcBot, true)
	
		npcBot:ActionQueue_UseAbilityOnLocation( abilityR, castRLocation )
		return;
	
	end
	
	castWDesire, sMotive = X.ConsiderW();
	if ( castWDesire > 0 ) 
	then
		J.SetReportMotive(bDebugMode,sMotive);
	
		J.SetQueuePtToINT(npcBot, true)
	
		npcBot:ActionQueue_UseAbility( abilityW )
		return;
	end
	
	castQDesire, castQTarget, sMotive = X.ConsiderQ();
	if ( castQDesire > 0 ) 
	then
		J.SetReportMotive(bDebugMode,sMotive);
	
		J.SetQueuePtToINT(npcBot, true)
	
		npcBot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget )
		return;
	end
	
	

end

function X.ConsiderQ()


	if not abilityQ:IsFullyCastable() then return 0 end
	
	local nSkillLV    = abilityQ:GetLevel(); 
	local nCastRange  = abilityQ:GetCastRange() + aetherRange
	local nCastPoint  = abilityQ:GetCastPoint()
	local nManaCost   = abilityQ:GetManaCost()
	local nDamage     = abilityQ:GetSpecialValueInt( "bolt_damage" ) + npcBot:GetAttributeValue(ATTRIBUTE_INTELLECT) *1.6 
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyHeroList = npcBot:GetNearbyHeroes(nCastRange + 50, true, BOT_MODE_NONE);
	
	
	local hAllyList = npcBot:GetNearbyHeroes(1300,false,BOT_MODE_NONE)
	
	
	if ( not J.IsValidHero(hBotTarget) or J.GetHPR(hBotTarget) > 0.2 )
	then
		for _,enemy in pairs(nInRangeEnemyHeroList)
		do
			if J.IsValidHero(enemy)
				and J.CanCastOnNonMagicImmune(enemy)
				and J.GetHPR(enemy) <= 0.2
			then
				return BOT_ACTION_DESIRE_HIGH, enemy, "Q击杀"..enemy:GetUnitName()
			end
		end
	end
	
	
	--对线期的使用
	if npcBot:GetActiveMode() == BOT_MODE_LANING 
	   and ( hAllyList[2] == nil or not J.IsHumanPlayer(hAllyList[2]) )
	   and #hAllyList <= 2
	then
		local hLaneCreepList = npcBot:GetNearbyLaneCreeps(nCastRange +50,true);
		for _,creep in pairs(hLaneCreepList)
		do
			if J.IsValid(creep)
				and not creep:HasModifier("modifier_fountain_glyph")
		        and J.IsKeyWordUnit( "ranged", creep )
				and not J.IsOtherAllysTarget(creep)
				and creep:GetHealth() > nDamage * 0.68
			then
				local nDelay = nCastPoint + GetUnitToUnitDistance(npcBot,creep)/500;
				if J.WillKillTarget(creep, nDamage, nDamageType, nDelay *0.9)
				then
					return BOT_ACTION_DESIRE_HIGH, creep, 'Q对线'
				end
			end
		end
	end
	
	
	if J.IsRetreating(npcBot) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
	then
		local target = J.GetVulnerableWeakestUnit(true, true, nCastRange, npcBot);
		if target ~= nil and npcBot:IsFacingLocation(target:GetLocation(),30) then
			return BOT_ACTION_DESIRE_HIGH, target, 'Q撤退'
		end
	end
	
	
	if ( J.IsPushing(npcBot) or J.IsDefending(npcBot) or J.IsFarming(npcBot) ) 
	   and #hAllyList < 3 and nLV > 7
	   and J.IsAllowedToSpam(npcBot, 30)
	then
		local hLaneCreepList = npcBot:GetNearbyLaneCreeps(nCastRange +150,true);
		for _,creep in pairs(hLaneCreepList)
		do
			if J.IsValid(creep)
				and not creep:HasModifier("modifier_fountain_glyph")
		        and ( J.IsKeyWordUnit( "ranged", creep ) 
					   or ( nMP > 0.5 and J.IsKeyWordUnit( "melee", creep )) )
				and not J.IsOtherAllysTarget(creep)
				and creep:GetHealth() > nDamage * 0.68
			then
				local nDelay = nCastPoint + GetUnitToUnitDistance(npcBot,creep)/500;
				if J.WillKillTarget(creep, nDamage, nDamageType, nDelay *0.8)
				then
					return BOT_ACTION_DESIRE_HIGH, creep, 'Q推进'
				end
			end
		end
	end
	
	
	if J.IsFarming(npcBot) and nLV > 9
	then
		if J.IsValid(hBotTarget)
		   and hBotTarget:GetTeam() == TEAM_NEUTRAL
		   and (hBotTarget:GetMagicResist() < 0.3 or nMP > 0.95)
		   and not J.CanKillTarget(hBotTarget,npcBot:GetAttackDamage() *1.68,DAMAGE_TYPE_PHYSICAL)
		   and not J.CanKillTarget(hBotTarget,nDamage - 10,nDamageType)
		then
			return BOT_ACTION_DESIRE_HIGH, hBotTarget, 'Q打野'
		end
	end
		
	
	if J.IsGoingOnSomeone(npcBot)
	then
		if J.IsValidHero(hBotTarget) 
		   and J.CanCastOnNonMagicImmune(hBotTarget) 
		   and J.IsInRange(hBotTarget, npcBot, nCastRange +50)
		then
			return BOT_ACTION_DESIRE_HIGH, hBotTarget, 'Q进攻'
		end
	end
	
	
	if  npcBot:GetActiveMode() == BOT_MODE_ROSHAN 
		and nLV > 15 and nMP > 0.4
	then
		if J.IsRoshan(hBotTarget) 
			and J.IsInRange(hBotTarget, npcBot, nCastRange)  
		then
			return BOT_ACTION_DESIRE_HIGH, hBotTarget, 'Q肉山'
		end
	end
	
	
	return BOT_ACTION_DESIRE_NONE;
	
	
end

function X.ConsiderW()


	if not abilityW:IsFullyCastable() then return 0 end
	
	local nSkillLV    = abilityW:GetLevel(); 
	local nCastRange  = 1600
	local nCastPoint  = abilityW:GetCastPoint()
	local nManaCost   = abilityW:GetManaCost()
	local nDamage     = abilityW:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_MAGICAL
	
	local nSkillTarget = hEnemyHeroList[1];
	
	if J.IsGoingOnSomeone(npcBot)
	then
		if J.IsValidHero(hBotTarget)
			and J.CanCastOnNonMagicImmune(hBotTarget)
			and J.IsValidHero(nSkillTarget)
			and J.CanCastOnNonMagicImmune(nSkillTarget)
			and J.IsInRange(npcBot,nSkillTarget,nCastRange +50)
			and J.IsInRange(hBotTarget,nSkillTarget,250)
		then
			return BOT_ACTION_DESIRE_HIGH, 'W进攻'
		end
	end
	
	if J.IsRetreating(npcBot)
	then
		if J.IsValidHero(nSkillTarget)
		   and J.CanCastOnNonMagicImmune(nSkillTarget)
		   and J.IsInRange(npcBot,nSkillTarget,nCastRange +50)
		   and npcBot:WasRecentlyDamagedByHero(nSkillTarget, 5.0)
		then
			return BOT_ACTION_DESIRE_HIGH, 'W撤退'
		end
	end		
	
	return BOT_ACTION_DESIRE_NONE;
	
	
end

function X.ConsiderE()


	if not abilityE:IsFullyCastable() then return 0 end
	
	local nSkillLV    = abilityE:GetLevel()
	local nCastRange  = abilityE:GetCastRange() + aetherRange
	local nCastPoint  = abilityE:GetCastPoint()
	local nManaCost   = abilityE:GetManaCost()
	local nDamage     = abilityE:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyHeroList = npcBot:GetNearbyHeroes(nCastRange +50, true, BOT_MODE_NONE);
           

	for _,npcEnemy in pairs(nInRangeEnemyHeroList)
	do
		if ( npcEnemy:IsCastingAbility() or npcEnemy:IsChanneling() )
		   and not npcEnemy:HasModifier("modifier_teleporting") 
		   and not npcEnemy:HasModifier("modifier_boots_of_travel_incoming")
		   and J.CanCastOnNonMagicImmune(npcEnemy)
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy, "E打断"
		end	
	end
		   
	
	if J.IsInTeamFight(npcBot, 1200)
	then
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;
		
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 100, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if  J.IsValidHero(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and not J.IsDisabled(true, npcEnemy)
			then
				local npcEnemyDamage = npcEnemy:GetEstimatedDamageToTarget( false, npcBot, 3.0, DAMAGE_TYPE_MAGICAL );
				if ( npcEnemyDamage > nMostDangerousDamage )
				then
					nMostDangerousDamage = npcEnemyDamage;
					npcMostDangerousEnemy = npcEnemy;
				end
			end
		end
		
		if ( npcMostDangerousEnemy ~= nil )
		then
			return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy, "E团战"
		end
		
	end
	
	
	if npcBot:WasRecentlyDamagedByAnyHero(3.0) 
		and nInRangeEnemyHeroList[1] ~= nil
		and #nInRangeEnemyHeroList >= 1
	then
		for _,npcEnemy in pairs( nInRangeEnemyHeroList )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and not J.IsDisabled(true, npcEnemy) 
				and npcBot:IsFacingLocation(npcEnemy:GetLocation(),40)
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy, "E自保"
			end
		end
	end
	
	
	if J.IsGoingOnSomeone(npcBot)
	then
		if J.IsValidHero(hBotTarget) 
			and J.CanCastOnNonMagicImmune(hBotTarget) 
			and J.IsInRange(hBotTarget, npcBot, nCastRange) 
			and not J.IsDisabled(true, hBotTarget)
		then
			return BOT_ACTION_DESIRE_HIGH, hBotTarget, "E进攻"
		end
	end
	
	
	if J.IsRetreating(npcBot) 
	then
		for _,npcEnemy in pairs( nInRangeEnemyHeroList )
		do
			if J.IsValid(npcEnemy)
			    and npcBot:WasRecentlyDamagedByHero( npcEnemy, 3.1 ) 
				and J.CanCastOnNonMagicImmune(npcEnemy) 
				and not J.IsDisabled(true, npcEnemy) 
				and J.IsInRange(npcEnemy, npcBot, nCastRange) 
				and ( not J.IsInRange(npcEnemy, npcBot, 450) or npcBot:IsFacingLocation(npcEnemy:GetLocation(), 45) )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy, "E撤退"
			end
		end
	end
	
	
	if  npcBot:GetActiveMode() == BOT_MODE_ROSHAN 
	    and npcBot:GetMana() >= 1200
		and abilityE:GetLevel() >= 3
	then
		if  J.IsRoshan(hBotTarget) 
			and J.IsInRange(hBotTarget, npcBot, nCastRange)
		then
			return BOT_ACTION_DESIRE_HIGH, hBotTarget, "E肉山"
		end
	end
	
	
	return BOT_ACTION_DESIRE_NONE;
	
	
end

--modifier_skywrath_mage_concussive_shot_slow
function X.ConsiderR()


	if not abilityR:IsFullyCastable() then return 0 end
	
	
	local nCastRange  = abilityR:GetCastRange() + aetherRange
	local nRadius     = 170
	local nCastPoint  = abilityR:GetCastPoint()
	local nManaCost   = abilityR:GetManaCost()
	local nDamage     = abilityR:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyHeroList = npcBot:GetNearbyHeroes(nCastRange +200, true, BOT_MODE_NONE);
	
	
	if J.IsInTeamFight(npcBot, 1200)
	then
		local nAoeLoc = J.GetAoeEnemyHeroLocation(npcBot, nCastRange, nRadius, 2);
		if nAoeLoc ~= nil
		then
			return BOT_ACTION_DESIRE_HIGH, nAoeLoc, 'R团战'
		end		
	end
	
	
	if J.IsGoingOnSomeone(npcBot)
	then
		if J.IsValidHero(hBotTarget)
		   and J.CanCastOnNonMagicImmune(hBotTarget)
		   and J.IsInRange(npcBot,hBotTarget,nCastRange +300)
		then
			if (not J.IsRunning(hBotTarget) and not J.IsMoving(hBotTarget))
			   or J.IsDisabled(true,hBotTarget)
			   or hBotTarget:GetCurrentMovementSpeed() < 180
			then	
				return BOT_ACTION_DESIRE_HIGH,J.GetFaceTowardDistanceLocation(hBotTarget,128),'R进攻'
			end
		end
	end
	
	if J.IsRetreating(npcBot) and nHP < 0.78
	then
		for _,npcEnemy in pairs( nInRangeEnemyHeroList )
		do
			if J.IsValid(npcEnemy)
			    and npcBot:WasRecentlyDamagedByHero( npcEnemy, 3.1 ) 
				and J.CanCastOnNonMagicImmune(npcEnemy) 
			then
				return BOT_ACTION_DESIRE_HIGH, J.GetFaceTowardDistanceLocation(npcEnemy,158),'R撤退'
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
	
	
end


return X
-- dota2jmz@163.com QQ:2462331592.
