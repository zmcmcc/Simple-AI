-----------------
--英雄：血魔
--技能：血怒
--键位：Q
--类型：指向目标
--作者：决明子
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('bloodseeker_bloodrage')
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
	local nCastRange = ability:GetCastRange();
	local nCastPoint = ability:GetCastPoint();
	local nManaCost  = ability:GetManaCost();
	local nDamage    = bot:GetAttackDamage()+ (( ability:GetSpecialValueInt( 'damage_increase_pct' ) / 100 ) * bot:GetAttackDamage());
	
	local npcTarget = J.GetProperTarget(bot);
	
	--对线期提高补刀
	if   bot:GetActiveMode() == BOT_MODE_LANING  
	     and not bot:HasModifier('modifier_bloodseeker_bloodrage')
	then
		local tableNearbyEnemyCreeps = bot:GetNearbyLaneCreeps( 1000, true );
		local tableNearbyAllyCreeps  = bot:GetNearbyLaneCreeps( 1000, false );
		for _,ECreep in pairs(tableNearbyEnemyCreeps)
		do
			if  J.IsValid(ECreep) and J.CanKillTarget(ECreep, nDamage *1.38, DAMAGE_TYPE_PHYSICAL) then
				return BOT_ACTION_DESIRE_HIGH, bot;
			end
		end
		for _,ACreep in pairs(tableNearbyAllyCreeps)
		do
			if  J.IsValid(ACreep) and J.CanKillTarget(ACreep, nDamage *1.18, DAMAGE_TYPE_PHYSICAL) then
				return BOT_ACTION_DESIRE_HIGH, bot;
			end
		end
	end	
	
	--打野时吸血
	if  J.IsValid(npcTarget) and npcTarget:GetTeam() == TEAM_NEUTRAL 
	    and not bot:HasModifier('modifier_bloodseeker_bloodrage')
	then
		local tableNearbyCreeps = bot:GetNearbyCreeps( 1000, true );
		for _,ECreep in pairs(tableNearbyCreeps)
		do
			if J.IsValid(ECreep) and J.CanKillTarget(ECreep, nDamage, DAMAGE_TYPE_PHYSICAL) then
				return BOT_ACTION_DESIRE_HIGH, bot;
			end
		end
	end	
	

	--打野时提高输出
	if J.IsFarming(bot) 
		and #hEnemyHeroList == 0
		and bot:GetHealth() > 300
	then
	
		if not bot:HasModifier('modifier_bloodseeker_bloodrage')
		   and bBotMagicImune
		then
			return BOT_ACTION_DESIRE_HIGH, bot;
		end
		
		if J.IsValid(npcTarget)
			and npcTarget:GetTeam() == TEAM_NEUTRAL
			and not J.CanKillTarget(npcTarget, nDamage * 2.18, DAMAGE_TYPE_PHYSICAL)
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	--打肉时破林肯
	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		if not bot:HasModifier('modifier_bloodseeker_bloodrage')
		then
			return BOT_ACTION_DESIRE_HIGH, bot;
		end	
	
		local npcTarget = J.GetProperTarget(bot);
		if ( J.IsRoshan(npcTarget) 
		     and J.IsInRange(npcTarget, bot, nCastRange) 
		     and not npcTarget:HasModifier('modifier_bloodseeker_bloodrage')  )
		then
			return BOT_ACTION_DESIRE_LOW, npcTarget;
		end
	end

	--团战时辅助
	if J.IsInTeamFight(bot, 1200) or J.IsPushing(bot) or J.IsDefending(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
	    
		if  #tableNearbyEnemyHeroes >= 1 then
			local tableNearbyAllyHeroes = bot:GetNearbyHeroes( nCastRange + 200, false, BOT_MODE_NONE );
			local highesAD = 0;
			local highesADUnit = nil;
			
			for _,npcAlly in pairs( tableNearbyAllyHeroes )
			do
				local AllyAD = npcAlly:GetAttackDamage();
				if ( J.IsValid(npcAlly) 
					 and npcAlly:GetAttackTarget() ~= nil
				     and J.CanCastOnNonMagicImmune(npcAlly) 
					 and ( J.GetHPR(npcAlly) > 0.18 or J.GetHPR(npcAlly:GetAttackTarget()) < 0.18 )
					 and not npcAlly:HasModifier('modifier_bloodseeker_bloodrage')
					 and AllyAD > highesAD ) 
				then
					highesAD = AllyAD;
					highesADUnit = npcAlly;
				end
			end
			
			if highesADUnit ~= nil then
				return BOT_ACTION_DESIRE_HIGH, highesADUnit;
			end
		
		end	
		
	end
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = J.GetProperTarget(bot);
		if J.IsValidHero(npcTarget) 
		   and J.CanCastOnNonMagicImmune(npcTarget) 
		   and J.IsInRange(npcTarget, bot, nCastRange + 150) 
		then
		    if J.IsDisabled(true, npcTarget) 
			   and J.GetHPR(npcTarget) < 0.62
			   and J.GetProperTarget(npcTarget) == nil
			   and not npcTarget:HasModifier('modifier_bloodseeker_bloodrage')
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			elseif not bot:HasModifier('modifier_bloodseeker_bloodrage') 
			    then 
				    return BOT_ACTION_DESIRE_HIGH, bot;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

return X;