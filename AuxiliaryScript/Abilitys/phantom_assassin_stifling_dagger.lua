-----------------
--英雄：幻影刺客
--技能：窒碍短匕
--键位：Q
--类型：指向单位
--作者：决明子
-----------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local U = require( GetScriptDirectory()..'/AuxiliaryScript/Generic')

--初始数据
local ability = bot:GetAbilityByName('phantom_assassin_stifling_dagger')
local nKeepMana, nMP, nHP, nLV, hEnemyHeroList, hAlleyHeroList;

nKeepMana = 400 --魔法储量
nLV = bot:GetLevel(); --当前英雄等级
nMP = bot:GetMana()/bot:GetMaxMana(); --目前法力值/最大法力值（魔法剩余比）
nHP = bot:GetHealth()/bot:GetMaxHealth();--目前生命值/最大生命值（生命剩余比）
hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内敌人
hAlleyHeroList = bot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);--1600范围内队友

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
	local nAttackDamage = bot:GetAttackDamage();
	local nCastRange  = ability:GetCastRange();
	if nCastRange < 600 then nCastRange = 600 end;	
	local nCastPoint  = ability:GetCastPoint();
	local nManaCost   = ability:GetManaCost();
	local nSkillLV    = ability:GetLevel(); 
	local nBonusPer   = 0.1 + 0.15 * nSkillLV;
	local nDamage     = 65 + nAttackDamage * nBonusPer;
	local nBonusDamage= 24 * nBonusPer;
	
	local nDamageType = DAMAGE_TYPE_PHYSICAL;
	
	local nAllies =  bot:GetNearbyHeroes(1200,false,BOT_MODE_NONE);
	
	local nEnemysHerosInView  = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	local nEnemysHerosInRange = bot:GetNearbyHeroes(nCastRange +50,true,BOT_MODE_NONE);
	local nEnemysHerosInBonus = bot:GetNearbyHeroes(nCastRange + 300,true,BOT_MODE_NONE);
		
	
	--击杀敌人
	for _,npcEnemy in pairs( nEnemysHerosInBonus )
	do
		if J.IsValid(npcEnemy)
		   and J.CanCastOnNonMagicImmune(npcEnemy)
		   and J.CanCastOnTargetAdvanced(npcEnemy)
		   and GetUnitToUnitDistance(bot,npcEnemy) <= nCastRange + 80
		   and ( J.CanKillTarget(npcEnemy,nDamage *1.38,nDamageType) 
		         or ( npcEnemy:IsChanneling() and J.GetHPR(npcEnemy) < 0.25))
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
		end
	end
	
	
	--团战中对血量最低的敌人使用
	if J.IsInTeamFight(bot, 1200)
	then
		local npcWeakestEnemy = nil;
		local npcWeakestEnemyHealth = 10000;		
		
		for _,npcEnemy in pairs( nEnemysHerosInRange )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and J.CanCastOnTargetAdvanced(npcEnemy)
			then
				local npcEnemyHealth = npcEnemy:GetHealth();
				if ( npcEnemyHealth < npcWeakestEnemyHealth )
				then
					npcWeakestEnemyHealth = npcEnemyHealth;
					npcWeakestEnemy = npcEnemy;
				end
			end
		end
		
		if ( npcWeakestEnemy ~= nil )
		then
			return BOT_ACTION_DESIRE_HIGH, npcWeakestEnemy;
		end		
	end
	
	--对线期间对线上小兵和敌人使用
	if bot:GetActiveMode() == BOT_MODE_LANING or ( nLV <= 14 and ( nLV <= 7 or bot:GetAttackTarget() == nil ))
	then
		local nLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange +80,true);
		local keyWord = "ranged";
		for _,creep in pairs(nLaneCreeps)
		do
			if J.IsValid(creep)
				and not creep:HasModifier("modifier_fountain_glyph")
				and J.IsKeyWordUnit(keyWord,creep)
				and ( GetUnitToUnitDistance(creep,bot) > 350 or nDamage + nBonusDamage -10 > nAttackDamage + 24)
			then
				local nTime = nCastPoint + GetUnitToUnitDistance(bot,creep)/1250;
				if J.WillKillTarget(creep,nDamage + nBonusDamage,nDamageType,nTime *0.9)
				then
					lastSkillCreep = creep ;
					return BOT_ACTION_DESIRE_HIGH, creep;
				end
			end
		end
		
		if bot:GetMana() > 100 + nLV * 10
		then
			local keyWord = "melee";
			for _,creep in pairs(nLaneCreeps)
			do
				if J.IsValid(creep)
					and not creep:HasModifier("modifier_fountain_glyph")
					and J.IsKeyWordUnit(keyWord,creep)
					and GetUnitToUnitDistance(creep,bot) > 320 + nLV * 20
				then
					local nTime = nCastPoint + GetUnitToUnitDistance(bot,creep)/1250;
					if J.WillKillTarget(creep,nDamage + nBonusDamage,nDamageType,nTime *0.9)
					then
						lastSkillCreep = creep ;
						return BOT_ACTION_DESIRE_HIGH, creep;
					end
				end
			end
		end
		
		--对线期间对敌人使用
		local nWeakestEnemyLaneCreep = J.GetVulnerableWeakestUnit(false, true, nCastRange +100, bot);
		local nWeakestEnemyLaneHero  = J.GetVulnerableWeakestUnit(true , true, nCastRange +40, bot);
		if nWeakestEnemyLaneCreep == nil 
		   or (nWeakestEnemyLaneCreep ~= nil 
				and not J.CanKillTarget(nWeakestEnemyLaneCreep,(nDamage+nBonusDamage) *2,nDamageType) )
		then
			if nWeakestEnemyLaneHero ~= nil 
				and ( J.GetHPR(nWeakestEnemyLaneHero) <= 0.48
					  or GetUnitToUnitDistance(bot,nWeakestEnemyLaneHero) < 350 )
			then
				return BOT_ACTION_DESIRE_HIGH, nWeakestEnemyLaneHero;
			end
		end
		
		-- 打断回复
		for _,npcEnemy in pairs( nEnemysHerosInRange )
		do
			if J.IsValid(npcEnemy)
			   and J.CanCastOnNonMagicImmune(npcEnemy)
			   and GetUnitToUnitDistance(bot,npcEnemy) <= nCastRange + 80
			   and ( npcEnemy:HasModifier("modifier_flask_healing") 
					 or npcEnemy:HasModifier("modifier_clarity_potion")
					 or npcEnemy:HasModifier("modifier_bottle_regeneration")
					 or npcEnemy:HasModifier("modifier_rune_regen") )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end	
	
	
	--打架时先手	
	if J.IsGoingOnSomeone(bot)
	then
	    local npcTarget = J.GetProperTarget(bot);
		if J.IsValidHero(npcTarget) 
			and J.CanCastOnNonMagicImmune(npcTarget) 
			and J.CanCastOnTargetAdvanced(npcTarget)
			and J.IsInRange(npcTarget, bot, nCastRange +50) 
		then
			if nSkillLV >= 3 
			   or nMP > 0.6 or nHP < 0.4  
			   or J.GetHPR(npcTarget) < 0.38 
			   or DotaTime() > 6 *60
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	
	
	--撤退时保护自己
	if J.IsRetreating(bot) 
		and #nEnemysHerosInBonus <= 2
	then
		for _,npcEnemy in pairs( nEnemysHerosInRange )
		do
			if  J.IsValid(npcEnemy)
			    and bot:WasRecentlyDamagedByHero( npcEnemy, 5.0 ) 
				and J.CanCastOnNonMagicImmune(npcEnemy) 
				and J.CanCastOnTargetAdvanced(npcEnemy)
				and not J.IsDisabled(true, npcEnemy) 
				and ( bot:IsFacingLocation(npcEnemy:GetLocation(),45)
						or not J.IsInRange(npcEnemy,bot,nCastRange - 300) )
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	
	--发育时对野怪输出
	if  J.IsFarming(bot) 
		and ( nSkillLV >= 3 or nMP > 0.88 )
		and J.IsAllowedToSpam(bot, nManaCost *2)
	then
		local nCreeps = bot:GetNearbyNeutralCreeps(nCastRange +80);
		
		local targetCreep = J.GetMostHpUnit(nCreeps);
		
		if J.IsValid(targetCreep)
			and GetUnitToUnitDistance(targetCreep,bot) >= 600
			and not J.IsRoshan(targetCreep)
			and ( not J.CanKillTarget(targetCreep,nDamage + nBonusDamage,nDamageType) or #nCreeps == 1 )
		then
			return BOT_ACTION_DESIRE_HIGH, targetCreep;
	    end
	end
	
	
	--推进时对小兵用
	if  (J.IsPushing(bot) or J.IsDefending(bot) or J.IsFarming(bot))
	    and J.IsAllowedToSpam(bot, nManaCost)
		and ( bot:GetAttackDamage() >= 100 or nLV >= 15 )
		and #nEnemysHerosInView == 0
		and #nAllies <= 2
	then
	
		--补刀远程程兵
		local nLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange + 88,true);
		local keyWord = "ranged"
		for _,creep in pairs(nLaneCreeps)
		do
			if J.IsValid(creep)
				and not creep:HasModifier("modifier_fountain_glyph")
			then
				if J.IsKeyWordUnit(keyWord,creep)
				then
					local nTime = nCastPoint + GetUnitToUnitDistance(bot,creep)/1250;
					if J.WillKillTarget(creep,nDamage + nBonusDamage,nDamageType,nTime *0.9)
					then
						return BOT_ACTION_DESIRE_HIGH, creep;
					end
				end
				
				if  not J.CanKillTarget(creep,bot:GetAttackDamage(),DAMAGE_TYPE_PHYSICAL)
					and not J.IsInRange(creep,bot,nCastRange - 300)
					and ( J.CanKillTarget(creep,nDamage-2,nDamageType)
						 or J.GetUnitAllyCountAroundEnemyTarget(creep, 450) <= 1)
				then
					return BOT_ACTION_DESIRE_HIGH, creep;
				end
			
			end
		end
		
		--补刀非狂战范围内的兵
		local keyWord = "melee";
		for _,creep in pairs(nLaneCreeps)
		do
			if J.IsValid(creep)
				and not creep:HasModifier("modifier_fountain_glyph")
				and J.IsKeyWordUnit(keyWord,creep)
				and GetUnitToUnitDistance(creep,bot) > 350
				and not bot:IsFacingLocation(creep:GetLocation(),80)
			then
				local nTime = nCastPoint + GetUnitToUnitDistance(bot,creep)/1250;
				if J.WillKillTarget(creep,nDamage + nBonusDamage,nDamageType,nTime *0.9)
				then
					return BOT_ACTION_DESIRE_HIGH, creep;
				end
			end
		end
	end
	
	
	--打肉的时候输出
	if  bot:GetActiveMode() == BOT_MODE_ROSHAN 
		and bot:GetMana() >= 200
	then
		local npcTarget = bot:GetAttackTarget();
		if  J.IsRoshan(npcTarget) 
			and J.IsInRange(npcTarget, bot, nCastRange)  
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	
	--通用消耗敌人或受到伤害时保护自己
	if (#nEnemysHerosInView > 0 or bot:WasRecentlyDamagedByAnyHero(3.0)) 
		and ( bot:GetActiveMode() ~= BOT_MODE_RETREAT or #nAllies >= 2 )
		and #nEnemysHerosInRange >= 1
		and nLV >= 7
	then
		for _,npcEnemy in pairs( nEnemysHerosInRange )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and J.CanCastOnTargetAdvanced(npcEnemy)
				and not J.IsDisabled(true, npcEnemy)			
				and bot:IsFacingLocation(npcEnemy:GetLocation(),80)
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end
	
	return 0;
end

return X;