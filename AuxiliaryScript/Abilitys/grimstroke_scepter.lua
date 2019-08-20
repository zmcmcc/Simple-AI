-----------------
--英雄：天涯墨客
--技能：墨涌
--键位：E
--类型：指向目标
--作者：Halcyon
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('grimstroke_scepter')
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
       or not ability:IsFullyCastable()
	then 
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end
	
	local nRadius = 300
	local castRange = ability:GetCastRange() 
	local target  = J.GetProperTarget(bot);
    local aTarget = bot:GetAttackTarget(); 
	local enemies = bot:GetNearbyHeroes(castRange, true, BOT_MODE_NONE);
	
	if J.IsInTeamFight(bot, 1200)
	then
		local npcMostAoeEnemy = nil;
		local nMostAoeECount  = 1;
		local nEnemysHerosInRange = bot:GetNearbyHeroes(castRange + 43,true,BOT_MODE_NONE);
		local nEmemysCreepsInRange = bot:GetNearbyCreeps(castRange + 43,true);
		local nAllEnemyUnits = J.CombineTwoTable(nEnemysHerosInRange,nEmemysCreepsInRange);
		
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;		
		
		for _,npcEnemy in pairs( nAllEnemyUnits )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
			then
				
				local nEnemyHeroCount = J.GetAroundTargetEnemyHeroCount(npcEnemy, nRadius);
				if ( nEnemyHeroCount > nMostAoeECount )
				then
					nMostAoeECount = nEnemyHeroCount;
					npcMostAoeEnemy = npcEnemy;
				end
				
				if npcEnemy:IsHero()
				then
					local npcEnemyDamage = npcEnemy:GetEstimatedDamageToTarget( false, bot, 3.0, DAMAGE_TYPE_MAGICAL );
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
			for _,npcAlly in pairs( npcMostAoeEnemy:GetNearbyHeroes(castRange, true, BOT_MODE_NONE) )
			do
				if  J.IsValid(npcAlly)
					and J.CanCastOnNonMagicImmune(npcAlly) 
				then
					return BOT_MODE_DESIRE_MODERATE, npcAlly;
				end
			end
		end	

		if ( npcMostDangerousEnemy ~= nil )
		then
			for _,npcAlly in pairs( npcMostDangerousEnemy:GetNearbyHeroes(castRange, true, BOT_MODE_NONE) )
			do
				if  J.IsValid(npcAlly)
					and J.CanCastOnNonMagicImmune(npcAlly) 
				then
					return BOT_MODE_DESIRE_MODERATE, npcAlly;
				end
			end
		end	
	end

	--对线期间对敌方英雄使用
	if bot:GetActiveMode() == BOT_MODE_LANING
	then
		for _,npcEnemy in pairs( enemies )
		do
			if  J.IsValid(npcEnemy)
				and J.CanCastOnNonMagicImmune(npcEnemy) 
				and not J.IsDisabled(true, npcEnemy)
				and J.GetAroundTargetEnemyHeroCount(npcEnemy, 600) >= 4
			then
				for _,npcAlly in pairs( npcEnemy:GetNearbyHeroes(castRange, true, BOT_MODE_NONE) )
				do
					if  J.IsValid(npcAlly)
						and J.CanCastOnNonMagicImmune(npcAlly) 
					then
						return BOT_ACTION_DESIRE_HIGH, npcAlly;
					end
				end
			end
		end
	end
	
	if ( J.IsPushing(bot) or J.IsDefending(bot) ) 
	then
		local creeps = bot:GetNearbyLaneCreeps(castRange, true);
		if #creeps >= 4 and creeps[1] ~= nil
		then
			local creep = creeps[1]:GetNearbyHeroes(castRange, true, BOT_MODE_NONE) 
			if creep ~= nil then
				for _,npcAlly in pairs( creep )
				do
					if  J.IsValid(npcAlly)
						and J.CanCastOnNonMagicImmune(npcAlly) 
					then
						return BOT_MODE_DESIRE_MODERATE, npcAlly;
					end
				end
			end
		end
	end

	
	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidHero(target) 
		   and J.CanCastOnNonMagicImmune(target) 
		   and J.IsInRange(target, bot, castRange) 
		then
			for _,npcAlly in pairs( target:GetNearbyHeroes(castRange, true, BOT_MODE_NONE) )
			do
				if  J.IsValid(npcAlly)
					and J.CanCastOnNonMagicImmune(npcAlly) 
				then
					return BOT_ACTION_DESIRE_HIGH, npcAlly;
				end
			end
		end	
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X;