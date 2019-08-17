-----------------
--英雄：全能骑士
--技能：洗礼
--键位：Q
--类型：指向目标
--作者：望天的稻草
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('omniknight_purification')
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
function X.Release(castTarget,compensation)
    if castTarget ~= nil then
        if compensation then X.Compensation() end
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
    if ability ~= nil
       and not ability:IsFullyCastable()
	then 
		return BOT_ACTION_DESIRE_NONE, 0, 0; --没欲望
	end
	
	-- 获取一些必要参数
	local nCastRange  = ability:GetCastRange() + 70 + aetherRange;	--施法范围
	local target      = J.GetProperTarget(bot); --获取目标
	local nManaCost   = ability:GetManaCost(); --魔法消耗
	local nSkillLV    = ability:GetLevel();    --技能等级
	local nDamage     = 70 * nSkillLV  + 20;    --技能伤害
	local nHeal       = 70 * nSkillLV  + 20;    --技能治疗
	local nDamageType = DAMAGE_TYPE_PURE;       --伤害类型
	local nRadius     = ability:GetSpecialValueInt( "radius" ); --治疗伤害半径
	
	local nAlleys =  bot:GetNearbyHeroes(1200,false,BOT_MODE_NONE); --获取1200范围内盟友
	local nEnemysHerosInView  = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE); --获取1200范围内敌人
	
	local nEnemysHerosInRadius = bot:GetNearbyHeroes(nRadius - 70, true, BOT_MODE_NONE);
	
	
	
	--击杀
	for _,npcEnemy in pairs( nEnemysHerosInRadius)
	do
		if J.IsValid(npcEnemy)
		   and J.CanCastOnNonMagicImmune(npcEnemy)
		then
			if  J.CanKillTarget(npcEnemy,nDamage,nDamageType)
			then
				return BOT_ACTION_DESIRE_VERYHIGH, bot; --直接杀死
			end
			
		end
	end
	
		--在团战中
	if J.IsInTeamFight(bot, 1200)
	then
		--附件有3人以上的敌人，且自己血量不高，优先自己保命
		if #nEnemysHerosInView > 3
			and J.IsValid(bot)
			and J.CanCastOnNonMagicImmune(bot) 
			and nHP < 0.6
		 then
			return BOT_ACTION_DESIRE_HIGH, bot;
		end
		--低血量参团，优先自己保命
		if J.IsValid(bot)
			and J.CanCastOnNonMagicImmune(bot)
			and nHP < 0.4
			then
			return BOT_ACTION_DESIRE_HIGH, bot;
		end
		--团队有人血量较低，自己血量充沛，给队友保命
		for _,npcEnemy in pairs( nAlleys )
		do
			npcEnemyHP = npcEnemy:GetHealth()/npcEnemy:GetMaxHealth();--队友血量比
			if  J.IsValid(npcEnemy)
				and J.CanCastOnNonMagicImmune(npcEnemy) 
				and nHP > 0.7
				and npcEnemyHP < 0.5
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	--对线期间对友方英雄使用
	if bot:GetActiveMode() == BOT_MODE_LANING
	then
		for _,npcEnemy in pairs( nAlleys )
		do
		    npcEnemyHP = npcEnemy:GetHealth()/npcEnemy:GetMaxHealth();
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and npcEnemyHP <= 0.7
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end	
	end
	
	--对线期间对自己使用
	if bot:GetActiveMode() == BOT_MODE_LANING
		and J.IsValid(bot)
		and J.CanCastOnNonMagicImmune(bot) 
	then
		if  nHP <= 0.3
		then
			return BOT_ACTION_DESIRE_HIGH, bot;
		elseif nHP <= 0.6
		then
			return BOT_ACTION_DESIRE_MODERATE, bot;
		end
	end
	
	--打钱
	if  J.IsFarming(bot) 
		and nMP > 0.4
	then
		local nCreeps = bot:GetNearbyNeutralCreeps(nRadius);
		if J.IsValid(targetCreep)
			and  #nCreeps >= 2
			and not J.IsOtherAllysTarget(targetCreep)
		then
			return BOT_ACTION_DESIRE_HIGH, bot;
	    end
	end
	
	
	--通用消耗敌人或受到伤害时保护自己
	if  bot:WasRecentlyDamagedByAnyHero(3.0)
		and ( bot:GetActiveMode() ~= BOT_MODE_RETREAT or #nAlleys >= 2 )
		and #nEnemysHerosInRadius >= 1
	then
		return BOT_ACTION_DESIRE_HIGH, bot;
	end
	return 0;
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X;