-----------------
--英雄：天涯墨客
--技能：幻影之拥
--键位：W
--类型：指向目标
--作者：Halcyon
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('grimstroke_ink_creature')
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
       or not ability:IsFullyCastable()
	then 
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end
	
	local nSkillLV    = ability:GetLevel()
	local nCastRange  = ability:GetCastRange()
	local nCastPoint  = ability:GetCastPoint()
	local nManaCost   = ability:GetManaCost()
	local nDamage     = ability:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyHeroList = bot:GetNearbyHeroes(nCastRange +50, true, BOT_MODE_NONE);
           

	for _,npcEnemy in pairs(nInRangeEnemyHeroList)
	do
		if ( npcEnemy:IsCastingAbility() or npcEnemy:IsChanneling() )
		   and not npcEnemy:HasModifier("modifier_teleporting") 
		   and not npcEnemy:HasModifier("modifier_boots_of_travel_incoming")
		   and J.CanCastOnNonMagicImmune(npcEnemy)
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end	
	end
		   
	
	if J.IsInTeamFight(bot, 1200)
	then
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;
		
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange + 100, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if  J.IsValidHero(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and not J.IsDisabled(true, npcEnemy)
			then
				local npcEnemyDamage = npcEnemy:GetEstimatedDamageToTarget( false, bot, 3.0, DAMAGE_TYPE_MAGICAL );
				if ( npcEnemyDamage > nMostDangerousDamage )
				then
					nMostDangerousDamage = npcEnemyDamage;
					npcMostDangerousEnemy = npcEnemy;
				end
			end
		end
		
		if ( npcMostDangerousEnemy ~= nil )
		then
			return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy;
		end
		
	end
	
	
	if bot:WasRecentlyDamagedByAnyHero(3.0) 
		and nInRangeEnemyHeroList[1] ~= nil
		and #nInRangeEnemyHeroList >= 1
	then
		for _,npcEnemy in pairs( nInRangeEnemyHeroList )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and not J.IsDisabled(true, npcEnemy) 
				and bot:IsFacingLocation(npcEnemy:GetLocation(),40)
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	
	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidHero(hBotTarget) 
			and J.CanCastOnNonMagicImmune(hBotTarget) 
			and J.IsInRange(hBotTarget, bot, nCastRange) 
			and not J.IsDisabled(true, hBotTarget)
		then
			return BOT_ACTION_DESIRE_HIGH, hBotTarget;
		end
	end
	
	
	if J.IsRetreating(bot) 
	then
		for _,npcEnemy in pairs( nInRangeEnemyHeroList )
		do
			if J.IsValid(npcEnemy)
			    and bot:WasRecentlyDamagedByHero( npcEnemy, 3.1 ) 
				and J.CanCastOnNonMagicImmune(npcEnemy) 
				and not J.IsDisabled(true, npcEnemy) 
				and J.IsInRange(npcEnemy, bot, nCastRange) 
				and ( not J.IsInRange(npcEnemy, bot, 450) or bot:IsFacingLocation(npcEnemy:GetLocation(), 45) )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	
	if  bot:GetActiveMode() == BOT_MODE_ROSHAN 
	    and bot:GetMana() >= 1200
		and ability:GetLevel() >= 3
	then
		if  J.IsRoshan(hBotTarget) 
			and J.IsInRange(hBotTarget, bot, nCastRange)
		then
			return BOT_ACTION_DESIRE_HIGH, hBotTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X;