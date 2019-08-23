-----------------
--英雄：天穹守望者
--技能：风暴双雄
--键位：R
--类型：无目标
--作者：决明子
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('arc_warden_tempest_double')
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

    X.UpdateDoubleStatus();

	-- 确保技能可以使用
    if ability == nil
	   or ability:IsNull()
       or not ability:IsFullyCastable()
	then 
		return BOT_ACTION_DESIRE_NONE; --没欲望
	end

    -- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if  J.IsDefending(bot) or J.IsPushing(bot) or J.IsGoingOnSomeone(bot) or bot:GetActiveMode() == BOT_MODE_FARM
	then
		local tableNearbyEnemyCreeps = bot:GetNearbyLaneCreeps( 800, true );
		local tableNearbyEnemyTowers = bot:GetNearbyTowers( 800, true );
		local tableNaturalCreeps     = bot:GetNearbyCreeps(800,true);
		if ( tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 2 ) 
		    or ( tableNearbyEnemyTowers ~= nil and #tableNearbyEnemyTowers >= 1 ) 
			or ( tableNaturalCreeps ~= nil and #tableNaturalCreeps >= 2 ) 
		then
			return BOT_ACTION_DESIRE_LOW;
		end
	end


	if J.IsInTeamFight(bot, 1200)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if J.IsValid(npcEnemy) and J.IsInRange(npcEnemy, bot, 1000)
			then
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	
	if J.IsRetreating(bot) 
	then
		local nEnemyHeroes   = bot:GetNearbyHeroes( 800, true, BOT_MODE_NONE  );
		local npcEnemy = nEnemyHeroes[1];
		if J.IsValid(npcEnemy) 
			and (J.GetHPR(bot) > 0.35 or #nEnemyHeroes <= 1)
			and bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) 
			and J.GetHPR(bot) > 0.25
			and #nEnemyHeroes <= 2
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end  
	end
	
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if J.IsValidHero(npcTarget) and J.IsInRange(npcTarget, bot, 1000) 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	local midas = J.GetComboItem(bot, "item_hand_of_midas")
	if midas ~= nil
	   and X.IsDoubleMidasCooldown()
	   and bot:DistanceFromFountain() > 600
	then
		local nCreeps = bot:GetNearbyCreeps(1600,true);
		if #nCreeps >= 1 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end

function X.IsDoubleMidasCooldown()
	
	if npcDouble == nil then X.UpdateDoubleStatus() end
	
	if npcDouble ~= nil
	then
		local midas = J.GetComboItem(npcDouble, "item_hand_of_midas")
		if midas ~= nil 
			and (midas:IsFullyCastable() or midas:GetCooldownTimeRemaining() <= 3.0 ) 
		then
			return true;
		end
	end

	return false;
end

function X.UpdateDoubleStatus()
	if npcDouble == nil 
		and bot:GetLevel() >= 6
	then
		local nHeroes = bot:GetNearbyHeroes(1600,false,BOT_MODE_NONE);
		for _,hero in pairs(nHeroes)
		do
			if hero ~= nil and hero:IsAlive()
			   and hero:HasModifier("modifier_arc_warden_tempest_double")
			then
				npcDouble = hero;
			end
		end
	end
end

return X;