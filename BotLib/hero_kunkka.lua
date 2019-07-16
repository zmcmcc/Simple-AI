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
						['t25'] = {0, 10},
						['t20'] = {10, 0},
						['t15'] = {10, 0},
						['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
						{2,1,2,3,2,6,2,3,3,3,6,1,1,1,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)

X['skills'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)

X['items'] = {
				'item_stout_shield', 
				sOutfit,
				"item_crimson_guard",
				"item_echo_sabre",
				"item_heavens_halberd",
				"item_assault",
--				"item_heart",
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

local abilityQ  = npcBot:GetAbilityByName( sAbilityList[1] )
local abilityW  = npcBot:GetAbilityByName( sAbilityList[2] )
local abilityE  = npcBot:GetAbilityByName( sAbilityList[3] )
local abilityE2 = npcBot:GetAbilityByName( 'kunkka_return' )
local abilityR  = npcBot:GetAbilityByName( sAbilityList[6] )

local castQDesire, castQLocation
local castWDesire, castWTarget
local castEDesire, castETarget
local castE2Desire
local castRDesire, castRLocation
local Combo1Desire, C1Target, C1Location
local Combo2Desire, C2Target, C2Location
local Combo3Desire, C3Target, C3Location

local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;



local Combo1Time = 0; --X船水  0.4,0.3,0.4,0.4.
local Combo2Time = 0; --X船
local Combo3Time = 0; --X水

local C1Delay = 2.1; --2.3MAX
local C2Delay = 3.2; --3.4MAX
local C3Delay = 1.8; --2.0MAX

function X.SkillsComplement()

	if not npcBot:IsAlive() 
	then
		Combo1Time = 0
		Combo2Time = 0
		Combo3Time = 0
	end
	
	
	if J.CanNotUseAbility(npcBot) or npcBot:IsInvisible() then return end
	
	
	
	nKeepMana = 240
	nMP = npcBot:GetMana()/npcBot:GetMaxMana();
	nHP = npcBot:GetHealth()/npcBot:GetMaxHealth();
	nLV = npcBot:GetLevel();
	hEnemyHeroList = npcBot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	
	
	
	--三连的最后一下
	if abilityE2:IsHidden() == false 
	   and abilityE2:IsFullyCastable()
	   and (    ( Combo3Time ~= 0 and DotaTime() >= Combo3Time + C3Delay ) 
	         or ( Combo1Time ~= 0 and DotaTime() >= Combo1Time + C1Delay ) 
		     or ( Combo2Time ~= 0 and DotaTime() >= Combo2Time + C2Delay ) )
	then
		Combo1Time = 0;
		Combo2Time = 0;
		Combo3Time = 0;
		npcBot:Action_UseAbility(abilityE2);
		return
	end
	
	if abilityE2:IsHidden() == true
	   or abilityE:IsFullyCastable()
	then
		Combo1Time = 0
		Combo2Time = 0
		Combo3Time = 0
	end		
	
	--正在连招的过程中
	if Combo1Time ~= 0
		or Combo2Time ~= 0
		or Combo2Time ~= 0
	then
		return;
	end
	
	--连招一 X船水
	Combo1Desire, C1Target, C1Location = X.ConsiderCombo1();
	if Combo1Desire > 0
	then
		Combo1Time = DotaTime()
		J.SetQueuePtToINT(npcBot, true)
		npcBot:ActionQueue_UseAbilityOnEntity(abilityE, C1Target);
		npcBot:ActionQueue_UseAbilityOnLocation(abilityR,  C1Location);
		npcBot:ActionQueue_UseAbilityOnLocation(abilityQ, C1Location);
		return;
	end
	
	--连招二 X船
	Combo2Desire, C2Target, C2Location = X.ConsiderCombo2();
	if Combo2Desire > 0
	then
		Combo2Time = DotaTime()
		J.SetQueuePtToINT(npcBot, true)
		npcBot:ActionQueue_UseAbilityOnEntity(abilityE, C2Target);
		npcBot:ActionQueue_UseAbilityOnLocation(abilityR,  C2Location);
		return;
	end
	
	--连招三 X水
	Combo3Desire, C3Target, C3Location = X.ConsiderCombo3();
	if Combo3Desire > 0
	then
		Combo3Time = DotaTime()
		J.SetQueuePtToINT(npcBot, true)
		npcBot:ActionQueue_UseAbilityOnEntity(abilityE, C3Target);
		npcBot:ActionQueue_UseAbilityOnLocation(abilityQ, C3Location);
		return;
	end
	
	--水
	castQDesire, castQLocation = X.ConsiderQ();
	if ( castQDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, true)
	
		npcBot:ActionQueue_UseAbilityOnLocation(abilityQ, castQLocation);
		return;
	end
	
	--X
	castEDesire, castETarget = X.ConsiderE();
	if ( castEDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, false)
	
		npcBot:ActionQueue_UseAbilityOnEntity( abilityE, castETarget )
		return;
	end
	
	--船
	castRDesire, castRLocation = X.ConsiderR();
	if ( castRDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, true)
	
		npcBot:ActionQueue_UseAbilityOnLocation(abilityR, castRLocation)
		return;
	
	end
	
	--刀
	castWDesire, castWTarget = X.ConsiderW();
	if ( castWDesire > 0 ) 
	then
		
		npcBot:Action_ClearActions(false);
		
		npcBot:ActionQueue_UseAbilityOnEntity( abilityW, castWTarget )
		return;
	
	end

end


function X.GetTowardsFountainLocation( unitLoc, distance )
	local destination = {};
	if ( GetTeam() == TEAM_RADIANT ) then
		destination[1] = unitLoc[1] - distance / math.sqrt(2);
		destination[2] = unitLoc[2] - distance / math.sqrt(2);
	end

	if ( GetTeam() == TEAM_DIRE ) then
		destination[1] = unitLoc[1] + distance / math.sqrt(2);
		destination[2] = unitLoc[2] + distance / math.sqrt(2);
	end
	return Vector(destination[1], destination[2]);
end

--X船水
function X.ConsiderCombo1()
	
	if not abilityQ:IsFullyCastable() 
	   or not abilityE:IsFullyCastable() 
	   or not abilityR:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local CurrMana = npcBot:GetMana();
	
	local ComboMana = abilityQ:GetManaCost() + abilityE:GetManaCost() + abilityR:GetManaCost();
	
	if ComboMana > CurrMana then
		return BOT_ACTION_DESIRE_NONE, nil
	end
	
	local nCastRange = abilityE:GetCastRange() + 38
	
	if J.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( J.IsValidHero(npcTarget) 
		     and J.CanCastOnNonMagicImmune(npcTarget) 
			 and GetUnitToUnitDistance(npcTarget, npcBot) > nCastRange/2 
			 and GetUnitToUnitDistance(npcTarget, npcBot) < nCastRange ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget, J.GetFaceTowardDistanceLocation(npcTarget, 60);
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil
end


--X船
function X.ConsiderCombo2()
	
	if not abilityR:IsFullyCastable() or not abilityE:IsFullyCastable() 
	then
		return BOT_ACTION_DESIRE_NONE, nil, {};
	end
	
	local CurrMana = npcBot:GetMana();
	
	local ComboMana = abilityR:GetManaCost() + abilityE:GetManaCost() 
	
	if ComboMana > CurrMana then
		return BOT_ACTION_DESIRE_NONE, nil, {};
	end
	
	local nCastRange = abilityE:GetCastRange() +38
	
	if J.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( J.IsValidHero(npcTarget) 
		     and J.CanCastOnNonMagicImmune(npcTarget)  
			 and GetUnitToUnitDistance(npcTarget, npcBot) < nCastRange ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget, npcTarget:GetLocation();
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil, {};
end


--X水
function X.ConsiderCombo3()
	if not abilityQ:IsFullyCastable() or not abilityE:IsFullyCastable() or abilityR:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, nil, {};
	end
	
	local CurrMana = npcBot:GetMana();
	
	local ComboMana = abilityQ:GetManaCost() + abilityE:GetManaCost() 
	
	if ComboMana > CurrMana then
		return BOT_ACTION_DESIRE_NONE, nil, {};
	end
	
	local nCastRange = abilityE:GetCastRange() + 38;
	
	--打断持续施法
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcEnemy, npcEnemy:GetLocation();
		end
	end
	
	
	if J.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( J.IsValidHero(npcTarget) 
		     and J.CanCastOnNonMagicImmune(npcTarget) 
			 and GetUnitToUnitDistance(npcTarget, npcBot) < nCastRange ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget, J.GetFaceTowardDistanceLocation(npcTarget,90)
		end
	end
	
	
	return BOT_ACTION_DESIRE_NONE, nil, {};
end



function X.ConsiderQ()
	
	if not abilityQ:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastPoint = abilityQ:GetCastPoint();
	local nDelay = abilityQ:GetSpecialValueFloat("delay");
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( J.IsRoshan(npcTarget) and J.CanCastOnMagicImmune(npcTarget) and J.IsInRange(npcTarget, npcBot, 600)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetLocation();
		end
	end
	
	if abilityE:GetLevel() >= 3
	   and abilityE:IsFullyCastable()
	   and npcBot:GetMana() > 160
	then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if (npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetExtrapolatedLocation((nDelay + nCastPoint) *0.68);
			end
		end
	end
	
	--打断持续施法
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
		end
	end
	
	
	if J.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if ( J.IsValidHero(npcTarget) 
			 and not J.IsRunning(npcTarget)
			 and not J.IsMoving(npcTarget)
		     and J.CanCastOnNonMagicImmune(npcTarget) 
			 and GetUnitToUnitDistance(npcTarget, npcBot) < 700 ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget:GetExtrapolatedLocation((nDelay + nCastPoint) *0.68);
		end
	end
	
	
	local skThere, skLoc = J.IsSandKingThere(npcBot, 1000, 2.0);
	if skThere then
		return BOT_ACTION_DESIRE_MODERATE, skLoc;
	end	
	
	return BOT_ACTION_DESIRE_NONE, {};
end


function X.ConsiderE()
	
	if not abilityE:IsFullyCastable()
		or abilityQ:IsFullyCastable()
		or abilityR:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	local nCastRange = abilityE:GetCastRange();
	
	if J.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) 
				and J.CanCastOnNonMagicImmune( npcEnemy )
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
			end
		end
	end
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() 
		   or ( npcBot:GetActiveMode() == BOT_MODE_ATTACK 
		        and #tableNearbyEnemyHeroes == 1
		        and npcBot:GetLevel() >= 6
				and npcBot:IsFacingLocation(npcEnemy:GetLocation(),30)
		        and npcEnemy:IsFacingLocation(J.GetEnemyFountain(),30)) ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end


function X.ConsiderR()
	
	if not abilityR:IsFullyCastable() or abilityE:IsFullyCastable() then
		return BOT_ACTION_DESIRE_NONE, nil;
	end
	
	
	local nCastRange = abilityR:GetCastRange();
	local nRadius = abilityR:GetSpecialValueInt("ghostship_width");
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if (npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, X.GetTowardsFountainLocation(npcBot:GetLocation(), nCastRange - 200)
			end
		end
	end
	
	--打断持续施法
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcEnemy:IsChanneling() ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
		end
	end
	
	
	--团战AOE
	if J.IsInTeamFight(npcBot, 1200)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange *0.8, nRadius, 0.8, 0 );
		local hTrueHeroList = J.GetEnemyList(npcBot,1200);
		if ( locationAoE.count >= 3 and #hTrueHeroList >= 2 )
		then
			return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, nil;
end


function X.ConsiderW()

	if not J.IsRunning(npcBot) 
	   or abilityW == nil
	   or not abilityW:IsFullyCastable()
	then return 0 end
	
	local npcTarget = J.GetProperTarget(npcBot);
	if not J.IsValid(npcTarget) then return 0 end

	local nAttackRange = npcBot:GetAttackRange() + 40;	
	
	if nAttackRange < 200  then nAttackRange = 200  end
	
	local nNearbyEnemy = X.GetNearbyUnit(npcBot, npcTarget);
	
	if  J.IsValid(nNearbyEnemy)
		and GetUnitToUnitDistance(npcTarget,npcBot) >  nAttackRange 		
	then
		return BOT_ACTION_DESIRE_HIGH, nNearbyEnemy
	end

	return BOT_ACTION_DESIRE_NONE
		
end


function X.GetNearbyUnit(npcBot, npcTarget)
	
	
	if npcBot:IsFacingLocation(npcTarget:GetLocation(),39)
	then
		local nCreeps = npcBot:GetNearbyCreeps(240,true);		
		for _,creep in pairs(nCreeps)
		do
			if J.IsValid(creep)
				and npcBot:IsFacingLocation(creep:GetLocation(),38)
			then
				return creep;
			end
		end	
		
		local nEnemys = npcBot:GetNearbyHeroes(240,true,BOT_MODE_NONE);
		for _,enemy  in pairs(nEnemys)
		do
			if J.IsValid(enemy)
				and npcBot:IsFacingLocation(enemy:GetLocation(),38)
			then
				return enemy;
			end
		end		
		
	end


	return nil;
end

return X
-- dota2jmz@163.com QQ:2462331592.
