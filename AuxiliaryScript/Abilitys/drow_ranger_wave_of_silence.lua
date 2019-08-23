-----------------
--英雄：卓尔游侠
--技能：狂风
--键位：W
--类型：指向地点
--作者：决明子
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('drow_ranger_wave_of_silence')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange;

nKeepMana = 90 --魔法储量
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
       or bot:IsInvisible()
	then 
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end
	
	local nCastRange = ability:GetCastRange();
	local nRadius 	 = ability:GetAOERadius();
	local nDamage 	 = 0
	local nCastPoint = ability:GetCastPoint();
	local nTargetLocation = nil;
	
	local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange +100,true,BOT_MODE_NONE)

	
	for _,npcEnemy in pairs( nEnemyHeroes )
	do
		if  J.IsValid(npcEnemy)
			and npcEnemy:IsChanneling()  
			and not npcEnemy:HasModifier("modifier_teleporting") 
			and not npcEnemy:HasModifier("modifier_boots_of_travel_incoming")
		then
			nTargetLocation = npcEnemy:GetLocation();
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation;
		end
	end
	
	
	local skThere, skLoc = J.IsSandKingThere(bot, nCastRange, 2.0);	
	if skThere then
		nTargetLocation = skLoc;
		return BOT_ACTION_DESIRE_HIGH, nTargetLocation;
	end	
	
	
	if bot:GetActiveMode() == BOT_MODE_RETREAT 
	then
			
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange-100, nRadius, nCastPoint, 0 );
		if locationAoE.count >= 2 
		   or (locationAoE.count >= 1 and bot:GetHealth()/bot:GetMaxHealth() < 0.5 ) 
		then
			nTargetLocation = locationAoE.targetloc;
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation;
		end
		
		
		for _,npcEnemy in pairs( nEnemyHeroes )
		do
			if  J.IsValid(npcEnemy)
			    and bot:WasRecentlyDamagedByHero( npcEnemy, 5.0 ) 
				and GetUnitToUnitDistance(bot,npcEnemy) <= 510 
			then
				nTargetLocation = npcEnemy:GetExtrapolatedLocation( nCastPoint );
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation;
			end
		end
	end
	
	
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = J.GetProperTarget(bot);
		if J.IsValidHero(npcTarget) 
			and J.CanCastOnNonMagicImmune(npcTarget) 
			and J.IsInRange(npcTarget, bot, nCastRange)
		    and not npcTarget:IsSilenced()
			and not J.IsDisabled(true, npcTarget)
			and ( npcTarget:IsFacingLocation(bot:GetLocation(),120) 
				  or npcTarget:GetAttackTarget() ~= nil )
		then		
			nTargetLocation = npcTarget:GetExtrapolatedLocation( nCastPoint )
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation;
		end
		
		local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius, nCastPoint, 0 );
		if ( locationAoE.count >= 2 ) 
		then
			nTargetLocation = locationAoE.targetloc;
			return BOT_ACTION_DESIRE_HIGH, nTargetLocation;
		end
		
    end
    
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X;