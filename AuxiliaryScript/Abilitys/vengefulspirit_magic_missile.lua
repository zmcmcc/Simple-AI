-----------------
--英雄：复仇之魂
--技能：魔法箭
--键位：Q
--类型：指向目标
--作者：Halcyon
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('vengefulspirit_magic_missile')
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
	
	local nCastRange = ability:GetCastRange( ) + 50;
	local nCastPoint = ability:GetCastPoint( );
	local nSkillLV   = ability:GetLevel( );
	local nDamage    = 25 + nSkillLV*75;
	
	local nEnemysHeroesInCastRange = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);	
	local nEnemysHeroesInView      = bot:GetNearbyHeroes(800, true, BOT_MODE_NONE);
	
	--击杀
	if #nEnemysHeroesInCastRange > 0 then
		for i=1, #nEnemysHeroesInCastRange do
			if J.IsValid(nEnemysHeroesInCastRange[i])
			   and J.CanCastOnNonMagicImmune(nEnemysHeroesInCastRange[i]) 
			   and nEnemysHeroesInCastRange[i]:GetHealth() < nEnemysHeroesInCastRange[i]:GetActualIncomingDamage(nDamage,DAMAGE_TYPE_MAGICAL)
			   and not (GetUnitToUnitDistance(nEnemysHeroesInCastRange[i],bot) <= bot:GetAttackRange() + 60)
			   and not J.IsDisabled(true, nEnemysHeroesInCastRange[i]) 
			then
				return BOT_ACTION_DESIRE_HIGH, nEnemysHeroesInCastRange[i];
			end
		end
	end
	
	--打断
	if #nEnemysHeroesInView > 0 then
		for i=1, #nEnemysHeroesInView do
			if J.IsValid(nEnemysHeroesInView[i])
			   and J.CanCastOnNonMagicImmune(nEnemysHeroesInView[i]) 
			   and nEnemysHeroesInView[i]:IsChanneling()
			then
				return BOT_ACTION_DESIRE_HIGH, nEnemysHeroesInCastRange[i];
			end
		end
	end
	
	
	--团战
	if J.IsInTeamFight(bot, 1200)
	   and  DotaTime() > 6*60
	then
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;
		
		for _,npcEnemy in pairs( nEnemysHeroesInCastRange )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and not J.IsDisabled(true, npcEnemy)
				and not npcEnemy:IsDisarmed()
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
	
	--常规
	if J.IsGoingOnSomeone(bot)
	then
		local target = J.GetProperTarget(bot)
		if J.IsValidHero(target) 
			and J.CanCastOnNonMagicImmune(target) 
			and J.IsInRange(target, bot, nCastRange) 
		    and not J.IsDisabled(true, target)
			and not target:IsDisarmed()
		then
			return BOT_ACTION_DESIRE_HIGH, target;
		end
	end
	
	
	if J.IsRetreating(bot) 
	then
		if J.IsValid(nEnemysHeroesInCastRange[1]) 
		   and J.CanCastOnNonMagicImmune(nEnemysHeroesInCastRange[1]) 
		   and not J.IsDisabled(true, nEnemysHeroesInCastRange[1])
		   and not nEnemysHeroesInCastRange[1]:IsDisarmed()
		   and GetUnitToUnitDistance(bot,nEnemysHeroesInCastRange[1]) <= nCastRange - 60 
		then
			
			return BOT_ACTION_DESIRE_HIGH, nEnemysHeroesInCastRange[1];
		end
	end
	
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN 
		and  bot:GetMana() > 400
	then
		local target =  bot:GetAttackTarget();
		
		if target ~= nil and target:IsAlive()
			and not J.IsDisabled(true, target)
			and not target:IsDisarmed()
		then
			return BOT_ACTION_DESIRE_LOW, target;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X;