local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local Minion = dofile( GetScriptDirectory()..'/FunLib/Minion')
local sTalentList = J.Skill.GetTalentList(bot)
local sAbilityList = J.Skill.GetAbilityList(bot)

--local tTalentTreeList = {
--						['t25'] = {0, 10},
--						['t20'] = {10, 0},
--						['t15'] = {0, 10},
--						['t10'] = {10, 0},
--}
--
--local tAllAbilityBuildList = {
--						{1,3,1,3,1,6,1,2,3,3,6,2,2,2,6},
--}
--
--local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)
--
--local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)
--
--X['sBuyList'] = {
--				'item_tango',
--				'item_enchanted_mango',
--				'item_double_branches',
--				'item_enchanted_mango',
--				'item_clarity',
--				'item_arcane_boots',
--				'item_rod_of_atos',
--				'item_sheepstick',
--				'item_ultimate_scepter',
--}
--
--X['sSellList'] = {
--	"item_crimson_guard",
--	"item_quelling_blade",
--}

-- 出装和加点来自于Misunderstand

local tTalentTreeList = {
						['t25'] = {10, 0},
						['t20'] = {10, 0},
						['t15'] = {10, 0},
						['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
						{ 1, 3, 1, 3, 2, 6, 1, 1, 3, 3, 6, 2, 2, 2, 6 }
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)

X['sBuyList'] = {
				"item_blight_stone",
				"item_double_tango",
				"item_clarity",
				"item_enchanted_mango",
				"item_magic_stick",
				"item_double_enchanted_mango",
				"item_magic_wand",
				"item_wind_lace",
				"item_medallion_of_courage",
				"item_arcane_boots",
				"item_hand_of_midas",
				"item_force_staff",
				"item_guardian_greaves",
				"item_pipe",
				"item_solar_crest",
				"item_necronomicon_3",
				"item_sheepstick",
				"item_ultimate_scepter_2",
				"item_silver_edge",
				"item_moon_shard",
}

X['sSellList'] = {
	"item_aeon_disk",
	"item_magic_wand",

	"item_necronomicon_3",
	"item_force_staff",

	"item_silver_edge",
	"item_hand_of_midas",

	"item_silver_edge",
	"item_aeon_disk",
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

local abilityQ = bot:GetAbilityByName( sAbilityList[1] );
local abilityW = bot:GetAbilityByName( sAbilityList[2] );
local abilityE = bot:GetAbilityByName( sAbilityList[3] );


local castRDesire,castRTarget
local castWDesire,castWTarget
local castEDesire,castETarget

local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;

function X.SkillsComplement()

	
	
	if J.CanNotUseAbility(bot) then return end
	
	
	
	nKeepMana = 400; 
	nLV = bot:GetLevel();
	nMP = bot:GetMana()/bot:GetMaxMana();
	nHP = bot:GetHealth()/bot:GetMaxHealth();
	hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	
	
	castWDesire, castWTarget = X.ConsiderW();
	if ( castWDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, false)

		if bot:HasScepter() 
		then
			bot:ActionQueue_UseAbilityOnLocation( abilityW, castWTarget:GetLocation() )
		else
			bot:ActionQueue_UseAbilityOnEntity( abilityW, castWTarget )
		end
	
		return;
	end
	
	
	castQDesire, castQTarget = X.ConsiderQ();
	if ( castQDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, false)
	
		bot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget )
		return;
	end

	castEDesire, castETarget = X.ConsiderE();
	if ( castEDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, false)
	
		bot:ActionQueue_UseAbilityOnEntity( abilityE, castETarget )
		return;
	end

end

function X.ConsiderQ()

	if not abilityQ:IsFullyCastable() then return 0 end
	
	local nCastRange = abilityQ:GetCastRange();
	local nAttackRange = bot:GetAttackRange();
	local nDamage = (abilityQ:GetLevel() * 12 + 4) * (abilityQ:GetLevel() + 3);
	
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
	local nAllysHerosInCastRange = bot:GetNearbyHeroes(nCastRange + 80 ,false,BOT_MODE_NONE);
	local Enemys = 0;
	local targetally = nil

	for _,npcAlly in pairs( nAllysHerosInCastRange )
	do
		local tableNearbyEnemyHeroes = J.GetAroundTargetEnemyUnitCount(npcAlly, 185);
		local allyHP = npcAlly:GetHealth()/npcAlly:GetMaxHealth();

		if tableNearbyEnemyHeroes ~= nil and
		 tableNearbyEnemyHeroes > 1 or
		 allyHP <= 0.6
		then
			if targetally == nil then
				targetally = npcAlly;
			end
			Enemys = Enemys + 1
		end

		if tableNearbyEnemyHeroes ~= nil and tableNearbyEnemyHeroes >= 2
		then
			if targetally == nil then
				targetally = npcAlly;
			end
			Enemys = Enemys + 2
		end

		if allyHP <= 0.15 and nLV > 14
		then
			return BOT_ACTION_DESIRE_HIGH, npcAlly;
		end
	end

	if targetally ~= nil and nMP > 0.15 then
		if Enemys > 7 then
			return BOT_ACTION_DESIRE_VERYHIGH, targetally;
		elseif Enemys > 5 and nLV >= 6 then
			return BOT_ACTION_DESIRE_HIGH, targetally;
		elseif Enemys > 3 and nMP > 0.3 and nLV >= 10 then
			return BOT_ACTION_DESIRE_MODERATE, targetally;
		end
	end

	return BOT_ACTION_DESIRE_NONE	
end


function X.ConsiderW()
	if not abilityW:IsFullyCastable() then return 0 end

	local nCastRange = abilityE:GetCastRange();
	local nAllysHerosInCastRange = bot:GetNearbyHeroes(nCastRange + 80 ,false,BOT_MODE_NONE);

	for _,npcAlly in pairs( nAllysHerosInCastRange )
	do
		local allyHP = npcAlly:GetHealth()/npcAlly:GetMaxHealth();

		if allyHP <= 0.25
		then
			return BOT_ACTION_DESIRE_HIGH, npcAlly;
		end
	end

	return BOT_ACTION_DESIRE_NONE

end

return X
