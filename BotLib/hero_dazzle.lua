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
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{1,3,1,3,1,6,1,2,3,3,6,2,2,2,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)

X['sBuyList'] = {
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

X['sSellList'] = {
	"item_crimson_guard",
	"item_quelling_blade",
}

nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList'] = J.SetUserHeroInit(nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList']);

X['sSkillList'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)


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


local castRDesire,castRTarget
local castWDesire,castWTarget
local castEDesire,castETarget

local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;

function X.SkillsComplement()

	
	
	if J.CanNotUseAbility(npcBot) then return end
	
	
	
	nKeepMana = 400; 
	nLV = npcBot:GetLevel();
	nMP = npcBot:GetMana()/npcBot:GetMaxMana();
	nHP = npcBot:GetHealth()/npcBot:GetMaxHealth();
	hEnemyHeroList = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	
	
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
	
		J.SetQueuePtToINT(npcBot, false)
	
		npcBot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget )
		return;
	end

	castEDesire, castETarget = X.ConsiderE();
	if ( castEDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, false)
	
		npcBot:ActionQueue_UseAbilityOnEntity( abilityE, castETarget )
		return;
	end

end

function X.ConsiderQ()

	if not abilityQ:IsFullyCastable() then return 0 end
	
	local nCastRange = abilityQ:GetCastRange();
	local nAttackRange = npcBot:GetAttackRange();
	local nDamage = (abilityQ:GetLevel() * 12 + 4) * (abilityQ:GetLevel() + 3);
	
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
			
			if J.IsValidHero(npcTarget)                        
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
		
		if J.CanCastOnMagicImmune(nEnemysHerosInCastRange[1])
		then
			castRTarget = nEnemysHerosInCastRange[1];   
			return BOT_ACTION_DESIRE_HIGH,castRTarget;
		end
	end	
	
	
	if npcBot:GetActiveMode() == BOT_MODE_ROSHAN and npcBot:HasScepter()
	then
	    local nAttackTarget = npcBot:GetAttackTarget();
		if  nAttackTarget ~= nil and nAttackTarget:IsAlive()
			--and nAttackTarget:HasModifier("modifier_viper_poison_attack_slow")
		then
			return BOT_ACTION_DESIRE_HIGH,nAttackTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE	
end

function X.ConsiderE()
	if not abilityE:IsFullyCastable() then return 0 end
	
	local nCastRange = abilityE:GetCastRange();
	local nArrysHerosInCastRange = npcBot:GetNearbyHeroes(nCastRange + 80 ,false,BOT_MODE_NONE);

	for _,npcArry in pairs( nArrysHerosInCastRange )
	do
		local tableNearbyEnemyHeroes = npcArry:GetNearbyHeroes( 185, true, BOT_MODE_NONE );
		local arryHP = npcArry:GetHealth()/npcArry:GetMaxHealth();

		if tableNearbyEnemyHeroes ~= nil and
		 #tableNearbyEnemyHeroes > 1 or
		 arryHP <= 0.6
		then
			return BOT_ACTION_DESIRE_MODERATE, npcArry;
		end

		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 3
		then
			return BOT_ACTION_DESIRE_HIGH, npcArry;
		end

		if arryHP <= 0.3
		then
			return BOT_ACTION_DESIRE_HIGH, npcArry;
		end
	end

	return BOT_ACTION_DESIRE_NONE	
end


function X.ConsiderW()
	if not abilityW:IsFullyCastable() then return 0 end

	local nCastRange = abilityE:GetCastRange();
	local nArrysHerosInCastRange = npcBot:GetNearbyHeroes(nCastRange + 80 ,false,BOT_MODE_NONE);

	for _,npcArry in pairs( nArrysHerosInCastRange )
	do
		local arryHP = npcArry:GetHealth()/npcArry:GetMaxHealth();

		if arryHP <= 0.2
		then
			return BOT_ACTION_DESIRE_HIGH, npcArry;
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

return X
