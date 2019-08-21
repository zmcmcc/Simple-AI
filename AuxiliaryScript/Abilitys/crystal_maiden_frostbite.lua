-----------------
--英雄：水晶室女
--技能：冰封禁制
--键位：W
--类型：指向目标
--作者：决明子
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('centaur_double_edge')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;
local sTalentList = J.Skill.GetTalentList(bot)

nKeepMana = 220 --魔法储量
nLV = bot:GetLevel(); --当前英雄等级
nMP = bot:GetMana()/bot:GetMaxMana(); --目前法力值/最大法力值（魔法剩余比）
nHP = bot:GetHealth()/bot:GetMaxHealth();--目前生命值/最大生命值（生命剩余比）
hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内敌人
hAlleyHeroList = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);--1600范围内队友

--获取以太棱镜施法距离加成
local aether = J.IsItemAvailable("item_aether_lens");
local talent2 = bot:GetAbilityByName( sTalentList[2] );
if aether ~= nil then aetherRange = 250 else aetherRange = 0 end
if talent2:IsTrained() and bot:GetUnitName() ~= 'npc_dota_hero_rubick' then aetherRange = aetherRange + talent2:GetSpecialValueInt('value') end

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
	local nCastRange = ability:GetCastRange() +30 +aetherRange;
	local nCastPoint = ability:GetCastPoint( );
	local nManaCost  = ability:GetManaCost( );
	local nSkillLV   = ability:GetLevel();                             
	local nDamage    = (100 + nSkillLV * 50);
	
	local nAllies =  bot:GetNearbyHeroes(1200,false,BOT_MODE_NONE);
	
	local nEnemysHeroesInView = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	if #nEnemysHeroesInView <= 1 and nCastRange < bot:GetAttackRange() then nCastRange = bot:GetAttackRange()+60 end
	local nEnemysHeroesInRange = bot:GetNearbyHeroes(nCastRange,true,BOT_MODE_NONE);
	local nEnemysHeroesInBonus = bot:GetNearbyHeroes(nCastRange + 200,true,BOT_MODE_NONE);
	
	local nWeakestEnemyHeroInRange,nWeakestEnemyHeroHealth1 = X.cm_GetWeakestUnit(nEnemysHeroesInRange);
	local nWeakestEnemyHeroInBonus,nWeakestEnemyHeroHealth2 = X.cm_GetWeakestUnit(nEnemysHeroesInBonus);
	
	local nEnemysCreeps1 = bot:GetNearbyCreeps(nCastRange + 100,true)
	local nEnemysCreeps2 = bot:GetNearbyCreeps(1400,true)
	
	local nEnemysStrongestCreeps1,nEnemysStrongestCreepsHealth1 = X.cm_GetStrongestUnit(nEnemysCreeps1);
	local nEnemysStrongestCreeps2,nEnemysStrongestCreepsHealth2 = X.cm_GetStrongestUnit(nEnemysCreeps2);
	
	local nTowers = bot:GetNearbyTowers(900,true)
	
	--击杀敌人
	if  J.IsValid(nWeakestEnemyHeroInRange)
		and J.CanCastOnTargetAdvanced(nWeakestEnemyHeroInRange)
	then
		if J.WillMagicKillTarget(bot, nWeakestEnemyHeroInRange, nDamage, nCastPoint)
		then
			return BOT_ACTION_DESIRE_HIGH, nWeakestEnemyHeroInRange;
		end
	end	
	
	--打断TP
	for _,npcEnemy in pairs( nEnemysHeroesInBonus)
	do
		if J.IsValid(npcEnemy)
		   and npcEnemy:IsChanneling()
		   and npcEnemy:HasModifier('modifier_teleporting')
		   and J.CanCastOnNonMagicImmune(npcEnemy)
		   and J.CanCastOnTargetAdvanced(npcEnemy)
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy
		end
	end
	
	--团战中对最强的敌人使用
	if J.IsInTeamFight(bot, 1200)
	   and  DotaTime() > 6*60
	then
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;
		
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and J.CanCastOnTargetAdvanced(npcEnemy)
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
			return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy;
		end
		
	end
	
	--保护自己
	if bot:WasRecentlyDamagedByAnyHero(3.0) 
		and #nEnemysHeroesInRange >= 1
	then
		for _,npcEnemy in pairs( nEnemysHeroesInRange )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and J.CanCastOnTargetAdvanced(npcEnemy)
				and not J.IsDisabled(true, npcEnemy)
                and not npcEnemy:IsDisarmed()				
				and bot:IsFacingLocation(npcEnemy:GetLocation(),45)
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end
	
	--对线期消耗
	if bot:GetActiveMode() == BOT_MODE_LANING and #nTowers == 0
	then
		if( nMP > 0.5 or bot:GetMana()> nKeepMana )
		then
			if J.IsValid(nWeakestEnemyHeroInRange)
			   and not J.IsDisabled(true, nWeakestEnemyHeroInRange) 
			then
				return BOT_ACTION_DESIRE_HIGH,nWeakestEnemyHeroInRange;
			end
		end	
	
		if( nMP > 0.78 or bot:GetMana()> nKeepMana )
		then
			if  J.IsValid(nWeakestEnemyHeroInBonus)
				and nHP > 0.6 
				and #nTowers == 0
				and #nEnemysCreeps2 + #nEnemysHeroesInBonus <= 5
			    and not J.IsDisabled(true, nWeakestEnemyHeroInBonus) 
				and nWeakestEnemyHeroInBonus:GetCurrentMovementSpeed() < bot:GetCurrentMovementSpeed()
			then
				return BOT_ACTION_DESIRE_HIGH,nWeakestEnemyHeroInBonus;
			end			
		end
		
		
		if  J.IsValid(nEnemysHeroesInView[1])
		then
			if  J.GetAllyUnitCountAroundEnemyTarget(nEnemysHeroesInView[1], 350, bot) >= 5
				and not J.IsDisabled(true, nEnemysHeroesInView[1]) 
				and not nEnemysHeroesInView[1]:IsMagicImmune()
				and nHP > 0.7
				and bot:GetMana()> nKeepMana
				and #nEnemysCreeps2 + #nEnemysHeroesInBonus <= 3
				and #nTowers == 0
			then
				return BOT_ACTION_DESIRE_HIGH,nEnemysHeroesInView[1];
			end
		end
		
		if  J.IsValid(nWeakestEnemyHeroInRange)  
		then
			if nWeakestEnemyHeroInRange:GetHealth()/nWeakestEnemyHeroInRange:GetMaxHealth() < 0.5 
			then
				return BOT_ACTION_DESIRE_HIGH,nWeakestEnemyHeroInRange;
			end
		end
	end
	
	--特殊用法之冰冻敌方英雄的随从
	if nEnemysHeroesInRange[1] == nil
		and nEnemysCreeps1[1] ~= nil
	then
		for _,EnemyplayerCreep in pairs(nEnemysCreeps1)
		do 
			if  J.IsValid(EnemyplayerCreep)
			    and EnemyplayerCreep:GetTeam() == GetOpposingTeam()
				and EnemyplayerCreep:GetHealth() > 460
				and not EnemyplayerCreep:IsMagicImmune()
				and not EnemyplayerCreep:IsInvulnerable()
				and (EnemyplayerCreep:IsDominated() or EnemyplayerCreep:IsMinion())
			then
			    return BOT_ACTION_DESIRE_HIGH, EnemyplayerCreep;
			end
		end
	end
	
	--无英雄目标时冰冻小兵打钱
	if bot:GetActiveMode() ~= BOT_MODE_LANING 
		and  bot:GetActiveMode() ~= BOT_MODE_RETREAT
		and  bot:GetActiveMode() ~= BOT_MODE_ATTACK
		and  #nEnemysHeroesInView == 0
		and  #nAllies < 3
		and  nLV >= 5
	then
		
		--先远
		if  J.IsValid(nEnemysStrongestCreeps2)
			and (DotaTime() > 10*60 
			     or (nEnemysStrongestCreeps2:GetUnitName() ~= 'npc_dota_creep_badguys_melee'
                     and nEnemysStrongestCreeps2:GetUnitName() ~= 'npc_dota_creep_badguys_ranged'
                     and nEnemysStrongestCreeps2:GetUnitName() ~= 'npc_dota_creep_goodguys_melee'
                     and nEnemysStrongestCreeps2:GetUnitName() ~= 'npc_dota_creep_goodguys_ranged') )
		then
			if  (nEnemysStrongestCreepsHealth2 > 460 or (nEnemysStrongestCreepsHealth1 > 390 and nMP > 0.45)) 
				and nEnemysStrongestCreepsHealth2 <= 1200
			then
				return BOT_ACTION_DESIRE_LOW, nEnemysStrongestCreeps2;
			end
		end
		
		--再近
		if  J.IsValid(nEnemysStrongestCreeps1)
			and (DotaTime() > 10*60 
			     or (nEnemysStrongestCreeps1:GetUnitName() ~= 'npc_dota_creep_badguys_melee'
                     and nEnemysStrongestCreeps1:GetUnitName() ~= 'npc_dota_creep_badguys_ranged'
                     and nEnemysStrongestCreeps1:GetUnitName() ~= 'npc_dota_creep_goodguys_melee'
                     and nEnemysStrongestCreeps1:GetUnitName() ~= 'npc_dota_creep_goodguys_ranged') )					 
		then
			if (nEnemysStrongestCreepsHealth1 > 410 or (nEnemysStrongestCreepsHealth1 > 360 and nMP > 0.45))   
				and nEnemysStrongestCreepsHealth1 <= 1200  
			then
				return BOT_ACTION_DESIRE_LOW, nEnemysStrongestCreeps1;
			end
		end
		
	end
	
	--进攻
	if J.IsGoingOnSomeone(bot)
	then
	    local npcTarget = J.GetProperTarget(bot);
		if J.IsValidHero(npcTarget) 
			and J.CanCastOnNonMagicImmune(npcTarget) 
			and J.CanCastOnTargetAdvanced(npcTarget)
			and J.IsInRange(npcTarget, bot, nCastRange + 50) 
			and not J.IsDisabled(true, npcTarget)
			and not npcTarget:IsDisarmed()
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end		
	end
	

	--撤退
	if J.IsRetreating(bot) 
	then
		for _,npcEnemy in pairs( nEnemysHeroesInRange )
		do
			if  J.IsValid(npcEnemy)
			    and bot:WasRecentlyDamagedByHero( npcEnemy, 5.0 ) 
				and J.CanCastOnNonMagicImmune(npcEnemy) 
				and J.CanCastOnTargetAdvanced(npcEnemy)
				and not J.IsDisabled(true, npcEnemy) 
				and J.IsInRange(npcEnemy, bot, nCastRange - 80) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	
	if  bot:GetActiveMode() == BOT_MODE_ROSHAN 
		and bot:GetMana() >= 400
	then
		local npcTarget = bot:GetAttackTarget();
		if  J.IsRoshan(npcTarget) 
			and not J.IsDisabled(true, npcTarget)
			and not npcTarget:IsDisarmed()
			and J.IsInRange(npcTarget, bot, nCastRange)  
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

function X.cm_GetWeakestUnit( nEnemyUnits )
	
	local nWeakestUnit = nil;
	local nWeakestUnitLowestHealth = 10000;
	for _,unit in pairs(nEnemyUnits)
	do
		if 	J.CanCastOnNonMagicImmune(unit)
		then
			if unit:GetHealth() < nWeakestUnitLowestHealth
			then
				nWeakestUnitLowestHealth = unit:GetHealth();
				nWeakestUnit = unit;
			end
		end
	end

	return nWeakestUnit,nWeakestUnitLowestHealth;	
end

function X.cm_GetStrongestUnit( nEnemyUnits )
	
	local nStrongestUnit = nil;
	local nStrongestUnitHealth = GetBot():GetAttackDamage();

	for _,unit in pairs(nEnemyUnits)
	do
		if 	unit ~= nil and unit:IsAlive() 
			and not unit:HasModifier('modifier_fountain_glyph') 
			and not unit:IsIllusion()
			and not unit:IsMagicImmune()
			and not unit:IsInvulnerable()
			and unit:GetHealth() <= 1100
			and not unit:IsAncientCreep()
			and unit:GetMagicResist() < 1.05 - unit:GetHealth()/1100
			and not unit:WasRecentlyDamagedByAnyHero(2.5)
			and not J.IsOtherAllysTarget(unit)
			and string.find(unit:GetUnitName(),'siege') == nil 
			and ( nLV < 25 or unit:GetTeam() == TEAM_NEUTRAL )
		then
			if string.find(unit:GetUnitName(),'ranged') ~= nil
				and unit:GetHealth() > GetBot():GetAttackDamage() * 2
		    then
			   return unit,500; 
			end
		
			if unit:GetHealth() > nStrongestUnitHealth
			then
				nStrongestUnitHealth = unit:GetHealth()
				nStrongestUnit = unit;
			end
		end
	end

	return nStrongestUnit,nStrongestUnitHealth	
end

return X;