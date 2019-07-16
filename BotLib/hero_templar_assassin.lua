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
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{1,3,1,3,1,6,1,2,2,2,6,2,3,3,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)

X['skills'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)

X['items'] = {
				sOutfit,
				"item_dragon_lance",
				"item_desolator",
				"item_black_king_bar",
				"item_hurricane_pike",
				"item_satanic",
				"item_lesser_crit",
				"item_bloodthorn",
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
		
		if hMinionUnit:GetUnitName() ==  "npc_dota_templar_assassin_psionic_trap" 
		then
			local abilitySTP = hMinionUnit:GetAbilityByName( "templar_assassin_self_trap" );
			local abilityTP = npcBot:GetAbilityByName( "templar_assassin_trap" );
			local nRadius = abilitySTP:GetSpecialValueInt("trap_radius");
			local nRange = npcBot:GetAttackRange();
			local nEnemies = hMinionUnit:GetNearbyHeroes(nRadius - 12, true, BOT_MODE_NONE);
			local nEnemyLaneCreepsNear = hMinionUnit:GetNearbyLaneCreeps(nRadius - 88, true);
			local nAllies = hMinionUnit:GetNearbyHeroes(800, false, BOT_MODE_NONE);
			local nEnemyNearby = hMinionUnit:GetNearbyHeroes(1200, true, BOT_MODE_NONE);
			local distance = GetUnitToUnitDistance(npcBot, hMinionUnit);
			if not npcBot:IsAlive() then distance = 9999 end;
			
			if abilitySTP:IsFullyCastable() 
			then
				if ( #nEnemies >= 1 ) 
				   and ( distance < 1200 or #nAllies >= 1 or X.IsEnemyRegenning(nEnemies)) 			   
				then
					hMinionUnit:Action_UseAbility( abilitySTP );
					return; 
				end
				
				if hMinionUnit:GetHealth()/hMinionUnit:GetMaxHealth() < 0.6
					or ( nEnemyNearby[1] ~= nil	and nEnemyNearby[1]:IsAlive() and nEnemyNearby[1]:GetAttackTarget() == hMinionUnit )
				then
					hMinionUnit:Action_UseAbility( abilitySTP );
					return; 
				end
				
				if #nEnemyLaneCreepsNear >= 4
					and #nAllies == 0
				then
					for _,creep in pairs(nEnemyLaneCreepsNear)
					do
						if creep:IsAlive()
						   and string.find(creep:GetUnitName(), "ranged") ~= nil 
						then
							hMinionUnit:Action_UseAbility( abilitySTP );
							return; 
						end
					end
				end
				
				local incProj = hMinionUnit:GetIncomingTrackingProjectiles()
				for _,p in pairs(incProj)
				do
					if p.is_attack
					   and GetUnitToLocationDistance(hMinionUnit, p.location) < nRadius
					then
						hMinionUnit:Action_UseAbility( abilitySTP );
						return; 
					end
				end
				
			end
		end

	end

end

function X.IsEnemyRegenning(nEnemies)

	for _,enemy in pairs(nEnemies)
	do
		if enemy ~= nil and enemy:CanBeSeen() and enemy:IsAlive()
			and ( 	enemy:GetHealth() < 240
					or enemy:HasModifier("modifier_clarity_potion")
					or enemy:HasModifier("modifier_bottle_regeneration")
					or enemy:HasModifier("modifier_rune_regen")
					or enemy:HasModifier("modifier_item_urn_heal")
					or enemy:HasModifier("modifier_item_spirit_vessel_heal") )
		then
			return true;
		end
	end

	return false;

end

local abilityQ = npcBot:GetAbilityByName( sAbilityList[1] )
local abilityW = npcBot:GetAbilityByName( sAbilityList[2] )
local abilityR = npcBot:GetAbilityByName( sAbilityList[6] )

local castQDesire
local castWDesire
local castRDesire,castRLocation
local roshanLoc = nil;
local midLoc = nil;
local topLoc = nil;
local botLoc = nil;
local ListRune = {
	RUNE_BOUNTY_1,
	RUNE_BOUNTY_2,
	RUNE_BOUNTY_3,
	RUNE_BOUNTY_4,
	RUNE_POWERUP_1,
	RUNE_POWERUP_2
}
local runeLocCheckTime = 0;
local ListRuneLoc = {};
local ListCampLoc = {};

local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;


function X.SkillsComplement()

	
	
	X.TAConsiderTarget();
	
	
	
	if J.CanNotUseAbility(npcBot) or npcBot:HasModifier('modifier_templar_assassin_meld') then return end
	
	
	
	nKeepMana = 300
	nLV = npcBot:GetLevel();
	nMP = npcBot:GetMana()/npcBot:GetMaxMana();
	nHP = npcBot:GetHealth()/npcBot:GetMaxHealth();
	hEnemyHeroList = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	if midLoc == nil 
	then 
		local opMidTower1 = GetTower(GetOpposingTeam(),TOWER_MID_1);
		local myMidTower1 = GetTower(GetTeam(),TOWER_MID_1);
		midLoc = J.GetUnitTowardDistanceLocation(opMidTower1,myMidTower1,928);
		topLoc = GetTower(GetTeam(),TOWER_TOP_1):GetLocation();
		botLoc = GetTower(GetTeam(),TOWER_BOT_1):GetLocation();
	end
	
	
	
		
	castRDesire, castRLocation = X.ConsiderR();
	if ( castRDesire > 0 )
	then
		J.SetQueuePtToINT(npcBot, false)
	
		npcBot:ActionQueue_UseAbilityOnLocation( abilityR, castRLocation );
		return;	
	end
	
	castQDesire = X.ConsiderQ();
	if ( castQDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, false)
	
		npcBot:ActionQueue_UseAbility( abilityQ );
		return;	
		
	end
	
	castWDesire = X.ConsiderW();
	if ( castWDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, false)
	
		npcBot:ActionQueue_UseAbility( abilityW );
		return;	

	end	

end


function X.ConsiderQ()

	-- Make sure it's castable
	if ( not abilityQ:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end

	-- Get some of its values
	local nRange = npcBot:GetAttackRange();
	local nAttackDamage = npcBot:GetAttackDamage();
	local nDamage = abilityQ:GetSpecialValueInt( "bonus_damage" );
	local nTotalDamage = nAttackDamage + nDamage;
	local nDamageType  = DAMAGE_TYPE_PHYSICAL;
	local nSkillLV = abilityQ:GetLevel();
	local nManaCost = abilityQ:GetManaCost();

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) and ( nLV > 10 or npcEnemy:GetUnitName() ~= "npc_dota_hero_necrolyte" ) )
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	if nHP < 0.11 and not npcBot:IsInvisible()
	   and ( npcBot:WasRecentlyDamagedByAnyHero(4.0) 
	         or npcBot:WasRecentlyDamagedByCreep(2.0)
			 or npcBot:WasRecentlyDamagedByTower(2.0) )			 
	then
		return BOT_ACTION_DESIRE_MODERATE;
	end
	
	--对线期间的使用
	if npcBot:GetActiveMode() == BOT_MODE_LANING or nLV <= 7
	then
		local nLaneCreeps = npcBot:GetNearbyLaneCreeps(800,true);
		if nMP > 0.28 and #nLaneCreeps >= 4
		then
			for _,creep in pairs(nLaneCreeps)
			do
				if J.IsValid(creep)
					and not creep:HasModifier("modifier_fountain_glyph")
					and J.IsInRange(npcBot,creep,nRange + 300)
					and J.CanKillTarget(creep,nTotalDamage,nDamageType)
				then
					return BOT_ACTION_DESIRE_MODERATE;
				end		
			end	
		end				
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(npcBot)
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) or nHP < 0.25 ) 
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	--格挡弹道
	if J.IsNotAttackProjectileIncoming(npcBot, 1600)
		or J.GetAttackProjectileDamageByRange(npcBot, 1600) >= 110
	then
		return BOT_ACTION_DESIRE_MODERATE;
	end
	
	--推进时对小兵输出
	if  (J.IsPushing(npcBot) or J.IsDefending(npcBot) or J.IsFarming(npcBot))
	    and J.IsAllowedToSpam(npcBot, nManaCost)
		and nSkillLV >= 3
	then
		local nLaneCreeps = npcBot:GetNearbyLaneCreeps(1600,true);
		if #nLaneCreeps >= 2
		then
			local targetCreep = J.GetMostHpUnit(nLaneCreeps);
			if J.IsValid(targetCreep)
				and ( targetCreep:GetHealth() >= 400 or #nLaneCreeps >= 5)
				and not targetCreep:HasModifier("modifier_fountain_glyph")
			then
				return BOT_ACTION_DESIRE_HIGH;
			end					
		end
	end
	
	--发育时对野怪输出
	if J.IsFarming(npcBot) and nSkillLV >= 2
	   and (npcBot:GetAttackDamage() < 200 or nMP > 0.49)
	   and nMP > 0.3
	then
		local nNeutralCreeps = npcBot:GetNearbyNeutralCreeps(800);
		if #nNeutralCreeps >= 2
		then
			local targetCreep = J.GetMostHpUnit(nNeutralCreeps);
			if J.IsValid(targetCreep)
				and ( targetCreep:GetHealth() >= 400 or #nNeutralCreeps >= 3 )
				and J.IsInRange(targetCreep,npcBot,nRange +50)
			then
				return BOT_ACTION_DESIRE_HIGH;
			end					
		end
	end
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(npcBot) and nSkillLV >= 2
	then
		local npcTarget = J.GetProperTarget(npcBot);
		if J.IsValidHero(npcTarget) 
		   and J.CanBeAttacked(npcTarget) 
		   and J.IsInRange(npcTarget, npcBot, 2000)
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end

		
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( J.IsRoshan(npcTarget) and J.GetHPR(npcTarget) > 0.3 and J.IsInRange(npcTarget, npcBot, nRange)  )
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	--通用的
	if nLV >= 12 and npcBot:GetMana() > 325
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes(800,true,BOT_MODE_NONE);
		local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps(1600,true);
		local tableNearbyEnemyTowers = npcBot:GetNearbyTowers(1600,true);
		if #tableNearbyEnemyHeroes > 0 
			or #tableNearbyEnemyTowers > 0
			or #tableNearbyEnemyCreeps > 1
			or ( J.IsInEnemyArea(npcBot) and nMP > 0.95 )
		then
			return  BOT_ACTION_DESIRE_LOW;
		end		
	end
	
	return BOT_ACTION_DESIRE_NONE;

end


function X.ConsiderW()

	-- Make sure it's castable
	local nEnemyTowers = npcBot:GetNearbyTowers(888,true);
	if not abilityW:IsFullyCastable() 
	   or #nEnemyTowers > 0 
	   or npcBot:HasModifier("modifier_item_dustofappearance")
	then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	local proDmg = J.GetAttackProjectileDamageByRange(npcBot, 1600)
	if proDmg > npcBot:GetAttackDamage() * ( nLV % 10 + 1 )
	   or proDmg > npcBot:GetHealth() * 0.38 
	   or ( npcBot:IsDisarmed() and npcBot:GetActiveMode() ~= BOT_MODE_RETREAT )
	   or npcBot:IsRooted()
	then
		if not npcBot:IsInvisible()
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if J.IsRunning(npcBot) then return BOT_ACTION_DESIRE_NONE;	end

	-- Get some of its values
	local nSkillLV   = abilityW:GetLevel();
	local nManaCost  = abilityW:GetManaCost();
	local nCastRange = npcBot:GetAttackRange();
	local nAttackDamage = npcBot:GetAttackDamage();
	local nDamage = abilityW:GetSpecialValueInt( "bonus_damage" );
	local nDamageType = DAMAGE_TYPE_PHYSICAL;
	local nTotalDamage = nAttackDamage + nDamage;
	local nEnemyHeroInView = npcBot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( J.IsRoshan(npcTarget) and J.IsInRange(npcTarget, npcBot, nCastRange + 40)  )
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetAttackTarget();
		if J.IsValidHero(npcTarget) 
		   and J.CanBeAttacked(npcTarget)
		   and J.IsInRange(npcTarget, npcBot, nCastRange + 64)
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
		npcTarget = npcBot:GetTarget();
		if J.IsValidHero(npcTarget) 
		   and J.CanBeAttacked(npcTarget)
		   and J.IsInRange(npcTarget, npcBot, nCastRange + 24)
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	--发育时对野怪输出
	if J.IsFarming(npcBot) 
	   and #nEnemyHeroInView == 0
	   and nMP > 0.28 + (4 - nSkillLV)/20
	then		
		local nCreeps = npcBot:GetNearbyNeutralCreeps(800);
		local targetCreep = npcBot:GetAttackTarget();
		if J.IsValid(targetCreep)
			and J.IsInRange(targetCreep,npcBot,nCastRange + 50)
			and targetCreep:GetHealth() >= ( nAttackDamage * 1.18 + nDamage ) 
			and ( #nCreeps > 1 or targetCreep:GetHealth() > nAttackDamage * 2.28 )
		then
			return BOT_ACTION_DESIRE_HIGH;
		end	
	end
	
	--推进时对小兵输出 待优化
	if  ( J.IsPushing(npcBot) or J.IsDefending(npcBot) or J.IsFarming(npcBot))
	    and J.IsAllowedToSpam(npcBot, nManaCost)
		and nSkillLV >= 3 and #nEnemyHeroInView == 0
	then
		local nLaneCreeps = npcBot:GetNearbyLaneCreeps(1200,true);
		local nAllyLaneCreeps = npcBot:GetNearbyLaneCreeps(800,false);
		if #nLaneCreeps >= 3
		then
			local targetCreep = npcBot:GetAttackTarget();
			if J.IsValid(targetCreep)
				and J.IsInRange(targetCreep,npcBot,nCastRange + 50)
				and not targetCreep:HasModifier("modifier_fountain_glyph")
				and not J.CanKillTarget(targetCreep,nAttackDamage * 1.2,nDamageType)
				and ( J.CanKillTarget(targetCreep,nTotalDamage * 1.2,nDamageType)
					  or #nAllyLaneCreeps <= 1 )
			then
				return BOT_ACTION_DESIRE_HIGH;
			end					
		end
	end
	
	--特殊用法之针对远程小兵
	local targetCreep = npcBot:GetAttackTarget()
	if J.IsValid(targetCreep)
	   and J.IsKeyWordUnit("ranged",targetCreep)
	   and not targetCreep:HasModifier("modifier_fountain_glyph")
	   and J.GetHPR(targetCreep) > 0.48
	   and J.IsInRange(targetCreep,npcBot,nCastRange + 40)
	   and not J.CanKillTarget(targetCreep,nAttackDamage * 1.2,nDamageType)
	   and J.CanKillTarget(targetCreep,nTotalDamage * 1.2,nDamageType)
	then
		return BOT_ACTION_DESIRE_HIGH;
	end	
	
	--通用的用法
	if nLV > 11 and npcBot:GetMana() > 280
	then
		local nAttackTarget = npcBot:GetAttackTarget();
		if J.IsValid(nAttackTarget)
			and J.IsInRange(nAttackTarget,npcBot,nCastRange + 50)
			and not J.CanKillTarget(nAttackTarget,nAttackDamage * 3.28,nDamageType)
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end


function X.ConsiderR()

	-- Make sure it's castable
	if ( not abilityR:IsFullyCastable() )
	then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	if #ListRuneLoc == 0
	then
		for i,r in pairs(ListRune)
		do
			local rLoc = GetRuneSpawnLocation(r);
			ListRuneLoc[i] = rLoc;
		end		
	end
	
	if #ListCampLoc == 0
	then
		local camps = GetNeutralSpawners();
		
		for i,camp in pairs(camps) 
		do			
			if camp.team == GetTeam() 
			   and camp.type ~= "small"
			   and camp.type ~= "medium"
			then
				ListCampLoc[i] = camp;
			end			
		end		
	end

	local nCastRange = abilityR:GetCastRange();
	local nCastPoint = abilityR:GetCastPoint();
	local nSkillLV   = abilityR:GetLevel();

	local creeps = npcBot:GetNearbyCreeps(1000, true)
	local enemyHeroes = npcBot:GetNearbyHeroes(600, true, BOT_MODE_NONE)
	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if  J.IsMoving(npcEnemy)
				and npcBot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) 
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetExtrapolatedLocation(1.0);
			end
		end
	end

	-- If we're going after someone
	local numPlayer = GetTeamPlayers(GetTeam());
	for i = 1, #numPlayer
	do
		local member = GetTeamMember(i);
		if J.IsValid(member)
		   and J.IsGoingOnSomeone(member)
		then
			local npcTarget = J.GetProperTarget(member);
			if J.IsValidHero(npcTarget) 
			   and J.IsRunning(npcTarget)
			   and J.IsInRange(npcTarget, npcBot, nCastRange + 800) 
			   and not J.IsInRange(npcTarget, npcBot, npcBot:GetAttackRange()) 
			   and J.CanCastOnNonMagicImmune(npcTarget) 
			then
				
				local targetFutureLoc = npcTarget:GetExtrapolatedLocation(1.8);
				if GetUnitToLocationDistance(npcBot,targetFutureLoc) <= nCastRange + 50
					and npcTarget:GetMovementDirectionStability() > 0.95
					and IsLocationPassable(targetFutureLoc)
				then
					return BOT_ACTION_DESIRE_HIGH, targetFutureLoc;
				end
				
				targetFutureLoc = npcTarget:GetExtrapolatedLocation(0.8);
				if GetUnitToLocationDistance(npcBot,targetFutureLoc) <= nCastRange + 50
				   and npcTarget:GetMovementDirectionStability() > 0.9
				   and IsLocationPassable(targetFutureLoc)
				then
					return BOT_ACTION_DESIRE_HIGH, targetFutureLoc;
				end
				
				local targetLoc = npcTarget:GetLocation();
				if GetUnitToLocationDistance(npcBot,targetLoc) <= nCastRange + 50
				then
					return BOT_ACTION_DESIRE_HIGH, targetLoc;
				end
				
			end
		end
	end
	
	-- if near Special Location 
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	if runeLocCheckTime < DotaTime() - 1.0
	   and #tableNearbyEnemyHeroes == 0 
	   and not npcBot:WasRecentlyDamagedByAnyHero(3.0)
	   and npcBot:GetActiveMode() ~= BOT_MODE_RETREAT
	then
		for i,loc in pairs(ListRuneLoc)
		do
			if GetUnitToLocationDistance(npcBot, loc) < nCastRange
			then
				if not IsLocationVisible(loc)
				then
					return BOT_ACTION_DESIRE_HIGH,loc;
				end			
			end
		end
		
		for i,loc in pairs(ListCampLoc)
		do
			if GetUnitToLocationDistance(npcBot, loc.location) < nCastRange
			   and nSkillLV >= 2
			   and ( loc.type ~= 'ancient' or nLV >= 15 )
			then
				if not IsLocationVisible(loc.location)
				then
					return BOT_ACTION_DESIRE_HIGH,loc.location;
				end			
			end
		end
		
		if midLoc ~= nil and nSkillLV >= 2
		then
			if GetUnitToLocationDistance(npcBot, midLoc) < nCastRange
				and not IsLocationVisible(midLoc)
			then
				return BOT_ACTION_DESIRE_HIGH,midLoc;
			end
		end
		
		if nSkillLV >= 3
		then
			-- if roshanLoc ~= nil 
			-- then
				-- if GetUnitToLocationDistance(npcBot, roshanLoc) < nCastRange
					-- and not IsLocationVisible(roshanLoc)
				-- then
					-- return BOT_ACTION_DESIRE_HIGH,roshanLoc;
				-- end
			-- end
			
			if topLoc ~= nil
			then
				if GetUnitToLocationDistance(npcBot, topLoc) < nCastRange
					and not IsLocationVisible(topLoc)
				then
					return BOT_ACTION_DESIRE_HIGH,topLoc;
				end
			end
			
			if botLoc ~= nil
			then
				if GetUnitToLocationDistance(npcBot, botLoc) < nCastRange
					and not IsLocationVisible(botLoc)
				then
					return BOT_ACTION_DESIRE_HIGH,botLoc;
				end
			end
		end
		
		runeLocCheckTime = DotaTime();
	end
	
	
	-- if roshan
	if npcBot:GetActiveMode() == BOT_MODE_ROSHAN and roshanLoc == nil
	then
		local npcTarget = J.GetProperTarget(npcBot);
		if J.IsRoshan(npcTarget) 
		then
			roshanLoc = npcTarget:GetLocation();
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end


function X.TAConsiderTarget()

	local npcBot = GetBot();
	
	if not J.IsRunning(npcBot) 
	   or npcBot:HasModifier("modifier_item_hurricane_pike_range")
	then return end
	
	local npcTarget = npcBot:GetAttackTarget();
	if not J.IsValidHero(npcTarget) then return end

	local nAttackRange = npcBot:GetAttackRange() + 40;	
	local nEnemyHeroInRange = npcBot:GetNearbyHeroes(nAttackRange,true,BOT_MODE_NONE);
	
	local nInAttackRangeNearestEnemyHero = nEnemyHeroInRange[1];

	if  J.IsValidHero(nInAttackRangeWeakestEnemyHero)
		and J.CanBeAttacked(nInAttackRangeWeakestEnemyHero)
		and ( GetUnitToUnitDistance(npcTarget,npcBot) > nAttackRange or J.HasForbiddenModifier(npcTarget) )		
	then
		npcBot:SetTarget(nInAttackRangeWeakestEnemyHero);
		return;
	end

end


return X
-- dota2jmz@163.com QQ:2462331592.
