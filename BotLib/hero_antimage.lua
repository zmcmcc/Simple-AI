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
						['t15'] = {10, 0},
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{3,1,2,2,2,6,2,3,3,3,6,1,1,1,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)

X['sBuyList'] = {
				sOutfit,
				"item_bfury",
				"item_manta",
				"item_skadi",
				"item_black_king_bar",
				"item_satanic",
}

X['sSellList'] = {
	"item_manta",
	"item_stout_shield",
}


nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList'] = J.SetUserHeroInit(nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList']);


X['sSkillList'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = true

function X.MinionThink(hMinionUnit)

	if minion.IsValidUnit(hMinionUnit) 
	then		
		if hMinionUnit:IsIllusion() 
		then 
			-- if hMinionUnit.fRemainTime == nil 
			-- then
				-- hMinionUnit.fRemainTime = hMinionUnit:GetRemainingLifespan()
			-- end
			
			-- if hMinionUnit.fRemainTime < 11 then return end
		
			minion.IllusionThink(hMinionUnit)	
		end
	end

end

local abilityW = npcBot:GetAbilityByName( sAbilityList[2] );
local abilityE = npcBot:GetAbilityByName( sAbilityList[3] );
local abilityR = npcBot:GetAbilityByName( sAbilityList[6] );
local talent3 = npcBot:GetAbilityByName( sTalentList[3] );


local castWDesire, castWLocation;
local castEDesire;
local castRDesire, castRTarget;
local castWEDesire,castWELocation,castWEType;
local castWRDesire,castWRLocation,castWRTarget;


local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;

function X.SkillsComplement()

	if X.ConsiderSpecialE() > 0 
	then 
		J.SetQueuePtToINT(npcBot, false)
	
		npcBot:ActionQueue_UseAbility( abilityE )
		return;
    end	
	
	if J.CanNotUseAbility(npcBot) or npcBot:IsInvisible() then return end
		
	
	nKeepMana = 180; 
	nMP = npcBot:GetMana()/npcBot:GetMaxMana();
	nHP = npcBot:GetHealth()/npcBot:GetMaxHealth();
	nLV = npcBot:GetLevel();
	hEnemyHeroList = npcBot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	
	
			
	
	castEDesire	= X.ConsiderE()
	if ( castEDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, false)
	
		npcBot:ActionQueue_UseAbility( abilityE )
		return;
	end
	
	castRDesire, castRTarget = X.ConsiderR()
	if ( castRDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, false)
	
		npcBot:ActionQueue_UseAbilityOnEntity( abilityR, castRTarget )
		return;
	
	end
	
	castWRDesire,castWRLocation,castWRTarget = X.ConsiderWR()
	if ( castWRDesire > 0 )
	then
		J.SetQueuePtToINT(npcBot, false)
		
		npcBot:ActionQueue_UseAbilityOnLocation( abilityW, castWRLocation )
		npcBot:ActionQueue_UseAbilityOnEntity( abilityR, castWRTarget)
		return ;
	end
	
	castWEDesire,castWELocation,castWEType	 = X.ConsiderWE()
	if ( castWEDesire > 0 ) 
	then
		J.SetQueuePtToINT(npcBot, false)
		
		if castWEType == 'WE'
		then	
			npcBot:ActionQueue_UseAbilityOnLocation( abilityW, castWELocation );
			npcBot:ActionQueue_UseAbility( abilityE );
			return;
		else
			npcBot:ActionQueue_UseAbility( abilityE );
			npcBot:ActionQueue_UseAbilityOnLocation( abilityW, castWELocation );
			return;
		end
		
	end
	
	castWDesire, castWLocation = X.ConsiderW()
	if ( castWDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, false)
	
		npcBot:ActionQueue_UseAbilityOnLocation( abilityW, castWLocation )
		return
		
	end

end

function X.ConsiderSpecialE()

	if not npcBot:IsChanneling() or not abilityE:IsFullyCastable() then return 0 end
	
	if J.IsUnitTargetProjectileIncoming(npcBot, 300)
	then
		return BOT_ACTION_DESIRE_HIGH;
	end

	return 0 

end

function X.ConsiderWE()
	
	if nLV < 10 
	   or npcBot:IsRooted()
	   or npcBot:IsMagicImmune()
	   or abilityE:GetLevel() < 4
	   or not abilityW:IsFullyCastable() 
	   or not abilityE:IsFullyCastable() 
	   or npcBot:HasModifier("modifier_sniper_assassinate")
	   or npcBot:HasModifier("modifier_bloodseeker_rupture") 
	then return 0,nil,nil; end
	
	local abilityWManaCost  = abilityW:GetManaCost();
	local abilityEManaCost  = abilityE:GetManaCost();
	
	if abilityEManaCost + abilityWManaCost > npcBot:GetMana() then return 0,nil,nil; end
	
	local nCastRange = abilityW:GetSpecialValueInt("blink_range");
	local nCastPoint = abilityW:GetCastPoint();
	local nAttackPoint = npcBot:GetAttackPoint();	
	
	local nAllies =  J.GetAllyList(npcBot,1200);
	local nAlliesNearby =  J.GetAllyList(npcBot,600);
	
	local nEnemysHerosInView  = hEnemyHeroList;
	local nEnemysHerosInRange = npcBot:GetNearbyHeroes(nCastRange +150,true,BOT_MODE_NONE);
	
	local npcTarget = J.GetProperTarget(npcBot);
		
	if J.IsRetreating(npcBot) and #nEnemysHerosInRange > 0
	   and J.ShouldEscape(npcBot) and #nAlliesNearby <= 1
	then
		local loc = J.GetEscapeLoc();
		local location = J.Site.GetXUnitsTowardsLocation(npcBot, loc, nCastRange );
		return BOT_ACTION_DESIRE_MODERATE, location, 'EW';
	end
	
	if J.IsInTeamFight(npcBot, 1200) and nHP > 0.2 and nLV >= 12
	   and ( npcTarget == nil or GetUnitToUnitDistance(npcBot,npcTarget) > 1400 )
	then
		local npcWeakestEnemy = nil;
		local npcWeakestEnemyHealth = 10000;		
		
		for _,npcEnemy in pairs( nEnemysHerosInRange )
		do
			if  J.IsValid(npcEnemy)
				and IsPlayerBot(npcEnemy:GetPlayerID())				
				and not npcEnemy:IsAttackImmune()
			    and J.CanCastOnMagicImmune(npcEnemy) 
				and not J.IsInRange(npcEnemy, npcBot, 850) 
				and J.IsInRange(npcEnemy, npcBot, nCastRange + 150) 
				and J.GetAroundTargetAllyHeroCount(npcEnemy, 660, npcBot) == 0
			then
				local npcEnemyHealth = npcEnemy:GetHealth();
				local tableNearbyAllysHeroes = npcEnemy:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
				if npcEnemyHealth < npcWeakestEnemyHealth 
					and #tableNearbyAllysHeroes >= 1
				then
					npcWeakestEnemyHealth = npcEnemyHealth;
					npcWeakestEnemy = npcEnemy;
				end
			end
		end
		
		if  npcWeakestEnemy ~= nil 
			and not npcWeakestEnemy:IsSilenced()
			and not npcWeakestEnemy:IsMuted()
			and not npcWeakestEnemy:IsHexed()
			and not npcWeakestEnemy:IsStunned()
		then
			local fLocation = npcWeakestEnemy:GetExtrapolatedLocation( nAttackPoint + nCastPoint + 0.1 );
			local bLocation = npcWeakestEnemy:GetExtrapolatedLocation( nCastPoint  );
			if GetUnitToLocationDistance(npcBot,bLocation) < GetUnitToLocationDistance(npcBot,fLocation)
			then
				bLocation = fLocation;
			end
		
			if GetUnitToLocationDistance(npcBot,bLocation) < nCastRange + 150
			then
				npcBot:SetTarget(npcWeakestEnemy);
				return BOT_ACTION_DESIRE_HIGH, bLocation, 'WE';
			end
		end		
	end
	
	if J.IsGoingOnSomeone(npcBot) and nLV >= 15 
	   and ( #nAllies >= 2 or #nEnemysHerosInView <= 1 )
	then
		if J.IsValidHero(npcTarget) 
			and npcTarget:GetMana() > 49
			and IsPlayerBot(npcTarget:GetPlayerID())
			and not J.IsInRange(npcTarget, npcBot, 650) 
			and J.IsInRange(npcTarget, npcBot, nCastRange + 150) 
			and not npcTarget:IsAttackImmune()
			and not npcTarget:IsMuted()
			and not npcTarget:IsHexed()
			and not npcTarget:IsStunned()
			and not npcTarget:IsSilenced()
			and J.CanCastOnMagicImmune(npcTarget) 
			and J.GetAroundTargetAllyHeroCount(npcTarget, 650, npcBot) == 0
		then
			local tableNearbyEnemyHeroes = npcTarget:GetNearbyHeroes( 800, false, BOT_MODE_NONE );
			local tableNearbyAllysHeroes = npcTarget:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
			local tableAllEnemyHeroes    = J.GetAllyList(npcTarget,1600);
			if  ( #tableNearbyEnemyHeroes <= #tableNearbyAllysHeroes )
				or ( #tableAllEnemyHeroes <= 1 )
			then
				local fLocation = npcTarget:GetExtrapolatedLocation( nAttackPoint + nCastPoint + 0.38);
				local bLocation = npcTarget:GetExtrapolatedLocation( nCastPoint  );
				if GetUnitToLocationDistance(npcBot,bLocation) < GetUnitToLocationDistance(npcBot,fLocation)
				then
					bLocation = fLocation;
				end
				
				if GetUnitToLocationDistance(npcBot,bLocation) < nCastRange + 150
				then
					npcBot:SetTarget(npcTarget);
					return BOT_ACTION_DESIRE_HIGH, bLocation, 'WE';
				end
			end
		end
	end
	
	
	return 0,nil,nil;
end

function X.ConsiderW()
	if not abilityW:IsFullyCastable() 
	   or npcBot:IsRooted() 
	   or npcBot:HasModifier("modifier_bloodseeker_rupture") 
	then return 0,nil; end
			
	local nCastRange = abilityW:GetSpecialValueInt("blink_range");
	local nCastPoint = abilityW:GetCastPoint();
	local nAttackPoint = npcBot:GetAttackPoint();
	
	local nAllies = J.GetAllyList(npcBot,1200);
	
	local nEnemysHerosInView  = hEnemyHeroList;
	local nEnemysHerosInRange = npcBot:GetNearbyHeroes(nCastRange +150,true,BOT_MODE_NONE);
	local nEnemysHerosInBonus = npcBot:GetNearbyHeroes(nCastRange + 350,true,BOT_MODE_NONE);

	local nEnemysTowers   = npcBot:GetNearbyTowers(1300,true);
	local aliveEnemyCount = J.GetNumOfAliveHeroes(true);
	
	local npcTarget = J.GetProperTarget(npcBot);
	
	if J.IsStuck(npcBot)
	then
		local loc = J.GetEscapeLoc();
		return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(npcBot, loc, nCastRange );
	end
	
	if J.IsRetreating(npcBot) or ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and nHP < 0.16 and npcBot:DistanceFromFountain() > 600 )
	then
		if J.ShouldEscape(npcBot) or ( npcBot:DistanceFromFountain() > 600 and  npcBot:DistanceFromFountain() < 3800 )
		then
			local loc = J.GetEscapeLoc();
			local location = J.Site.GetXUnitsTowardsLocation(npcBot, loc, nCastRange );
			return BOT_ACTION_DESIRE_MODERATE, location;
		end
	end
	
	if J.IsGoingOnSomeone(npcBot) and nLV >= 3 
	   and ( #nAllies >= 2 or #nEnemysHerosInView <= 1 )
	then
		if J.IsValidHero(npcTarget) 
			and not npcTarget:IsAttackImmune()
			and J.CanCastOnMagicImmune(npcTarget) 
			and not J.IsInRange(npcTarget, npcBot, 400) 
			and J.IsInRange(npcTarget, npcBot, nCastRange + 200) 
		then
			local tableNearbyEnemyHeroes = npcTarget:GetNearbyHeroes( 800, false, BOT_MODE_NONE );
			local tableNearbyAllysHeroes = npcTarget:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
			local tableAllEnemyHeroes    = J.GetAllyList(npcTarget,1600);				
			if  ( J.WillKillTarget(npcTarget, npcBot:GetAttackDamage() * 3, DAMAGE_TYPE_PHYSICAL, 2.0) )
				or ( #tableNearbyEnemyHeroes <= #tableNearbyAllysHeroes )
				or ( #tableAllEnemyHeroes <= 1 )
				or ( aliveEnemyCount <= 2 )
			then
				local fLocation = npcTarget:GetExtrapolatedLocation( nAttackPoint + nCastPoint );
				local bLocation = npcTarget:GetExtrapolatedLocation( nCastPoint  );
				if GetUnitToLocationDistance(npcBot,bLocation) < GetUnitToLocationDistance(npcBot,fLocation)
				then
					bLocation = fLocation;
				end
				if GetUnitToLocationDistance(npcBot,bLocation) < nCastRange + 150
				then
					npcBot:SetTarget(npcTarget);
					return BOT_ACTION_DESIRE_HIGH, bLocation;
				end
			end
		end
	end
	
	if J.IsInTeamFight(npcBot, 1200) and nHP > 0.2
	   and ( npcTarget == nil or GetUnitToUnitDistance(npcBot,npcTarget) > 1400 )
	then
		local npcWeakestEnemy = nil;
		local npcWeakestEnemyHealth = 10000;		
		
		for _,npcEnemy in pairs( nEnemysHerosInRange )
		do
			if  J.IsValid(npcEnemy)
				and not npcEnemy:IsAttackImmune()
			    and J.CanCastOnMagicImmune(npcEnemy)  
				and not J.IsInRange(npcEnemy, npcBot, 700) 
			then
				local npcEnemyHealth = npcEnemy:GetHealth();
				local tableNearbyAllysHeroes = npcEnemy:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
				if npcEnemyHealth < npcWeakestEnemyHealth 
					and ( #tableNearbyAllysHeroes >= 1 or aliveEnemyCount <= 2 )
				then
					npcWeakestEnemyHealth = npcEnemyHealth;
					npcWeakestEnemy = npcEnemy;
				end
			end
		end
		
		if ( npcWeakestEnemy ~= nil )
		then
			local fLocation = npcWeakestEnemy:GetExtrapolatedLocation( nAttackPoint + nCastPoint  );
			local bLocation = npcWeakestEnemy:GetExtrapolatedLocation( nCastPoint  );
			if GetUnitToLocationDistance(npcBot,bLocation) < GetUnitToLocationDistance(npcBot,fLocation)
			then
				bLocation = fLocation;
			end
		
			if GetUnitToLocationDistance(npcBot,bLocation) < nCastRange + 150
			then
				npcBot:SetTarget(npcWeakestEnemy);
				return BOT_ACTION_DESIRE_HIGH, bLocation;
			end
		end		
	end
	
	if ( npcBot:GetActiveMode() == BOT_MODE_LANING or nLV <= 7 )
	   and #nEnemysHerosInView == 0 and #nEnemysTowers == 0
	then
		local nLaneCreeps = npcBot:GetNearbyLaneCreeps(nCastRange +80,true);
		local keyWord = "ranged";
		for _,creep in pairs(nLaneCreeps)
		do
			if J.IsValid(creep)
				and not creep:HasModifier("modifier_fountain_glyph")
				and J.IsKeyWordUnit(keyWord,creep)
				and GetUnitToUnitDistance(creep,npcBot) > 500
			then
				local nTime = nCastPoint + npcBot:GetAttackPoint() ;
				local nDamage = npcBot:GetAttackDamage() + 38;
				if J.WillKillTarget(creep,nDamage,DAMAGE_TYPE_PHYSICAL,nTime *0.9)
				then
					npcBot:SetTarget(creep);
					return BOT_ACTION_DESIRE_HIGH, creep:GetLocation();
				end				
			end
		end
		
		if nMP > 0.96
		   and npcBot:DistanceFromFountain() > 60 
		   and npcBot:DistanceFromFountain() < 6000 
		   and npcBot:GetAttackTarget() == nil
		   and npcBot:GetActiveMode() == BOT_MODE_LANING 
		then
			local nLane = npcBot:GetAssignedLane();
			local nLaneFrontLocation = GetLaneFrontLocation(GetTeam(),nLane,0);
			local nDist = GetUnitToLocationDistance(npcBot,nLaneFrontLocation);
			
			if nDist > 2000
			then
				local location = J.Site.GetXUnitsTowardsLocation(npcBot, nLaneFrontLocation, nCastRange );
				if IsLocationPassable(location)
				then
					return BOT_ACTION_DESIRE_HIGH, location;
				end
			end			
		end
	end	
	
	if J.IsFarming(npcBot)
	then
		if npcTarget ~= nil and npcTarget:IsAlive()
		   and GetUnitToUnitDistance(npcBot,npcTarget) > 550
		   and ( nLV > 9 or not npcTarget:IsAncientCreep() )
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation();
		end
	end	
		

	local nAttackAllys  = npcBot:GetNearbyHeroes(1600,false,BOT_MODE_ATTACK);
	if #nEnemysHerosInView == 0 and not npcBot:WasRecentlyDamagedByAnyHero(3.0) and nLV >= 10
	   and #nAttackAllys == 0 and ( npcTarget == nil or not npcTarget:IsHero())
	then
		local nAOELocation = npcBot:FindAoELocation(true,false,npcBot:GetLocation(),1600,400,0,0);
		local nLaneCreeps  = npcBot:GetNearbyLaneCreeps(1600,true);
		if nAOELocation.count >= 3 
		   and #nLaneCreeps >= 3
		then
			local bCenter = J.GetCenterOfUnits(nLaneCreeps);
			local bDist = GetUnitToLocationDistance(npcBot,bCenter);
			local vLocation = J.Site.GetXUnitsTowardsLocation(npcBot, bCenter, bDist + 550);
			local bLocation = J.Site.GetXUnitsTowardsLocation(npcBot, bCenter, bDist - 350);
			if bDist >= 1500 then bLocation = J.Site.GetXUnitsTowardsLocation(npcBot, bCenter, 1150); end
			
			if IsLocationPassable(bLocation) 
			   and IsLocationVisible(vLocation)
			   and GetUnitToLocationDistance(npcBot,bLocation) > 600
			then
				return BOT_ACTION_DESIRE_HIGH, bLocation;
			end
		end				
	end
	
	return 0,nil;
end

function X.ConsiderE()

	if not abilityE:IsFullyCastable() then return 0; end
	
	if J.IsUnitTargetProjectileIncoming(npcBot, 400)
	then
		return BOT_ACTION_DESIRE_HIGH;
	end
	
	if not npcBot:HasModifier("modifier_sniper_assassinate") 
		and not npcBot:IsMagicImmune() 
	then
		if J.IsWillBeCastUnitTargetSpell(npcBot,1400)
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
		
	return 0;
end

function X.ConsiderWR()

	if nLV < 6 
	   or npcBot:IsRooted()
	   or not abilityW:IsFullyCastable() 
	   or not abilityR:IsFullyCastable() 
	then return 0,nil,nil; end
	
	local abilityWManaCost   = abilityW:GetManaCost();
	local abilityRManaCost   = abilityR:GetManaCost();
	
	if abilityWManaCost + abilityRManaCost > npcBot:GetMana() then return 0,nil,nil; end

	local rCastRange = abilityR:GetCastRange();
	local rCastPoint = abilityR:GetCastPoint();
	local wCastRange = abilityW:GetSpecialValueInt("blink_range");
	local wCastPoint = abilityW:GetCastPoint();
	local nDelayTime = rCastPoint + wCastPoint;
	local nAoeRange  = 500;
	local nDamageType = DAMAGE_TYPE_MAGICAL;
	local nDamagaPerHealth = abilityR:GetSpecialValueFloat("mana_void_damage_per_mana");
	local nCastTarget = nil;
	
	local nMaxRange = rCastRange + wCastRange + 50;
	
	local nEnemysHerosCanSeen = GetUnitList(UNIT_LIST_ENEMY_HEROES);
	
	for _,npcEnemy in pairs( nEnemysHerosCanSeen )
	do
		
		if npcEnemy ~= nil and npcEnemy:IsAlive()
		   and J.IsInRange(npcEnemy, npcBot, nMaxRange)
		   and not J.IsInRange(npcEnemy, npcBot, rCastRange + 300)
		   and J.CanCastOnTargetAdvanced(npcEnemy) 
		   and J.CanCastOnNonMagicImmune(npcEnemy) 
		then
			local EstDamage = nDamagaPerHealth * ( npcEnemy:GetMaxMana() - npcEnemy:GetMana() );
			
			for _,enemy in pairs(nEnemysHerosCanSeen)
			do
				if GetUnitToLocationDistance(npcEnemy,enemy:GetExtrapolatedLocation(nDelayTime)) < nAoeRange
				   and J.CanCastOnNonMagicImmune(enemy) 
				   and not J.IsHaveAegis(enemy)
				   and not enemy:HasModifier("modifier_arc_warden_tempest_double")
				   and J.WillMagicKillTarget(npcBot,enemy, EstDamage, nDelayTime)
				then
					X.ReportDetails(npcBot,enemy,EstDamage);
					nCastTarget = npcEnemy;
					break;
				end			
			end				
		
			if (nCastTarget ~= nil  )
			then
				J.Print("释放跳大目标是:",nCastTarget:GetUnitName());
				return BOT_ACTION_DESIRE_HIGH,nCastTarget:GetLocation(),nCastTarget;
			end
		end
	end
	
	
	return 0,nil,nil;
end

function X.ConsiderR()
	
	if not abilityR:IsFullyCastable() then return 0,nil; end
	
	-- Get some of its values
	local nCastRange = abilityR:GetCastRange();
	local CastPoint = abilityR:GetCastPoint();
	local nAoeRange  = 500;
	local nDamageType = DAMAGE_TYPE_MAGICAL;
	local nDamagaPerHealth = abilityR:GetSpecialValueFloat("mana_void_damage_per_mana");
	local nCastTarget = nil;

	-- If we're going after someone
	if J.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = J.GetProperTarget(npcBot);
		if J.IsValidHero(npcTarget) 
		   and J.IsInRange(npcTarget, npcBot, nCastRange +200) 
		   and J.CanCastOnNonMagicImmune(npcTarget) 
		   and J.CanCastOnTargetAdvanced(npcTarget)
		   and not J.IsHaveAegis(npcTarget)
		   and not npcTarget:HasModifier("modifier_arc_warden_tempest_double")
		then
			local EstDamage = nDamagaPerHealth * ( npcTarget:GetMaxMana() - npcTarget:GetMana() )
			if J.WillMagicKillTarget(npcBot,npcTarget, EstDamage, CastPoint) 
			then
				X.ReportDetails(npcBot,npcTarget,EstDamage);
				nCastTarget = npcTarget;
				return BOT_ACTION_DESIRE_HIGH, nCastTarget;
			end
		end
	end
	

	-- If we're in a teamfight, use it on the scariest enemy
	if J.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 700, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			local EstDamage = nDamagaPerHealth * ( npcEnemy:GetMaxMana() - npcEnemy:GetMana() )
			if J.IsValidHero(npcEnemy) 
			   and J.CanCastOnTargetAdvanced(npcEnemy) 
			   and J.CanCastOnNonMagicImmune(npcEnemy) 
			   and not J.IsHaveAegis(npcEnemy)
		       and not npcEnemy:HasModifier("modifier_arc_warden_tempest_double")
			   and J.IsInRange(npcEnemy, npcBot, nCastRange +150) 
			   and ( J.WillMagicKillTarget(npcBot,npcEnemy, EstDamage, CastPoint) ) 
			then
				X.ReportDetails(npcBot,npcEnemy,EstDamage);
				nCastTarget = npcEnemy;
				break;
			end
		end

		if (nCastTarget ~= nil  )
		then
			npcBot:SetTarget(nCastTarget);
			return BOT_ACTION_DESIRE_HIGH, nCastTarget;
		end
	end
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange + 100, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		local EstDamage = nDamagaPerHealth * ( npcEnemy:GetMaxMana() - npcEnemy:GetMana() )
		local TPerMana = npcEnemy:GetMana()/npcEnemy:GetMaxMana();
		if J.IsValidHero(npcEnemy) 
		   and J.CanCastOnTargetAdvanced(npcEnemy) 
		   and J.CanCastOnNonMagicImmune(npcEnemy) 
		then
		
			if npcEnemy:IsChanneling()
				and npcEnemy:HasModifier("modifier_teleporting") 
				and not npcEnemy:HasModifier("modifier_arc_warden_tempest_double")
			then
				nCastTarget = npcEnemy;
			end
			
			if  TPerMana < 0.01
				and not J.IsHaveAegis(npcEnemy)
		        and not npcEnemy:HasModifier("modifier_arc_warden_tempest_double")
				and ( J.WillMagicKillTarget(npcBot,npcEnemy, EstDamage * 1.68, CastPoint)
					  or ( J.GetAroundTargetEnemyHeroCount(npcEnemy,nAoeRange) >= 3 and J.CanKillTarget(npcEnemy,EstDamage * 1.98,nDamageType) )
					  or nHP < 0.25 )
			then
				nCastTarget = npcEnemy;
			end
			
			local nEnemys = npcBot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE );
			for _,enemy in pairs(nEnemys)
			do
				if GetUnitToLocationDistance(npcEnemy,enemy:GetExtrapolatedLocation(CastPoint)) < nAoeRange
				   and J.CanCastOnNonMagicImmune(enemy) 
				   and not J.IsHaveAegis(enemy)
				   and not enemy:HasModifier("modifier_arc_warden_tempest_double")
				   and J.WillMagicKillTarget(npcBot,enemy, EstDamage, CastPoint)
				then
					nCastTarget = npcEnemy;
					X.ReportDetails(npcBot,enemy,EstDamage);
					break;
				end			
			end			
		
			if (nCastTarget ~= nil  )
			then
				npcBot:SetTarget(nCastTarget);
				return BOT_ACTION_DESIRE_HIGH, nCastTarget;
			end
		end
	end

	
	return 0,nil;
end

local ReportTime = 99999;
function X.ReportDetails(npcBot,npcTarget,EstDamage)

	if DotaTime() > ReportTime + 5.0
	then
		local nMessage;
		local nNumber;
		local MagicResist = 1 - npcTarget:GetMagicResist();
		local rCastPoint = abilityR:GetCastPoint();
		local wCastPoint = abilityW:GetCastPoint();
		
		ReportTime = DotaTime();
		
		nMessage = "基础伤害:"
		nNumber  = EstDamage * MagicResist;
		npcBot:ActionImmediate_Chat(nMessage..tostring(J.GetOne(nNumber)),true);
		
		-- nMessage = "计算伤害值:";
		-- nNumber  =  J.GetFutureMagicDamage(npcBot,npcTarget, EstDamage, wCastPoint + rCastPoint);
		-- npcBot:ActionImmediate_Chat(nMessage..tostring(J.GetOne(nNumber)),true);
		
		nMessage = npcTarget:GetUnitName();
		nNumber  = npcTarget:GetHealth();
		npcBot:ActionImmediate_Chat(string.gsub(tostring(nMessage),"npc_dota_","")..'当前生命值:'..tostring(nNumber),true);

	end

end

return X
-- dota2jmz@163.com QQ:2462331592
