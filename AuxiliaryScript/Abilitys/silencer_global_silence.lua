-----------------
--英雄：沉默术士
--技能：全领域静默
--键位：R
--类型：无目标
--作者：决明子
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('silencer_global_silence')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList, aetherRange, abilityAhg;

nKeepMana = 300 --魔法储量
nLV = bot:GetLevel(); --当前英雄等级
nMP = bot:GetMana()/bot:GetMaxMana(); --目前法力值/最大法力值（魔法剩余比）
nHP = bot:GetHealth()/bot:GetMaxHealth();--目前生命值/最大生命值（生命剩余比）
hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内敌人
hAlleyHeroList = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);--1600范围内队友

--是否拥有蓝杖
abilityAhg = J.IsItemAvailable("item_ultimate_scepter"); 

--获取以太棱镜施法距离加成
local aether = J.IsItemAvailable("item_aether_lens");
if aether ~= nil then aetherRange = 250 else aetherRange = 0 end
    
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
		return BOT_ACTION_DESIRE_NONE; --没欲望
	end
	
	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1400, true, BOT_MODE_NONE );
	local tableNearbyAllyHeroes = bot:GetNearbyHeroes( 800, false, BOT_MODE_NONE );
	
	-- Check for a channeling enemy
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if  J.IsValid(npcEnemy)
		    and npcEnemy:IsChanneling() 
			and J.CanCastOnNonMagicImmune(npcEnemy) 
			and not npcEnemy:HasModifier("modifier_teleporting")
			and npcEnemy:GetHealth( ) > 500
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	if J.IsRetreating(bot)
	then
		if #tableNearbyEnemyHeroes >= 2 
		   and #tableNearbyAllyHeroes > 2 
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	local numPlayer =  GetTeamPlayers(GetTeam());
	for i = 1, #numPlayer
	do
		local member =  GetTeamMember(i);
		if member ~= nil and member:IsAlive()
		then
			if J.IsInTeamFight(member, 1200)
			then
				local locationAoE = member:FindAoELocation( true, true, member:GetLocation(), 1400, 600, 0, 0 );
				if ( locationAoE.count >= 2 ) then
					return BOT_ACTION_DESIRE_HIGH;
				end
			end						
		end
	end
			
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if J.IsValidHero(npcTarget) 
		   and J.CanCastOnNonMagicImmune(npcTarget) 
		   and J.IsInRange(npcTarget, bot, 1200)
		   and not J.IsDisabled(true, npcTarget)
		then
			local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1600, false, BOT_MODE_NONE );
			if #tableNearbyEnemyHeroes >= 2 
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE;

end

return X;