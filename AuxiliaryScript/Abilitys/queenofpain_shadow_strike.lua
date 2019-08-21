-----------------
--英雄：痛苦女王
--技能：暗影突袭
--键位：Q
--类型：指向单位
--作者：Halcyon
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('queenofpain_shadow_strike')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList;

nKeepMana = 400 --魔法储量
nLV = bot:GetLevel(); --当前英雄等级
nMP = bot:GetMana()/bot:GetMaxMana(); --目前法力值/最大法力值（魔法剩余比）
nHP = bot:GetHealth()/bot:GetMaxHealth();--目前生命值/最大生命值（生命剩余比）
hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内敌人
hAlleyHeroList = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);--1600范围内队友

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

    -- 获取一些必要参数
	local nCastRange  = ability:GetCastRange();	--施法范围
	local nCastPoint  = ability:GetCastPoint();	--施法点
	local nManaCost   = ability:GetManaCost();		--魔法消耗
    local nSkillLV    = ability:GetLevel();    	--技能等级
    local nIDamage = ability:GetSpecialValueInt( "strike_damage" ); --攻击伤害
	local nDuration = ability:GetSpecialValueInt( "duration_damage" ); --每秒伤害
	local nDOT = ability:GetSpecialValueInt( "duration_damage" ); --点伤害
	local nDamage     = nIDamage + (nDuration * (nDOT / 3));	--技能伤害
    local nDamageType = DAMAGE_TYPE_MAGICAL;		--伤害类型
	
	local nAllies =  bot:GetNearbyHeroes(1200,false,BOT_MODE_NONE); --获取1200范围内盟友
	
    local nEnemysHerosInView  = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE); --获取1600范围内敌人
	local nEnemysHerosInRange = bot:GetNearbyHeroes(nCastRange +50,true,BOT_MODE_NONE);--获得施法范围内敌人
    local nEnemysHerosInBonus = bot:GetNearbyHeroes(nCastRange + 300,true,BOT_MODE_NONE);--获得施法范围+150内敌人
    local nAllies =  bot:GetNearbyHeroes(1200,false,BOT_MODE_NONE);--获得1200范围内友军

    -----------
    --策略部分
    -----------

    --击杀敌人
    for _,npcEnemy in pairs( nEnemysHerosInBonus )
    do
        if J.IsValid(npcEnemy)
        and J.CanCastOnNonMagicImmune(npcEnemy)
        and J.CanCastOnTargetAdvanced(npcEnemy)
        and GetUnitToUnitDistance(bot,npcEnemy) <= nCastRange + 80
        and ( J.CanKillTarget(npcEnemy,nDamage *1.38,nDamageType)
        or ( npcEnemy:IsChanneling() and J.GetHPR(npcEnemy) < 0.25))
        then
            return BOT_ACTION_DESIRE_HIGH, npcEnemy;
        end
    end


    --团战中对血量最低的敌人使用
    if J.IsInTeamFight(bot, 1200)
    then
        local npcWeakestEnemy = nil;
        local npcWeakestEnemyHealth = 10000;		
        
        for _,npcEnemy in pairs( nEnemysHerosInRange )
        do
            if  J.IsValid(npcEnemy)
                and J.CanCastOnNonMagicImmune(npcEnemy) 
                and J.CanCastOnTargetAdvanced(npcEnemy)
            then
                local npcEnemyHealth = npcEnemy:GetHealth();
                if ( npcEnemyHealth < npcWeakestEnemyHealth )
                then
                    npcWeakestEnemyHealth = npcEnemyHealth;
                    npcWeakestEnemy = npcEnemy;
                end
            end
        end
        
        if ( npcWeakestEnemy ~= nil )
        then
            return BOT_ACTION_DESIRE_HIGH, npcWeakestEnemy;
        end		
    end

    --对线期间对线上小兵和敌人使用
    if bot:GetActiveMode() == BOT_MODE_LANING or ( nLV <= 14 and ( nLV <= 7 or bot:GetAttackTarget() == nil ))
    then
        --对线期间对敌人使用
        local nWeakestEnemyLaneCreep = J.GetVulnerableWeakestUnit(false, true, nCastRange +100, bot);
        local nWeakestEnemyLaneHero  = J.GetVulnerableWeakestUnit(true , true, nCastRange +40, bot);
        if nWeakestEnemyLaneCreep == nil 
           or (nWeakestEnemyLaneCreep ~= nil 
           and not J.CanKillTarget(nWeakestEnemyLaneCreep,nDamage *2,nDamageType) )
        then
            if nWeakestEnemyLaneHero ~= nil 
                and ( J.GetHPR(nWeakestEnemyLaneHero) <= 0.48
                    or GetUnitToUnitDistance(bot,nWeakestEnemyLaneHero) < 350 )
            then
                return BOT_ACTION_DESIRE_HIGH, nWeakestEnemyLaneHero;
            end
        end
        
        -- 打断回复
        for _,npcEnemy in pairs( nEnemysHerosInRange )
        do
            if J.IsValid(npcEnemy)
            and J.CanCastOnNonMagicImmune(npcEnemy)
            and GetUnitToUnitDistance(bot,npcEnemy) <= nCastRange + 80
            and ( npcEnemy:HasModifier("modifier_flask_healing") 
                    or npcEnemy:HasModifier("modifier_clarity_potion")
                    or npcEnemy:HasModifier("modifier_bottle_regeneration")
                    or npcEnemy:HasModifier("modifier_rune_regen") )
            then
                return BOT_ACTION_DESIRE_HIGH, npcEnemy;
            end
        end
    end	


    --打架时先手	
    if J.IsGoingOnSomeone(bot)
    then
        local npcTarget = J.GetProperTarget(bot);
        if J.IsValidHero(npcTarget) 
            and J.CanCastOnNonMagicImmune(npcTarget) 
            and J.CanCastOnTargetAdvanced(npcTarget)
            and J.IsInRange(npcTarget, bot, nCastRange + 200) 
        then
            if nSkillLV >= 3 
            or nMP > 0.6 or nHP < 0.4  
            or J.GetHPR(npcTarget) < 0.38 
            or DotaTime() > 6 *60
            then
                return BOT_ACTION_DESIRE_HIGH, npcTarget;
            end
        end
    end


    --撤退时保护自己
    if J.IsRetreating(bot) 
        and #nEnemysHerosInBonus <= 2
    then
        for _,npcEnemy in pairs( nEnemysHerosInRange )
        do
            if  J.IsValid(npcEnemy)
                and bot:WasRecentlyDamagedByHero( npcEnemy, 5.0 ) 
                and J.CanCastOnNonMagicImmune(npcEnemy) 
                and J.CanCastOnTargetAdvanced(npcEnemy)
                and not J.IsDisabled(true, npcEnemy) 
                and ( bot:IsFacingLocation(npcEnemy:GetLocation(),45)
                        or not J.IsInRange(npcEnemy,bot,nCastRange - 300) )
            then
                return BOT_ACTION_DESIRE_HIGH, npcEnemy;
            end
        end
    end

    --打肉的时候输出
    if  bot:GetActiveMode() == BOT_MODE_ROSHAN 
        and bot:GetMana() >= 200
    then
        local npcTarget = bot:GetAttackTarget();
        if  J.IsRoshan(npcTarget) 
            and J.IsInRange(npcTarget, bot, nCastRange)  
        then
            return BOT_ACTION_DESIRE_HIGH, npcTarget;
        end
    end


    --通用消耗敌人或受到伤害时保护自己
    if (#nEnemysHerosInView > 0 or bot:WasRecentlyDamagedByAnyHero(3.0)) 
        and ( bot:GetActiveMode() ~= BOT_MODE_RETREAT or #nAllies >= 2 )
        and #nEnemysHerosInRange >= 1
        and nLV >= 7
    then
        for _,npcEnemy in pairs( nEnemysHerosInRange )
        do
            if  J.IsValid(npcEnemy)
                and J.CanCastOnNonMagicImmune(npcEnemy) 
                and J.CanCastOnTargetAdvanced(npcEnemy)
                and not J.IsDisabled(true, npcEnemy)			
                and bot:IsFacingLocation(npcEnemy:GetLocation(),80)
            then
                return BOT_ACTION_DESIRE_HIGH, npcEnemy
            end
        end
    end
	
	return 0;
end

return X;