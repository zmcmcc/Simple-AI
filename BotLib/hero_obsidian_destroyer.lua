local X = {}
local bDebugMode = false;
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local Minion = dofile( GetScriptDirectory()..'/FunLib/Minion')
local sTalentList = J.Skill.GetTalentList(bot)
local sAbilityList = J.Skill.GetAbilityList(bot)
local sOutfit = J.Skill.GetOutfitName(bot)

--local tTalentTreeList = {
--						['t25'] = {10, 0},
--						['t20'] = {10, 0},
--						['t15'] = {10, 0},
--						['t10'] = {10, 0},
--}
--
--local tAllAbilityBuildList = {
--						{2,3,1,3,3,6,3,2,1,2,6,2,1,1,6},
--						{2,3,1,3,3,6,3,1,1,1,6,2,2,2,6}
--}
--
--local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)
--
--local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)
--
--X['sBuyList'] = {
--				sOutfit,
--				"item_hurricane_pike",
--				"item_yasha_and_kaya",
--				"item_black_king_bar",
--				"item_shivas_guard",
--				"item_ultimate_scepter_2",
--				"item_sheepstick",
--}
--
--X['sSellList'] = {
--
--	"item_monkey_king_bar",
--	"item_arcane_boots",
--	
--	"item_cyclone",
--	"item_magic_wand",
--
--}

-- 出装和加点来自于Misunderstand

local tTalentTreeList = {
						['t25'] = {0, 10},
						['t20'] = {10, 0},
						['t15'] = {0, 10},
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{ 2, 3, 2, 1, 2, 6, 2, 3, 3, 1, 6, 1, 3, 1, 6 }
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)

X['sBuyList'] = {
				"item_double_mantle",
				"item_circlet",
				"item_tango",
				"item_magic_stick",
				"item_double_null_talisman",
				"item_flask",
				"item_power_treads",
				"item_kaya",
				"item_blink",
				"item_yasha_and_kaya",
				"item_black_king_bar",
				"item_sheepstick",
				"item_refresher",
				"item_hurricane_pike",
				"item_ultimate_scepter_2",
				"item_moon_shard",
}

X['sSellList'] = {

	"item_black_king_bar",
	"item_magic_stick",
	
	"item_sheepstick",
	"item_null_talisman",
	
	"item_hurricane_pike",
	"item_blink",

}

nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList'] = J.SetUserHeroInit(nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList']);

X['sSkillList'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = true


function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit(hMinionUnit) 
	then
		Minion.IllusionThink(hMinionUnit)	
	end

end

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )

local castQDesire, castQLocation
local castEDesire
local castWDesire, castWTarget
local castRDesire, castRLocation


local nKeepMana,nMP,nHP,nLV,hEnemyList,hAllyList,botTarget;



function X.SkillsComplement()


	
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
	
	
	nKeepMana = 400
	nLV = bot:GetLevel();
	nMP = bot:GetMana()/bot:GetMaxMana();
	nHP = bot:GetHealth()/bot:GetMaxHealth();
	botTarget = J.GetProperTarget(bot);
	hEnemyList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	hAllyList = J.GetAlliesNearLoc(bot:GetLocation(), 1600);
	
	
	
	castRDesire, castRLocation = X.ConsiderR();
	if ( castRDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, true)
	
		bot:Action_UseAbilityOnLocation( abilityR, castRLocation )
		return;
	
	end
	
	castQDesire, castQTarget = X.ConsiderQ();
	if ( castQDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, true)
	
		bot:Action_UseAbilityOnEntity( abilityQ, castQTarget )
		return;
	end

	castEDesire = X.ConsiderE();
	if ( castEDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, true)
	
		bot:Action_UseAbility( abilityE )
		return;
	end
	
	castWDesire, castWTarget = X.ConsiderW();
	if ( castWDesire > 0 ) 
	then
		
		J.SetQueuePtToINT(bot, true)
	
		bot:Action_UseAbilityOnEntity( abilityW, castWTarget )
		return;
	end
	
	
end


function X.ConsiderQ()


	if ( abilityQ:IsFullyCastable() == false ) then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	local attackRange = bot:GetAttackRange()

	-- If we're going after someone
	if J.IsGoingOnSomeone(bot) 
	then
		local npcTarget = bot:GetTarget();
		if J.IsValidHero(npcTarget) and J.CanCastOnNonMagicImmune(npcTarget) and J.IsInRange(npcTarget, bot, attackRange+200)
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
	
end

function X.ConsiderW()

-- Make sure it's castable
if ( not abilityW:IsFullyCastable() ) then 
	return BOT_ACTION_DESIRE_NONE, 0;
end

-- Get some of its values
local nCastRange = abilityW:GetCastRange();
local nDamage = abilityW:GetSpecialValueInt("damage");
--------------------------------------
-- Mode based usage
--------------------------------------
-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
if J.IsRetreating(bot) 
then
	local tableNearbyAllyHeroes = bot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if tableNearbyAllyHeroes ~= nil and #tableNearbyAllyHeroes == 2 
	then
		return BOT_ACTION_DESIRE_HIGH, bot;
	else
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange+200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( bot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) and J.CanCastOnNonMagicImmune(npcEnemy) ) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
end

local tableNearbyFriendlyHeroes = bot:GetNearbyHeroes( 1000, false, BOT_MODE_NONE );
for _,myFriend in pairs(tableNearbyFriendlyHeroes) 
do
	if  myFriend:GetUnitName() ~= bot:GetUnitName() and J.IsRetreating(myFriend) and
		myFriend:WasRecentlyDamagedByAnyHero(2.0) and J.CanCastOnNonMagicImmune(myFriend)
	then
		return BOT_ACTION_DESIRE_MODERATE, myFriend;
	end
end	

-- Check for a channeling enemy
local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange + 200, true, BOT_MODE_NONE );
for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
do
	if ( J.CanKillTarget(npcEnemy, nDamage, DAMAGE_TYPE_MAGICAL) or npcEnemy:IsChanneling() ) and J.CanCastOnNonMagicImmune( npcEnemy ) 
		and not J.IsDisabled(true, npcEnemy) 
	then
		return BOT_ACTION_DESIRE_HIGH, npcEnemy;
	end
end

if J.IsInTeamFight(bot, 1200)
then
	local npcMostDangerousEnemy = nil;
	local nMostDangerousDamage = 0;
	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if J.CanCastOnNonMagicImmune( npcEnemy ) and not J.IsDisabled(true, npcEnemy) 
		then
			local nDamage = npcEnemy:GetEstimatedDamageToTarget( false, bot, 3.0, DAMAGE_TYPE_ALL );
			if ( nDamage > nMostDangerousDamage )
			then
				nMostDangerousDamage = nDamage;
				npcMostDangerousEnemy = npcEnemy;
			end
		end
	end

	if ( npcMostDangerousEnemy ~= nil )
	then
		return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy;
	end
end

-- If we're going after someone
if J.IsGoingOnSomeone(bot)
then
	local npcTarget = bot:GetTarget();
	if J.IsValidHero(npcTarget) and J.CanCastOnNonMagicImmune(npcTarget) and not J.IsInRange(npcTarget, bot, (nCastRange+200)/2) and J.IsInRange(npcTarget, bot, nCastRange+200) and
		not J.IsDisabled(true, npcTarget) 
	then
		local allies = npcTarget:GetNearbyHeroes(450, true, BOT_MODE_NONE);
		if #allies <= 1 then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end	
	end
end

return BOT_ACTION_DESIRE_NONE, 0;
	
end

function X.ConsiderE()

	-- Make sure it's castable
	if ( not abilityE:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end

	-- Get some of its values
	local nAttackRange = bot:GetAttackRange();

	-- If we're going after someone
	if J.IsGoingOnSomeone(bot) or J.IsInTeamFight(bot, 1200)
	then
		local npcTarget = bot:GetTarget();
		if J.IsValidHero(npcTarget) and J.IsInRange(npcTarget, bot, nAttackRange+400)
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end	

function X.ConsiderR()


	-- Make sure it's castable
	if ( not abilityR:IsFullyCastable() ) 
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nRadius = abilityR:GetSpecialValueInt( "radius" );
	local nCastRange = abilityR:GetCastRange();
	local nCastPoint = abilityR:GetCastPoint( );
	local MyIntVal = bot:GetAttributeValue(ATTRIBUTE_INTELLECT); 
	local nMultiplier = abilityR:GetSpecialValueInt( "damage_multiplier" );

	--------------------------------------
	-- Mode based usage
	--------------------------------------
	local tableNearbyAllyHeroes = bot:GetNearbyHeroes( nCastRange, false, BOT_MODE_ATTACK );
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if (  J.IsRetreating(bot)  and tableNearbyAllyHeroes ~= nil and #tableNearbyAllyHeroes >= 2 ) 
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
			end
		end
	end
	
	if J.IsInTeamFight(bot, 1200)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange+(nRadius/2), true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			local EnemyInt = npcEnemy:GetAttributeValue(ATTRIBUTE_INTELLECT);
			local diff = MyIntVal - EnemyInt;
			local nDamage = nMultiplier * diff;
			if ( diff > 0 and J.CanKillTarget(npcEnemy,nDamage, DAMAGE_TYPE_MAGICAL ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetLocation();
			end
		end
	end
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if J.IsValidHero(npcTarget) and J.CanCastOnNonMagicImmune(npcTarget) and J.IsInRange(npcTarget, bot, nCastRange+200)  
		then
			local EnemyInt = npcTarget:GetAttributeValue(ATTRIBUTE_INTELLECT);
			local diff = MyIntVal - EnemyInt;
			local nDamage = nMultiplier * diff;
			if ( diff > 0 and J.CanKillTarget(npcTarget,nDamage, DAMAGE_TYPE_MAGICAL ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation();
			end
		end
	end
--
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X
