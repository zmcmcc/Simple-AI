-----------------
--英雄：剃刀
--技能：等离子场
--键位：Q
--类型：无目标
--作者：决明子
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('razor_plasma_field')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange, abilityAhg;

nKeepMana = 280 --魔法储量
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
	then 
		return BOT_ACTION_DESIRE_NONE; --没欲望
	end
    
    local nSkillLV    = ability:GetLevel(); 
	local nCastRange  = 777
	local nCastPoint  = ability:GetCastPoint()
	local nManaCost   = ability:GetManaCost()
	local nDamage     = ability:GetAbilityDamage()
	local nDamageMin  = ability:GetSpecialValueInt('damage_min')
	local nDamageMax  = ability:GetSpecialValueInt('damage_max')
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
	
	--团战和击杀
	for _,npcEnemy in pairs(nInRangeEnemyList)
	do
		if J.IsValidHero(npcEnemy)
		   and J.CanCastOnMagicImmune(npcEnemy)
		then
		
			--击杀
			local nDist = GetUnitToUnitDistance(bot,npcEnemy)
			local nDamage = RemapValClamped(nDist, 0, nCastRange, nDamageMin, nDamageMax) *2;
			if J.WillMagicKillTarget(bot,npcEnemy,nDamage,nCastPoint + nDist /636)
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
			
			--打断大药
			if npcEnemy:HasModifier("modifier_flask_healing") 
			   and J.GetModifierTime(npcEnemy,'modifier_flask_healing') > 3.0
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
			
			--撤退
			if J.IsRetreating(bot)
			   and ( bot:WasRecentlyDamagedByHero(npcEnemy,2.0) or bot:GetActiveModeDesire() > BOT_MODE_DESIRE_VERYHIGH )
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
			
			--打架
			if J.IsGoingOnSomeone(bot)
			   and J.IsValidHero(botTarget)
			   and J.IsInRange(bot,botTarget,nCastRange)
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
						
		end
	end
	
	--推线
	if ( J.IsPushing(bot) or J.IsDefending(bot) or J.IsFarming(bot) ) 
	   and #hAllyList < 3 and nLV > 7
	   and J.IsAllowedToSpam(bot, nManaCost)
	then
		local nCanKillCount = 0;
		local nCanHurtCount = 0;
		local hLaneCreepList = bot:GetNearbyLaneCreeps(nCastRange +100,true);
		for _,creep in pairs(hLaneCreepList)
		do
			if J.IsValid(creep)
				and not creep:HasModifier("modifier_fountain_glyph")
			then
				nCanHurtCount = nCanHurtCount +1;
				local nDist = GetUnitToUnitDistance(bot,creep)
				local nDamage = RemapValClamped(nDist, 0, nCastRange, nDamageMin, nDamageMax) *2;
				if J.WillKillTarget(creep,nDamage,nDamageType,nDist/636)
				then
					nCanKillCount = nCanKillCount +1;
				end				
			end
		end
		
		if nCanKillCount >= 3 or nCanHurtCount >= 5
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	--打钱
	if J.IsFarming(bot) and nLV > 7 and bot:GetMana() > nKeepMana
	then
		local nCreepList = bot:GetNearbyNeutralCreeps(nCastRange +200);
		local nNearCreepList = bot:GetNearbyNeutralCreeps(400);
		if (#nCreepList >= 3 and #nNearCreepList <= 2)
		    or #nCreepList >= 5
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	
	end
	
	--对线
	if J.IsLaning(bot)
	then
		local nCanKillMeleeCount = 0;
		local nCanKillRangedCount = 0;
		local hLaneCreepList = bot:GetNearbyLaneCreeps(nCastRange +100,true);
		for _,creep in pairs(hLaneCreepList)
		do
			if J.IsValid(creep)
				and not creep:HasModifier("modifier_fountain_glyph")
			then
				local nDist = GetUnitToUnitDistance(bot,creep)
				local nDamage = RemapValClamped(nDist, 0, nCastRange, nDamageMin, nDamageMax) *2;
				if J.WillKillTarget(creep,nDamage,nDamageType,nDist*0.9/636)
				then
					if J.IsKeyWordUnit('ranged',creep)
					then
						nCanKillRangedCount = nCanKillRangedCount +1;
						if not J.IsInRange(bot,creep,bot:GetAttackRange() +50)
						then
							return BOT_ACTION_DESIRE_HIGH;
						end
					end
					
					if J.IsKeyWordUnit('melee',creep)
					then
						nCanKillMeleeCount = nCanKillMeleeCount +1;
					end
					
				end				
			end
		end
		
		if nCanKillMeleeCount + nCanKillRangedCount >= 3
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
		
		if nCanKillRangedCount >= 1 and nCanKillMeleeCount >= 1
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	
	
	end
	
	--通用
	if (#hEnemyList > 0 or bot:WasRecentlyDamagedByAnyHero(3.0)) 
		and ( bot:GetActiveMode() ~= BOT_MODE_RETREAT or #hAllyList >= 2 )
		and #nInRangeEnemyList >= 1
		and nLV >= 15
	then
		for _,npcEnemy in pairs( nInRangeEnemyList )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 			
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end

return X;