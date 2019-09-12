-----------------
--英雄：巫妖
--技能：冰霜魔盾
--键位：W
--类型：指向目标
--作者：决明子
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('lich_frost_shield')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;
local sTalentList = J.Skill.GetTalentList(bot)

nKeepMana = 400 --魔法储量
nLV = bot:GetLevel(); --当前英雄等级
nMP = bot:GetMana()/bot:GetMaxMana(); --目前法力值/最大法力值（魔法剩余比）
nHP = bot:GetHealth()/bot:GetMaxHealth();--目前生命值/最大生命值（生命剩余比）
hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内敌人
hAlleyHeroList = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);--1600范围内队友

local talent7 = bot:GetAbilityByName( sTalentList[7] )

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
	local nCastRange  = ability:GetCastRange() + aetherRange
	local nCastPoint  = ability:GetCastPoint()
	local nManaCost   = ability:GetManaCost()
	local nDamage     = ability:GetAbilityDamage()
	local nDamageType = DAMAGE_TYPE_MAGICAL
	local nInRangeAllyList = J.GetAlliesNearLoc(bot:GetLocation(),nCastRange +50);
	
	local nRadius = ability:GetSpecialValueInt("radius")
	
	--团战保护
	if J.IsInTeamFight(bot,900)
	then
		local nTargetAlly = nil
		local nMostScore = 39
		
		for _,npcAlly in pairs(nInRangeAllyList)
		do 
			local nEnemyHeroList = npcAlly:GetNearbyHeroes(1600,true,BOT_MODE_NONE)
			local nEnemyCreepList = npcAlly:GetNearbyCreeps(1000,true)
			local nAllyScore = 0;		
		
			for _,npcEnemy in pairs(nEnemyHeroList)
			do 
				if npcEnemy:GetAttackTarget() == npcAlly
					or npcEnemy:IsFacingLocation(npcAlly:GetLocation(),12)
				then
					nAllyScore = nAllyScore + 30;
				end
			end
			
			for _,nCreep in pairs(nEnemyCreepList)
			do 
				if nCreep:GetAttackTarget() == npcAlly
				then
					nAllyScore = nAllyScore + 10;
				end
			end
			
			if nAllyScore > nMostScore
			then
				nTargetAlly = npcAlly;
				nMostScore = nAllyScore;
			end
		
		end
		
		if nTargetAlly ~= nil
		then
			return BOT_ACTION_DESIRE_HIGH,nTargetAlly;
		end
	
	end
	
	
	--修塔兵营基地
	if talent7:IsTrained()
	then
		local nTowerList = bot:GetNearbyTowers(nCastRange +50,false);
		for _,target in pairs(nTowerList)
		do 
			if J.IsValidBuilding(target)
				and target:GetMaxHealth() - target:GetHealth() > 600
				and ( #hEnemyList == 0 or hEnemyList[1]:GetAttackTarget() == target )
			then
				return BOT_ACTION_DESIRE_HIGH,target;
			end
		end
		
		local nBarrackList = bot:GetNearbyBarracks(nCastRange +50,false);
		for _,target in pairs(nBarrackList)
		do 
			if J.IsValidBuilding(target)
				and target:GetMaxHealth() - target:GetHealth() > 800
				and ( #hEnemyList == 0 or hEnemyList[1]:GetAttackTarget() == target )
			then
				return BOT_ACTION_DESIRE_HIGH,target;
			end
		end
		
		local nAncient = GetAncient(GetTeam());
		if J.IsInRange(bot,nAncient,nCastRange)
			and nAncient:GetMaxHealth() - nAncient:GetHealth() > 1000
		then
			return BOT_ACTION_DESIRE_HIGH,nAncient;
		end
	end
	
	
	--肉山
	if J.IsDoingRoshan(bot)
	then
		if J.IsRoshan(botTarget)
			and botTarget:GetAttackTarget() ~= nil
		then
			local nRoshanTarget = botTarget:GetAttackTarget();
			for _,npcAlly in pairs(nInRangeAllyList)
			do 
				if nRoshanTarget == npcAlly
				then
					return BOT_ACTION_DESIRE_HIGH,npcAlly;
				end
			end
		end
	end
	
	
	--对每个友军
	for _,npcAlly in pairs(nInRangeAllyList)
	do	
		--Aoe
		local nEnemyHeroList = npcAlly:GetNearbyHeroes(nRadius -20,true,BOT_MODE_NONE)
		if #nEnemyHeroList >= 3 
		then
			return BOT_ACTION_DESIRE_HIGH,npcAlly;
		end
		
		--撤退
		if J.IsRetreating(npcAlly)
		then
			for _,npcEnemy in pairs(nEnemyHeroList)
			do 
				if J.IsValidHero(npcEnemy)
					and J.CanCastOnMagicImmune(npcEnemy)
					and ( npcAlly == npcEnemy:GetAttackTarget() 
						   or npcAlly:GetActiveModeDesire() > 0.85
						   or npcAlly:WasRecentlyDamagedByHero(npcEnemy,4.0))
				then
					return BOT_ACTION_DESIRE_HIGH,npcAlly;
				end
			end
		end
		
		
		--进攻
		if J.IsGoingOnSomeone(npcAlly)
		then
			local allyTarget = J.GetProperTarget(npcAlly);
			if J.IsValidHero(allyTarget)
				and J.CanCastOnNonMagicImmune(allyTarget)
				and J.IsInRange(npcAlly,allyTarget,nRadius)
			then
				--protect
				if allyTarget:GetAttackTarget() == npcAlly
				then
					return BOT_ACTION_DESIRE_HIGH,npcAlly;
				end
				
				--assist
				if npcAlly:IsFacingLocation(allyTarget:GetLocation(), 20)
					and not allyTarget:IsFacingLocation(npcAlly:GetLocation(), 120)
					and J.IsRunning(allyTarget)
				then
					return BOT_ACTION_DESIRE_HIGH,npcAlly;
				end			
			end		
		end
		
		
		--推进
		if J.IsPushing(npcAlly) and nSkillLV >= 4 and J.IsAllowedToSpam(bot,nManaCost)
			and #hAllyList <= 2 and #hEnemyList == 0
		then
			local nCreeps = npcAlly:GetNearbyLaneCreeps(nRadius,true);
			if #nCreeps >= 4
				and not nCreeps[1]:HasModifier("modifier_fountain_glyph")
			then
				return BOT_ACTION_DESIRE_HIGH, npcAlly;
			end
		end
		
		
		--打野
		if J.IsFarming(npcAlly) and nSkillLV >= 4 and J.IsAllowedToSpam(bot,nManaCost)
			and #hAllyList <= 3 and #hEnemyList == 0
		then
			local nCreeps = npcAlly:GetNearbyNeutralCreeps(nRadius);
			if #nCreeps >= 4
				and nCreeps[1]:GetMagicResist() < 0.3
			then
				return BOT_ACTION_DESIRE_HIGH, npcAlly;
			end
		end
		
		if talent7:IsTrained() 
			and J.IsAllowedToSpam(bot,nManaCost)
			and #hEnemyList == 0
		then
			if J.GetHPR(npcAlly) < 0.38
			then
				return BOT_ACTION_DESIRE_HIGH, npcAlly;
			end
		end
	
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X;