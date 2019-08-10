----------------------------------------------------------------------------------------------------
--- The Creation Come From: BOT EXPERIMENT Credit:FURIOUSPUPPY
--- BOT EXPERIMENT Author: Arizona Fauzie 2018.11.21
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=837040016
--- Update by: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
----------------------------------------------------------------------------------------------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local Minion = dofile( GetScriptDirectory()..'/FunLib/Minion')
local sTalentList = J.Skill.GetTalentList(bot)
local sAbilityList = J.Skill.GetAbilityList(bot)
local sOutfit = J.Skill.GetOutfitName(bot)

local tTalentTreeList = {
						['t25'] = {10, 0},
						['t20'] = {0, 10},
						['t15'] = {10, 0},
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{1,2,1,3,1,6,2,2,2,3,6,3,3,1,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)



X['sBuyList'] = {
				sOutfit,
				"item_bfury",
				"item_solar_crest",
				"item_black_king_bar",
				"item_satanic",
				"item_monkey_king_bar",
}


X['sSellList'] = {
	"item_power_treads",
	"item_stout_shield",
	
	'item_satanic',
	'item_magic_wand',
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

--[[
npc_dota_hero_phantom_assassin

--]]


local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityE = bot:GetAbilityByName( sAbilityList[3] )


local castQDesire,castQTarget;
local castWDesire,castWTarget;
local castEDesire;
local castQWDesire,castQWTarget;


local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;


local lastSkillCreep

function X.SkillsComplement()


	
	if J.CanNotUseAbility(bot) then return end
	
	
	nKeepMana = 400
	aetherRange = 0
	talentDamage = 0
	nLV = bot:GetLevel();
	nMP = bot:GetMana()/bot:GetMaxMana();
	nHP = bot:GetHealth()/bot:GetMaxHealth();
	hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	
	

	castEDesire  = X.ConsiderE();	
	if castEDesire > 0
	then
					
		J.SetQueuePtToINT(bot, false)
				
		bot:ActionQueue_UseAbility( abilityE );
		return;
		
	end
		
	castQDesire,castQTarget = X.ConsiderQ();	
	if castQDesire > 0
	then
		local nLaneCreeps = bot:GetNearbyLaneCreeps(1200,true);
		
		if #hEnemyHeroList == 0 and #nLaneCreeps == 0  
		then
			J.SetQueuePtToINT(bot, false)
		else
			bot:Action_ClearActions(false)
		end
				
		bot:ActionQueue_UseAbilityOnEntity( abilityQ , castQTarget);
		return;
	end
	
	castWDesire,castWTarget = X.ConsiderW();	
	if castWDesire > 0
	then
				
		J.SetQueuePtToINT(bot, false)
				
		bot:ActionQueue_UseAbilityOnEntity( abilityW , castWTarget);
		return;
	end
	

end


function X.ConsiderQ()

	if  not abilityQ:IsFullyCastable() then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nAttackDamage = bot:GetAttackDamage();
	local nCastRange  = abilityQ:GetCastRange();
	if nCastRange < 600 then nCastRange = 600 end;	
	local nCastPoint  = abilityQ:GetCastPoint();
	local nManaCost   = abilityQ:GetManaCost();
	local nSkillLV    = abilityQ:GetLevel(); 
	local nBonusPer   = 0.1 + 0.15 * nSkillLV;
	local nDamage     = 65 + nAttackDamage * nBonusPer;
	local nBonusDamage= 24 * nBonusPer;
	
	local nDamageType = DAMAGE_TYPE_PHYSICAL;
	
	local nAllies =  bot:GetNearbyHeroes(1200,false,BOT_MODE_NONE);
	
	local nEnemysHerosInView  = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	local nEnemysHerosInRange = bot:GetNearbyHeroes(nCastRange +50,true,BOT_MODE_NONE);
	local nEnemysHerosInBonus = bot:GetNearbyHeroes(nCastRange + 300,true,BOT_MODE_NONE);
		
	
	--击杀敌人
	for _,npcEnemy in pairs( nEnemysHerosInBonus )
	do
		if J.IsValid(npcEnemy)
		   and J.CanCastOnNonMagicImmune(npcEnemy)
		   and J.CanCastOnTargetAdvanced(npcEnemy)
		   and GetUnitToUnitDistance(bot,npcEnemy) <= nCastRange + 80
		   and ( J.CanKillTarget(npcEnemy,nDamage *1.38,nDamageType) 
		         or ( npcEnemy:IsChanneling() and J.GetHPR(npcEnemy) < 0.25))
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	
	
	--团战中对血量最低的敌人使用
	if J.IsInTeamFight(bot, 1200)
	then
		local npcWeakestEnemy = nil;
		local npcWeakestEnemyHealth = 10000;		
		
		for _,npcEnemy in pairs( nEnemysHerosInRange )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and J.CanCastOnTargetAdvanced(npcEnemy)
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
	
	--对线期间对线上小兵和敌人使用
	if bot:GetActiveMode() == BOT_MODE_LANING or ( nLV <= 14 and ( nLV <= 7 or bot:GetAttackTarget() == nil ))
	then
		local nLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange +80,true);
		local keyWord = "ranged";
		for _,creep in pairs(nLaneCreeps)
		do
			if J.IsValid(creep)
				and not creep:HasModifier("modifier_fountain_glyph")
				and J.IsKeyWordUnit(keyWord,creep)
				and ( GetUnitToUnitDistance(creep,bot) > 350 or nDamage + nBonusDamage -10 > nAttackDamage + 24)
			then
				local nTime = nCastPoint + GetUnitToUnitDistance(bot,creep)/1250;
				if J.WillKillTarget(creep,nDamage + nBonusDamage,nDamageType,nTime *0.9)
				then
					lastSkillCreep = creep ;
					return BOT_ACTION_DESIRE_HIGH, creep;
				end
			end
		end
		
		if bot:GetMana() > 100 + nLV * 10
		then
			local keyWord = "melee";
			for _,creep in pairs(nLaneCreeps)
			do
				if J.IsValid(creep)
					and not creep:HasModifier("modifier_fountain_glyph")
					and J.IsKeyWordUnit(keyWord,creep)
					and GetUnitToUnitDistance(creep,bot) > 320 + nLV * 20
				then
					local nTime = nCastPoint + GetUnitToUnitDistance(bot,creep)/1250;
					if J.WillKillTarget(creep,nDamage + nBonusDamage,nDamageType,nTime *0.9)
					then
						lastSkillCreep = creep ;
						return BOT_ACTION_DESIRE_HIGH, creep;
					end
				end
			end
		end
		
		--对线期间对敌人使用
		local nWeakestEnemyLaneCreep = J.GetVulnerableWeakestUnit(false, true, nCastRange +100, bot);
		local nWeakestEnemyLaneHero  = J.GetVulnerableWeakestUnit(true , true, nCastRange +40, bot);
		if nWeakestEnemyLaneCreep == nil 
		   or (nWeakestEnemyLaneCreep ~= nil 
				and not J.CanKillTarget(nWeakestEnemyLaneCreep,(nDamage+nBonusDamage) *2,nDamageType) )
		then
			if nWeakestEnemyLaneHero ~= nil 
				and ( J.GetHPR(nWeakestEnemyLaneHero) <= 0.48
					  or GetUnitToUnitDistance(bot,nWeakestEnemyLaneHero) < 350 )
			then
				return BOT_ACTION_DESIRE_HIGH, nWeakestEnemyLaneHero;
			end
		end
		
		-- 打断回复
		for _,npcEnemy in pairs( nEnemysHerosInRange )
		do
			if J.IsValid(npcEnemy)
			   and J.CanCastOnNonMagicImmune(npcEnemy)
			   and GetUnitToUnitDistance(bot,npcEnemy) <= nCastRange + 80
			   and ( npcEnemy:HasModifier("modifier_flask_healing") 
					 or npcEnemy:HasModifier("modifier_clarity_potion")
					 or npcEnemy:HasModifier("modifier_bottle_regeneration")
					 or npcEnemy:HasModifier("modifier_rune_regen") )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end	
	
	
	--打架时先手	
	if J.IsGoingOnSomeone(bot)
	then
	    local npcTarget = J.GetProperTarget(bot);
		if J.IsValidHero(npcTarget) 
			and J.CanCastOnNonMagicImmune(npcTarget) 
			and J.CanCastOnTargetAdvanced(npcTarget)
			and J.IsInRange(npcTarget, bot, nCastRange +50) 
		then
			if nSkillLV >= 3 
			   or nMP > 0.6 or nHP < 0.4  
			   or J.GetHPR(npcTarget) < 0.38 
			   or DotaTime() > 6 *60
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	
	
	--撤退时保护自己
	if J.IsRetreating(bot) 
		and #nEnemysHerosInBonus <= 2
	then
		for _,npcEnemy in pairs( nEnemysHerosInRange )
		do
			if  J.IsValid(npcEnemy)
			    and bot:WasRecentlyDamagedByHero( npcEnemy, 5.0 ) 
				and J.CanCastOnNonMagicImmune(npcEnemy) 
				and J.CanCastOnTargetAdvanced(npcEnemy)
				and not J.IsDisabled(true, npcEnemy) 
				and ( bot:IsFacingLocation(npcEnemy:GetLocation(),45)
						or not J.IsInRange(npcEnemy,bot,nCastRange - 300) )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	
	--发育时对野怪输出
	if  J.IsFarming(bot) 
		and ( nSkillLV >= 3 or nMP > 0.88 )
		and J.IsAllowedToSpam(bot, nManaCost *2)
	then
		local nCreeps = bot:GetNearbyNeutralCreeps(nCastRange +80);
		
		local targetCreep = J.GetMostHpUnit(nCreeps);
		
		if J.IsValid(targetCreep)
			and GetUnitToUnitDistance(targetCreep,bot) >= 600
			and not J.IsRoshan(targetCreep)
			and ( not J.CanKillTarget(targetCreep,nDamage + nBonusDamage,nDamageType) or #nCreeps == 1 )
		then
			return BOT_ACTION_DESIRE_HIGH, targetCreep;
	    end
	end
	
	
	--推进时对小兵用
	if  (J.IsPushing(bot) or J.IsDefending(bot) or J.IsFarming(bot))
	    and J.IsAllowedToSpam(bot, nManaCost)
		and ( bot:GetAttackDamage() >= 100 or nLV >= 15 )
		and #nEnemysHerosInView == 0
		and #nAllies <= 2
	then
	
		--补刀远程程兵
		local nLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange + 88,true);
		local keyWord = "ranged"
		for _,creep in pairs(nLaneCreeps)
		do
			if J.IsValid(creep)
				and not creep:HasModifier("modifier_fountain_glyph")
			then
				if J.IsKeyWordUnit(keyWord,creep)
				then
					local nTime = nCastPoint + GetUnitToUnitDistance(bot,creep)/1250;
					if J.WillKillTarget(creep,nDamage + nBonusDamage,nDamageType,nTime *0.9)
					then
						return BOT_ACTION_DESIRE_HIGH, creep;
					end
				end
				
				if  not J.CanKillTarget(creep,bot:GetAttackDamage(),DAMAGE_TYPE_PHYSICAL)
					and not J.IsInRange(creep,bot,nCastRange - 300)
					and ( J.CanKillTarget(creep,nDamage-2,nDamageType)
						 or J.GetUnitAllyCountAroundEnemyTarget(creep, 450) <= 1)
				then
					return BOT_ACTION_DESIRE_HIGH, creep;
				end
			
			end
		end
		
		--补刀非狂战范围内的兵
		local keyWord = "melee";
		for _,creep in pairs(nLaneCreeps)
		do
			if J.IsValid(creep)
				and not creep:HasModifier("modifier_fountain_glyph")
				and J.IsKeyWordUnit(keyWord,creep)
				and GetUnitToUnitDistance(creep,bot) > 350
				and not bot:IsFacingLocation(creep:GetLocation(),80)
			then
				local nTime = nCastPoint + GetUnitToUnitDistance(bot,creep)/1250;
				if J.WillKillTarget(creep,nDamage + nBonusDamage,nDamageType,nTime *0.9)
				then
					return BOT_ACTION_DESIRE_HIGH, creep;
				end
			end
		end
	end
	
	
	--打肉的时候输出
	if  bot:GetActiveMode() == BOT_MODE_ROSHAN 
		and bot:GetMana() >= 200
	then
		local npcTarget = bot:GetAttackTarget();
		if  J.IsRoshan(npcTarget) 
			and J.IsInRange(npcTarget, bot, nCastRange)  
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	
	--通用消耗敌人或受到伤害时保护自己
	if (#nEnemysHerosInView > 0 or bot:WasRecentlyDamagedByAnyHero(3.0)) 
		and ( bot:GetActiveMode() ~= BOT_MODE_RETREAT or #nAllies >= 2 )
		and #nEnemysHerosInRange >= 1
		and nLV >= 7
	then
		for _,npcEnemy in pairs( nEnemysHerosInRange )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and J.CanCastOnTargetAdvanced(npcEnemy)
				and not J.IsDisabled(true, npcEnemy)			
				and bot:IsFacingLocation(npcEnemy:GetLocation(),80)
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end
	

	return 0;
	
end

function X.ConsiderW()

	if  not abilityW:IsFullyCastable() then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nAttackDamage = bot:GetAttackDamage();
	local nCastRange  = abilityW:GetCastRange();
	local nCastPoint  = abilityW:GetCastPoint();
	local nManaCost   = abilityW:GetManaCost();
	local nSkillLV    = abilityW:GetLevel(); 
	local nBonus      = 24;
	local nDamage     = nAttackDamage;
	local nDamageType = DAMAGE_TYPE_PHYSICAL;
	
	local nAllies =  bot:GetNearbyHeroes(1200,false,BOT_MODE_NONE);
	
	local nEnemysHerosInView  = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	local nEnemysHerosInRange = bot:GetNearbyHeroes(nCastRange +50,true,BOT_MODE_NONE);
	local nEnemysHerosInBonus = bot:GetNearbyHeroes(nCastRange + 300,true,BOT_MODE_NONE);

	local nEnemysTowers   = bot:GetNearbyTowers(1400,true);
	local aliveEnemyCount = J.GetNumOfAliveHeroes(true);
	
	
	--击杀敌人
	for _,npcEnemy in pairs( nEnemysHerosInBonus )
	do
		if J.IsValid(npcEnemy)
		   and not npcEnemy:IsAttackImmune()
		   and J.CanCastOnMagicImmune(npcEnemy)
		   and GetUnitToUnitDistance(bot,npcEnemy) <= nCastRange + 80
		   and ( J.CanKillTarget(npcEnemy,nDamage *1.28,nDamageType)
				or ( npcEnemy:IsChanneling() and J.CanKillTarget(npcEnemy,nDamage *2.28,nDamageType)))
		then
			bot:SetTarget(npcEnemy);
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	
	
	--团战中对血量最低的敌人使用
	if J.IsInTeamFight(bot, 1200)
	then
		local npcWeakestEnemy = nil;
		local npcWeakestEnemyHealth = 10000;		
		
		for _,npcEnemy in pairs( nEnemysHerosInRange )
		do
			if  J.IsValid(npcEnemy)
				and not npcEnemy:IsAttackImmune()
			    and J.CanCastOnMagicImmune(npcEnemy) 
			then
				local npcEnemyHealth = npcEnemy:GetHealth();
				local tableNearbyAllyHeroes = npcEnemy:GetNearbyHeroes( 600, true, BOT_MODE_NONE );
				if npcEnemyHealth < npcWeakestEnemyHealth 
					and ( #tableNearbyAllyHeroes >= 1 or aliveEnemyCount <= 2 )
				then
					npcWeakestEnemyHealth = npcEnemyHealth;
					npcWeakestEnemy = npcEnemy;
				end
			end
		end
		
		if ( npcWeakestEnemy ~= nil )
		then
			bot:SetTarget(npcWeakestEnemy);
			return BOT_ACTION_DESIRE_HIGH, npcWeakestEnemy;
		end		
	end
	
	
	--对线期间对线上小兵使用
	if bot:GetActiveMode() == BOT_MODE_LANING and #nEnemysHerosInView == 0 and #nEnemysTowers == 0
	then
		local nLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange +80,true);
		local keyWord = "ranged";
		for _,creep in pairs(nLaneCreeps)
		do
			if J.IsValid(creep)
				and creep ~= lastSkillCreep
				and not creep:HasModifier("modifier_fountain_glyph")
				and J.IsKeyWordUnit(keyWord,creep)
				and GetUnitToUnitDistance(creep,bot) > 400
			then
				local nTime = nCastPoint * 3 ;
				if J.WillKillTarget(creep,nDamage + nBonus,nDamageType,nTime)
				then
					bot:SetTarget(creep);
					return BOT_ACTION_DESIRE_HIGH, creep;
				end				
			end
		end
	end	
	
	
	--打架时先手	
	if J.IsGoingOnSomeone(bot) and nLV >= 3 
	   and ( #nAllies >= 2 or #nEnemysHerosInView <= 1 )
	then
	    local npcTarget = J.GetProperTarget(bot);
		if J.IsValidHero(npcTarget) 
			and not npcTarget:IsAttackImmune()
			and J.CanCastOnMagicImmune(npcTarget) 
			and J.IsInRange(npcTarget, bot, nCastRange +50) 
		then
			local tableNearbyEnemyHeroes = npcTarget:GetNearbyHeroes( 800, false, BOT_MODE_NONE );
			local tableNearbyAllyHeroes = npcTarget:GetNearbyHeroes( 800, true, BOT_MODE_NONE );
			local tableAllEnemyHeroes    = npcTarget:GetNearbyHeroes( 1600, false, BOT_MODE_NONE );
			if  ( J.WillKillTarget(npcTarget,nAttackDamage * 3,DAMAGE_TYPE_PHYSICAL,1.0) )
				or ( #tableNearbyEnemyHeroes <= #tableNearbyAllyHeroes )
				or ( #tableAllEnemyHeroes <= 1 )
				or GetUnitToUnitDistance(bot,npcTarget) <= 400
				or aliveEnemyCount <= 2 
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	
	
	--撤退时逃跑
	if J.IsRetreating(bot) 
	    and bot:WasRecentlyDamagedByAnyHero(2.0)
	then
		local nAttackAllys = bot:GetNearbyHeroes(600,false,BOT_MODE_ATTACK);
		if #nAttackAllys == 0 or nHP < 0.13
		then
		    local nAllyInCastRange = bot:GetNearbyHeroes(nCastRange +80,false,BOT_MODE_NONE);
			local nAllyCreeps      = bot:GetNearbyCreeps(nCastRange +80,false);
			local nEnemyCreeps     = bot:GetNearbyCreeps(nCastRange +80,true);
			local nAllyUnits  = J.CombineTwoTable(nAllyInCastRange,nAllyCreeps)
			local nAllUnits   = J.CombineTwoTable(nAllyUnits,nEnemyCreeps)
			
			local targetUnit = nil
			local targetUnitDistance = J.GetDistanceFromAllyFountain(bot);
			for _,unit in pairs(nAllUnits)
			do
				if J.IsValid(unit)
					and GetUnitToUnitDistance(unit,bot) > 260
					and J.GetDistanceFromAllyFountain(unit) < targetUnitDistance
				then
					targetUnit = unit;
					targetUnitDistance = J.GetDistanceFromAllyFountain(unit)
				end
			end
			
			if targetUnit ~= nil
			then
				return BOT_ACTION_DESIRE_HIGH, targetUnit;
			end
		end
	end
	
	
	--发育时对野怪输出
	if  J.IsFarming(bot) 
		and not bot:HasModifier("modifier_filler_heal")
		and (bot:GetAttackTarget() == nil or not bot:GetAttackTarget():IsBuilding())
		and nLV >= 6
	then
		local nCreeps = bot:GetNearbyNeutralCreeps(nCastRange +80);
		
		local targetCreep = J.GetProperTarget(bot);--J.GetMostHpUnit(nCreeps);
--		if nLV <= 14 then targetCreep = J.GetLeastHpUnit(nCreeps); end
		
		if J.IsValid(targetCreep)
			and not J.IsRoshan(targetCreep)
			and  ( not J.CanKillTarget(targetCreep,nDamage *2,nDamageType)
				   or GetUnitToUnitDistance(targetCreep,bot) >= 650 )
		then
			
			if J.IsAllowedToSpam(bot, nManaCost )			  
			then
				if ( #nCreeps >= 3 and GetUnitToUnitDistance(targetCreep,bot) <= 400 )
					or ( #nCreeps >= 2 and not J.CanKillTarget(targetCreep,nDamage *3,nDamageType))
					or ( #nCreeps >= 1 and not J.CanKillTarget(targetCreep,nDamage *6,nDamageType))
				then
					return BOT_ACTION_DESIRE_HIGH, targetCreep;
				end
			end
			
			if bot:GetMana() >= 100
				and GetUnitToUnitDistance(targetCreep,bot) >= 550
			then
				return BOT_ACTION_DESIRE_HIGH, targetCreep;
			end
			
	    end
		
	end
	
	--推进时对小兵用
	if  (J.IsPushing(bot) or J.IsDefending(bot) or J.IsFarming(bot))
		and nLV >= 8
		and #nEnemysHerosInView == 0
		and #nAllies <= 2
	then
		local nLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange +160,true);
		if  ( #nLaneCreeps >= 3 and J.IsAllowedToSpam(bot, nManaCost))
			or ( J.IsValid(nLaneCreeps[1]) 
				 and GetUnitToUnitDistance(nLaneCreeps[1],bot) >= 650
				 and bot:GetMana() >= 100 )
		then
			if J.IsValid(nLaneCreeps[1])
				and not J.IsEnemyHeroAroundLocation(nLaneCreeps[1]:GetLocation(), 800)
			then
				for _,creep in pairs(nLaneCreeps)
				do
					if J.IsValid(creep)
						and not creep:HasModifier("modifier_fountain_glyph")
					then
						return BOT_ACTION_DESIRE_HIGH, creep;
					end
				end
			end
		end
	end
	
	--打肉的时候输出
	if  bot:GetActiveMode() == BOT_MODE_ROSHAN 
	then
		local npcTarget = bot:GetAttackTarget();
		if  J.IsRoshan(npcTarget) 
		    and J.GetHPR(npcTarget) > 0.15
			and J.IsInRange(npcTarget, bot, nCastRange)  
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	return 0;
	
end

function X.ConsiderE()

	local nEnemyTowers = bot:GetNearbyTowers(878,true);
	
	if  not abilityE:IsFullyCastable() 
	    or bot:IsInvisible() 
		or #nEnemyTowers >= 1 
		or bot:DistanceFromFountain() < 600
	then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- 撤退逃跑
	if J.IsRetreating(bot) 
		and bot:WasRecentlyDamagedByAnyHero(3.1)
		and ( nLV >= 6 or nHP <= 0.3 )
	then
		local nEnemysHerosInRange = bot:GetNearbyHeroes(740,true,BOT_MODE_NONE);
		if #nEnemysHerosInRange == 0
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	-- 过河道接近敌方基地
	if J.IsInEnemyArea(bot) and nLV >= 7
	then
		local nEnemies = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
		local nAllies  = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
		local nEnemyTowers = bot:GetNearbyTowers(1600,true);
		if #nEnemies == 0 and #nAllies <= 2 and nEnemyTowers == 0
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	--低血量打远古
	if J.IsFarming(bot)
	then
		local nTarget = J.GetProperTarget(bot);
		if  J.IsValid(nTarget)
		    and ( nTarget:IsAncientCreep() or nHP < 0.28 )
			and nHP <= 0.58 
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	return 0;
	
end

return X
-- dota2jmz@163.com QQ:2462331592
