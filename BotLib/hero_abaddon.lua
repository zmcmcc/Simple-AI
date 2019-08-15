local X = {}
local bot = GetBot() --获取当前电脑

local J = require( GetScriptDirectory()..'/FunLib/jmz_func') --引入jmz_func文件
local Minion = dofile( GetScriptDirectory()..'/FunLib/Minion') --引入Minion文件
local sTalentList = J.Skill.GetTalentList(bot) --获取当前英雄（当前电脑选择的英雄，一下省略为当前英雄）的天赋列表
local sAbilityList = J.Skill.GetAbilityList(bot) --获取当前英雄的技能列表
--英雄天赋树
local tTalentTreeList = {
						['t25'] = {0, 10},
						['t20'] = {0, 10},
						['t15'] = {0, 10},
						['t10'] = {10, 0},
}

--英雄技能树
local tAllAbilityBuildList = {
						{2,1,1,3,1,6,1,2,2,2,6,3,3,3,6},
						{2,3,2,3,2,6,2,3,3,1,6,1,1,1,6},
}
--从技能树中随机选择一套技能
local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)
--根据天赋树生成天赋列表
local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)
--技能和天赋加点方案
X['sBuyList'] = {
				"item_tango",
				"item_flask",
				"item_quelling_blade",
				"item_soul_ring",
				"item_phase_boots",
				"item_blade_mail",
				"item_mjollnir",
				"item_sange_and_yasha",
				"item_radiance",
				"item_satanic",
				"item_heart",
}

X['sSellList'] = {
	"item_crimson_guard",
	"item_quelling_blade",
}


nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList'] = J.SetUserHeroInit(nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList']);


X['sSkillList'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)

X['bDeafaultAbility'] = true
X['bDeafaultItem'] = true

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit(hMinionUnit) 
	then
		if hMinionUnit:IsIllusion() 
		then 
			Minion.IllusionThink(hMinionUnit)	
		end
	end

end
--将英雄技能初始入变量
local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )
--初始化技能欲望与点变量
local castQDesire, castQTarget
local castWDesire, castWTarget
--初始英雄状态变量
local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;

function X.SkillsComplement()

	--如果当前英雄无法使用技能或英雄处于隐形状态，则不做操作。
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
	
	
	--设定一些必要条件
	nKeepMana = 160 --魔法储量 160
	nLV = bot:GetLevel(); --当前英雄等级
	nMP = bot:GetMana()/bot:GetMaxMana(); --目前法力值/最大法力值（魔法剩余比）
	nHP = bot:GetHealth()/bot:GetMaxHealth();--目前生命值/最大生命值（生命剩余比）
	hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内敌人
	
	
	
	
	castQDesire, castQTarget = X.ConsiderQ();--索引第一个技能（快捷键Q）

	if ( castQDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, true) --临时补充魔法，使用魂戒
	
		bot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget ) --使用技能
		return;
	end
	
	castWDesire, castWTarget = X.ConsiderW();--索引第二个技能（快捷键W）
	if ( castWDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, true) --临时补充魔法，使用魂戒
	
		bot:ActionQueue_UseAbilityOnEntity( abilityW, castWTarget )

		local nEnemysHerosInRange = bot:GetNearbyHeroes(1000,true,BOT_MODE_NONE);
		if nHP >= 0.5
			and #nEnemysHerosInRange < 4 
			then --血量大于0.5就追击附近强者
				local npcMostDangerousEnemy = nil;
				local nMostDangerousDamage = 0;		
				
				for _,npcEnemy in pairs( nEnemysHerosInRange )
				do
					if  J.IsValid(npcEnemy)
						and not J.IsDisabled(true, npcEnemy)
						and not npcEnemy:IsDisarmed()
						and npcEnemy:IsHero()
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
					bot:SetTarget(npcMostDangerousEnemy);
					--bot:Action_AttackUnit(npcMostDangerousEnemy, false);
				end	
			end
		return;
	
	end

end

function X.ConsiderQ()--使用Q技能的欲望

	-- 确保技能可以使用
	if not abilityQ:IsFullyCastable()
		or bot:IsRooted()
		or X.ShouldSaveMana(abilityQ) --是否应当节省魔法不去使用技能
	then 
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end

	-- 获取一些必要参数
	local nCastRange  = abilityQ:GetCastRange();	--施法范围
	local nCastPoint  = abilityQ:GetCastPoint();	--施法点
	local nManaCost   = abilityQ:GetManaCost();		--魔法消耗
	local nSkillLV    = abilityQ:GetLevel();    	--技能等级 
	local nDamageOwn  = 25 * ( nSkillLV - 1) + 50;	--技能自身伤害                        
	local nDamage     = 45 * ( nSkillLV - 1) + 75;	--技能伤害
	local nDamageType = DAMAGE_TYPE_MAGICAL;		--伤害类型
	
	local nAlleys =  bot:GetNearbyHeroes(1200,false,BOT_MODE_NONE); --获取1200范围内盟友
	
	local nEnemysHerosInView  = bot:GetNearbyHeroes(1200,true,BOT_MODE_NONE); --获取1200范围内敌人
	
	if #nEnemysHerosInView == 1 --如果敌人只有一个
	   and J.IsValidHero(nEnemysHerosInView[1]) --是英雄
	   and J.IsInRange(nEnemysHerosInView[1],bot,nCastRange + 50) --在施法范围+50内
	   and nEnemysHerosInView[1]:IsFacingLocation(bot:GetLocation(),30) --单位面向目标30°范围内
	   and nEnemysHerosInView[1]:GetAttackRange() > nCastRange --单位的攻击范围在施法范围外
	   and nEnemysHerosInView[1]:GetAttackRange() < 1250 --且小于1250
	then
		nCastRange = nCastRange + 200; --使得施法欲望范围增加200
	end
	
	local nEnemysHerosInRange = bot:GetNearbyHeroes(nCastRange ,true,BOT_MODE_NONE); --获得施法范围内敌人
	local nEnemysHerosInBonus = bot:GetNearbyHeroes(nCastRange + 150,true,BOT_MODE_NONE);--获得施法范围+150内敌人
	
	--击杀
	for _,npcEnemy in pairs( nEnemysHerosInBonus )
	do
		if J.IsValid(npcEnemy)
		   and J.CanCastOnNonMagicImmune(npcEnemy)
		then
			
			if  GetUnitToUnitDistance(bot,npcEnemy) <= nCastRange + 50 --如果在技能范围+50内且有把握击杀
				and J.CanKillTarget(npcEnemy,nDamage,nDamageType)
				and (bot:GetHealth() - nDamageOwn)/bot:GetMaxHealth() >= 0.3
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy; --追杀
			end

			if  GetUnitToUnitDistance(bot,npcEnemy) <= nCastRange --如果在技能范围内且有把握击杀
				and J.CanKillTarget(npcEnemy,nDamage,nDamageType)
			then
				return BOT_ACTION_DESIRE_VERYHIGH, npcEnemy; --直接杀死
			end
			
		end
	end
	
	--团战中对战力最高的敌人使用
	if J.IsInTeamFight(bot, 1200)
	then
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;		
		
		for _,npcEnemy in pairs( nEnemysHerosInRange )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
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
	
	--对线期间对敌方英雄使用
	if bot:GetActiveMode() == BOT_MODE_LANING
	then
		for _,npcEnemy in pairs( nEnemysHerosInBonus )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and not J.IsDisabled(true, npcEnemy)
				and J.GetAttackTargetEnemyCreepCount(npcEnemy, 600) >= 4
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end	
	end
	
	--对线期间对自己使用
	if bot:GetActiveMode() == BOT_MODE_LANING
		and J.IsValid(bot)
		and J.CanCastOnNonMagicImmune(bot) 
	then
		if  nHP <= 0.2
		then
			return BOT_ACTION_DESIRE_HIGH, bot;
		elseif nHP <= 0.6
		then
			return BOT_ACTION_DESIRE_MODERATE, bot;
		end
	end
	
	--打架时先手	
	if J.IsGoingOnSomeone(bot)
	then
	    local npcTarget = J.GetProperTarget(bot);
		if J.IsValidHero(npcTarget) 
			and J.CanCastOnNonMagicImmune(npcTarget) 
			and J.IsInRange(npcTarget, bot, nCastRange +80) 
			and not J.IsDisabled(true, npcTarget)
			and not npcTarget:IsDisarmed()
		then
			if nSkillLV >= 3 or nMP > 0.68 or J.GetHPR(npcTarget) < 0.38 or nHP < 0.25
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end
	
	--撤退时战术输出和撑血 抬手太长
	--if J.IsRetreating(bot) 
	--	and not bot:IsInvisible()
	--then
	--	for _,npcEnemy in pairs( nEnemysHerosInRange )
	--	do
	--		if J.IsValid(npcEnemy)
	--			and nHP < 0.3
	--			and GetUnitToUnitDistance(bot,npcEnemy) >= 100
	--		then
	--			return BOT_ACTION_DESIRE_HIGH, bot;
	--		end

	--		if J.IsValid(npcEnemy)
	--		    and ( bot:WasRecentlyDamagedByHero( npcEnemy, 5.0 ) 
	--					or nMP > 0.8
	--					or GetUnitToUnitDistance(bot,npcEnemy) <= 400 )
	--			and J.CanCastOnNonMagicImmune(npcEnemy) 
	--			and not J.IsDisabled(true, npcEnemy) 
	--			and not npcEnemy:IsDisarmed()
	--		then
	--			return BOT_ACTION_DESIRE_HIGH, npcEnemy;
	--		end
	--	end
	--end
	
	if  J.IsFarming(bot) 
		and nSkillLV >= 3
		and (bot:GetAttackDamage() < 200 or nMP > 0.88)
		and nMP > 0.71
	then
		local nCreeps = bot:GetNearbyNeutralCreeps(nCastRange +100);
		
		local targetCreep = J.GetMostHpUnit(nCreeps);
		
		if J.IsValid(targetCreep)
			and ( #nCreeps >= 2 or GetUnitToUnitDistance(targetCreep,bot) <= 400 )
			and not J.IsRoshan(targetCreep)
			and not J.IsOtherAllysTarget(targetCreep)
			and targetCreep:GetMagicResist() < 0.3
			and not J.CanKillTarget(targetCreep,bot:GetAttackDamage() *1.68,DAMAGE_TYPE_PHYSICAL)
			and not J.CanKillTarget(targetCreep,nDamage,nDamageType)
		then
			return BOT_ACTION_DESIRE_HIGH, targetCreep;
	    end
	end
	
	--受到伤害时保护自己
	if bot:WasRecentlyDamagedByAnyHero(3.0) 
		and bot:GetActiveMode() ~= BOT_MODE_RETREAT
		and not bot:IsInvisible()
		and #nEnemysHerosInRange >= 1
		and nLV >= 6
	then
		for _,npcEnemy in pairs( nEnemysHerosInRange )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and not J.IsDisabled(true, npcEnemy)
                and not npcEnemy:IsDisarmed()				
				and bot:IsFacingLocation(npcEnemy:GetLocation(),45)
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end
	
	--通用消耗敌人或受到伤害时保护自己
	if (#nEnemysHerosInView > 0 or bot:WasRecentlyDamagedByAnyHero(3.0)) 
		and ( bot:GetActiveMode() ~= BOT_MODE_RETREAT or #nAlleys >= 2 )
		and #nEnemysHerosInRange >= 1
		and nLV >= 7
	then
		for _,npcEnemy in pairs( nEnemysHerosInRange )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and not J.IsDisabled(true, npcEnemy)			
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end

	--if bot:GetMaxMana() - bot:GetMana() >= nDamage --魔法充裕时给自己回满血
	--	and J.IsValid(bot)
	--	and J.CanCastOnNonMagicImmune(bot) 
	--	and nMP > 0.9
	--then
	--	return BOT_ACTION_DESIRE_HIGH, bot;
	--end
	
	return 0;

end

function X.ConsiderW()
	-- 确保技能可以使用
	if not abilityW:IsFullyCastable()
	   or bot:IsRooted()
	   or X.ShouldSaveMana(abilityW) --是否应当节省魔法不去使用技能
	   or bot:HasModifier("modifier_abaddon_aphotic_shield") --有盾了
	   or bot:HasModifier("modifier_abaddon_borrowed_time") --开大了
	then 
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end

	--获取一些参数
	local nCastRange = abilityW:GetCastRange();		--施法范围
	local nCastPoint = abilityW:GetCastPoint();		--施法点
	local nManaCost   = abilityW:GetManaCost();		--魔法消耗
	local nSkillLV    = abilityW:GetLevel();    	--技能等级 

	--一些单位
	local nAlleys =  bot:GetNearbyHeroes(nCastRange,false,BOT_MODE_NONE); --获取技能范围内盟友
	local nEnemysHerosInView  = bot:GetNearbyHeroes(1200,true,BOT_MODE_NONE); --获取1200范围内敌人
	local nEnemysHerosInRange = bot:GetNearbyHeroes(nCastRange ,true,BOT_MODE_NONE); --获得施法范围内敌人
	
	--在团战中
	if J.IsInTeamFight(bot, 1200)
	then
		--附件有3人以上的敌人，且自己血量不高，优先自己保命
		if #nEnemysHerosInView > 3
			and J.IsValid(bot)
			and J.CanCastOnNonMagicImmune(bot) 
			and nHP < 0.8
		 then
			return BOT_ACTION_DESIRE_HIGH, bot;
		end
		--低血量参团，优先自己保命
		if J.IsValid(bot)
			and J.CanCastOnNonMagicImmune(bot)
			and nHP < 0.4
			then
			return BOT_ACTION_DESIRE_HIGH, bot;
		end
		--团队有人血量较低，自己血量充沛，给队友保命
		for _,npcEnemy in pairs( nAlleys )
		do
			npcEnemyHP = npcEnemy:GetHealth()/npcEnemy:GetMaxHealth();--队友血量比
			if  J.IsValid(npcEnemy)
				and J.CanCastOnNonMagicImmune(npcEnemy) 
				and nHP > 0.7
				and npcEnemyHP < 0.4
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
		--魔法充裕，给自己套个套子
		if nMP > 0.7 then
				if nHP >= 0.7
					and #nEnemysHerosInView < 4 then --血量大于0.7就追击附近强者
					local npcMostDangerousEnemy = nil;
					local nMostDangerousDamage = 0;		
					
					for _,npcEnemy in pairs( nEnemysHerosInRange )
					do
						if  J.IsValid(npcEnemy)
							and J.CanCastOnNonMagicImmune(npcEnemy) 
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
						bot:SetTarget(npcMostDangerousEnemy);
					end	
				end
			return BOT_ACTION_DESIRE_HIGH, bot;
		end	
	end
	--遭遇战
	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValid(bot)
			and #nEnemysHerosInView > 3
			and J.CanCastOnNonMagicImmune(bot) 
			and nHP < 0.7
		 then
			return BOT_ACTION_DESIRE_HIGH, bot;
		end
		for _,npcEnemy in pairs( nAlleys )
		do
			npcEnemyHP = npcEnemy:GetHealth()/npcEnemy:GetMaxHealth();--队友血量比
			if  J.IsValid(npcEnemy)
				and J.CanCastOnNonMagicImmune(npcEnemy) 
				and nHP > 0.7
				and npcEnemyHP < 0.4
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
		if J.IsValid(bot)
			and J.CanCastOnNonMagicImmune(bot)
			and nMP > 0.6
			then
			return BOT_ACTION_DESIRE_HIGH, bot;
		end	
	end

	--对线期间对自己使用
	if bot:GetActiveMode() == BOT_MODE_LANING or nLV <= 5
	then
		if  nMP >= 0.6
			and #nEnemysHerosInView > 5
			and J.IsValid(bot)
		    and J.CanCastOnNonMagicImmune(bot) 
			and not J.IsDisabled(true, bot)
		then
			return BOT_ACTION_DESIRE_HIGH, bot;
		end
	end

	--受到伤害时保护自己
	if bot:WasRecentlyDamagedByAnyHero(3.0) 
		and bot:GetActiveMode() ~= BOT_MODE_RETREAT
		and not bot:IsInvisible()
		and #nEnemysHerosInRange >= 1
		and nLV >= 6
	then
		for _,npcEnemy in pairs( nEnemysHerosInRange )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and not J.IsDisabled(true, npcEnemy)
                and not npcEnemy:IsDisarmed()				
				and bot:IsFacingLocation(npcEnemy:GetLocation(),45)
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end

	--撤退时不顾一切先保命
	if J.IsRetreating(bot) 
		and not bot:IsInvisible()
	then
		for _,npcEnemy in pairs( nAlleys )
		do
			npcEnemyHP = npcEnemy:GetHealth()/npcEnemy:GetMaxHealth();--队友血量比
			if  J.IsValid(npcEnemy)
				and J.CanCastOnNonMagicImmune(npcEnemy) 
				and nHP > 0.8
				and npcEnemyHP < 0.2
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
		if J.IsValid(bot)
		    and J.CanCastOnNonMagicImmune(bot)
		then
			return BOT_ACTION_DESIRE_HIGH, bot;
		end
	end

	return 0;

end
--是否应当节省魔法
function X.ShouldSaveMana(nAbility)

	if  nLV >= 6
	    and abilityR:GetCooldownTimeRemaining() <= 3.0
		and ( bot:GetMana() - nAbility:GetManaCost() < abilityR:GetManaCost())
	then
		return true;
	end
	
	return false;
end
return X