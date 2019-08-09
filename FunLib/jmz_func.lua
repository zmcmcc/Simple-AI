----------------------------------------------------------------------------------------------------
--- The Creation Come From: BOT EXPERIMENT Credit:FURIOUSPUPPY
--- BOT EXPERIMENT Author: Arizona Fauzie 
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=837040016
--- Update by: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
----------------------------------------------------------------------------------------------------

--[[计划一:
编码规范化推进计划正在进行中...
1, 自定义变量命名用匈牙利法, 即首单词小写, 其他单词首字母大写(除个别特殊情况, 如npc类, 循环头, 部分临时变量)
  自定义变量如果是表的话, 以List结尾, 如 enemyList; (当前的矛盾是一些老代码处混用的大小驼峰法, 用大驼峰法处应尽快修正)
  同功能含义和类型的变量后缀可用1, 2, 3....(name1, name2), 最好尽量用有区分度的英文后缀(nameLong, nameShort)
  自定义函数或模块命名用大驼峰法, 即将各单词首字母大写连接构成, 尽量只使用已有的函数开头词, 如:Is, Has, Can, Should, Will, Get, Print, Set, Consider  
2, 各类运算符添加空格风格要统一(循环头特殊), 
  比如说' = '及其他赋值或关系或逻辑运算符的两边, ', '后面有内容时的右边, 
  ' -'及其他算术运算符左边, '- '及其他算术运算符与非数字的右边, 
  能不用双引号尽量不用双引号, 能不用分号尽量不用分号, 
  '( () )'多重括号嵌套的外层括号内侧.
3, 需要使用循环逻辑时尽量不用除 for 语句外的关键字, 
  需要进行多个条件逻辑运算时, 每个条件块单独一行.
4, 函数参数中包含了 bot(句柄) 的话, 将其放在第一位, 同一文件内, 要么均为npcBot, 要么均为bot
如有遗漏或矛盾的情况以文件内同类代码的主流规范为准.
附: 常用词汇  放最后: 表示布尔值 bDone bError bSuccess bFound  bReady  如: bUpdateDone
    表修饰时(放最后) Total、 Sum、 Average、 Max、 Min、 Record、 String、 Pointer、 First、 Last、 Lim  如: creepCountMax
	句柄handle = h, 坐标矢量vector = v, 布尔值bool = b, 字符串string = s, 
	一般的数量normal = n, 特殊的小数float = f, 全局命名空间变量goble = g, 未确定类型的单位unknow = u, 
	表名以表内容类型....List命名, 即 'sBotList' 表示内容为英雄名的线性表, 非线性表或表中表table = t, 
--]]

--[[计划二:
冗余代码分类整合计划正在进行中...
将同类型的函数分类
将功能类似的函数整合
--]]

--[[计划三:
同义词合并计划正在进行中...
将所有表达同一个意思的变量名字统一
--]]

--[[计划四:
队列行动替换计划正在进行中...
将动作尽量用队列的形式来执行
例如 原来是 bot:Action_UseAbility(hAbility) 改为 bot:ActionQueue_UseAbility(hAbility)
--]]


local J = {}

----------------------------------------
--[[全局变量----------------------------
----------------------------------------
--------------------全局变量放这里初始化
----------------------------------------
------------------------------直接使用的
-------------G开头表示禁止修改的全局变量
-------------g开头表示可以修改的全局变量
--]]
GBotTeam = GetTeam()
GOppTeam = GetOpposingTeam() 
if gTime == nil then gTime = 0 end

----------------------------------------
--[[文件局部变量------------------------
-----------------------------------------
-----------------文件局部变量放这里初始化
---------------------------通过文件使用的
--]]
local sDota2Version= '7.22d'
local sDebugVersion= '20190812ver1.1a'
local nPrintTime   = 9999
local nDebugTime   = 9999
local bDebugMode   = false
local bDebugTeam   = (GBotTeam == TEAM_RADIANT)
local sDebugHero   = 'npc_dota_hero_luna'
local tAllyIDList    = GetTeamPlayers(GBotTeam)
local tAllyHeroList = {}
local tAllyHumanList  = {}
local nAllyTotalKill = 0
local nAllyAverageLevel = 1
local tEnemyIDList    = GetTeamPlayers(GOppTeam)
local tEnemyHeroList = {}
local tEnemyHumanList = {}
local nEnemyTotalKill = 0
local nEnemyAverageLevel = 1

local tSleevelHeros = {
	'npc_dota_hero_vengefulspirit',
	'npc_dota_hero_shadow_demon',
	'npc_dota_hero_tidehunter',
	'npc_dota_hero_disruptor',
	'npc_dota_hero_axe',
	'npc_dota_hero_leshrac',
	'npc_dota_hero_batrider',
	'npc_dota_hero_dazzle',
	'npc_dota_hero_abaddon',
	'npc_dota_hero_grimstroke',
	'npc_dota_hero_puck',
	--原脚本
	'npc_dota_hero_antimage',
	'npc_dota_hero_arc_warden',
	'npc_dota_hero_bloodseeker',
	'npc_dota_hero_bristleback',
	'npc_dota_hero_chaos_knight',
	'npc_dota_hero_crystal_maiden',
	'npc_dota_hero_dragon_knight',
	'npc_dota_hero_drow_ranger',
	'npc_dota_hero_jakiro',
	'npc_dota_hero_kunkka',
	'npc_dota_hero_luna',
	'npc_dota_hero_medusa',
	'npc_dota_hero_necrolyte',
	'npc_dota_hero_nevermore',
	'npc_dota_hero_phantom_assassin',
	'npc_dota_hero_silencer',
	'npc_dota_hero_skeleton_king',
	'npc_dota_hero_sniper',
	'npc_dota_hero_sven',
	'npc_dota_hero_templar_assassin',
	'npc_dota_hero_viper',
	'npc_dota_hero_warlock',
	'npc_dota_hero_zuus',
	'npc_dota_hero_skywrath_mage',
}


local RB = Vector(-7174.000000, -6671.00000, 0.000000)
local DB = Vector(7023.000000, 6450.000000, 0.000000)
local fSpamThreshold = 0.35;


----------------------------------------
--[[句柄全局变量------------------------
-----------------------------------------
----------------句柄全局变量放这里初始化
-----------------------------------------
---------------------------通过句柄使用的
--]]
--每个友方英雄的个人全局变量
for i,id in pairs(tAllyIDList)
do
	--获取成员信息
	local bHuman = not IsPlayerBot(id)
	local hHero = GetTeamMember(i)
	
	--初始化文件全局变量
	if hHero ~= nil
	then
		if bHuman then table.insert(tAllyHumanList, hHero) end
		table.insert(tAllyHeroList, hHero)
	
		--逐个初始化个人全局变量
		hHero.continueKillCount = 0
		hHero.continueDeathCount = 0
		
		hHero.sLastRepeatItem = nil	
	
	
	end
end 

--每个敌方英雄的标记全局变量
for i,id in pairs(tEnemyIDList)
do
	--获取成员信息
	local bHuman = not IsPlayerBot(id)
	local hHero = GetTeamMember(i)
	
	
	if hHero ~= nil
	then
		--初始化文件全局变量
		if bHuman then table.insert(tEnemyHumanList, hHero) end
		table.insert(tEnemyHeroList, hHero)
	
	
		--逐个初始化个人全局变量
		hHero.continueKillCount = 0
		hHero.continueDeathCount = 0
	
	
	
	end
end 

----------------------------------------
--[[模块全局变量------------------------
-----------------------------------------
----------------模块全局变量放这里初始化
-----------------------------------------
---------------------------通过模块使用的
--]]

J.Site  = require(GetScriptDirectory()..'/FunLib/jmz_site')
J.Item  = require(GetScriptDirectory()..'/FunLib/jmz_item')
J.Buff  = require(GetScriptDirectory()..'/FunLib/jmz_buff')
J.Role  = require(GetScriptDirectory()..'/FunLib/jmz_role')
J.Skill = require(GetScriptDirectory()..'/FunLib/jmz_skill')
J.Chat  = require(GetScriptDirectory()..'/FunLib/jmz_chat')

---[[--------------------------------
-------------------------------------
if bDebugTeam
then
	print(GBotTeam..': Simple AI: Function Init Successful!')
end
------------------------------------
-------变量部分完成, 下面开始函数部分
-----------------------------------]]
function J.SetUserHeroInit(nAbilityBuildList, nTalentBuildList, sBuyList, sSellList)

	local bot = GetBot()
	
	if not IsSleevelHeros() then --不是锦囊英雄
		return nAbilityBuildList, nTalentBuildList, sBuyList, sSellList;
	end

	if J.Role.IsUserMode() and J.Role.IsUserHero()
	then
		local nDirType = J.Role.GetDirType()
		local sBotDir = J.Chat.GetHeroDirName(bot, nDirType)
		local BotSet = require( sBotDir );
		if J.Chat.GetRawGameWord(BotSet['ShiFouShengXiao']) == true
		then
			nAbilityBuildList = BotSet['JiNeng'];
			nTalentBuildList = J.Chat.GetTalentBuildList(BotSet['TianFu'])
			sBuyList = J.Chat.GetItemBuildList(BotSet['ChuZhuang'])
			sSellList = J.Chat.GetItemBuildList(BotSet['GuoDuZhuang'])
			if J.Chat.GetRawGameWord(BotSet['ShiFouDaFuZhu']) == true
			then J.Role.SetUserSup(bot) end
		end
	end

	return nAbilityBuildList, nTalentBuildList, sBuyList, sSellList;
	
end

function IsSleevelHeros() 

	local bot = GetBot()

	for _,u in pairs(tSleevelHeros) do
		if bot:GetUnitName() == u
		then
			return true;
		end
	end
	return false;
end

--在这里更新全局变量
function J.ConsiderUpdateEnvironment(bot)



end


function J.PrintInitStatus(nFlag, nNum, sMessage1, sMessage2)

	local bot = GetBot()

	if nFlag +1 ~= nNum 
	   or not J.IsDebugHero(bot, sDebugHero)
	then return nFlag end
	
	local botName = string.gsub(string.sub(bot:GetUnitName(), 15), '_', '');
	print('Simple AI '..string.sub(botName, 1, 4)..': '..string.sub(sMessage1, 1, 5)..' of '..sMessage2..' init successful!')
	return nNum
	
end


function J.IsDebugHero(bot, sName)

    return  bDebugMode and bDebugTeam
			and bot:GetUnitName() == sName

end


function J.CanNotUseAbility(bot)
	return bot:NumQueuedActions() > 0 
		   or not bot:IsAlive()
		   or bot:IsInvulnerable() 
		   or bot:IsCastingAbility() 
		   or bot:IsUsingAbility() 
		   or bot:IsChanneling()  
	       or bot:IsSilenced() 
		   or bot:IsStunned() 
		   or bot:IsHexed()  
		   or bot:HasModifier("modifier_doom_bringer_doom")
		   or bot:HasModifier('modifier_item_forcestaff_active')
end


function J.GetVulnerableWeakestUnit(bHero, bEnemy, nRadius, bot)
	local units = {};
	local weakest = nil;
	local weakestHP = 10000;
	if bHero then
		units = bot:GetNearbyHeroes(nRadius, bEnemy, BOT_MODE_NONE);
	else
		units = bot:GetNearbyLaneCreeps(nRadius, bEnemy);
	end
	for _,u in pairs(units) do
		if u:GetHealth() < weakestHP 
		   and J.CanCastOnNonMagicImmune(u) 
		then
			weakest = u;
			weakestHP = u:GetHealth();
		end
	end
	return weakest;
end


--友军生物数量
function J.GetUnitAllyCountAroundEnemyTarget(target, nRadius)

	local targetLoc  = target:GetLocation();
	local heroCount  = J.GetNearbyAroundLocationUnitCount(false, true, nRadius, targetLoc);
	local creepCount = J.GetNearbyAroundLocationUnitCount(false, false, nRadius, targetLoc);
	
	return heroCount + creepCount;
	
end


--敌军生物数量
function J.GetAroundTargetEnemyUnitCount(target, nRadius)

	local targetLoc  = target:GetLocation();
	local heroCount  = J.GetNearbyAroundLocationUnitCount(true, true, nRadius, targetLoc);
	local creepCount = J.GetNearbyAroundLocationUnitCount(true, false, nRadius, targetLoc);
	
	return heroCount + creepCount;
	
end


--敌军英雄数量
function J.GetAroundTargetEnemyHeroCount(target, nRadius)
	
	return J.GetNearbyAroundLocationUnitCount(true, true, nRadius, target:GetLocation());
	
end


--通用数量
function J.GetNearbyAroundLocationUnitCount(bEnemy, bHero, nRadius, vLoc)

	local bot = GetBot();
	local nCount = 0;	
	local units = {};
	
	if bHero then
		units = bot:GetNearbyHeroes(1600, bEnemy, BOT_MODE_NONE);
	else
		units = bot:GetNearbyCreeps(1600, bEnemy);
	end
	
	for _,u in pairs(units)
	do
		if u:IsAlive()
		   and GetUnitToLocationDistance(u, vLoc) <= nRadius
		then
			nCount = nCount + 1;
		end	
	end
	
	return nCount;
end


function J.GetAttackTargetEnemyCreepCount(target, nRange)

	local bot = GetBot();
	local nAllyCreeps = bot:GetNearbyCreeps(nRange, false);
	local nAttackEnemyCount = 0;
	for _,creep in pairs(nAllyCreeps)
	do
		if  creep:IsAlive()
			and creep:GetAttackTarget() == target
		then
			nAttackEnemyCount = nAttackEnemyCount + 1;
		end
	end
	
	return nAttackEnemyCount;

end


function J.GetVulnerableUnitNearLoc(bHero, bEnemy, nCastRange, nRadius, vLoc, bot)
	local units = {};
	local weakest = nil;
	if bHero then
		units = bot:GetNearbyHeroes(nCastRange, bEnemy, BOT_MODE_NONE);
	else
		units = bot:GetNearbyLaneCreeps(nCastRange, bEnemy);
	end
	for _,u in pairs(units) do
		if GetUnitToLocationDistance(u, vLoc) < nRadius and J.CanCastOnNonMagicImmune(u) then
			weakest = u;
			break;
		end
	end
	return weakest;
end

function J.GetAoeEnemyHeroLocation(bot, nCastRange, nRadius, nCount)

	local nAoe = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0);
	if nAoe.count >= nCount
	then
		local nEnemyHeroList = J.GetEnemyList(bot, 1600);
		local nTrueCount = 0;
		for _,enemy in pairs(nEnemyHeroList)
		do
			if GetUnitToLocationDistance(enemy, nAoe.targetloc) <= nRadius
			   and not enemy:IsMagicImmune()
			then
				nTrueCount = nTrueCount + 1;
			end
		end
		
		if nTrueCount >= nCount
		then
			return nAoe.targetLoc;
		end
	end
	
	return nil
end

function J.IsWithoutTarget(bot)

	return bot:GetTarget() == nil and bot:GetAttackTarget() == nil

end


function J.GetProperTarget(bot)
	local target = bot:GetTarget();
	if target == nil then
		target = bot:GetAttackTarget();
	end
	return target;
end


function J.IsAllyCanKill(target)
	
	if target:GetHealth()/target:GetMaxHealth() > 0.38
	then
		return false;
	end	
	
	local nTotalDamage = 0;
	local nDamageType = DAMAGE_TYPE_PHYSICAL;
	local TeamMember = GetTeamPlayers(GetTeam());
	for i = 1, #TeamMember
	do 
		local ally = GetTeamMember(i);
		if ally ~= nil and ally:IsAlive() 
		   and ( ally:GetAttackTarget() == target )
		   and GetUnitToUnitDistance(ally, target) <= ally:GetAttackRange() + 100
		then
			nTotalDamage = nTotalDamage + ally:GetAttackDamage();
		end
	end
	
	nTotalDamage = nTotalDamage * 1.88 + J.GetAttackProjectileDamageByRange(target, 1200);
	
	if J.CanKillTarget(target, nTotalDamage, nDamageType)
	then
		return true;
	end
	
	return false;
end


function J.IsOtherAllyCanKillTarget(bot, target)

	if target:GetHealth()/target:GetMaxHealth() > 0.38
	then
		return false;
	end

	local nTotalDamage = 0;
	local nDamageType = DAMAGE_TYPE_PHYSICAL;
	local TeamMember = GetTeamPlayers(GetTeam());
	for i = 1, #TeamMember
	do
		local ally = GetTeamMember(i);
		if ally ~= nil 
		   and ally:IsAlive() and ally ~= bot
		   and not J.IsDisabled(true, ally)
		   and ally:GetHealth()/ally:GetMaxHealth() > 0.15
		   and ally:IsFacingLocation(target:GetLocation(), 45)
		   and GetUnitToUnitDistance(ally, target) <= ally:GetAttackRange() + 90
		then
			local allyTarget = J.GetProperTarget(ally);
			if allyTarget == nil or allyTarget == target
			then
				local allyDamageTime = 2.8;
				if J.IsHumanPlayer(ally) then allyDamageTime = 4.2 end;
				nTotalDamage = nTotalDamage + ally:GetEstimatedDamageToTarget(true, target, allyDamageTime, DAMAGE_TYPE_PHYSICAL);
			end
		end
	end
	
	if nTotalDamage > target:GetHealth()
	then
		return true;
	end

	return false;
end


function J.GetAlliesNearLoc(vLoc, nRadius)
	local allies = {};
	for i,id in pairs(GetTeamPlayers(GetTeam())) do
		local member = GetTeamMember(i);
		if member ~= nil and member:IsAlive() and GetUnitToLocationDistance(member, vLoc) <= nRadius then
			table.insert(allies, member);
		end
	end
	return allies;
end


function J.IsAllyHeroBetweenAllyAndEnemy(hAlly, hEnemy, vLoc, nRadius)
	local vStart = hAlly:GetLocation();
	local vEnd = vLoc;
	local heroes = hAlly:GetNearbyHeroes(1600, false, BOT_MODE_NONE);
	for i,hero in pairs(heroes) do
		if hero ~= hAlly then
			local tResult = PointToLineDistance(vStart, vEnd, hero:GetLocation());
			if tResult ~= nil and tResult.within and tResult.distance <= nRadius + 50 then
				return true;
			end
		end
	end
	heroes = hEnemy:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	for i,hero in pairs(heroes) do
		if hero ~= hAlly then
			local tResult = PointToLineDistance(vStart, vEnd, hero:GetLocation());
			if tResult ~= nil and tResult.within and tResult.distance <= nRadius + 50 then
				return true;
			end
		end
	end
	return false;
end


function J.IsSandKingThere(bot, nCastRange, fTime)
	local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	for _,enemy in pairs(enemies) do
		if enemy:GetUnitName() == "npc_dota_hero_sand_king" and enemy:HasModifier('modifier_sandking_sand_storm_invis') then
			return true, enemy:GetLocation();
		end
		if enemy:IsChanneling() and not enemy:HasModifier('modifier_item_dustofappearance')
		then
		    if enemy:IsInvisible()
			   or enemy:HasModifier('modifier_invisible')
			   or enemy:HasModifier('modifier_item_invisibility_edge_windwalk')
			   or enemy:HasModifier('modifier_item_silver_edge_windwalk')
			then
				return true, enemy:GetLocation();
			end
		end
	end
	return false, nil;
end


function J.GetUltimateAbility(bot)
	return bot:GetAbilityInSlot(5);
end


function J.CanUseRefresherShard(bot)
	local ult = J.GetUltimateAbility(bot);
	if ult ~= nil and ult:IsPassive() == false then
		local ultCD = ult:GetCooldown();
		local manaCost = ult:GetManaCost();
		if bot:GetMana() >= manaCost and ult:GetCooldownTimeRemaining() >= ultCD/2 then
			return true;
		end
	end
	return false;
end


function J.GetMostUltimateCDUnit()
	local unit = nil;
	local maxCD = 0;
	for i,id in pairs(GetTeamPlayers(GetTeam())) do
		if IsHeroAlive(id) then
			local member = GetTeamMember(i);
			if member ~= nil and member:IsAlive() 
			   and member:GetUnitName() ~= "npc_dota_hero_nevermore" 
			   and member:GetUnitName() ~= "npc_dota_hero_arc_warden"
			then
			    if member:GetUnitName() == "npc_dota_hero_silencer" or member:GetUnitName() == "npc_dota_hero_warlock"
				then
				    return member;
				end
				local ult = J.GetUltimateAbility(member);
				--print(member:GetUnitName()..tostring(ult:GetName())..tostring(ult:GetCooldown()))
				if ult ~= nil and ult:IsPassive() == false and ult:GetCooldown() >= maxCD then
					unit = member;
					maxCD = ult:GetCooldown();
				end
			end
		end
	end
	return unit;
end


function J.GetPickUltimateScepterUnit()
	local unit = nil;
	local maxNetWorth = 0;
	for i,id in pairs(GetTeamPlayers(GetTeam())) do
		if IsHeroAlive(id) then
			local member = GetTeamMember(i);
			if member ~= nil and member:IsAlive() 
			   and not member:HasScepter()
			   and ( member:GetPrimaryAttribute() == ATTRIBUTE_INTELLECT
					 or not member:IsBot() )
			then
				if not member:IsBot()
				then
					return member;
				end
			
			    if member:GetUnitName() ~= "npc_dota_hero_necrolyte" 
					and member:GetUnitName() ~= "npc_dota_hero_warlock"
					and member:GetUnitName() ~= "npc_dota_hero_zuus"
					and ( member:GetItemInSlot(8) == nil or member:GetItemInSlot(7) == nil )
				then
					local mNetWorth = member:GetNetWorth();
--					print(member:GetUnitName()..":"..tostring(mNetWorth))
					if mNetWorth >= maxNetWorth 
					then
						unit = member;
						maxNetWorth = mNetWorth;
					end
				end
			end
		end
	end
	return unit;
end


function J.CanUseRefresherOrb(bot)
	local ult = J.GetUltimateAbility(bot);
	if ult ~= nil and ult:IsPassive() == false then
		local ultCD = ult:GetCooldown();
		local manaCost = ult:GetManaCost();
		if bot:GetMana() >= manaCost+375 and ult:GetCooldownTimeRemaining() >= ultCD/2 then
			return true;
		end
	end
	return false;
end


function J.IsSuspiciousIllusion(npcTarget)
		
	if not npcTarget:IsHero()
	   or npcTarget:IsCastingAbility()
	   or npcTarget:IsUsingAbility()
	   or npcTarget:IsChanneling()
	   -- or npcTarget:HasModifier("modifier_item_satanic_unholy")
	   -- or npcTarget:HasModifier("modifier_item_mask_of_madness_berserk")
	   -- or npcTarget:HasModifier("modifier_black_king_bar_immune")
	   -- or npcTarget:HasModifier("modifier_rune_doubledamage")
	   -- or npcTarget:HasModifier("modifier_rune_regen")
	   -- or npcTarget:HasModifier("modifier_rune_haste")
	   -- or npcTarget:HasModifier("modifier_rune_arcane")
	   -- or npcTarget:HasModifier("modifier_item_phase_boots_active")
	then
		return false;
	end

	local bot = GetBot();

	if npcTarget:GetTeam() == bot:GetTeam()
	then
		return npcTarget:IsIllusion() or npcTarget:HasModifier("modifier_arc_warden_tempest_double")
	elseif npcTarget:GetTeam() == GetOpposingTeam()	then
	
		if  npcTarget:HasModifier('modifier_illusion') 
			or npcTarget:HasModifier('modifier_phantom_lancer_doppelwalk_illusion') 
			or npcTarget:HasModifier('modifier_phantom_lancer_juxtapose_illusion')
			or npcTarget:HasModifier('modifier_darkseer_wallofreplica_illusion') 
			or npcTarget:HasModifier('modifier_terrorblade_conjureimage')	   
		then
			return true;
		end

		
		local tID = npcTarget:GetPlayerID();
		
		if not IsHeroAlive( tID )
		then
			return true;
		end	

		if GetHeroLevel( tID ) > npcTarget:GetLevel()
		then
			return true;
		end
		--[[
		if GetSelectedHeroName( tID ) ~= "npc_dota_hero_morphling"
			and GetSelectedHeroName( tID ) ~= npcTarget:GetUnitName()
		then
			return true;
		end
		--]]
	end
	
	return false;
end


function J.CanCastOnMagicImmune(npcTarget)
	return npcTarget:CanBeSeen() 
	       and not npcTarget:IsInvulnerable() 
		   and not J.IsSuspiciousIllusion(npcTarget) 
		   and not J.HasForbiddenModifier(npcTarget) 
		   and not J.IsAllyCanKill(npcTarget)
end


function J.CanCastOnNonMagicImmune(npcTarget)
	return npcTarget:CanBeSeen() 
		   and not npcTarget:IsMagicImmune() 
		   and not npcTarget:IsInvulnerable() 
		   and not J.IsSuspiciousIllusion(npcTarget) 
		   and not J.HasForbiddenModifier(npcTarget) 
		   and not J.IsAllyCanKill(npcTarget);
end


function J.CanCastOnTargetAdvanced( npcTarget )
	return not npcTarget:HasModifier("modifier_antimage_spell_shield")
			and not npcTarget:HasModifier("modifier_item_sphere_target")
			and not npcTarget:HasModifier("modifier_item_lotus_orb_active")
			and not npcTarget:HasModifier("modifier_item_aeon_disk_buff")
			and not npcTarget:HasModifier("modifier_dazzle_shallow_grave")
end


--加入时间后的进阶函数
function J.CanCastUnitSpellOnTarget( npcTarget, nDelay )
	
	for _,mod in pairs(J.Buff["hero_has_spell_shield"])
	do
		if npcTarget:HasModifier(mod) 
		   and J.GetModifierTime(npcTarget, mod) >= nDelay
		then
			return false;
		end	
	end
	
	return true;
end


function J.CanKillTarget(npcTarget, dmg, dmgType)
	return npcTarget:GetActualIncomingDamage( dmg, dmgType ) >= npcTarget:GetHealth(); 
end


function J.WillKillTarget(npcTarget, dmg, dmgType, dTime)
	
	local targetHealth = npcTarget:GetHealth() + npcTarget:GetHealthRegen() * dTime + 1;
	
	local nRealBonus = J.GetTotalAttackWillRealDamage(npcTarget, dTime);
	
	local nTotalDamage = npcTarget:GetActualIncomingDamage( dmg, dmgType ) + nRealBonus;

	return nTotalDamage > targetHealth and nRealBonus < targetHealth - 1  ; 
end


function J.WillMagicKillTarget(bot, npcTarget, dmg, nDelay)
	
	local nDamageType = DAMAGE_TYPE_MAGICAL;
	
	local MagicResistReduce = 1 - npcTarget:GetMagicResist();
	if MagicResistReduce  < 0.05 then  MagicResistReduce  = 0.05 end;
	
	local HealthBack =  npcTarget:GetHealthRegen() *nDelay;
	
	local EstDamage =  dmg * ( 1 + bot:GetSpellAmp()) - HealthBack/MagicResistReduce;	

	if npcTarget:HasModifier("modifier_medusa_mana_shield") 
	then 
		local EstDamageMaxReduce = EstDamage * 0.6;
		if npcTarget:GetMana() * 2.5 >= EstDamageMaxReduce
		then
			EstDamage = EstDamage *  0.4;
		else
			EstDamage = EstDamage *  0.4 + EstDamageMaxReduce - npcTarget:GetMana() * 2.5;
		end
	end 
	
	if npcTarget:GetUnitName() == "npc_dota_hero_bristleback" 
		and not npcTarget:IsFacingLocation(bot:GetLocation(), 120)
	then 
		EstDamage = EstDamage * 0.7; 
	end 
	
	if npcTarget:HasModifier("modifier_kunkka_ghost_ship_damage_delay")
	then
		local buffTime = J.GetModifierTime(npcTarget, "modifier_kunkka_ghost_ship_damage_delay");
		if buffTime >= nDelay then EstDamage = EstDamage *0.55; end
	end		
	
	if npcTarget:HasModifier("modifier_templar_assassin_refraction_absorb") 
	then
		local buffTime = J.GetModifierTime(npcTarget, "modifier_templar_assassin_refraction_absorb");
		if buffTime >= nDelay then EstDamage = 0; end
	end		
	
	local nRealDamage = npcTarget:GetActualIncomingDamage( EstDamage, nDamageType )

	return nRealDamage >= npcTarget:GetHealth() --, nRealDamage 
end


function J.HasForbiddenModifier(npcTarget)
	
	for _,mod in pairs(J.Buff['enemy_is_immune'])
	do
		if npcTarget:HasModifier(mod) then
			return true
		end	
	end

	if npcTarget:IsHero()
	then
		local enemies = npcTarget:GetNearbyHeroes(800, false, BOT_MODE_NONE);
		if enemies ~= nil and #enemies >= 2
		then
			for _,mod in pairs(J.Buff['enemy_is_undead'])
			do
				if npcTarget:HasModifier(mod) then
					return true
				end	
			end
		end
		
		if npcTarget:GetItemInSlot(8) ~= nil		
		then
			local keyItem = npcTarget:GetItemInSlot(8);
			if keyItem:GetName() == "item_orb_of_venom"
			then
				return true;
			end
		end
	else
		if npcTarget:HasModifier("modifier_crystal_maiden_frostbite")
		   or npcTarget:HasModifier("modifier_fountain_glyph")
		then
			return true;
		end	
	end	
	
	return false;
end


function J.ShouldEscape(bot)
	
	local tableNearbyAttackAllies = bot:GetNearbyHeroes( 660, false, BOT_MODE_ATTACK );
	if #tableNearbyAttackAllies > 0 and J.GetHPR(bot) > 0.16 then return false end

	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	if ( bot:WasRecentlyDamagedByAnyHero(2.0) 
	     or bot:WasRecentlyDamagedByTower(2.0) 
		 or #tableNearbyEnemyHeroes >= 2   )
	then
		return true;
	end
end


function J.IsDisabled(bEnemy, npcTarget)
	
	if bEnemy then
		
		return npcTarget:IsRooted() 
		       or npcTarget:IsStunned() 
			   or npcTarget:IsHexed() 
			   or npcTarget:IsNightmared() 
			   or J.IsTaunted(npcTarget); 
	else
	
		if npcTarget:IsStunned() and J.GetRemainStunTime(npcTarget) > 0.8
		then
			return true;
		end
		
		if npcTarget:IsSilenced() and not npcTarget:HasModifier("modifier_item_mask_of_madness_berserk")
		then
			return true;
		end
	
		return npcTarget:IsRooted() 
		       or npcTarget:IsHexed() 
			   or npcTarget:IsNightmared() 
			   or J.IsTaunted(npcTarget);
	
	end
end


function J.IsTaunted(npcTarget)
	return npcTarget:HasModifier("modifier_axe_berserkers_call") 
	    or npcTarget:HasModifier("modifier_legion_commander_duel") 
	    or npcTarget:HasModifier("modifier_winter_wyvern_winters_curse") 
		or npcTarget:HasModifier("modifier_winter_wyvern_winters_curse_aura");
end


function J.IsInRange(npcTarget, bot, nCastRange)
	return GetUnitToUnitDistance( npcTarget, bot ) <= nCastRange;
end


function J.IsInLocRange(npcTarget, nLoc, nCastRange)
	return GetUnitToLocationDistance( npcTarget, nLoc ) <= nCastRange;
end


function J.IsInTeamFight(bot, range)
	if range > 1600 then range = 1600 end;
	local tableNearbyAttackingAlliedHeroes = bot:GetNearbyHeroes( range, false, BOT_MODE_ATTACK );
	return #tableNearbyAttackingAlliedHeroes >= 2 and bot:GetActiveMode() ~= BOT_MODE_RETREAT;
end


function J.IsRetreating(bot)

	local mode = bot:GetActiveMode();
	local modeDesire = bot:GetActiveModeDesire();
	local bDamagedByAnyHero = bot:WasRecentlyDamagedByAnyHero(2.0);

	return ( mode == BOT_MODE_RETREAT and modeDesire > BOT_MODE_DESIRE_MODERATE and bot:DistanceFromFountain() > 600 )
		  or ( mode == BOT_MODE_EVASIVE_MANEUVERS and bDamagedByAnyHero ) 
		  or ( bot:HasModifier('modifier_bloodseeker_rupture') and bDamagedByAnyHero )
		  or ( mode == BOT_MODE_FARM and modeDesire > BOT_MODE_DESIRE_ABSOLUTE )
end


function J.IsGoingOnSomeone(bot)
	local mode = bot:GetActiveMode();
	return mode == BOT_MODE_ROAM or
		   mode == BOT_MODE_TEAM_ROAM or
		   mode == BOT_MODE_ATTACK or
		   mode == BOT_MODE_DEFEND_ALLY
end


function J.IsDefending(bot)
	local mode = bot:GetActiveMode();
	return mode == BOT_MODE_DEFEND_TOWER_TOP or
		   mode == BOT_MODE_DEFEND_TOWER_MID or
		   mode == BOT_MODE_DEFEND_TOWER_BOT 
end


function J.IsPushing(bot)
	local mode = bot:GetActiveMode();
	return mode == BOT_MODE_PUSH_TOWER_TOP or
		   mode == BOT_MODE_PUSH_TOWER_MID or
		   mode == BOT_MODE_PUSH_TOWER_BOT 
end


function J.IsLaning(bot)
	local mode = bot:GetActiveMode();
	return mode == BOT_MODE_LANING
end


function J.IsFarming(bot)
	local mode = bot:GetActiveMode();
	local nTarget = J.GetProperTarget(bot);
	return mode == BOT_MODE_FARM
			or ( nTarget ~= nil and nTarget:IsAlive() and nTarget:GetTeam() == TEAM_NEUTRAL and not J.IsRoshan(nTarget))
end


function J.IsShopping(bot)
	
	local mode = bot:GetActiveMode();
	return mode == BOT_MODE_RUNE 
	       or mode == BOT_MODE_SECRET_SHOP 
		   or mode == BOT_MODE_SIDE_SHOP 
end


function J.GetTeamFountain()
	local Team = GetTeam();
	if Team == TEAM_DIRE then
		return DB;
	else
		return RB;
	end
end


function J.GetEnemyFountain()
	local Team = GetTeam();
	if Team == TEAM_DIRE then
		return RB;
	else
		return DB;
	end
end


function J.GetComboItem(bot, item_name)
	local Slot = bot:FindItemSlot(item_name);
	if Slot >= 0 and Slot <= 5 then
		return bot:GetItemInSlot(Slot);
	else
		return nil;
	end
end


function J.HasItem(bot, item_name)
	
	if bot:IsMuted() then return false end 
	
	local Slot = bot:FindItemSlot(item_name);
	
	if Slot >= 0 and Slot <= 5 then	return true; end
	
	return false;
end


function J.IsItemAvailable(item_name)
	
	local bot = GetBot();
		
    local slot = bot:FindItemSlot(item_name)
	
	if slot >= 0 and slot <= 5 then
		return bot:GetItemInSlot(slot);
	end
	
    return nil;
end


function J.GetMostHpUnit(ListUnit)
	local mostHpUnit = nil;
	local maxHP = 0;
	for _,unit in pairs(ListUnit)
	do
		local uHp = unit:GetHealth();
		if  uHp > maxHP then
			mostHpUnit = unit;
			maxHP = uHp;
		end
	end
	return mostHpUnit
end


function J.GetLeastHpUnit(ListUnit)
	local leastHpUnit = nil;
	local minHP = 999999;
	for _,unit in pairs(ListUnit)
	do
		local uHp = unit:GetHealth();
		if  uHp < minHP then
			leastHpUnit = unit;
			minHP = uHp;
		end
	end
	return leastHpUnit;
end


function J.IsAllowedToSpam(bot, nManaCost)
	if bot:HasModifier("modifier_silencer_curse_of_the_silent") then return false end;

	return ( bot:GetMana() - nManaCost ) / bot:GetMaxMana() >= fSpamThreshold;
end


function J.IsAllyUnitSpell(sAbilityName)

	local  nSpell = {
					"bloodseeker_bloodrage", 
					"omniknight_purification", 
					"omniknight_repel", 
					"medusa_mana_shield", 
					"grimstroke_spirit_walk", 
					"dazzle_shallow_grave", 
					"ogre_magi_bloodlust", 
					"lich_frost_shield", 
					};
	for _,name in pairs(nSpell)
	do
		if sAbilityName == name
		then
			return true;
		end
	end

	return false;
	
end


function J.IsProjectileUnitSpell(sAbilityName)

	local nSpell = {
					"chaos_knight_chaos_bolt", 
					"grimstroke_ink_creature", 
					"lich_chain_frost", 
					"medusa_mystic_snake", 
					"phantom_assassin_stifling_dagger", 
					"skeleton_king_hellfire_blast", 
					"skywrath_mage_arcane_bolt", 
					"sven_storm_bolt", 
					"viper_viper_strike", 
					"witch_doctor_paralyzing_cask", 
					};
					
	for _,name in pairs(nSpell)
	do
		if sAbilityName == name
		then
			return true;
		end
	end

	return false;


end


function J.IsOnlyProjectileSpell(sAbilityName)

	local nSpell = {
					"necrolyte_death_pulse", 
					"arc_warden_spark_wraith", 
					"tinker_heat_seeking_missile", 
					"skywrath_mage_concussive_shot", 
					"rattletrap_battery_assault", 
					};
					
	for _,name in pairs(nSpell)
	do
		if sAbilityName == name
		then
			return true;
		end
	end

	return false;

end


function J.IsWillBeCastUnitTargetSpell(bot, nRange)
	
	if nRange > 1600 then nRange = 1600 end
	
	local nEnemys = bot:GetNearbyHeroes(nRange, true, BOT_MODE_NONE);
	for _,npcEnemy in pairs(nEnemys)
	do
		if npcEnemy ~= nil and npcEnemy:IsAlive()
		   and ( npcEnemy:IsCastingAbility() or npcEnemy:IsUsingAbility() )
		   and npcEnemy:IsFacingLocation(bot:GetLocation(), 20)
		then
			local nAbility = npcEnemy:GetCurrentActiveAbility();
			if nAbility ~= nil 
				and nAbility:GetBehavior() == ABILITY_BEHAVIOR_UNIT_TARGET
			then
				local sAbilityName = nAbility:GetName();
				if not J.IsAllyUnitSpell(sAbilityName)
				then				
					if J.IsInRange(npcEnemy, bot, 330)
						or not J.IsProjectileUnitSpell(sAbilityName)
					then	
						if not J.IsHumanPlayer(npcEnemy)
						then
							return true;
						else
							local nCycle = npcEnemy:GetAnimCycle();
							local nPoint = nAbility:GetCastPoint();
							if nCycle > 0.1 and nPoint * ( 1 - nCycle) < 0.27 --极限时机0.26
							then
								return true;
							end						
						end
					end
				end
			end		
		end
	end

	return false;
end


function J.IsWillBeCastPointSpell(bot, nRange)
	
	local nEnemys = bot:GetNearbyHeroes(nRange, true, BOT_MODE_NONE);
	for _,npcEnemy in pairs(nEnemys)
	do
		if npcEnemy ~= nil and npcEnemy:IsAlive()
		   and ( npcEnemy:IsCastingAbility() or npcEnemy:IsUsingAbility() )
		   and npcEnemy:IsFacingLocation(bot:GetLocation(), 45)
		then
			local nAbility = npcEnemy:GetCurrentActiveAbility();
			if nAbility ~= nil 
				and nAbility:GetBehavior() == ABILITY_BEHAVIOR_POINT
			then
				return true;
			end		
		end
	end

	return false;
end


--可躲避敌方非攻击弹道
function J.IsProjectileIncoming(bot, range)
	local incProj = bot:GetIncomingTrackingProjectiles()
	for _,p in pairs(incProj)
	do
		if p.is_dodgeable 
		   and not p.is_attack 
		   and GetUnitToLocationDistance(bot, p.location) < range 
		   and ( p.caster == nil or p.caster:GetTeam() ~= GetTeam() ) 
		   and ( p.ability ~= nil and not J.IsOnlyProjectileSpell(p.ability:GetName()) )
		then
			return true;
		end
	end
	return false;
end


--可反弹敌方非攻击弹道
function J.IsUnitTargetProjectileIncoming(bot, range)
	local incProj = bot:GetIncomingTrackingProjectiles()
	for _,p in pairs(incProj)
	do
		if not p.is_attack 
		   and GetUnitToLocationDistance(bot, p.location) < range 
		   and ( p.caster == nil 
		         or ( p.caster:GetTeam() ~= bot:GetTeam() 
					  and p.caster:GetUnitName() ~= "npc_dota_hero_antimage" 
					  and p.caster:GetUnitName() ~= "npc_dota_hero_templar_assassin") )
		   and ( p.ability ~= nil 
		         and ( p.ability:GetName() ~= "medusa_mystic_snake" 
				       or p.caster == nil 
					   or p.caster:GetUnitName() == "npc_dota_hero_medusa" ) ) 
		   and ( p.ability:GetBehavior() == ABILITY_BEHAVIOR_UNIT_TARGET 
				 or not J.IsOnlyProjectileSpell(p.ability:GetName()))
		then
			return true;
		end
	end
	return false;
end


--攻击弹道
function J.IsAttackProjectileIncoming(bot, range)
	local incProj = bot:GetIncomingTrackingProjectiles()
	for _,p in pairs(incProj)
	do
		if p.is_attack
		   and GetUnitToLocationDistance(bot, p.location) < range 
	    then
			return true;
		end
	end
	return false;
end


--非攻击敌方弹道
function J.IsNotAttackProjectileIncoming(bot, range)
	local incProj = bot:GetIncomingTrackingProjectiles()
	for _,p in pairs(incProj)
	do
		if not p.is_attack
		   and GetUnitToLocationDistance(bot, p.location) < range 
		   and ( p.caster == nil or p.caster:GetTeam() ~= bot:GetTeam() )
		   and ( p.ability ~= nil and ( p.ability:GetName() ~= "medusa_mystic_snake" or p.caster == nil or p.caster:GetUnitName() == "npc_dota_hero_medusa" ) ) 
		then
			return true;
		end
	end
	return false;
end


function J.GetAttackProDelayTime(bot, nCreep)

	local botName        = bot:GetUnitName();
	local botAttackRange = bot:GetAttackRange();
	local botAttackPoint = bot:GetAttackPoint();
	local botAttackSpeed = bot:GetAttackSpeed();
	local botProSpeed    = bot:GetAttackProjectileSpeed();
	local botMoveSpeed   = bot:GetCurrentMovementSpeed();
	local nDist  =  GetUnitToUnitDistance(bot, nCreep);
	local nAttackProDelayTime = botAttackPoint / botAttackSpeed;
	
	if bot:GetAttackTarget() == nCreep
	   and bot:GetAnimActivity() == 1503
	   and bot:GetAnimCycle() < botAttackPoint
	then
		nAttackProDelayTime = 0.7 * (botAttackPoint - bot:GetAnimCycle())/ botAttackSpeed;
	end
	
	if botAttackRange > 310 or botName == "npc_dota_hero_templar_assassin"
	then		
		
		local ignoreDist = 50 ;
		if bot:GetPrimaryAttribute() == ATTRIBUTE_INTELLECT then ignoreDist = 70 end;
		
		local projectMoveDist = nDist - ignoreDist;
		
		if projectMoveDist < 0 then projectMoveDist = 0 end;
		
		if projectMoveDist > botAttackRange then projectMoveDist = botAttackRange - 32; end
	
		nAttackProDelayTime = nAttackProDelayTime + projectMoveDist/botProSpeed;
		
		if nDist > botAttackRange + ignoreDist/1.25 and botName ~= "npc_dota_hero_sniper"
		then
			nAttackProDelayTime = nAttackProDelayTime + (nDist - botAttackRange - ignoreDist/1.25 )/botMoveSpeed;
		end
		
	end
	
	if botAttackRange < 310 
	   and nDist > botAttackRange + 50
	   and botName ~= "npc_dota_hero_templar_assassin"
	then
		nAttackProDelayTime = nAttackProDelayTime + (nDist - botAttackRange - 50)/botMoveSpeed;
	end
	
	return nAttackProDelayTime ;

end


function J.GetCreepAttackActivityWillRealDamage(nUnit, nTime)
	
	local bot = GetBot();
	local botLV  = bot:GetLevel();
	local gameTime = GameTime();
	local nDamage = 0;
	local othersBeEnemy = true;
	
	if nUnit:GetTeam() ~= bot:GetTeam() then othersBeEnemy = false end;
	
	local nCreeps = bot:GetNearbyLaneCreeps(1600, othersBeEnemy);
	for _,creep in pairs(nCreeps)
	do
		if  creep:GetAttackTarget() == nUnit
			and creep:GetAnimActivity() == ACTIVITY_ATTACK
			and ( J.IsKeyWordUnit( "melee", creep ))
		then
			local attackPoint   = creep:GetAttackPoint();
			local animCycle     = creep:GetAnimCycle();
			local attackPerTime = creep:GetSecondsPerAttack();
			
			if  attackPoint > animCycle 
				and creep:GetLastAttackTime() < gameTime - 0.1
				and (attackPoint - animCycle) * attackPerTime  < nTime * ( 0.9 - botLV/100 )
			then
				nDamage = nDamage + creep:GetAttackDamage() * creep:GetAttackCombatProficiency(nUnit);
			end		
		end
	end
	
	--(or J.IsKeyWordUnit( "ranged", creep ) and GetUnitToUnitDistance(creep, nUnit) < 150)
	
	return nUnit:GetActualIncomingDamage(nDamage, DAMAGE_TYPE_PHYSICAL);

end


function J.GetCreepAttackProjectileWillRealDamage(nUnit, nTime)
	
	local nDamage = 0;
	local incProj = nUnit:GetIncomingTrackingProjectiles()
	for _,p in pairs(incProj)
	do
		if p.is_attack 
		   and p.caster ~= nil
		then
			local nProjectSpeed = p.caster:GetAttackProjectileSpeed();
			if p.caster:IsTower() then nProjectSpeed = nProjectSpeed * 0.9 end;
			local nProjectDist  = nProjectSpeed * nTime * 0.95;
			local nDistance     = GetUnitToLocationDistance(nUnit, p.location);
			if nProjectDist > nDistance 
			then
				nDamage = nDamage + p.caster:GetAttackDamage() * p.caster:GetAttackCombatProficiency(nUnit);
			end
		end
	end
	
	return nUnit:GetActualIncomingDamage(nDamage, DAMAGE_TYPE_PHYSICAL);

end


function J.GetTotalAttackWillRealDamage(nUnit, nTime)

     return J.GetCreepAttackProjectileWillRealDamage(nUnit, nTime) + J.GetCreepAttackActivityWillRealDamage(nUnit, nTime);

end


function J.GetAttackProjectileDamageByRange(nUnit, nRange)
	
	local nDamage = 0;
	local incProj = nUnit:GetIncomingTrackingProjectiles()
	for _,p in pairs(incProj)
	do
		if p.is_attack and p.caster ~= nil
		   and GetUnitToLocationDistance(nUnit, p.location) < nRange 
		then
			nDamage = nDamage + p.caster:GetAttackDamage() * p.caster:GetAttackCombatProficiency(nUnit);
		end
	end
	
	return nDamage;

end


function J.GetCorrectLoc(target, delay)
	
	if target:GetMovementDirectionStability() < 0.6 
	then
		return (target:GetLocation() + target:GetExtrapolatedLocation(delay *0.68))/2;
	elseif target:GetMovementDirectionStability() < 0.9 
		then
			return (target:GetLocation() + target:GetExtrapolatedLocation(delay *0.88))/2;
	else
		return target:GetExtrapolatedLocation(delay);	
	end
	
	return target:GetExtrapolatedLocation(delay);
end


function J.GetEscapeLoc()
	local bot = GetBot();
	local team = GetTeam();
	if bot:DistanceFromFountain() > 2500 then
		return GetAncient(team):GetLocation();
	else
		if team == TEAM_DIRE then
			return DB;
		else
			return RB;
		end
	end
end


function J.IsStuck2(bot)
	if bot.stuckLoc ~= nil and bot.stuckTime ~= nil then 
		local EAd = GetUnitToUnitDistance(bot, GetAncient(GetOpposingTeam()));
		if DotaTime() > bot.stuckTime + 5.0 and GetUnitToLocationDistance(bot, bot.stuckLoc) < 25  
           and bot:GetCurrentActionType() == BOT_ACTION_TYPE_MOVE_TO and EAd > 2200		
		then
			print(bot:GetUnitName().." is stuck")
			--DebugPause();
			return true;
		end
	end
	return false
end


function J.IsStuck(bot)
	if bot.stuckLoc ~= nil and bot.stuckTime ~= nil then 
		local attackTarget = bot:GetAttackTarget();
		local EAd = GetUnitToUnitDistance(bot, GetAncient(GetOpposingTeam()));
		local TAd = GetUnitToUnitDistance(bot, GetAncient(GetTeam()));
		local Et = bot:GetNearbyTowers(450, true);
		local At = bot:GetNearbyTowers(450, false);
		if bot:GetCurrentActionType() == BOT_ACTION_TYPE_MOVE_TO and attackTarget == nil and EAd > 2200 and TAd > 2200 and #Et == 0 and #At == 0  
		   and DotaTime() > bot.stuckTime + 5.0 and GetUnitToLocationDistance(bot, bot.stuckLoc) < 25    
		then
			print(bot:GetUnitName().." is stuck")
			return true;
		end
	end
	return false
end


function J.IsExistInTable(u, tUnit)
	for _,t in pairs(tUnit) 
	do
		if u == t 
		then
			return true;
		end
	end
	return false;
end 


function J.CombineTwoTable(tableOne, tableTwo)
	local targetTable = tableOne;
	local Num = #tableOne;
	
	for i,u in pairs(tableTwo) 
	do  
		targetTable[Num + i] = u;
	end
	
	return targetTable;
end


function J.GetInvUnitInLocCount(bot, nRange, nRadius, loc, pierceImmune)
	local nUnits = 0;
	if nRange > 1600 then nRange = 1600 end
	local units = bot:GetNearbyHeroes(nRange, true, BOT_MODE_NONE);
	for _,u in pairs(units) do
		if ( ( pierceImmune and J.CanCastOnMagicImmune(u) ) 
		      or ( not pierceImmune and J.CanCastOnNonMagicImmune(u) ) ) 
		   and GetUnitToLocationDistance(u, loc) <= nRadius
		then
			nUnits = nUnits + 1;
		end
	end
	return nUnits;
end


function J.GetInLocLaneCreepCount(bot, nRange, nRadius, loc)
	local nUnits = 0;
	if nRange > 1600 then nRange = 1600 end
	local units = bot:GetNearbyLaneCreeps(nRange, true);
	for _,u in pairs(units) do
		if GetUnitToLocationDistance(u, loc) <= nRadius 
		then
			nUnits = nUnits + 1;
		end
	end
	return nUnits;
end


function J.GetInvUnitCount(pierceImmune, units)
	local nUnits = 0;
	if units ~= nil then
		for _,u in pairs(units) do
			if ( pierceImmune and J.CanCastOnMagicImmune(u) ) or ( not pierceImmune and J.CanCastOnNonMagicImmune(u) )  then
				nUnits = nUnits + 1;
			end
		end
	end
	return nUnits;
end


----------------------------------------------------new functions 2018.12.7

function J.GetDistanceFromEnemyFountain(bot)
	local EnemyFountain = J.GetEnemyFountain();
	local Distance = GetUnitToLocationDistance(bot, EnemyFountain);
	return Distance;
end


function J.GetDistanceFromAllyFountain(bot)
	local OurFountain = J.GetTeamFountain();
	local Distance = GetUnitToLocationDistance(bot, OurFountain);
	return Distance;
end


function J.GetDistanceFromAncient(bot, bEnemy)
	local targetAncient = GetAncient(GetTeam());
	if bEnemy then  targetAncient = GetAncient(GetOpposingTeam()); end
	
	return GetUnitToUnitDistance(bot, targetAncient);
end


function J.GetAroundTargetAllyHeroCount(target, nRadius, bot)
			
	local heroes = J.GetAlliesNearLoc(target:GetLocation(), nRadius)

	return #heroes;
end


function J.GetAroundTargetOtherAllyHeroCount(target, nRadius, bot)
			
	local heroes = J.GetAlliesNearLoc(target:GetLocation(), nRadius)
	
	if GetUnitToUnitDistance(bot, target) <= nRadius
	then
		return #heroes - 1;
	end
	
	return #heroes;
end


function J.GetAllyCreepNearLoc(vLoc, nRadius, bot)
	local AllyCreepsAll = bot:GetNearbyCreeps(1600, false);
	local AllyCreeps = { };
	for _,creep in pairs(AllyCreepsAll) 
	do	
		if creep ~= nil 
		   and creep:IsAlive() 
		   and GetUnitToLocationDistance(creep, vLoc) <= nRadius 
		then
			table.insert(AllyCreeps, creep);
		end
	end
	return AllyCreeps;
end 


function J.GetAllyUnitCountAroundEnemyTarget(target, nRadius, bot)
	local heroes = J.GetAlliesNearLoc(target:GetLocation(), nRadius)	
	local creeps = J.GetAllyCreepNearLoc(target:GetLocation(), nRadius, bot);		
	return #heroes + #creeps ;
end


function J.GetLocationToLocationDistance(fLoc, sLoc)
	
	local x1=fLoc.x
	local x2=sLoc.x
	local y1=fLoc.y
	local y2=sLoc.y
	return math.sqrt(math.pow((y2-y1), 2)+math.pow((x2-x1), 2))

end


function J.GetUnitTowardDistanceLocation(bot, towardTarget, nDistance)
    local npcBotLocation = bot:GetLocation();
    local tempVector = (towardTarget:GetLocation() - npcBotLocation) / GetUnitToUnitDistance(bot, towardTarget);
	return npcBotLocation + nDistance * tempVector;
end


function J.GetLocationTowardDistanceLocation(bot, towardLocation, nDistance)
    local npcBotLocation = bot:GetLocation();
    local tempVector = (towardLocation - npcBotLocation) / GetUnitToLocationDistance(bot, towardLocation);
	return npcBotLocation + nDistance * tempVector;
end


function J.GetFaceTowardDistanceLocation(bot, nDistance)
	local npcBotLocation = bot:GetLocation();
	local tempRadians = bot:GetFacing() * math.pi / 180;
	local tempVector = Vector(math.cos(tempRadians), math.sin(tempRadians));
	return npcBotLocation + nDistance * tempVector;
end


local PrintTime = {};
function J.PrintMessage(nMessage, nNumber, n, nIntevel)
	if PrintTime[n] == nil then PrintTime[n] = nPrintTime end;
	if PrintTime[n] < DotaTime() - nIntevel
	then
		PrintTime[n] = DotaTime();	
		local preStr = string.gsub(GetBot():GetUnitName(), "npc_dota_", "")..':';
		local suffix = string.gsub(tostring(nNumber), "npc_dota_", "");
		print("++++++++++++++++++++++++++++++++++++＄＄＄＄＄＄＄＄＄START");
		print(preStr..nMessage..suffix);
		print("------------------------------------＄＄＄＄＄＄＄＄＄＄＄END");
	end
end


local PrTime = nPrintTime;
function J.Print(nMessage, nNumber)
	if PrTime < DotaTime() - 3.0
	then
		PrTime = DotaTime();	
		local preStr = string.gsub(GetBot():GetUnitName(), "npc_dota_", "")..':';
		local suffix = string.gsub(tostring(nNumber), "npc_dota_", "");
		print("++++++++++++++++++++++++++++++++++++＄＄＄＄＄＄＄＄＄START");
		print(preStr..nMessage..suffix);
		print("------------------------------------＄＄＄＄＄＄＄＄＄＄＄END");
	end
end


local PARTime = nDebugTime;
function J.PrintAndReport(nMessage, nNumber)
	if PARTime < DotaTime() - 5.0
	then
		PARTime = DotaTime();
		local pMessage = nMessage..string.gsub(tostring(nNumber), "npc_dota_", "");
		print("++++++++++++++++++++++++++++++++++++＄＄＄＄＄＄＄＄＄START");
		print(GetBot():GetUnitName()..pMessage);
		print("------------------------------------＄＄＄＄＄＄＄＄＄＄＄END");
		GetBot():ActionImmediate_Chat(pMessage, true);
	end
end


local ReportTime = {};
function J.SetReportMessage(nMessage, nNumber, n)
	if ReportTime[n] == nil then ReportTime[n] = nDebugTime end;
	if ReportTime[n] < DotaTime() - 5.0
	then
		ReportTime[n] = DotaTime();	
		GetBot():ActionImmediate_Chat(nMessage..string.gsub(tostring(nNumber), "npc_dota_", ""), true);
	end
end


local ReTime = nDebugTime;
function J.SetReport(nMessage, nNumber)
	if ReTime < DotaTime() - 5.0
	then
		ReTime = DotaTime();	
		GetBot():ActionImmediate_Chat(nMessage..string.gsub(tostring(nNumber), "npc_dota_", ""), true);
	end
end


local PingTime = nDebugTime;
function J.SetPingLocation(bot, vLoc)
	if PingTime < DotaTime() - 2.0
	then
		PingTime = DotaTime();
		bot:ActionImmediate_Ping( vLoc.x, vLoc.y, false );
	end
end


local RePingTime = nDebugTime;
function J.SetReportAndPingLocation(vLoc, nMessage, nNumber)
	if RePingTime < DotaTime() - 2.0
	then
		local bot = GetBot();
		RePingTime = DotaTime();
		bot:ActionImmediate_Chat(nMessage..string.gsub(tostring(nNumber), "npc_dota_", ""), true);
		bot:ActionImmediate_Ping( vLoc.x, vLoc.y, false );
	end
end

function J.SetReportMotive(bDebugFile, sMotive)
	
	if bDebugMode and bDebugTeam and bDebugFile and sMotive ~= nil
	then
		GetBot():ActionImmediate_Chat(sMotive, true);
	end

end


function J.GetCastLocation(bot, npcTarget, nCastRange, nRadius)

	local nDistance = GetUnitToUnitDistance(bot, npcTarget)

	if nDistance <= nCastRange
	then
	    return npcTarget:GetLocation();
	end
	
	if nDistance <= nCastRange + nRadius -120
	then
	    return J.GetUnitTowardDistanceLocation(bot, npcTarget, nCastRange);
	end
	
	if nDistance < nCastRange + nRadius -18
	   and ( ( J.IsDisabled(true, npcTarget) or npcTarget:GetCurrentMovementSpeed() <= 160) 
			or npcTarget:IsFacingLocation(bot:GetLocation(), 45)
	        or (bot:IsFacingLocation(npcTarget:GetLocation(), 45) and npcTarget:GetCurrentMovementSpeed() <= 220))
	then
		return J.GetUnitTowardDistanceLocation(bot, npcTarget, nCastRange +18);
	end
	
	if nDistance < nCastRange + nRadius + 28
		and npcTarget:IsFacingLocation(bot:GetLocation(), 30)
		and bot:IsFacingLocation(npcTarget:GetLocation(), 30)
		and npcTarget:GetMovementDirectionStability() > 0.95
		and npcTarget:GetCurrentMovementSpeed() >= 300 
	then
		return J.GetUnitTowardDistanceLocation(bot, npcTarget, nCastRange +18);
	end
    
	return nil;
end


function J.GetDelayCastLocation(bot, npcTarget, nCastRange, nRadius, nTime)

	local nFutureLoc = J.GetCorrectLoc(npcTarget, nTime);
	local nDistance = GetUnitToLocationDistance(bot, nFutureLoc);
	
	if nDistance > nCastRange + nRadius
	then
		return nil;
	end
	
	if nDistance > nCastRange - nRadius *0.62
	then
		return J.GetLocationTowardDistanceLocation(bot, nFutureLoc, nCastRange);
	end

	return J.GetLocationTowardDistanceLocation(bot, nFutureLoc, nDistance + nRadius *0.38);

end


function J.GetOne(number)
	return math.floor(number * 10)/10;
end


function J.GetTwo(number)
	return math.floor(number * 100)/100;
end


function J.SetQueueSwitchPtToINT(bot)
	
	local pt = J.IsItemAvailable("item_power_treads");
	if pt~=nil and pt:IsFullyCastable()   
	then
		if pt:GetPowerTreadsStat() == ATTRIBUTE_INTELLECT
		then
			bot:ActionQueue_UseAbility(pt);
			bot:ActionQueue_UseAbility(pt);
			return;
		elseif pt:GetPowerTreadsStat() == ATTRIBUTE_STRENGTH
			then
				bot:ActionQueue_UseAbility(pt);
				return;
		end
	end
end


function J.SetQueueUseSoulRing(bot)
	local sr = J.IsItemAvailable("item_soul_ring");
	if sr ~= nil and sr:IsFullyCastable() 
	   
	then
		local nEnemyCount = J.GetEnemyCount(bot, 1600);
		if J.GetHPR(bot) > 0.426 + 0.1 * nEnemyCount
	       and J.GetMPR(bot) < 0.98 - 0.1 * nEnemyCount
		then
			bot:ActionQueue_UseAbility(sr);
			return;
		end
	end
end


function J.SetQueuePtToINT(bot, bSoulRingUsed)

	bot:Action_ClearActions(true)
	
	if bSoulRingUsed then J.SetQueueUseSoulRing(bot) end
	
	if not J.IsPTReady(bot, ATTRIBUTE_INTELLECT) 
	then
		J.SetQueueSwitchPtToINT(bot)
	end

end




function J.IsPTReady(bot, status)
	if  not bot:IsAlive()
		or bot:IsMuted()
		or bot:IsChanneling()
		or bot:IsInvisible()
		or bot:GetHealth()/bot:GetMaxHealth() < 0.25
	then
		return true;
	end
	
	if status == ATTRIBUTE_INTELLECT 
	then 
		status = ATTRIBUTE_AGILITY;
	elseif status == ATTRIBUTE_AGILITY
		then
			status = ATTRIBUTE_INTELLECT;
	end
	
    local pt = J.IsItemAvailable("item_power_treads");
	if pt ~= nil and pt:IsFullyCastable()
	then
		if pt:GetPowerTreadsStat() ~= status
		then
			return false
		end
	end
	
	return true;
end


function J.ShouldSwitchPTStat(bot, pt)
	
	local ptStatus = pt:GetPowerTreadsStat();
	if ptStatus == ATTRIBUTE_INTELLECT 
	then 
		ptStatus = ATTRIBUTE_AGILITY;
	elseif ptStatus == ATTRIBUTE_AGILITY
		then
			ptStatus = ATTRIBUTE_INTELLECT;
	end
    
	return bot:GetPrimaryAttribute() ~= ptStatus;
end


function J.IsOtherAllysTarget(unit)
	local bot = GetBot();
	local allys = bot:GetNearbyHeroes(800, false, BOT_MODE_NONE);
	for _,ally in pairs(allys) do
		if J.IsValid(ally)
		    and ally ~= bot 
			and ( J.GetProperTarget(ally) == unit 
					or ally:IsFacingLocation(unit:GetLocation(), 12) )
		then
			return true;
		end
	end
	return false;
end


function J.IsAllysTarget(unit)
	local bot = GetBot();
	local allys = bot:GetNearbyHeroes(800, false, BOT_MODE_NONE);
	for _,ally in pairs(allys) do
		if  J.IsValid(ally)
			and ( J.GetProperTarget(ally) == unit 
					or ally:IsFacingLocation(unit:GetLocation(), 12) )
		then
			return true;
		end
	end
	return false;
end


function J.IsKeyWordUnit(keyWord, Unit)
	
	if string.find(Unit:GetUnitName(), keyWord) ~= nil 
	then
		return true;  
	end
	
	return false;
end


function J.IsHumanPlayer(nUnit)

    return not nUnit:IsBot() --not IsPlayerBot(nUnit:GetPlayerID())

end


function J.IsValid(nTarget)
	return nTarget ~= nil and not nTarget:IsNull() and nTarget:IsAlive() and not nTarget:IsBuilding() --and nTarget:CanBeSeen()
end


function J.IsValidHero(nTarget)
	return nTarget ~= nil and not nTarget:IsNull() and nTarget:IsAlive() and nTarget:IsHero() --and nTarget:CanBeSeen(); 
end


function J.IsValidBuilding(nTarget)
	return nTarget ~= nil and not nTarget:IsNull() and nTarget:IsAlive() and nTarget:IsBuilding() --and nTarget:CanBeSeen() 
end


function J.IsRoshan(nTarget)
	return nTarget ~= nil and not nTarget:IsNull() and nTarget:IsAlive() and string.find(nTarget:GetUnitName(), "roshan");
end


function J.IsMoving(bot)
	
	if not bot:IsAlive() then return false end
	
	local loc = bot:GetExtrapolatedLocation(0.6);
	if GetUnitToLocationDistance(bot, loc) > bot:GetCurrentMovementSpeed() * 0.3
	then
		return true;
	end
	
	return false;

end


function J.IsRunning(bot)
	
	if not bot:IsAlive() then return false end ;
	
	return bot:GetAnimActivity() == ACTIVITY_RUN ;

end


function J.IsAttacking(bot)

	local nAnimActivity = bot:GetAnimActivity();
	
	if nAnimActivity ~= ACTIVITY_ATTACK
		and nAnimActivity ~= ACTIVITY_ATTACK2
	then
		return false;
	end
	
	if bot:GetAttackPoint() > bot:GetAnimCycle() * 0.99
	then
		return true;
	end	

	return false;
end


function J.GetModifierTime(bot, nMoName)
	
	if not bot:HasModifier(nMoName) then return 0; end

	local npcModifier = bot:NumModifiers();
	for i = 0, npcModifier 
	do
		if bot:GetModifierName(i) == nMoName 
		then
			return bot:GetModifierRemainingDuration(i);
		end
	end
	return 0;
end


function J.GetRemainStunTime(bot)
	
	if not bot:HasModifier("modifier_stunned") then return 0; end

	local npcModifier = bot:NumModifiers();
	for i = 0, npcModifier 
	do
		if bot:GetModifierName(i) == "modifier_stunned" 
		then
			return bot:GetModifierRemainingDuration(i);
		end
	end
	return 0;
end


function J.IsTeamActivityCount(bot, nCount)
	local numPlayer =  GetTeamPlayers(GetTeam());
	for i = 1, #numPlayer
	do
		local member =  GetTeamMember(i);
		if member ~= nil and member:IsAlive()
		then
		    if J.GetAllyCount(member, 1600) >= nCount
			then
				return true;
			end
		end
	end
	return false;
end


function J.GetSpecialModeAllies(nMode, nDistance, bot)

	local nAllies = {}
	local numPlayer =  GetTeamPlayers(GetTeam());
	for i = 1, #numPlayer
	do
		local member =  GetTeamMember(i);
		if member ~= nil and member:IsAlive()
		then
		    if member:GetActiveMode() == nMode
				and GetUnitToUnitDistance(member, bot) <= nDistance
			then
				table.insert(nAllies, member);
			end
		end
	end
	return nAllies;
end


function J.GetSpecialModeAlliesCount(nMode)
	local nAllies = J.GetSpecialModeAllies(nMode, 99999, GetBot());
	return #nAllies;
end


function J.GetTeamFightLocation(bot)
	
	local targetLocation = nil;
	local numPlayer = GetTeamPlayers(GetTeam());
	
	for i = 1, #numPlayer
	do
		local member =  GetTeamMember(i);
		if member ~= nil and member:IsAlive() 
		   and J.IsInTeamFight(member, 1500)
		   and J.GetEnemyCount(member, 1300) >= 2
		then
			local nAllies = J.GetSpecialModeAllies(BOT_MODE_ATTACK, 1400, member);
			targetLocation = J.GetCenterOfUnits(nAllies);
			break;					
		end
	end

	return targetLocation;
end


function J.GetTeamFightAlliesCount(bot)
	local numPlayer =  GetTeamPlayers(GetTeam());
	local nCount = 0;
	for i = 1, #numPlayer
	do
		local member = GetTeamMember(i);
		if member ~= nil and member:IsAlive()
		   and J.IsInTeamFight(member, 1200)
		   and J.GetEnemyCount(member, 1400) >= 2
		then			
			nCount = J.GetSpecialModeAlliesCount(BOT_MODE_ATTACK);
			break;
		end
	end
	return nCount;
end


function J.GetCenterOfUnits(nUnits)
	
	if #nUnits == 0 then
		return Vector(0.0, 0.0);
	end
	
	local sum = Vector(0.0, 0.0);
	local num = 0;
	
	for _,unit in pairs(nUnits) 
	do
		if unit ~= nil 
		   and unit:IsAlive() 
		then
			sum = sum + unit:GetLocation();
			num = num + 1;
		end
	end
	
	if num == 0 then return Vector(0.0, 0.0) end;
	
	return sum/num;

end


function J.GetMostFarmLaneDesire()
	local nTopDesire = GetFarmLaneDesire(LANE_TOP);
	local nMidDesire = GetFarmLaneDesire(LANE_MID);
	local nBotDesire = GetFarmLaneDesire(LANE_BOT);
	
	if nTopDesire > nMidDesire and nTopDesire > nBotDesire
	then
		return LANE_TOP, nTopDesire;
	end
	
	if nBotDesire > nMidDesire and nBotDesire > nTopDesire
	then
		return LANE_BOT, nBotDesire;
	end
	
	return LANE_MID, nMidDesire;
end


function J.GetMostDefendLaneDesire()
	local nTopDesire = GetDefendLaneDesire(LANE_TOP);
	local nMidDesire = GetDefendLaneDesire(LANE_MID);
	local nBotDesire = GetDefendLaneDesire(LANE_BOT);
	
	if nTopDesire > nMidDesire and nTopDesire > nBotDesire
	then
		return LANE_TOP, nTopDesire;
	end
	
	if nBotDesire > nMidDesire and nBotDesire > nTopDesire
	then
		return LANE_BOT, nBotDesire;
	end
	
	return LANE_MID, nMidDesire;
end


function J.GetMostPushLaneDesire()
	local nTopDesire = GetPushLaneDesire(LANE_TOP);
	local nMidDesire = GetPushLaneDesire(LANE_MID);
	local nBotDesire = GetPushLaneDesire(LANE_BOT);
	
	if nTopDesire > nMidDesire and nTopDesire > nBotDesire
	then
		return LANE_TOP, nTopDesire;
	end
	
	if nBotDesire > nMidDesire and nBotDesire > nTopDesire
	then
		return LANE_BOT, nBotDesire;
	end
	
	return LANE_MID, nMidDesire;
end


function J.GetNearestLaneFrontLocation(nUnitLoc, bEnemy, fDeltaFromFront)

	local nTeam = GetTeam();
	if bEnemy then nTeam = GetOpposingTeam(); end
	
	local nTopLoc = GetLaneFrontLocation( nTeam, LANE_TOP, fDeltaFromFront );
	local nMidLoc = GetLaneFrontLocation( nTeam, LANE_MID, fDeltaFromFront );
	local nBotLoc = GetLaneFrontLocation( nTeam, LANE_BOT, fDeltaFromFront );
	
	local nTopDist = J.GetLocationToLocationDistance(nUnitLoc, nTopLoc);
	local nMidDist = J.GetLocationToLocationDistance(nUnitLoc, nMidLoc);
	local nBotDist = J.GetLocationToLocationDistance(nUnitLoc, nBotLoc);
	
	if nTopDist < nMidDist and nTopDist < nBotDist
	then
		return nTopLoc;
	end
	
	if nBotDist < nMidDist and nBotDist < nTopDist
	then
		return nBotLoc;
	end
	
	return nMidLoc;

end


function J.IsSpecialCarry(bot)
    
	local botName = bot:GetUnitName();
	
	return  botName == "npc_dota_hero_axe"
			or botName == "npc_dota_hero_antimage"
			or botName == "npc_dota_hero_arc_warden"
			or botName == "npc_dota_hero_abaddon"
			or botName == "npc_dota_hero_alchemist"		
			or botName == "npc_dota_hero_bloodseeker"
			or botName == "npc_dota_hero_bristleback" 
			or botName == "npc_dota_hero_clinkz"
			or botName == "npc_dota_hero_chaos_knight" 
			or botName == "npc_dota_hero_dragon_knight"
			or botName == "npc_dota_hero_drow_ranger"
			or botName == "npc_dota_hero_kunkka"
			or botName == "npc_dota_hero_luna"
			or botName == "npc_dota_hero_medusa"
			or botName == "npc_dota_hero_nevermore"
			or botName == "npc_dota_hero_night_stalker"
			or botName == "npc_dota_hero_omniknight"
			or botName == "npc_dota_hero_phantom_assassin"
			or botName == 'npc_dota_hero_phantom_lancer'
			or botName == "npc_dota_hero_queenofpain"
			or botName == "npc_dota_hero_razor"
			or botName == "npc_dota_hero_skeleton_king"
			or botName == "npc_dota_hero_sven"
			or botName == "npc_dota_hero_sniper"
			or botName == "npc_dota_hero_templar_assassin"
			or botName == "npc_dota_hero_terrorblade"		 
			or botName == "npc_dota_hero_viper" 
			or botName == "npc_dota_hero_weaver"
			or botName == "npc_dota_hero_earthshaker"
		 
end


function J.IsSpecialSupport(bot)
    
	local botName = bot:GetUnitName();
	
	return  botName == "npc_dota_hero_crystal_maiden"
			or botName == "npc_dota_hero_death_prophet"		
			or botName == "npc_dota_hero_jakiro"
			or botName == "npc_dota_hero_lich"
			or botName == "npc_dota_hero_lina"
			or botName == "npc_dota_hero_necrolyte"
			or botName == "npc_dota_hero_ogre_magi"
			or botName == "npc_dota_hero_oracle"
			or botName == "npc_dota_hero_silencer"
			or botName == "npc_dota_hero_shadow_shaman"
			or botName == "npc_dota_hero_skywrath_mage"
			or botName == "npc_dota_hero_warlock"		  
			or botName == "npc_dota_hero_zuus" 
			or botName == "npc_dota_hero_dazzle" 
			or botName == "npc_dota_hero_batrider" 
end 

	
function J.GetAttackableWeakestUnit(bHero, bEnemy, nRadius, bot)
	local units = {};
	local weakest = nil;
	local weakestHP = 10000;
	if bHero then
		units = bot:GetNearbyHeroes(nRadius, bEnemy, BOT_MODE_NONE);
	else
		units = bot:GetNearbyLaneCreeps(nRadius, bEnemy);
	end
	
	for _,unit in pairs(units) do
		if  J.IsValid(unit)
			and unit:GetHealth() < weakestHP 
			and not unit:IsAttackImmune()
			and not unit:IsInvulnerable()
			and not J.HasForbiddenModifier(unit)
			and not J.IsSuspiciousIllusion(unit)
			and not J.IsAllyCanKill(unit)
		then
			weakest = unit;
			weakestHP = unit:GetHealth();
		end
	end
	return weakest;
end


function J.CanBeAttacked(npcTarget)
	
	return  not npcTarget:IsAttackImmune()
			and not npcTarget:IsInvulnerable()
			and not J.HasForbiddenModifier(npcTarget)
end


function J.GetHPR(bot)

	return bot:GetHealth()/bot:GetMaxHealth();

end


function J.GetMPR(bot)

	return bot:GetMana()/bot:GetMaxMana();

end


function J.GetAllyList(bot, nRange)
	if nRange > 1600 then nRange = 1600 end
	local nRealAllies = {};
	local nCandidate = bot:GetNearbyHeroes(nRange, false, BOT_MODE_NONE);
	if nCandidate[1] == nil then return nCandidate end
	
	for _,ally in pairs(nCandidate)
	do
		if ally ~= nil and ally:IsAlive()
			and not ally:IsIllusion()
			and not J.IsExistInTable(ally, nRealAllies)
		then
			table.insert(nRealAllies, ally);
		end
	end
	
	return nRealAllies;
end


function J.GetAllyCount(bot, nRange)
		
	local nRealAllies = J.GetAllyList(bot, nRange);
	
	return #nRealAllies;
	
end


function J.GetEnemyList(bot, nRange)
	if nRange > 1600 then nRange = 1600 end
	local nRealEnemys = {};
	local nCandidate = bot:GetNearbyHeroes(nRange, true, BOT_MODE_NONE);
	if nCandidate[1] == nil then return nCandidate end
	
	for _,enemy in pairs(nCandidate)
	do
		if enemy ~= nil and enemy:IsAlive()
			and not J.IsSuspiciousIllusion(enemy)
			and not J.IsExistInTable(enemy, nRealEnemys)
		then
			table.insert(nRealEnemys, enemy);
		end
	end
	
	return nRealEnemys;
end


function J.GetEnemyCount(bot, nRange)
		
	local nRealEnemys = J.GetEnemyList(bot, nRange);
	
	return #nRealEnemys;
	
end


function J.ConsiderTarget()

	local bot = GetBot();
	if not J.IsRunning(bot) 
	   or bot:HasModifier("modifier_item_hurricane_pike_range")
	then return  end
	
	local npcTarget = J.GetProperTarget(bot);
	if not J.IsValidHero(npcTarget) then return end

	local nAttackRange = bot:GetAttackRange() + 69;	
	if nAttackRange > 1600 then nAttackRange = 1600 end
	if nAttackRange < 200  then nAttackRange = 350  end
	
	local nInAttackRangeWeakestEnemyHero = J.GetAttackableWeakestUnit(true, true, nAttackRange, bot);

	if  J.IsValidHero(nInAttackRangeWeakestEnemyHero)
		and ( GetUnitToUnitDistance(npcTarget, bot) >  nAttackRange or J.HasForbiddenModifier(npcTarget) )		
	then
		bot:SetTarget(nInAttackRangeWeakestEnemyHero);
		return;
	end

end


function J.IsHaveAegis(bot)

	for i = 0, 5 
	do
		local item = bot:GetItemInSlot(i)
		if item ~= nil and item:GetName() == "item_aegis" 
		then
			return true;
		end
	end

	return false;

end


function J.IsLocHaveTower(nRange, bEnemy, nLoc)

	local nTeam = GetTeam();
	if bEnemy then nTeam = GetOpposingTeam(); end
	
	if (not bEnemy and J.GetLocationToLocationDistance(nLoc,J.GetTeamFountain()) < 2500 )
	   or ( bEnemy and J.GetLocationToLocationDistance(nLoc,J.GetEnemyFountain()) < 2500 )
	then
		return true;
	end
	
	for i = 0, 10  
	do
		local tower = GetTower(nTeam, i);
		if tower ~= nil and GetUnitToLocationDistance(tower, nLoc) <= nRange 
		then
			 return true;
		end
	end
	
	return false;

end


function J.GetNearbyLocationToTp(nLoc)
	local nTeam = GetTeam();
	local nFountain = J.GetTeamFountain();
	
	if J.GetLocationToLocationDistance(nLoc, nFountain) <= 2500
	then
		return nLoc;
	end
	
	local targetTower = nil;
	local minDist     = 99999
	for i=0, 10, 1 do
		local tower = GetTower(nTeam, i);
		if tower ~= nil 
		   and GetUnitToLocationDistance(tower, nLoc) < minDist
		then
			 targetTower = tower;
			 minDist     = GetUnitToLocationDistance(tower, nLoc);
		end
	end
	
	local shrines = {
		 SHRINE_JUNGLE_1, 
		 SHRINE_JUNGLE_2 
	}
	for _,s in pairs(shrines) do
		local shrine = GetShrine(GetTeam(), s);
		if  shrine ~= nil and shrine:GetHealth()/shrine:GetMaxHealth() > 0.99
		    and GetUnitToLocationDistance(shrine, nLoc) < minDist
		then
			 targetTower = shrine;
			 minDist     = GetUnitToLocationDistance(shrine, nLoc);
		end	
	end	

	if targetTower ~= nil
	then		
		return J.GetLocationTowardDistanceLocation(targetTower, nLoc, 600);
	end
	
	return nFountain;
end


function J.IsEnemyFacingUnit(nRange, bot, nDegrees)
	
	local nLoc = bot:GetLocation();
	
	if nRange > 1600 then nRange = 1600; end
	local nEnemyHeroes = bot:GetNearbyHeroes( nRange, true, BOT_MODE_NONE );
	for _,enemy in pairs(nEnemyHeroes)
	do
		if J.IsValid(enemy)
		   and enemy:IsFacingLocation(nLoc, nDegrees)
		then
			return true;
		end
	end

	return false;
end


function J.IsAllyFacingUnit(nRange, bot, nDegrees)
	
	local nLoc = bot:GetLocation();
	local numPlayer = GetTeamPlayers(GetTeam());
	for i = 1, #numPlayer
	do
		local member = GetTeamMember(i);
		if member ~= nil
			and member ~= bot
			and GetUnitToUnitDistance(member, bot) <= nRange
			and member:IsFacingLocation(nLoc, nDegrees)
		then
			return true;
		end
	end

	return false;
end


function J.IsEnemyTargetUnit(nRange, nUnit)
	
	if nRange > 1600 then nRange = 1600; end
	local nEnemyHeroes = GetBot():GetNearbyHeroes( nRange, true, BOT_MODE_NONE );
	for _,enemy in pairs(nEnemyHeroes)
	do
		if J.IsValid(enemy)
			and J.GetProperTarget(enemy) == nUnit
		then
			return true;
		end
	end

	return false;
end


function J.IsCastingUltimateAbility(bot)
	
	if bot:IsCastingAbility() or bot:IsUsingAbility()
	then
		local nAbility = bot:GetCurrentActiveAbility();
		if nAbility ~= nil 
			and nAbility:IsUltimate()
		then
			return true;
		end
	end

	return false;
end


function J.IsInAllyArea(bot)
   
   local AllyAcient = GetAncient(GetTeam());
   local EnemyAcient = GetAncient(GetOpposingTeam());
      
   if GetUnitToUnitDistance(bot, AllyAcient) + 768 < GetUnitToUnitDistance(bot, EnemyAcient)
   then
		return true;
   end
      
   return false;
end


function J.IsInEnemyArea(bot)
   
   local AllyAcient = GetAncient(GetTeam());
   local EnemyAcient = GetAncient(GetOpposingTeam());
      
   if GetUnitToUnitDistance(bot, EnemyAcient) + 1280 < GetUnitToUnitDistance(bot, AllyAcient)
   then
		return true;
   end
      
   return false;
end


function J.IsEnemyHeroAroundLocation(vLoc, nRadius)
	for i,id in pairs(GetTeamPlayers(GetOpposingTeam())) 
	do
		if IsHeroAlive(id) then
			local info = GetHeroLastSeenInfo(id);
			if info ~= nil then
				local dInfo = info[1];
				if dInfo ~= nil 
				   and J.GetLocationToLocationDistance(vLoc, dInfo.location) <= nRadius 
				   and dInfo.time_since_seen < 2.0 
				then
					return true;
				end
			end
		end
	end
	return false;
end


function J.GetNumOfAliveHeroes(bEnemy)
	local count = 0;
	local nTeam = GetTeam();
	if bEnemy then nTeam = GetOpposingTeam() end;
	
	for i,id in pairs(GetTeamPlayers(nTeam)) 
	do
		if IsHeroAlive(id)
		then
			count = count + 1;
		end
	end
	return count;
end


function J.GetAverageLevel(bEnemy)
	local count = 0;
	local sum = 0;
	local nTeam = GetTeam();
	if bEnemy then nTeam = GetOpposingTeam() end;
	
	for i,id in pairs(GetTeamPlayers(nTeam)) 
	do
		sum = sum + GetHeroLevel( id );
		count = count + 1;
	end
	
	return sum/count;
end


function J.GetNumOfTeamTotalKills(bEnemy)
	local count = 0;
	local nTeam = GetOpposingTeam();
	if bEnemy then nTeam = GetTeam(); end;
	
	for i,id in pairs(GetTeamPlayers(nTeam)) 
	do
		count = count + GetHeroDeaths( id );
	end
	
	return count;
end


local dismantleForBtCheckTime = 600;
local lifestealForBtDismantleDone = false;
local staffForBtDismantleDone = false;
function J.ConsiderForBtDisassembleMask(bot)
	
	if staffForBtDismantleDone then return; end
	
	if dismantleForBtCheckTime < DotaTime() + 1.0
	then
		dismantleForBtCheckTime = DotaTime();	
		
		local mask     = bot:FindItemSlot("item_mask_of_madness");
		local claymore = bot:FindItemSlot("item_claymore");
		local reaver   = bot:FindItemSlot("item_reaver");
				
		if bot:GetItemInSlot(6) == nil
			or bot:GetItemInSlot(7) == nil
			or bot:GetItemInSlot(8) == nil
		then
						
			if mask >= 0 and mask <= 8
			   and ( ( reaver >= 0 and reaver <= 8 ) or claymore >= 0 )
			   and ( bot:GetGold() >= 1400 or bot:GetStashValue() >= 1400 or bot:GetCourierValue() >= 1400 )
			then
				bot:ActionImmediate_DisassembleItem( bot:GetItemInSlot(mask) );
				return;
			end
			
			if mask >= 0 and mask <= 8
			   and claymore >= 0 and claymore <= 8
			   and reaver >= 0 and reaver <= 8
			then
				bot:ActionImmediate_DisassembleItem( bot:GetItemInSlot(mask) );
				return;
			end
		end
		
		local lifesteal = bot:FindItemSlot("item_lifesteal");
		local staff = bot:FindItemSlot("item_quarterstaff");
		
		if lifesteal >= 0 then -- and not lifestealForBtDismantleDone then
			bot:ActionImmediate_SetItemCombineLock( bot:GetItemInSlot(lifesteal), false );
--			lifestealForBtDismantleDone = true;
			return;
		end
		
		local satanic  = bot:FindItemSlot("item_satanic");
		
		if satanic >= 0 and staff >= 0 then
			bot:ActionImmediate_SetItemCombineLock( bot:GetItemInSlot(staff), false );
			staffForBtDismantleDone = true;
			return;
		end
		
		-- if satanic >= 0 
		   -- and bot:GetGold() > GetItemCost("item_quarterstaff") 
		-- then
			-- bot:ActionImmediate_PurchaseItem("item_quarterstaff");
			-- staffForBtDismantleDone = true;
			-- return;
		-- end
	end
end


local dismantleForMkbCheckTime = 600;
local lifestealForMkbDismantleDone = false;
local staffForMkbDismantleDone = false;
function J.ConsiderForMkbDisassembleMask(bot)
	
	if staffForMkbDismantleDone then return; end
	
	if dismantleForMkbCheckTime < DotaTime() + 1.0
	then
		dismantleForMkbCheckTime = DotaTime();	
		
		local mask     = bot:FindItemSlot("item_mask_of_madness");
		local claymore = bot:FindItemSlot("item_claymore");
		local reaver   = bot:FindItemSlot("item_reaver");
						
		if bot:GetItemInSlot(6) == nil
			or bot:GetItemInSlot(7) == nil
			or bot:GetItemInSlot(8) == nil
		then
						
			if mask >= 0 and mask <= 8
			   and ( ( reaver >= 0 and reaver <= 8 ) or claymore >= 0 )
			   and ( bot:GetGold() >= 1400 or bot:GetStashValue() >= 1400 or bot:GetCourierValue() >= 1400 )
			then
				bot:ActionImmediate_DisassembleItem( bot:GetItemInSlot(mask) );
				return;
			end
			
			if mask >= 0 and mask <= 8
			   and claymore >= 0 and claymore <= 8
			   and reaver >= 0 and reaver <= 8
			then
				bot:ActionImmediate_DisassembleItem( bot:GetItemInSlot(mask) );
				return;
			end
		end
		
		local lifesteal = bot:FindItemSlot("item_lifesteal");
		local staff = bot:FindItemSlot("item_quarterstaff");
		
		if lifesteal >= 0 then -- and not lifestealForMkbDismantleDone then
			bot:ActionImmediate_SetItemCombineLock( bot:GetItemInSlot(lifesteal), false );
--			lifestealForMkbDismantleDone = true;
			return;
		end
		
		local satanic  = bot:FindItemSlot("item_satanic");
				
		if satanic >= 0 and staff >= 0 and not staffForMkbDismantleDone then
			bot:ActionImmediate_SetItemCombineLock( bot:GetItemInSlot(staff), false );
			staffForMkbDismantleDone = true;	
			return;
		end
		
	end
end


local LastActionTime = {};
function J.HasNotActionLast(nCD, nNumber)
	
	if LastActionTime[nNumber] == nil then LastActionTime[nNumber] = -90; end
	
	if DotaTime() > LastActionTime[nNumber] + nCD
	then
		LastActionTime[nNumber] = DotaTime();
		return true;
	end
	
	return false;

end


function J.GetCastPoint(bot, unit, nPointTime, nProjectSpeed)	
				
	local nDist = GetUnitToUnitDistance(bot, unit);
	
	local nDistTime = 0;
	if nProjectSpeed ~= 0 then nDistTime = nDist/nProjectSpeed; end
	
	return nPointTime + nDistTime;
		
end


function J.CanBreakTeleport(bot, unit, nPointTime, nProjectSpeed)	

	if unit:HasModifier("modifier_teleporting") 
	then
		return J.GetCastPoint(bot, unit, nPointTime, nProjectSpeed) < J.GetModifierTime(unit, "modifier_teleporting")
	end
	
	return true;
end


function J.GetMagicToPhysicalDamage(bot, nUnit, nMagicDamage)

	local realMagicDamage = nUnit:GetActualIncomingDamage(nMagicDamage, DAMAGE_TYPE_MAGICAL);
	
	local basePhysicalDamage = 100 * bot:GetAttackCombatProficiency(nUnit);
	local nTDamage = nUnit:GetActualIncomingDamage(basePhysicalDamage, DAMAGE_TYPE_PHYSICAL)/100;

	return realMagicDamage / nTDamage ;

end


return J

--[[

[[
CanAbilityBeUpgraded(): bool
CanBeDisassembled(): bool
GetAOERadius(): int
GetAbilityDamage(): int
GetAutoCastState(): bool
GetBehavior(): int
GetCastPoint(): float
GetCastRange(): int
GetCaster(): handle
GetChannelTime(): float
GetChannelledManaCostPerSecond(): int
GetCooldown(): float
GetCooldownTimeRemaining(): float
GetCurrentCharges(): int
GetDamageType(): int
GetDuration(): float
GetEstimatedDamageToTarget(handlehTarget, floatfDuration, intnDamageTypes): int
GetHeroLevelRequiredToUpgrade(): int
GetInitialCharges(): int
GetLevel(): int
GetManaCost(): int
GetMaxLevel(): int
GetName(): cstring
GetPowerTreadsStat(): int
GetSecondaryCharges(): int
GetSpecialValueFloat(cstringpszKey): float
GetSpecialValueInt(cstringpszKey): int
GetTargetFlags(): int
GetTargetTeam(): int
GetTargetType(): int
GetToggleState(): bool
IsActivated(): bool
IsChanneling(): bool
IsCombineLocked(): bool
IsCooldownReady(): bool
IsFullyCastable(): bool
IsHidden(): bool
IsInAbilityPhase(): bool
IsItem(): bool
IsOwnersManaEnough(): bool
IsPassive(): bool
IsStealable(): bool
IsStolen(): bool
IsTalent(): bool
IsToggle(): bool
IsTrained(): bool
IsUltimate(): bool
ProcsMagicStick(): bool
ToggleAutoCast(): void
ActionImmediate_Buyback(): void
ActionImmediate_Chat(cstringpszMessage, boolbAllChat): void
ActionImmediate_Courier(handlehCourier, inteAction): bool
ActionImmediate_DisassembleItem(handlehItem): void
ActionImmediate_Glyph(): void
ActionImmediate_LevelAbility(cstringpszAbilityName): void
ActionImmediate_Ping(floatx, floaty, boolbNormalPing): void
ActionImmediate_PurchaseItem(cstringpszItemName): 
ActionImmediate_SellItem(handlehItem): void
ActionImmediate_SetItemCombineLock(handlehItem, boolbLocked): void
ActionImmediate_SwapItems(intnSlot1, intnSlot2): void
ActionPush_AttackMove(vectorlocation): void
ActionPush_AttackUnit(handlehTarget, boolbOnce): void
ActionPush_Delay(floatfDelay): void
ActionPush_DropItem(handlehItem, vectorlocation): void
ActionPush_MoveDirectly(vectorlocation): void
ActionPush_MovePath(handlehPathTable): void
ActionPush_MoveToLocation(vectorlocation): void
ActionPush_MoveToUnit(handlehTarget): void
ActionPush_PickUpItem(handlehItem): void
ActionPush_PickUpRune(intnRune): void
ActionPush_UseAbility(handlehAbility): void
ActionPush_UseAbilityOnEntity(handlehAbility, handlehTarget): void
ActionPush_UseAbilityOnLocation(handlehAbility, vectorlocation): void
ActionPush_UseAbilityOnTree(handlehAbility, intiTree): void
ActionPush_UseShrine(handlehShrine): void
ActionQueue_AttackMove(vectorlocation): void
ActionQueue_AttackUnit(handlehTarget, boolbOnce): void
ActionQueue_Delay(floatfDelay): void
ActionQueue_DropItem(handlehItem, vectorlocation): void
ActionQueue_MoveDirectly(vectorlocation): void
ActionQueue_MovePath(handlehPathTable): void
ActionQueue_MoveToLocation(vectorlocation): void
ActionQueue_MoveToUnit(handlehTarget): void
ActionQueue_PickUpItem(handlehItem): void
ActionQueue_PickUpRune(intnRune): void
ActionQueue_UseAbility(handlehAbility): void
ActionQueue_UseAbilityOnEntity(handlehAbility, handlehTarget): void
ActionQueue_UseAbilityOnLocation(handlehAbility, vectorlocation): void
ActionQueue_UseAbilityOnTree(handlehAbility, intiTree): void
ActionQueue_UseShrine(handlehShrine): void
Action_AttackMove(vectorlocation): void
Action_AttackUnit(handlehTarget, boolbOnce): void
Action_ClearActions(boolbStop): void
Action_Delay(floatfDelay): void
Action_DropItem(handlehItem, vectorlocation): void
Action_MoveDirectly(vectorlocation): void
Action_MovePath(handlehPathTable): void
Action_MoveToLocation(vectorlocation): void
Action_MoveToUnit(handlehTarget): void
Action_PickUpItem(handlehItem): void
Action_PickUpRune(intnRune): void
Action_UseAbility(handlehAbility): void
Action_UseAbilityOnEntity(handlehAbility, handlehTarget): void
Action_UseAbilityOnLocation(handlehAbility, vectorlocation): void
Action_UseAbilityOnTree(handlehAbility, intiTree): void
Action_UseShrine(handlehShrine): void
CanBeSeen(): bool
DistanceFromFountain(): int
DistanceFromSecretShop(): int
DistanceFromSideShop(): int
FindAoELocation(boolbEnemies, boolbHeroes, vectorvBaseLocation, intnMaxDistanceFromBase, intnRadius, floatfTimeInFuture, intnMaxHealth): variant
FindItemSlot(cstringpszItemName): int
GetAbilityByName(cstringpszAbilityName): handle
GetAbilityInSlot(intiAbility): handle
GetAbilityPoints(): int
GetAbilityTarget(): handle
GetAcquisitionRange(): int
GetActiveMode(): int
GetActiveModeDesire(): float
GetActualIncomingDamage(intnDamage, inteDamageType): int
GetAnimActivity(): int
GetAnimCycle(): float
GetArmor(): float
GetAssignedLane(): int
GetAttackCombatProficiency(handlehTarget): float
GetAttackDamage(): float
GetAttackPoint(): float
GetAttackProjectileSpeed(): int
GetAttackRange(): int
GetAttackSpeed(): float
GetAttackTarget(): handle
GetAttributeValue(intnAttribute): int
GetBaseDamage(): float
GetBaseDamageVariance(): float
GetBaseHealthRegen(): float
GetBaseManaRegen(): float
GetBaseMovementSpeed(): int
GetBoundingRadius(): float
GetBountyGoldMax(): int
GetBountyGoldMin(): int
GetBountyXP(): int
GetBuybackCooldown(): float
GetBuybackCost(): int
GetCourierValue(): int
GetCurrentActionType(): int
GetCurrentActiveAbility(): handle
GetCurrentMovementSpeed(): int
GetCurrentVisionRange(): int
GetDayTimeVisionRange(): int
GetDefendCombatProficiency(handlehAttacker): float
GetDenies(): int
GetDifficulty(): int
GetEstimatedDamageToTarget(boolbCurrentlyAvailable, handlehTarget, floatfDuration, intnDamageTypes): int
GetEvasion(): float
GetExtrapolatedLocation(floatfDelay): vector
GetFacing(): int
GetGold(): int
GetGroundHeight(): int
GetHealth(): int
GetHealthRegen(): float
GetHealthRegenPerStr(): float
GetIncomingTrackingProjectiles(): variant
GetItemInSlot(intnSlot): handle
GetItemSlotType(intnSlot): int
GetLastAttackTime(): float
GetLastHits(): int
GetLevel(): int
GetLocation(): vector
GetMagicResist(): float
GetMana(): int
GetManaRegen(): float
GetManaRegenPerInt(): float
GetMaxHealth(): int
GetMaxMana(): int
GetModifierAuxiliaryUnits(intnModifier): variant
GetModifierByName(cstringpszModifierName): int
GetModifierList(): variant
GetModifierName(intnModifier): cstring
GetModifierRemainingDuration(intnModifier): float
GetModifierStackCount(intnModifier): int
GetMostRecentPing(): variant
GetMovementDirectionStability(): float
GetNearbyBarracks(intnRadius, boolbEnemies): variant
GetNearbyCreeps(intnRadius, boolbEnemies): variant
GetNearbyFillers(intnRadius, boolbEnemies): variant
GetNearbyHeroes(intnRadius, boolbEnemies, inteBotMode): variant
GetNearbyLaneCreeps(intnRadius, boolbEnemies): variant
GetNearbyNeutralCreeps(intnRadius): variant
GetNearbyShrines(intnRadius, boolbEnemies): variant
GetNearbyTowers(intnRadius, boolbEnemies): variant
GetNearbyTrees(intnRadius): variant
GetNetWorth(): int
GetNextItemPurchaseValue(): int
GetNightTimeVisionRange(): int
GetOffensivePower(): float
GetPlayerID(): int
GetPrimaryAttribute(): int
GetQueuedActionType(intnQueuedAction): int
GetRawOffensivePower(): float
GetRemainingLifespan(): float
GetRespawnTime(): float
GetSecondsPerAttack(): float
GetSlowDuration(boolbCurrentlyAvailable): float
GetSpellAmp(): float
GetStashValue(): int
GetStunDuration(boolbCurrentlyAvailable): float
GetTalent(intnLevel, intnSide): handle
GetTarget(): handle
GetTeam(): int
GetUnitName(): cstring
GetVelocity(): vector
GetXPNeededToLevel(): int
HasBlink(boolbCurrentlyAvailable): bool
HasBuyback(): bool
HasInvisibility(boolbCurrentlyAvailable): bool
HasMinistunOnAttack(): bool
HasModifier(cstringpszModifierName): bool
HasScepter(): bool
HasSilence(boolbCurrentlyAvailable): bool
IsAlive(): bool
IsAncientCreep(): bool
IsAttackImmune(): bool
IsBlind(): bool
IsBlockDisabled(): bool
IsBot(): bool
IsBuilding(): bool
IsCastingAbility(): bool
IsChanneling(): bool
IsCourier(): bool
IsCreep(): bool
IsDisarmed(): bool
IsDominated(): bool
IsEvadeDisabled(): bool
IsFacingLocation(vectorvLocation, intnDegrees): bool
IsFort(): bool
IsHero(): bool
IsHexed(): bool
IsIllusion(): bool
IsInvisible(): bool
IsInvulnerable(): bool
IsMagicImmune(): bool
IsMinion(): bool
IsMuted(): bool
IsNightmared(): bool
IsRooted(): bool
IsSilenced(): bool
IsSpeciallyDeniable(): bool
IsStunned(): bool
IsTower(): bool
IsUnableToMiss(): bool
IsUsingAbility(): bool
NumModifiers(): int
NumQueuedActions(): int
SetNextItemPurchaseValue(intnGold): void
SetTarget(handle): void
TimeSinceDamagedByAnyHero(): float
TimeSinceDamagedByCreep(): float
TimeSinceDamagedByHero(handlehHero): float
TimeSinceDamagedByPlayer(intnPlayerID): float
TimeSinceDamagedByTower(): float
UsingItemBreaksInvisibility(): bool
WasRecentlyDamagedByAnyHero(floatfTime): bool
WasRecentlyDamagedByCreep(floatfTime): bool
WasRecentlyDamagedByHero(handlehHero, floatfTime): bool
WasRecentlyDamagedByPlayer(intnPlayerID, floatfTime): bool
WasRecentlyDamagedByTower(floatfTime): bool
CDOTA_TeamCommander
AddAvoidanceZone(vector, float): int
AddConditionalAvoidanceZone(vector, handle): int
CMBanHero(cstring): void
CMPickHero(cstring): void
Clamp(float, float, float): float
CreateHTTPRequest(cstring): handle
CreateRemoteHTTPRequest(cstring): handle
DebugDrawCircle(vector, float, int, int, int): void
DebugDrawLine(vector, vector, int, int, int): void
DebugDrawText(float, float, cstring, int, int, int): void
DebugPause(): void
DotaTime(): float
GameTime(): float
GeneratePath(vector, vector, handle, handle): int
GetAllTrees(): variant
GetAmountAlongLane(int, vector): variant
GetAncient(int): handle
GetAvoidanceZones(): variant
GetBarracks(int, int): handle
GetBot(): handle
GetBotAbilityByHandle(uint): handle
GetBotByHandle(uint): handle
GetCMCaptain(): int
GetCMPhaseTimeRemaining(): float
GetCourier(int): handle
GetCourierState(handle): int
GetDefendLaneDesire(int): float
GetDroppedItemList(): variant
GetFarmLaneDesire(int): float
GetGameMode(): int
GetGameState(): int
GetGameStateTimeRemaining(): float
GetGlyphCooldown(): float
GetHeightLevel(vector): int
GetHeroAssists(int): int
GetHeroDeaths(int): int
GetHeroKills(int): int
GetHeroLastSeenInfo(int): variant
GetHeroLevel(int): int
GetHeroPickState(): int
GetIncomingTeleports(): variant
GetItemComponents(cstring): variant
GetItemCost(cstring): int
GetItemStockCount(cstring): int
GetLaneFrontAmount(int, int, bool): float
GetLaneFrontLocation(int, int, float): vector
GetLinearProjectileByHandle(int): variant
GetLinearProjectiles(): variant
GetLocationAlongLane(int, float): vector
GetNeutralSpawners(): variant
GetNumCouriers(): int
GetOpposingTeam(): int
GetPushLaneDesire(int): float
GetRoamDesire(): float
GetRoamTarget(): handle
GetRoshanDesire(): float
GetRoshanKillTime(): float
GetRuneSpawnLocation(int): vector
GetRuneStatus(int): 
GetRuneTimeSinceSeen(int): float
GetRuneType(int): int
GetScriptDirectory(): cstring
GetSelectedHeroName(int): cstring
GetShopLocation(int, int): vector
GetShrine(int, int): handle
GetShrineCooldown(handle): float
GetTeam(): int
GetTeamForPlayer(int): int
GetTeamMember(int): handle
GetTeamPlayers(int): variant
GetTimeOfDay(): float
GetTower(int, int): handle
GetTowerAttackTarget(int, int): handle
GetTreeLocation(int): vector
GetUnitList(int): variant
GetUnitPotentialValue(handle, vector, float): int
GetUnitToLocationDistance(handle, vector): float
GetUnitToLocationDistanceSqr(handle, vector): float
GetUnitToUnitDistance(handle, handle): float
GetUnitToUnitDistanceSqr(handle, handle): float
GetWorldBounds(): variant
InstallCastCallback(int, handle): void
InstallChatCallback(handle): void
InstallCourierDeathCallback(handle): void
InstallDamageCallback(int, handle): void
InstallRoshanDeathCallback(handle): void
IsCMBannedHero(cstring): bool
IsCMPickedHero(int, cstring): bool
IsCourierAvailable(): bool
IsFlyingCourier(handle): bool
IsHeroAlive(int): bool
IsInCMBanPhase(): bool
IsInCMPickPhase(): bool
IsItemPurchasedFromSecretShop(cstring): bool
IsItemPurchasedFromSideShop(cstring): bool
IsLocationPassable(vector): bool
IsLocationVisible(vector): bool
IsPlayerBot(int): bool
IsPlayerInHeroSelectionControl(int): bool
IsRadiusVisible(vector, float): bool
IsShrineHealing(handle): bool
IsTeamPlayer(int): bool
Max(float, float): float
Min(float, float): float
PointToLineDistance(vector, vector, vector): variant
RandomFloat(float, float): float
RandomInt(int, int): int
RandomVector(float): vector
RealTime(): float
RemapVal(float, float, float, float, float): float
RemapValClamped(float, float, float, float, float): float
RemoveAvoidanceZone(int): void
RollPercentage(int): bool
SelectHero(int, cstring): void
SetCMCaptain(int): void
]]


--[[
BOT_MODE_NONE
BOT_MODE_LANING
BOT_MODE_ATTACK
BOT_MODE_ROAM
BOT_MODE_RETREAT
BOT_MODE_RUNE
BOT_MODE_SECRET_SHOP
BOT_MODE_SIDE_SHOP
BOT_MODE_PUSH_TOWER_TOP
BOT_MODE_PUSH_TOWER_MID
BOT_MODE_PUSH_TOWER_BOT
BOT_MODE_DEFEND_TOWER_TOP
BOT_MODE_DEFEND_TOWER_MID
BOT_MODE_DEFEND_TOWER_BOT
BOT_MODE_ASSEMBLE
BOT_MODE_TEAM_ROAM
BOT_MODE_FARM
BOT_MODE_DEFEND_ALLY
BOT_MODE_EVASIVE_MANEUVERS
BOT_MODE_ROSHAN
BOT_MODE_ITEM
BOT_MODE_WARD
BOT_ACTION_DESIRE_NONE - 0.0
BOT_ACTION_DESIRE_VERYLOW - 0.1
BOT_ACTION_DESIRE_LOW - 0.25
BOT_ACTION_DESIRE_MODERATE - 0.5
BOT_ACTION_DESIRE_HIGH - 0.75
BOT_ACTION_DESIRE_VERYHIGH - 0.9
BOT_ACTION_DESIRE_ABSOLUTE - 1.0
BOT_MODE_DESIRE_NONE - 0
BOT_MODE_DESIRE_VERYLOW - 0.1
BOT_MODE_DESIRE_LOW - 0.25
BOT_MODE_DESIRE_MODERATE - 0.5
BOT_MODE_DESIRE_HIGH - 0.75
BOT_MODE_DESIRE_VERYHIGH - 0.9
BOT_MODE_DESIRE_ABSOLUTE - 1.0
DAMAGE_TYPE_PHYSICAL
DAMAGE_TYPE_MAGICAL
DAMAGE_TYPE_PURE
DAMAGE_TYPE_ALL
UNIT_LIST_ALL
UNIT_LIST_ALLIES
UNIT_LIST_ALLIED_HEROES
UNIT_LIST_ALLIED_CREEPS
UNIT_LIST_ALLIED_WARDS
UNIT_LIST_ALLIED_BUILDINGS
UNIT_LIST_ENEMIES
UNIT_LIST_ENEMY_HEROES
UNIT_LIST_ENEMY_CREEPS
UNIT_LIST_ENEMY_WARDS
UNIT_LIST_NEUTRAL_CREEPS
UNIT_LIST_ENEMY_BUILDINGS
DIFFICULTY_INVALID
DIFFICULTY_PASSIVE
DIFFICULTY_EASY
DIFFICULTY_MEDIUM
DIFFICULTY_HARD
DIFFICULTY_UNFAIR
ATTRIBUTE_INVALID
ATTRIBUTE_STRENGTH
ATTRIBUTE_AGILITY
ATTRIBUTE_INTELLECT
PURCHASE_ITEM_SUCCESS
PURCHASE_ITEM_OUT_OF_STOCK
PURCHASE_ITEM_DISALLOWED_ITEM
PURCHASE_ITEM_INSUFFICIENT_GOLD
PURCHASE_ITEM_NOT_AT_HOME_SHOP
PURCHASE_ITEM_NOT_AT_SIDE_SHOP
PURCHASE_ITEM_NOT_AT_SECRET_SHOP
PURCHASE_ITEM_INVALID_ITEM_NAME
GAMEMODE_NONE
GAMEMODE_AP
GAMEMODE_CM
GAMEMODE_RD
GAMEMODE_SD
GAMEMODE_AR
GAMEMODE_REVERSE_CM
GAMEMODE_MO
GAMEMODE_CD
GAMEMODE_ABILITY_DRAFT
GAMEMODE_ARDM
GAMEMODE_1V1MID
GAMEMODE_ALL_DRAFT
TEAM_RADIANT
TEAM_DIRE
TEAM_NEUTRAL
TEAM_NONE
LANE_NONE
LANE_TOP
LANE_MID
LANE_BOT
GAME_STATE_INIT
GAME_STATE_WAIT_FOR_PLAYERS_TO_LOAD
GAME_STATE_HERO_SELECTION
GAME_STATE_STRATEGY_TIME
GAME_STATE_PRE_GAME
GAME_STATE_GAME_IN_PROGRESS
GAME_STATE_POST_GAME
GAME_STATE_DISCONNECT
GAME_STATE_TEAM_SHOWCASE
GAME_STATE_CUSTOM_GAME_SETUP
GAME_STATE_WAIT_FOR_MAP_TO_LOAD
GAME_STATE_LAST
HEROPICK_STATE_NONE
HEROPICK_STATE_AP_SELECT
HEROPICK_STATE_SD_SELECT
HEROPICK_STATE_CM_INTRO
HEROPICK_STATE_CM_CAPTAINPICK
HEROPICK_STATE_CM_BAN1
HEROPICK_STATE_CM_BAN2
HEROPICK_STATE_CM_BAN3
HEROPICK_STATE_CM_BAN4
HEROPICK_STATE_CM_BAN5
HEROPICK_STATE_CM_BAN6
HEROPICK_STATE_CM_BAN7
HEROPICK_STATE_CM_BAN8
HEROPICK_STATE_CM_BAN9
HEROPICK_STATE_CM_BAN10
HEROPICK_STATE_CM_SELECT1
HEROPICK_STATE_CM_SELECT2
HEROPICK_STATE_CM_SELECT3
HEROPICK_STATE_CM_SELECT4
HEROPICK_STATE_CM_SELECT5
HEROPICK_STATE_CM_SELECT6
HEROPICK_STATE_CM_SELECT7
HEROPICK_STATE_CM_SELECT8
HEROPICK_STATE_CM_SELECT9
HEROPICK_STATE_CM_SELECT10
HEROPICK_STATE_CM_PICK
HEROPICK_STATE_AR_SELECT
HEROPICK_STATE_MO_SELECT
HEROPICK_STATE_FH_SELECT
HEROPICK_STATE_CD_INTRO
HEROPICK_STATE_CD_CAPTAINPICK
HEROPICK_STATE_CD_BAN1
HEROPICK_STATE_CD_BAN2
HEROPICK_STATE_CD_BAN3
HEROPICK_STATE_CD_BAN4
HEROPICK_STATE_CD_BAN5
HEROPICK_STATE_CD_BAN6
HEROPICK_STATE_CD_SELECT1
HEROPICK_STATE_CD_SELECT2
HEROPICK_STATE_CD_SELECT3
HEROPICK_STATE_CD_SELECT4
HEROPICK_STATE_CD_SELECT5
HEROPICK_STATE_CD_SELECT6
HEROPICK_STATE_CD_SELECT7
HEROPICK_STATE_CD_SELECT8
HEROPICK_STATE_CD_SELECT9
HEROPICK_STATE_CD_SELECT10
HEROPICK_STATE_CD_PICK
HEROPICK_STATE_BD_SELECT
HERO_PICK_STATE_ABILITY_DRAFT_SELECT
HERO_PICK_STATE_ARDM_SELECT
HEROPICK_STATE_ALL_DRAFT_SELECT
HERO_PICK_STATE_CUSTOMGAME_SELECT
HEROPICK_STATE_SELECT_PENALTY
RUNE_INVALID (used as return value)
RUNE_DOUBLEDAMAGE
RUNE_HASTE
RUNE_ILLUSION
RUNE_INVISIBILITY
RUNE_REGENERATION
RUNE_BOUNTY
RUNE_ARCANE
RUNE_STATUS_UNKNOWN
RUNE_STATUS_AVAILABLE
RUNE_STATUS_MISSING
RUNE_POWERUP_1
RUNE_POWERUP_2
RUNE_BOUNTY_1
RUNE_BOUNTY_2
RUNE_BOUNTY_3
RUNE_BOUNTY_4
ITEM_SLOT_TYPE_INVALID
ITEM_SLOT_TYPE_MAIN
ITEM_SLOT_TYPE_BACKPACK
ITEM_SLOT_TYPE_STASH
BOT_ACTION_TYPE_NONE
BOT_ACTION_TYPE_IDLE
BOT_ACTION_TYPE_MOVE_TO
BOT_ACTION_TYPE_MOVE_TO_DIRECTLY
BOT_ACTION_TYPE_ATTACK
BOT_ACTION_TYPE_ATTACKMOVE
BOT_ACTION_TYPE_USE_ABILITY
BOT_ACTION_TYPE_PICK_UP_RUNE
BOT_ACTION_TYPE_PICK_UP_ITEM
BOT_ACTION_TYPE_DROP_ITEM
BOT_ACTION_TYPE_SHRINE
BOT_ACTION_TYPE_DELAY
COURIER_ACTION_BURST
COURIER_ACTION_ENEMY_SECRET_SHOP
COURIER_ACTION_RETURN
COURIER_ACTION_SECRET_SHOP
COURIER_ACTION_SIDE_SHOP
COURIER_ACTION_SIDE_SHOP2
COURIER_ACTION_TAKE_STASH_ITEMS
COURIER_ACTION_TAKE_AND_TRANSFER_ITEMS
COURIER_ACTION_TRANSFER_ITEMS
COURIER_STATE_IDLE - 0
COURIER_STATE_AT_BASE - 1
COURIER_STATE_MOVING - 2
COURIER_STATE_DELIVERING_ITEMS - 3
COURIER_STATE_RETURNING_TO_BASE - 4
COURIER_STATE_DEAD
TOWER_TOP_1
TOWER_TOP_2
TOWER_TOP_3
TOWER_MID_1
TOWER_MID_2
TOWER_MID_3
TOWER_BOT_1
TOWER_BOT_2
TOWER_BOT_3
TOWER_BASE_1
TOWER_BASE_2
BARRACKS_TOP_MELEE
BARRACKS_TOP_RANGED
BARRACKS_MID_MELEE
BARRACKS_MID_RANGED
BARRACKS_BOT_MELEE
BARRACKS_BOT_RANGED
SHRINE_JUNGLE_1
SHRINE_JUNGLE_2
SHOP_HOME
SHOP_SIDE
SHOP_SECRET
SHOP_SIDE2
SHOP_SECRET2
ABILITY_TARGET_TEAM_NONE
ABILITY_TARGET_TEAM_FRIENDLY
ABILITY_TARGET_TEAM_ENEMY
ABILITY_TARGET_TYPE_NONE
ABILITY_TARGET_TYPE_HERO
ABILITY_TARGET_TYPE_CREEP
ABILITY_TARGET_TYPE_BUILDING
ABILITY_TARGET_TYPE_COURIER
ABILITY_TARGET_TYPE_OTHER
ABILITY_TARGET_TYPE_TREE
ABILITY_TARGET_TYPE_BASIC
ABILITY_TARGET_TYPE_ALL
ABILITY_TARGET_FLAG_NONE
ABILITY_TARGET_FLAG_RANGED_ONLY
ABILITY_TARGET_FLAG_MELEE_ONLY
ABILITY_TARGET_FLAG_DEAD
ABILITY_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
ABILITY_TARGET_FLAG_NOT_MAGIC_IMMUNE_ALLIES
ABILITY_TARGET_FLAG_INVULNERABLE
ABILITY_TARGET_FLAG_FOW_VISIBLE
ABILITY_TARGET_FLAG_NO_INVIS
ABILITY_TARGET_FLAG_NOT_ANCIENTS
ABILITY_TARGET_FLAG_PLAYER_CONTROLLED
ABILITY_TARGET_FLAG_NOT_DOMINATED
ABILITY_TARGET_FLAG_NOT_SUMMONED
ABILITY_TARGET_FLAG_NOT_ILLUSIONS
ABILITY_TARGET_FLAG_NOT_ATTACK_IMMUNE
ABILITY_TARGET_FLAG_MANA_ONLY
ABILITY_TARGET_FLAG_CHECK_DISABLE_HELP
ABILITY_TARGET_FLAG_NOT_CREEP_HERO
ABILITY_TARGET_FLAG_OUT_OF_WORLD
ABILITY_TARGET_FLAG_NOT_NIGHTMARED
ABILITY_TARGET_FLAG_PREFER_ENEMIES
ABILITY_BEHAVIOR_NONE
ABILITY_BEHAVIOR_HIDDEN
ABILITY_BEHAVIOR_PASSIVE
ABILITY_BEHAVIOR_NO_TARGET
ABILITY_BEHAVIOR_UNIT_TARGET
ABILITY_BEHAVIOR_POINT
ABILITY_BEHAVIOR_AOE
ABILITY_BEHAVIOR_NOT_LEARNABLE
ABILITY_BEHAVIOR_CHANNELLED
ABILITY_BEHAVIOR_ITEM
ABILITY_BEHAVIOR_TOGGLE
ABILITY_BEHAVIOR_DIRECTIONAL
ABILITY_BEHAVIOR_IMMEDIATE
ABILITY_BEHAVIOR_AUTOCAST
ABILITY_BEHAVIOR_OPTIONAL_UNIT_TARGET
ABILITY_BEHAVIOR_OPTIONAL_POINT
ABILITY_BEHAVIOR_OPTIONAL_NO_TARGET
ABILITY_BEHAVIOR_AURA
ABILITY_BEHAVIOR_ATTACK
ABILITY_BEHAVIOR_DONT_RESUME_MOVEMENT
ABILITY_BEHAVIOR_ROOT_DISABLES
ABILITY_BEHAVIOR_UNRESTRICTED
ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE
ABILITY_BEHAVIOR_IGNORE_CHANNEL
ABILITY_BEHAVIOR_DONT_CANCEL_MOVEMENT
ABILITY_BEHAVIOR_DONT_ALERT_TARGET
ABILITY_BEHAVIOR_DONT_RESUME_ATTACK
ABILITY_BEHAVIOR_NORMAL_WHEN_STOLEN
ABILITY_BEHAVIOR_IGNORE_BACKSWING
ABILITY_BEHAVIOR_RUNE_TARGET
ABILITY_BEHAVIOR_DONT_CANCEL_CHANNEL
ABILITY_BEHAVIOR_VECTOR_TARGETING
ABILITY_BEHAVIOR_LAST_RESORT_POINT
GLYPH_COOLDOWN
ACTIVITY_IDLE - 1500
ACTIVITY_IDLE_RARE - 1501
ACTIVITY_RUN - 1502
ACTIVITY_ATTACK - 1503
ACTIVITY_ATTACK2 - 1504
ACTIVITY_ATTACK_EVENT - 1505
ACTIVITY_DIE - 1506
ACTIVITY_FLINCH - 1507
ACTIVITY_FLAIL - 1508
ACTIVITY_DISABLED - 1509
ACTIVITY_CAST_ABILITY_1 - 1510
ACTIVITY_CAST_ABILITY_2 - 1511
ACTIVITY_CAST_ABILITY_3 - 1512
ACTIVITY_CAST_ABILITY_4 - 1513
ACTIVITY_CAST_ABILITY_5 - 1514
ACTIVITY_CAST_ABILITY_6 - 1515
ACTIVITY_OVERRIDE_ABILITY_1 - 1516
ACTIVITY_OVERRIDE_ABILITY_2 - 1517
ACTIVITY_OVERRIDE_ABILITY_3 - 1518
ACTIVITY_OVERRIDE_ABILITY_4 - 1519
ACTIVITY_CHANNEL_ABILITY_1 - 1520
ACTIVITY_CHANNEL_ABILITY_2 - 1521
ACTIVITY_CHANNEL_ABILITY_3 - 1522
ACTIVITY_CHANNEL_ABILITY_4 - 1523
ACTIVITY_CHANNEL_ABILITY_5 - 1524
ACTIVITY_CHANNEL_ABILITY_6 - 1525
ACTIVITY_CHANNEL_END_ABILITY_1 - 1526
ACTIVITY_CHANNEL_END_ABILITY_2 - 1527
ACTIVITY_CHANNEL_END_ABILITY_3 - 1528
ACTIVITY_CHANNEL_END_ABILITY_4 - 1529
ACTIVITY_CHANNEL_END_ABILITY_5 - 1530
ACTIVITY_CHANNEL_END_ABILITY_6 - 1531
ACTIVITY_CONSTANT_LAYER - 1532
ACTIVITY_CAPTURE - 1533
ACTIVITY_SPAWN - 1534
ACTIVITY_KILLTAUNT - 1535
ACTIVITY_TAUNT - 1536
--]]	


--[[
J.SetUserHeroInit(nAbilityBuildList, nTalentBuildList, sBuyList, sSellList)
J.ConsiderUpdateEnvironment(bot)
J.PrintInitStatus(nFlag, nNum, sMessage1, sMessage2)
J.IsDebugHero(bot, sName)
J.CanNotUseAbility(bot)
J.GetVulnerableWeakestUnit(bHero, bEnemy, nRadius, bot)
J.GetUnitAllyCountAroundEnemyTarget(target, nRadius)
J.GetAroundTargetEnemyUnitCount(target, nRadius)
J.GetAroundTargetEnemyHeroCount(target, nRadius)
J.GetNearbyAroundLocationUnitCount(bEnemy, bHero, nRadius, vLoc)
J.GetAttackTargetEnemyCreepCount(target, nRange)
J.GetVulnerableUnitNearLoc(bHero, bEnemy, nCastRange, nRadius, vLoc, bot)
J.GetAoeEnemyHeroLocation(bot, nCastRange, nRadius, nCount)
J.IsWithoutTarget(bot)
J.GetProperTarget(bot)
J.IsAllyCanKill(target)
J.IsOtherAllyCanKillTarget(bot, target)
J.GetAlliesNearLoc(vLoc, nRadius)
J.IsAllyHeroBetweenAllyAndEnemy(hAlly, hEnemy, vLoc, nRadius)
J.IsSandKingThere(bot, nCastRange, fTime)
J.GetUltimateAbility(bot)
J.CanUseRefresherShard(bot)
J.GetMostUltimateCDUnit()
J.GetPickUltimateScepterUnit()
J.CanUseRefresherOrb(bot)
J.IsSuspiciousIllusion(npcTarget)
J.CanCastOnMagicImmune(npcTarget)
J.CanCastOnNonMagicImmune(npcTarget)
J.CanCastOnTargetAdvanced(npcTarget)
J.CanCastUnitSpellOnTarget(npcTarget, nDelay)
J.CanKillTarget(npcTarget, dmg, dmgType)
J.WillKillTarget(npcTarget, dmg, dmgType, dTime)
J.WillMagicKillTarget(bot, npcTarget, dmg, nDelay)
J.HasForbiddenModifier(npcTarget)
J.ShouldEscape(bot)
J.IsDisabled(bEnemy, npcTarget)
J.IsTaunted(npcTarget)
J.IsInRange(npcTarget, bot, nCastRange)
J.IsInLocRange(npcTarget, nLoc, nCastRange)
J.IsInTeamFight(bot, range)
J.IsRetreating(bot)
J.IsGoingOnSomeone(bot)
J.IsDefending(bot)
J.IsPushing(bot)
J.IsLaning(bot)
J.IsFarming(bot)
J.IsShopping(bot)
J.GetTeamFountain()
J.GetEnemyFountain()
J.GetComboItem(bot, item_name)
J.HasItem(bot, item_name)
J.IsItemAvailable(item_name)
J.GetMostHpUnit(ListUnit)
J.GetLeastHpUnit(ListUnit)
J.IsAllowedToSpam(bot, nManaCost)
J.IsAllyUnitSpell(sAbilityName)
J.IsProjectileUnitSpell(sAbilityName)
J.IsOnlyProjectileSpell(sAbilityName)
J.IsWillBeCastUnitTargetSpell(bot, nRange)
J.IsWillBeCastPointSpell(bot, nRange)
J.IsProjectileIncoming(bot, range)
J.IsUnitTargetProjectileIncoming(bot, range)
J.IsAttackProjectileIncoming(bot, range)
J.IsNotAttackProjectileIncoming(bot, range)
J.GetAttackProDelayTime(bot, nCreep)
J.GetCreepAttackActivityWillRealDamage(nUnit, nTime)
J.GetCreepAttackProjectileWillRealDamage(nUnit, nTime)
J.GetTotalAttackWillRealDamage(nUnit, nTime)
J.GetAttackProjectileDamageByRange(nUnit, nRange)
J.GetCorrectLoc(target, delay)
J.GetEscapeLoc()
J.IsStuck2(bot)
J.IsStuck(bot)
J.IsExistInTable(u, tUnit)
J.CombineTwoTable(tableOne, tableTwo)
J.GetInvUnitInLocCount(bot, nRange, nRadius, loc, pierceImmune)
J.GetInLocLaneCreepCount(bot, nRange, nRadius, loc)
J.GetInvUnitCount(pierceImmune, units)
J.GetDistanceFromEnemyFountain(bot)
J.GetDistanceFromAllyFountain(bot)
J.GetDistanceFromAncient(bot, bEnemy)
J.GetAroundTargetAllyHeroCount(target, nRadius, bot)
J.GetAroundTargetOtherAllyHeroCount(target, nRadius, bot)
J.GetAllyCreepNearLoc(vLoc, nRadius, bot)
J.GetAllyUnitCountAroundEnemyTarget(target, nRadius, bot)
J.GetLocationToLocationDistance(fLoc, sLoc)
J.GetUnitTowardDistanceLocation(bot, towardTarget, nDistance)
J.GetLocationTowardDistanceLocation(bot, towardLocation, nDistance)
J.GetFaceTowardDistanceLocation(bot, nDistance)
J.PrintMessage(nMessage, nNumber, n, nIntevel)
J.Print(nMessage, nNumber)
J.PrintAndReport(nMessage, nNumber)
J.SetReportMessage(nMessage, nNumber, n)
J.SetReport(nMessage, nNumber)
J.SetPingLocation(bot, vLoc)
J.SetReportAndPingLocation(vLoc, nMessage, nNumber)
J.SetReportMotive(bDebugFile, sMotive)
J.GetCastLocation(bot, npcTarget, nCastRange, nRadius)
J.GetDelayCastLocation(bot, npcTarget, nCastRange, nRadius, nTime)
J.GetOne(number)
J.GetTwo(number)
J.SetQueueSwitchPtToINT(bot)
J.SetQueueUseSoulRing(bot)
J.SetQueuePtToINT(bot, bSoulRingUsed)
J.IsPTReady(bot, status)
J.ShouldSwitchPTStat(bot, pt)
J.IsOtherAllysTarget(unit)
J.IsAllysTarget(unit)
J.IsKeyWordUnit(keyWord, Unit)
J.IsHumanPlayer(nUnit)
J.IsValid(nTarget)
J.IsValidHero(nTarget)
J.IsValidBuilding(nTarget)
J.IsRoshan(nTarget)
J.IsMoving(bot)
J.IsRunning(bot)
J.IsAttacking(bot)
J.GetModifierTime(bot, nMoName)
J.GetRemainStunTime(bot)
J.IsTeamActivityCount(bot, nCount)
J.GetSpecialModeAllies(nMode, nDistance, bot)
J.GetSpecialModeAlliesCount(nMode)
J.GetTeamFightLocation(bot)
J.GetTeamFightAlliesCount(bot)
J.GetCenterOfUnits(nUnits)
J.GetMostFarmLaneDesire()
J.GetMostDefendLaneDesire()
J.GetMostPushLaneDesire()
J.GetNearestLaneFrontLocation(nUnitLoc, bEnemy, fDeltaFromFront)
J.IsSpecialCarry(bot)
J.IsSpecialSupport(bot)
J.GetAttackableWeakestUnit(bHero, bEnemy, nRadius, bot)
J.CanBeAttacked(npcTarget)
J.GetHPR(bot)
J.GetMPR(bot)
J.GetAllyList(bot, nRange)
J.GetAllyCount(bot, nRange)
J.GetEnemyList(bot, nRange)
J.GetEnemyCount(bot, nRange)
J.ConsiderTarget()
J.IsHaveAegis(bot)
J.IsLocHaveTower(nRange, bEnemy, nLoc)
J.GetNearbyLocationToTp(nLoc)
J.IsEnemyFacingUnit(nRange, bot, nDegrees)
J.IsAllyFacingUnit(nRange, bot, nDegrees)
J.IsEnemyTargetUnit(nRange, nUnit)
J.IsCastingUltimateAbility(bot)
J.IsInAllyArea(bot)
J.IsInEnemyArea(bot)
J.IsEnemyHeroAroundLocation(vLoc, nRadius)
J.GetNumOfAliveHeroes(bEnemy)
J.GetAverageLevel(bEnemy)
J.GetNumOfTeamTotalKills(bEnemy)
J.ConsiderForBtDisassembleMask(bot)
J.ConsiderForMkbDisassembleMask(bot)
J.HasNotActionLast(nCD, nNumber)
J.GetCastPoint(bot, unit, nPointTime, nProjectSpeed)	
J.CanBreakTeleport(bot, unit, nPointTime, nProjectSpeed)	
J.GetMagicToPhysicalDamage(bot, nUnit, nMagicDamage)
--]]


--]]