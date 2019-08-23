-----------------
--英雄：天穹守望者
--技能：磁场
--键位：W
--类型：指向地点
--作者：决明子
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('arc_warden_magnetic_field')
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
        bot:ActionQueue_UseAbilityOnLocation( ability, castTarget ) --使用技能
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
       or X.IsDoubleCasting()
	then 
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end
    
    -- Get some of its values
	local nRadius = ability:GetSpecialValueInt( "radius" );
	local nCastRange = ability:GetCastRange();

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot) 
	   and not bot:HasModifier("modifier_arc_warden_magnetic_field") 
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if ( J.IsValid(npcEnemy) and bot:WasRecentlyDamagedByHero( npcEnemy, 2.0 ) ) 
			then
				return BOT_ACTION_DESIRE_MODERATE, bot:GetLocation();
			end
		end
	end

	if bot:GetActiveMode() == BOT_MODE_ROSHAN
	   and not bot:HasModifier("modifier_arc_warden_magnetic_field") 
	then
		local npcTarget = bot:GetAttackTarget();
		if ( J.IsRoshan(npcTarget) and J.CanCastOnMagicImmune(npcTarget) and J.IsInRange(npcTarget, bot, nCastRange)  )
		then
			return BOT_ACTION_DESIRE_LOW, bot:GetLocation();
		end
	end
	
	-- If we're farming and can kill 3+ creeps with LSA
	if bot:GetActiveMode() == BOT_MODE_FARM 
	   and not bot:HasModifier("modifier_arc_warden_magnetic_field") 
	then
		local locationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), 600, nRadius, 0, 0 );
		if ( locationAoE.count >= 3  ) then
			return BOT_ACTION_DESIRE_HIGH, bot:GetLocation();
		end
	end

	if J.IsInTeamFight(bot, 1200)
	then
		local locationAoE = bot:FindAoELocation( false, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 );
		if ( locationAoE.count >= 2 ) then
			local targetAllies = J.GetAlliesNearLoc(locationAoE.targetloc, nRadius);
			if J.IsValidHero(targetAllies[1]) 
				and not targetAllies[1]:HasModifier("modifier_arc_warden_magnetic_field")
				and targetAllies[1]:GetAttackTarget() ~= nil
				and GetUnitToUnitDistance(targetAllies[1],targetAllies[1]:GetAttackTarget()) <= targetAllies[1]:GetAttackRange() +50
			then
				return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
			end
		end
	end

	-- If we're pushing or defending a lane and can hit 4+ creeps, go for it
	if J.IsDefending(bot) or J.IsPushing(bot) and not bot:HasModifier("modifier_arc_warden_magnetic_field")
	then
		local tableNearbyEnemyCreeps = bot:GetNearbyLaneCreeps( 800, true );
		local tableNearbyEnemyTowers = bot:GetNearbyTowers( 800, true );
		if ( tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 3 ) 
		   or ( tableNearbyEnemyTowers ~= nil and #tableNearbyEnemyTowers >= 1 ) 
		then
			return BOT_ACTION_DESIRE_LOW, bot:GetLocation();
		end
	end
	
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if J.IsValidHero(npcTarget) and  J.IsInRange(npcTarget, bot, nCastRange)  
		then
			local tableNearbyAttackingAlliedHeroes = bot:GetNearbyHeroes( nCastRange, false, BOT_MODE_ATTACK );
			for _,npcAlly in pairs( tableNearbyAttackingAlliedHeroes )
			do
				if J.IsValid(npcAlly) 
				    and ( J.IsInRange(npcAlly, bot, nCastRange) and not npcAlly:HasModifier("modifier_arc_warden_magnetic_field") ) 
					and ( J.IsValid(npcAlly:GetAttackTarget()) and GetUnitToUnitDistance(npcAlly,npcAlly:GetAttackTarget()) <= npcAlly:GetAttackRange() )
				then
					return BOT_ACTION_DESIRE_MODERATE, npcAlly:GetLocation();
				end
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

function X.IsDoubleCasting()
	if npcDouble == nil 
		or not npcDouble:IsAlive()
	then
		return false;
	end

	local nAlly = bot:GetNearbyHeroes(1200,false,BOT_MODE_NONE);
	for _,ally in pairs(nAlly)
	do
		if J.IsValid(ally)
			and ally ~= bot
			and ally:GetUnitName() == "npc_dota_hero_arc_warden"
			and (ally:IsCastingAbility() or ally:IsUsingAbility())
		then
			return true;
		end
	end	

	return false;
end

return X;