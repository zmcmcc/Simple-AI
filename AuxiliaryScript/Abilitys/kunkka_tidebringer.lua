-----------------
--英雄：昆卡
--技能：潮汐使者
--键位：W
--类型：指向目标
--作者：决明子
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('kunkka_tidebringer')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;

nKeepMana = 240 --魔法储量
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
       or not J.IsRunning(bot) 
       or not ability:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end
	
	local npcTarget = J.GetProperTarget(bot);
	if not J.IsValid(npcTarget) then return 0 end

	local nAttackRange = bot:GetAttackRange() + 40;	
	
	if nAttackRange < 200  then nAttackRange = 200  end
	
	local nNearbyEnemy = X.GetNearbyUnit(bot, npcTarget);
	
	if  J.IsValid(nNearbyEnemy)
		and GetUnitToUnitDistance(npcTarget,bot) >  nAttackRange 		
	then
		return BOT_ACTION_DESIRE_HIGH, nNearbyEnemy
	end
    
    return BOT_ACTION_DESIRE_NONE
end

function X.GetNearbyUnit(bot, npcTarget)
	
	
	if bot:IsFacingLocation(npcTarget:GetLocation(),39)
	then
		local nCreeps = bot:GetNearbyCreeps(240,true);		
		for _,creep in pairs(nCreeps)
		do
			if J.IsValid(creep)
				and bot:IsFacingLocation(creep:GetLocation(),38)
			then
				return creep;
			end
		end	
		
		local nEnemys = bot:GetNearbyHeroes(240,true,BOT_MODE_NONE);
		for _,enemy  in pairs(nEnemys)
		do
			if J.IsValid(enemy)
				and bot:IsFacingLocation(enemy:GetLocation(),38)
			then
				return enemy;
			end
		end		
		
	end


	return nil;
end

return X;