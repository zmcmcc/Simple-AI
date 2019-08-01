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
						{2,3,1,2,2,6,2,3,3,3,6,1,1,1,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)

X['sBuyList'] = {
				sOutfit,
				"item_crimson_guard",
				"item_heavens_halberd",
				"item_lotus_orb",
				"item_assault", 
--				"item_heart",
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
local abilityR = npcBot:GetAbilityByName( sAbilityList[6] )


local castQDesire
local castWDesire, castWTarget
local castRDesire, castRTarget

local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;


function X.SkillsComplement()

	
	if J.CanNotUseAbility(npcBot) or npcBot:IsInvisible() then return end

	
	
	nKeepMana = 180
	nMP = npcBot:GetMana()/npcBot:GetMaxMana();
	nHP = npcBot:GetHealth()/npcBot:GetMaxHealth();
	nLV = npcBot:GetLevel();
	hEnemyHeroList = npcBot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	
	
	castRDesire, castRTarget = X.ConsiderR();
	if ( castRDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, true)

		npcBot:ActionQueue_UseAbilityOnEntity( abilityR, castRTarget)
		return;
	end

	castQDesire = X.ConsiderQ();
	if ( castQDesire > 0) 
	then
	
		J.SetQueuePtToINT(npcBot, true)
	
		npcBot:ActionQueue_UseAbility( abilityQ )
		return;
	end
	
	castWDesire, castWTarget   = X.ConsiderW();
	if ( castWDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, true)
		
		if npcBot:HasScepter() 
		then
			npcBot:ActionQueue_UseAbilityOnLocation( abilityW, castWTarget:GetLocation() )
		else
			npcBot:ActionQueue_UseAbilityOnEntity( abilityW, castWTarget )
		end
		return;
	end
	

end

function X.ConsiderW()

	if not abilityW:IsFullyCastable() then return 0 end
	
	local nCastRange = abilityW:GetCastRange();
	local nAttackRange = npcBot:GetAttackRange();
	local nDamage = (abilityW:GetLevel() *8 + 8) * 12;
	
	local nEnemysHerosInCastRange = npcBot:GetNearbyHeroes(nCastRange + 80 ,true,BOT_MODE_NONE);
	local nWeakestEnemyHeroInCastRange = J.GetVulnerableWeakestUnit(true, true, nCastRange + 80, npcBot);
	local npcTarget = J.GetProperTarget(npcBot)
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
			
			if J.IsValidHero(npcTarget) and
				not npcTarget:HasModifier("modifier_axe_battle_hunger")
			then
				if J.IsInRange(npcTarget, npcBot, nCastRange + 80)   
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
		
		if J.CanCastOnMagicImmune(nEnemysHerosInCastRange[1]) and
			not nEnemysHerosInCastRange[1]:HasModifier("modifier_axe_battle_hunger")
		then
			castRTarget = nEnemysHerosInCastRange[1];   
			return BOT_ACTION_DESIRE_HIGH,castRTarget;
		end
	end	
	
	
	if npcBot:GetActiveMode() == BOT_MODE_ROSHAN and npcBot:HasScepter()
	then
	    local nAttackTarget = npcBot:GetAttackTarget();
		if  nAttackTarget ~= nil and nAttackTarget:IsAlive() and
		not nAttackTarget:HasModifier("modifier_axe_battle_hunger")
		then
			return BOT_ACTION_DESIRE_HIGH,nAttackTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE	
end

function X.ConsiderQ()

	-- Make sure it's castable
	if ( not abilityQ:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end

	-- Get some of its values
	local nRadius    = abilityQ:GetSpecialValueInt( "radius" );
	local nCastPoint = abilityQ:GetCastPoint( );
	local nManaCost  = abilityQ:GetManaCost( );
	local nSkillLV   = abilityQ:GetLevel();
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nRadius - 80, true, BOT_MODE_NONE );
	
	-- If we're doing Roshan
	if ( npcBot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = npcBot:GetAttackTarget();
		if ( J.IsRoshan(npcTarget) and J.CanCastOnMagicImmune(npcTarget) and J.IsInRange(npcBot, npcTarget, nRadius - 80)  )
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if J.IsInTeamFight(npcBot, 1200)
	then
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 1 then
			return BOT_ACTION_DESIRE_LOW;
		end
	end
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = J.GetProperTarget(npcBot);
		if J.IsValidHero(npcTarget) and J.CanCastOnMagicImmune(npcTarget) and J.IsInRange(npcTarget, npcBot, nRadius-100)
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
	local nCastRange = abilityR:GetCastRange() + 600;
	local nSkillLV   = abilityR:GetLevel();
	local nKillHealth = 75 * nSkillLV + 175;

	-- If we're going after someone
	if J.IsGoingOnSomeone(npcBot)
	then
		local npcTarget = J.GetProperTarget(npcBot);
		if J.IsValidHero(npcTarget) 
		   and J.CanCastOnNonMagicImmune(npcTarget) 
		   and not J.IsHaveAegis(npcTarget)
		   and J.IsInRange(npcTarget, npcBot, nCastRange + 200)
		then
			if --J.CanKillTarget(npcTarget, nKillHealth, DAMAGE_TYPE_MAGICAL ) 
			npcTarget:GetHealth() < nKillHealth
			then
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
			then
				if --J.CanKillTarget(npcEnemy, nKillHealth, DAMAGE_TYPE_MAGICAL )
				npcEnemy:GetHealth() < nKillHealth
				then
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
	
	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if J.IsValidHero(npcEnemy) 
		   and not J.IsHaveAegis(npcEnemy) 
		then
			if J.CanCastOnNonMagicImmune(npcEnemy) and --J.CanKillTarget(npcEnemy, nKillHealth, DAMAGE_TYPE_MAGICAL )
			npcEnemy:GetHealth() < nKillHealth
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end

return X