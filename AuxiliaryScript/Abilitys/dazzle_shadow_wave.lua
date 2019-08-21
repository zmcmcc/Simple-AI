-----------------
--英雄：戴泽
--技能：暗影波
--键位：E
--类型：指向目标
--作者：Halcyon
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('dazzle_shadow_wave')
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
	
	local nCastRange = ability:GetCastRange();
	local nAllysHerosInCastRange = bot:GetNearbyHeroes(nCastRange + 80 ,false,BOT_MODE_NONE);
	local Enemys = 0;
	local targetally = nil

	for _,npcAlly in pairs( nAllysHerosInCastRange )
	do
		local tableNearbyEnemyHeroes = J.GetAroundTargetEnemyUnitCount(npcAlly, 185);
		local allyHP = npcAlly:GetHealth()/npcAlly:GetMaxHealth();

		if tableNearbyEnemyHeroes ~= nil and
		 tableNearbyEnemyHeroes > 1 or
		 allyHP <= 0.6
		then
			if targetally == nil then
				targetally = npcAlly;
			end
			Enemys = Enemys + 1
		end

		if tableNearbyEnemyHeroes ~= nil and tableNearbyEnemyHeroes >= 2
		then
			if targetally == nil then
				targetally = npcAlly;
			end
			Enemys = Enemys + 2
		end

		if allyHP <= 0.15 and nLV > 14
		then
			return BOT_ACTION_DESIRE_HIGH, npcAlly;
		end
	end

	if targetally ~= nil and nMP > 0.15 then
		if Enemys > 7 then
			return BOT_ACTION_DESIRE_VERYHIGH, targetally;
		elseif Enemys > 5 and nLV >= 6 then
			return BOT_ACTION_DESIRE_HIGH, targetally;
		elseif Enemys > 3 and nMP > 0.3 and nLV >= 10 then
			return BOT_ACTION_DESIRE_MODERATE, targetally;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X;