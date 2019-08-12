------------------------------------------------------------------------------------------------------------
--	英雄数据文件模板
------------------------------------------------------------------------------------------------------------
--	将文件名中template改为英雄名
--	英雄名称可以登录https://dota2.gamepedia.com/Cheats对照
--	例如大喵（白虎）npc_dota_hero_mirana，将文件名改为hero_mirana.lua
--	在GetAllowHeroData中找到对应英雄，还以大喵举例，npc_dota_hero_mirana在806行，将bot项（841行）改为true
--	注意，GetAllowHeroData以当前版本文件行数为准
--	此时文件和英雄生效
--	如果仅调试英雄，在RoleTargetsData中的test_hero中添加npc_dota_hero_mirana即可
------------------------------------------------------------------------------------------------------------

local X = {}
local bot = GetBot() --获取当前电脑

local J = require( GetScriptDirectory()..'/FunLib/jmz_func') --引入jmz_func文件
local Minion = dofile( GetScriptDirectory()..'/FunLib/Minion') --引入Minion文件
local sTalentList = J.Skill.GetTalentList(bot) --获取当前英雄（当前电脑选择的英雄，一下省略为当前英雄）的天赋列表
local sAbilityList = J.Skill.GetAbilityList(bot) --获取当前英雄的技能列表
local sOutfit = J.Skill.GetOutfitName(bot) --获取当前英雄的装备信息

------------------------------------------------------------------------------------------------------------
--	英雄加点及出装数据
------------------------------------------------------------------------------------------------------------

--英雄天赋树
local tTalentTreeList = {
						['t25'] = {0, 10}, --右
						['t20'] = {0, 10}, --右
						['t15'] = {0, 10}, --右
						['t10'] = {10, 0}, --左
}

--英雄技能树
--6代表大招
--可多组，游戏时随机一组使用
local tAllAbilityBuildList = {
						{2,1,1,3,1,6,1,2,2,2,6,3,3,3,6},
						{2,3,2,3,2,6,2,3,3,1,6,1,1,1,6},
}
--从技能树中随机选择一套技能
local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)
--根据天赋树生成天赋列表
local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)

--出装方案
--基础出装在jmz_item.lua中编写，对应sOutfit项
X['sBuyList'] = {
				"item_stout_shield",
				sOutfit,
				"item_blade_mail",
				"item_mjollnir",
				"item_sange_and_yasha",
				"item_radiance",
				"item_satanic",
				"item_heart",
}
--后期更换装备方案
X['sSellList'] = {
	"item_crimson_guard",
	"item_quelling_blade",
}

--加载锦囊数据
nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList'] = J.SetUserHeroInit(nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList']);

--获取技能列表
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
local abilityQ = bot:GetAbilityByName( sAbilityList[1] ) --第一个技能
local abilityW = bot:GetAbilityByName( sAbilityList[2] ) --第二个技能
local abilityE = bot:GetAbilityByName( sAbilityList[3] ) --第三个技能
local abilityR = bot:GetAbilityByName( sAbilityList[6] ) --大招
--初始化技能欲望与点变量
local castQDesire, castQTarget
local castWDesire, castWLocation
local castEDesire
local castRDesire
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
	
	
	
	
	castQDesire, castQTarget = X.ConsiderQ();--索引第一个技能（快捷键Q）

	if ( castQDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, true) --临时补充魔法，使用魂戒（false为不使用魂戒）
	
		bot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget ) --使用指向目标的技能
		return;
	end
	
	castWDesire, castWLocation = X.ConsiderW();--索引第二个技能（快捷键W）
	if ( castWDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, true) --临时补充魔法，使用魂戒
	
		bot:ActionQueue_UseAbilityOnLocation( abilityW, castWLocation ) --使用指向点的技能
		return;
	
	end

	--被动技能通常无需操作，如果想要配合进行一些其他操作也可以写

	castRDesire = X.ConsiderR();--索引终极技能（快捷键R）
	if ( castRDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, true) --临时补充魔法，使用魂戒
	
		bot:ActionQueue_UseAbility( abilityR ) --使用无指向的技能
		return;
	
	end

end

function X.ConsiderQ()--使用一技能的欲望

	-- 确保技能可以使用
	if not abilityQ:IsFullyCastable()
	then 
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end

	-- 以下内容为示例内容，仅供参考
	-- 编写时请以实际情况为准
	-- 建议删除下列内容手动编写

	-- 获取一些必要参数
	local nCastRange  = abilityQ:GetCastRange();	--施法范围
	local nCastPoint  = abilityQ:GetCastPoint();	--施法点
	local nManaCost   = abilityQ:GetManaCost();		--魔法消耗
	local nSkillLV    = abilityQ:GetLevel();    	--技能等级 
	local nDamageOwn  = 25 * ( nSkillLV - 1) + 50;	--技能自身伤害 （手动计算）                       
	local nDamage     = 45 * ( nSkillLV - 1) + 75;	--技能伤害 （手动计算）
	local nDamageType = DAMAGE_TYPE_MAGICAL;		--伤害类型 （魔法）
	
	--获取一些单位信息
	local nAlleys =  bot:GetNearbyHeroes(1200,false,BOT_MODE_NONE); 		  --获取1200范围内盟友
	local nEnemysHerosInView  = bot:GetNearbyHeroes(1200,true,BOT_MODE_NONE); --获取1200范围内敌人
	
	--一些补偿写法
	if #nEnemysHerosInView == 1 --如果敌人只有一个
	   and J.IsValidHero(nEnemysHerosInView[1]) --是英雄
	   and J.IsInRange(nEnemysHerosInView[1],bot,nCastRange + 50) --在施法范围+50内
	   and nEnemysHerosInView[1]:IsFacingLocation(bot:GetLocation(),30) --单位面向目标30°范围内
	   and nEnemysHerosInView[1]:GetAttackRange() > nCastRange --单位的攻击范围在施法范围外
	   and nEnemysHerosInView[1]:GetAttackRange() < 1250 --且小于1250
	then
		nCastRange = nCastRange + 200; --使得施法欲望范围增加200
	end
	
	--获取一些和技能相关的单位信息
	local nEnemysHerosInRange = bot:GetNearbyHeroes(nCastRange ,true,BOT_MODE_NONE); --获得施法范围内敌人
	local nEnemysHerosInBonus = bot:GetNearbyHeroes(nCastRange + 150,true,BOT_MODE_NONE);--获得施法范围+150内敌人
	
	--击杀
	for _,npcEnemy in pairs( nEnemysHerosInBonus )
	do
		if J.IsValid(npcEnemy)--单位还活着
		   and J.CanCastOnNonMagicImmune(npcEnemy)--不处于魔免或无敌状态
		then
			--如果在追击（技能范围+50且自己血量大于30%）时且有把握击杀
			if  GetUnitToUnitDistance(bot,npcEnemy) <= nCastRange + 50 
				and J.CanKillTarget(npcEnemy,nDamage,nDamageType)
				and (bot:GetHealth() - nDamageOwn)/bot:GetMaxHealth() >= 0.3
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy; --追杀
			end
			--如果在技能范围内且有把握击杀
			if  GetUnitToUnitDistance(bot,npcEnemy) <= nCastRange 
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
		--计算战力最高的敌人
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
		--如果成功获取到敌人
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

	--打钱时使用
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
	return 0;

end

function X.ConsiderW()
	-- 确保技能可以使用
	if not abilityW:IsFullyCastable()
	   or bot:HasModifier("modifier_abaddon_aphotic_shield") --单位有某些buff，避免重复施法
	then 
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end

	--策略和一技能一样自行编辑

	return 0;

end

function X.ConsiderE()
	-- 确保技能可以使用
	if not abilityE:IsFullyCastable()
	then 
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end

	--策略和一技能一样自行编辑

	return 0;

end

function X.ConsiderR()
	-- 确保技能可以使用
	if not abilityR:IsFullyCastable()
	then 
		return BOT_ACTION_DESIRE_NONE, 0; --没欲望
	end

	--策略和一技能一样自行编辑

	return 0;

end

return X