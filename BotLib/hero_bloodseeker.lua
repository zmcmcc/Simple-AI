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
						['t15'] = {0, 10},
						['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
						{1,3,2,3,1,6,1,1,3,3,6,2,2,2,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)

X['skills'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)

X['items'] = {
				sOutfit,
				"item_sange_and_yasha",
				"item_diffusal_blade",
				"item_black_king_bar",
				"item_abyssal_blade", 
				"item_monkey_king_bar",
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
local abilityR = npcBot:GetAbilityByName( sAbilityList[6] );

local castQDesire, castQTarget   = 0;
local castWDesire, castWLocation = 0;
local castRDesire, castRTarget   = 0;

local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;


function X.SkillsComplement()

	
	
	if J.CanNotUseAbility(npcBot) or npcBot:IsInvisible() then return end
	
	
	
	nKeepMana = 300; 
	nMP = npcBot:GetMana()/npcBot:GetMaxMana();
	nHP = npcBot:GetHealth()/npcBot:GetMaxHealth();
	nLV = npcBot:GetLevel();
	hEnemyHeroList = npcBot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	
	
	
	
	castRDesire, castRTarget   = X.ConsiderR();
	if ( castRDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, false)
	
		npcBot:ActionQueue_UseAbilityOnEntity( abilityR, castRTarget)
		return;
	
	end
	
	castQDesire, castQTarget   = X.ConsiderQ();
	if ( castQDesire > 0 ) 
	then
	
		npcBot:Action_ClearActions(false);
	
		npcBot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget )
		return;
		
	end
	
	castWDesire, castWLocation = X.ConsiderW();
	if ( castWDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, false)
	
		npcBot:ActionQueue_UseAbilityOnLocation( abilityW, castWLocation )
		return;
	end
	

end

function X.ConsiderQ()

	-- Make sure it's castable
	if  not abilityQ:IsFullyCastable() then return 0 end

	-- Get some of its values
	local nCastRange = abilityQ:GetCastRange();
	local nCastPoint = abilityQ:GetCastPoint();
	local nManaCost  = abilityQ:GetManaCost();
	local nDamage    = npcBot:GetAttackDamage()+ (( abilityQ:GetSpecialValueInt( 'damage_increase_pct' ) / 100 ) * npcBot:GetAttackDamage());
	
	local npcTarget = J.GetProperTarget(npcBot);
	local bBotMagicImune = J.CanCastOnNonMagicImmune(npcBot);
	
	--对线期提高补刀
	if   npcBot:GetActiveMode() == BOT_MODE_LANING  
		 and bBotMagicImune
	     and not npcBot:HasModifier('modifier_bloodseeker_bloodrage')
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps( 1000, true );
		local tableNearbyAllyCreeps  = npcBot:GetNearbyLaneCreeps( 1000, false );
		for _,ECreep in pairs(tableNearbyEnemyCreeps)
		do
			if  J.IsValid(ECreep) and J.CanKillTarget(ECreep, nDamage *1.38, DAMAGE_TYPE_PHYSICAL) then
				return BOT_ACTION_DESIRE_HIGH, npcBot;
			end
		end
		for _,ACreep in pairs(tableNearbyAllyCreeps)
		do
			if  J.IsValid(ACreep) and J.CanKillTarget(ACreep, nDamage *1.18, DAMAGE_TYPE_PHYSICAL) then
				return BOT_ACTION_DESIRE_HIGH, npcBot;
			end
		end
	end	
	
	--打野时吸血
	if  J.IsValid(npcTarget) and npcTarget:GetTeam() == TEAM_NEUTRAL and bBotMagicImune
	    and not npcBot:HasModifier('modifier_bloodseeker_bloodrage')
	then
		local tableNearbyCreeps = npcBot:GetNearbyCreeps( 1000, true );
		for _,ECreep in pairs(tableNearbyCreeps)
		do
			if J.IsValid(ECreep) and J.CanKillTarget(ECreep, nDamage, DAMAGE_TYPE_PHYSICAL) then
				return BOT_ACTION_DESIRE_HIGH, npcBot;
			end
		end
	end	
	

	--打野时提高输出
	if J.IsFarming(npcBot) 
		and #hEnemyHeroList == 0
		and npcBot:GetHealth() > 300
	then
	
		if not npcBot:HasModifier('modifier_bloodseeker_bloodrage')
		   and bBotMagicImune
		then
			return BOT_ACTION_DESIRE_HIGH, npcBot;
		end
		
		if J.IsValid(npcTarget)
			and npcTarget:GetTeam() == TEAM_NEUTRAL
			and not J.CanKillTarget(npcTarget, nDamage * 2.18, DAMAGE_TYPE_PHYSICAL)
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	--打肉时破林肯
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		if not npcBot:HasModifier('modifier_bloodseeker_bloodrage')
		   and bBotMagicImune
		then
			return BOT_ACTION_DESIRE_HIGH, npcBot;
		end	
	
		local npcTarget = J.GetProperTarget(npcBot);
		if ( J.IsRoshan(npcTarget) 
		     and J.IsInRange(npcTarget, npcBot, nCastRange) 
		     and not npcTarget:HasModifier('modifier_bloodseeker_bloodrage')  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget;
		end
	end

	--团战时辅助
	if J.IsInTeamFight(npcBot, 1200) or J.IsPushing(npcBot) or J.IsDefending(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
	    
		if  #tableNearbyEnemyHeroes >= 1 then
			local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( nCastRange + 200, false, BOT_MODE_NONE );
			local highesAD = 0;
			local highesADUnit = nil;
			
			for _,npcAlly in pairs( tableNearbyAllyHeroes )
			do
				local AllyAD = npcAlly:GetAttackDamage();
				if ( J.IsValid(npcAlly) 
					 and npcAlly:GetAttackTarget() ~= nil
				     and J.CanCastOnNonMagicImmune(npcAlly) 
					 and ( J.GetHPR(npcAlly) > 0.18 or J.GetHPR(npcAlly:GetAttackTarget()) < 0.18 )
					 and not npcAlly:HasModifier('modifier_bloodseeker_bloodrage')
					 and AllyAD > highesAD ) 
				then
					highesAD = AllyAD;
					highesADUnit = npcAlly;
				end
			end
			
			if highesADUnit ~= nil then
				return BOT_ACTION_DESIRE_HIGH, highesADUnit;
			end
		
		end	
		
	end
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = J.GetProperTarget(npcBot);
		if J.IsValidHero(npcTarget) 
		   and J.CanCastOnNonMagicImmune(npcTarget) 
		   and J.IsInRange(npcTarget, npcBot, nCastRange + 150) 
		then
		    if J.IsDisabled(true, npcTarget) 
			   and J.GetHPR(npcTarget) < 0.62
			   and J.GetProperTarget(npcTarget) == nil
			   and not npcTarget:HasModifier('modifier_bloodseeker_bloodrage')
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			elseif not npcBot:HasModifier('modifier_bloodseeker_bloodrage') 
				   and bBotMagicImune
			    then 
				    return BOT_ACTION_DESIRE_HIGH, npcBot;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function X.ConsiderW()

	-- Make sure it's castable
	if not abilityW:IsFullyCastable()  then return 0 end

	-- Get some of its values
	local nRadius    = 600;
	local nCastRange = abilityW:GetCastRange();
	local nCastPoint = abilityW:GetCastPoint();
	local nDelay	 = abilityW:GetSpecialValueFloat( 'delay' );
	local nManaCost  = abilityW:GetManaCost();
	local nDamage    = abilityW:GetSpecialValueInt('damage');
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	local tableNearbyAllyHeroes = npcBot:GetNearbyHeroes( 800, false, BOT_MODE_NONE );
	
	--if we can kill any enemies
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes)
	do
		if  J.IsValid(npcEnemy) and J.CanCastOnNonMagicImmune(npcEnemy) and J.CanKillTarget(npcEnemy, nDamage, DAMAGE_TYPE_PURE)
		then
			if  npcEnemy:GetMovementDirectionStability() >= 0.75 then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetExtrapolatedLocation(nDelay);
			else
				return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation();
			end
		end
	end
	
	--对线期补兵
	if npcBot:GetActiveMode() == BOT_MODE_LANING and J.IsAllowedToSpam(npcBot, nManaCost) 
	then
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), 1000, nRadius/2, nCastPoint, nDamage );
		if ( locationAoE.count >= 4 ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc;
		end
	end	
	
	--推进带线
	if ( J.IsPushing(npcBot) or J.IsDefending(npcBot) ) and J.IsAllowedToSpam(npcBot, nManaCost) 
		 and tableNearbyEnemyHeroes == nil or #tableNearbyEnemyHeroes == 0 
		 and #tableNearbyAllyHeroes <= 2
	then
		local lanecreeps = npcBot:GetNearbyLaneCreeps(1000, true);
		local locationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), 1000, nRadius/2, nCastPoint, nDamage );
		if ( locationAoE.count >= 4 and #lanecreeps >= 4 ) 
		then
			return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc;
		end
	end	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(npcBot)
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( J.IsValid(npcEnemy) and npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) and J.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcBot:GetLocation();
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
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = J.GetProperTarget(npcBot);
		if J.IsValidHero(npcTarget) 
		   and J.CanCastOnNonMagicImmune(npcTarget) 
		   and J.IsInRange(npcTarget, npcBot, nCastRange + nRadius) 
		then
			local nCastLoc = J.GetDelayCastLocation(npcBot,npcTarget,nCastRange,nRadius,2.0)
			if nCastLoc ~= nil 
			then
				return BOT_ACTION_DESIRE_HIGH, nCastLoc;
			end
		end
	end
	
	--特殊用法
	local skThere, skLoc = J.IsSandKingThere(npcBot, nCastRange, 2.0);
	if skThere then
		return BOT_ACTION_DESIRE_MODERATE, skLoc;
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function X.ConsiderR()

	-- Make sure it's castable
	if not abilityR:IsFullyCastable() then 	return 0 end

	-- Get some of its values
	local nCastRange   = abilityR:GetCastRange();
	local nCastPoint   = abilityR:GetCastPoint();
	local nManaCost    = abilityR:GetManaCost();
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange +200, true, BOT_MODE_NONE );
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(npcBot) 
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if npcBot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) 
			   and J.CanCastOnMagicImmune( npcEnemy )
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
			end
		end
	end

	if J.IsInTeamFight(npcBot, 1200)
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if J.CanCastOnMagicImmune(npcEnemy) 
			   and J.Role.IsCarry(npcEnemy:GetUnitName()) 
			   and not npcEnemy:HasModifier('modifier_bloodseeker_bloodrage')
			   and not J.IsDisabled(true, npcEnemy) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = J.GetProperTarget(npcBot);
		if J.IsValidHero(npcTarget) 
		   and J.CanCastOnMagicImmune(npcTarget)
		   and J.IsInRange(npcTarget, npcBot, nCastRange +100)
		   and not npcTarget:HasModifier('modifier_bloodseeker_bloodrage')
		   and not J.IsDisabled(true, npcTarget)
		then
			local allies = npcTarget:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
			if ( allies ~= nil and #allies >= 2 )
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end


return X
-- dota2jmz@163.com QQ:2462331592.
