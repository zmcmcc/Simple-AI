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
						['t20'] = {0, 10},
						['t15'] = {0, 10},
						['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
						{1,3,2,2,2,6,2,1,1,1,6,3,3,3,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)


X['sBuyList'] = {
				sOutfit,
				"item_crimson_guard",
				"item_echo_sabre",
				"item_heavens_halberd",
				"item_manta",
--				"item_heart",
				"item_assault",
}

X['sSellList'] = {
	"item_crimson_guard",
	"item_quelling_blade",
	"item_assault",
	"item_echo_sabre",
}

nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList'] = J.SetUserHeroInit(nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList']);

X['sSkillList'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)


X['bDeafaultAbility'] = false
X['bDeafaultItem'] = true

function X.MinionThink(hMinionUnit)

	if minion.IsValidUnit(hMinionUnit) 
	then
		minion.IllusionThink(hMinionUnit)
	end

end

local abilityQ = npcBot:GetAbilityByName( sAbilityList[1] );
local abilityW = npcBot:GetAbilityByName( sAbilityList[2] );
local abilityR = npcBot:GetAbilityByName( sAbilityList[6] );

local castQDesire,castQTarget = 0;
local castWDesire,castWTarget = 0;
local castRDesire = 0;

local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;


function X.SkillsComplement()


	
	if J.CanNotUseAbility(npcBot) or npcBot:IsInvisible() then return end

	
	
	nKeepMana = 240; 
	nMP = npcBot:GetMana()/npcBot:GetMaxMana();
	nHP = npcBot:GetHealth()/npcBot:GetMaxHealth();
	nLV = npcBot:GetLevel();
	hEnemyHeroList = npcBot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	
	
	
	
	castRDesire              = X.ConsiderR();
	if ( castRDesire > 0 ) 
	then
	
		npcBot:ActionQueue_UseAbility( abilityR )
		return;
	
	end
	
	castWDesire, castWTarget = X.ConsiderW();
	if ( castWDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, false)
	
		npcBot:ActionQueue_UseAbilityOnEntity( abilityW, castWTarget )
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
	
	if not abilityQ:IsFullyCastable() or npcBot:IsRooted() then return BOT_ACTION_DESIRE_NONE end
	
	local nCastRange = abilityQ:GetCastRange( ) + 50;
	local nCastPoint = abilityQ:GetCastPoint( );
	local nSkillLV   = abilityQ:GetLevel( );
	local nDamage    = 30 + nSkillLV*30 + 120 * 0.38;
	
	local nEnemysHeroesInCastRange = npcBot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);	
	local nEnemysHeroesInView      = npcBot:GetNearbyHeroes(800, true, BOT_MODE_NONE);
	
	--击杀
	if #nEnemysHeroesInCastRange > 0 then
		for i=1, #nEnemysHeroesInCastRange do
			if J.IsValid(nEnemysHeroesInCastRange[i])
			   and J.CanCastOnNonMagicImmune(nEnemysHeroesInCastRange[i]) 
			   and nEnemysHeroesInCastRange[i]:GetHealth() < nEnemysHeroesInCastRange[i]:GetActualIncomingDamage(nDamage,DAMAGE_TYPE_MAGICAL)
			   and not (GetUnitToUnitDistance(nEnemysHeroesInCastRange[i],npcBot) <= npcBot:GetAttackRange() + 60)
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
	if J.IsInTeamFight(npcBot, 1200)
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
				and not npcEnemy:HasModifier("modifier_chaos_knight_reality_rift_debuff")
			then
				local npcEnemyDamage = npcEnemy:GetEstimatedDamageToTarget( false, npcBot, 3.0, DAMAGE_TYPE_ALL );
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
	
	
	--配合
	for _,npcEnemy in pairs( nEnemysHeroesInCastRange )
	do
		if  J.IsValid(npcEnemy)
		    and J.CanCastOnNonMagicImmune(npcEnemy) 
			and not J.IsDisabled(true, npcEnemy)
			and not npcEnemy:IsDisarmed()
			and npcEnemy:HasModifier("modifier_chaos_knight_reality_rift")
		then
		    local npcModifier = npcEnemy:NumModifiers();
			for i = 0, npcModifier 
			do
				if npcEnemy:GetModifierName(i) == "modifier_chaos_knight_reality_rift" 
				then
					if ( npcEnemy:GetModifierRemainingDuration(i) <= nCastPoint )
					then
						return BOT_ACTION_DESIRE_HIGH, npcEnemy;
					end
					break;
				end
			end
		end
	end
	
	--常规
	if J.IsGoingOnSomeone(npcBot)
	then
		local target = J.GetProperTarget(npcBot)
		if J.IsValidHero(target) 
			and J.CanCastOnNonMagicImmune(target) 
			and J.IsInRange(target, npcBot, nCastRange) 
		    and not J.IsDisabled(true, target)
			and not target:IsDisarmed()
			and not target:HasModifier("modifier_chaos_knight_reality_rift_debuff")
		then
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	
	
	if J.IsRetreating(npcBot) 
	then
		if J.IsValid(nEnemysHeroesInCastRange[1]) 
		   and J.CanCastOnNonMagicImmune(nEnemysHeroesInCastRange[1]) 
		   and not J.IsDisabled(true, nEnemysHeroesInCastRange[1])
		   and not nEnemysHeroesInCastRange[1]:IsDisarmed()
		   and GetUnitToUnitDistance(npcBot,nEnemysHeroesInCastRange[1]) <= nCastRange - 60 
		then
			
			return BOT_ACTION_DESIRE_HIGH, nEnemysHeroesInCastRange[1];
		end
	end
	
	
	if npcBot:GetActiveMode() == BOT_MODE_ROSHAN 
		and  npcBot:GetMana() > 400
	then
		local target =  npcBot:GetAttackTarget();
		
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
	if not abilityW:IsFullyCastable() or npcBot:IsRooted() then return BOT_ACTION_DESIRE_NONE end
	
	local nCastRange = abilityW:GetCastRange() + 40;
	local nCastPoint = abilityW:GetCastPoint();
	local nSkillLV   = abilityW:GetLevel();
	local nDamage    = 0;
	
	local nEnemysHeroesInCastRange = npcBot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);	
	
	
	if J.IsInTeamFight(npcBot, 1200)
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
			npcBot:SetTarget(npcTarget);
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
			npcBot:SetTarget(npcTarget);
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
			
			npcBot:SetTarget(npcTarget);
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end			
	end
	
	
	if J.IsGoingOnSomeone(npcBot)
		and DotaTime() > 6*30 
	then
		local target = J.GetProperTarget(npcBot)
		if  J.IsValidHero(target) 
			and J.CanCastOnNonMagicImmune(target) 
			and J.IsInRange(target, npcBot, nCastRange) 
		    and not J.IsDisabled(true, target)
		then
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	
	
	if J.IsRetreating(npcBot) 
	then
		local enemies = npcBot:GetNearbyHeroes(800, true, BOT_MODE_NONE);
		local creeps  = npcBot:GetNearbyLaneCreeps(nCastRange, true);
		if J.IsValid(enemies[1])
		   and npcBot:IsFacingLocation(enemies[1]:GetLocation(),45)
		   and J.CanCastOnNonMagicImmune(enemies[1])
		   and J.IsInRange(enemies[1], npcBot, 150)
		   and not J.IsDisabled(true, enemies[1])
		   and not enemies[1]:IsDisarmed()
		then
			
			return BOT_ACTION_DESIRE_HIGH, enemies[1];
		end		
		
		if enemies[1] ~= nil and creeps[1] ~= nil
		then
		    for _,creep in pairs( creeps )
			do
				if  enemies[1]:IsFacingLocation(npcBot:GetLocation(),30)
					and npcBot:IsFacingLocation(creep:GetLocation(),30)
					and GetUnitToUnitDistance(npcBot,creep) >= 650
				then
					
					return BOT_ACTION_DESIRE_LOW, creep;
				end
			end
		end
	end
	
	
	if hEnemyHeroList[1] == nil
		and npcBot:GetAttackDamage() >= 150
	then
		local nCreeps = npcBot:GetNearbyLaneCreeps(1000,true);
		for i=1,#nCreeps
		do
		    local creep = nCreeps[#nCreeps -i +1]
			if J.IsValid(creep)
			   and not creep:HasModifier("modifier_fountain_glyph")
			   and J.IsKeyWordUnit("ranged",creep)
			   and GetUnitToUnitDistance(npcBot,creep) >= 350
			then
				return BOT_ACTION_DESIRE_LOW, creep;
		    end
		end
	end
	
	if npcBot:GetActiveMode() == BOT_MODE_ROSHAN 
		and npcBot:GetMana() > 400
	then
		local target =  npcBot:GetAttackTarget();
		if target ~= nil 
			and not J.IsDisabled(true, target)
			and not target:IsDisarmed()
		then
			return BOT_ACTION_DESIRE_LOW, target;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end

function X.ConsiderR()
	
	if not abilityR:IsFullyCastable() or npcBot:DistanceFromFountain() < 500 then return BOT_ACTION_DESIRE_NONE end

	local nNearbyAllyHeroes = npcBot:GetNearbyHeroes( 1600, false, BOT_MODE_NONE );
	local nNearbyEnemyHeroes  = npcBot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE );
	local nNearbyEnemyTowers = npcBot:GetNearbyTowers(800,true);
	local nNearbyEnemyBarracks = npcBot:GetNearbyBarracks(400,true);
	local nNearbyAlliedCreeps = npcBot:GetNearbyLaneCreeps(1000,false);
	
	
	-- if #nNearbyAllyHeroes + #nNearbyEnemyHeroes >= 3
	   -- and  #hEnemyHeroList - #nNearbyAllyHeroes <= 2
	   -- and  (#nNearbyEnemyHeroes >= 2 or (#hEnemyHeroList <= 1 and #nNearbyEnemyHeroes >= 1 ))
	-- then
	  	-- return BOT_ACTION_DESIRE_HIGH;
	-- end
	
	if J.IsGoingOnSomeone(npcBot) and #nNearbyAllyHeroes - #nNearbyEnemyHeroes < 3
	then
		local hBotTarget = J.GetProperTarget(npcBot)
		if J.IsValidHero(hBotTarget)
		   and J.CanCastOnMagicImmune(hBotTarget)
		   and J.IsInRange(hBotTarget, npcBot, abilityW:IsFullyCastable() and 770 or 660 )
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	
	if J.IsPushing(npcBot) 
	   and DotaTime() > 6 * 30
	then
		if (#nNearbyEnemyTowers >= 1 or #nNearbyEnemyBarracks >= 1)
			and #nNearbyAlliedCreeps >= 2
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end	
	
	
	if npcBot:GetActiveMode() == BOT_MODE_RETREAT
	   and nHP >= 0.5
	   and nNearbyEnemyHeroes[1] ~= nil
	   and GetUnitToUnitDistance(npcBot,nNearbyEnemyHeroes[1]) <= 400
	then
		return BOT_ACTION_DESIRE_HIGH;
	end
	
	return BOT_ACTION_DESIRE_NONE;
end


return X
-- dota2jmz@163.com QQ:2462331592
