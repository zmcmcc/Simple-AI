-----------------
--英雄：暗影恶魔
--技能：释放暗影毒
--键位：D
--类型：无目标
--作者：Halcyon
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('shadow_demon_shadow_poison_release')
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
	then 
		return BOT_ACTION_DESIRE_NONE; --没欲望
	end
	
	local nSkillLV = ability:GetLevel()

	local gEnemies = GetUnitList(UNIT_LIST_ENEMY_HEROES);
	for _,npcEnemy in pairs( gEnemies )
	do
		local nStack = 0
		local nPoisonDamage = 0
		local modIdx = npcEnemy:GetModifierByName("modifier_shadow_demon_shadow_poison");
		if modIdx > -1 then
			nStack = npcEnemy:GetModifierStackCount(modIdx);
		end

		if nStack <= 5 then
			nPoisonDamage = (5 + (nSkillLV * 15)) * 2^(nStack - 1)
		else
			nPoisonDamage = ((5 + (nSkillLV * 15)) * 16) + (50 * (nStack - 5))
		end

		if npcEnemy:GetHealth() < nPoisonDamage then
			return BOT_ACTION_DESIRE_HIGH
		end

	end

	if nHP < 0.05 then
		return BOT_ACTION_DESIRE_HIGH
	end
	
	return BOT_ACTION_DESIRE_NONE;
	
end

return X;