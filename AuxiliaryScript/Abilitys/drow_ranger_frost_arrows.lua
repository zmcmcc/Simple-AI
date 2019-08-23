-----------------
--英雄：卓尔游侠
--技能：霜冻之箭
--键位：Q
--类型：指向目标
--作者：决明子
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('drow_ranger_frost_arrows')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;

nKeepMana = 90 --魔法储量
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
       or bot:IsInvisible()
	   or bot:IsDisarmed()
	   or J.GetDistanceFromEnemyFountain(bot) < 800
	then
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end
    
    local nAttackRange = bot:GetAttackRange() + 40;
	local nAttackDamage = bot:GetAttackDamage();
	
	local nTowers = bot:GetNearbyTowers(900,true)
	local nEnemysLaneCreepsInRange = bot:GetNearbyLaneCreeps(nAttackRange + 30,true)
	local nEnemysLaneCreepsNearby = bot:GetNearbyLaneCreeps(400,true)
	local nEnemysWeakestLaneCreepsInRange = J.GetAttackableWeakestUnit(false, true, nAttackRange + 30, bot)
	local nEnemysWeakestLaneCreepsInRangeHealth = 10000
	if(nEnemysWeakestLaneCreepsInRange ~= nil)
	then
	    nEnemysWeakestLaneCreepsInRangeHealth = nEnemysWeakestLaneCreepsInRange:GetHealth();
	end
	
	local nEnemysHeroesInAttackRange = bot:GetNearbyHeroes(nAttackRange,true,BOT_MODE_NONE);
	local nInAttackRangeWeakestEnemyHero = J.GetAttackableWeakestUnit(true, true, nAttackRange, bot);
	local nInViewWeakestEnemyHero = J.GetAttackableWeakestUnit(true, true, 800, bot);

	local nAlleyLaneCreeps = bot:GetNearbyLaneCreeps(330,false);
	local npcTarget = J.GetProperTarget(bot)
	local nTargetUint = nil;
	local npcMode = bot:GetActiveMode();
	
	
	if nLV >= 10 
	then
		if hEnemyHeroList[1] ~= nil
			and not ability:GetAutoCastState()
		then
			lastAutoTime = DotaTime();
			ability:ToggleAutoCast();
		elseif hEnemyHeroList[1] == nil
				and lastAutoTime + 3.0 < DotaTime()
				and ability:GetAutoCastState()
			then
				ability:ToggleAutoCast()
	    end
	else
		if  ability:GetAutoCastState( ) 
		then
			ability:ToggleAutoCast()
		end
	end	
	
	if nLV <= 9 
	   and not J.IsRunning(bot)
	   and nHP > 0.55
	then
		if  J.IsValidHero(npcTarget)
			and GetUnitToUnitDistance(bot,npcTarget) < nAttackRange + 99
		then
			nTargetUint = npcTarget;
			return BOT_ACTION_DESIRE_HIGH, nTargetUint;
		end	
	end
	
	
	if npcMode == BOT_MODE_LANING
		and #nTowers == 0
	then
		
		if J.IsValid(nInAttackRangeWeakestEnemyHero)
		then
			if nEnemysWeakestLaneCreepsInRangeHealth > 130
				and nHP >= 0.6 
				and #nEnemysLaneCreepsNearby <= 3 
				and #nAlleyLaneCreeps >= 2
				and not bot:WasRecentlyDamagedByCreep(1.5)
				and not bot:WasRecentlyDamagedByAnyHero(1.5)
			then
				nTargetUint = nInAttackRangeWeakestEnemyHero;
				return BOT_ACTION_DESIRE_HIGH, nTargetUint;
			end
		end
		
		
		if J.IsValid(nInViewWeakestEnemyHero)
		then
			if nEnemysWeakestLaneCreepsInRangeHealth > 180
				and nHP >= 0.7 
				and #nEnemysLaneCreepsNearby <= 2 
				and #nAlleyLaneCreeps >= 3
				and not bot:WasRecentlyDamagedByCreep(1.5)
				and not bot:WasRecentlyDamagedByAnyHero(1.5)
				and not bot:WasRecentlyDamagedByTower(1.5)
			then
				nTargetUint = nInViewWeakestEnemyHero;
				return BOT_ACTION_DESIRE_HIGH, nTargetUint;
			end
			
			if J.GetUnitAllyCountAroundEnemyTarget(nInViewWeakestEnemyHero , 500) >= 4
				and not bot:WasRecentlyDamagedByCreep(1.5)
				and not bot:WasRecentlyDamagedByAnyHero(1.5)
				and not bot:WasRecentlyDamagedByTower(1.5)
			    and nHP >= 0.6 
			then
				nTargetUint = nInViewWeakestEnemyHero;
				return BOT_ACTION_DESIRE_HIGH, nTargetUint;
			end			
		end		
	end
	
	
	if npcTarget ~= nil
		and npcTarget:IsHero()
		and GetUnitToUnitDistance(npcTarget,bot) >  nAttackRange + 160
		and J.IsValid(nInAttackRangeWeakestEnemyHero)
		and not nInAttackRangeWeakestEnemyHero:IsAttackImmune()
	then
		nTargetUint = nInAttackRangeWeakestEnemyHero;
		bot:SetTarget(nTargetUint);
		return BOT_ACTION_DESIRE_HIGH, nTargetUint;
	end
	
	
	if bot:HasModifier("modifier_item_hurricane_pike_range")
		and J.IsValid(npcTarget)
	then
		nTargetUint = npcTarget;
		return BOT_ACTION_DESIRE_HIGH, nTargetUint;	
	end
	
	
	if  bot:GetAttackTarget() == nil 
		and  bot:GetTarget() == nil
		and  #hEnemyHeroList == 0
		and  npcMode ~= BOT_MODE_RETREAT
		and  npcMode ~= BOT_MODE_ATTACK 
		and  npcMode ~= BOT_MODE_ASSEMBLE
		and  npcMode ~= BOT_MODE_FARM
		and  npcMode ~= BOT_MODE_TEAM_ROAM
		and  J.GetTeamFightAlliesCount(bot) < 3
		and  bot:GetMana() >= 180
		and  not bot:WasRecentlyDamagedByAnyHero(3.0) 
	then		
		
        if bot:HasScepter()
		then
			local nEnemysCreeps = bot:GetNearbyCreeps(1600,true)
			if J.IsValid(nEnemysCreeps[1])
			then
				nTargetUint = nEnemysCreeps[1];
				return BOT_ACTION_DESIRE_HIGH, nTargetUint;
			end
		end
			
		local nNeutralCreeps = bot:GetNearbyNeutralCreeps(1600)
		if npcMode ~= BOT_MODE_LANING
			and nLV >= 6  
			and nHP > 0.25
			and J.IsValid(nNeutralCreeps[1])
			and not J.IsRoshan(nNeutralCreeps[1])
			and (nNeutralCreeps[1]:IsAncientCreep() == false or nLV >= 12)
		then
			nTargetUint = nNeutralCreeps[1];
			return BOT_ACTION_DESIRE_HIGH, nTargetUint;
		end
		
		
		local nLaneCreeps = bot:GetNearbyLaneCreeps(1600,true)
		if npcMode ~= BOT_MODE_LANING
			and nLV >= 6  
			and nHP > 0.25
			and J.IsValid(nLaneCreeps[1])
			and bot:GetAttackDamage() > 130
		then
			nTargetUint = nLaneCreeps[1]; 
			return BOT_ACTION_DESIRE_HIGH, nTargetUint;
		end
	end
	
	
	if npcMode == BOT_MODE_RETREAT
	then
		
		nDistance = 999
		local nTargetUint = nil
	    for _,npcEnemy in pairs( nEnemysHeroesInAttackRange )
		do
			if  J.IsValid(npcEnemy)
				and npcEnemy:HasModifier("modifier_drowranger_wave_of_silence_knockback") 
				and GetUnitToUnitDistance(npcEnemy,bot) < nDistance
			then
				nTargetUint = npcEnemy;
				nDistance = GetUnitToUnitDistance(npcEnemy,bot);	
			end
		end		
		
		if nTargetUint ~= nil
		   and not nTargetUint:HasModifier("modifier_drow_ranger_frost_arrows_slow")
		then
			return BOT_ACTION_DESIRE_HIGH, nTargetUint;
		end
	end
    
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X;