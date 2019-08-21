-----------------
--英雄：血魔
--技能：割裂
--键位：R
--类型：指向目标
--作者：决明子
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('bloodseeker_rupture')
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
	
	-- Get some of its values
	local nCastRange   = ability:GetCastRange();
	local nCastPoint   = ability:GetCastPoint();
	local nManaCost    = ability:GetManaCost();
	
	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange +200, true, BOT_MODE_NONE );
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot) 
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if bot:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) 
			   and J.CanCastOnMagicImmune( npcEnemy )
			   and J.CanCastOnTargetAdvanced(npcEnemy)
			   and not npcEnemy:HasModifier('modifier_bloodseeker_bloodrage')
			then
				return BOT_ACTION_DESIRE_MODERATE, npcEnemy;
			end
		end
	end

	if J.IsInTeamFight(bot, 1200)
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if J.CanCastOnMagicImmune(npcEnemy) 
			   and J.CanCastOnTargetAdvanced(npcEnemy)
			   and J.Role.IsCarry(npcEnemy:GetUnitName()) 
			   and not npcEnemy:HasModifier('modifier_bloodseeker_bloodrage')
			   and not J.IsDisabled(true, npcEnemy) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = J.GetProperTarget(bot);
		if J.IsValidHero(npcTarget) 
		   and J.CanCastOnMagicImmune(npcTarget)
		   and J.CanCastOnTargetAdvanced(npcTarget)
		   and J.IsInRange(npcTarget, bot, nCastRange +100)
		   and not npcTarget:HasModifier('modifier_bloodseeker_bloodrage')
		   and not J.IsDisabled(true, npcTarget)
		then
			local allies = npcTarget:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
			if ( allies ~= nil and #allies >= 2 )
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X;