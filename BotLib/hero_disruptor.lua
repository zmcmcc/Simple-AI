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
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
                        {1,3,2,2,2,6,2,3,3,3,6,1,1,1,6},
                        {1,3,1,2,1,6,1,2,2,2,6,3,3,3,6},
                        {1,3,1,2,1,6,1,3,3,3,6,2,2,2,6}
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)

X['skills'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)

X['items'] = {
				sOutfit,
				"item_pipe",
				"item_glimmer_cape",
				"item_veil_of_discord",
				"item_cyclone",
				"item_sheepstick",
				"item_ultimate_scepter",
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

local abilityQ = npcBot:GetAbilityByName( sAbilityList[1] );
local abilityW = npcBot:GetAbilityByName( sAbilityList[2] );
local abilityE = npcBot:GetAbilityByName( sAbilityList[3] );
local abilityR = npcBot:GetAbilityByName( sAbilityList[6] );


local castCombo1Desire = 0;
local castCombo2Desire = 0;
local castQDesire, castQTarget
local castWDesire, castWTarget
local castEDesire, castELocation
local castRDesire, castRLocation

local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;
local aetherRange = 0

local hEnemyOnceLocation = {}

for _,TeamPlayer in pairs( GetTeamPlayers(GetOpposingTeam()) )
do
    hEnemyOnceLocation[TeamPlayer] = nil;
end

local hEnemyRecordLocation = {}

function X.SkillsComplement()
	
	
	if J.CanNotUseAbility(npcBot) or npcBot:IsInvisible() then return end
	--暂时取消位置记录
	--RecordTheLocation();
	
	nKeepMana = 400; 
	aetherRange = 0
	nLV = npcBot:GetLevel();
	nMP = npcBot:GetMana()/npcBot:GetMaxMana();
	nHP = npcBot:GetHealth()/npcBot:GetMaxHealth();
	hEnemyHeroList = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	

	local aether = J.IsItemAvailable("item_aether_lens");
	if aether ~= nil then aetherRange = 250 end	
	
	
	castWDesire, castWTarget = X.ConsiderW()
	if ( castWDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, true)
	
		npcBot:ActionQueue_UseAbilityOnEntity( abilityW, castWTarget )
		return;
	end
	
	
	castRDesire, castRLocation = X.ConsiderR()
	if ( castRDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, true)
	
		npcBot:ActionQueue_UseAbilityOnLocation( abilityR, castRLocation )
		return;
	end

	
	castQDesire, castQTarget = X.ConsiderQ()
	if ( castQDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, true)
	
		npcBot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget )
		return;
	end
	
	castEDesire, castELocation = X.ConsiderE()
	if ( castEDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, true)
	
		npcBot:ActionQueue_UseAbilityOnLocation( abilityE, castELocation )
		return;
	end
	

end

function X.ConsiderQ()

	if not abilityQ:IsFullyCastable() then return 0 end

    local nRadius = 300
	local castRange = abilityQ:GetCastRange() + aetherRange 
	local target  = J.GetProperTarget(npcBot);
    local aTarget = npcBot:GetAttackTarget(); 
	local enemies = npcBot:GetNearbyHeroes(castRange, true, BOT_MODE_NONE);
	
	if J.IsInTeamFight(npcBot, 1200)
	then
		local npcMostAoeEnemy = nil;
		local nMostAoeECount  = 1;
		local nEnemysHerosInRange = npcBot:GetNearbyHeroes(castRange + 43,true,BOT_MODE_NONE);
		local nEmemysCreepsInRange = npcBot:GetNearbyCreeps(castRange + 43,true);
		local nAllEnemyUnits = J.CombineTwoTable(nEnemysHerosInRange,nEmemysCreepsInRange);
		
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;		
		
		for _,npcEnemy in pairs( nAllEnemyUnits )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
			then
				
				local nEnemyHeroCount = J.GetAroundTargetEnemyHeroCount(npcEnemy, nRadius);
				if ( nEnemyHeroCount > nMostAoeECount )
				then
					nMostAoeECount = nEnemyHeroCount;
					npcMostAoeEnemy = npcEnemy;
				end
				
				if npcEnemy:IsHero()
				then
					local npcEnemyDamage = npcEnemy:GetEstimatedDamageToTarget( false, npcBot, 3.0, DAMAGE_TYPE_MAGICAL );
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
			return BOT_MODE_DESIRE_MODERATE, npcMostAoeEnemy;
		end	

		if ( npcMostDangerousEnemy ~= nil )
		then
			return BOT_MODE_DESIRE_MODERATE, npcMostDangerousEnemy;
		end	
	end

	--对线期间对敌方英雄使用
	if npcBot:GetActiveMode() == BOT_MODE_LANING
	then
		for _,npcEnemy in pairs( enemies )
		do
			if  J.IsValid(npcEnemy)
				and J.CanCastOnNonMagicImmune(npcEnemy) 
				and not J.IsDisabled(true, npcEnemy)
				and J.GetEnemyUnitCountAroundTarget(npcEnemy, 600) >= 4
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	if ( J.IsPushing(npcBot) or J.IsDefending(npcBot) ) 
	then
		local creeps = npcBot:GetNearbyLaneCreeps(castRange, true);
		if #creeps >= 4 and creeps[1] ~= nil
		then
			return BOT_MODE_DESIRE_MODERATE, creeps[1];
		end
	end

	
	if J.IsGoingOnSomeone(npcBot)
	then
		if J.IsValidHero(target) 
		   and J.CanCastOnNonMagicImmune(target) 
		   and J.IsInRange(target, npcBot, castRange) 
		then
			return BOT_ACTION_DESIRE_HIGH, target;
		end	
	end
	
	return BOT_ACTION_DESIRE_NONE
	
end

function X.ConsiderW()

	if not abilityW:IsFullyCastable() then return 0 end

	local castRange = abilityW:GetCastRange() + aetherRange;

	if castRange >= 1800 then castRange = 1750 end
	
	local npcMostAoeEnemy = nil;
	local nAllEnemyUnits = npcBot:GetNearbyHeroes(castRange,true,BOT_MODE_NONE);
	
	local npcMostDangerousEnemy = nil;
	local nMostDangerousDamage = 0;	

	for _,npcEnemy in pairs( nAllEnemyUnits )
	do
		if  J.IsValid(npcEnemy)
			and J.CanCastOnNonMagicImmune(npcEnemy)
			and not J.IsAllyCanKill(npcEnemy)
		then

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

	if ( npcMostDangerousEnemy ~= nil )
	then
		return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy;
	end	


	return BOT_ACTION_DESIRE_NONE, 0

end


function X.ConsiderE()

	if not abilityE:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE, 0; end

    local nCastRange = abilityE:GetCastRange() + aetherRange;
    local nCastPoint = abilityE:GetCastPoint();
    local nDelay	 = abilityE:GetSpecialValueFloat( 'delay' );
    local nManaCost  = abilityE:GetManaCost();
	local nRadius = 340

    local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( 800, false, BOT_MODE_NONE );
	
	--有把握在困住后击杀
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if  J.IsValid(npcEnemy) and J.CanCastOnNonMagicImmune(npcEnemy) and J.IsOtherAllyCanKillTarget(npcBot, npcEnemy)
		then
			if  npcEnemy:GetMovementDirectionStability() >= 0.75 then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetExtrapolatedLocation(nDelay);
			else
				return BOT_MODE_DESIRE_MODERATE, J.GetDelayCastLocation(npcBot,npcEnemy,nCastRange,nRadius,1.45);
			end
		end
	end
	
	-- 撤退时尝试留住敌人
	for _,npcAlly in pairs(tableNearbyAllyHeroes)
	do
		if J.IsRetreating(npcAlly)
		then
			for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
			do
				if ( J.IsValid(npcEnemy) and npcAlly:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) ) 
				then
					return BOT_ACTION_DESIRE_HIGH, J.GetDelayCastLocation(npcAlly,npcEnemy,nCastRange,nRadius,1.45);
				end
			end
		end
	end
	
	

	--团战
	if J.IsInTeamFight(npcBot, 1200)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange - 200, nRadius/2, nCastPoint, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			local nInvUnit = J.GetInvUnitInLocCount(npcBot, nCastRange, nRadius/2, locationAoE.targetloc, false);
			if nInvUnit >= locationAoE.count then
				return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc;
			end
		end
	end
	
	-- 追击
	if J.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = J.GetProperTarget(npcBot);
		if J.IsValidHero(npcTarget) 
		   and J.CanCastOnNonMagicImmune(npcTarget) 
		   and J.IsInRange(npcTarget, npcBot, nCastRange + nRadius) 
		then
			local nCastLoc = J.GetDelayCastLocation(npcBot,npcTarget,nCastRange,nRadius,1.45)
			if nCastLoc ~= nil 
			then
				return BOT_ACTION_DESIRE_HIGH, nCastLoc;
			end
		end
	end

	--对线
	if ( J.IsPushing(npcBot) or J.IsDefending(npcBot) ) 
	then
		if #tableNearbyEnemyHeroes >= 4 and tableNearbyEnemyHeroes[1] ~= nil
		then
			local nCastLoc = J.GetDelayCastLocation(npcBot,tableNearbyEnemyHeroes[1],nCastRange,nRadius,1.45)
			if nCastLoc ~= nil and nMP > 0.6
			then
				return BOT_MODE_DESIRE_LOW, nCastLoc;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end


function X.ConsiderR()

	if not abilityR:IsFullyCastable() then return 0 end

	-- Get some of its values
	local nRadius    = 450;
	local nCastRange = abilityR:GetCastRange() + aetherRange;
	local nCastPoint = abilityR:GetCastPoint();
	local nDelay	 = abilityR:GetSpecialValueFloat( 'delay' );
	local nManaCost  = abilityR:GetManaCost();
	local nDamage    = abilityR:GetSpecialValueInt('damage');
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( 800, false, BOT_MODE_NONE );

	--有把握在困住后击杀
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		local tableEnemyAllyHeroes = npcEnemy:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE );
		if  J.IsValid(npcEnemy) and J.CanCastOnNonMagicImmune(npcEnemy) and J.IsOtherAllyCanKillTarget(npcBot, npcEnemy) and #tableEnemyAllyHeroes >= 3
		then
			if  npcEnemy:GetMovementDirectionStability() >= 0.75 then
				return BOT_MODE_DESIRE_MODERATE, npcEnemy:GetExtrapolatedLocation(nDelay);
			else
				return BOT_MODE_DESIRE_MODERATE, npcEnemy:GetLocation();
			end
		end
	end

	--团战
	if J.IsInTeamFight(npcBot, 1200)
	then
		local locationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius/2, nCastPoint, 0 );
		if ( locationAoE.count >= 4 ) 
		then
			local nInvUnit = J.GetInvUnitInLocCount(npcBot, nCastRange, nRadius/2, locationAoE.targetloc, false);
			if nInvUnit >= locationAoE.count then
				return BOT_MODE_DESIRE_HIGH, locationAoE.targetloc;
			end
		end
	end

	-- 追击
	if J.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = J.GetProperTarget(npcBot);
		if J.IsValidHero(npcTarget) then
			local tableEnemyAllyHeroes = npcTarget:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE );
			if J.CanCastOnNonMagicImmune(npcTarget)
			and J.IsInRange(npcTarget, npcBot, nCastRange + nRadius)
			and #tableEnemyAllyHeroes >= 2
			then
				local nCastLoc = J.GetDelayCastLocation(npcBot,npcTarget,nCastRange,nRadius,2.0)
				if nCastLoc ~= nil 
				then
					return BOT_MODE_DESIRE_MODERATE, nCastLoc;
				end
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function RecordTheLocation()
    local nEnemysTeam = GetTeamPlayers(GetOpposingTeam());
    local nEnemysHeroesCanSeen = GetUnitList(UNIT_LIST_ENEMY_HEROES);
    local loctime = DotaTime();
    local players = {}

    for _,TeamPlayer in pairs( nEnemysTeam )
	do
        for _,Enemy in pairs( nEnemysHeroesCanSeen )
        do
            if Enemy:GetUnitName() == GetSelectedHeroName(TeamPlayer) then --取得英雄的玩家id
                table.insert(hEnemyRecordLocation,{
                    ['playerid'] = TeamPlayer,
                    ['time'] = loctime,
                    ['location'] = Enemy:GetLocation(),
                });
                players[TeamPlayer] = Enemy:GetLocation();
            end
        end
        if players[TeamPlayer] == nil then
            local info = GetHeroLastSeenInfo(TeamPlayer)
            if info ~= nil then
                local dInfo = info[1];
                if dInfo ~= nil then
                    table.insert(hEnemyRecordLocation,{
                        ['playerid'] = TeamPlayer,
                        ['time'] = dInfo.time_since_seen,
                        ['location'] = dInfo.location,
					});
                end
            end
        end
        --清除缓存,加入地址库
		if #hEnemyRecordLocation >= 10 then
			for i = 2, #hEnemyRecordLocation - 10
			do
				if hEnemyRecordLocation[i] ~= nil then
					if hEnemyRecordLocation[i]['time'] < loctime - 4 then
						table.remove(hEnemyRecordLocation,i)
					elseif hEnemyRecordLocation[i]['time'] >= loctime - 4 and hEnemyRecordLocation[i]['time'] <= loctime - 5 then
						hEnemyOnceLocation[hEnemyRecordLocation[i]['playerid']] = {
							['location'] = hEnemyRecordLocation[i]['location'],
							['time'] = hEnemyRecordLocation[i]['time'],
						};
						print('-2-');
						print(hEnemyOnceLocation[hEnemyRecordLocation[i]['playerid']]['time']);
					end
				end
            end
		end
		if hEnemyRecordLocation[1] ~= nil then
			if hEnemyRecordLocation[1]['time'] > loctime - 4 and hEnemyRecordLocation[1]['time'] <= loctime - 5 then
				hEnemyOnceLocation[hEnemyRecordLocation[i]['playerid']] = {
					['location'] = hEnemyRecordLocation[i]['location'],
					['time'] = hEnemyRecordLocation[i]['time'],
				};
				print('-1-');
				print(hEnemyOnceLocation[hEnemyRecordLocation[i]['playerid']]['time']);
			elseif hEnemyRecordLocation[1]['time'] > loctime - 10 then
				table.remove(hEnemyRecordLocation,1)
			end
		end
		for i = 1, #hEnemyOnceLocation
		do
			if hEnemyOnceLocation[i]['time'] < loctime - 10 then
				hEnemyOnceLocation[i] = nil
			end
		end
	end

	return;
end

return X