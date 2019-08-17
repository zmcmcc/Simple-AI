local X = {}
local bot = GetBot() --获取当前电脑

local J = require( GetScriptDirectory()..'/FunLib/jmz_func') --引入jmz_func文件
local Minion = dofile( GetScriptDirectory()..'/FunLib/Minion') --引入Minion文件
local sTalentList = J.Skill.GetTalentList(bot) --获取当前英雄（当前电脑选择的英雄，一下省略为当前英雄）的天赋列表
local sAbilityList = J.Skill.GetAbilityList(bot) --获取当前英雄的技能列表
local sOutfit = J.Skill.GetOutfitName(bot) --获取当前英雄的装备信息
--英雄天赋树
local tTalentTreeList = {
						['t25'] = {10, 0},
						['t20'] = {0, 10},
						['t15'] = {10, 0},
						['t10'] = {0, 10},
}

--英雄技能树
local tAllAbilityBuildList = {
						{1,2,2,1,2,6,2,1,1,3,3,3,3,6,6},
}
--从技能树中随机选择一套技能
local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)
--根据天赋树生成天赋列表
local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)
--技能和天赋加点方案
X['sBuyList'] = {
				sOutfit,
				"item_hand_of_midas",
				"item_aether_lens",
				"item_hood_of_defiance",
				"item_guardian_greaves",
				"item_ultimate_scepter",
}

X['sSellList'] = {
	"item_lotus_orb",
	"item_magic_wand",
	
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
local abilityE = bot:GetAbilityByName( sAbilityList[3] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )
local talent5 = bot:GetAbilityByName( sTalentList[5] );
--初始化技能欲望与点变量
local castQDesire, castQTarget
local castWDesire, castWTarget
local castRDesire
local castRFRAhgDesire
--初始英雄状态变量
local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;
local abilityAhg = nil
local aetherRange = 0

function X.SkillsComplement()

	--如果当前英雄无法使用技能或英雄处于隐形状态，则不做操作。
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
	
	
	--设定一些必要条件
	nKeepMana = 160 --魔法储量 160
	nLV = bot:GetLevel(); --当前英雄等级
	nMP = bot:GetMana()/bot:GetMaxMana(); --目前法力值/最大法力值（魔法剩余比）
	nHP = bot:GetHealth()/bot:GetMaxHealth();--目前生命值/最大生命值（生命剩余比）
	hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内敌人
	abilityAhg = J.IsItemAvailable("item_ultimate_scepter"); --是否拥有蓝杖
	
	
	
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
		return;
	
	end
	
	castRDesire   = X.ConsiderR();
	if ( castRDesire > 0 ) 
	then
	
		    J.SetQueuePtToINT(bot, true)
			bot:ActionQueue_UseAbilityOnEntity( abilityR )
		
		return;
	end
	
	castRAhgDesire = X.ConsiderRAhg();
	if ( castRAhgDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, true)
        bot:ActionQueue_UseAbilityOnEntity( abilityR )
		
		return;
	
	end	
	
	

end

function X.ConsiderQ()--使用Q技能的欲望

	-- 确保技能可以使用
	if not abilityQ:IsFullyCastable()
	then 
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end

	-- 获取一些必要参数
	local nCastRange  = abilityQ:GetCastRange() + 70 + aetherRange;	--施法范围
	local target      = J.GetProperTarget(bot);
	local nManaCost   = abilityQ:GetManaCost();		--魔法消耗
	local nSkillLV    = abilityQ:GetLevel();    	--技能等级 
	local nDamage     = 70 * nSkillLV  + 20;	--技能伤害                        
	local nHeal       = 70 * nSkillLV  + 20;	--技能治疗
	local nDamageType = DAMAGE_TYPE_PURE;		--伤害类型
	local nRadius    = abilityW:GetSpecialValueInt( "radius" ); --治疗伤害半径
	
	local nAlleys =  bot:GetNearbyHeroes(1200,false,BOT_MODE_NONE); --获取1200范围内盟友
	local nEnemysHerosInView  = bot:GetNearbyHeroes(1200,true,BOT_MODE_NONE); --获取1200范围内敌人
	
	local nEnemysHerosInRadius = bot:GetNearbyHeroes(nRadius - 70, true, BOT_MODE_NONE);
	
	
	
	--击杀
	for _,npcEnemy in pairs( nEnemysHerosInRadius)
	do
		if J.IsValid(npcEnemy)
		   and J.CanCastOnNonMagicImmune(npcEnemy)
		then
			if  J.CanKillTarget(npcEnemy,nDamage,nDamageType)
			then
				return BOT_ACTION_DESIRE_VERYHIGH, bot; --直接杀死
			end
			
		end
	end
	
		--在团战中
	if J.IsInTeamFight(bot, 1200)
	then
		--附件有3人以上的敌人，且自己血量不高，优先自己保命
		if #nEnemysHerosInView > 3
			and J.IsValid(bot)
			and J.CanCastOnNonMagicImmune(bot) 
			and nHP < 0.6
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
				and npcEnemyHP < 0.5
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	--对线期间对友方英雄使用
	if bot:GetActiveMode() == BOT_MODE_LANING
	then
		for _,npcEnemy in pairs( nAlleys )
		do
		    npcEnemyHP = npcEnemy:GetHealth()/npcEnemy:GetMaxHealth();
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and npcEnemyHP <= 0.7
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
		if  nHP <= 0.3
		then
			return BOT_ACTION_DESIRE_HIGH, bot;
		elseif nHP <= 0.6
		then
			return BOT_ACTION_DESIRE_MODERATE, bot;
		end
	end
	
	--打钱
	if  J.IsFarming(bot) 
		and nMP > 0.4
	then
		local nCreeps = bot:GetNearbyNeutralCreeps(nRadius);
		if J.IsValid(targetCreep)
			and  #nCreeps >= 2
			and not J.IsOtherAllysTarget(targetCreep)
		then
			return BOT_ACTION_DESIRE_HIGH, bot;
	    end
	end
	
	
	--通用消耗敌人或受到伤害时保护自己
	if  bot:WasRecentlyDamagedByAnyHero(3.0)
		and ( bot:GetActiveMode() ~= BOT_MODE_RETREAT or #nAlleys >= 2 )
		and #nEnemysHerosInRadius >= 1
	then
		return BOT_ACTION_DESIRE_HIGH, bot;
	end
	return 0;

end

function X.ConsiderW()
	-- 确保技能可以使用
	if not abilityW:IsFullyCastable()
	then 
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end

	--获取一些参数
	local nCastRange  = abilityW:GetCastRange() + aetherRange;		--施法范围
	local nManaCost   = abilityW:GetManaCost();		                --魔法消耗
	local nSkillLV    = abilityW:GetLevel();    	                --技能等级 

	--一些单位信息
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
			and nHP < 0.6
			or  bot:HasModifier("modifier_silencer_curse_of_the_silent")
			or  bot:HasModifier("modifier_silencer_last_word")
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
		--团队有人血量较低或者被控，给队友保命
		for _,npcEnemy in pairs( nAlleys )
		do
			npcEnemyHP = npcEnemy:GetHealth()/npcEnemy:GetMaxHealth();--队友血量比
			if  J.IsValid(npcEnemy)
				and J.CanCastOnNonMagicImmune(npcEnemy) 
				and (npcEnemyHP < 0.4
				or  J.IsDisabled(false, npcEnemy)
				or  bot:HasModifier("modifier_silencer_curse_of_the_silent")
			    or  bot:HasModifier("modifier_silencer_last_word"))
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
		--魔法充裕，给自己套个套子
		--if nMP > 0.7 then
				--if nHP >= 0.7
					--and #nEnemysHerosInView < 4 then --血量大于0.7就追击附近强者
					--local npcMostDangerousEnemy = nil;
					--local nMostDangerousDamage = 0;		
					
					--for _,npcEnemy in pairs( nEnemysHerosInRange )
					--do
						--if  J.IsValid(npcEnemy)
							--and J.CanCastOnNonMagicImmune(npcEnemy) 
							--and not J.IsDisabled(true, npcEnemy)
							--and not npcEnemy:IsDisarmed()
						--then
							--local npcEnemyDamage = npcEnemy:GetEstimatedDamageToTarget( false, bot, 3.0, DAMAGE_TYPE_PHYSICAL );
							--if ( npcEnemyDamage > nMostDangerousDamage )
							--then
								--nMostDangerousDamage = npcEnemyDamage;
								--npcMostDangerousEnemy = npcEnemy;
							--end
						--end
					--end
					
					--if ( npcMostDangerousEnemy ~= nil )
					--then
						--bot:SetTarget(npcMostDangerousEnemy, false);
					--end	
				--end
			--return BOT_ACTION_DESIRE_HIGH, bot;
		--end	
	end
	--遭遇
	if J.IsGoingOnSomeone(bot)
	then
		if J.IsValid(bot)
			and #nEnemysHerosInView > 3
			and J.CanCastOnNonMagicImmune(bot) 
			and nHP < 0.65
		then
			return BOT_ACTION_DESIRE_HIGH, bot;
		end
		for _,npcEnemy in pairs( nAlleys )
		do
			npcEnemyHP = npcEnemy:GetHealth()/npcEnemy:GetMaxHealth();--队友血量比
			if  J.IsValid(npcEnemy)
				and J.CanCastOnNonMagicImmune(npcEnemy) 
				and (npcEnemyHP < 0.5
				or  J.IsDisabled(false, npcEnemy)
				or  bot:HasModifier("modifier_silencer_curse_of_the_silent")
			    or  bot:HasModifier("modifier_silencer_last_word"))
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end

	--对线期间对自己使用
	if bot:GetActiveMode() == BOT_MODE_LANING
	then
		if  nMP >= 0.6
			and #nEnemysHerosInView > 3
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
	then
		for _,npcEnemy in pairs( nEnemysHerosInRange )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and not J.IsDisabled(true, npcEnemy)
                and not npcEnemy:IsDisarmed()				
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
				and (npcEnemyHP < 0.3
				or  J.IsDisabled(false, npcEnemy)
				or  bot:HasModifier("modifier_silencer_curse_of_the_silent")
			    or  bot:HasModifier("modifier_silencer_last_word"))
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

function X.ConsiderR()
	
	if not abilityR:IsFullyCastable() then return BOT_ACTION_DESIRE_NONE, nil;	end
	
	local manaCost   = abilityR:GetManaCost();
	local hTrueHeroList = J.GetEnemyList(bot,1400);
	local nAllieslowhp = 0;
	local nAlleys =  bot:GetNearbyHeroes(1200,false,BOT_MODE_NONE); --获取1200范围内盟友
	local nEnemysHerosInView  = bot:GetNearbyHeroes(1200,true,BOT_MODE_NONE); --获取1200范围内敌人
	
	for _,npcAlly in pairs( nAlleys )
	    do
		    if  J.IsValidHero(npcAlly)
				and J.CanCastOnNonMagicImmune(npcAlly) 
				then
				if J.GetHealth(npcAlly) <= 0.45
				then
					nAllieslowhp = nAllieslowhp + 1;
                end
			end
		end
	
	if  #nAlleys >= 4 
	    or nAllieslowhp >= 2
	    or #nEnemysHerosInView >= 3
	    then 
	       return BOT_ACTION_DESIRE_HIGH;
	    end
	
	
	return BOT_ACTION_DESIRE_NONE;
end

function X.ConsiderRAhg()
	
	if not abilityR:IsFullyCastable() 
	   or abilityAhg == nil
	   or not abilityRef:IsFullyCastable()
	then return BOT_ACTION_DESIRE_NONE, nil; end
	
	local base      = bot:GetAncient(GetTeam());

	if base:WasRecentlyDamagedByAnyHero(3.0) 
	   then 
	        return BOT_ACTION_DESIRE_VERYHIGH;
	   end
	   
	
	
	return BOT_ACTION_DESIRE_NONE;
end



return X