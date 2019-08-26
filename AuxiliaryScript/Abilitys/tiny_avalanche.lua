-----------------
--英雄：小小
--技能：山崩
--键位：Q
--类型：指向地点
--作者：Halcyon
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('tiny_avalanche')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;

nKeepMana = 300 --魔法储量
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
    
	local nSkillLV    = ability:GetLevel()
    local nRadius     = ability:GetSpecialValueInt("radius");
    local manaCost    = ability:GetManaCost();
	local nCastRange  = ability:GetCastRange() + aetherRange
    local nCastPoint  = ability:GetCastPoint()
    local nDamage     = ability:GetSpecialValueInt('damage');
	local nDamageType = DAMAGE_TYPE_MAGICAL;

    local target  = J.GetProperTarget(bot);
    local hNearEnemyHeroList = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
    
    --打断和击杀
    for _,npcEnemy in pairs( hNearEnemyHeroList )
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
					return BOT_ACTION_DESIRE_HIGH, nBetterTarget:GetLocation();
				else
					J.SetReport("打断或击杀目标:",npcEnemy:GetUnitName());
					return BOT_ACTION_DESIRE_HIGH, npcEnemy:GetLocation();
				end
			end			
		end
    end
    -- 对单人
    if J.IsGoingOnSomeone(bot) and #hNearEnemyHeroList == 1
	then
		local castRangetarget = ability:GetCastRange() + 128 + aetherRange

		if J.IsValidHero(target) 
		   and J.CanCastOnNonMagicImmune(target) 
		   and J.IsInRange(target, bot, castRangetarget) 
		then
			return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
		end
	end
    -- 对多人
    if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidHero(target) 
		   and J.CanCastOnNonMagicImmune(target) 
		   and J.IsInRange(target, bot, nCastRange - 200) 
		then
			return BOT_ACTION_DESIRE_HIGH, target:GetExtrapolatedLocation(nCastPoint + 0.3);
		end
    end
    --逃跑
    if J.IsRetreating(bot)
	then
		if #hNearEnemyHeroList > 0 and bot:WasRecentlyDamagedByAnyHero(2.0) then
			local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange - 100, nRadius *1.6, nCastPoint, 0 );
			if locationAoE.count >= 1 and #hNearEnemyHeroList >= 1
			then
				return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
			end
		end
	end	
    
    --清兵
    if J.IsInTeamFight(bot, 1300)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2 and #hNearEnemyHeroList >= 2 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
    end

    if ( J.IsPushing(bot) or J.IsDefending(bot) ) and J.IsAllowedToSpam(bot, manaCost)
	then
		local lanecreeps = bot:GetNearbyLaneCreeps(nCastRange, true);
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 4 and #lanecreeps >= 4  ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X;