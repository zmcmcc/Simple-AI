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
						['t20'] = {0, 10},
						['t15'] = {10, 0},
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{1,3,2,3,1,6,1,1,3,3,6,2,2,2,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)

X['skills'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)

X['items'] = {
				sOutfit,
				"item_mekansm",
				"item_urn_of_shadows",
				"item_glimmer_cape",
				"item_rod_of_atos",
				"item_guardian_greaves",
				"item_spirit_vessel",
				"item_ultimate_scepter",
				"item_shivas_guard",
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


local castQDesire
local castWDesire
local castWQDesire
local castRDesire,castRTarget

local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;

function X.SkillsComplement()

	
	
	if J.CanNotUseAbility(npcBot) then return end
	
	
	
	nKeepMana = 400; 
	nLV = npcBot:GetLevel();
	nMP = npcBot:GetMana()/npcBot:GetMaxMana();
	nHP = npcBot:GetHealth()/npcBot:GetMaxHealth();
	hEnemyHeroList = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	
	
	
	
	
	castRDesire, castRTarget = X.ConsiderR();
	if ( castRDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, false)
	
		npcBot:ActionQueue_UseAbilityOnEntity( abilityR, castRTarget )
		return;
	end
	
	castWDesire = X.ConsiderW();
	if ( castWDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, false)
	
		npcBot:ActionQueue_UseAbility( abilityW )
		return;
	
	end
	
	castQDesire = X.ConsiderQ();
	if ( castQDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, false)
	
		npcBot:ActionQueue_UseAbility( abilityQ )
		return;
	
	end

end


function X.ConsiderW()

	-- Make sure it's castable
	if ( not abilityW:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nRadius = abilityW:GetSpecialValueInt( "slow_aoe" );
	
	local SadStack = 0;
	local npcModifier = npcBot:NumModifiers();
	
	for i = 0, npcModifier 
	do
		if npcBot:GetModifierName(i) == "modifier_necrolyte_death_pulse_counter" then
			SadStack = npcBot:GetModifierStackCount(i);
			break;
		end
	end
	
	if ( SadStack >= 8 or npcBot:GetHealthRegen() > 90) and npcBot:GetHealth() / npcBot:GetMaxHealth() < 0.5 then
		return BOT_ACTION_DESIRE_LOW;
	end
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(npcBot)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		if npcBot:WasRecentlyDamagedByAnyHero( 2.0 ) and #tableNearbyEnemyHeroes > 0  
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	
	-- If we're going after someone
	if J.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = npcBot:GetTarget();
		if J.IsValidHero(npcTarget) 
		   and J.IsRunning(npcTarget)
		   and J.CanCastOnNonMagicImmune(npcTarget)
		   and J.IsInRange(npcTarget, npcBot, nRadius - 50)
		   and ( J.GetHPR(npcBot) < 0.25 
		         or ( not J.IsInRange(npcTarget, npcBot, 350)
					  and npcBot:IsFacingLocation(npcTarget:GetLocation(),30) 
				      and not npcTarget:IsFacingLocation(npcBot:GetLocation(),90) ))
		then
			local targetAllies = npcTarget:GetNearbyHeroes(1000, false, BOT_MODE_NONE);
			if #targetAllies == 1 then 
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end


function X.ConsiderQ()

	-- Make sure it's castable
	if  not abilityQ:IsFullyCastable() 
		or npcBot:IsInvisible()
		or ( J.GetHPR(npcBot) > 0.62 and abilityR:GetCooldownTimeRemaining() < 6 and npcBot:GetMana() < abilityR:GetManaCost() )
	then 
		return BOT_ACTION_DESIRE_NONE;
	end


	-- Get some of its values
	local nRadius = abilityQ:GetSpecialValueInt( "area_of_effect" );
	local nCastRange = 0;
	local nDamage = abilityQ:GetAbilityDamage();
	local nDamageType = DAMAGE_TYPE_MAGICAL;

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(npcBot) or J.GetHPR(npcBot) < 0.5
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 2*nRadius, true, BOT_MODE_NONE );
		if ( npcBot:WasRecentlyDamagedByAnyHero( 2.0 ) and #tableNearbyEnemyHeroes > 0 )
			or (J.GetHPR(npcBot) < 0.75 and npcBot:DistanceFromFountain() < 400)
			or J.GetHPR(npcBot) < J.GetMPR(npcBot)
			or J.GetHPR(npcBot) < 0.25
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if abilityQ:GetLevel() >= 3
	then
		local tableNearbyEnemyCreeps = npcBot:GetNearbyLaneCreeps( nRadius, true );
		local nCanHurtCount = 0;
		local nCanKillCount = 0;
		for _,creep in pairs(tableNearbyEnemyCreeps)
		do
			if J.IsValid(creep)
				and not creep:HasModifier("modifier_fountain_glyph")				
			then
				nCanHurtCount = nCanHurtCount +1;
				if J.CanKillTarget(creep, nDamage +2, nDamageType)
				then
					nCanKillCount = nCanKillCount +1;
				end
			end		
		end
		
		if  nCanKillCount >= 2
			or (nCanKillCount >= 1 and J.GetMPR(npcBot) > 0.9)
			or (nCanHurtCount >= 3 and npcBot:GetActiveMode() ~= BOT_MODE_LANING)
			or (nCanHurtCount >= 3 and nCanKillCount >= 1 and J.IsAllowedToSpam(npcBot, 190))
			or (nCanHurtCount >= 3 and J.GetMPR(npcBot) > 0.8 and npcBot:GetLevel() > 10 and #tableNearbyEnemyCreeps == 3)
			or (nCanHurtCount >= 2 and nCanKillCount >= 1 and npcBot:GetLevel() > 24 and #tableNearbyEnemyCreeps == 2)
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
		
	end

	if J.IsInTeamFight(npcBot, 1200)
	then
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		local tableNearbyAlliesHeroes = npcBot:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE );
		local lowHPAllies = 0;
		for _,ally in pairs(tableNearbyAlliesHeroes)
		do
			if J.IsValidHero(ally)
			then
				local allyHealth = ally:GetHealth() / ally:GetMaxHealth();
				if allyHealth < 0.5 then
					lowHPAllies = lowHPAllies + 1;
				end
			end
		end
		
		if #tableNearbyEnemyHeroes >= 2 or lowHPAllies >= 1 then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	-- If we can heal 3+ allyHero
	local tableNearbyAlliesHeroes = npcBot:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE );
	if #tableNearbyAlliesHeroes >= 2
	then
		local needHPCount = 0;
		for _,Ally in pairs(tableNearbyAlliesHeroes)
		do
			if J.IsValidHero(Ally)
			   and Ally:GetMaxHealth()- Ally:GetHealth() > 220
			then
			    needHPCount = needHPCount + 1;
				
				if Ally:GetHealth()/Ally:GetMaxHealth() < 0.15 
				then
					return BOT_ACTION_DESIRE_MODERATE;
				end
	
				if needHPCount >= 2 and  Ally:GetHealth()/Ally:GetMaxHealth() < 0.38 
				then
					return BOT_ACTION_DESIRE_MODERATE;
				end
				
				if needHPCount >= 3 
				then
					return BOT_ACTION_DESIRE_MODERATE;
				end
				
			end
		end
	
	end
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = J.GetProperTarget(npcBot);

		if J.IsValidHero(npcTarget) and J.CanCastOnNonMagicImmune(npcTarget) and J.IsInRange(npcTarget, npcBot, nRadius)
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end


	return BOT_ACTION_DESIRE_NONE;

end


function X.ConsiderR()

	-- Make sure it's castable
	if not abilityR:IsFullyCastable() then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityR:GetCastRange();
	local nDamagePerHealth = abilityR:GetSpecialValueFloat("damage_per_health");

	-- If we're going after someone
	if J.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = J.GetProperTarget(npcBot);
		if J.IsValidHero(npcTarget) 
		   and J.CanCastOnNonMagicImmune(npcTarget) 
		   and not J.IsHaveAegis(npcTarget)
		   and not npcTarget:HasModifier("modifier_arc_warden_tempest_double")
		   and J.IsInRange(npcTarget, npcBot, nCastRange + 200)
		then
			local EstDamage = X.GetEstDamage(npcBot,npcTarget,nDamagePerHealth);
			
			if J.CanKillTarget(npcTarget, EstDamage, DAMAGE_TYPE_MAGICAL ) 
			   or ( npcTarget:IsChanneling() and npcTarget:HasModifier("modifier_teleporting") )
			then
				X.ReportDetails(npcBot,npcTarget,EstDamage,nDamagePerHealth)
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end	

	-- If we're in a teamfight, use it on the scariest enemy
	if J.IsInTeamFight(npcBot, 1200)
	then
		local npcToKill = nil;
		local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if J.IsValidHero(npcEnemy)
			   and J.CanCastOnNonMagicImmune(npcEnemy)
			   and not J.IsHaveAegis(npcEnemy) 
			   and not npcEnemy:HasModifier("modifier_arc_warden_tempest_double")
			then
				local EstDamage = X.GetEstDamage(npcBot,npcEnemy,nDamagePerHealth);
				if J.CanKillTarget(npcEnemy, EstDamage, DAMAGE_TYPE_MAGICAL )
				then
					X.ReportDetails(npcBot,npcEnemy,EstDamage,nDamagePerHealth)
					npcToKill = npcEnemy;
					break;
				end
			end
		end
		if ( npcToKill ~= nil  )
		then
			return BOT_ACTION_DESIRE_HIGH, npcToKill;
		end
	end
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if J.IsValidHero(npcEnemy) 
		   and not J.IsHaveAegis(npcEnemy) 
		   and not npcEnemy:HasModifier("modifier_arc_warden_tempest_double")
		then
			local EstDamage = X.GetEstDamage(npcBot,npcEnemy,nDamagePerHealth);
			if J.CanCastOnNonMagicImmune(npcEnemy) and J.CanKillTarget(npcEnemy, EstDamage, DAMAGE_TYPE_MAGICAL )
			then
				X.ReportDetails(npcBot,npcEnemy,EstDamage,nDamagePerHealth)
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end


function X.GetEstDamage(npcBot, npcTarget, nDamagePerHealth)

	local targetMaxHealth = npcTarget:GetMaxHealth();
	
	if npcTarget:GetHealth()/ targetMaxHealth > 0.75 
	then
		return targetMaxHealth * 0.3;
	end
	
	local AroundTargetAllyCount = J.GetAroundTargetAllyHeroCount(npcTarget, 650, npcBot);
	
	local MagicResistReduce = 1 - npcTarget:GetMagicResist();
	if MagicResistReduce  < 0.1 then  MagicResistReduce  = 0.1 end;
	local HealthBack =  npcTarget:GetHealthRegen() *2;
	
	local EstDamage = ( targetMaxHealth - npcTarget:GetHealth() - HealthBack ) * nDamagePerHealth - HealthBack/MagicResistReduce;	
	
	if npcBot:GetLevel() >= 9 then EstDamage = EstDamage + targetMaxHealth * 0.026; end
	if npcBot:GetLevel() >= 12 then EstDamage = EstDamage + targetMaxHealth * 0.032; end
	if npcBot:GetLevel() >= 18 then EstDamage = EstDamage + targetMaxHealth * 0.016; end
	
	if npcBot:HasScepter() and J.GetHPR(npcBot) < 0.2 then EstDamage = EstDamage + targetMaxHealth * 0.3; end
		
	if AroundTargetAllyCount >= 2 then EstDamage = EstDamage + targetMaxHealth * 0.08 *(AroundTargetAllyCount - 1); end

	if npcTarget:HasModifier("modifier_medusa_mana_shield") 
	then 
		local EstDamageMaxReduce = EstDamage * 0.6;
		if npcTarget:GetMana() * 2.5 >= EstDamageMaxReduce
		then
			EstDamage = EstDamage *  0.4;
		else
			EstDamage = EstDamage *  0.4 + EstDamageMaxReduce - npcTarget:GetMana() * 2.5;
		end
	end 
	
	if npcTarget:GetUnitName() == "npc_dota_hero_bristleback" 
		and not npcTarget:IsFacingLocation(GetBot():GetLocation(),120)
	then 
		EstDamage = EstDamage * 0.7; 
	end 
	
	if npcTarget:HasModifier("modifier_kunkka_ghost_ship_damage_delay")
	then
		local buffTime = J.GetModifierTime(npcTarget,"modifier_kunkka_ghost_ship_damage_delay");
		if buffTime > 2.0 then EstDamage = EstDamage *0.55; end
	end		
	
	if npcTarget:HasModifier("modifier_templar_assassin_refraction_absorb") then EstDamage = 0; end
	
	return EstDamage;
	
end


local ReportTime = 99999;
function X.ReportDetails(bot,npcTarget,EstDamage,nDamagePerHealth)

	if DotaTime() > ReportTime + 5.0
	then
		local nMessage;
		local nNumber;
		local MagicResist = 1 - npcTarget:GetMagicResist();
		
		ReportTime = DotaTime();
		
		nMessage = "基础伤害值:"
		nNumber  = nDamagePerHealth * ( npcTarget:GetMaxHealth() - npcTarget:GetHealth()) ;
		nNumber  = nNumber * MagicResist;
		bot:ActionImmediate_Chat(nMessage..string.gsub(tostring(nNumber),"npc_dota_",""),true);
		
		nMessage = "计算伤害值:";
		nNumber  = EstDamage * MagicResist;
		bot:ActionImmediate_Chat(nMessage..string.gsub(tostring(nNumber),"npc_dota_",""),true);
		
		-- nMessage = "目标魔法增强率:";
		-- nNumber  = npcTarget:GetSpellAmp();
		-- bot:ActionImmediate_Chat(nMessage..string.gsub(tostring(nNumber),"npc_dota_",""),true);
		
		nMessage = npcTarget:GetUnitName();
		nNumber  = npcTarget:GetHealth();
		bot:ActionImmediate_Chat(string.gsub(tostring(nMessage),"npc_dota_","")..'当前生命值:'..tostring(nNumber),true);

	end

end

return X
-- dota2jmz@163.com QQ:2462331592.
