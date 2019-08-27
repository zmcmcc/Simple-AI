-----------------
--英雄：潮汐猎人
--技能：巨浪
--键位：Q
--类型：指向单位
--作者：Halcyon
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('tidehunter_gush')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList;

nKeepMana = 180 --魔法储量
nLV = bot:GetLevel(); --当前英雄等级
nMP = bot:GetMana()/bot:GetMaxMana(); --目前法力值/最大法力值（魔法剩余比）
nHP = bot:GetHealth()/bot:GetMaxHealth();--目前生命值/最大生命值（生命剩余比）
hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内敌人
hAlleyHeroList = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);--1600范围内队友

--初始化函数库
U.init(nLV, nMP, nHP, bot);

--技能释放功能
function X.Release(castTarget)
    local abilityR = bot:GetAbilityByName('tidehunter_ravage') 
    if castTarget ~= nil
       and (abilityR == nil or U.ManaR(abilityR ,ability:GetManaCost()))
    then
        X.Compensation()

        if bot:HasScepter() 
		then
			bot:ActionQueue_UseAbilityOnLocation( ability, castTarget:GetLocation() )
		else
			bot:ActionQueue_UseAbilityOnEntity( ability, castTarget )
		end
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
    local nAttackRange = bot:GetAttackRange();
    local nDamage = ability:GetLevel() * 50 + 60;

    if nCastRange > 1500 then nCastRange = 1500 end

    local nEnemysHerosInCastRange = bot:GetNearbyHeroes(nCastRange + 80 ,true,BOT_MODE_NONE);
    local nWeakestEnemyHeroInCastRange = J.GetVulnerableWeakestUnit(true, true, nCastRange + 80, bot);
    local npcTarget = J.GetProperTarget(bot)
    local castRTarget = nil


    if J.IsValid(nEnemysHerosInCastRange[1])
    then
        --最弱目标和当前目标
        if(nWeakestEnemyHeroInCastRange ~= nil)
        then           
            if nWeakestEnemyHeroInCastRange:GetHealth() < nWeakestEnemyHeroInCastRange:GetActualIncomingDamage(nDamage,DAMAGE_TYPE_MAGICAL)
            then				
                castRTarget = nWeakestEnemyHeroInCastRange;
                return BOT_ACTION_DESIRE_HIGH, castRTarget;
            end
            
            if J.IsValidHero(npcTarget)                        
            then
                if J.IsInRange(npcTarget, bot, nCastRange + 80)   
                    and J.CanCastOnMagicImmune(npcTarget)
                then					
                    castRTarget = npcTarget;
                    return BOT_ACTION_DESIRE_HIGH,castRTarget;
                else
                    castRTarget = nWeakestEnemyHeroInCastRange;                    
                    return BOT_ACTION_DESIRE_HIGH,castRTarget;
                end
            end	
        end
        
        if J.CanCastOnMagicImmune(nEnemysHerosInCastRange[1])
        then
            castRTarget = nEnemysHerosInCastRange[1];   
            return BOT_ACTION_DESIRE_HIGH,castRTarget;
        end
    end	


    if bot:GetActiveMode() == BOT_MODE_ROSHAN and bot:HasScepter()
    then
        local nAttackTarget = bot:GetAttackTarget();
        if  nAttackTarget ~= nil and nAttackTarget:IsAlive()
        then
            return BOT_ACTION_DESIRE_HIGH,nAttackTarget;
        end
    end
	
	return 0;
end

return X;