-----------------
--英雄：复仇之魂
--技能：移形换位
--键位：R
--类型：指向目标
--作者：Halcyon
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('vengefulspirit_nether_swap')
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
		bot:ActionQueue_UseAbilityOnEntity( ability, castTarget ) --使用技能
		
		local glimmer = J.IsItemAvailable("item_glimmer_cape");
		local shadow = J.IsItemAvailable("item_shadow_amulet");
		
		if shadow ~= nil and shadow:IsFullyCastable() then 
			bot:ActionQueue_UseAbilityOnEntity( shadow, bot )
		end	

		if glimmer ~= nil and glimmer:IsFullyCastable() then 
			bot:ActionQueue_UseAbilityOnEntity( glimmer, bot )
		end	
    end
end

--补偿功能
function X.Compensation()
    J.SetQueuePtToINT(bot, false)--临时补充魔法
end

--技能释放欲望
function X.Consider()

	-- 确保技能可以使用
    if ability == nil
       or not ability:IsFullyCastable()
       or bot:IsRooted()
	then
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end
	
	local nCastRange = ability:GetCastRange() + 40;
	local nCastPoint = ability:GetCastPoint();
	local nSkillLV   = ability:GetLevel();
	local nDamage    = 0;
	
	local nEnemysHeroesInCastRange = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);	
	local nAllysHeroesInCastRange = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE);
	
	
	if J.IsInTeamFight(bot, 1200)
	   and DotaTime() > 6*60
	then
		local npcTarget = nil;
		local npcTargetHealth = 99999;		
		
		for _,npcEnemy in pairs( nEnemysHeroesInCastRange )
		do
			if  J.IsValid(npcEnemy)
				and J.CanCastOnNonMagicImmune(npcEnemy) 
				and not J.IsDisabled(true, npcEnemy)
				and not npcEnemy:IsAttackImmune()
				and npcEnemy:GetPrimaryAttribute() == ATTRIBUTE_INTELLECT
				and npcEnemy:GetUnitName() ~= "npc_dota_hero_necrolyte"
			then
				if ( npcEnemy:GetHealth() < npcTargetHealth )
				then
					npcTarget = npcEnemy;
					npcTargetHealth = npcEnemy:GetHealth();
				end
			end
		end		
        if npcTarget ~= nil
           and not DangerousTarget(npcTarget)
		then
			bot:SetTarget(npcTarget);
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end		
		
		
		for _,npcEnemy in pairs( nEnemysHeroesInCastRange )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and not J.IsDisabled(true, npcEnemy)
				and not npcEnemy:IsAttackImmune()
				and npcEnemy:GetPrimaryAttribute() == ATTRIBUTE_AGILITY
				and not npcEnemy:GetUnitName() == "npc_dota_hero_meepo"
			then
				if ( npcEnemy:GetHealth() < npcTargetHealth )
				then
					npcTarget = npcEnemy;
					npcTargetHealth = npcEnemy:GetHealth();
				end
			end
		end		
        if npcTarget ~= nil
           and not DangerousTarget(npcTarget)
		then
			bot:SetTarget(npcTarget);
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end		
		
		
		for _,npcEnemy in pairs( nEnemysHeroesInCastRange )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and not npcEnemy:IsAttackImmune()
				and not J.IsDisabled(true, npcEnemy)
			then
				if ( npcEnemy:GetHealth() < npcTargetHealth )
				then
					npcTarget = npcEnemy;
					npcTargetHealth = npcEnemy:GetHealth();
				end
			end
		end		
        if npcTarget ~= nil
           and not DangerousTarget(npcTarget)
		then
			bot:SetTarget(npcTarget);
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end			
	end
	
	
	if J.IsGoingOnSomeone(bot)
		and DotaTime() > 6*30 
	then
		local target = J.GetProperTarget(bot)
		if  J.IsValidHero(target) 
			and J.CanCastOnNonMagicImmune(target) 
			and J.IsInRange(target, bot, nCastRange) 
            and not J.IsDisabled(true, target)
            and not DangerousTarget(target)
		then
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end

	for _,npcAlly in pairs( nAllysHeroesInCastRange )
	do
		local npcAllyHP = npcAlly:GetHealth()/npcAlly:GetMaxHealth();--队友血量比
		local nEnemy = npcAlly:GetNearbyHeroes(100, true, BOT_MODE_NONE)

		if  J.IsValid(npcAlly)
			and J.CanCastOnNonMagicImmune(npcAlly) 
			and nHP > 0.7
			and npcAllyHP < 0.1
			and #nEnemy > 0
            and npcAlly:DistanceFromFountain() > bot:DistanceFromFountain()
            and not DangerousTarget(npcAlly)
		then
			return BOT_ACTION_DESIRE_HIGH, npcAlly;
		end
	end
	
	
	if J.IsRetreating(bot) 
	then
		return BOT_ACTION_DESIRE_NONE;
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

function DangerousTarget(target)
	local targets = target:GetNearbyHeroes(500, false, BOT_MODE_NONE)
	local allys = target:GetNearbyHeroes(400, true, BOT_MODE_NONE)
	local distance = GetUnitToUnitDistance(bot, target);

	if allys ~= nil then
		if #allys >= 3 then
			return true;
		end
	end
	
	if J.GetDistanceFromAllyFountain(target) < J.GetDistanceFromAllyFountain(bot) then
		return true;
	end

	if targets ~= nil then
		if #targets >= 4 then
			return true;
		elseif #targets <= 2
			and distance <= 800
		then
			return false;
		end

		local DangerousHp = 0;

		if target:GetHealth() / target:GetMaxHealth() < 0.15
			and distance >= 600
		then
			return false;
		end

		for i=1, #targets do
			if targets[i]:GetHealth() > bot:GetHealth() + 200
			then
				DangerousHp = DangerousHp + 1;
			end
		end

		if DangerousHp >= 2
		then
			return true;
		end

	end

	return false;
end

return X;