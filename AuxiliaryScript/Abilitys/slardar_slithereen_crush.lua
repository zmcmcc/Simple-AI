-----------------
--英雄：斯拉达
--技能：鱼人碎击
--键位：W
--类型：无目标
--作者：望天的稻草
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('slardar_slithereen_crush')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;

nKeepMana = 160 --魔法储量
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
	
	-- 获取一些必要参数
	local nRadius    = ability:GetSpecialValueInt( "Crush_radius" ); --鱼人踩半径
	local nManaCost  = ability:GetManaCost();		--魔法消耗
	local nSkillLV   = ability:GetLevel();    	--技能等级                     
	local nDamage    = 60 * nSkillLV + 20;	        --技能伤害
    
	local nAlleys =  bot:GetNearbyHeroes(1200,false,BOT_MODE_NONE); --获取1200范围内盟友
	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE ); --获取踩范围内敌人
	local tableNearbyEnemyHeroes2 = bot:GetNearbyHeroes( nRadius - 100, true, BOT_MODE_NONE ); --获取踩范围内敌人
	local nEnemysHerosInView  = bot:GetNearbyHeroes(1200,true,BOT_MODE_NONE); --获取1200范围内敌人
    
	
	--撤退时踩断后
	if J.IsRetreating(bot)
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if bot:WasRecentlyDamagedByHero( npcEnemy, 3.0 ) 
			   and J.CanCastOnNonMagicImmune(npcEnemy)
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	
	--可以击杀时击杀
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes2 )
	do
		if #nAlleys >= 1
		   and J.CanCastOnNonMagicImmune(npcEnemy)
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
 	
	
	--对线期间
	if bot:GetActiveMode() == BOT_MODE_LANING
	   and J.IsValid(bot) 
	then
		if  #tableNearbyEnemyHeroes2 >= 1
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	

	--遭遇
	if J.IsGoingOnSomeone(bot)
	then 
		if  #tableNearbyEnemyHeroes >= 1
		    and J.CanCastOnNonMagicImmune(tableNearbyEnemyHeroes[1])
		then
			return BOT_ACTION_DESIRE_VERYHIGH;
		end
    end
	
	--打钱时使用
	if  J.IsFarming(bot) and nSkillLV >= 2

	then
		local nCreeps = bot:GetNearbyNeutralCreeps(nRadius);
		
		if #nCreeps >= 3
		then
			return BOT_ACTION_DESIRE_HIGH;
	    end
	end
	
	--团战
	if J.IsInTeamFight(bot, 1200)
	then
		--附件有3人以上的敌人，且自己血量不高，优先自己保命
		if #nEnemysHerosInView >= 3
			and J.IsValid(bot)
			and J.CanCastOnNonMagicImmune(bot) 
			and #tableNearbyEnemyHeroes2 >= 1
		 then
			return BOT_ACTION_DESIRE_VERYHIGH;
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end

return X;