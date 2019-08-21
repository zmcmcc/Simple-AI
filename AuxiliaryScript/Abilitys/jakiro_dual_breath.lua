-----------------
--英雄：杰奇洛
--技能：冰火交加
--键位：Q
--类型：指向地点
--作者：决明子
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('jakiro_dual_breath')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;

nKeepMana = 400 --魔法储量
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
	then 
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end
	
	local castRange = ability:GetCastRange() + 100 + aetherRange 
	local castPoint = ability:GetCastPoint();
	local manaCost  = ability:GetManaCost();
	local nRadius   = ability:GetSpecialValueInt( "start_radius" );
	local nDuration = ability:GetDuration();
	local nSpeed    = ability:GetSpecialValueInt('speed');
	local nDamage   = ability:GetSpecialValueInt('burn_damage');
	
	local target  = J.GetProperTarget(bot);
	local enemies = bot:GetNearbyHeroes(castRange, true, BOT_MODE_NONE);
	
	if J.IsGoingOnSomeone(bot) and #enemies == 1
	then
		local castRangetarget = ability:GetCastRange() + 128 + aetherRange

		if J.IsValidHero(target) 
		   and J.CanCastOnNonMagicImmune(target) 
		   and J.IsInRange(target, bot, castRangetarget) 
		then
			return BOT_ACTION_DESIRE_HIGH, target:GetLocation();
		end
	end

	if J.IsRetreating(bot)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), castRange - 100, nRadius *1.6, castPoint, 0 );
		if locationAoE.count >= 2 and #enemies >= 2
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end	
	
	if ( J.IsPushing(bot) or J.IsDefending(bot) ) and J.IsAllowedToSpam(bot, manaCost)
	then
		local lanecreeps = bot:GetNearbyLaneCreeps(castRange, true);
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), castRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 4 and #lanecreeps >= 4  ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	if J.IsInTeamFight(bot, 1300)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), castRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2 and #enemies >= 2 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end

	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidHero(target) 
		   and J.CanCastOnNonMagicImmune(target) 
		   and J.IsInRange(target, bot, castRange - 200) 
		then
			return BOT_ACTION_DESIRE_HIGH, target:GetExtrapolatedLocation(castPoint + 0.3);
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X;