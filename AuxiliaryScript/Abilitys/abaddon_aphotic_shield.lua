-----------------
--英雄：亚巴顿
--技能：无光之盾
--键位：W
--类型：指向目标
--作者：Halcyon
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('abaddon_aphotic_shield')
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
    if castTarget ~= nil then
        X.Compensation()
		bot:ActionQueue_UseAbilityOnEntity( ability, castTarget ) --使用技能
		local nEnemysHerosInRange = bot:GetNearbyHeroes(1000,true,BOT_MODE_NONE);
		if nHP >= 0.5
		   and #nEnemysHerosInRange < 4 
		then --血量大于0.5就追击附近强者
			local npcMostDangerousEnemy = nil;
			local nMostDangerousDamage = 0;		
			
			for _,npcEnemy in pairs( nEnemysHerosInRange )
			do
				if  J.IsValid(npcEnemy)
					and not J.IsDisabled(true, npcEnemy)
					and not npcEnemy:IsDisarmed()
					and npcEnemy:IsHero()
				then
					local npcEnemyDamage = npcEnemy:GetEstimatedDamageToTarget( false, bot, 3.0, DAMAGE_TYPE_PHYSICAL );
					if ( npcEnemyDamage > nMostDangerousDamage )
					then
						nMostDangerousDamage = npcEnemyDamage;
						npcMostDangerousEnemy = npcEnemy;
					end
				end
			end
			
			if ( npcMostDangerousEnemy ~= nil )
			then
				bot:SetTarget(npcMostDangerousEnemy);
			end	
		end
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
       or bot:IsRooted()
	   or bot:HasModifier("modifier_abaddon_aphotic_shield") --有盾了
	   or bot:HasModifier("modifier_abaddon_borrowed_time") --开大了
	then
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end
	
	--获取一些参数
	local nCastRange = ability:GetCastRange();		--施法范围
	local nCastPoint = ability:GetCastPoint();		--施法点
	local nManaCost   = ability:GetManaCost();		--魔法消耗
	local nSkillLV    = ability:GetLevel();    	--技能等级 

	--一些单位
	local nAlleys =  bot:GetNearbyHeroes(nCastRange,false,BOT_MODE_NONE); --获取技能范围内盟友
	local nEnemysHerosInView  = bot:GetNearbyHeroes(1200,true,BOT_MODE_NONE); --获取1200范围内敌人
	local nEnemysHerosInRange = bot:GetNearbyHeroes(nCastRange ,true,BOT_MODE_NONE); --获得施法范围内敌人
	
	--在团战中
	if J.IsInTeamFight(bot, 1200)
	then
		--附件有3人以上的敌人，且自己血量不高，优先自己保命
		if #nEnemysHerosInView > 3
			and J.IsValid(bot)
			and J.CanCastOnNonMagicImmune(bot) 
			and nHP < 0.8
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
				and npcEnemyHP < 0.4
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
		--魔法充裕，给自己套个套子
		if nMP > 0.7 then
				if nHP >= 0.7
					and #nEnemysHerosInView < 4 then --血量大于0.7就追击附近强者
					local npcMostDangerousEnemy = nil;
					local nMostDangerousDamage = 0;		
					
					for _,npcEnemy in pairs( nEnemysHerosInRange )
					do
						if  J.IsValid(npcEnemy)
							and J.CanCastOnNonMagicImmune(npcEnemy) 
							and not J.IsDisabled(true, npcEnemy)
							and not npcEnemy:IsDisarmed()
						then
							local npcEnemyDamage = npcEnemy:GetEstimatedDamageToTarget( false, bot, 3.0, DAMAGE_TYPE_PHYSICAL );
							if ( npcEnemyDamage > nMostDangerousDamage )
							then
								nMostDangerousDamage = npcEnemyDamage;
								npcMostDangerousEnemy = npcEnemy;
							end
						end
					end
					
					if ( npcMostDangerousEnemy ~= nil )
					then
						bot:SetTarget(npcMostDangerousEnemy);
					end	
				end
			return BOT_ACTION_DESIRE_HIGH, bot;
		end	
	end
	--遭遇战
	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValid(bot)
			and #nEnemysHerosInView > 3
			and J.CanCastOnNonMagicImmune(bot) 
			and nHP < 0.7
		 then
			return BOT_ACTION_DESIRE_HIGH, bot;
		end
		for _,npcEnemy in pairs( nAlleys )
		do
			npcEnemyHP = npcEnemy:GetHealth()/npcEnemy:GetMaxHealth();--队友血量比
			if  J.IsValid(npcEnemy)
				and J.CanCastOnNonMagicImmune(npcEnemy) 
				and nHP > 0.7
				and npcEnemyHP < 0.4
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
		if J.IsValid(bot)
			and J.CanCastOnNonMagicImmune(bot)
			and nMP > 0.6
			then
			return BOT_ACTION_DESIRE_HIGH, bot;
		end	
	end

	--对线期间对自己使用
	if bot:GetActiveMode() == BOT_MODE_LANING or nLV <= 5
	then
		if  nMP >= 0.6
			and #nEnemysHerosInView > 5
			and J.IsValid(bot)
		    and J.CanCastOnNonMagicImmune(bot) 
			and not J.IsDisabled(true, bot)
		then
			return BOT_ACTION_DESIRE_HIGH, bot;
		end
	end

	--受到伤害时保护自己
	if bot:WasRecentlyDamagedByAnyHero(3.0) 
		and bot:GetActiveMode() ~= BOT_MODE_RETREAT
		and not bot:IsInvisible()
		and #nEnemysHerosInRange >= 1
		and nLV >= 6
	then
		for _,npcEnemy in pairs( nEnemysHerosInRange )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and not J.IsDisabled(true, npcEnemy)
                and not npcEnemy:IsDisarmed()				
				and bot:IsFacingLocation(npcEnemy:GetLocation(),45)
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end

	--撤退时不顾一切先保命
	if J.IsRetreating(bot) 
		and not bot:IsInvisible()
	then
		for _,npcEnemy in pairs( nAlleys )
		do
			npcEnemyHP = npcEnemy:GetHealth()/npcEnemy:GetMaxHealth();--队友血量比
			if  J.IsValid(npcEnemy)
				and J.CanCastOnNonMagicImmune(npcEnemy) 
				and nHP > 0.8
				and npcEnemyHP < 0.2
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
		if J.IsValid(bot)
		    and J.CanCastOnNonMagicImmune(bot)
		then
			return BOT_ACTION_DESIRE_HIGH, bot;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X;