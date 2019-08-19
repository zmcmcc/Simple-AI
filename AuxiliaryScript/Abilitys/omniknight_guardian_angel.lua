-----------------
--英雄：全能骑士
--技能：守护天使
--键位：R
--类型：无目标
--作者：望天的稻草
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('omniknight_guardian_angel')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange, abilityAhg;

nKeepMana = 300 --魔法储量
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
       or not ability:IsFullyCastable()
	then 
		return BOT_ACTION_DESIRE_NONE; --没欲望
	end
	
	local manaCost   = ability:GetManaCost();
	local hTrueHeroList = J.GetEnemyList(bot,1400);
	local nAllieslowhp = 0;
	local nAlleys =  bot:GetNearbyHeroes(1200,false,BOT_MODE_NONE); --获取1200范围内盟友
	local nEnemysHerosInView  = bot:GetNearbyHeroes(1200,true,BOT_MODE_NONE); --获取1200范围内敌人
	
	for _,npcAlly in pairs( nAlleys )
	do
		if npcAlly ~= nil
           and J.IsValidHero(npcAlly)
           and J.CanCastOnNonMagicImmune(npcAlly)
           and J.GetHPR(npcAlly) <= 0.45
        then
            nAllieslowhp = nAllieslowhp + 1;
        end
    end
        
	if #nAlleys >= 4
	   or nAllieslowhp >= 2
	   or #nEnemysHerosInView >= 3
	then 
	   return BOT_ACTION_DESIRE_HIGH;
    end
    
    if not ability:IsFullyCastable() 
	   or abilityAhg == nil
	   or not abilityef:IsFullyCastable()
	then 
		return BOT_ACTION_DESIRE_NONE, nil; 
	end
	
	local base = bot:GetAncient(GetTeam());

    if abilityAhg ~= nil
       and base:WasRecentlyDamagedByAnyHero(3.0)
    then 
        return BOT_ACTION_DESIRE_VERYHIGH;
    end

	return BOT_ACTION_DESIRE_NONE;

end

return X;