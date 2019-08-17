-----------------
--英雄：斯拉达
--技能：守卫冲刺
--键位：Q
--类型：无目标
--作者：望天的稻草
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('slardar_sprint')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;

nKeepMana = 160 --魔法储量
nLV = bot:GetLevel(); --当前英雄等级
nMP = bot:GetMana()/bot:GetMaxMana(); --目前法力值/最大法力值（魔法剩余比）
nHP = bot:GetHealth()/bot:GetMaxHealth();--目前生命值/最大生命值（生命剩余比）
hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内敌人
hAlleyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内队友

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
    if ability ~= nil
       and not ability:IsFullyCastable()
	then 
		return BOT_ACTION_DESIRE_NONE; --没欲望
	end
	
	-- 获取一些必要参数
	local nSkillLV    = ability:GetLevel();    	--技能等级 
	
	--获取一些单位信息
	local nAlleys =  bot:GetNearbyHeroes(1200,false,BOT_MODE_NONE); 		  --获取1200范围内盟友
	local nEnemysHerosInView  = bot:GetNearbyHeroes(1200,true,BOT_MODE_NONE); --获取1200范围内敌人
	
	
	
	--击杀
	for _,npcEnemy in pairs( nEnemysHerosInView )
	do
		if J.IsValid(npcEnemy)--单位还活着
		   and J.CanCastOnNonMagicImmune(npcEnemy)--不处于魔免或无敌状态
		then
			--如果在追击（200且自己血量大于30%）时
			if  GetUnitToUnitDistance(bot,npcEnemy) <= 200 
				and bot:GetHealth() /bot:GetMaxHealth() >= 0.3
			then
				return BOT_ACTION_DESIRE_HIGH; --追杀
			end
			--如果敌方单位在TP，无脑开冲，满足条件后可以接踩
			if npcEnemy:IsChanneling()
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
			
		end
	end
	

	
    -- 过河道接近敌方基地
	if J.IsInEnemyArea(bot)
	then
		local nEnemies = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
		local nAllies  = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
		local nEnemyTowers = bot:GetNearbyTowers(1600,true);
		if #nEnemies == 0 or nEnemyTowers == 0
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	
	--对线期间对自己使用
	if bot:GetActiveMode() == BOT_MODE_LANING
		and J.IsValid(bot) 
	then
		if  nHP <= 0.3
		then
			return BOT_ACTION_DESIRE_HIGH;
		elseif nHP <= 0.6
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	--打架时先手	
	if J.IsGoingOnSomeone(bot)
	then 
	
	    local nEnemysHerosInView = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE); --Enemy within 1200 range

		if nEnemysHerosInView ~= nil and #nEnemysHerosInView >= 1
        then
             return BOT_ACTION_DESIRE_HIGH;
        end
    end		 
	
	--打钱时使用
	if  J.IsFarming(bot) and nSkillLV >= 2

	then
		local nCreeps = bot:GetNearbyNeutralCreeps(300);
		
		local targetCreep = J.GetMostHpUnit(nCreeps);
		
		if J.IsValid(targetCreep)
			and GetUnitToUnitDistance(targetCreep,bot) > 100
			and not J.IsOtherAllysTarget(targetCreep)
		then
			return BOT_ACTION_DESIRE_HIGH;
	    end
	end
	
	--受到伤害时保护自己
	local nEnemies = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	local nAllies  = bot:GetNearbyHeroes(1600,false,BOT_MODE_NONE);
	if (#nEnemies >= 1 and bot:WasRecentlyDamagedByAnyHero(3.0)) 
		and not bot:IsInvisible()
	then
		for _,npcEnemy in pairs( nEnemysHerosInView )
		do
			if  J.IsValid(npcEnemy)
				and not J.IsDisabled(true, npcEnemy)
                and not npcEnemy:IsDisarmed()				
			then
				return BOT_ACTION_DESIRE_HIGH; 
			end
		end
	end
	
    --低血量参团，优先自己保命
	if J.IsInTeamFight(bot, 1200)
	then
		if J.IsValid(bot)
			and J.CanCastOnNonMagicImmune(bot)
			and nHP < 0.4
			then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end

return X;