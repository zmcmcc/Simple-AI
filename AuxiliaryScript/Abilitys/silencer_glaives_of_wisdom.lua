-----------------
--英雄：沉默术士
--技能：智慧之刃
--键位：w
--类型：指向目标
--作者：决明子
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('silencer_glaives_of_wisdom')
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
	   or bot:IsDisarmed()
	then
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end
	
	local nAttackRange = bot:GetAttackRange() + 50;
	local nAttackDamage = bot:GetAttackDamage();
	local nAbilityDamage = ability:GetSpecialValueInt("intellect_damage_pct")/100 * bot:GetAttributeValue(ATTRIBUTE_INTELLECT) * ( 1 + bot:GetSpellAmp() )
	local nCastRange = nAttackRange;

	local nTowers = bot:GetNearbyTowers(900,true)
	local nEnemysLaneCreepsInRange = bot:GetNearbyLaneCreeps(nAttackRange + 100,true)
	local nEnemysLaneCreepsInBonus = bot:GetNearbyLaneCreeps(400,true)
	local nEnemysWeakestLaneCreepsInRange = J.GetVulnerableWeakestUnit(false, true, nAttackRange + 100, bot)
	
	local nEnemysHerosInAttackRange = bot:GetNearbyHeroes(nAttackRange,true,BOT_MODE_NONE);
	local nEnemysWeakestHerosInAttackRange = J.GetVulnerableWeakestUnit(true, true, nAttackRange, bot)
	local nEnemysWeakestHero = J.GetVulnerableWeakestUnit(true, true, nAttackRange + 40, bot)
	
	local nAllyLaneCreeps = bot:GetNearbyLaneCreeps(350,false)
	
	local npcTarget = J.GetProperTarget(bot);
	
	--try to kill enemy hero
	if(bot:GetActiveMode() ~= BOT_MODE_RETREAT or bot:GetActiveModeDesire( ) < 0.6) 
	then
		if J.IsValidHero(nEnemysWeakestHerosInAttackRange)
		then
			if nEnemysWeakestHerosInAttackRange:GetHealth() <= sil_RealDamage(nAttackDamage,nAbilityDamage,nEnemysWeakestHerosInAttackRange)
			then
				return BOT_ACTION_DESIRE_HIGH,WeakestEnemy; 
			end
		end
	end
	
	
	if nLV > 9
	then
		if not ability:GetAutoCastState( ) 
		then
			ability:ToggleAutoCast()
		end
	else
		if  ability:GetAutoCastState( ) 
		then
			ability:ToggleAutoCast()
		end
	end
	
	if nLV <= 9 
	   and not J.IsRunning(bot)
	   and nHP > 0.55
	then
		if  J.IsValidHero(npcTarget)
			and GetUnitToUnitDistance(bot,npcTarget) < nAttackRange + 99
		then
			nTargetUint = npcTarget;
			return BOT_ACTION_DESIRE_HIGH, nTargetUint;
		end	
	end
	
	
	if ( bot:GetActiveMode() == BOT_MODE_LANING and #nTowers == 0) 
	then
		if J.IsValid(nEnemysWeakestHero)
		then		    
			if  nHP >= 0.62 
				and #nEnemysLaneCreepsInBonus <= 6 
				and #nAllyLaneCreeps >= 2
				and not bot:WasRecentlyDamagedByCreep(1.5)
				and not bot:WasRecentlyDamagedByAnyHero(1.5)
			then
				return BOT_ACTION_DESIRE_HIGH,nEnemysWeakestHero;	
			end
			
			
			if J.GetAllyUnitCountAroundEnemyTarget(nEnemysWeakestHero, 500, bot) >= 3
			   and nHP >= 0.6 
			   and not bot:WasRecentlyDamagedByCreep(1.5)
			   and not bot:WasRecentlyDamagedByAnyHero(1.5)
			then
				return BOT_ACTION_DESIRE_HIGH,nEnemysWeakestHero;
			end
			
		end
	end
	
	
	if  J.IsValidHero(npcTarget)
		and GetUnitToUnitDistance(npcTarget,bot) >  nAttackRange + 200
		and J.IsValidHero(nEnemysHerosInAttackRange[1])
		and J.CanBeAttacked(nEnemysHerosInAttackRange[1])
		and bot:GetActiveMode() ~= BOT_MODE_RETREAT
	then
		return BOT_ACTION_DESIRE_HIGH, nEnemysHerosInAttackRange[1];
	end
	
	
	if  npcTarget == nil
	    and  bot:GetActiveMode() ~= BOT_MODE_RETREAT 
	    and  bot:GetActiveMode() ~= BOT_MODE_ATTACK 
		and  bot:GetActiveMode() ~= BOT_MODE_ASSEMBLE
		and  J.GetTeamFightAlliesCount(bot) < 3
	then
		
		if J.IsValid(nEnemysWeakestLaneCreepsInRange)
			and not J.IsOtherAllysTarget(nEnemysWeakestLaneCreepsInRange)
		then
			local nCreep = nEnemysWeakestLaneCreepsInRange;
			local nAttackProDelayTime = J.GetAttackProDelayTime(bot,nCreep)
			
			local otherAttackRealDamage = J.GetTotalAttackWillRealDamage(nCreep,nAttackProDelayTime);
			local silRealDamage = sil_RealDamage(nAttackDamage,nAbilityDamage,nCreep);
			
			if otherAttackRealDamage + silRealDamage > nCreep:GetHealth() +1
			   and not J.CanKillTarget(nCreep, nAttackDamage, DAMAGE_TYPE_PHYSICAL)
			then	

				local nTime = nAttackProDelayTime;
				local rMessage = "生命:"..tostring(nCreep:GetHealth()).."增益:"..tostring(J.GetOne(nAbilityDamage)).."额外:"..tostring(J.GetOne(otherAttackRealDamage)).."总共:";
				J.SetReportAndPingLocation(nCreep:GetLocation(),rMessage,otherAttackRealDamage + silRealDamage); 
			
				return BOT_ACTION_DESIRE_HIGH,nCreep;
			end
			
		end
		
        if ( bot:HasScepter() or nAttackDamage > 160)
			and #hEnemyHeroList == 0
		then
			local nEnemysCreeps = bot:GetNearbyCreeps(800,true)
			if J.IsValid(nEnemysCreeps[1])
			then
				return BOT_ACTION_DESIRE_HIGH,nEnemysCreeps[1];
			end
		end
		
		
		local nNeutrals = bot:GetNearbyNeutralCreeps(800);
		if DotaTime()%60>52 and DotaTime()%60 < 54.5
			and  J.IsValid(nNeutrals[1])
			and not nNeutrals[1]:WasRecentlyDamagedByAnyHero(3.0)
		then
			return BOT_ACTION_DESIRE_HIGH,nNeutrals[1];
		end
		
		
		local nNeutralCreeps = bot:GetNearbyNeutralCreeps(1600);
		local botMode = bot:GetActiveMode();
		if botMode ~= BOT_MODE_LANING
			and botMode ~= BOT_MODE_FARM
			and botMode ~= BOT_MODE_RUNE
			and botMode ~= BOT_MODE_ASSEMBLE
			and botMode ~= BOT_MODE_SECRET_SHOP
			and botMode ~= BOT_MODE_SIDE_SHOP
			and botMode ~= BOT_MODE_WARD
			and GetRoshanDesire() < BOT_MODE_DESIRE_HIGH	
			and not bot:WasRecentlyDamagedByAnyHero(2.0)
			and #hEnemyHeroList == 0
			and nAttackDamage > 140 
			and J.IsValid(nNeutralCreeps[1])
			and not J.IsRoshan(nNeutralCreeps[1])
			and (not nNeutralCreeps[1]:IsAncientCreep() or nAttackDamage > 180)
		then
			nTargetUint = nNeutralCreeps[1];
			return BOT_ACTION_DESIRE_HIGH, nTargetUint;
		end
		
	end
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot) 
	then
		if J.IsValidHero(npcTarget) 
			and J.CanCastOnNonMagicImmune(npcTarget)
			and J.IsInRange(npcTarget, bot, nAttackRange + 80)
		then
			return BOT_ACTION_DESIRE_MODERATE, npcTarget;
		end
	end
	
	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN and not ability:GetAutoCastState() ) 
	then
		local npcTarget = bot:GetAttackTarget();
		if  J.IsRoshan(npcTarget) 
			and J.IsInRange(npcTarget, bot, nAttackRange)			
		then
			return BOT_ACTION_DESIRE_HIGH,npcTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

function sil_RealDamage( nAttackDamage,nAbilityDamage,unit)
	
	local RealDamage = unit:GetActualIncomingDamage(nAttackDamage,DAMAGE_TYPE_PHYSICAL) + unit:GetActualIncomingDamage(nAbilityDamage,DAMAGE_TYPE_PURE);

	return RealDamage;
end

return X;