-----------------
--英雄：巫妖
--技能：阴邪凝视
--键位：E
--类型：指向目标
--作者：决明子
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('lich_sinister_gaze')
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
	   or ability:IsNull()
       or not ability:IsFullyCastable()
	then
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end
	
	local nSkillLV    = ability:GetLevel(); 
	local nCastRange  = ability:GetCastRange() + aetherRange;
	
	if #hEnemyList <= 2 and nCastRange < 630 then nCastRange = nCastRange + 150 end
	
	local nCastPoint  = ability:GetCastPoint();
	local nManaCost   = ability:GetManaCost();
	local nDamage     = ability:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeEnemyList = bot:GetNearbyHeroes(nCastRange +50, true, BOT_MODE_NONE);
	
	
	--打断
	for _,npcEnemy in pairs(nInRangeEnemyList)
	do
		if J.IsValidHero(npcEnemy)
		then
			if npcEnemy:IsChanneling()
				and J.CanCastOnNonMagicImmune(npcEnemy)
			then
				return BOT_ACTION_DESIRE_HIGH,npcEnemy
			end
			
			if J.IsCastingUltimateAbility(npcEnemy)
				and J.CanCastOnNonMagicImmune(npcEnemy)
			then
				return BOT_ACTION_DESIRE_HIGH,npcEnemy
			end		
		end
	end
	
	
	--团战中对输出最强的敌人使用
	if J.IsInTeamFight(bot,900)
	then
		local nInBonusEnemyList = J.GetEnemyList(bot,nCastRange +420);
		if #nInBonusEnemyList >= 2 or #hAllyList >= 3
		then
			local npcMostDangerousEnemy = nil;
			local nMostDangerousDamage = 0;
			
			for _,npcEnemy in pairs( nInBonusEnemyList )
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
			
			if npcMostDangerousEnemy ~= nil
				and J.IsInRange(bot,npcMostDangerousEnemy,nCastRange +50)
			then
				return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy
			end
		
		end
	end
	
	
	--牵引
	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidHero(botTarget)
			and J.CanCastOnNonMagicImmune(botTarget)
			and J.IsInRange(bot,botTarget,nCastRange +32)
			and not J.IsInRange(bot,botTarget,nCastRange -200)
			and bot:IsFacingLocation(botTarget:GetLocation(),30)
			and not botTarget:IsFacingLocation(bot:GetLocation(),100)
		then
			return BOT_ACTION_DESIRE_HIGH, botTarget
		end	
	end
	
	
	--肉山
	if J.IsDoingRoshan(bot) and nMP > 0.6
	then
		if J.IsRoshan(botTarget)
			and J.IsInRange(bot,botTarget,nCastRange)
			and not J.IsDisabled(true,botTarget)
			and not botTarget:IsDisarmed()
		then
			return BOT_ACTION_DESIRE_HIGH,botTarget
		end	
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X;