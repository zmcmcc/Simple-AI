local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local Minion = dofile( GetScriptDirectory()..'/FunLib/Minion')
local sTalentList = J.Skill.GetTalentList(bot)
local sAbilityList = J.Skill.GetAbilityList(bot)
local sOutfit = J.Skill.GetOutfitName(bot)

local tTalentTreeList = {
						['t25'] = {10, 0},
						['t20'] = {10, 0},
						['t15'] = {0, 10},
						['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
						{3,1,3,2,2,6,2,2,3,3,6,1,1,1,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)

X['sBuyList'] = {
				sOutfit,
				"item_vladmir",
				"item_blink",
				"item_greater_crit",
				"item_ultimate_scepter", 
				"item_solar_crest",
				"item_assault",
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
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )


local castQDesire, castQTarget
local castEDesire
local castRDesire, castRTarget

local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;


function X.SkillsComplement()

	
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end

	
	
	nKeepMana = 180
	nMP = bot:GetMana()/bot:GetMaxMana();
	nHP = bot:GetHealth()/bot:GetMaxHealth();
	nLV = bot:GetLevel();
	hEnemyHeroList = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	
	
	castRDesire, castRTarget = X.ConsiderR();
	if ( castRDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, true)

		if castRTarget ~= nil then
			local blink = X.IsItemAvailable("item_blink");
			if blink ~= nil and blink:IsFullyCastable() then
				bot:Action_UseAbilityOnLocation(blink, castRTarget);
				bot:ActionQueue_UseAbility( abilityR )
			end
		else
			bot:ActionQueue_UseAbility( abilityR )
		end
		return;
	end
	
	castQDesire, castQTarget   = X.ConsiderQ();
	if ( castQDesire > 0 and X.ManaR(abilityQ:GetManaCost())) 
	then
	
		J.SetQueuePtToINT(bot, true)
		
		if bot:HasScepter() 
		then
			bot:ActionQueue_UseAbilityOnLocation( abilityQ, castQTarget:GetLocation() )
		else
			bot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget )
		end
		return;
	end
	
	castEDesire = X.ConsiderE();
	if ( castEDesire > 0 and X.ManaR(abilityE:GetManaCost())) 
	then
	
		J.SetQueuePtToINT(bot, true)
	
		bot:ActionQueue_UseAbility( abilityE )
		return;
	end
	

end

function X.ConsiderQ()

	if not abilityQ:IsFullyCastable() then return 0 end
	
	local nCastRange = abilityQ:GetCastRange();
	local nAttackRange = bot:GetAttackRange();
	local nDamage = abilityQ:GetLevel() *50 + 60;
	
	local nEnemysHerosInCastRange = bot:GetNearbyHeroes(nCastRange + 80 ,true,BOT_MODE_NONE);
	local nWeakestEnemyHeroInCastRange = J.GetVulnerableWeakestUnit(true, true, nCastRange + 80, bot);
	local npcTarget = J.GetProperTarget(bot)
	local castRTarget = nil
	
	
	if J.IsValid(nEnemysHerosInCastRange[1])
	then
		--最弱目标和当前目标
		if(nWeakestEnemyHeroInCastRange ~= nil)
		then           
			if nWeakestEnemyHeroInCastRange:GetHealth() < nWeakestEnemyHeroInCastRange:GetActualIncomingDamage(nDamage,DAMAGE_TYPE_MAGICAL)
			then				
				castRTarget = nWeakestEnemyHeroInCastRange;
				return BOT_ACTION_DESIRE_HIGH, castRTarget;
			end
			
			if J.IsValidHero(npcTarget)                        
			then
				if J.IsInRange(npcTarget, bot, nCastRange + 80)   
					and J.CanCastOnMagicImmune(npcTarget)
				then					
					castRTarget = npcTarget;
					return BOT_ACTION_DESIRE_HIGH,castRTarget;
				else
					castRTarget = nWeakestEnemyHeroInCastRange;                    
					return BOT_ACTION_DESIRE_HIGH,castRTarget;
				end
			end	
		end
		
		if J.CanCastOnMagicImmune(nEnemysHerosInCastRange[1])
		then
			castRTarget = nEnemysHerosInCastRange[1];   
			return BOT_ACTION_DESIRE_HIGH,castRTarget;
		end
	end	
	
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN and bot:HasScepter()
	then
	    local nAttackTarget = bot:GetAttackTarget();
		if  nAttackTarget ~= nil and nAttackTarget:IsAlive()
		then
			return BOT_ACTION_DESIRE_HIGH,nAttackTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE	
end

function X.ConsiderE()

	-- Make sure it's castable
	if ( not abilityE:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end

	-- Get some of its values
	local nRadius    = abilityE:GetSpecialValueInt( "radius" );
	local nCastPoint = abilityE:GetCastPoint( );
	local nManaCost  = abilityE:GetManaCost( );
	local nSkillLV   = abilityE:GetLevel();
	local nDamage    = 15 + 40 * nSkillLV;
	
	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nRadius - 80, true, BOT_MODE_NONE );

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot) and #tableNearbyEnemyHeroes > 0
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if bot:WasRecentlyDamagedByHero( npcEnemy, 1.0 )
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	-- If we're doing Roshan
	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = bot:GetAttackTarget();
		if ( J.IsRoshan(npcTarget) and J.CanCastOnMagicImmune(npcTarget) and J.IsInRange(bot, npcTarget, nRadius - 80)  )
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	-- If We're pushing or defending
	if J.IsPushing(bot) or J.IsDefending(bot) or J.IsGoingOnSomeone(bot)
	then
		local tableNearbyEnemyCreeps = bot:GetNearbyLaneCreeps( nRadius - 80, true );
		if ( tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 1 and J.IsAllowedToSpam(bot, nManaCost) ) then
			for _,npcEnemyCreeps in pairs( tableNearbyEnemyCreeps )
			do
				if npcEnemyCreeps:GetHealth() <= nDamage or #tableNearbyEnemyCreeps >= 5 then
					return BOT_ACTION_DESIRE_MODERATE;
				end
			end
		end
	end
	
	if J.IsInTeamFight(bot, 1200)
	then
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = J.GetProperTarget(bot);
		if J.IsValidHero(npcTarget) and J.CanCastOnMagicImmune(npcTarget) and J.IsInRange(npcTarget, bot, nRadius-100)
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;

end

function X.ConsiderR()
	
	if not abilityR:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE, nil;	end
	
	local nCastPoint = abilityR:GetCastPoint();
	local manaCost   = abilityR:GetManaCost();
	local nRadius    = abilityR:GetAOERadius();
	local nCastRange = 1000;
	local hTrueHeroList = bot:GetNearbyHeroes(nRadius,true,BOT_MODE_NONE);
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = J.GetProperTarget(bot);
		if J.IsValidHero(npcTarget) 
		   and J.CanCastOnMagicImmune(npcTarget) 
		   and J.IsInRange(npcTarget, bot, nCastRange + 200) 
		then
			if #hTrueHeroList >= 2 then
				return BOT_ACTION_DESIRE_HIGH, nil;
			end	
		end
	end

	local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange + nRadius, nRadius, 0, 0 );
	local blink = X.IsItemAvailable("item_blink");
	if blink ~= nil and blink:IsFullyCastable() then
		if locationAoE.count >= 2
			or locationAoE.count >= 3
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
		if locationAoE.count >= 1 and J.GetHPR(bot) < 0.38
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	if #hTrueHeroList >= 3 then
		return BOT_ACTION_DESIRE_HIGH, nil;
	end	
	
	return BOT_ACTION_DESIRE_NONE, nil;
end

function X.IsItemAvailable(item_name)
    local slot = bot:FindItemSlot(item_name)
	
	if slot >= 0 and slot <= 5 then
		return bot:GetItemInSlot(slot);
	end
	
    return nil;
end

function X.ManaR(avilityManaCost)
	local manaCost   = abilityR:GetManaCost();

	if abilityR:IsFullyCastable() then --如果大招就绪，确保大招可以释放
		return bot:GetMana() > manaCost + avilityManaCost;
	elseif nHP > 0.25 then --省着点蓝，保证大招就绪时蓝量差不多
		return bot:GetMana() > manaCost * 0.8;
	else --血量过低就不要纠结是否留着大招了
		return true;
	end
	
	return false;
end

return X