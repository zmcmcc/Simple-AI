-----------------
--英雄：拉比克
--技能：技能窃取
--键位：R
--类型：指向目标
--作者：Halcyon
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('rubick_spell_steal')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;
local castUltDelay = 0;
local castUltTime = -90;

nKeepMana = 300 --魔法储量
nLV = bot:GetLevel(); --当前英雄等级
nMP = bot:GetMana()/bot:GetMaxMana(); --目前法力值/最大法力值（魔法剩余比）
nHP = bot:GetHealth()/bot:GetMaxHealth();--目前生命值/最大生命值（生命剩余比）
hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内敌人
hAlleyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内队友

--获取以太棱镜施法距离加成
local aether = J.IsItemAvailable("item_aether_lens");
if aether ~= nil then aetherRange = 250 else aetherRange = 0 end

--初始化函数库
U.init(nLV, nMP, nHP, bot);

--技能释放功能
function X.Release(castTarget)
    print('rubick_spell_steal')
    if castTarget ~= nil then
        X.Compensation() 
        bot:ActionQueue_UseAbilityOnEntity( ability, castTarget ) --使用技能
        castUltTime = DotaTime();
    end
end

--补偿功能
function X.Compensation()
    J.SetQueuePtToINT(bot, true)--临时补充魔法，使用魂戒
end

--偷取的技能
function X.StealingAbility()
    local sAbilityList = J.Skill.GetAbilityList(bot)
    return bot:GetAbilityByName(sAbilityList[4])
end

--技能释放欲望
function X.Consider()

	-- 确保技能可以使用
    if ability ~= nil
       and (not ability:IsFullyCastable() or DotaTime() - castUltTime <= castUltDelay)
	then
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end
    
    local StealingAbility = X.StealingAbility();

    if not string.find(StealingAbility:GetName(), 'empty') and not StealingAbility:IsToggle() and StealingAbility:IsFullyCastable() then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    -- Get some of its values
    local nCastRange = ability:GetCastRange();
    local projSpeed = ability:GetSpecialValueInt('projectile_speed')
    --------------------------------------
    -- Mode based usage
    --------------------------------------

    -- If we're going after someone
    if J.IsGoingOnSomeone(bot)
    then
        local npcTarget = bot:GetTarget();
        if J.IsValidHero(npcTarget) and J.CanCastOnNonMagicImmune(npcTarget) and J.IsInRange(npcTarget, bot, nCastRange + 200) 
        then
            castUltDelay = GetUnitToUnitDistance(bot, npcTarget) / projSpeed + ( 2*0.1 ); 
            return BOT_ACTION_DESIRE_HIGH, npcTarget;
        end
    end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X;