-----------------
--英雄：斧王
--技能：淘汰之刃
--键位：R
--类型：指向目标
--作者：Halcyon
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('axe_culling_blade')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;

nKeepMana = 180 --魔法储量
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
	
	-- Get some of its values
	local nCastRange = ability:GetCastRange() + 600;
	local nSkillLV   = ability:GetLevel();
	local nKillHealth = 75 * nSkillLV + 175;

	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = J.GetProperTarget(bot);
		if J.IsValidHero(npcTarget) 
		   and J.CanCastOnNonMagicImmune(npcTarget) 
		   and not J.IsHaveAegis(npcTarget)
		   and J.IsInRange(npcTarget, bot, nCastRange + 200)
		then
			if --J.CanKillTarget(npcTarget, nKillHealth, DAMAGE_TYPE_MAGICAL ) 
			npcTarget:GetHealth() < nKillHealth
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end

	-- If we're in a teamfight, use it on the scariest enemy
	if J.IsInTeamFight(bot, 1200)
	then
		local npcToKill = nil;
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if J.IsValidHero(npcEnemy)
			   and J.CanCastOnNonMagicImmune(npcEnemy)
			   and not J.IsHaveAegis(npcEnemy) 
			then
				if --J.CanKillTarget(npcEnemy, nKillHealth, DAMAGE_TYPE_MAGICAL )
				npcEnemy:GetHealth() < nKillHealth
				then
					npcToKill = npcEnemy;
					break;
				end
			end
		end
		if ( npcToKill ~= nil  )
		then
			return BOT_ACTION_DESIRE_HIGH, npcToKill;
		end
	end
	
	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs(tableNearbyEnemyHeroes )
	do
		if J.IsValidHero(npcEnemy) 
		   and not J.IsHaveAegis(npcEnemy) 
		then
			if J.CanCastOnNonMagicImmune(npcEnemy) and --J.CanKillTarget(npcEnemy, nKillHealth, DAMAGE_TYPE_MAGICAL )
			npcEnemy:GetHealth() < nKillHealth
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X;