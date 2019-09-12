-----------------
--英雄：巫妖
--技能：寒霜爆发
--键位：Q
--类型：指向目标
--作者：决明子
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('lich_frost_nova')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;

nKeepMana = 400 --魔法储量
nLV = bot:GetLevel(); --当前英雄等级
nMP = bot:GetMana()/bot:GetMaxMana(); --目前法力值/最大法力值（魔法剩余比）
nHP = bot:GetHealth()/bot:GetMaxHealth();--目前生命值/最大生命值（生命剩余比）
hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内敌人
hAlleyHeroList = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);--1600范围内队友

--获取以太棱镜施法距离加成
local aether = J.IsItemAvailable("item_aether_lens");
if aether ~= nil then aetherRange = 250 else aetherRange = 0 end
    
--初始化函数库
U.init(nLV, nMP, nHP, bot);

--技能释放功能
function X.Release(castTarget)
    if castTarget ~= nil then
        X.Compensation()
        bot:ActionQueue_UseAbilityOnEntity( ability, castTarget ) --使用技能
    end
end

--补偿功能
function X.Compensation()
    J.SetQueuePtToINT(bot, true)--临时补充魔法，使用魂戒
end

--技能释放欲望
function X.Consider()

	-- 确保技能可以使用
    if ability == nil
	   or ability:IsNull()
       or not ability:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end
	
	local nSkillLV    = ability:GetLevel(); 
	local nCastRange  = ability:GetCastRange() + aetherRange
	local nRealRange  = nCastRange
	
	if #hEnemyList <= 2 and nCastRange < 700 then nCastRange = nCastRange + 100 end
	
	local nCastPoint  = ability:GetCastPoint()
	local nManaCost   = ability:GetManaCost()
	local nMainDamage = nSkillLV * 50
	local nAoeDamage  = ability:GetSpecialValueInt("aoe_damage")
	local nDamage     = nMainDamage + nAoeDamage
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nRadius = ability:GetSpecialValueInt("radius")
	
		
	local nInRangeEnemyList = bot:GetNearbyHeroes(nCastRange + 32, true, BOT_MODE_NONE);
	local nInBonusEnemyList = bot:GetNearbyHeroes(nCastRange + 150,true,BOT_MODE_NONE);
	local nEmemysCreepsInRange = bot:GetNearbyCreeps(nCastRange + 43,true);
	
	
	--击杀 
	for _,npcEnemy in pairs( nInBonusEnemyList )
	do
		if J.IsValid(npcEnemy)
		   and J.CanCastOnNonMagicImmune(npcEnemy)
		   and J.CanCastOnTargetAdvanced(npcEnemy)
		   and J.WillMagicKillTarget(bot,npcEnemy,nDamage,nCastPoint)
		then
			if J.WillMagicKillTarget(bot,npcEnemy,nAoeDamage,nCastPoint)
			then
				local nBetterTarget = nil;
				local nAllEnemyUnits = J.CombineTwoTable(nInRangeEnemyList,nEmemysCreepsInRange);
				for _,enemy in pairs(nAllEnemyUnits)
				do
					if J.IsValid(enemy)
						and J.IsInRange(npcEnemy,enemy,nRadius)
						and J.CanCastOnNonMagicImmune(enemy)
						and J.CanCastOnTargetAdvanced(enemy)
					then
						nBetterTarget = enemy;
						break;
					end
				end
				
				if nBetterTarget ~= nil
				then
					return BOT_ACTION_DESIRE_HIGH,nBetterTarget;
				end				
			end
			
			return BOT_ACTION_DESIRE_HIGH,npcEnemy;
		end
	end
	
	--团战
	if J.IsInTeamFight(bot, 1200)
	then
		local npcMostAoeEnemy = nil;
		local nMostAoeECount  = 1;		
		local nAllEnemyUnits = J.CombineTwoTable(nInRangeEnemyList,nEmemysCreepsInRange);
		
		local nWeakestEnemy = nil;
		local nWeakestEnemyHealth = 9999;		
		
		for _,npcEnemy in pairs( nAllEnemyUnits )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and J.CanCastOnTargetAdvanced(npcEnemy)
			then
				
				local nEnemyHeroCount = J.GetAroundTargetEnemyHeroCount(npcEnemy, nRadius);
				if ( nEnemyHeroCount > nMostAoeECount )
				then
					nMostAoeECount = nEnemyHeroCount;
					npcMostAoeEnemy = npcEnemy;
				end
				
				if npcEnemy:IsHero()
				then
					local npcEnemyHealth = npcEnemy:GetHealth();
					if ( npcEnemyHealth < nWeakestEnemyHealth )
					then
						nWeakestEnemyHealth = npcEnemyHealth;
						nWeakestEnemy = npcEnemy;
					end
				end
			end
		end
		
		if ( npcMostAoeEnemy ~= nil )
		then
			return BOT_ACTION_DESIRE_HIGH, npcMostAoeEnemy;
		end	

		if ( nWeakestEnemy ~= nil )
		then
			return BOT_ACTION_DESIRE_HIGH, nWeakestEnemy;
		end	
	end
	
	--对线
	if J.IsLaning(bot)
	then
	
		if nMP > 0.5
		then	
			for _,npcEnemy in pairs( nInRangeEnemyList )
			do
				if  J.IsValid(npcEnemy)
					and J.CanCastOnNonMagicImmune(npcEnemy) 
					and J.CanCastOnTargetAdvanced(npcEnemy)
					and J.GetAttackTargetEnemyCreepCount(npcEnemy, 1400) >= 3
				then
					return BOT_ACTION_DESIRE_HIGH, npcEnemy;
				end
			end	
		end
		
		local nEnemyCreeps = bot:GetNearbyLaneCreeps(800,true);
		for _,creep in pairs(nEnemyCreeps)
		do 
			if J.IsValid(creep)
				and not creep:HasModifier('modifier_fountain_glyph')
			then
				if J.IsKeyWordUnit('ranged',creep)
					and J.WillKillTarget(creep,nDamage,nDamageType,nCastPoint)
					and not J.IsAllysTarget(creep)
				then
					return BOT_ACTION_DESIRE_HIGH, creep, "Q-LaneRanged";
				end
				
				if  #hAllyList <= 1 and bot:GetMana() > 320
					and J.IsKeyWordUnit('melee',creep)
					and J.WillKillTarget(creep,nDamage,nDamageType,nCastPoint)
					and not J.WillKillTarget(creep,nDamage *0.5,nDamageType,nCastPoint)
				then
					return BOT_ACTION_DESIRE_HIGH, creep;
				end
			end
		end
		
		
	end
	
	--打架时先手	
	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidHero(botTarget) 
			and J.IsInRange(bot, botTarget, nCastRange +30)
			and J.CanCastOnNonMagicImmune(botTarget) 
			and J.CanCastOnTargetAdvanced(botTarget)
		then
			if nSkillLV >= 2 or nMP > 0.68 or J.GetHPR(botTarget) < 0.48 or nHP < 0.28
			then
				return BOT_ACTION_DESIRE_HIGH, botTarget;
			end
		end
	end
	
	
	--撤退时保护自己
	if J.IsRetreating(bot) 
	then
		for _,npcEnemy in pairs( nInRangeEnemyList )
		do
			if J.IsValidHero(npcEnemy)
				and J.IsInRange(bot,npcEnemy,nRealRange)
			    and ( bot:WasRecentlyDamagedByHero( npcEnemy, 4.0 ) or nMP > 0.68
						or GetUnitToUnitDistance(bot,npcEnemy) <= 400 )
				and J.CanCastOnNonMagicImmune(npcEnemy) 
				and J.CanCastOnTargetAdvanced(npcEnemy)
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	--打钱
	if J.IsFarming(bot) and nSkillLV >= 3
	   and J.IsAllowedToSpam(bot,nManaCost)
	   and #hEnemyList == 0
	   and #hAllyList <= 2
	   and not ( J.IsPushing(bot) or J.IsDefending(bot) )
	then
		local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nCastRange + 100);
		if #nNeutralCreeps >= 3
		then
			for _,creep in pairs(nNeutralCreeps)
			do
				if J.IsValid(creep)
					and bot:IsFacingLocation(creep:GetLocation(),30)
					and creep:GetHealth() >= 600
					and creep:GetMagicResist() < 0.3
					and J.GetAroundTargetEnemyUnitCount(creep, nRadius) >= 3
				then
					return BOT_ACTION_DESIRE_HIGH, creep;
				end			
			end
		end
	end
	
	
	--推进
	if  (J.IsPushing(bot) or J.IsDefending(bot) or J.IsFarming(bot))
	    and J.IsAllowedToSpam(bot,30)
		and nSkillLV >= 3 
		and #hEnemyList == 0
		and #hAllyList <= 2
	then
		local nEnemyCreeps = bot:GetNearbyLaneCreeps(999,true);
		local nAllyCreeps = bot:GetNearbyLaneCreeps(888,false);
		
		for _,creep in pairs(nEnemyCreeps)
		do
			if J.IsValid(creep)
				and not creep:HasModifier("modifier_fountain_glyph")
				and J.IsInRange(creep,bot,nCastRange + 300)
			then
			
				if #nAllyCreeps == 0
					and J.GetAroundTargetEnemyUnitCount(creep, nRadius) >= 4
				then
					return BOT_ACTION_DESIRE_HIGH, creep;
				end
			
				if J.IsKeyWordUnit('ranged',creep)
					and J.WillKillTarget(creep,nDamage,nDamageType,nCastPoint)
				then
					return BOT_ACTION_DESIRE_HIGH, creep;
				end
				
				if J.IsKeyWordUnit('melee',creep)
					and J.WillKillTarget(creep,nDamage,nDamageType,nCastPoint)
					and ( J.GetAroundTargetEnemyUnitCount(creep, nRadius) >= 2 or nMP > 0.8 )
				then
					return BOT_ACTION_DESIRE_HIGH, creep;
				end
				
			end			
		end
		
	end
	
	--打肉的时候输出
	if  bot:GetActiveMode() == BOT_MODE_ROSHAN 
		and bot:GetMana() >= 600
	then
		if J.IsRoshan(botTarget) and J.GetHPR(botTarget) > 0.2
			and J.IsInRange(bot, botTarget, nRealRange)  
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget;
		end
	end
	
	--通用受到伤害时保护自己
	if bot:WasRecentlyDamagedByAnyHero(3.0) 
		and bot:GetActiveMode() ~= BOT_MODE_RETREAT
		and #nInRangeEnemyList >= 1
		and nSkillLV >= 4
	then
		for _,npcEnemy in pairs( nInRangeEnemyList )
		do
			if  J.IsValidHero(npcEnemy)
				and J.IsInRange(bot,npcEnemy,nRealRange)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and J.CanCastOnTargetAdvanced(npcEnemy)		
				and bot:IsFacingLocation(npcEnemy:GetLocation(),45)
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end
	
	--通用消耗敌人
	if (#hEnemyList > 0 or bot:WasRecentlyDamagedByAnyHero(3.0)) 
		and ( bot:GetActiveMode() ~= BOT_MODE_RETREAT or #hAllyList >= 2 )
		and #nInRangeEnemyList >= 1
		and nSkillLV >= 4 and bot:GetMana() > nKeepMana
	then
		for _,npcEnemy in pairs( nInRangeEnemyList )
		do
			if  J.IsValidHero(npcEnemy)
				and J.IsInRange(bot,npcEnemy,nRealRange)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and J.CanCastOnTargetAdvanced(npcEnemy)		
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X;