-----------------
--英雄：暗影恶魔
--技能：灵魂猎手
--键位：W
--类型：指向地点
--作者：Halcyon
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('shadow_demon_soul_catcher')
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
       or bot:GetMana() <= 120
	then 
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end
	
	local nSkillLV    = ability:GetLevel(); 
    local nRadius     = ability:GetSpecialValueInt( "radius" );
    local nCastPoint  = ability:GetCastPoint();
	local nCastRange  = ability:GetCastRange();
    
    local nEnemysHeroesInSkillRange = bot:GetNearbyHeroes(nCastRange + nRadius + 30,true,BOT_MODE_NONE)

    local nCanHurtHeroLocationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius - 30, 0.2, 0);
    
    local npcTarget = J.GetProperTarget(bot)

    if #nEnemysHeroesInSkillRange >= 2
		and nCanHurtHeroLocationAoE.cout ~= nil
		and nCanHurtHeroLocationAoE.cout >= 2
		and bot:GetActiveMode() ~= BOT_MODE_LANING
		and ( bot:GetActiveMode() ~= BOT_MODE_RETREAT or bot:GetActiveModeDesire() < 0.7 )
    then
		return BOT_ACTION_DESIRE_HIGH,nCanHurtHeroLocationAoE.targetloc;
    end
    
    if J.IsValidHero(npcTarget) 
	   and J.CanCastOnNonMagicImmune(npcTarget)
	   and J.IsInRange(npcTarget, bot, nCastRange +100)
	   and (nSkillLV >= 3 or bot:GetMana() >= nKeepMana)
	then
		local targetFutureLoc = J.GetCorrectLoc(npcTarget, nCastPoint + 0.8) 
	    if npcTarget:GetLocation() ~= targetFutureLoc
	    then			
		    return BOT_ACTION_DESIRE_HIGH,targetFutureLoc ;
		end
		
		local castDistance = GetUnitToUnitDistance(bot, npcTarget)
		if npcTarget:IsFacingLocation(bot:GetLocation(), 45)
		then
			if castDistance > 300	
			then   
			    castDistance = castDistance - 100;
			end
			
		    return BOT_ACTION_DESIRE_HIGH,J.GetUnitTowardDistanceLocation(bot,npcTarget,castDistance);
		end		
		
		if bot:IsFacingLocation(npcTarget:GetLocation(), 45)
		then
		    if castDistance + 100 <= nCastRange
			then
			    castDistance = castDistance + 200;
			else
			    castDistance = nCastRange+ 100;
			end
			
		    return BOT_ACTION_DESIRE_HIGH, J.GetUnitTowardDistanceLocation(bot,npcTarget,castDistance);
		end
		
		return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation();
		
	end
	
	if ( bot:GetActiveMode() == BOT_MODE_RETREAT and not bot:IsMagicImmune()) 
	then
		local nCanHurtHeroLocationAoENearby = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange - 200, nRadius, 0.2, 0);
		if nCanHurtHeroLocationAoENearby.count >= 1 
			and bot:IsFacingLocation(nCanHurtHeroLocationAoENearby.targetloc,60)
		then			
			return BOT_ACTION_DESIRE_HIGH, nCanHurtHeroLocationAoENearby.targetloc;
		end
	end
	
	if  bot:GetActiveMode() == BOT_MODE_ROSHAN  
	then
	    local nAttackTarget = bot:GetAttackTarget();
        if J.IsValid(nAttackTarget)
           and J.IsRoshan(nAttackTarget)
           and J.CanCastOnMagicImmune(nAttackTarget)
           and J.IsInRange(nAttackTarget, bot, nCastRange)
		then
			return BOT_ACTION_DESIRE_HIGH,nAttackTarget:GetLocation();
		end
    end
    
    if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if J.IsValidHero(npcTarget) and J.CanCastOnNonMagicImmune(npcTarget) and J.IsInRange(npcTarget, bot, nCastRange + 200) 
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation();
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X;