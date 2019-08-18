-----------------
--英雄：斯拉达
--技能：侵蚀雾霭
--键位：R
--类型：指向目标
--作者：望天的稻草
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('slardar_amplify_damage')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;

nKeepMana = 400 --魔法储量
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
    if ability ~= nil
       and not ability:IsFullyCastable()
	then 
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end
	
	local nSkillLV    = ability:GetLevel();    	--技能等级 
	local nManaCost   = ability:GetManaCost();  --魔法消耗
    local nCastRange  = 100* nSkillLV + 600;    --施法范围
	local aTarget = bot:GetAttackTarget();

	
	local nEnemysHerosInRange = bot:GetNearbyHeroes(nCastRange,true,BOT_MODE_NONE);
	local nEnemyHeroes = bot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
	
	--肉山
	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = bot:GetAttackTarget();
		if npcTarget ~= nil and
		   J.IsRoshan(npcTarget) and
		   J.CanCastOnMagicImmune(npcTarget) and
		   J.IsInRange(npcTarget, bot, nCastRange)
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	--遭遇
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = J.GetProperTarget(bot);
		if npcTarget ~= nil then
			if J.IsValidHero(npcTarget) 
			and J.CanCastOnNonMagicImmune(npcTarget) 
			and J.IsInRange(npcTarget, bot, nCastRange) 
			and J.CanCastOnTargetAdvanced(npcTarget)
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
			
			if J.IsValid(npcTarget) and #nEnemyHeroes == 0
			and J.IsAllowedToSpam(bot, nManaCost) 
			and J.CanCastOnNonMagicImmune(npcTarget) 
			and J.CanCastOnTargetAdvanced(npcTarget)
			and J.IsInRange(npcTarget, bot, nCastRange) 
			and not J.CanKillTarget(npcTarget,bot:GetAttackDamage() *1.48,DAMAGE_TYPE_PHYSICAL)
			then
				local nCreeps = bot:GetNearbyCreeps(800,true);
				if #nCreeps >= 1
				then
					return BOT_ACTION_DESIRE_HIGH, npcTarget;
				end
			end
		end
	end
	
	
    --团战
	if J.IsInTeamFight(bot, 1200)
	then
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;	

		
		for _,npcEnemy in pairs( nEnemysHerosInRange )
		do
			if  J.IsValidHero(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
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
		then
			return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy;
		end	
		

	end
	
	--打钱时使用
	if  J.IsFarming(bot) 
		and nSkillLV >= 1
		and nMP > 0.65
	then
		local nCreeps = bot:GetNearbyNeutralCreeps(nCastRange +100);
		
		local targetCreep = J.GetMostHpUnit(nCreeps);
		
		if targetCreep ~= nil
		   and J.IsValid(targetCreep)
		   and GetUnitToUnitDistance(targetCreep,bot) <= 400 
		   and not J.CanKillTarget(targetCreep,bot:GetAttackDamage() *1.68,DAMAGE_TYPE_PHYSICAL)
		then
			return BOT_ACTION_DESIRE_HIGH, targetCreep;
	    end
	end
	

	--对线期间
	if nEnemysHerosInRange ~= nil
	   and bot:GetActiveMode() == BOT_MODE_LANING
	   and J.IsValid(bot) 
	then
		for _,npcEnemy in pairs( nEnemysHerosInRange)
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X;