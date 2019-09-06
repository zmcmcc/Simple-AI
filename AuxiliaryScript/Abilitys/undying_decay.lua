-----------------
--英雄：不朽尸王
--技能：腐朽
--键位：Q
--类型：指向地点
--作者：Halcyon
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('undying_decay')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;

nKeepMana = 240 --魔法储量
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
        bot:ActionQueue_UseAbilityOnLocation( ability, castTarget ) --使用技能
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
	local nRadius    = ability:GetSpecialValueInt('radius');  
	local nCastRange = ability:GetCastRange() + aetherRange;					
	local nCastPoint = ability:GetCastPoint();			    
	local nManaCost  = ability:GetManaCost();					
	local nDamage    = ability:GetSpecialValueInt("decay_damage");
	local nSkillLV   = ability:GetLevel();                             	
	
	local nEnemysHeroesInRange = bot:GetNearbyHeroes(nCastRange + nRadius,true,BOT_MODE_NONE);
	local nEnemysHeroesInBonus = bot:GetNearbyHeroes(nCastRange + nRadius + 80,true,BOT_MODE_NONE);
	local nEnemysHeroesInView = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	local nWeakestEnemyHeroInRange,nWeakestEnemyHeroInRangeHealth = sil_GetWeakestUnit(nEnemysHeroesInRange);
	local nWeakestEnemyHeroInBonus,nWeakestEnemyHeroInBonusHealth = sil_GetWeakestUnit(nEnemysHeroesInBonus);
	
	local nEnemysLaneCreepsInRange = bot:GetNearbyLaneCreeps(nCastRange + nRadius,true)
	local nEnemysLaneCreepsInBonus = bot:GetNearbyLaneCreeps(nCastRange + nRadius + 80,true)
	local nEnemysWeakestLaneCreepsInRange,nEnemysWeakestLaneCreepsInRangeHealth = sil_GetWeakestUnit(nEnemysLaneCreepsInRange);
	local nEnemysWeakestLaneCreepsInBonus,nEnemysWeakestLaneCreepsInBonusHealth = sil_GetWeakestUnit(nEnemysLaneCreepsInBonus);
	
	local nTowers = bot:GetNearbyTowers(1000,true)
	
	local nCanKillHeroLocationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius , 0, 0.7*nDamage);
	local nCanHurtHeroLocationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius , 0, 0);
	local nCanKillCreepsLocationAoE = bot:FindAoELocation( true, false, bot:GetLocation(),nCastRange, nRadius, 0, nDamage);
	local nCanHurtCreepsLocationAoE = bot:FindAoELocation( true, false, bot:GetLocation(),nCastRange, nRadius, 0, 0);
	
	
	if nCanHurtCreepsLocationAoE == nil
       or J.GetInLocLaneCreepCount(bot, 1600, nRadius, nCanHurtCreepsLocationAoE.targetloc) <= 2        
	then
	     nCanHurtCreepsLocationAoE.count = 0
	end
	
	
	if nCanKillHeroLocationAoE.count ~= nil
	   and nCanKillHeroLocationAoE.count >= 1
	then
		if J.IsValidHero(nWeakestEnemyHeroInBonus)
		   and J.CanCastOnNonMagicImmune(nWeakestEnemyHeroInBonus)
		then
		    local nTargetLocation = J.GetCastLocation(bot,nWeakestEnemyHeroInBonus,nCastRange,nRadius);
			if nTargetLocation ~= nil
			then
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation;
			end
		end
	end
	    
	
	if bot:GetActiveMode() == BOT_MODE_LANING 
		and nHP >= 0.4
	then
		if nCanHurtHeroLocationAoE.count >= 2
		   and J.IsValidHero(nWeakestEnemyHeroInBonus)
		then 
			return BOT_ACTION_DESIRE_HIGH, nCanHurtHeroLocationAoE.targetloc;
		end
	end

	
	if bot:GetActiveMode() == BOT_MODE_RETREAT 
	then
		local nCanHurtHeroLocationAoENearby = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange - 300, nRadius, 0.8, 0);
		if nCanHurtHeroLocationAoENearby.count >= 1 
		   and J.IsValidHero(nWeakestEnemyHeroInBonus)
		then
			return BOT_ACTION_DESIRE_HIGH, nCanHurtHeroLocationAoENearby.targetloc;
		end
	end
	
	
	if J.IsGoingOnSomeone(bot)
	then
			
		if nCanHurtHeroLocationAoE.count >= 2 
		    and GetUnitToLocationDistance(bot,nCanHurtHeroLocationAoE.targetloc) <= nCastRange
			and J.IsValidHero(nWeakestEnemyHeroInBonus)
		then
			return BOT_ACTION_DESIRE_HIGH, nCanHurtHeroLocationAoE.targetloc;
		end
		
		local npcEnemy = J.GetProperTarget(bot);
		if  J.IsValidHero(npcEnemy)
			and J.CanCastOnNonMagicImmune(npcEnemy)
		then
			
			if nMP > 0.8 
			   or bot:GetMana() > nKeepMana * 2
			then
				local nTargetLocation = J.GetCastLocation(bot,npcEnemy,nCastRange,nRadius);
				if nTargetLocation ~= nil
				then
					return BOT_ACTION_DESIRE_HIGH, nTargetLocation;
				end
			end
			
			if (npcEnemy:GetHealth()/npcEnemy:GetMaxHealth() < 0.4)
               and GetUnitToUnitDistance(npcEnemy,bot) <= nRadius + nCastRange
		    then
			    local nTargetLocation = J.GetCastLocation(bot,npcEnemy,nCastRange,nRadius);
				if nTargetLocation ~= nil
				then
					return BOT_ACTION_DESIRE_HIGH, nTargetLocation;
				end			   
			end
			
		end	
		
		npcEnemy = nWeakestEnemyHeroInRange;
		if  npcEnemy ~= nil and npcEnemy:IsAlive()
			and (npcEnemy:GetHealth()/npcEnemy:GetMaxHealth() < 0.4)
			and GetUnitToUnitDistance(npcEnemy,bot) <= nRadius + nCastRange
		then
			local nTargetLocation = J.GetCastLocation(bot,npcEnemy,nCastRange,nRadius);
			if nTargetLocation ~= nil
			then
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation;
			end			   
		end 
		
		if nCanHurtCreepsLocationAoE.count >= 5 
			and nEnemysWeakestLaneCreepsInBonus ~= nil
			and #nEnemysHeroesInBonus <= 0
			and bot:GetActiveMode() ~= BOT_MODE_ATTACK
			and nSkillLV >= 3
			and DotaTime() >= 10 * 60
		then
		    return BOT_ACTION_DESIRE_HIGH, nCanHurtCreepsLocationAoE.targetloc;
		end		
	
	    if nCanKillCreepsLocationAoE.count >= 3 
			and (nEnemysWeakestLaneCreepsInRange ~= nil or nLV == 25)
			and #nEnemysHeroesInBonus <= 0
			and bot:GetActiveMode() ~= BOT_MODE_ATTACK
			and nSkillLV >= 3
			and DotaTime() >= 10 * 60
		then
		    return BOT_ACTION_DESIRE_HIGH, nCanKillCreepsLocationAoE.targetloc;
		end		
	end
	
	
	if bot:GetActiveMode() ~= BOT_MODE_RETREAT 
	then
		if  J.IsValidHero(nWeakestEnemyHeroInBonus)
		then
		
		    if nCanHurtHeroLocationAoE.count >= 3
			   and GetUnitToLocationDistance(bot,nCanHurtHeroLocationAoE.targetloc) <= nCastRange
			then
			    return BOT_ACTION_DESIRE_VERYHIGH, nCanHurtHeroLocationAoE.targetloc;
			end
			
			if nCanHurtHeroLocationAoE.count >= 2 
			   and GetUnitToLocationDistance(bot,nCanHurtHeroLocationAoE.targetloc) <= nCastRange
			   and bot:GetMana() > nKeepMana
			then
			    return BOT_ACTION_DESIRE_HIGH, nCanHurtHeroLocationAoE.targetloc;
			end
			
			if  J.IsValidHero(nWeakestEnemyHeroInBonus) 
			then
				if nMP > 0.8 
				   or bot:GetMana() > nKeepMana * 2
				then
					local nTargetLocation = J.GetCastLocation(bot,nWeakestEnemyHeroInBonus,nCastRange,nRadius);
					if nTargetLocation ~= nil
					then
						return BOT_ACTION_DESIRE_HIGH, nTargetLocation;
					end
				end
				
				if (nWeakestEnemyHeroInBonus:GetHealth()/nWeakestEnemyHeroInBonus:GetMaxHealth() <= 0.4)
				   and GetUnitToUnitDistance(nWeakestEnemyHeroInBonus,bot) <= nRadius + nCastRange
				then
					local nTargetLocation = J.GetCastLocation(bot,nWeakestEnemyHeroInBonus,nCastRange,nRadius);
					if nTargetLocation ~= nil
					then
						return BOT_ACTION_DESIRE_HIGH, nTargetLocation;
					end			   
				end
			end
		end
	end
	
     
	if  bot:GetActiveMode() == BOT_MODE_FARM
		and nSkillLV >= 3
	then
	
		if nCanKillCreepsLocationAoE.count >= 3 
			and nEnemysWeakestLaneCreepsInRange ~= nil
		then
		    return BOT_ACTION_DESIRE_HIGH, nCanKillCreepsLocationAoE.targetloc;
		end
		
		if nCanHurtCreepsLocationAoE.count >= 5 
			and nEnemysWeakestLaneCreepsInRange ~= nil
		then
		    return BOT_ACTION_DESIRE_HIGH, nCanHurtCreepsLocationAoE.targetloc;
		end
		
	end
	
	
	if (bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP or
		 bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID or
		 bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT or
		 bot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP or
		 bot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID or
		 bot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT ) 
		 and nSkillLV >= 3
		 and DotaTime() >= 10*60
	then
	
		if nCanHurtCreepsLocationAoE.count >= 5 
			and nEnemysWeakestLaneCreepsInRange ~= nil
		then
		    return BOT_ACTION_DESIRE_HIGH, nCanHurtCreepsLocationAoE.targetloc;
		end		
	
	    if nCanKillCreepsLocationAoE.count >= 3 
			and nEnemysWeakestLaneCreepsInRange ~= nil
		then
		    return BOT_ACTION_DESIRE_HIGH, nCanKillCreepsLocationAoE.targetloc;
		end
	end
	
	
	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	   and bot:GetMana() >= 600
	then
		local npcTarget = bot:GetAttackTarget();
		if  J.IsRoshan(npcTarget) 
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation();
		end
	end
		
	
	if  #nEnemysHeroesInView == 0 
		and DotaTime() > 9*60
		and bot:GetActiveMode() ~= BOT_MODE_ATTACK
		and nSkillLV > 2
	then
		
		if nCanKillCreepsLocationAoE.count >= 3 
			and (nEnemysWeakestLaneCreepsInBonus ~= nil or nLV >= 20)
		then
		    return BOT_ACTION_DESIRE_HIGH, nCanKillCreepsLocationAoE.targetloc;
		end		
		
		if nCanHurtCreepsLocationAoE.count >= 5
		   and nEnemysWeakestLaneCreepsInBonus ~= nil
		then
			return BOT_ACTION_DESIRE_HIGH, nCanHurtCreepsLocationAoE.targetloc;
		end
		
	end
    
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

function sil_GetWeakestUnit( nEnemyUnits )
	
	local nWeakestUnit = nil;
	local nWeakestUnitLowestHealth = 10000;
	for _,unit in pairs(nEnemyUnits)
	do
		if 	unit:IsAlive() 
			and J.CanCastOnNonMagicImmune(unit)
			and J.CanCastOnTargetAdvanced(unit)
		then
			if unit:GetHealth() < nWeakestUnitLowestHealth
			then
				nWeakestUnitLowestHealth = unit:GetHealth();
				nWeakestUnit = unit;
			end
		end
	end

	return nWeakestUnit,nWeakestUnitLowestHealth;	
end

return X;