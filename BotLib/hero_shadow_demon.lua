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
						['t15'] = {0, 10},
						['t10'] = {0, 10},
}


local tAllAbilityBuildList = {
						{1,3,3,2,3,6,3,1,1,1,6,2,2,2,6},
	                    {1,3,3,2,3,6,3,2,2,2,6,1,1,1,6}
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)

X['sBuyList'] = {
				sOutfit,
				"item_soul_ring",
				"item_null_talisman",
				"item_ultimate_scepter",
				"item_yasha_and_kaya",
				"item_hurricane_pike",
				"item_sheepstick",
}

X['sSellList'] = {
	"item_hand_of_midas",
}

nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList'] = J.SetUserHeroInit(nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList']);

X['sSkillList'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)

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
local castWDesire, castWLocation
local castEDesire, castELocation
local castRDesire, castRTarget


local nKeepMana,nMP,nHP,nLV,hEnemyHeroList,hBotTarget;

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
	
	
	castEDesire, castELocation = X.ConsiderE();
	if ( castEDesire > 0 ) 
	then	
		J.SetQueuePtToINT(npcBot, true)
	
		npcBot:ActionQueue_UseAbilityOnLocation( abilityE, castELocation )
		return;
	end
	
	castRDesire, castRTarget = X.ConsiderR();
	if ( castRDesire > 0 ) 
	then	
		J.SetQueuePtToINT(npcBot, true)
	
		npcBot:ActionQueue_UseAbilityOnEntity( abilityR, castRTarget )
		return;
	
	end
	
	castWDesire, castWLocation = X.ConsiderW();
	if ( castWDesire > 0 ) 
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


	if not abilityQ:IsFullyCastable() then return 0 end
	
	local nSkillLV    = abilityQ:GetLevel(); 
	local nCastRange  = abilityQ:GetCastRange() + aetherRange

	local nInRangeEnemyHeroList = npcBot:GetNearbyHeroes(nCastRange + 200, true, BOT_MODE_NONE);
	local hAllyList = npcBot:GetNearbyHeroes(nCastRange + 200,false,BOT_MODE_NONE)
	
    --逃跑时对受到伤害的队友释放
    -- 待补充：
    -- 针对可以安全逃脱的队友，不应该强行留住，需增加判断
    for _,myFriend in pairs(hAllyList) do
		if ( J.IsRetreating(npcBot) and myFriend:WasRecentlyDamagedByAnyHero(2.0) and J.CanCastOnNonMagicImmune(myFriend) ) or J.IsDisabled(false, myFriend)
		then
			return BOT_ACTION_DESIRE_MODERATE, myFriend;
		end
	end	
	
    --打断敌人施法
    for _,npcEnemy in pairs( nInRangeEnemyHeroList )
	do
		if ( npcEnemy:IsChanneling() and J.CanCastOnNonMagicImmune(npcEnemy) ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	
    -- 逃跑时困住追击的敌人
	if J.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE ); --技能范围内的敌人
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and J.CanCastOnNonMagicImmune(npcEnemy) ) --如果这个敌人在2秒内打过我并且可以被控制 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end

    -- 在团战中，如果敌方在技能可触及范围（技能范围 + 200）内有高伤害英雄，尝试关他
    if J.IsInTeamFight(npcBot, 1200)
	then
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;

		for _,npcEnemy in pairs( nInRangeEnemyHeroList )
		do
			if ( J.CanCastOnNonMagicImmune(npcEnemy) and not J.IsDisabled(true, npcEnemy) )
			then
				local nDamage = npcEnemy:GetEstimatedDamageToTarget( false, npcBot, 3.0, DAMAGE_TYPE_ALL );
				if ( nDamage > nMostDangerousDamage )
				then
					nMostDangerousDamage = nDamage;
					npcMostDangerousEnemy = npcEnemy;
				end
			end
		end

		if ( npcMostDangerousEnemy ~= nil  )
		then
			return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy;
		end
	end

    -- 追杀时
	if  J.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if J.IsValidHero(npcTarget) and J.CanCastOnNonMagicImmune(npcTarget) and J.IsInRange(npcTarget, npcBot, nCastRange + 200) and
		   not J.IsDisabled(true, npcTarget)
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function X.ConsiderW()


	if not abilityW:IsFullyCastable() then return 0 end
	
	local nSkillLV    = abilityW:GetLevel(); 
    local nRadius = abilityW:GetSpecialValueInt( "radius" );
	local nCastRange  = abilityW:GetCastRange();
	
    if npcBot:GetActiveMode() == BOT_MODE_ROSHAN 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( J.IsRoshan(npcTarget) and J.CanCastOnMagicImmune(npcTarget) and J.IsInRange(npcTarget, npcBot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget:GetLocation();
		end
	end

    if J.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if J.IsValidHero(npcTarget) and J.CanCastOnNonMagicImmune(npcTarget) and J.IsInRange(npcTarget, npcBot, nCastRange + 200) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation();
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

function X.ConsiderE()


	if not abilityE:IsFullyCastable() then return 0 end
	
	local nSkillLV    = abilityE:GetLevel()
    local nRadius     = abilityE:GetSpecialValueInt("radius");
	local nCastRange  = abilityE:GetCastRange() + aetherRange
	local nCastPoint  = abilityE:GetCastPoint()

    --满魔，攻击附近敌人
    if ( npcBot:GetActiveMode() == BOT_MODE_LANING and 
		nMP >= 0.65  ) 
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius/2, 0, 0 );
		if ( locationAoE.count >= 1 ) then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
    --防守时可以打到4人（包括小兵）以上
    if ( J.IsDefending(npcBot) or J.IsPushing(npcBot) ) and  nMP >= 0.65
	then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 4 ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc;
		end
	end
    --追击时
    if J.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();

		if J.IsValidHero(npcTarget) and J.CanCastOnNonMagicImmune(npcTarget) and J.IsInRange(npcTarget, npcBot, nCastRange + 200)
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation( (GetUnitToUnitDistance(npcTarget, npcBot) / 1000) + nCastPoint );
		end
	end

    return BOT_ACTION_DESIRE_NONE, 0;

end

function X.ConsiderR()


	if not abilityR:IsFullyCastable() then return 0 end
	
	
	local nCastRange  = abilityR:GetCastRange() + aetherRange

	local nInRangeEnemyHeroList = npcBot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
	
	-- 撤退时控制敌人
	if J.IsRetreating(npcBot)
	then
		for _,npcEnemy in pairs( nInRangeEnemyHeroList )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) and J.CanCastOnMagicImmune(npcEnemy) 
				and not npcEnemy:HasModifier("modifier_shadow_demon_purge_slow")  ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	if J.IsInTeamFight(npcBot, 1200)
	then
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;

		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( J.CanCastOnMagicImmune(npcEnemy) and not npcEnemy:HasModifier("modifier_shadow_demon_purge_slow") and not J.IsDisabled(true, npcEnemy) )
			then
				local nDamage = npcEnemy:GetEstimatedDamageToTarget( false, npcBot, 3.0, DAMAGE_TYPE_ALL );
				if ( nDamage > nMostDangerousDamage )
				then
					nMostDangerousDamage = nDamage;
					npcMostDangerousEnemy = npcEnemy;
				end
			end
		end

		if ( npcMostDangerousEnemy ~= nil )
		then
			return BOT_ACTION_DESIRE_MODERATE, npcMostDangerousEnemy;
		end
	end
	
	-- 追击时
	if J.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if J.IsValidHero(npcTarget) and J.CanCastOnMagicImmune(npcTarget) and J.IsInRange(npcTarget, npcBot, nCastRange + 200) 
		   and not npcTarget:HasModifier("modifier_shadow_demon_purge_slow") and not J.IsDisabled(true, npcTarget)
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end


return X