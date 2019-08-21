-----------------
--英雄：敌法师
--技能：法力虚空
--键位：R
--类型：指向目标
--作者：决明子
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('antimage_mana_void')
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
	local nCastRange = ability:GetCastRange();
	local CastPoint = ability:GetCastPoint();
	local nAoeRange  = 500;
	local nDamageType = DAMAGE_TYPE_MAGICAL;
	local nDamagaPerHealth = ability:GetSpecialValueFloat("mana_void_damage_per_mana");
	local nCastTarget = nil;

	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = J.GetProperTarget(bot);
		if J.IsValidHero(npcTarget) 
		   and J.IsInRange(npcTarget, bot, nCastRange +200) 
		   and J.CanCastOnNonMagicImmune(npcTarget) 
		   and J.CanCastOnTargetAdvanced(npcTarget)
		   and not J.IsHaveAegis(npcTarget)
		   and not npcTarget:HasModifier("modifier_arc_warden_tempest_double")
		then
			local EstDamage = nDamagaPerHealth * ( npcTarget:GetMaxMana() - npcTarget:GetMana() )
			if J.WillMagicKillTarget(bot,npcTarget, EstDamage, CastPoint) 
			then
				X.ReportDetails(bot,npcTarget,EstDamage);
				nCastTarget = npcTarget;
				return BOT_ACTION_DESIRE_HIGH, nCastTarget;
			end
		end
	end
	

	-- If we're in a teamfight, use it on the scariest enemy
	if J.IsInTeamFight(bot, 1200)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 700, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			local EstDamage = nDamagaPerHealth * ( npcEnemy:GetMaxMana() - npcEnemy:GetMana() )
			if J.IsValidHero(npcEnemy) 
			   and J.CanCastOnTargetAdvanced(npcEnemy) 
			   and J.CanCastOnNonMagicImmune(npcEnemy) 
			   and not J.IsHaveAegis(npcEnemy)
		       and not npcEnemy:HasModifier("modifier_arc_warden_tempest_double")
			   and J.IsInRange(npcEnemy, bot, nCastRange +150) 
			   and ( J.WillMagicKillTarget(bot,npcEnemy, EstDamage, CastPoint) ) 
			then
				X.ReportDetails(bot,npcEnemy,EstDamage);
				nCastTarget = npcEnemy;
				break;
			end
		end

		if (nCastTarget ~= nil  )
		then
			bot:SetTarget(nCastTarget);
			return BOT_ACTION_DESIRE_HIGH, nCastTarget;
		end
	end
	
	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange + 100, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		local EstDamage = nDamagaPerHealth * ( npcEnemy:GetMaxMana() - npcEnemy:GetMana() )
		local TPerMana = npcEnemy:GetMana()/npcEnemy:GetMaxMana();
		if J.IsValidHero(npcEnemy) 
		   and J.CanCastOnTargetAdvanced(npcEnemy) 
		   and J.CanCastOnNonMagicImmune(npcEnemy) 
		then
		
			if npcEnemy:IsChanneling()
				and npcEnemy:HasModifier("modifier_teleporting") 
				and not npcEnemy:HasModifier("modifier_arc_warden_tempest_double")
			then
				nCastTarget = npcEnemy;
			end
			
			if  TPerMana < 0.01
				and not J.IsHaveAegis(npcEnemy)
		        and not npcEnemy:HasModifier("modifier_arc_warden_tempest_double")
				and ( J.WillMagicKillTarget(bot,npcEnemy, EstDamage * 1.68, CastPoint)
					  or ( J.GetAroundTargetEnemyHeroCount(npcEnemy,nAoeRange) >= 3 and J.CanKillTarget(npcEnemy,EstDamage * 1.98,nDamageType) )
					  or nHP < 0.25 )
			then
				nCastTarget = npcEnemy;
			end
			
			local nEnemys = bot:GetNearbyHeroes( 1600, true, BOT_MODE_NONE );
			for _,enemy in pairs(nEnemys)
			do
				if GetUnitToLocationDistance(npcEnemy,enemy:GetExtrapolatedLocation(CastPoint)) < nAoeRange
				   and J.CanCastOnNonMagicImmune(enemy) 
				   and not J.IsHaveAegis(enemy)
				   and not enemy:HasModifier("modifier_arc_warden_tempest_double")
				   and J.WillMagicKillTarget(bot,enemy, EstDamage, CastPoint)
				then
					nCastTarget = npcEnemy;
					X.ReportDetails(bot,enemy,EstDamage);
					break;
				end			
			end			
		
			if (nCastTarget ~= nil  )
			then
				bot:SetTarget(nCastTarget);
				return BOT_ACTION_DESIRE_HIGH, nCastTarget;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

local ReportTime = 99999;
function X.ReportDetails(bot,npcTarget,EstDamage)

	if DotaTime() > ReportTime + 5.0
	then
		local nMessage;
		local nNumber;
		local MagicResist = 1 - npcTarget:GetMagicResist();
		local rCastPoint = abilityR:GetCastPoint();
		local wCastPoint = abilityW:GetCastPoint();
		
		ReportTime = DotaTime();
		
		nMessage = "基础伤害:"
		nNumber  = EstDamage * MagicResist;
		bot:ActionImmediate_Chat(nMessage..tostring(J.GetOne(nNumber)),true);
		
		-- nMessage = "计算伤害值:";
		-- nNumber  =  J.GetFutureMagicDamage(bot,npcTarget, EstDamage, wCastPoint + rCastPoint);
		-- bot:ActionImmediate_Chat(nMessage..tostring(J.GetOne(nNumber)),true);
		
		nMessage = npcTarget:GetUnitName();
		nNumber  = npcTarget:GetHealth();
		bot:ActionImmediate_Chat(string.gsub(tostring(nMessage),"npc_dota_","")..'当前生命值:'..tostring(nNumber),true);

	end

end

return X;