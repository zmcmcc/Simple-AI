-----------------
--英雄：虚空假面
--技能：时间结界
--键位：R
--类型：指向地点
--作者：Halcyon
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('faceless_void_chronosphere')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;

nKeepMana = 180 --魔法储量
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
	
	-- Get some of its values
	local nRadius = ability:GetSpecialValueInt("radius");
	local nCastRange = ability:GetCastRange();

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange+(nRadius/2), true, BOT_MODE_NONE );
		local tableNearbyAllyHeroes = bot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
		if tableNearbyAllyHeroes ~= nil and  #tableNearbyAllyHeroes >= 2 then
			for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
			do
				if bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) 
				then
					local allies = J.GetAlliesNearLoc(npcEnemy:GetLocation(), nRadius);
					if #allies <= 2 then
						return BOT_ACTION_DESIRE_LOW, npcEnemy:GetLocation();
					end	
				end
			end
		end
	end
	
	if J.IsInTeamFight(bot, 1200)
	then
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius/2, 0, 0 );
		if ( locationAoE.count >= 2 ) then
			local nInvUnit = J.GetInvUnitInLocCount(bot, nCastRange, nRadius/2, locationAoE.targetloc, true);
			if nInvUnit >= locationAoE.count then
				local allies = J.GetAlliesNearLoc(locationAoE.targetloc, nRadius);
				if #allies <= 2 then
					return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
				end
			end
		end
	end
	
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if ( J.IsValidHero(npcTarget) and J.CanCastOnMagicImmune(npcTarget) and J.IsInRange(npcTarget, bot, nCastRange+(nRadius/2)) )   
		then
			local tableNearbyEnemyHeroes = npcTarget:GetNearbyHeroes( nRadius/2, false, BOT_MODE_NONE );
			local nInvUnit = J.GetInvUnitCount(true, tableNearbyEnemyHeroes);
			if nInvUnit >= 2 then
				local allies = J.GetAlliesNearLoc(npcTarget:GetLocation(), nRadius);
				if #allies <= 2 then
					return BOT_ACTION_DESIRE_MODERATE, npcTarget:GetLocation();
				end
			end
		end
	end
    
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X;