local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local Minion = dofile( GetScriptDirectory()..'/FunLib/Minion')
local sTalentList = J.Skill.GetTalentList(bot)
local sAbilityList = J.Skill.GetAbilityList(bot)
local sOutfit = J.Skill.GetOutfitName(bot)
local sausdue = false

local tTalentTreeList = {
						['t25'] = {0, 10},
						['t20'] = {0, 10},
						['t15'] = {0, 10},
						['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
						{1,3,1,3,1,6,1,3,3,2,6,2,2,2,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)

X['sBuyList'] = {
				sOutfit,
				"item_glimmer_cape",
				"item_aether_lens",
				"item_force_staff",
				"item_ultimate_scepter",
				"item_solar_crest",
				"item_spirit_vessel",
				"item_lotus_orb",
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

	if Minion.IsValidUnit(hMinionUnit) 
	then
		if hMinionUnit:IsIllusion() 
		then 
			Minion.IllusionThink(hMinionUnit)	
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

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )

local castQDesire,castQTarget = 0;
local castWDesire,castWLocation = 0;
local castRDesire,castRTarget = 0;

local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;


function X.SkillsComplement()
	
	
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
	
	
	
	nKeepMana = 300
	nLV = bot:GetLevel();
	nMP = bot:GetMana()/bot:GetMaxMana();
	nHP = bot:GetHealth()/bot:GetMaxHealth();
	hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	
		
	castRDesire, castRTarget = X.ConsiderR();
	if castRDesire > 0 and not DangerousTarget(castRTarget) and sausdue
	then
	
		J.SetQueuePtToINT(bot, false)
	
		bot:ActionQueue_UseAbilityOnEntity( abilityR, castRTarget )
		sausdue = false;
		
		local glimmer = J.IsItemAvailable("item_glimmer_cape");
		local shadow = J.IsItemAvailable("item_shadow_amulet");
		
		if shadow ~= nil and shadow:IsFullyCastable() then 
			bot:ActionQueue_UseAbility( shadow )
		end	

		if glimmer ~= nil and glimmer:IsFullyCastable() then 
			bot:ActionQueue_UseAbilityOnEntity( glimmer, bot )
		end	

		return;
	end
	
	castQDesire, castQTarget = X.ConsiderQ();
	if ( castQDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, false)
	
		bot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget )
		sausdue = true;
		return;
	end

	castWDesire, castWLocation = X.ConsiderW();
	if ( castWDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, false)
	
		bot:ActionQueue_UseAbilityOnLocation( abilityW, castWLocation )
		return;
	end

end


function X.ConsiderQ()
	
	if not abilityQ:IsFullyCastable() or bot:IsRooted() then return BOT_ACTION_DESIRE_NONE end
	
	local nCastRange = abilityQ:GetCastRange( ) + 50;
	local nCastPoint = abilityQ:GetCastPoint( );
	local nSkillLV   = abilityQ:GetLevel( );
	local nDamage    = 25 + nSkillLV*75;
	
	local nEnemysHeroesInCastRange = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);	
	local nEnemysHeroesInView      = bot:GetNearbyHeroes(800, true, BOT_MODE_NONE);
	
	--击杀
	if #nEnemysHeroesInCastRange > 0 then
		for i=1, #nEnemysHeroesInCastRange do
			if J.IsValid(nEnemysHeroesInCastRange[i])
			   and J.CanCastOnNonMagicImmune(nEnemysHeroesInCastRange[i]) 
			   and nEnemysHeroesInCastRange[i]:GetHealth() < nEnemysHeroesInCastRange[i]:GetActualIncomingDamage(nDamage,DAMAGE_TYPE_MAGICAL)
			   and not (GetUnitToUnitDistance(nEnemysHeroesInCastRange[i],bot) <= bot:GetAttackRange() + 60)
			   and not J.IsDisabled(true, nEnemysHeroesInCastRange[i]) 
			then
				return BOT_ACTION_DESIRE_HIGH, nEnemysHeroesInCastRange[i];
			end
		end
	end
	
	--打断
	if #nEnemysHeroesInView > 0 then
		for i=1, #nEnemysHeroesInView do
			if J.IsValid(nEnemysHeroesInView[i])
			   and J.CanCastOnNonMagicImmune(nEnemysHeroesInView[i]) 
			   and nEnemysHeroesInView[i]:IsChanneling()
			then
				return BOT_ACTION_DESIRE_HIGH, nEnemysHeroesInCastRange[i];
			end
		end
	end
	
	
	--团战
	if J.IsInTeamFight(bot, 1200)
	   and  DotaTime() > 6*60
	then
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;
		
		for _,npcEnemy in pairs( nEnemysHeroesInCastRange )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and not J.IsDisabled(true, npcEnemy)
				and not npcEnemy:IsDisarmed()
			then
				local npcEnemyDamage = npcEnemy:GetEstimatedDamageToTarget( false, bot, 3.0, DAMAGE_TYPE_ALL );
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
	
	--常规
	if J.IsGoingOnSomeone(bot)
	then
		local target = J.GetProperTarget(bot)
		if J.IsValidHero(target) 
			and J.CanCastOnNonMagicImmune(target) 
			and J.IsInRange(target, bot, nCastRange) 
		    and not J.IsDisabled(true, target)
			and not target:IsDisarmed()
		then
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	
	
	if J.IsRetreating(bot) 
	then
		if J.IsValid(nEnemysHeroesInCastRange[1]) 
		   and J.CanCastOnNonMagicImmune(nEnemysHeroesInCastRange[1]) 
		   and not J.IsDisabled(true, nEnemysHeroesInCastRange[1])
		   and not nEnemysHeroesInCastRange[1]:IsDisarmed()
		   and GetUnitToUnitDistance(bot,nEnemysHeroesInCastRange[1]) <= nCastRange - 60 
		then
			
			return BOT_ACTION_DESIRE_HIGH, nEnemysHeroesInCastRange[1];
		end
	end
	
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN 
		and  bot:GetMana() > 400
	then
		local target =  bot:GetAttackTarget();
		
		if target ~= nil and target:IsAlive()
			and not J.IsDisabled(true, target)
			and not target:IsDisarmed()
		then
			return BOT_ACTION_DESIRE_LOW, target;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end


function X.ConsiderW()

	-- Make sure it's castable
	if ( not abilityW:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nRadius    = abilityW:GetAOERadius();
	local nCastRange = abilityW:GetCastRange();
	local nCastPoint = abilityW:GetCastPoint();
	local nManaCost  = abilityW:GetManaCost();
	local nDamage    = 0;
	
	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange + 150, true, BOT_MODE_NONE );
	local nEnemysHeroesInView = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE );
	
	if J.IsFarming(bot) and bot:GetMana() > 150
	then
		local npcTarget = J.GetProperTarget(bot);
		if J.IsValid(npcTarget)
		   and npcTarget:GetTeam() == TEAM_NEUTRAL
		   and npcTarget:GetMagicResist() < 0.4
		then
			local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
			if ( locationAoE.count >= 2 ) 
			then
				return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
			end
		end
	end	
	
	if ( J.IsPushing(bot) or J.IsDefending(bot) or J.IsFarming(bot)) 
	    and J.IsAllowedToSpam(bot, nManaCost *0.3)
		and bot:GetLevel() >= 6 
		and #nEnemysHeroesInView == 0
	then
		local lanecreeps = bot:GetNearbyLaneCreeps(nCastRange+200, true);
		local allyHeroes  = bot:GetNearbyHeroes(1000,true,BOT_MODE_NONE);
		if #lanecreeps >= 2 
		   and #allyHeroes <= 2 
		   and J.IsValid(lanecreeps[1])
		then
			local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, nDamage );
			if ( locationAoE.count >= 2 and #lanecreeps >= 2  and bot:GetLevel() < 25 and #allyHeroes == 1) 
			then
				return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
			end
			local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
			if ( locationAoE.count >= 4 and #lanecreeps >= 4  ) 
			then
				return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
			end
		end
	end
	
	if J.IsInTeamFight(bot, 1200)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius - 30, 0, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
		end
		
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;				
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if  J.IsValid(npcEnemy)
				and J.IsInRange(npcTarget, bot, nCastRange) 
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
			then
				local npcEnemyDamage = npcEnemy:GetEstimatedDamageToTarget( false, bot, 3.0, DAMAGE_TYPE_PHYSICAL );
				if ( npcEnemyDamage > nMostDangerousDamage )
				then
					nMostDangerousDamage = npcEnemyDamage;
					npcMostDangerousEnemy = npcEnemy;
				end
			end
		end
		
		if ( npcMostDangerousEnemy ~= nil )
		then
			return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy:GetExtrapolatedLocation(nCastPoint);
		end		
	end

	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = J.GetProperTarget(bot);
		if J.IsValidHero(npcTarget) 
		   and J.CanCastOnNonMagicImmune(npcTarget) 
		   and J.IsInRange(npcTarget, bot, nCastRange - 100) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget:GetExtrapolatedLocation(nCastPoint);
		end
	end
	
	if bot:GetLevel() < 18
	then
		local lanecreeps = bot:GetNearbyLaneCreeps(nCastRange+200, true);
		local allyHeroes  = bot:GetNearbyHeroes(1000,true,BOT_MODE_NONE);
		if #lanecreeps >= 3 
		   and #allyHeroes < 3
		   and J.IsValid(lanecreeps[1])
		then
			local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, nDamage );
			if ( locationAoE.count >= 3 and #lanecreeps >= 3  ) 
			then
				return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
end


function X.ConsiderR()

	if not abilityR:IsFullyCastable() or bot:IsRooted() then return BOT_ACTION_DESIRE_NONE end
	
	local nCastRange = abilityR:GetCastRange() + 40;
	local nCastPoint = abilityR:GetCastPoint();
	local nSkillLV   = abilityR:GetLevel();
	local nDamage    = 0;
	
	local nEnemysHeroesInCastRange = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);	
	local nAllysHeroesInCastRange = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE);
	
	
	if J.IsInTeamFight(bot, 1200)
	   and DotaTime() > 6*60
	then
		local npcTarget = nil;
		local npcTargetHealth = 99999;		
		
		for _,npcEnemy in pairs( nEnemysHeroesInCastRange )
		do
			if  J.IsValid(npcEnemy)
				and J.CanCastOnNonMagicImmune(npcEnemy) 
				and not J.IsDisabled(true, npcEnemy)
				and not npcEnemy:IsAttackImmune()
				and npcEnemy:GetPrimaryAttribute() == ATTRIBUTE_INTELLECT
				and npcEnemy:GetUnitName() ~= "npc_dota_hero_necrolyte"
			then
				if ( npcEnemy:GetHealth() < npcTargetHealth )
				then
					npcTarget = npcEnemy;
					npcTargetHealth = npcEnemy:GetHealth();
				end
			end
		end		
		if ( npcTarget ~= nil )
		then
			bot:SetTarget(npcTarget);
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end		
		
		
		for _,npcEnemy in pairs( nEnemysHeroesInCastRange )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and not J.IsDisabled(true, npcEnemy)
				and not npcEnemy:IsAttackImmune()
				and npcEnemy:GetPrimaryAttribute() == ATTRIBUTE_AGILITY
				and not npcEnemy:GetUnitName() == "npc_dota_hero_meepo"
			then
				if ( npcEnemy:GetHealth() < npcTargetHealth )
				then
					npcTarget = npcEnemy;
					npcTargetHealth = npcEnemy:GetHealth();
				end
			end
		end		
		if ( npcTarget ~= nil )
		then
			bot:SetTarget(npcTarget);
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end		
		
		
		for _,npcEnemy in pairs( nEnemysHeroesInCastRange )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and not npcEnemy:IsAttackImmune()
				and not J.IsDisabled(true, npcEnemy)
			then
				if ( npcEnemy:GetHealth() < npcTargetHealth )
				then
					npcTarget = npcEnemy;
					npcTargetHealth = npcEnemy:GetHealth();
				end
			end
		end		
		if ( npcTarget ~= nil )
		then
			
			bot:SetTarget(npcTarget);
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end			
	end
	
	
	if J.IsGoingOnSomeone(bot)
		and DotaTime() > 6*30 
	then
		local target = J.GetProperTarget(bot)
		if  J.IsValidHero(target) 
			and J.CanCastOnNonMagicImmune(target) 
			and J.IsInRange(target, bot, nCastRange) 
		    and not J.IsDisabled(true, target)
		then
			
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end

	for _,npcAlly in pairs( nAllysHeroesInCastRange )
	do
		local npcAllyHP = npcAlly:GetHealth()/npcAlly:GetMaxHealth();--队友血量比
		local nEnemy = npcAlly:GetNearbyHeroes(100, true, BOT_MODE_NONE)

		if  J.IsValid(npcAlly)
			and J.CanCastOnNonMagicImmune(npcAlly) 
			and nHP > 0.7
			and npcAllyHP < 0.1
			and #nEnemy > 0
			and npcAlly:DistanceFromFountain() > bot:DistanceFromFountain()
		then
			return BOT_ACTION_DESIRE_HIGH, npcAlly;
		end
	end
	
	
	if J.IsRetreating(bot) 
	then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

function DangerousTarget(target)
	local targets = target:GetNearbyHeroes(500, false, BOT_MODE_NONE)
	local allys = target:GetNearbyHeroes(400, true, BOT_MODE_NONE)
	local distance = GetUnitToUnitDistance(bot, target);

	if allys ~= nil then
		if #allys >= 3 then
			return true;
		end
	end
	
	if J.GetDistanceFromAllyFountain(target) < J.GetDistanceFromAllyFountain(bot) then
		return true;
	end

	if targets ~= nil then
		if #targets >= 4 then
			return true;
		elseif #targets <= 2
			and distance <= 800
		then
			return false;
		end

		local DangerousHp = 0;

		if target:GetHealth() / target:GetMaxHealth() < 0.15
			and distance >= 600
		then
			return false;
		end

		for i=1, #targets do
			if targets[i]:GetHealth() > bot:GetHealth() + 200
			then
				DangerousHp = DangerousHp + 1;
			end
		end

		if DangerousHp >= 2
		then
			return true;
		end

	end

	return false;
end

return X