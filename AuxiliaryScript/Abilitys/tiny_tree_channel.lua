-----------------
--英雄：小小
--技能：树木连掷
--键位：D
--类型：指向地点
--作者：Halcyon
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')
--前置技能

--初始数据
local ability = bot:GetAbilityByName('tiny_tree_channel')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;
local goTrees = nil

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
        if goTrees ~= nil then
            bot:ActionQueue_MoveDirectly( goTrees )
        end
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
    if ConsiderStop() == true 
	then 
		bot:Action_ClearActions(true);
		return BOT_ACTION_DESIRE_NONE, 0; 
	end
	-- 确保技能可以使用
    if ability == nil
	   or ability:IsNull()
       or not ability:IsFullyCastable()
       or ability:IsHidden()
	then 
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end
    
    --获取树木地点
    local nGrabRadius = 525;
    local nTreesList = bot:GetNearbyTrees(1600)
    local nNearTreesList = bot:GetNearbyTrees(nGrabRadius)

    if #nTreesList > 5 
       and not ConsiderStop()
    then
        goTrees = GetTreeLocation(nTreesList[1])
    else
        goTrees = nil
    end

    if #nNearTreesList > 4 then
        goTrees = nil
    end

	local nCastRange = ability:GetCastRange();
	local nCastPoint = ability:GetCastPoint();
	local manaCost   = ability:GetManaCost();
	local nRadius    = 400;
	
	if J.IsInTeamFight(bot, 1200)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius/2, 0, 0 );
		if ( locationAoE.count >= 1 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end

	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = J.GetProperTarget(bot);
		if J.IsValidHero(npcTarget) 
		   and J.CanCastOnNonMagicImmune(npcTarget) 
		   and J.IsInRange(npcTarget, bot, nCastRange) 
		then
			local enemies = npcTarget:GetNearbyHeroes(nRadius, false, BOT_MODE_NONE);
			if #enemies >= 1 then
				return BOT_ACTION_DESIRE_HIGH, npcTarget:GetExtrapolatedLocation(nCastPoint);
			end	
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
	
end

function ConsiderStop()
    
    local nNearTreesList = bot:GetNearbyTrees(525)

    if bot:IsChanneling()
       and not bot:HasModifier("modifier_teleporting")
       and #nNearTreesList > 0
	then
		return true;
	end

	return false;
end

return X;
