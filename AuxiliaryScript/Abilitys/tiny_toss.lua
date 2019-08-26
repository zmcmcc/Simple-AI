-----------------
--英雄：小小
--技能：投掷
--键位：W
--类型：指向目标
--作者：Halcyon
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('tiny_toss')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;
local sTalentList = J.Skill.GetTalentList(bot)

nKeepMana = 300 --魔法储量
nLV = bot:GetLevel(); --当前英雄等级
nMP = bot:GetMana()/bot:GetMaxMana(); --目前法力值/最大法力值（魔法剩余比）
nHP = bot:GetHealth()/bot:GetMaxHealth();--目前生命值/最大生命值（生命剩余比）
hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内敌人
hAlleyHeroList = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);--1600范围内队友

--获取以太棱镜施法距离加成
local aether = J.IsItemAvailable("item_aether_lens");
local talent6 = bot:GetAbilityByName( sTalentList[6] );
if aether ~= nil then aetherRange = 250 else aetherRange = 0 end
    
--初始化函数库
U.init(nLV, nMP, nHP, bot);

--技能释放功能
function X.Release(castTarget)
    if castTarget ~= nil then
		X.Compensation()
		if talent6:IsTrained() and bot:GetUnitName() ~= 'npc_dota_hero_rubick' then 
			bot:ActionQueue_UseAbilityOnLocation( ability, castTarget:GetLocation() ) --使用技能
		else
			bot:ActionQueue_UseAbilityOnEntity( ability, castTarget ) --使用技能
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
	   or ability:IsNull()
       or not ability:IsFullyCastable()
	then 
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end
    
	local nSkillLV    = ability:GetLevel();
    local nRadius     = ability:GetSpecialValueInt("grab_radius");
    local manaCost    = ability:GetManaCost();
	local nCastRange  = ability:GetCastRange();
    local nCastPoint  = ability:GetCastPoint();
    local nDamage     = ability:GetSpecialValueInt('damage');
	local nDamageType = DAMAGE_TYPE_MAGICAL;

    local target  = J.GetProperTarget(bot);
	local hEnemyHeroListInRange = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE);
	local hAlleyHeroListInRange = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE);
	local hAllCreepListInRange = bot:GetNearbyLaneCreeps(nCastRange, false);

	--获取当前投掷目标
	local tossTarget = nil
	
	local hAlleyHeroListInRadius = bot:GetNearbyHeroes(nRadius, false, BOT_MODE_NONE)
	local hAlleyCreepListInRadius = bot:GetNearbyLaneCreeps(nRadius, false)
	local hEnemyHeroListInRadius = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE)
	local hEnemyCreepListInRadius = bot:GetNearbyLaneCreeps(nRadius, true)

	for _,npcTarget in pairs( hAlleyHeroListInRadius )
	do
		if (tossTarget == nil or GetUnitToUnitDistance(bot, npcTarget) < GetUnitToUnitDistance(bot, tossTarget))
		   and J.IsValid(npcTarget)
		   and J.CanCastOnNonMagicImmune(npcTarget)
		   and J.CanCastOnTargetAdvanced(npcTarget)
		then
			tossTarget = npcTarget
		end
	end
	for _,npcTarget in pairs( hAlleyCreepListInRadius )
	do
		if (tossTarget == nil or GetUnitToUnitDistance(bot, npcTarget) < GetUnitToUnitDistance(bot, tossTarget))
		   and J.IsValid(npcTarget)
		   and J.CanCastOnNonMagicImmune(npcTarget)
		   and J.CanCastOnTargetAdvanced(npcTarget)
		then
			tossTarget = npcTarget
		end
	end
	for _,npcTarget in pairs( hEnemyHeroListInRadius )
	do
		if (tossTarget == nil or GetUnitToUnitDistance(bot, npcTarget) < GetUnitToUnitDistance(bot, tossTarget))
		   and J.IsValid(npcTarget)
		   and J.CanCastOnNonMagicImmune(npcTarget)
		   and J.CanCastOnTargetAdvanced(npcTarget)
		then
			tossTarget = npcTarget
		end
	end
	for _,npcTarget in pairs( hEnemyCreepListInRadius )
	do
		if (tossTarget == nil or GetUnitToUnitDistance(bot, npcTarget) < GetUnitToUnitDistance(bot, tossTarget))
		   and J.IsValid(npcTarget)
		   and J.CanCastOnNonMagicImmune(npcTarget)
		   and J.CanCastOnTargetAdvanced(npcTarget)
		then
			tossTarget = npcTarget
		end
	end

	if tossTarget == nil then
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	--把敌人扔到人群（我方人数大于敌方）

	if tossTarget:GetTeam() ~= bot:GetTeam()
	   and #hAlleyHeroList >= #hEnemyHeroList
	   and (#hAlleyHeroListInRange > 0 or #hAllCreepListInRange > 0)
	then
		if hAlleyHeroListInRange[1] ~= nil then
			return BOT_ACTION_DESIRE_HIGH, hAlleyHeroListInRange[1]
		else
			return BOT_ACTION_DESIRE_HIGH, hAllCreepListInRange[1]
		end
	end
	--追击时 把队友扔到敌人脸上（敌人小于2人且友方生命足够）

	if J.IsGoingOnSomeone(bot)
	then
		if tossTarget:GetTeam() == bot:GetTeam()
		   and tossTarget:IsHero()
		   and #hEnemyHeroListInRange <= 2
		   and hEnemyHeroListInRange[1] ~= nil
		   and J.GetHPR(tossTarget) > 0.5
		then
			return BOT_ACTION_DESIRE_HIGH, hEnemyHeroListInRange[1]
		end
	end
	--撤退时 把敌人扔回去
	if J.IsRetreating(bot)
	then
		if #hEnemyHeroListInRadius > 0 and bot:WasRecentlyDamagedByAnyHero(2.0) then
			return BOT_ACTION_DESIRE_LOW, hEnemyHeroListInRadius[1];
		end
	end	
	--打团时 如果可以使用跳刀，跳到敌人脸上把人扔回人群（团灭发动机）
	
	--追击时 把周边的任意单位扔到敌人脸上

	if J.IsGoingOnSomeone(bot)
	then
		if tossTarget:GetTeam() == bot:GetTeam()
		   and not tossTarget:IsHero()
		   and hEnemyHeroListInRange[1] ~= nil
		then
			return BOT_ACTION_DESIRE_HIGH, hEnemyHeroListInRange[1]
		end
	end
	--打断和击杀

	if tossTarget:IsChanneling()
	   and tossTarget:GetTeam() ~= bot:GetTeam()
	   and tossTarget:IsHero()
	then
		return BOT_ACTION_DESIRE_HIGH, tossTarget
	end

	for _,npcEnemy in pairs( hEnemyHeroListInRange )
	do
		if J.IsValid(npcEnemy)
		   and J.CanCastOnNonMagicImmune(npcEnemy)
		   and J.CanCastOnTargetAdvanced(npcEnemy)
		then
			if J.IsInRange(bot,npcEnemy,nCastRange +80)
				and J.WillMagicKillTarget(bot,npcEnemy,nDamage *2.38,nCastPoint)
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
			
		end
	end
	--对线时 把敌人扔到小兵堆里,把敌人扔到塔

	if bot:GetActiveMode() == BOT_MODE_LANING then
		local nTowersList = bot:GetNearbyTowers(nCastRange,false)
		if tossTarget:GetTeam() ~= bot:GetTeam()
		   and tossTarget:IsHero()
		   and nTowersList > 3
		   and nTowersList[1] ~= nil
		then
			return BOT_ACTION_DESIRE_HIGH, nTowersList[1]
		end

		if tossTarget:GetTeam() ~= bot:GetTeam()
		   and tossTarget:IsHero()
		   and hAllCreepListInRange > 3
		then
			return BOT_ACTION_DESIRE_HIGH, hAllCreepListInRange[1]
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X;