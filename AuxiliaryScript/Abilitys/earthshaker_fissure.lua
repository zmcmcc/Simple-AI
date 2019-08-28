-----------------
--英雄：撼地者
--技能：沟壑
--键位：Q
--类型：指向地点
--作者：halcyon
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('earthshaker_fissure')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;

nKeepMana = 180 --魔法储量
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
	
	local nCastRange = ability:GetCastRange();
	local nDamage = ability:GetAbilityDamage();
	local nRadius = ability:GetAOERadius();
	local nCastPoint = ability:GetCastPoint();
	
	local nAllys = bot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
	local nEenemys = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE)
	local WeakestEnemy = J.GetVulnerableWeakestUnit(true, true, nRadius, bot);
	local WeakestCreep = J.GetVulnerableWeakestUnit(false, true, nRadius, bot);

	local nCreeps = bot:GetNearbyCreeps(1600,true)

	--------------------------------------
	-- Global high-priorty usage
	--------------------------------------
	-- Check for a channeling enemy
	for _,npcEnemy in pairs(nEenemys)
	do
		if npcEnemy:IsChanneling()
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation();
		end
	end

	--try to kill enemy hero
	if bot:GetActiveMode() ~= BOT_MODE_RETREAT
	then
		if WeakestEnemy ~= nil
		then
			if J.IsValid(WeakestEnemy)
			   and J.CanCastOnNonMagicImmune(WeakestEnemy) 
			   and not J.IsDisabled(true, WeakestEnemy)
			then
                if WeakestEnemy:GetHealth() <= WeakestEnemy:GetActualIncomingDamage(nDamage, DAMAGE_TYPE_MAGICAL)
                   or WeakestEnemy:GetHealth() <= WeakestEnemy:GetActualIncomingDamage(nDamage,DAMAGE_TYPE_MAGICAL)
				then
					return BOT_ACTION_DESIRE_HIGH,WeakestEnemy:GetExtrapolatedLocation(nCastPoint); 
				end
			end
		end
	end
	--------------------------------------
	-- Mode based usage
	--------------------------------------		
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
    if bot:GetActiveMode() == BOT_MODE_RETREAT 
       and bot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH
	then
		for _,npcEnemy in pairs(nEenemys)
		do
			if bot:WasRecentlyDamagedByHero(npcEnemy, 2.0)
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy:GetExtrapolatedLocation(nCastPoint);
			end
		end
	end
	
	-- If we're farming and can kill 3+ creeps
	if bot:GetActiveMode() == BOT_MODE_FARM
	then
		if nMP > 0.4
		then
			local locationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0);
			if locationAoE.count >= 3 then
				return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
			end
		end
	end
	
	if bot:GetActiveMode() == BOT_MODE_LANING
	then
		if nMP > 0.75
		then	
			local locationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0);
			if locationAoE.count >= 2 then
				return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc;
			end
			
			if J.IsValid(WeakestEnemy)
			and J.CanCastOnNonMagicImmune(WeakestEnemy) 
			and not J.IsDisabled(true, WeakestEnemy)
			then
				
				return BOT_ACTION_DESIRE_LOW,WeakestEnemy:GetExtrapolatedLocation(nCastPoint)
			end	
		end
	end

	-- If we're pushing or defending a lane and can hit 4+ creeps
    if bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_TOP 
       or bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_MID
       or bot:GetActiveMode() == BOT_MODE_PUSH_TOWER_BOT
       or bot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_TOP
       or bot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_MID
       or bot:GetActiveMode() == BOT_MODE_DEFEND_TOWER_BOT
	then
		if nMP > 0.4
		then
			local locationAoE = bot:FindAoELocation(true, false, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0);
			if locationAoE.count >= 3
			then
				return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
			end
		end
	end

	-- If we're going after someone
    if bot:GetActiveMode() == BOT_MODE_ROAM
       or bot:GetActiveMode() == BOT_MODE_TEAM_ROAM
       or bot:GetActiveMode() == BOT_MODE_DEFEND_ALLY
       or bot:GetActiveMode() == BOT_MODE_ATTACK
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0 );
		if locationAoE.count >= 2 then
			return BOT_ACTION_DESIRE_MODERATE, locationAoE.targetloc;
		end
		
		local npcTarget = bot:GetTarget();
		if npcTarget ~= nil
		then
			if J.IsValid(WeakestEnemy)
			   and J.CanCastOnNonMagicImmune(WeakestEnemy) 
			   and not J.IsDisabled(true, WeakestEnemy)
			   and GetUnitToUnitDistance(bot,npcEnemy) <= nCastRange
			then
				return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetExtrapolatedLocation(nCastPoint);
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X;