-----------------
--英雄：水晶室女
--技能：冰霜新星
--键位：Q
--类型：指向地点
--作者：决明子
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('crystal_maiden_crystal_nova')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;
local sTalentList = J.Skill.GetTalentList(bot)

nKeepMana = 220 --魔法储量
nLV = bot:GetLevel(); --当前英雄等级
nMP = bot:GetMana()/bot:GetMaxMana(); --目前法力值/最大法力值（魔法剩余比）
nHP = bot:GetHealth()/bot:GetMaxHealth();--目前生命值/最大生命值（生命剩余比）
hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内敌人
hAlleyHeroList = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);--1600范围内队友

--获取以太棱镜施法距离加成
local aether = J.IsItemAvailable("item_aether_lens");
local talent2 = bot:GetAbilityByName( sTalentList[2] );
if aether ~= nil then aetherRange = 250 else aetherRange = 0 end
if talent2:IsTrained() and bot:GetUnitName() ~= 'npc_dota_hero_rubick' then aetherRange = aetherRange + talent2:GetSpecialValueInt('value') end

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
	local nCastRange = ability:GetCastRange() + aetherRange + 32;					
	local nCastPoint = ability:GetCastPoint( );			    
	local nManaCost  = ability:GetManaCost( );					
	local nDamage    = ability:GetSpecialValueInt('nova_damage');		
	local nSkillLV   = ability:GetLevel();                             
	
	local nAllys =  bot:GetNearbyHeroes(1200,false,BOT_MODE_NONE);
	
	local nEnemysHeroesInRange = bot:GetNearbyHeroes(nCastRange + nRadius,true,BOT_MODE_NONE);
	local nEnemysHeroesInBonus = bot:GetNearbyHeroes(nCastRange + nRadius + 150,true,BOT_MODE_NONE);
	local nEnemysHeroesInView = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	local nWeakestEnemyHeroInRange,nWeakestEnemyHeroHealth1 = X.cm_GetWeakestUnit(nEnemysHeroesInRange);
	local nWeakestEnemyHeroInBonus,nWeakestEnemyHeroHealth2 = X.cm_GetWeakestUnit(nEnemysHeroesInBonus);
	
	local nEnemysLaneCreeps1 = bot:GetNearbyLaneCreeps(nCastRange + nRadius,true)
	local nEnemysLaneCreeps2 = bot:GetNearbyLaneCreeps(nCastRange + nRadius + 200,true)
	local nEnemysWeakestLaneCreeps1,nEnemysWeakestLaneCreepsHealth1 = X.cm_GetWeakestUnit(nEnemysLaneCreeps1);
	local nEnemysWeakestLaneCreeps2,nEnemysWeakestLaneCreepsHealth2 = X.cm_GetWeakestUnit(nEnemysLaneCreeps2);
	
	local nTowers = bot:GetNearbyTowers(1000,true)
	
	local nCanKillHeroLocationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius , 0.8, nDamage);
	local nCanHurtHeroLocationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius , 0.8, 0);
	local nCanKillCreepsLocationAoE = bot:FindAoELocation( true, false, bot:GetLocation(),nCastRange + nRadius, nRadius, 0.5, nDamage);
	local nCanHurtCreepsLocationAoE = bot:FindAoELocation( true, false, bot:GetLocation(),nCastRange + nRadius, nRadius, 0.5, 0);
	
	if nCanHurtCreepsLocationAoE == nil
       or  J.GetInLocLaneCreepCount(bot, 1600, nRadius, nCanHurtCreepsLocationAoE.targetloc) <= 2        
	then
	    nCanHurtCreepsLocationAoE.count = 0
	end
	
	--击杀敌人
	if nCanKillHeroLocationAoE.count ~= nil
	   and nCanKillHeroLocationAoE.count >= 1
	then
		if J.IsValid(nWeakestEnemyHeroInBonus) 
		then
		    local nTargetLocation = J.GetCastLocation(bot,nWeakestEnemyHeroInBonus,nCastRange,nRadius);
			if nTargetLocation ~= nil
			then
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation;
			end
		end
	end
	   
	--对线期对两名以上敌人使用
	if bot:GetActiveMode() == BOT_MODE_LANING 
		and #nTowers <= 0 
		and nHP >= 0.4
	then
		if nCanHurtHeroLocationAoE.count >= 2
		   and GetUnitToLocationDistance(bot,nCanHurtHeroLocationAoE.targetloc) <= nCastRange + 50
		then 
			return BOT_ACTION_DESIRE_HIGH, nCanHurtHeroLocationAoE.targetloc;
		end
	end
	
	--撤退时保护自己
	if  bot:GetActiveMode() == BOT_MODE_RETREAT 
		and bot:WasRecentlyDamagedByAnyHero(2.0)
	then
		local nCanHurtHeroLocationAoENearby = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange - 300, nRadius, 0.8, 0);
		if nCanHurtHeroLocationAoENearby.count >= 1 
		then
			return BOT_ACTION_DESIRE_HIGH, nCanHurtHeroLocationAoENearby.targetloc;
		end
	end
	
	--进攻时的逻辑
	if J.IsGoingOnSomeone(bot)
	then
	
		--进攻时对两名以上敌人使用
		if J.IsValid(nWeakestEnemyHeroInBonus)
		   and nCanHurtHeroLocationAoE.count >= 2 
		   and GetUnitToLocationDistance(bot,nCanHurtHeroLocationAoE.targetloc) <= nCastRange
		then
			return BOT_ACTION_DESIRE_HIGH, nCanHurtHeroLocationAoE.targetloc;
		end
		
		--对进攻目标使用
		local npcEnemy = J.GetProperTarget(bot);
		if J.IsValidHero(npcEnemy)
			and J.CanCastOnNonMagicImmune(npcEnemy)
		then
			
			--蓝很多随意用
			if nMP > 0.75 
			   or bot:GetMana() > nKeepMana * 2
			then
				local nTargetLocation = J.GetCastLocation(bot,npcEnemy,nCastRange,nRadius);
				if nTargetLocation ~= nil
				then
					return BOT_ACTION_DESIRE_HIGH, nTargetLocation;
				end
			end
			
			--进攻目标血很少
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
		
		--对最虚弱的敌人使用
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
		
		--无敌人时清理兵线
		if 	J.IsValid(nEnemysWeakestLaneCreeps2)
			and nCanHurtCreepsLocationAoE.count >= 5 
			and #nEnemysHeroesInBonus <= 0
			and bot:GetActiveMode() ~= BOT_MODE_ATTACK
			and nSkillLV >= 3
		then
		    return BOT_ACTION_DESIRE_HIGH, nCanHurtCreepsLocationAoE.targetloc;
		end		
	
		--无敌人时收钱
	    if nCanKillCreepsLocationAoE.count >= 3 
			and (J.IsValid(nEnemysWeakestLaneCreeps1) or nLV >= 25)
			and #nEnemysHeroesInBonus <= 0
			and bot:GetActiveMode() ~= BOT_MODE_ATTACK
			and nSkillLV >= 3
		then
		    return BOT_ACTION_DESIRE_HIGH, nCanKillCreepsLocationAoE.targetloc;
		end		
	end
	
	--非撤退的逻辑
	if bot:GetActiveMode() ~= BOT_MODE_RETREAT 
	then
		if  J.IsValid(nWeakestEnemyHeroInBonus)
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
			
			if  J.IsValid(nWeakestEnemyHeroInBonus) 
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
				
				if (nWeakestEnemyHeroInBonus:GetHealth()/nWeakestEnemyHeroInBonus:GetMaxHealth() < 0.4)
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
	
    
	--打钱
	if  J.IsFarming(bot)
		and nSkillLV >= 3
	then
	
		if nCanKillCreepsLocationAoE.count >= 2 
			and J.IsValid(nEnemysWeakestLaneCreeps1)
		then
		    return BOT_ACTION_DESIRE_HIGH, nCanKillCreepsLocationAoE.targetloc;
		end
		
		if nCanHurtCreepsLocationAoE.count >= 4 
			and J.IsValid(nEnemysWeakestLaneCreeps1)
		then
		    return BOT_ACTION_DESIRE_HIGH, nCanHurtCreepsLocationAoE.targetloc;
		end
		
	end
	
	--推进和防守
	if #nAllys <= 2 and nSkillLV >= 3
		and (J.IsPushing(bot) or J.IsDefending(bot)) 
	then
	
		if nCanHurtCreepsLocationAoE.count >= 4 
			and  J.IsValid(nEnemysWeakestLaneCreeps1)
		then
		    return BOT_ACTION_DESIRE_HIGH, nCanHurtCreepsLocationAoE.targetloc;
		end		
	
	    if nCanKillCreepsLocationAoE.count >= 2 
			and J.IsValid(nEnemysWeakestLaneCreeps1)
		then
		    return BOT_ACTION_DESIRE_HIGH, nCanKillCreepsLocationAoE.targetloc;
		end
	end
	
	
	if  bot:GetActiveMode() == BOT_MODE_ROSHAN
		and bot:GetMana() >= 400	
	then
		local npcTarget = bot:GetAttackTarget();
		if  J.IsRoshan(npcTarget)
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation();
		end
	end
	
	--特殊用法之辅助二技能收大野
	local nNeutarlCreeps = bot:GetNearbyNeutralCreeps(nCastRange + nRadius);
	if J.IsValid(nNeutarlCreeps[1])
	then 
	    for _,creep in pairs(nNeutarlCreeps)
		do
			if J.IsValid(creep)
				and creep:HasModifier('modifier_crystal_maiden_frostbite')
				and creep:GetHealth()/creep:GetMaxHealth() > 0.3
				and (  creep:GetUnitName() == 'npc_dota_neutral_dark_troll_warlord'
					or creep:GetUnitName() == 'npc_dota_neutral_satyr_hellcaller'
					or creep:GetUnitName() == 'npc_dota_neutral_polar_furbolg_ursa_warrior' )
			then
				local nTargetLocation = J.GetCastLocation(bot,creep,nCastRange,nRadius);
				if nTargetLocation ~= nil
				then
					return BOT_ACTION_DESIRE_HIGH, nTargetLocation;
				end			
			end
		end
	end
	
	--通用的用法
	if  #nEnemysHeroesInView == 0 
		and not J.IsGoingOnSomeone(bot)
		and nSkillLV > 2
	then
		
		if nCanKillCreepsLocationAoE.count >= 2 
			and (nEnemysWeakestLaneCreeps2 ~= nil or nLV == 25)
		then
		    return BOT_ACTION_DESIRE_HIGH, nCanKillCreepsLocationAoE.targetloc;
		end		
		
		if nCanHurtCreepsLocationAoE.count >= 4
		   and nEnemysWeakestLaneCreeps2 ~= nil
		then
			return BOT_ACTION_DESIRE_HIGH, nCanHurtCreepsLocationAoE.targetloc;
		end
		
	end
    
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

function X.cm_GetWeakestUnit( nEnemyUnits )
	
	local nWeakestUnit = nil;
	local nWeakestUnitLowestHealth = 10000;
	for _,unit in pairs(nEnemyUnits)
	do
		if 	J.CanCastOnNonMagicImmune(unit)
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