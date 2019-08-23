-----------------
--英雄：龙骑士
--技能：古龙形态
--键位：R
--类型：无目标
--作者：决明子
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('dragon_knight_elder_dragon_form')
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
       or J.GetHPR(bot) < 0.25
	then 
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end

    -- Get some of its values
	local nCastPoint = ability:GetCastPoint( );
	local nManaCost  = ability:GetManaCost( );

	-- If We're pushing or defending
	if ( J.IsPushing(bot) or J.IsFarming(bot) or J.IsDefending(bot) ) 
	then
		local tableNearbyEnemyCreeps = bot:GetNearbyCreeps( 800, true );
		local tableNearbyTowers = bot:GetNearbyTowers( 800, true );
		if #tableNearbyEnemyCreeps >= 2 or #tableNearbyTowers >= 1 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = J.GetProperTarget(bot);
		if J.IsValidHero(npcTarget) 
		   and J.IsInRange(npcTarget, bot, 800)
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
    return BOT_ACTION_DESIRE_NONE;
    
end

return X;