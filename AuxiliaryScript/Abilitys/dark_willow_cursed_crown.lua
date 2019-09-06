-----------------
--英雄：邪影芳灵
--技能：诅咒王冠
--键位：E
--类型：指向单位
--作者：Halcyon
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('dark_willow_cursed_crown')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList;

nKeepMana = 400 --魔法储量
nLV = bot:GetLevel(); --当前英雄等级
nMP = bot:GetMana()/bot:GetMaxMana(); --目前法力值/最大法力值（魔法剩余比）
nHP = bot:GetHealth()/bot:GetMaxHealth();--目前生命值/最大生命值（生命剩余比）
hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内敌人
hAlleyHeroList = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);--1600范围内队友

--初始化函数库
U.init(nLV, nMP, nHP, bot);

--技能释放功能
function X.Release(castTarget)
    local abilityR = bot:GetAbilityByName('tidehunter_ravage') 
    if castTarget ~= nil
       and (abilityR == nil or U.ManaR(abilityR ,ability:GetManaCost()))
    then
        X.Compensation()
        bot:ActionQueue_UseAbilityOnEntity( ability, castTarget )
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

    -- Get some of its values
	local nCastRange  = ability:GetCastRange();
	local nCastPoint  = ability:GetCastPoint();
	local nManaCost   = ability:GetManaCost();
	local nSkillLV    = ability:GetLevel();                             
	local nDamage     = 80 * nSkillLV;
	local nRadius     = 255;
	local nDamageType = DAMAGE_TYPE_MAGICAL;
	
	local nAllies =  bot:GetNearbyHeroes(1200,false,BOT_MODE_NONE);
	
	if #hEnemyHeroList == 1 
	   and J.IsValidHero(hEnemyHeroList[1])
	   and J.IsInRange(hEnemyHeroList[1],bot,nCastRange + 350)
	   and hEnemyHeroList[1]:IsFacingLocation(bot:GetLocation(),30)
	   and hEnemyHeroList[1]:GetAttackRange() > nCastRange
	   and hEnemyHeroList[1]:GetAttackRange() < 1250
	then
		nCastRange = nCastRange + 260;
	end
	
	local nEnemysHerosInRange = bot:GetNearbyHeroes(nCastRange + 43,true,BOT_MODE_NONE);
	local nEnemysHerosInBonus = bot:GetNearbyHeroes(nCastRange + 350,true,BOT_MODE_NONE);
		
	local nEmemysCreepsInRange = bot:GetNearbyCreeps(nCastRange + 43,true);
	
	--打断和击杀 
	for _,npcEnemy in pairs( nEnemysHerosInBonus )
	do
		if J.IsValid(npcEnemy)
		   and J.CanCastOnNonMagicImmune(npcEnemy)
		   and J.CanCastOnTargetAdvanced(npcEnemy)
		   and not J.IsDisabled(true,npcEnemy)
		then
			if npcEnemy:IsChanneling()
				or J.CanKillTarget(npcEnemy,nDamage,nDamageType)
			then
			
				--隔空打断击杀目标
				local nBetterTarget = nil;
				local nAllEnemyUnits = J.CombineTwoTable(nEnemysHerosInRange,nEmemysCreepsInRange);
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
				   and not J.IsInRange(npcEnemy,bot,nCastRange) 
				then
					J.SetReport("打断或击杀Better:",nBetterTarget:GetUnitName());
					return BOT_ACTION_DESIRE_HIGH, nBetterTarget;
				else
					J.SetReport("打断或击杀目标:",npcEnemy:GetUnitName());
					return BOT_ACTION_DESIRE_HIGH, npcEnemy;
				end
			end			
		end
	end
	
	--团战中对作用数量最多或物理输出最强的敌人使用
	if J.IsInTeamFight(bot, 1200)
	then
		local npcMostAoeEnemy = nil;
		local nMostAoeECount  = 1;		
		local nAllEnemyUnits = J.CombineTwoTable(nEnemysHerosInRange,nEmemysCreepsInRange);
		
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;		
		
		for _,npcEnemy in pairs( nAllEnemyUnits )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and J.CanCastOnTargetAdvanced(npcEnemy)
				and not J.IsDisabled(true, npcEnemy)
				and not npcEnemy:IsDisarmed()
			then
				
				local nEnemyHeroCount = J.GetAroundTargetEnemyHeroCount(npcEnemy, nRadius);
				if ( nEnemyHeroCount > nMostAoeECount )
				then
					nMostAoeECount = nEnemyHeroCount;
					npcMostAoeEnemy = npcEnemy;
				end
				
				if npcEnemy:IsHero()
				then
					local npcEnemyDamage = npcEnemy:GetEstimatedDamageToTarget( false, bot, 3.0, DAMAGE_TYPE_PHYSICAL );
					if ( npcEnemyDamage > nMostDangerousDamage )
					then
						nMostDangerousDamage = npcEnemyDamage;
						npcMostDangerousEnemy = npcEnemy;
					end
				end
			end
		end
		
		if ( npcMostAoeEnemy ~= nil )
		then
			J.SetReport("团战控制数量多:",npcMostAoeEnemy:GetUnitName());
			return BOT_ACTION_DESIRE_HIGH, npcMostAoeEnemy;
		end	

		if ( npcMostDangerousEnemy ~= nil )
		then
--			J.SetReport("团战控制战力最强:",npcMostDangerousEnemy:GetUnitName());
			return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy;
		end	
	end
	
	--对线期间对敌方英雄使用
	if bot:GetActiveMode() == BOT_MODE_LANING or nLV <= 5
	then
		for _,npcEnemy in pairs( nEnemysHerosInRange )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and J.CanCastOnTargetAdvanced(npcEnemy)
				and not J.IsDisabled(true, npcEnemy)
				and J.GetAttackTargetEnemyCreepCount(npcEnemy, 1400) >= 5
			then
				J.SetReport("对线期间使用:",npcEnemy:GetUnitName());
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
			and J.IsInRange(npcTarget, bot, nCastRange +60) 
			and not J.IsDisabled(true, npcTarget)
			and not npcTarget:IsDisarmed()
		then
			if nSkillLV >= 3 or nMP > 0.88 or J.GetHPR(npcTarget) < 0.38 or nHP < 0.25
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	
	--撤退时保护自己
	if J.IsRetreating(bot) 
	then
		for _,npcEnemy in pairs( nEnemysHerosInRange )
		do
			if J.IsValid(npcEnemy)
			    and ( bot:WasRecentlyDamagedByHero( npcEnemy, 5.0 ) 
						or nMP > 0.8
						or GetUnitToUnitDistance(bot,npcEnemy) <= 400 )
				and J.CanCastOnNonMagicImmune(npcEnemy) 
				and J.CanCastOnTargetAdvanced(npcEnemy)
				and not J.IsDisabled(true, npcEnemy) 
				and not npcEnemy:IsDisarmed()
			then
				J.SetReport("撤退了保护自己:",npcEnemy:GetUnitName());
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	--发育时对野怪输出
	if J.IsFarming(bot) and nSkillLV >= 3
	   and (bot:GetAttackDamage() < 200 or nMP > 0.88)
	   and nMP > 0.78
	then
		local nNeutralCreeps = bot:GetNearbyNeutralCreeps(700);
		if #nNeutralCreeps >= 3
		then
			for _,creep in pairs(nNeutralCreeps)
			do
				if J.IsValid(creep)
					and creep:GetHealth() >= 900
					and creep:GetMagicResist() < 0.3
					and J.IsInRange(creep,bot,350)
					and J.GetAroundTargetEnemyUnitCount(creep, nRadius) >= 3
				then
					J.SetReport("打野时野怪数量:",#nNeutralCreeps);
					return BOT_ACTION_DESIRE_HIGH, creep;
				end			
			end
		end
	end
	
	
	--推进时对小兵用
	if  (J.IsPushing(bot) or J.IsDefending(bot) or J.IsFarming(bot))
	    and (bot:GetAttackDamage() < 200 or nMP > 0.9)
		and nSkillLV >= 4 and #hEnemyHeroList == 0 and nMP > 0.68
		and not J.IsInEnemyArea(bot)
	then
		local nLaneCreeps = bot:GetNearbyLaneCreeps(1000,true);
		if #nLaneCreeps >= 5
		then
			for _,creep in pairs(nLaneCreeps)
			do
				if J.IsValid(creep)
					and creep:GetHealth() >= 500
					and not creep:HasModifier("modifier_fountain_glyph")
					and J.IsInRange(creep,bot,nCastRange + 100)
					and J.GetAroundTargetEnemyUnitCount(creep, nRadius) >= 5
				then
					J.SetReport("推进时小兵数量:",#nLaneCreeps);
					return BOT_ACTION_DESIRE_HIGH, creep;
				end			
			end
		end
	end
	
	--打肉的时候输出
	if  bot:GetActiveMode() == BOT_MODE_ROSHAN 
		and bot:GetMana() >= 600
	then
		local npcTarget = bot:GetAttackTarget();
		if  J.IsRoshan(npcTarget) 
			and not J.IsDisabled(true, npcTarget)
			and not npcTarget:IsDisarmed()
			and J.IsInRange(npcTarget, bot, nCastRange)  
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	--通用受到伤害时保护自己
	if bot:WasRecentlyDamagedByAnyHero(3.0) 
		and bot:GetActiveMode() ~= BOT_MODE_RETREAT
		and #nEnemysHerosInRange >= 1
		and nLV >= 7
	then
		for _,npcEnemy in pairs( nEnemysHerosInRange )
		do
			if  J.IsValidHero(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and J.CanCastOnTargetAdvanced(npcEnemy)
				and not J.IsDisabled(true, npcEnemy)
                and not npcEnemy:IsDisarmed()				
				and bot:IsFacingLocation(npcEnemy:GetLocation(),45)
			then
				J.SetReport("保护我自己:",npcEnemy:GetUnitName());
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end
	
	--通用消耗敌人或保护自己
	if (#hEnemyHeroList > 0 or bot:WasRecentlyDamagedByAnyHero(3.0)) 
		and ( bot:GetActiveMode() ~= BOT_MODE_RETREAT or #nAllies >= 2 )
		and #nEnemysHerosInRange >= 1
		and nLV >= 7
	then
		for _,npcEnemy in pairs( nEnemysHerosInRange )
		do
			if  J.IsValidHero(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and J.CanCastOnTargetAdvanced(npcEnemy)
				and not J.IsDisabled(true, npcEnemy)			
			then
				J.SetReport("通用的情况:",npcEnemy:GetUnitName());
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end
	
	return 0;
end

return X;