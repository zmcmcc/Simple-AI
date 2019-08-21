-----------------
--英雄：帕克
--技能：梦境缠绕
--键位：R
--类型：指向地点
--作者：Halcyon
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('puck_dream_coil')
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
       or not ability:IsFullyCastable()
	then 
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end
	
	-- Get some of its values
	local nCastRange = ability:GetCastRange();
	local nInitDamage = ability:GetSpecialValueInt( "coil_init_damage_tooltip" );
	local nBreakDamage = ability:GetSpecialValueInt( "coil_break_damage" );
	local nRadius = ability:GetSpecialValueInt( "coil_radius" );

	-- If enemy is channeling cancel it
	local npcTarget = npcTarget;
	if (npcTarget ~= nil and npcTarget:IsChanneling() and GetUnitToUnitDistance( npcTarget, bot ) < ( nCastRange + nRadius ))
	then
		return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation();
	end
	-- If a mode has set a target, and we can kill them, do it
	if ( npcTarget ~= nil and J.CanCastOnNonMagicImmune( npcTarget ) )
	then
		if ( npcTarget:GetActualIncomingDamage( nInitDamage + nBreakDamage, 2 ) > npcTarget:GetHealth() and GetUnitToUnitDistance( npcTarget, bot ) < ( nCastRange + nRadius ) )
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation();
		end
	end

	-- If we're in a teamfight, use it on the scariest enemy
	local tableNearbyAttackingAlliedHeroes = bot:GetNearbyHeroes( 1000, false, BOT_MODE_ATTACK );
	if ( #tableNearbyAttackingAlliedHeroes >= 2 ) 
	then

		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 );

		if ( locationAoE.count >= 2 ) 
		then
			return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
		end
	end

	-- If an enemy is under our tower...
	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange + nRadius, true, BOT_MODE_NONE );
	local tableNearbyFriendlyTowers = bot:GetNearbyTowers( 1300, false );
	if tower ~= nil then
		for _,npcTarget in pairs(tableNearbyEnemyHeroes) do
			if ( GetUnitToUnitDistance( npcTarget, tower ) < 1100 ) 
			then
				if(npcTarget:IsFacingUnit( tower, 15 ) and npcTarget:HasModifier("modifier_puck_coiled") ) then
					return BOT_ACTION_DESIRE_MODERATE, bot:IsFacingLocation( npcTarget:GetLocation(), nCastRange - 1);
				end
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X;