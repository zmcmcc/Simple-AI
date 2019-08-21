-----------------
--英雄：杰奇洛
--技能：冰封路径
--键位：W
--类型：指向地点
--作者：决明子
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('jakiro_ice_path')
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
	
	local castRange = ability:GetCastRange() +30 + aetherRange 
	local castPoint = ability:GetCastPoint();
	local manaCost  = ability:GetManaCost();
	local nRadius   = ability:GetSpecialValueInt( "path_radius" );
	local nDelay    = ability:GetSpecialValueFloat('path_delay')/2.0;
	local nDamage   = ability:GetSpecialValueInt('damage');
	
	local target  = J.GetProperTarget(bot);
	local enemies = bot:GetNearbyHeroes(castRange + 200, true, BOT_MODE_NONE);
	local hNearEnemyHeroList = bot:GetNearbyHeroes(castRange, true, BOT_MODE_NONE);

	for _,enemy in pairs(enemies)
	do
		if enemy:IsChanneling() then
			return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation();
		end
	end
	
	
	if J.IsRetreating(bot)
	then
		if #enemies > 0 and bot:WasRecentlyDamagedByAnyHero(2.0) then
			local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), castRange - 100, nRadius *1.6, castPoint, 0 );
			if locationAoE.count >= 1 and #hNearEnemyHeroList >= 1
			then
				return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
			end
		end
	end	
	
	
	if ( J.IsPushing(bot) or J.IsDefending(bot) ) and J.IsAllowedToSpam(bot, manaCost)
	then
		local lanecreeps = bot:GetNearbyLaneCreeps(castRange, true);
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), castRange, nRadius, castPoint, 0 );
		if ( locationAoE.count >= 6 and #lanecreeps >= 6  ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end
	
	
	if J.IsInTeamFight(bot, 1300)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), castRange, nRadius, nDelay+castPoint, 0 );
		if locationAoE.count >= 2 and #hNearEnemyHeroList >= 2
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end

	
	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidHero(target) 
		   and J.CanCastOnNonMagicImmune(target) 
		   and J.IsInRange(target, bot, castRange - 200) 
		   and not J.IsDisabled(true, target)
		then
			return BOT_ACTION_DESIRE_HIGH, target:GetExtrapolatedLocation(nDelay + castPoint);
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X;