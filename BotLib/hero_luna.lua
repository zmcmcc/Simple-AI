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
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{3,1,1,2,1,6,1,2,2,2,6,3,3,3,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)

X['sBuyList'] = {
				sOutfit,
				'item_pers', 
				'item_dragon_lance', 
				'item_yasha',
				'item_manta',
				'item_sphere',
				'item_hurricane_pike',
				'item_black_king_bar',
				'item_lesser_crit',
				'item_bloodthorn',
}

X['sSellList'] = {
	"item_hurricane_pike",
	"item_magic_wand",
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
local abilityR = npcBot:GetAbilityByName( sAbilityList[6] );
local talent2 = npcBot:GetAbilityByName( sTalentList[2] );
local talent6 = npcBot:GetAbilityByName( sTalentList[6] );

local castQDesire,castQTarget = 0;
local castRDesire = 0;

local nKeepMana,nMP,nHP,nLV;
local aetherRange = 0
local talent6BonusDamage = 0;

function X.SkillsComplement()

	J.ConsiderTarget();
	
	if J.CanNotUseAbility(npcBot) then return end
	
	nKeepMana = 400; 
	aetherRange = 0
	nMP = npcBot:GetMana()/npcBot:GetMaxMana();
	nHP = npcBot:GetHealth()/npcBot:GetMaxHealth();
	nLV = npcBot:GetLevel();
	
	local aether = J.IsItemAvailable("item_aether_lens");
	if aether ~= nil then aetherRange = 250 end
	
	if talent2:IsTrained() then aetherRange = aetherRange + talent2:GetSpecialValueInt("value") end
	if talent6:IsTrained() then talent6BonusDamage = talent6:GetSpecialValueInt("value") end
	
	
	castRDesire = X.ConsiderR();
	if ( castRDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, false)
	
		npcBot:ActionQueue_UseAbility( abilityR );
		return;
	
	end
	
	castQDesire, castQTarget = X.ConsiderQ();
	if ( castQDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, false)
	
		npcBot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget )
		return;
	end

end

function X.ConsiderQ()

	-- Make sure it's castable
	if not abilityQ:IsFullyCastable() 
	   or npcBot:IsInvisible() 
	   or ( nLV >= 6 and abilityR:GetCooldownTimeRemaining() <= 2.0 and ( npcBot:GetMana() - abilityQ:GetManaCost()) < abilityR:GetManaCost())
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange  = abilityQ:GetCastRange() + aetherRange
	local nCastPoint  = abilityQ:GetCastPoint();
	local nManaCost   = abilityQ:GetManaCost();
	local nSkillLV    = abilityQ:GetLevel();                             
	local nDamage     = 75 * nSkillLV + talent6BonusDamage;
	local nDamageType = DAMAGE_TYPE_MAGICAL;
	
	local nAllies =  npcBot:GetNearbyHeroes(1200,false,BOT_MODE_NONE);
	
	local nEnemysHerosInView  = npcBot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	local nEnemysHerosInRange = npcBot:GetNearbyHeroes(nCastRange + 50,true,BOT_MODE_NONE);
	local nEnemysHerosInBonus = npcBot:GetNearbyHeroes(nCastRange + 300,true,BOT_MODE_NONE);
		
	
	--打断和击杀
	for _,npcEnemy in pairs( nEnemysHerosInBonus )
	do
		if J.IsValid(npcEnemy)
		   and J.CanCastOnNonMagicImmune(npcEnemy)
		then
			if npcEnemy:IsChanneling()
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
			
			if  GetUnitToUnitDistance(npcBot,npcEnemy) <= nCastRange + 80
				and J.CanKillTarget(npcEnemy,nDamage,nDamageType)
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
			
		end
	end
	
	--团战中对血量最低的敌人使用
	if J.IsInTeamFight(npcBot, 1200)
	then
		local npcWeakestEnemy = nil;
		local npcWeakestEnemyHealth = 10000;		
		
		for _,npcEnemy in pairs( nEnemysHerosInRange )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and not J.IsDisabled(true, npcEnemy)
			then
				local npcEnemyHealth = npcEnemy:GetHealth();
				if ( npcEnemyHealth < npcWeakestEnemyHealth )
				then
					npcWeakestEnemyHealth = npcEnemyHealth;
					npcWeakestEnemy = npcEnemy;
				end
			end
		end
		
		if ( npcWeakestEnemy ~= nil )
		then
			return BOT_ACTION_DESIRE_HIGH, npcWeakestEnemy;
		end		
	end
	
	--受到伤害时保护自己
	if npcBot:WasRecentlyDamagedByAnyHero(3.0) 
		and npcBot:GetActiveMode() ~= BOT_MODE_RETREAT
		and not npcBot:IsInvisible()
		and #nEnemysHerosInRange >= 1
		and nLV >= 10
	then
		for _,npcEnemy in pairs( nEnemysHerosInRange )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and not J.IsDisabled(true, npcEnemy)
                and not npcEnemy:IsDisarmed()				
				and npcBot:IsFacingLocation(npcEnemy:GetLocation(),45)
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end
	
	--对线期间对线上小兵使用
	if npcBot:GetActiveMode() == BOT_MODE_LANING or nLV <= 7
	then
		local nLaneCreeps = npcBot:GetNearbyLaneCreeps(nCastRange +200,true);
		local keyWord = "ranged"
		for _,creep in pairs(nLaneCreeps)
		do
			if J.IsValid(creep)
				and not creep:HasModifier("modifier_fountain_glyph")
				and J.IsKeyWordUnit(keyWord,creep)
				and J.WillKillTarget(creep,nDamage,nDamageType,nCastPoint)
				and GetUnitToUnitDistance(creep,npcBot) > npcBot:GetAttackRange() + 80
			then
				return BOT_ACTION_DESIRE_HIGH, creep;
			end
		end
		
		if nSkillLV >= 2
			and ( npcBot:GetMana() > 350 or nMP > 0.95 )
		then
			local keyWord = "melee";
			for _,creep in pairs(nLaneCreeps)
			do
				if J.IsValid(creep)
					and not creep:HasModifier("modifier_fountain_glyph")
					and J.IsKeyWordUnit(keyWord,creep)
					and J.WillKillTarget(creep,nDamage,nDamageType,nCastPoint)
					and GetUnitToUnitDistance(creep,npcBot) > npcBot:GetAttackRange() + 80
				then
					return BOT_ACTION_DESIRE_HIGH, creep;
				end
			end
		end
	end	
	
	--打架时先手	
	if J.IsGoingOnSomeone(npcBot) and nLV >= 5
	then
	    local npcTarget = J.GetProperTarget(npcBot);
		if J.IsValidHero(npcTarget) 
			and J.CanCastOnNonMagicImmune(npcTarget) 
			and J.IsInRange(npcTarget, npcBot, nCastRange +50) 
			and not J.IsDisabled(true, npcTarget)
			and not npcTarget:IsDisarmed()
		then
			if nSkillLV >= 4 or nMP > 0.88 or J.GetHPR(npcTarget) < 0.38
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	
	--撤退时保护自己
	if J.IsRetreating(npcBot) 
		and not npcBot:IsInvisible()
		and #nEnemysHerosInBonus <= 2
	then
		for _,npcEnemy in pairs( nEnemysHerosInRange )
		do
			if  J.IsValid(npcEnemy)
			    and npcBot:WasRecentlyDamagedByHero( npcEnemy, 5.0 ) 
				and J.CanCastOnNonMagicImmune(npcEnemy) 
				and not J.IsDisabled(true, npcEnemy) 
				and not npcEnemy:IsDisarmed()
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	--发育时对野怪输出
	if  J.IsFarming(npcBot) 
		and nSkillLV >= 3
		and (npcBot:GetAttackDamage() < 200 or nMP > 0.78)
		and J.IsAllowedToSpam(npcBot, nManaCost *0.15)
	then
		local nCreeps = npcBot:GetNearbyNeutralCreeps(nCastRange +100);
		
		local targetCreep = J.GetMostHpUnit(nCreeps);
		
		if J.IsValid(targetCreep)
			and ( #nCreeps >= 2 or GetUnitToUnitDistance(targetCreep,npcBot) <= 400 )
			and npcBot:IsFacingLocation(targetCreep:GetLocation(),30)
			and not J.IsRoshan(targetCreep)
			and (targetCreep:GetMagicResist() < 0.3 or nMP > 0.95)
			and not J.CanKillTarget(targetCreep,npcBot:GetAttackDamage() *1.68,DAMAGE_TYPE_PHYSICAL)
			and not J.CanKillTarget(targetCreep,nDamage - 10,nDamageType)
		then
			return BOT_ACTION_DESIRE_HIGH, targetCreep;
	    end
	end
		
	
	--推进时对小兵用
	if  (J.IsPushing(npcBot) or J.IsDefending(npcBot) or J.IsFarming(npcBot))
	    and J.IsAllowedToSpam(npcBot, nManaCost *0.32)
		and (npcBot:GetAttackDamage() < 200 or nMP > 0.9)
		and nSkillLV >= 3
	then
		local nLaneCreeps = npcBot:GetNearbyLaneCreeps(nCastRange,true);
		local keyWord = "ranged"
		for _,creep in pairs(nLaneCreeps)
		do
			if J.IsValid(creep)
			    and ( J.IsKeyWordUnit(keyWord,creep) or nMP > 0.8 )
				and not creep:HasModifier("modifier_fountain_glyph")
				and J.WillKillTarget(creep,nDamage,nDamageType,nCastPoint)
				and not J.CanKillTarget(creep,npcBot:GetAttackDamage() *1.68,DAMAGE_TYPE_PHYSICAL)
			then
				return BOT_ACTION_DESIRE_HIGH, creep;
			end
		end
	end
	
	--打肉的时候输出
	if  npcBot:GetActiveMode() == BOT_MODE_ROSHAN 
		and npcBot:GetMana() >= 400
	then
		local npcTarget = npcBot:GetAttackTarget();
		if  J.IsRoshan(npcTarget) 
			and not J.IsDisabled(true, npcTarget)
			and not npcTarget:IsDisarmed()
			and J.IsInRange(npcTarget, npcBot, nCastRange)  
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	--通用消耗敌人或受到伤害时保护自己
	if (#nEnemysHerosInView > 0 or npcBot:WasRecentlyDamagedByAnyHero(3.0)) 
		and ( npcBot:GetActiveMode() ~= BOT_MODE_RETREAT or #nAllies >= 2 )
		and #nEnemysHerosInRange >= 1
		and nLV >= 10
	then
		for _,npcEnemy in pairs( nEnemysHerosInRange )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and not J.IsDisabled(true, npcEnemy)			
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end
	
	return 0;

end

function X.ConsiderR()

	-- Make sure it's castable
	if  not abilityR:IsFullyCastable() 
	   or ( npcBot:WasRecentlyDamagedByAnyHero(1.5) and  nHP < 0.38)
	   or npcBot:DistanceFromFountain() < 600
	then return 0; end

	-- Get some of its values
	local nRadius = 675;                          
	
	local nEnemysHerosInSkillRange = npcBot:GetNearbyHeroes(675,true,BOT_MODE_NONE);
	local nEnemysHerosNearby       = npcBot:GetNearbyHeroes(350,true,BOT_MODE_NONE);
	

	if #nEnemysHerosInSkillRange >= 3
		or (#nEnemysHerosNearby >= 1 and #nEnemysHerosInSkillRange >= 2)
	then
		return BOT_ACTION_DESIRE_HIGH;
	end		
	
	local nAoe = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), 100, 600, 0.8, 0 );
	if nAoe.count >= 3
	then
		return BOT_ACTION_DESIRE_HIGH;
	end	
	
	local npcTarget = J.GetProperTarget(npcBot);		
	if J.IsValidHero(npcTarget) 
		and J.CanCastOnNonMagicImmune(npcTarget) 
		and ( GetUnitToUnitDistance(npcTarget,npcBot) <= 350
				or ( J.GetHPR(npcTarget) < 0.38 and  GetUnitToUnitDistance(npcTarget,npcBot) <= 650 ) )
		and npcTarget:GetHealth() > 600
	then
		return BOT_ACTION_DESIRE_HIGH;
	end
				
	return 0;
end

return X
-- dota2jmz@163.com QQ:2462331592
