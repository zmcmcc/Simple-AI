--------------------
--from 望天的稻草
--------------------
local X = {}
local bot = GetBot() --获取当前电脑

local J = require( GetScriptDirectory()..'/FunLib/jmz_func') --引入jmz_func文件
local Minion = dofile( GetScriptDirectory()..'/FunLib/Minion') --引入Minion文件
local sTalentList = J.Skill.GetTalentList(bot) --获取当前英雄（当前电脑选择的英雄，一下省略为当前英雄）的天赋列表
local sAbilityList = J.Skill.GetAbilityList(bot) --获取当前英雄的技能列表

------------------------------------------------------------------------------------------------------------
--	英雄加点及出装数据
------------------------------------------------------------------------------------------------------------

--英雄天赋树
local tTalentTreeList = {
						['t25'] = {0, 10}, --右
						['t20'] = {10, 0}, --左
						['t15'] = {10, 0}, --左
						['t10'] = {10, 0}, --左
}

--英雄技能树
--6代表大招
--可多组，游戏时随机一组使用
local tAllAbilityBuildList = {
						{2,3,1,3,1,6,3,1,1,3,6,2,2,2,6},
}
--从技能树中随机选择一套技能
local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)
--根据天赋树生成天赋列表
local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)

--出装方案
--基础出装在jmz_item.lua中编写，对应sOutfit项
X['sBuyList'] = {
				"item_stout_shield",
				'item_tango',
				'item_flask',
				'item_quelling_blade',
				'item_soul_ring',
				'item_phase_boots',
				"item_echo_sabre",
				"item_blade_mail",
				"item_mjollnir",
				"item_sange_and_yasha",
				"item_satanic",
				"item_heart",
}
--后期更换装备方案
X['sSellList'] = {
	"item_crimson_guard",
	"item_abyssal_blade",
}

--加载锦囊数据
nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList'] = J.SetUserHeroInit(nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList']);

--获取技能列表
X['sSkillList'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)

X['bDeafaultAbility'] = false
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
local abilityQ = bot:GetAbilityByName( sAbilityList[1] ) --第一个技能
local abilityW = bot:GetAbilityByName( sAbilityList[2] ) --第二个技能
local abilityE = bot:GetAbilityByName( sAbilityList[3] ) --第三个技能
local abilityR = bot:GetAbilityByName( sAbilityList[6] ) --大招
--初始化技能欲望与点变量
local castQDesire
local castWDesire
local castRDesire, castRTarget
--初始英雄状态变量
local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;

function X.SkillsComplement()

	--如果当前英雄无法使用技能或英雄处于隐形状态，则不做操作。
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
	
	
	--设定一些必要条件
	nKeepMana = 160 --魔法储量
	nLV = bot:GetLevel(); --当前英雄等级
	nMP = bot:GetMana()/bot:GetMaxMana(); --目前法力值/最大法力值（魔法剩余比）
	nHP = bot:GetHealth()/bot:GetMaxHealth();--目前生命值/最大生命值（生命剩余比）
	hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);--1600范围内敌人
	
	
	
	
	castQDesire= X.ConsiderQ();--索引第一个技能（快捷键Q）

	if castQDesire > 0  
	then
	
		J.SetQueuePtToINT(bot, false) 
	
		bot:ActionQueue_UseAbility(abilityQ) --使用指向目标的技能
		return;
	end
	
	castWDesire = X.ConsiderW();--索引第二个技能（快捷键W）
	if ( castWDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, true) --临时补充魔法，使用魂戒
	
		bot:ActionQueue_UseAbility( abilityW ) 
		return;
	
	end



	castRDesire, castRTarget = X.ConsiderR();--索引终极技能（快捷键R）
	if ( castRDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, true) --临时补充魔法，使用魂戒
	
		bot:ActionQueue_UseAbilityOnEntity( abilityR, castRTarget ) 
		return;
	
	end

end

function X.ConsiderQ()--使用一技能的欲望

	-- 确保技能可以使用
	if not abilityQ:IsFullyCastable()
	then 
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end

	-- 获取一些必要参数
	local nSkillLV    = abilityQ:GetLevel();    	--技能等级 
	
	--获取一些单位信息
	local nAlleys =  bot:GetNearbyHeroes(1200,false,BOT_MODE_NONE); 		  --获取1200范围内盟友
	local nEnemysHerosInView  = bot:GetNearbyHeroes(1200,true,BOT_MODE_NONE); --获取1200范围内敌人
	
	
	
	--击杀
	for _,npcEnemy in pairs( nEnemysHerosInView )
	do
		if J.IsValid(npcEnemy)--单位还活着
		   and J.CanCastOnNonMagicImmune(npcEnemy)--不处于魔免或无敌状态
		then
			--如果在追击（200且自己血量大于30%）时
			if  GetUnitToUnitDistance(bot,npcEnemy) <= 200 
				and bot:GetHealth() /bot:GetMaxHealth() >= 0.3
			then
				return BOT_ACTION_DESIRE_HIGH; --追杀
			end
			--如果敌方单位在TP，无脑开冲，满足条件后可以接踩
			if npcEnemy:IsChanneling()
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
			
		end
	end
	

	
    -- 过河道接近敌方基地
	if J.IsInEnemyArea(bot)
	then
		local nEnemies = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
		local nAllies  = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
		local nEnemyTowers = bot:GetNearbyTowers(1600,true);
		if #nEnemies == 0 or nEnemyTowers == 0
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	
	--对线期间对自己使用
	if bot:GetActiveMode() == BOT_MODE_LANING
		and J.IsValid(bot) 
	then
		if  nHP <= 0.3
		then
			return BOT_ACTION_DESIRE_HIGH;
		elseif nHP <= 0.6
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	--打架时先手	
	if J.IsGoingOnSomeone(bot)
	then 
	
	    local nEnemysHerosInView = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE); --Enemy within 1200 range

		if nEnemysHerosInView ~= nil and #nEnemysHerosInView >= 1
        then
             return BOT_ACTION_DESIRE_HIGH;
        end
    end		 
	
	--打钱时使用
	if  J.IsFarming(bot) and nSkillLV >= 2

	then
		local nCreeps = bot:GetNearbyNeutralCreeps(300);
		
		local targetCreep = J.GetMostHpUnit(nCreeps);
		
		if J.IsValid(targetCreep)
			and GetUnitToUnitDistance(targetCreep,bot) > 100
			and not J.IsOtherAllysTarget(targetCreep)
		then
			return BOT_ACTION_DESIRE_HIGH;
	    end
	end
	
	--受到伤害时保护自己
	if (#nEnemysHerosInView >= 1 and bot:WasRecentlyDamagedByAnyHero(3.0)) 
		and not bot:IsInvisible()
	then
		for _,npcEnemy in pairs( nEnemysHerosInView )
		do
			if  J.IsValid(npcEnemy)
				and not J.IsDisabled(true, npcEnemy)
                and not npcEnemy:IsDisarmed()				
			then
				return BOT_ACTION_DESIRE_HIGH; 
			end
		end
	end
	
    --低血量参团，优先自己保命
	if J.IsInTeamFight(bot, 1200)
	then
		if J.IsValid(bot)
			and J.CanCastOnNonMagicImmune(bot)
			and nHP < 0.4
			then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	return BOT_ACTION_DESIRE_NONE;

end

function X.ConsiderW()
	-- 确保技能可以使用
	if not abilityW:IsFullyCastable()
	then 
		return BOT_ACTION_DESIRE_NONE; --没欲望
	end
	
    -- 获取一些必要参数
	local nRadius    = abilityW:GetSpecialValueInt( "Crush_radius" ); --鱼人踩半径
	local nManaCost   = abilityQ:GetManaCost();		--魔法消耗
	local nSkillLV    = abilityQ:GetLevel();    	--技能等级                     
	local nDamage     = 60 * nSkillLV + 20;	        --技能伤害
    
	local nAlleys =  bot:GetNearbyHeroes(1200,false,BOT_MODE_NONE); --获取1200范围内盟友
	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE ); --获取踩范围内敌人
	local tableNearbyEnemyHeroes2 = bot:GetNearbyHeroes( nRadius - 100, true, BOT_MODE_NONE ); --获取踩范围内敌人
	local nEnemysHerosInView  = bot:GetNearbyHeroes(1200,true,BOT_MODE_NONE); --获取1200范围内敌人
    
	
	--撤退时踩断后
	if J.IsRetreating(bot)
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if bot:WasRecentlyDamagedByHero( npcEnemy, 3.0 ) 
			   and J.CanCastOnNonMagicImmune(npcEnemy)
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	end
	
	
	--可以击杀时击杀
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes2 )
		do
			if #nAlleys >= 1
			   and J.CanCastOnNonMagicImmune(npcEnemy)
			then
				return BOT_ACTION_DESIRE_HIGH;
			end
		end
	
 	
	
	--对线期间
	if bot:GetActiveMode() == BOT_MODE_LANING
	   and J.IsValid(bot) 
	then
		if  #tableNearbyEnemyHeroes2 >= 1
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
	end
	
	

	--遭遇
	if J.IsGoingOnSomeone(bot)
	then 
			if  #tableNearbyEnemyHeroes >= 1
			    and J.CanCastOnNonMagicImmune(npcEnemy)
			then
				return BOT_ACTION_DESIRE_VERYHIGH;
			end
		
        end		 
	
	--打钱时使用
	if  J.IsFarming(bot) and nSkillLV >= 3

	then
		local nCreeps = bot:GetNearbyNeutralCreeps(nRadius);
		
		if #nCreeps >= 3
		then
			return BOT_ACTION_DESIRE_HIGH;
	    end
	end
	
	--团战
	if J.IsInTeamFight(bot, 1200)
	then
		--附件有3人以上的敌人，且自己血量不高，优先自己保命
		if #nEnemysHerosInView >= 3
			and J.IsValid(bot)
			and J.CanCastOnNonMagicImmune(bot) 
			and #tableNearbyEnemyHeroes2 >= 1
		 then
			return BOT_ACTION_DESIRE_VERYHIGH;
		end
	end
		
		

	return BOT_ACTION_DESIRE_NONE;
end



function X.ConsiderR()
	-- 确保技能可以使用
	if not abilityR:IsFullyCastable()
	then 
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end
	
    

	local nSkillLV    = abilityR:GetLevel();    	--技能等级 
    local nCastRange  = 100* nSkillLV + 600;	--施法范围
	local aTarget = bot:GetAttackTarget(); 

	
	local nEnemysHerosInRange = bot:GetNearbyHeroes(nCastRange,true,BOT_MODE_NONE);
	local nEnemyHeroes = bot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
	
	--肉山
	if ( bot:GetActiveMode() == BOT_MODE_ROSHAN  ) 
	then
		local npcTarget = bot:GetAttackTarget();
		if npcTarget ~= nil and
		   J.IsRoshan(npcTarget) and
		   J.CanCastOnMagicImmune(npcTarget) and
		   J.IsInRange(npcTarget, bot, nCastRange)
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	--遭遇
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = J.GetProperTarget(bot);
		if npcTarget ~= nil then
			if J.IsValidHero(npcTarget) 
			and J.CanCastOnNonMagicImmune(npcTarget) 
			and J.IsInRange(npcTarget, bot, nCastRange) 
			and J.CanCastOnTargetAdvanced(npcTarget)
			then
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
			
			if J.IsValid(npcTarget) and #nEnemyHeroes == 0
			and J.IsAllowedToSpam(bot, nManaCost) 
			and J.CanCastOnNonMagicImmune(npcTarget) 
			and J.CanCastOnTargetAdvanced(npcTarget)
			and J.IsInRange(npcTarget, bot, nCastRange) 
			and not J.CanKillTarget(npcTarget,bot:GetAttackDamage() *1.48,DAMAGE_TYPE_PHYSICAL)
			then
				local nCreeps = bot:GetNearbyCreeps(800,true);
				if #nCreeps >= 1
				then
					return BOT_ACTION_DESIRE_HIGH, npcTarget;
				end
			end
		end
	end
	
	
    --团战
	if J.IsInTeamFight(bot, 1200)
	then
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;	

		
		for _,npcEnemy in pairs( nEnemysHerosInRange )
		do
			if  J.IsValidHero(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				then
					local npcEnemyDamage = npcEnemy:GetEstimatedDamageToTarget( false, bot, 3.0, DAMAGE_TYPE_PHYSICAL );
					if ( npcEnemyDamage > nMostDangerousDamage )
					then
						nMostDangerousDamage = npcEnemyDamage;
						npcMostDangerousEnemy = npcEnemy;
					end
				end
			end

		if npcMostDangerousEnemy ~= nil
		then
			return BOT_ACTION_DESIRE_HIGH, npcMostDangerousEnemy;
		end	
		

	end
	
	--打钱时使用
	if  J.IsFarming(bot) 
		and nSkillLV >= 1
		and nMP > 0.65
	then
		local nCreeps = bot:GetNearbyNeutralCreeps(nCastRange +100);
		
		local targetCreep = J.GetMostHpUnit(nCreeps);
		
		if targetCreep ~= nil
		   and J.IsValid(targetCreep)
		   and GetUnitToUnitDistance(targetCreep,bot) <= 400 
		   and not J.CanKillTarget(targetCreep,bot:GetAttackDamage() *1.68,DAMAGE_TYPE_PHYSICAL)
		then
			return BOT_ACTION_DESIRE_HIGH, targetCreep;
	    end
	end
	

	--对线期间
	if nEnemysHerosInRange ~= nil
	   and bot:GetActiveMode() == BOT_MODE_LANING
	   and J.IsValid(bot) 
	then
		for _,npcEnemy in pairs( nEnemysHerosInRange)
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
		

	return BOT_ACTION_DESIRE_NONE;

end

return X

--https://developer.valvesoftware.com/wiki/Dota_Bot_Scripting#Ability_and_Item_usage
--http://discuss.alcedogroup.com/d/7-simple-ai