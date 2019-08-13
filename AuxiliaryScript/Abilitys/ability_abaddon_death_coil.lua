local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('abaddon_death_coil')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList;

nKeepMana = 200 --魔法储量
nLV = bot:GetLevel(); --当前英雄等级
nMP = bot:GetMana()/bot:GetMaxMana(); --目前法力值/最大法力值（魔法剩余比）
nHP = bot:GetHealth()/bot:GetMaxHealth();--目前生命值/最大生命值（生命剩余比）
hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内敌人
hAlleyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内队友

--初始化函数库
U.init(nLV, nMP, nHP, bot);

--技能释放功能
function X.Release(castTarget,compensation)
	if compensation then X.Compensation() end
	bot:ActionQueue_UseAbilityOnEntity( ability, castTarget ) --使用技能
	return;
end

--补偿功能
function X.Compensation()
    J.SetQueuePtToINT(bot, true)--临时补充魔法，使用魂戒
end

--技能释放欲望
function X.Consider()
	-- 确保技能可以使用
	if not ability:IsFullyCastable()
		or bot:IsRooted()
		or U.ShouldSaveMana(ability) --是否应当节省魔法不去使用技能
	then 
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end

	-- 获取一些必要参数
	local nCastRange  = ability:GetCastRange();	--施法范围
	local nCastPoint  = ability:GetCastPoint();	--施法点
	local nManaCost   = ability:GetManaCost();		--魔法消耗
	local nSkillLV    = ability:GetLevel();    	--技能等级 
	local nDamageOwn  = 25 * ( nSkillLV - 1) + 50;	--技能自身伤害                        
	local nDamage     = 45 * ( nSkillLV - 1) + 75;	--技能伤害
	local nDamageType = DAMAGE_TYPE_MAGICAL;		--伤害类型
	
	local nAlleys =  bot:GetNearbyHeroes(1200,false,BOT_MODE_NONE); --获取1200范围内盟友
	
	local nEnemysHerosInView  = bot:GetNearbyHeroes(1200,true,BOT_MODE_NONE); --获取1200范围内敌人
	
	if #nEnemysHerosInView == 1 --如果敌人只有一个
	   and J.IsValidHero(nEnemysHerosInView[1]) --是英雄
	   and J.IsInRange(nEnemysHerosInView[1],bot,nCastRange + 50) --在施法范围+50内
	   and nEnemysHerosInView[1]:IsFacingLocation(bot:GetLocation(),30) --单位面向目标30°范围内
	   and nEnemysHerosInView[1]:GetAttackRange() > nCastRange --单位的攻击范围在施法范围外
	   and nEnemysHerosInView[1]:GetAttackRange() < 1250 --且小于1250
	then
		nCastRange = nCastRange + 200; --使得施法欲望范围增加200
	end
	
	local nEnemysHerosInRange = bot:GetNearbyHeroes(nCastRange ,true,BOT_MODE_NONE); --获得施法范围内敌人
	local nEnemysHerosInBonus = bot:GetNearbyHeroes(nCastRange + 150,true,BOT_MODE_NONE);--获得施法范围+150内敌人
	
	--击杀
	for _,npcEnemy in pairs( nEnemysHerosInBonus )
	do
		if J.IsValid(npcEnemy)
		   and J.CanCastOnNonMagicImmune(npcEnemy)
		then
			
			if  GetUnitToUnitDistance(bot,npcEnemy) <= nCastRange + 50 --如果在技能范围+50内且有把握击杀
				and J.CanKillTarget(npcEnemy,nDamage,nDamageType)
				and (bot:GetHealth() - nDamageOwn)/bot:GetMaxHealth() >= 0.3
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy; --追杀
			end

			if  GetUnitToUnitDistance(bot,npcEnemy) <= nCastRange --如果在技能范围内且有把握击杀
				and J.CanKillTarget(npcEnemy,nDamage,nDamageType)
			then
				return BOT_ACTION_DESIRE_VERYHIGH, npcEnemy; --直接杀死
			end
			
		end
	end
	
	--团战中对战力最高的敌人使用
	if J.IsInTeamFight(bot, 1200)
	then
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;		
		
		for _,npcEnemy in pairs( nEnemysHerosInRange )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and not J.IsDisabled(true, npcEnemy)
				and not npcEnemy:IsDisarmed()
			then
				local npcEnemyDamage = npcEnemy:GetEstimatedDamageToTarget( false, bot, 3.0, DAMAGE_TYPE_PHYSICAL );
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
	
	--对线期间对敌方英雄使用
	if bot:GetActiveMode() == BOT_MODE_LANING
	then
		for _,npcEnemy in pairs( nEnemysHerosInBonus )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and not J.IsDisabled(true, npcEnemy)
				and J.GetAttackTargetEnemyCreepCount(npcEnemy, 600) >= 4
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end	
	end
	
	--对线期间对自己使用
	if bot:GetActiveMode() == BOT_MODE_LANING
		and J.IsValid(bot)
		and J.CanCastOnNonMagicImmune(bot) 
	then
		if  nHP <= 0.2
		then
			return BOT_ACTION_DESIRE_HIGH, bot;
		elseif nHP <= 0.6
		then
			return BOT_ACTION_DESIRE_MODERATE, bot;
		end
	end
	
	--打架时先手	
	if J.IsGoingOnSomeone(bot)
	then
	    local npcTarget = J.GetProperTarget(bot);
		if J.IsValidHero(npcTarget) 
			and J.CanCastOnNonMagicImmune(npcTarget) 
			and J.IsInRange(npcTarget, bot, nCastRange +80) 
			and not J.IsDisabled(true, npcTarget)
			and not npcTarget:IsDisarmed()
		then
			if nSkillLV >= 3 or nMP > 0.68 or J.GetHPR(npcTarget) < 0.38 or nHP < 0.25
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	
	--撤退时战术输出和撑血 抬手太长
	--if J.IsRetreating(bot) 
	--	and not bot:IsInvisible()
	--then
	--	for _,npcEnemy in pairs( nEnemysHerosInRange )
	--	do
	--		if J.IsValid(npcEnemy)
	--			and nHP < 0.3
	--			and GetUnitToUnitDistance(bot,npcEnemy) >= 100
	--		then
	--			return BOT_ACTION_DESIRE_HIGH, bot;
	--		end

	--		if J.IsValid(npcEnemy)
	--		    and ( bot:WasRecentlyDamagedByHero( npcEnemy, 5.0 ) 
	--					or nMP > 0.8
	--					or GetUnitToUnitDistance(bot,npcEnemy) <= 400 )
	--			and J.CanCastOnNonMagicImmune(npcEnemy) 
	--			and not J.IsDisabled(true, npcEnemy) 
	--			and not npcEnemy:IsDisarmed()
	--		then
	--			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
	--		end
	--	end
	--end
	
	if  J.IsFarming(bot) 
		and nSkillLV >= 3
		and (bot:GetAttackDamage() < 200 or nMP > 0.88)
		and nMP > 0.71
	then
		local nCreeps = bot:GetNearbyNeutralCreeps(nCastRange +100);
		
		local targetCreep = J.GetMostHpUnit(nCreeps);
		
		if J.IsValid(targetCreep)
			and ( #nCreeps >= 2 or GetUnitToUnitDistance(targetCreep,bot) <= 400 )
			and not J.IsRoshan(targetCreep)
			and not J.IsOtherAllysTarget(targetCreep)
			and targetCreep:GetMagicResist() < 0.3
			and not J.CanKillTarget(targetCreep,bot:GetAttackDamage() *1.68,DAMAGE_TYPE_PHYSICAL)
			and not J.CanKillTarget(targetCreep,nDamage,nDamageType)
		then
			return BOT_ACTION_DESIRE_HIGH, targetCreep;
	    end
	end
	
	--受到伤害时保护自己
	if bot:WasRecentlyDamagedByAnyHero(3.0) 
		and bot:GetActiveMode() ~= BOT_MODE_RETREAT
		and not bot:IsInvisible()
		and #nEnemysHerosInRange >= 1
		and nLV >= 6
	then
		for _,npcEnemy in pairs( nEnemysHerosInRange )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and not J.IsDisabled(true, npcEnemy)
                and not npcEnemy:IsDisarmed()				
				and bot:IsFacingLocation(npcEnemy:GetLocation(),45)
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end
	
	--通用消耗敌人或受到伤害时保护自己
	if (#nEnemysHerosInView > 0 or bot:WasRecentlyDamagedByAnyHero(3.0)) 
		and ( bot:GetActiveMode() ~= BOT_MODE_RETREAT or #nAlleys >= 2 )
		and #nEnemysHerosInRange >= 1
		and nLV >= 7
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

return X;