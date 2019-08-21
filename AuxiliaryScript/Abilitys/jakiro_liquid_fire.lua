-----------------
--英雄：杰奇洛
--技能：液态火
--键位：E
--类型：指向目标
--作者：决明子
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('jakiro_liquid_fire')
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
	   or ability:IsNull()
       or not ability:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end
	
	local castRange = bot:GetAttackRange() + 200;
	if castRange > 1300 then castRange = 1300 end
	
	local target  = J.GetProperTarget(bot);
	local aTarget = bot:GetAttackTarget(); 
	local enemies = bot:GetNearbyHeroes(castRange, true, BOT_MODE_NONE);
	local nRadius = 300
	
	--团战中对作用数量最多或物理输出最强的敌人使用
	if J.IsInTeamFight(bot, 1200)
	then
		local npcMostAoeEnemy = nil;
		local nMostAoeECount  = 1;	
		local nEnemysHerosInBonus = bot:GetNearbyHeroes(castRange + 299,true,BOT_MODE_NONE);
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
			return BOT_ACTION_DESIRE_HIGH, npcMostAoeEnemy;
		end	

		if ( npcMostDangerousEnemy ~= nil )
		then
			return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy;
		end	
	end
	
	
	if aTarget ~= nil 
	   and aTarget:IsAlive()
	   and aTarget:IsBuilding() 
	   and J.IsInRange(aTarget, bot, castRange)  
	then
		return BOT_ACTION_DESIRE_HIGH, aTarget;
	end	
	
	
	if aTarget == nil and #enemies == 0
	then
		local hEnemyTowerList = bot:GetNearbyTowers(castRange +36,true);
		local hEnemyBarrackList = bot:GetNearbyBarracks(castRange + 36,true);
		local hTarget = hEnemyTowerList[1];
		if hTarget == nil then hTarget = hEnemyBarrackList[1] end
		if hTarget ~= nil
			and not hTarget:IsAttackImmune()
			and not hTarget:IsInvulnerable()
			and not hTarget:HasModifier("modifier_fountain_glyph")
			and not hTarget:HasModifier("modifier_backdoor_protection_active")
		then
			return BOT_ACTION_DESIRE_HIGH, hTarget;
		end
	end
	
	
	if ( J.IsPushing(bot) or J.IsDefending(bot) ) 
	then
		local towers = bot:GetNearbyTowers(castRange, true);
		if towers[1] ~= nil and not towers[1]:IsInvulnerable() and not towers[1]:HasModifier("modifier_fountain_glyph")
		then
			return BOT_ACTION_DESIRE_HIGH, towers[1];
		end
		local barracks = bot:GetNearbyBarracks(castRange, true);
		if barracks[1] ~= nil and not barracks[1]:IsInvulnerable() and not barracks[1]:HasModifier("modifier_fountain_glyph")
		then
			return BOT_ACTION_DESIRE_HIGH, barracks[1];
		end
		local creeps = bot:GetNearbyLaneCreeps(castRange, true);
		if #creeps >= 2 and creeps[1] ~= nil and not creeps[1]:HasModifier("modifier_fountain_glyph")
		then
			return BOT_ACTION_DESIRE_HIGH, creeps[1];
		end
	end

	
	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidHero(target) 
		   and J.CanCastOnNonMagicImmune(target) 
		   and J.IsInRange(target, bot, castRange) 
		then
			return BOT_ACTION_DESIRE_HIGH, target;
		end	
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X;