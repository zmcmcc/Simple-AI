local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local Minion = dofile( GetScriptDirectory()..'/FunLib/Minion')
local sTalentList = J.Skill.GetTalentList(bot)
local sAbilityList = J.Skill.GetAbilityList(bot)
local sOutfit = J.Skill.GetOutfitName(bot)

local tTalentTreeList = {
						['t25'] = {10, 0},
						['t20'] = {0, 10},
						['t15'] = {10, 0},
						['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
						{1,3,1,2,1,6,1,3,3,3,6,2,2,2,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)

X['sBuyList'] = {
				sOutfit,
				"item_vanguard",
				"item_blink",
				"item_blade_mail",
				"item_mjollnir", 
				"item_manta",
				"item_octarine_core",
}

X['sSellList'] = {
	"item_crimson_guard",
	"item_quelling_blade",
}

nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList'] = J.SetUserHeroInit(nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList']);

X['sSkillList'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = true

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit(hMinionUnit) 
	then
		if hMinionUnit:IsIllusion() 
		then 
			Minion.IllusionThink(hMinionUnit)	
		end
	end

end

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )


local castQDesire, castQLocation
local castWDesire, castWTarget
local castRDesire

local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;


function X.SkillsComplement()

	
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end

	
	
	nKeepMana = 180
	nMP = bot:GetMana()/bot:GetMaxMana();
	nHP = bot:GetHealth()/bot:GetMaxHealth();
	nLV = bot:GetLevel();
	hEnemyHeroList = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	
	
	castRDesire = X.ConsiderR();
	if ( castRDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, true)

		bot:ActionQueue_UseAbility( abilityR)
		return;
	end

	castQDesire, castQLocation = X.ConsiderQ();
	if ( castQDesire > 0) 
	then
	
		J.SetQueuePtToINT(bot, true)
	
		bot:ActionQueue_UseAbilityOnLocation( abilityQ, castQLocation )
		return;
	end
	
	castWDesire, castWTarget   = X.ConsiderW();
	if ( castWDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, true)
		
		if bot:HasScepter() 
		then
			bot:ActionQueue_UseAbility( abilityW, castWTarget:GetLocation() )
		else
			bot:ActionQueue_UseAbilityOnEntity( abilityW, castWTarget )
		end
		return;
	end
	

end

function X.ConsiderW()

	if ( not abilityW:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityW:GetCastRange();
	local nDamage = 0
	local nRadius = abilityE:GetAOERadius()-80
	local nCastPoint = abilityW:GetCastPoint()
	
	local nAllys = bot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
	local nEenemys = bot:GetNearbyHeroes(nRadius+300,true,BOT_MODE_NONE)
	local WeakestEnemy = J.GetVulnerableWeakestUnit(true, true, nRadius + 300, bot);
	local WeakestCreep = J.GetVulnerableWeakestUnit(false, true, nRadius + 300, bot);
	local nCreeps = bot:GetNearbyCreeps(nRadius+300,true)

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	if(bot:HasScepter() or bot:HasModifier("modifier_item_ultimate_scepter"))
	then
		-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
		if ( bot:GetActiveMode() == BOT_MODE_RETREAT and bot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
		then
			if ( bot:WasRecentlyDamagedByAnyHero( 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, bot:GetExtrapolatedLocation(nCastRange);
			end
		end
	
		--protect myself
		if((bot:WasRecentlyDamagedByAnyHero(2) and #nEenemys>=1) or #nEenemys >=2)
		then
			for _,npcEnemy in pairs( nEenemys )
			do
				if ( J.CanCastOnNonMagicImmune( npcEnemy ) )
				then
					return BOT_ACTION_DESIRE_HIGH,bot:GetLocation();
				end
			end
		end
		
		-- If we're farming and can hit 2+ creeps
		if ( bot:GetActiveMode() == BOT_MODE_FARM )
		then
			if ( #nCreeps >= 2 and nMP>0.4) 
			then
				return BOT_ACTION_DESIRE_LOW,bot:FindAoELocation( true, false, bot:GetLocation(), CastRange, nRadius, 0, 0 )
			end
		end

		
		-- If we're going after someone
		if ( bot:GetActiveMode() == BOT_MODE_ROAM or
			 bot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
			 bot:GetActiveMode() == BOT_MODE_DEFEND_ALLY or
			 bot:GetActiveMode() == BOT_MODE_ATTACK ) 
		then
			local npcEnemy = bot:GetTarget();

			if ( npcEnemy ~= nil ) 
			then
				if ( J.CanCastOnNonMagicImmune( npcEnemy ) and GetUnitToUnitDistance(bot,npcEnemy)<=nRadius)
				then
					return BOT_ACTION_DESIRE_MODERATE,bot:FindAoELocation( true, true, bot:GetLocation(), CastRange, nRadius, 0, 0 )
				end
			end
		end
	else
		--protect myself
		if((bot:WasRecentlyDamagedByAnyHero(2) and #nEenemys>=1) or #nEenemys >=2)
		then
			for _,npcEnemy in pairs( nEenemys )
			do
				if ( J.CanCastOnNonMagicImmune( npcEnemy ) )
				then
					return BOT_ACTION_DESIRE_HIGH
				end
			end
		end
		
		-- If my mana is enough
		if ( bot:GetActiveMode() == BOT_MODE_LANING ) 
		then
			if(WeakestCreep~=nil and nMP>0.4)
			then
				if WeakestCreep:GetHealth() <= (3 * bot:GetAttackDamage()) and GetUnitToUnitDistance(bot, WeakestCreep) <= 300
				then
					return BOT_ACTION_DESIRE_LOW
				end
			end
		end
		
		-- If we're farming and can hit 2+ creeps
		if ( bot:GetActiveMode() == BOT_MODE_FARM )
		then
			if ( #nCreeps >= 2 and nMP>0.4) 
			then
				return BOT_ACTION_DESIRE_LOW
			end
		end

		
		-- If we're going after someone
		if ( bot:GetActiveMode() == BOT_MODE_ROAM or
			 bot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
			 bot:GetActiveMode() == BOT_MODE_DEFEND_ALLY or
			 bot:GetActiveMode() == BOT_MODE_ATTACK ) 
		then
			local npcEnemy = bot:GetTarget();

			if ( npcEnemy ~= nil ) 
			then
				if ( J.CanCastOnNonMagicImmune( npcEnemy ) and GetUnitToUnitDistance(bot,npcEnemy)<=nRadius)
				then
					return BOT_ACTION_DESIRE_MODERATE
				end
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end

function X.ConsiderQ()

	if not abilityQ:IsFullyCastable() then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = abilityQ:GetCastRange();
	local nDamage = abilityQ:GetAbilityDamage();
	local nRadius = abilityQ:GetAOERadius();
	local nCastPoint = abilityQ:GetCastPoint();
	
	local nAllys = bot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
	local nEenemys = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE)
	local WeakestEnemy = J.GetVulnerableWeakestUnit(true, true, nRadius, bot);
	local WeakestCreep = J.GetVulnerableWeakestUnit(false, true, nRadius, bot);

	local nCreeps = bot:GetNearbyCreeps(1600,true)

	--------------------------------------
	-- Global high-priorty usage
	--------------------------------------
	-- Check for a channeling enemy
	for _,npcEnemy in pairs( nEenemys )
	do
		if ( npcEnemy:IsChanneling() ) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation();
		end
	end

	--try to kill enemy hero
	if(bot:GetActiveMode() ~= BOT_MODE_RETREAT ) 
	then
		if (WeakestEnemy~=nil)
		then
			if J.IsValid(WeakestEnemy)
				and J.CanCastOnNonMagicImmune(WeakestEnemy) 
				and not J.IsDisabled(true, WeakestEnemy)
			then
				if(WeakestEnemy:GetHealth()<=WeakestEnemy:GetActualIncomingDamage(nDamage,DAMAGE_TYPE_MAGICAL) or (WeakestEnemy:GetHealth()<=WeakestEnemy:GetActualIncomingDamage(nDamage,DAMAGE_TYPE_MAGICAL)))
				then
					return BOT_ACTION_DESIRE_HIGH,WeakestEnemy:GetExtrapolatedLocation(nCastPoint); 
				end
			end
		end
	end
	--------------------------------------
	-- Mode based usage
	--------------------------------------		
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if ( bot:GetActiveMode() == BOT_MODE_RETREAT and bot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		for _,npcEnemy in pairs( nEenemys )
		do
			if ( bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				if ( CanCast[abilityNumber]( npcEnemy ) and not enemyDisabled(npcEnemy)) 
				then
					return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetExtrapolatedLocation(nCastPoint);
				end
			end
		end
	end
	
	-- If we're farming and can kill 3+ creeps
	if ( bot:GetActiveMode() == BOT_MODE_FARM ) 
	then
		if nMP > 0.4
		then
			local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0 );
			if ( locationAoE.count >= 3 ) then
				return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
			end
		end
	end
	
	if ( bot:GetActiveMode() == BOT_MODE_LANING ) 
	then
		if nMP > 0.75
		then	
			local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0 );
			if ( locationAoE.count >= 2 ) then
				return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc;
			end
			
			if J.IsValid(WeakestEnemy)
			and J.CanCastOnNonMagicImmune(WeakestEnemy) 
			and not J.IsDisabled(true, WeakestEnemy)
			then
				
				return BOT_ACTION_DESIRE_LOW,WeakestEnemy:GetExtrapolatedLocation(nCastPoint)
			end	
		end
	end

	-- If we're pushing or defending a lane and can hit 4+ creeps
	if ( bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT or
		 bot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 bot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 bot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT ) 
	then
		if nMP > 0.4
		then
			local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0 );
			if ( locationAoE.count >= 3 ) 
			then
				return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
			end
		end
	end

	-- If we're going after someone
	if ( bot:GetActiveMode() == BOT_MODE_ROAM or
		 bot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 bot:GetActiveMode() == BOT_MODE_DEFEND_ALLY or
		 bot:GetActiveMode() == BOT_MODE_ATTACK ) 
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0 );
		if ( locationAoE.count >= 2 ) then
			return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc;
		end
		
		local npcTarget = bot:GetTarget();
		if ( npcTarget ~= nil ) 
		then
			if J.IsValid(WeakestEnemy)
			   and J.CanCastOnNonMagicImmune(WeakestEnemy) 
			   and not J.IsDisabled(true, WeakestEnemy)
			   and GetUnitToUnitDistance(bot,npcEnemy) <= nCastRange
			then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation(nCastPoint);
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;

end

function X.ConsiderR()
	
	if ( not abilityR:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	local nCastRange = 0;
	local nRadius = abilityR:GetAOERadius() - 80
	local nCastPoint = abilityR:GetCastPoint()
	
	local nAllys = bot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
	local nEenemys = bot:GetNearbyHeroes(nRadius,true,BOT_MODE_NONE)
	local WeakestEnemy = J.GetVulnerableWeakestUnit(true, true, nRadius + 300, bot);
	local WeakestCreep = J.GetVulnerableWeakestUnit(false, true, nRadius + 300, bot);
	local nCreeps = bot:GetNearbyCreeps(nRadius,true)

	if(nEenemys==nil) then nEenemys={} end
	if(nCreeps==nil) then nCreeps={} end
	local count=#nEenemys+#nCreeps
	local nDamage = abilityR:GetSpecialValueInt("AbilityDamage")+count*abilityR:GetSpecialValueInt("echo_slam_echo_damage")
	
	
	-- If we're going after someone
	if ( bot:GetActiveMode() == BOT_MODE_ROAM or
		 bot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 bot:GetActiveMode() == BOT_MODE_DEFEND_ALLY or
		 bot:GetActiveMode() == BOT_MODE_ATTACK ) 
	then
		local i=bot:FindItemSlot("item_blink")
		if(i>=0 and i<=5)
		then
			blink=bot:GetItemInSlot(i)
			i=nil
		end
	
		if(blink~=nil and blink:IsFullyCastable())
		then
			local CastRange=1200
			local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), CastRange, nRadius, 0, 0 );
			local locationAoE2 = bot:FindAoELocation( true, false, bot:GetLocation(), CastRange, nRadius, 0, 0 );
			if ( locationAoE.count+locationAoE2.count >= 6 ) 
			then
				bot:Action_UseAbilityOnLocation( blink,locationAoE.targetloc );
				return 0
			end
			
			if (WeakestEnemy~=nil)
			then
				if ( J.CanCastOnNonMagicImmune( WeakestEnemy ))
				then
					if(WeakestEnemy:GetHealth()<=WeakestEnemy:GetActualIncomingDamage(GetUltDamage(WeakestEnemy),DAMAGE_TYPE_MAGICAL) or (WeakestEnemy:GetHealth()<=WeakestEnemy:GetActualIncomingDamage(nDamage,DAMAGE_TYPE_MAGICAL)))
					then
						bot:Action_UseAbilityOnLocation( blink,WeakestEnemy:GetLocation() );
						return 0
					end
				end
			end
		end
	end
	--------------------------------------
	-- Global high-priorty usage
	--------------------------------------
	--try to kill enemy hero
	if(bot:GetActiveMode() ~= BOT_MODE_RETREAT ) 
	then
		if (WeakestEnemy~=nil)
		then
			if J.CanCastOnNonMagicImmune( WeakestEnemy )
			then
				if WeakestEnemy:GetHealth() <= WeakestEnemy:GetActualIncomingDamage(nDamage,DAMAGE_TYPE_MAGICAL)
				then
					return BOT_ACTION_DESIRE_MODERATE
				end
			end
		end
	end
	
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	-- If we're going after someone
	if ( bot:GetActiveMode() == BOT_MODE_ROAM or
		 bot:GetActiveMode() == BOT_MODE_TEAM_ROAM or
		 bot:GetActiveMode() == BOT_MODE_DEFEND_ALLY or
		 bot:GetActiveMode() == BOT_MODE_ATTACK ) 
	then
		local npcEnemy = bot:GetTarget();

		if ( npcEnemy ~= nil and #nEenemys>=2) 
		then
			if ( J.CanCastOnNonMagicImmune( npcEnemy ) and GetUnitToUnitDistance(bot,npcEnemy)<=nRadius)
			then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end

return X