-----------------
--英雄：水晶室女
--技能：极寒领域
--键位：R
--类型：无目标
--作者：决明子
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('leshrac_pulse_nova')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange, abilityAhg;

nKeepMana = 400 --魔法储量
nLV = bot:GetLevel(); --当前英雄等级
nMP = bot:GetMana()/bot:GetMaxMana(); --目前法力值/最大法力值（魔法剩余比）
nHP = bot:GetHealth()/bot:GetMaxHealth();--目前生命值/最大生命值（生命剩余比）
hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内敌人
hAlleyHeroList = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);--1600范围内队友

--是否拥有蓝杖
abilityAhg = J.IsItemAvailable("item_ultimate_scepter"); 

--获取以太棱镜施法距离加成
local aether = J.IsItemAvailable("item_aether_lens");
if aether ~= nil then aetherRange = 250 else aetherRange = 0 end
    
--初始化函数库
U.init(nLV, nMP, nHP, bot);

--技能释放功能
function X.Release(castTarget)
	bot:ActionQueue_UseAbility( ability ) --使用技能
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
       or bot:DistanceFromFountain() < 100 
	then 
		return BOT_ACTION_DESIRE_NONE; --没欲望
	end
    
    -- Get some of its values
	local nRadius 	 = ability:GetAOERadius();                          
	
	local nAllies =  bot:GetNearbyHeroes(1200,false,BOT_MODE_NONE);
	
	local nEnemysHeroesInRange = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE);
	local nWeakestEnemyHeroInRange,nWeakestEnemyHeroHealth1 = X.cm_GetWeakestUnit(nEnemysHeroesInRange);
	
	
	local aoeCanHurtCount = 0
	for _,enemy in pairs (nEnemysHeroesInRange)
	do
		if  J.IsValid(enemy)
			and J.CanCastOnNonMagicImmune(enemy)
		    and ( J.IsDisabled(true, enemy) 
				  or J.IsInRange(bot, enemy, nRadius *0.82 - enemy:GetCurrentMovementSpeed()) )
		then
			aoeCanHurtCount = aoeCanHurtCount + 1
		end
	end
	if bot:GetActiveMode() ~= BOT_MODE_RETREAT 
	   or (bot:GetActiveMode() == BOT_MODE_RETREAT and bot:GetActiveModeDesire() <= 0.75 ) 
	then
		if ( #nEnemysHeroesInRange >= 3 or aoeCanHurtCount >= 2) 
		then
			return BOT_ACTION_DESIRE_HIGH;
		end		
	end	
	
	
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = J.GetProperTarget(bot);		
		if J.IsValidHero(npcTarget) 
			and J.CanCastOnNonMagicImmune(npcTarget) 
			and ( J.IsDisabled(true, npcTarget) or J.IsInRange(bot,npcTarget,280) )
			and npcTarget:GetHealth() <= npcTarget:GetActualIncomingDamage(bot:GetOffensivePower(),DAMAGE_TYPE_MAGICAL)
			and GetUnitToUnitDistance(npcTarget,bot) <= nRadius
			and npcTarget:GetHealth( ) > 400
			and #nAllies <= 2 
		then
--			J.PrintAndReport('进攻时尝试放大,队友数量:',#nAllies);
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	if J.IsRetreating(bot) and nHP > 0.38
	then
		local nEnemysHeroesNearby = bot:GetNearbyHeroes(500,true,BOT_MODE_NONE);
		local nEnemysHeroesFurther = bot:GetNearbyHeroes(1300,true,BOT_MODE_NONE);
		local npcTarget = nEnemysHeroesNearby[1];
		if J.IsValidHero(npcTarget) 
		   and J.CanCastOnNonMagicImmune(npcTarget)
		   and not abilityQ:IsFullyCastable()
		   and not abilityW:IsFullyCastable()
		   and nHP > 0.38 * #nEnemysHeroesFurther
		then
--			J.PrintAndReport('撤退时尝试放大,附近敌人:',#nEnemysHeroesFurther);
			return BOT_ACTION_DESIRE_HIGH;
		end	
	end	

	return BOT_ACTION_DESIRE_NONE;

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