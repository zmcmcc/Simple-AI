-----------------
--英雄：撼地者
--技能：回音击
--键位：R
--类型：无目标
--作者：Halcyon
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('earthshaker_echo_slam')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList;

nKeepMana = 180 --魔法储量
nLV = bot:GetLevel(); --当前英雄等级
nMP = bot:GetMana()/bot:GetMaxMana(); --目前法力值/最大法力值（魔法剩余比）
nHP = bot:GetHealth()/bot:GetMaxHealth();--目前生命值/最大生命值（生命剩余比）
hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内敌人
hAlleyHeroList = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);--1600范围内队友

--初始化函数库
U.init(nLV, nMP, nHP, bot);

--技能释放功能
function X.Release(castTarget)
    X.Compensation() 
    bot:ActionQueue_UseAbility( ability ) --使用技能
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

    local nCastRange = 0;
	local nRadius = ability:GetAOERadius() - 80
	local nCastPoint = ability:GetCastPoint()
	
	local nAllys = bot:GetNearbyHeroes( 1200, false, BOT_MODE_NONE );
	local nEenemys = bot:GetNearbyHeroes(nRadius,true,BOT_MODE_NONE)
	local WeakestEnemy = J.GetVulnerableWeakestUnit(true, true, nRadius + 300, bot);
	local WeakestCreep = J.GetVulnerableWeakestUnit(false, true, nRadius + 300, bot);
	local nCreeps = bot:GetNearbyCreeps(nRadius,true)

	if nEenemys == nil then nEenemys = {} end
	if nCreeps == nil then nCreeps = {} end
	local count = #nEenemys+#nCreeps
	local nDamage = ability:GetSpecialValueInt("AbilityDamage")+count*ability:GetSpecialValueInt("echo_slam_echo_damage")
	
	
	-- If we're going after someone
    if bot:GetActiveMode() == BOT_MODE_ROAM
       or bot:GetActiveMode() == BOT_MODE_TEAM_ROAM
       or bot:GetActiveMode() == BOT_MODE_DEFEND_ALLY
       or bot:GetActiveMode() == BOT_MODE_ATTACK
	then
		local i = bot:FindItemSlot("item_blink")
		if i >= 0 and i <= 5
		then
			blink = bot:GetItemInSlot(i)
			i=nil
		end
	
		if blink~=nil and blink:IsFullyCastable()
		then
			local CastRange=1200
			local locationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), CastRange, nRadius, 0, 0 );
			local locationAoE2 = bot:FindAoELocation( true, false, bot:GetLocation(), CastRange, nRadius, 0, 0 );
			if locationAoE.count+locationAoE2.count >= 6
			then
				bot:Action_UseAbilityOnLocation(blink, locationAoE.targetloc);
				return 0
			end
			
			if WeakestEnemy~=nil
			then
				if J.CanCastOnNonMagicImmune(WeakestEnemy)
				then
                    if WeakestEnemy:GetHealth() <= WeakestEnemy:GetActualIncomingDamage(GetUltDamage(WeakestEnemy), DAMAGE_TYPE_MAGICAL) 
                       or WeakestEnemy:GetHealth() <= WeakestEnemy:GetActualIncomingDamage(nDamage, DAMAGE_TYPE_MAGICAL)
					then
						bot:Action_UseAbilityOnLocation(blink, WeakestEnemy:GetLocation());
						return 0
					end
				end
			end
		end
	end
	--------------------------------------
	-- Global high-priorty usage
	--------------------------------------
	--try to kill enemy hero
	if bot:GetActiveMode() ~= BOT_MODE_RETREAT
	then
		if WeakestEnemy~=nil
		then
			if J.CanCastOnNonMagicImmune(WeakestEnemy)
			then
				if WeakestEnemy:GetHealth() <= WeakestEnemy:GetActualIncomingDamage(nDamage, DAMAGE_TYPE_MAGICAL)
				then
					return BOT_ACTION_DESIRE_MODERATE
				end
			end
		end
	end
	
	--------------------------------------
	-- Mode based usage
	--------------------------------------
	-- If we're going after someone
    if bot:GetActiveMode() == BOT_MODE_ROAM
       or bot:GetActiveMode() == BOT_MODE_TEAM_ROAM
       or bot:GetActiveMode() == BOT_MODE_DEFEND_ALLY
       or bot:GetActiveMode() == BOT_MODE_ATTACK
	then
		local npcEnemy = bot:GetTarget();

		if npcEnemy ~= nil and #nEenemys >= 2
		then
            if J.CanCastOnNonMagicImmune( npcEnemy ) 
               and GetUnitToUnitDistance(bot,npcEnemy) <= nRadius
			then
				return BOT_ACTION_DESIRE_HIGH
			end
		end
	end

	if J.IsGoingOnSomeone(bot)
    then
        local npcTarget = J.GetProperTarget(bot);
        if J.IsValidHero(npcTarget) 
        and J.CanCastOnMagicImmune(npcTarget) 
        and J.IsInRange(npcTarget, bot, nCastRange) 
        then
            if count >= 6 then
                return BOT_ACTION_DESIRE_HIGH;
            end	
        end
	end
	
	if J.IsInTeamFight(bot, 1200)
	   and count >= 8
	then
        return BOT_ACTION_DESIRE_HIGH;
    end	

    return BOT_ACTION_DESIRE_NONE;
    
end

return X;
