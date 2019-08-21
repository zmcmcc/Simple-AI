-----------------
--英雄：拉席克
--技能：恶魔敕令
--键位：W
--类型：无目标
--作者：Halcyon
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('leshrac_diabolic_edict')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange, abilityAhg;

nKeepMana = 400 --魔法储量
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

	-- 确保技能可以使用
    if ability == nil
	   or ability:IsNull()
       or not ability:IsFullyCastable()
       or (bot:WasRecentlyDamagedByAnyHero(1.5) and nHP < 0.38)
       or bot:DistanceFromFountain() < 600
	then 
		return BOT_ACTION_DESIRE_NONE; --没欲望
	end
	
	-- Get some of its values
	local nRadius = 500;                          
	
	local nEnemysHerosInSkillRange = bot:GetNearbyHeroes(500,true,BOT_MODE_NONE);
	local nEnemysHerosNearby       = bot:GetNearbyHeroes(300,true,BOT_MODE_NONE);
	

	if #nEnemysHerosInSkillRange >= 3
		or (#nEnemysHerosNearby >= 1 and #nEnemysHerosInSkillRange >= 2)
	then
		return BOT_ACTION_DESIRE_HIGH;
	end		
	
	local nAoe = bot:FindAoELocation( true, true, bot:GetLocation(), 100, 600, 0.8, 0 );
	if nAoe.count >= 3
	then
		return BOT_ACTION_DESIRE_HIGH;
	end	
	
	local npcTarget = J.GetProperTarget(bot);		
	if J.IsValidHero(npcTarget) 
		and J.CanCastOnNonMagicImmune(npcTarget) 
		and ( GetUnitToUnitDistance(npcTarget,bot) <= 350
				or ( J.GetHPR(npcTarget) < 0.38 and  GetUnitToUnitDistance(npcTarget,bot) <= 650 ) )
		and npcTarget:GetHealth() > 600
	then
		return BOT_ACTION_DESIRE_HIGH;
	end
	
	--推塔
	if ( J.IsPushing(bot) or J.IsDefending(bot) ) 
	then
		local towers = bot:GetNearbyTowers(nRadius, true);
		local creeps = bot:GetNearbyLaneCreeps(nRadius, true);
		local barracks = bot:GetNearbyBarracks(nRadius, true);
		if towers[1] ~= nil and not towers[1]:IsInvulnerable() and #creeps < 3
		then
			return BOT_ACTION_DESIRE_HIGH, towers[1];
		end
		if barracks[1] ~= nil and not barracks[1]:IsInvulnerable() and #creeps < 3
		then
			return BOT_ACTION_DESIRE_HIGH, barracks[1];
		end
		if #creeps >= 4 and creeps[1] ~= nil
		then
			return BOT_ACTION_DESIRE_HIGH, creeps[1];
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end

return X;