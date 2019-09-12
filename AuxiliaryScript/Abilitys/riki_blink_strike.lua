-----------------
--英雄：力丸
--技能：闪烁突袭
--键位：W
--类型：指向单位
--作者：Halcyon
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('riki_blink_strike')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList;

nKeepMana = 300 --魔法储量
nLV = bot:GetLevel(); --当前英雄等级
nMP = bot:GetMana()/bot:GetMaxMana(); --目前法力值/最大法力值（魔法剩余比）
nHP = bot:GetHealth()/bot:GetMaxHealth();--目前生命值/最大生命值（生命剩余比）
hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内敌人
hAlleyHeroList = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);--1600范围内队友

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

    -- Get some of its values
	local nAttackDamage = bot:GetAttackDamage();
	local nCastRange  = ability:GetCastRange();
	local nCastPoint  = ability:GetCastPoint();
	local nManaCost   = ability:GetManaCost();
	local nSkillLV    = ability:GetLevel(); 
	local nBonus      = 24;
	local nDamage     = nAttackDamage + ability:GetSpecialValueInt("bonus_damage");
	local nDamageType = DAMAGE_TYPE_MAGICAL;
	
	local nAllies =  bot:GetNearbyHeroes(1200,false,BOT_MODE_NONE);

	if nCastRange > 1300 then
		nCastRange = 1300 
	end
	
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

return X;