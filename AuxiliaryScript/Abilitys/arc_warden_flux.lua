-----------------
--英雄：天穹守望者
--技能：乱流
--键位：Q
--类型：指向目标
--作者：决明子
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('arc_warden_flux')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;

nKeepMana = 300 --魔法储量
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
	local nCastRange = ability:GetCastRange() +60;
	local nDot = ability:GetSpecialValueInt( "damage_per_second" );
	local nDuration = ability:GetSpecialValueInt( "duration" );
	local nDamage = nDot * nDuration;
	local npcTarget = J.GetProperTarget(bot);
	
	-- If a mode has set a target, and we can kill them, do it
	if J.IsValidHero(npcTarget) 
	   and J.CanCastOnNonMagicImmune(npcTarget) 
	   and J.CanCastOnTargetAdvanced(npcTarget)
	   and J.CanKillTarget(npcTarget, nDamage, DAMAGE_TYPE_MAGICAL) 
	   and J.IsInRange(npcTarget, bot, nCastRange)
	then
		return BOT_ACTION_DESIRE_HIGH, npcTarget;
	end
	
	
	-- If we're in a teamfight, use it on the scariest enemy
	if J.IsInTeamFight(bot, 1200)
	then
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;

		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE  );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if J.IsValid(npcEnemy) 
			   and J.CanCastOnNonMagicImmune(npcEnemy) 
			   and J.CanCastOnTargetAdvanced(npcEnemy)
			then
				local nDamage = npcEnemy:GetEstimatedDamageToTarget( false, bot, 3.0, DAMAGE_TYPE_ALL );
				if ( nDamage > nMostDangerousDamage )
				then
					nMostDangerousDamage = nDamage;
					npcMostDangerousEnemy = npcEnemy;
				end
			end
		end

		if ( npcMostDangerousEnemy ~= nil )
		then
			return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy;
		end
	end

	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		if J.IsRoshan(npcTarget) 
		   and J.CanCastOnMagicImmune(npcTarget) 
		   and J.IsInRange(npcTarget, bot, nCastRange)  
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget;
		end
	end
	
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValidHero(npcTarget) 
		   and J.CanCastOnNonMagicImmune(npcTarget) 
		   and J.CanCastOnTargetAdvanced(npcTarget)
		   and J.IsInRange(npcTarget, bot, nCastRange +40)
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	
	if J.IsRetreating(bot) 
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE  );
		local nEnemyHeroes   = bot:GetNearbyHeroes( 800, true, BOT_MODE_NONE  );
		local npcEnemy = tableNearbyEnemyHeroes[1];
		if J.IsValid(npcEnemy) 
			and (bot:IsFacingLocation(npcEnemy:GetLocation(),10) or #nEnemyHeroes <= 1)
			and bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) 
			and J.CanCastOnNonMagicImmune(npcEnemy)
			and J.CanCastOnTargetAdvanced(npcEnemy)
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end  
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X;