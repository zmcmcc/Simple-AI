-----------------
--英雄：不朽尸王
--技能：噬魂
--键位：W
--类型：指向目标
--作者：Halcyon
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('undying_soul_rip')
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
	local nCastRange = ability:GetCastRange()  + aetherRange;
	local nCastPoint = ability:GetCastPoint();
	local nManaCost  = ability:GetManaCost();
	local nSkillLV   = ability:GetLevel();
	
	local nAllies =  bot:GetNearbyHeroes(1200,false,BOT_MODE_NONE);
	
	local nEnemysHeroesInRange = bot:GetNearbyHeroes(nCastRange +50,true,BOT_MODE_NONE);
	local nEnemysHeroesInBonus = bot:GetNearbyHeroes(nCastRange + 150,true,BOT_MODE_NONE);
	local nWeakestEnemyHeroInRange,nWeakestEnemyHeroInRangeHealth = sil_GetWeakestUnit(nEnemysHeroesInRange);
	local nWeakestEnemyHeroInBonus,nWeakestEnemyHeroInBonusHealth = sil_GetWeakestUnit(nEnemysHeroesInBonus);
	
	local nTowers = bot:GetNearbyTowers(900,true)
	
	if J.IsInTeamFight(bot, 1200)
	then
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;
		
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange + 100, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if  J.IsValidHero(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and J.CanCastOnTargetAdvanced(npcEnemy)
				and not J.IsDisabled(true, npcEnemy)
			then
				local npcEnemyDamage = npcEnemy:GetEstimatedDamageToTarget( false, bot, 3.0, DAMAGE_TYPE_ALL );
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
	
	
	if bot:WasRecentlyDamagedByAnyHero(3.0) 
		and nEnemysHeroesInRange[1] ~= nil
		and #nEnemysHeroesInRange >= 1
	then
		for _,npcEnemy in pairs( nEnemysHeroesInRange )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and J.CanCastOnTargetAdvanced(npcEnemy)
				and not J.IsDisabled(true, npcEnemy) 
				and not npcEnemy:IsIllusion()
				and bot:IsFacingLocation(npcEnemy:GetLocation(),30)
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end
	
	
	if ( bot:GetActiveMode() == BOT_MODE_LANING and #nTowers == 0) or DotaTime() > 12*60 
	then
		if( nMP > 0.7 or bot:GetMana()> nKeepMana * (3 - nSkillLV) )
		then
			if J.IsValid(nWeakestEnemyHeroInRange)
			then
				if not J.IsDisabled(true, nWeakestEnemyHeroInRange) 
				then
					return BOT_ACTION_DESIRE_HIGH,nWeakestEnemyHeroInRange;
				end
			end
		end	
	
		if( nMP > 0.88 or bot:GetMana()> nKeepMana * 3 )
		then
			local nEnemysCreeps = bot:GetNearbyCreeps(1400,true)	
			if J.IsValidHero(nWeakestEnemyHeroInBonus) 
				and nHP > 0.6 
				and #nTowers == 0
				and ( (#nEnemysCreeps + #nEnemysHeroesInBonus) <= 5 or DotaTime() > 12*60 )
			then
				if not J.IsDisabled(true, nWeakestEnemyHeroInBonus) 
				then
					return BOT_ACTION_DESIRE_HIGH,nWeakestEnemyHeroInBonus;
				end
			end
		end
		
		if J.IsValid(nWeakestEnemyHeroInRange)
		then
			if nWeakestEnemyHeroInRange:GetHealth()/nWeakestEnemyHeroInRange:GetMaxHealth() < 0.4 
			then
				return BOT_ACTION_DESIRE_HIGH,nWeakestEnemyHeroInRange;
			end
		end
	end
		
	
	if J.IsGoingOnSomeone(bot)
	then
	    local npcTarget = J.GetProperTarget(bot);
		if J.IsValidHero(npcTarget) 
			and J.CanCastOnNonMagicImmune(npcTarget) 
			and J.CanCastOnTargetAdvanced(npcTarget)
			and J.IsInRange(npcTarget, bot, nCastRange + 150) 
			and not J.IsDisabled(true, npcTarget)
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	
	if J.IsRetreating(bot) 
	then
		for _,npcEnemy in pairs( nEnemysHeroesInRange )
		do
			if J.IsValid(npcEnemy)
			    and bot:WasRecentlyDamagedByHero( npcEnemy, 3.1 ) 
				and J.CanCastOnNonMagicImmune(npcEnemy) 
				and J.CanCastOnTargetAdvanced(npcEnemy)
				and not J.IsDisabled(true, npcEnemy) 
				and J.IsInRange(npcEnemy, bot, nCastRange) 
				and ( not J.IsInRange(npcEnemy, bot, 450) or bot:IsFacingLocation(npcEnemy:GetLocation(), 45) )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	
	if  bot:GetActiveMode() == BOT_MODE_ROSHAN 
	    and bot:GetMana() >= 600
		and ability:GetLevel() >= 3
	then
		local npcTarget = bot:GetAttackTarget();
		if  J.IsRoshan(npcTarget) 
			and J.IsInRange(npcTarget, bot, nCastRange)
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
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