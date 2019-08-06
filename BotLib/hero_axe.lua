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
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{2,3,1,2,2,6,2,3,3,3,6,1,1,1,6},
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
local abilityR = bot:GetAbilityByName( sAbilityList[6] )


local castQDesire
local castWDesire, castWTarget
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

		bot:ActionQueue_UseAbilityOnEntity( abilityR, castRTarget)
		return;
	end

	castQDesire = X.ConsiderQ();
	if ( castQDesire > 0) 
	then
	
		J.SetQueuePtToINT(bot, true)
	
		bot:ActionQueue_UseAbility( abilityQ )
		return;
	end
	
	castWDesire, castWTarget   = X.ConsiderW();
	if ( castWDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, true)
		
		if bot:HasScepter() 
		then
			bot:ActionQueue_UseAbilityOnLocation( abilityW, castWTarget:GetLocation() )
		else
			bot:ActionQueue_UseAbilityOnEntity( abilityW, castWTarget )
		end
		return;
	end
	

end

function X.ConsiderW()

	if not abilityW:IsFullyCastable() then return 0 end
	
	local nCastRange = abilityW:GetCastRange();
	local nAttackRange = bot:GetAttackRange();
	local nDamage = (abilityW:GetLevel() *8 + 8) * 12;
	
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
			
			if J.IsValidHero(npcTarget) and
				not npcTarget:HasModifier("modifier_axe_battle_hunger")
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
		
		if J.CanCastOnMagicImmune(nEnemysHerosInCastRange[1]) and
			not nEnemysHerosInCastRange[1]:HasModifier("modifier_axe_battle_hunger")
		then
			castRTarget = nEnemysHerosInCastRange[1];   
			return BOT_ACTION_DESIRE_HIGH,castRTarget;
		end
	end	
	
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN and bot:HasScepter()
	then
	    local nAttackTarget = bot:GetAttackTarget();
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
	
	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nRadius - 80, true, BOT_MODE_NONE );

	if J.IsRetreating(bot)
	then
		local tableEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableEnemyHeroes )
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
	
	-- Make sure it's castable
	if not abilityR:IsFullyCastable() then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityR:GetCastRange() + 600;
	local nSkillLV   = abilityR:GetLevel();
	local nKillHealth = 75 * nSkillLV + 175;

	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = J.GetProperTarget(bot);
		if J.IsValidHero(npcTarget) 
		   and J.CanCastOnNonMagicImmune(npcTarget) 
		   and not J.IsHaveAegis(npcTarget)
		   and J.IsInRange(npcTarget, bot, nCastRange + 200)
		then
			if --J.CanKillTarget(npcTarget, nKillHealth, DAMAGE_TYPE_MAGICAL ) 
			npcTarget:GetHealth() < nKillHealth
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end	

	-- If we're in a teamfight, use it on the scariest enemy
	if J.IsInTeamFight(bot, 1200)
	then
		local npcToKill = nil;
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
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
	
	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
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