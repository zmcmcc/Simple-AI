-----------------
--英雄：帕克
--技能：灵动之翼
--键位：D
--类型：无目标
--前置：puck_illusory_orb
--作者：Halcyon
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')
--前置技能
local Q = require( GetScriptDirectory()..'/AuxiliaryScript/Abilitys/puck_illusory_orb')

--初始数据
local ability = bot:GetAbilityByName('puck_ethereal_jaunt')
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
       or not ability:IsFullyCastable()
	then 
		return BOT_ACTION_DESIRE_NONE; --没欲望
	end
	
	if ( bot:GetActiveMode() == BOT_MODE_ROAM or
		 bot:GetActiveMode() == BOT_MODE_ATTACK or
		 bot:GetActiveMode() == BOT_MODE_GANK or
		 bot:GetActiveMode() == BOT_MODE_DEFEND_ALLY ) 
	then
		local npcTarget = npcTarget;
		if ( npcTarget ~= nil ) then
			local pro = GetLinearProjectiles();
			for _,pr in pairs(pro)
			do
				if pr.ability:GetName() == "puck_illusory_orb" then
					local ProjDist = GetUnitToLocationDistance(npcTarget, pr.location);
					if ProjDist < pr.radius then
						return BOT_ACTION_DESIRE_MODERATE;
					end
				end	
			end
		end
		
	end
	
	if ( bot:GetActiveMode() == BOT_MODE_RETREAT and bot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH ) 
	then
		local pro = GetLinearProjectiles();
		for _,pr in pairs(pro)
		do
			if pr.ability:GetName() == "puck_illusory_orb" then
				local ProjDist = GetDistance(Q.illuOrbLoc, pr.location);
				if ProjDist < 100 then
					return BOT_ACTION_DESIRE_MODERATE;
				end
			end	
		end	
    end
    
	return BOT_ACTION_DESIRE_NONE;

end

function GetDistance(s, t)
    return math.sqrt((s[1]-t[1])*(s[1]-t[1]) + (s[2]-t[2])*(s[2]-t[2]));
end

return X;