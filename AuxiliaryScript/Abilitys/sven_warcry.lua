-----------------
--英雄：斯温
--技能：战吼
--键位：E
--类型：无目标
--作者：决明子
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('sven_warcry')
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
    X.Compensation()
    bot:ActionQueue_UseAbility( ability )
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
       or ( #hEnemyHeroList == 0 and nHP > 0.2 )
	then 
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end
    
    local nSkillRange = 700;	          
	
	local nAllies = J.GetAllyList(bot,nSkillRange);
	local nAlliesCount = #nAllies;
	local nWeakestAlly = J.GetLeastHpUnit(nAllies);
	if nWeakestAlly == nil then nWeakestAlly = bot; end
	local nWeakestAllyHP = J.GetHPR(nWeakestAlly);
	
	local nEnemysHerosNearby = nWeakestAlly:GetNearbyHeroes(800,true,BOT_MODE_NONE);
	
	local nBonusPer = (#nEnemysHerosNearby)/20;
	
	local nShouldBonusCount = 1;
	if nWeakestAllyHP > 0.35  + nBonusPer then nShouldBonusCount = nShouldBonusCount + 1 end;
	if nWeakestAllyHP > 0.50  + nBonusPer then nShouldBonusCount = nShouldBonusCount + 1 end;
	if nWeakestAllyHP > 0.65 + nBonusPer then nShouldBonusCount = nShouldBonusCount + 1 end;
	if nWeakestAllyHP > 0.9  + nBonusPer then nShouldBonusCount = nShouldBonusCount + 1 end;
	
	--根据血量决定作用人数
	if nAlliesCount >= nShouldBonusCount
		and #nEnemysHerosNearby >= 1
		and nWeakestAlly:WasRecentlyDamagedByAnyHero(4.0)
	then
--		J.SetReport("当前血量适合套盾",nShouldBonusCount);
		return BOT_ACTION_DESIRE_HIGH;
	end	
	
	--尝试救队友一命
	if J.IsRetreating(nWeakestAlly)
		and nWeakestAlly:GetHealth() < 150
	then
		J.SetReport("尝试救队友一命",nShouldBonusCount);
		return BOT_ACTION_DESIRE_HIGH;
	end		
	
	--打架时追杀	
	if J.IsGoingOnSomeone(bot)
	then
	    local npcTarget = J.GetProperTarget(bot);
		if J.IsValidHero(npcTarget) 
		   and not J.IsInRange(npcTarget,bot,300)
		   and J.IsInRange(npcTarget,bot,600)
		   and bot:IsFacingLocation(npcTarget:GetLocation(),15)
		   and npcTarget:IsFacingLocation(J.GetEnemyFountain(),20)
		then
--			J.SetReport("套盾打架:",npcTarget:GetUnitName());
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
    return BOT_ACTION_DESIRE_NONE;
    
end

return X;