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
1,自定义变量命名用匈牙利法,即首单词小写,其他单词首字母大写(除个别特殊情况,如npc类,循环头,部分临时变量)
  自定义变量如果是表的话,以List结尾,如 enemyList; (当前的矛盾是一些老代码处混用的大小驼峰法,用大驼峰法处应尽快修正)
  同功能含义和类型的变量后缀可用1,2,3....(name1, name2),最好尽量用有区分度的英文后缀(nameLong, nameShort)
  自定义函数或模块命名用大驼峰法,即将各单词首字母大写连接构成,尽量只使用已有的函数开头词,如:Is,Has,Can,Should,Will,Get,Print,Set,Consider  
2,各类运算符添加空格风格要统一(循环头特殊),
  比如说' = '及其他赋值或关系或逻辑运算符的两边, ', '后面有内容时的右边,
  ' -'及其他算术运算符左边, '- '及其他算术运算符与非数字的右边,
  能不用双引号尽量不用双引号,能不用分号尽量不用分号,
  '( () )'多重括号嵌套的外层括号内侧.
3,需要使用循环逻辑时尽量不用除 for 语句外的关键字,
  需要进行多个条件逻辑运算时,每个条件块单独一行.
4,函数参数中包含了 bot(句柄) 的话, 将其放在第一位, 同一文件内,要么均为npcBot, 要么均为bot
如有遗漏或矛盾的情况以文件内同类代码的主流规范为准.
附:常用词汇  放最后: 表示布尔值 bDone bError bSuccess bFound  bReady  如: bUpdateDone
   表修饰时(放最后) Total、 Sum、 Average、 Max、 Min、 Record、 String、 Pointer、 First、 Last、 Lim  如: creepCountMax
--]]

--[[计划二:
冗余代码分类整合计划正在进行中...
将同类型的函数分类
将功能类似的函数整合
--]]

--[[计划三:
同义词合并计划正在进行中...
将所有表达同一个意思的变量名字统一
例如 bot和npcBot,计划全文件统一为用 bot(即替换npcBot的存在)
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
local sDebugVersion= '20190712ver1.00'
local nPrintTime   = 9999
local nDebugTime   = 9999
local bDebugMode   = false
local bDebugTeam   = (GBotTeam == TEAM_RADIANT)
local sDebugHero   = 'luna'
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


local RB = Vector(-7174.000000, -6671.00000,  0.000000)
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
	local hHero   = GetTeamMember(i)
	
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
	local hHero   = GetTeamMember(i)
	
	
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
--J.Chat  = require(GetScriptDirectory()..'/FunLib/jmz_chat')

---[[--------------------------------
-------------------------------------
if bDebugTeam
then
	print(GBotTeam..': Simple AI: Function Init Successful!')
end
------------------------------------
-------变量部分完成,下面开始函数部分
-----------------------------------]]

--在这里更新全局变量
function J.ConsiderUpdateEnvironment(bot)



end


function J.PrintInitStatus(nFlag, nNum, sMessage1, sMessage2)

	local npcBot = GetBot()

	if nFlag +1 ~= nNum 
	   or not J.IsDebugHero(npcBot, sDebugHero)
	then return nFlag end
	
	local botName = string.gsub(string.sub(npcBot:GetUnitName(), 15),'_','');
	print('Simple AI '..string.sub(botName, 1, 4)..': '..string.sub(sMessage1, 1, 5)..' of '..sMessage2..' init successful!')
	return nNum
	
end


function J.IsDebugHero(npcBot, sName)

    return  bDebugMode and bDebugTeam
			and npcBot:GetUnitName() == sName

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
function J.GetEnemyUnitCountAroundTarget(target, nRadius)

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

	local bot    = GetBot();
	local nCount = 0;	
	local units  = {};
	
	if bHero then
		units = bot:GetNearbyHeroes(1600, bEnemy, BOT_MODE_NONE);
	else
		units = bot:GetNearbyCreeps(1600, bEnemy);
	end
	
	for _,u in pairs(units)
	do
		if u:IsAlive()
		   and GetUnitToLocationDistance(u,vLoc) <= nRadius
		then
			nCount = nCount + 1;
		end	
	end
	
	return nCount;
end


function J.GetAttackTargetEnemyCreepCount(target, nRange)

	local bot = GetBot();
	local nAllyCreeps = bot:GetNearbyCreeps(nRange,false);
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

function J.GetAoeEnemyHeroLocation(npcBot,nCastRange,nRadius,nCount)

	local nAoe = npcBot:FindAoELocation(true,true,npcBot:GetLocation(),nCastRange,nRadius,0,0);
	if nAoe.count >= nCount
	then
		local nEnemyHeroList = J.GetEnemyList(npcBot,1600);
		local nTrueCount = 0;
		for _,enemy in pairs(nEnemyHeroList)
		do
			if GetUnitToLocationDistance(enemy,nAoe.targetloc) <= nRadius
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
		   and GetUnitToUnitDistance(ally,target) <= ally:GetAttackRange() + 100
		then
			nTotalDamage = nTotalDamage + ally:GetAttackDamage();
		end
	end
	
	nTotalDamage = nTotalDamage * 1.88 + J.GetAttackProjectileDamageByRange(target,1200);
	
	if J.CanKillTarget(target,nTotalDamage ,nDamageType)
	then
		return true;
	end
	
	return false;
end


function J.IsOtherAllyCanKillTarget(bot,target)

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
		   and not J.IsDisabled(true,ally)
		   and ally:GetHealth()/ally:GetMaxHealth() > 0.15
		   and ally:IsFacingLocation(target:GetLocation(),45)
		   and GetUnitToUnitDistance(ally,target) <= ally:GetAttackRange() + 90
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
			return true,  enemy:GetLocation();
		end
		if enemy:IsChanneling() and not enemy:HasModifier('modifier_item_dustofappearance')
		then
		    if enemy:IsInvisible()
			   or enemy:HasModifier('modifier_invisible')
			   or enemy:HasModifier('modifier_item_invisibility_edge_windwalk')
			   or enemy:HasModifier('modifier_item_silver_edge_windwalk')
			then
				return true,  enemy:GetLocation();
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
function J.CanCastUnitSpellOnTarget( npcTarget ,nDelay )
	
	for _,mod in pairs(J.Buff["hero_has_spell_shield"])
	do
		if npcTarget:HasModifier(mod) 
		   and J.GetModifierTime(npcTarget,mod) >= nDelay
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
	
	local nRealBonus = J.GetTotalAttackWillRealDamage(npcTarget,dTime);
	
	local nTotalDamage = npcTarget:GetActualIncomingDamage( dmg, dmgType ) + nRealBonus;

	return nTotalDamage > targetHealth and nRealBonus < targetHealth - 1  ; 
end


function J.WillMagicKillTarget(bot,npcTarget, dmg, nDelay)
	
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
		and not npcTarget:IsFacingLocation(bot:GetLocation(),120)
	then 
		EstDamage = EstDamage * 0.7; 
	end 
	
	if npcTarget:HasModifier("modifier_kunkka_ghost_ship_damage_delay")
	then
		local buffTime = J.GetModifierTime(npcTarget,"modifier_kunkka_ghost_ship_damage_delay");
		if buffTime >= nDelay then EstDamage = EstDamage *0.55; end
	end		
	
	if npcTarget:HasModifier("modifier_templar_assassin_refraction_absorb") 
	then
		local buffTime = J.GetModifierTime(npcTarget,"modifier_templar_assassin_refraction_absorb");
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
		local enemies = npcTarget:GetNearbyHeroes(800,false,BOT_MODE_NONE);
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


function J.ShouldEscape(npcBot)
	
	local tableNearbyAttackAllies = npcBot:GetNearbyHeroes( 660, false, BOT_MODE_ATTACK );
	if #tableNearbyAttackAllies > 0 and J.GetHPR(npcBot) > 0.16 then return false end

	local tableNearbyEnemyHeroes = npcBot:GetNearbyHeroes( 1000, true, BOT_MODE_NONE );
	if ( npcBot:WasRecentlyDamagedByAnyHero(2.0) 
	     or npcBot:WasRecentlyDamagedByTower(2.0) 
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


function J.IsInRange(npcTarget, npcBot, nCastRange)
	return GetUnitToUnitDistance( npcTarget, npcBot ) <= nCastRange;
end


function J.IsInLocRange(npcTarget, nLoc, nCastRange)
	return GetUnitToLocationDistance( npcTarget, nLoc ) <= nCastRange;
end


function J.IsInTeamFight(npcBot, range)
	if range > 1600 then range = 1600 end;
	local tableNearbyAttackingAlliedHeroes = npcBot:GetNearbyHeroes( range, false, BOT_MODE_ATTACK );
	return #tableNearbyAttackingAlliedHeroes >= 2 and npcBot:GetActiveMode() ~= BOT_MODE_RETREAT;
end


function J.IsRetreating(npcBot)

	local mode = npcBot:GetActiveMode();
	local modeDesire = npcBot:GetActiveModeDesire();
	local bDamagedByAnyHero = npcBot:WasRecentlyDamagedByAnyHero(2.0);

	return ( mode == BOT_MODE_RETREAT and modeDesire > BOT_MODE_DESIRE_MODERATE and npcBot:DistanceFromFountain() > 600 )
		  or ( mode == BOT_MODE_EVASIVE_MANEUVERS and bDamagedByAnyHero ) 
		  or ( npcBot:HasModifier('modifier_bloodseeker_rupture') and bDamagedByAnyHero )
		  or ( mode == BOT_MODE_FARM and modeDesire > BOT_MODE_DESIRE_ABSOLUTE )
end


function J.IsGoingOnSomeone(npcBot)
	local mode = npcBot:GetActiveMode();
	return mode == BOT_MODE_ROAM or
		   mode == BOT_MODE_TEAM_ROAM or
		   mode == BOT_MODE_ATTACK or
		   mode == BOT_MODE_DEFEND_ALLY
end


function J.IsDefending(npcBot)
	local mode = npcBot:GetActiveMode();
	return mode == BOT_MODE_DEFEND_TOWER_TOP or
		   mode == BOT_MODE_DEFEND_TOWER_MID or
		   mode == BOT_MODE_DEFEND_TOWER_BOT 
end


function J.IsPushing(npcBot)
	local mode = npcBot:GetActiveMode();
	return mode == BOT_MODE_PUSH_TOWER_TOP or
		   mode == BOT_MODE_PUSH_TOWER_MID or
		   mode == BOT_MODE_PUSH_TOWER_BOT 
end


function J.IsLaning(npcBot)
	local mode = npcBot:GetActiveMode();
	return mode == BOT_MODE_LANING
end


function J.IsFarming(npcBot)
	local mode = npcBot:GetActiveMode();
	local nTarget = J.GetProperTarget(npcBot);
	return mode == BOT_MODE_FARM
			or ( nTarget ~= nil and nTarget:IsAlive() and nTarget:GetTeam() == TEAM_NEUTRAL and not J.IsRoshan(nTarget))
end


function J.IsShopping(npcBot)
	
	local mode = npcBot:GetActiveMode();
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


function J.GetComboItem(npcBot, item_name)
	local Slot = npcBot:FindItemSlot(item_name);
	if Slot >= 0 and Slot <= 5 then
		return npcBot:GetItemInSlot(Slot);
	else
		return nil;
	end
end


function J.HasItem(npcBot, item_name)
	
	if npcBot:IsMuted() then return false end 
	
	local Slot = npcBot:FindItemSlot(item_name);
	
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


function J.IsAllowedToSpam(npcBot, nManaCost)
	if npcBot:HasModifier("modifier_silencer_curse_of_the_silent") then return false end;

	return ( npcBot:GetMana() - nManaCost ) / npcBot:GetMaxMana() >= fSpamThreshold;
end


function J.IsAllyUnitSpell(sAbilityName)

	local  nSpell = {
					"bloodseeker_bloodrage",
					"omniknight_purification",
					"omniknight_repel",
					"medusa_mana_shield",
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

	local  nSpell = {
					"sven_storm_bolt",
					"skywrath_mage_arcane_bolt",
					"medusa_mystic_snake",
					"chaos_knight_chaos_bolt",
					"skeleton_king_hellfire_blast",
					"phantom_assassin_stifling_dagger",
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


function J.IsWillBeCastUnitTargetSpell(npcBot,nRange)
	
	local nEnemys = npcBot:GetNearbyHeroes(nRange,true,BOT_MODE_NONE);
	for _,npcEnemy in pairs(nEnemys)
	do
		if npcEnemy ~= nil and npcEnemy:IsAlive()
		   and ( npcEnemy:IsCastingAbility() or npcEnemy:IsUsingAbility() )
		   and npcEnemy:IsFacingLocation(npcBot:GetLocation(),20)
		then
			local nAbility = npcEnemy:GetCurrentActiveAbility();
			if nAbility ~= nil 
				and nAbility:GetBehavior() == ABILITY_BEHAVIOR_UNIT_TARGET
			then
				local sAbilityName = nAbility:GetName();
				if not J.IsAllyUnitSpell(sAbilityName)
				then				
					if J.IsInRange(npcEnemy,npcBot,330)
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


function J.IsWillBeCastPointSpell(npcBot,nRange)
	
	local nEnemys = npcBot:GetNearbyHeroes(nRange,true,BOT_MODE_NONE);
	for _,npcEnemy in pairs(nEnemys)
	do
		if npcEnemy ~= nil and npcEnemy:IsAlive()
		   and ( npcEnemy:IsCastingAbility() or npcEnemy:IsUsingAbility() )
		   and npcEnemy:IsFacingLocation(npcBot:GetLocation(),45)
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
function J.IsProjectileIncoming(npcBot, range)
	local incProj = npcBot:GetIncomingTrackingProjectiles()
	for _,p in pairs(incProj)
	do
		if p.is_dodgeable 
		   and not p.is_attack 
		   and GetUnitToLocationDistance(npcBot, p.location) < range 
		   and ( p.caster == nil or p.caster:GetTeam() ~= GetTeam() ) 
		   and ( p.ability ~= nil and not J.IsOnlyProjectileSpell(p.ability:GetName()) )
		then
			return true;
		end
	end
	return false;
end


--可反弹敌方非攻击弹道
function J.IsUnitTargetProjectileIncoming(npcBot, range)
	local incProj = npcBot:GetIncomingTrackingProjectiles()
	for _,p in pairs(incProj)
	do
		if not p.is_attack 
		   and GetUnitToLocationDistance(npcBot, p.location) < range 
		   and ( p.caster == nil 
		         or ( p.caster:GetTeam() ~= npcBot:GetTeam() 
					  and p.caster:GetUnitName() ~= "npc_dota_hero_antimage" 
					  and p.caster:GetUnitName() ~= "npc_dota_hero_templar_assassin") )
		   and ( p.ability ~= nil 
		         and ( p.ability:GetName() ~= "medusa_mystic_snake" 
				       or p.caster == nil 
					   or p.caster:GetUnitName() == "npc_dota_hero_medusa"
					   or p.caster:GetUnitName() == "npc_dota_hero_abaddon" ) ) 
		   and ( p.ability:GetBehavior() == ABILITY_BEHAVIOR_UNIT_TARGET 
				 or not J.IsOnlyProjectileSpell(p.ability:GetName()))
		then
			return true;
		end
	end
	return false;
end


--攻击弹道
function J.IsAttackProjectileIncoming(npcBot, range)
	local incProj = npcBot:GetIncomingTrackingProjectiles()
	for _,p in pairs(incProj)
	do
		if p.is_attack
		   and GetUnitToLocationDistance(npcBot, p.location) < range 
	    then
			return true;
		end
	end
	return false;
end


--非攻击敌方弹道
function J.IsNotAttackProjectileIncoming(npcBot, range)
	local incProj = npcBot:GetIncomingTrackingProjectiles()
	for _,p in pairs(incProj)
	do
		if not p.is_attack
		   and GetUnitToLocationDistance(npcBot, p.location) < range 
		   and ( p.caster == nil or p.caster:GetTeam() ~= npcBot:GetTeam() )
		   and ( p.ability ~= nil and ( p.ability:GetName() ~= "medusa_mystic_snake" or p.caster == nil or p.caster:GetUnitName() == "npc_dota_hero_medusa" ) ) 
		then
			return true;
		end
	end
	return false;
end


function J.GetAttackProDelayTime(bot,nCreep)

	local botName        = bot:GetUnitName();
	local botAttackRange = bot:GetAttackRange();
	local botAttackPoint = bot:GetAttackPoint();
	local botAttackSpeed = bot:GetAttackSpeed();
	local botProSpeed    = bot:GetAttackProjectileSpeed();
	local botMoveSpeed   = bot:GetCurrentMovementSpeed();
	local nDist  =  GetUnitToUnitDistance(bot,nCreep);
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


function J.GetCreepAttackActivityWillRealDamage(nUnit,nTime)
	
	local npcBot = GetBot();
	local botLV  = npcBot:GetLevel();
	local gameTime = GameTime();
	local nDamage = 0;
	local othersBeEnemy = true;
	
	if nUnit:GetTeam() ~= npcBot:GetTeam() then othersBeEnemy = false end;
	
	local nCreeps = npcBot:GetNearbyLaneCreeps(1600,othersBeEnemy);
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
	
	--(or J.IsKeyWordUnit( "ranged", creep ) and GetUnitToUnitDistance(creep,nUnit) < 150)
	
	return nUnit:GetActualIncomingDamage(nDamage,DAMAGE_TYPE_PHYSICAL);

end


function J.GetCreepAttackProjectileWillRealDamage(nUnit,nTime)
	
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
			local nDistance     = GetUnitToLocationDistance(nUnit,p.location);
			if nProjectDist > nDistance 
			then
				nDamage = nDamage + p.caster:GetAttackDamage() * p.caster:GetAttackCombatProficiency(nUnit);
			end
		end
	end
	
	return nUnit:GetActualIncomingDamage(nDamage,DAMAGE_TYPE_PHYSICAL);

end


function J.GetTotalAttackWillRealDamage(nUnit,nTime)

     return J.GetCreepAttackProjectileWillRealDamage(nUnit,nTime) + J.GetCreepAttackActivityWillRealDamage(nUnit,nTime);

end


function J.GetAttackProjectileDamageByRange(nUnit,nRange)
	
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


function J.IsStuck2(npcBot)
	if npcBot.stuckLoc ~= nil and npcBot.stuckTime ~= nil then 
		local EAd = GetUnitToUnitDistance(npcBot, GetAncient(GetOpposingTeam()));
		if DotaTime() > npcBot.stuckTime + 5.0 and GetUnitToLocationDistance(npcBot, npcBot.stuckLoc) < 25  
           and npcBot:GetCurrentActionType() == BOT_ACTION_TYPE_MOVE_TO and EAd > 2200		
		then
			print(npcBot:GetUnitName().." is stuck")
			--DebugPause();
			return true;
		end
	end
	return false
end


function J.IsStuck(npcBot)
	if npcBot.stuckLoc ~= nil and npcBot.stuckTime ~= nil then 
		local attackTarget = npcBot:GetAttackTarget();
		local EAd = GetUnitToUnitDistance(npcBot, GetAncient(GetOpposingTeam()));
		local TAd = GetUnitToUnitDistance(npcBot, GetAncient(GetTeam()));
		local Et = npcBot:GetNearbyTowers(450, true);
		local At = npcBot:GetNearbyTowers(450, false);
		if npcBot:GetCurrentActionType() == BOT_ACTION_TYPE_MOVE_TO and attackTarget == nil and EAd > 2200 and TAd > 2200 and #Et == 0 and #At == 0  
		   and DotaTime() > npcBot.stuckTime + 5.0 and GetUnitToLocationDistance(npcBot, npcBot.stuckLoc) < 25    
		then
			print(npcBot:GetUnitName().." is stuck")
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


function J.CombineTwoTable(tableOne,tableTwo)
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

function J.GetDistanceFromEnemyFountain(npcBot)
	local EnemyFountain = J.GetEnemyFountain();
	local Distance = GetUnitToLocationDistance(npcBot,EnemyFountain);
	return Distance;
end


function J.GetDistanceFromAllyFountain(npcBot)
	local OurFountain = J.GetTeamFountain();
	local Distance = GetUnitToLocationDistance(npcBot,OurFountain);
	return Distance;
end


function J.GetDistanceFromAncient(npcBot,bEnemy)
	local targetAncient = GetAncient(GetTeam());
	if bEnemy then  targetAncient = GetAncient(GetOpposingTeam()); end
	
	return GetUnitToUnitDistance(npcBot,targetAncient);
end


function J.GetAroundTargetAllyHeroCount(target, nRadius, npcBot)
			
	local heroes = J.GetAlliesNearLoc(target:GetLocation(), nRadius)

	return #heroes;
end


function J.GetAroundTargetOtherAllyHeroCount(target, nRadius, npcBot)
			
	local heroes = J.GetAlliesNearLoc(target:GetLocation(), nRadius)
	
	if GetUnitToUnitDistance(npcBot,target) <= nRadius
	then
		return #heroes - 1;
	end
	
	return #heroes;
end


function J.GetAllyCreepNearLoc(vLoc, nRadius, npcBot)
	local AllyCreepsAll = npcBot:GetNearbyCreeps(1600, false);
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


function J.GetAllyUnitCountAroundEnemyTarget(target, nRadius,npcBot)
	local heroes = J.GetAlliesNearLoc(target:GetLocation(), nRadius)	
	local creeps = J.GetAllyCreepNearLoc(target:GetLocation(), nRadius, npcBot);		
	return #heroes + #creeps ;
end


function J.GetLocationToLocationDistance(fLoc,sLoc)
	
	local x1=fLoc.x
	local x2=sLoc.x
	local y1=fLoc.y
	local y2=sLoc.y
	return math.sqrt(math.pow((y2-y1),2)+math.pow((x2-x1),2))

end


function J.GetUnitTowardDistanceLocation(npcBot,towardTarget,nDistance)
    local npcBotLocation = npcBot:GetLocation();
    local tempVector = (towardTarget:GetLocation() - npcBotLocation) / GetUnitToUnitDistance(npcBot,towardTarget);
	return npcBotLocation + nDistance * tempVector;
end


function J.GetLocationTowardDistanceLocation(npcBot,towardLocation,nDistance)
    local npcBotLocation = npcBot:GetLocation();
    local tempVector = (towardLocation - npcBotLocation) / GetUnitToLocationDistance(npcBot,towardLocation);
	return npcBotLocation + nDistance * tempVector;
end


function J.GetFaceTowardDistanceLocation(npcBot,nDistance)
	local npcBotLocation = npcBot:GetLocation();
	local tempRadians = npcBot:GetFacing() * math.pi / 180;
	local tempVector = Vector(math.cos(tempRadians),math.sin(tempRadians));
	return npcBotLocation + nDistance * tempVector;
end


local PrintTime = {};
function J.PrintMessage(nMessage,nNumber,n,nIntevel)
	if PrintTime[n] == nil then PrintTime[n] = nPrintTime end;
	if PrintTime[n] < DotaTime() - nIntevel
	then
		PrintTime[n] = DotaTime();	
		local preStr = string.gsub(GetBot():GetUnitName(),"npc_dota_","")..':';
		local suffix = string.gsub(tostring(nNumber),"npc_dota_","");
		print("++++++++++++++++++++++++++++++++++++＄＄＄＄＄＄＄＄＄START");
		print(preStr..nMessage..suffix);
		print("------------------------------------＄＄＄＄＄＄＄＄＄＄＄END");
	end
end


local PrTime = nPrintTime;
function J.Print(nMessage,nNumber)
	if PrTime < DotaTime() - 3.0
	then
		PrTime = DotaTime();	
		local preStr = string.gsub(GetBot():GetUnitName(),"npc_dota_","")..':';
		local suffix = string.gsub(tostring(nNumber),"npc_dota_","");
		print("++++++++++++++++++++++++++++++++++++＄＄＄＄＄＄＄＄＄START");
		print(preStr..nMessage..suffix);
		print("------------------------------------＄＄＄＄＄＄＄＄＄＄＄END");
	end
end


local PARTime = nDebugTime;
function J.PrintAndReport(nMessage,nNumber)
	if PARTime < DotaTime() - 5.0
	then
		PARTime = DotaTime();
		local pMessage = nMessage..string.gsub(tostring(nNumber),"npc_dota_","");
		print("++++++++++++++++++++++++++++++++++++＄＄＄＄＄＄＄＄＄START");
		print(GetBot():GetUnitName()..pMessage);
		print("------------------------------------＄＄＄＄＄＄＄＄＄＄＄END");
		GetBot():ActionImmediate_Chat(pMessage,true);
	end
end


local ReportTime = {};
function J.SetReportMessage(nMessage,nNumber,n)
	if ReportTime[n] == nil then ReportTime[n] = nDebugTime end;
	if ReportTime[n] < DotaTime() - 5.0
	then
		ReportTime[n] = DotaTime();	
		GetBot():ActionImmediate_Chat(nMessage..string.gsub(tostring(nNumber),"npc_dota_",""),true);
	end
end


local ReTime = nDebugTime;
function J.SetReport(nMessage,nNumber)
	if ReTime < DotaTime() - 5.0
	then
		ReTime = DotaTime();	
		GetBot():ActionImmediate_Chat(nMessage..string.gsub(tostring(nNumber),"npc_dota_",""),true);
	end
end


local PingTime = nDebugTime;
function J.SetPingLocation(bot,vLoc)
	if PingTime < DotaTime() - 2.0
	then
		PingTime = DotaTime();
		bot:ActionImmediate_Ping( vLoc.x, vLoc.y, false );
	end
end


local RePingTime = nDebugTime;
function J.SetReportAndPingLocation(vLoc,nMessage,nNumber)
	if RePingTime < DotaTime() - 2.0
	then
		local bot = GetBot();
		RePingTime = DotaTime();
		bot:ActionImmediate_Chat(nMessage..string.gsub(tostring(nNumber),"npc_dota_",""),true);
		bot:ActionImmediate_Ping( vLoc.x, vLoc.y, false );
	end
end

function J.SetReportMotive(bDebugFile, sMotive)
	
	if bDebugMode and bDebugTeam and bDebugFile and sMotive ~= nil
	then
		GetBot():ActionImmediate_Chat(sMotive,true);
	end

end


function J.GetCastLocation(npcBot,npcTarget,nCastRange,nRadius)

	local nDistance = GetUnitToUnitDistance(npcBot,npcTarget)

	if nDistance <= nCastRange
	then
	    return npcTarget:GetLocation();
	end
	
	if nDistance <= nCastRange + nRadius -120
	then
	    return J.GetUnitTowardDistanceLocation(npcBot,npcTarget,nCastRange);
	end
	
	if nDistance < nCastRange + nRadius -18
	   and ( ( J.IsDisabled(true, npcTarget) or npcTarget:GetCurrentMovementSpeed() <= 160) 
			or npcTarget:IsFacingLocation(npcBot:GetLocation(),45)
	        or (npcBot:IsFacingLocation(npcTarget:GetLocation(),45) and npcTarget:GetCurrentMovementSpeed() <= 220))
	then
		return J.GetUnitTowardDistanceLocation(npcBot,npcTarget,nCastRange +18);
	end
	
	if nDistance < nCastRange + nRadius + 28
		and npcTarget:IsFacingLocation(npcBot:GetLocation(),30)
		and npcBot:IsFacingLocation(npcTarget:GetLocation(),30)
		and npcTarget:GetMovementDirectionStability() > 0.95
		and npcTarget:GetCurrentMovementSpeed() >= 300 
	then
		return J.GetUnitTowardDistanceLocation(npcBot,npcTarget,nCastRange +18);
	end
    
	return nil;
end


function J.GetDelayCastLocation(npcBot, npcTarget, nCastRange, nRadius, nTime)

	local nFutureLoc = J.GetCorrectLoc(npcTarget,nTime);
	local nDistance = GetUnitToLocationDistance(npcBot,nFutureLoc);
	
	if nDistance > nCastRange + nRadius
	then
		return nil;
	end
	
	if nDistance > nCastRange - nRadius *0.62
	then
		return J.GetLocationTowardDistanceLocation(npcBot,nFutureLoc,nCastRange);
	end

	return J.GetLocationTowardDistanceLocation(npcBot,nFutureLoc,nDistance + nRadius *0.38);

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
		local nEnemyCount = J.GetEnemyCount(bot,1600);
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


function J.ShouldSwitchPTStat(bot,pt)
	
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
	local allys = bot:GetNearbyHeroes(800,false,BOT_MODE_NONE);
	for _,ally in pairs(allys) do
		if J.IsValid(ally)
		    and ally ~= bot 
			and ( J.GetProperTarget(ally) == unit 
					or ally:IsFacingLocation(unit:GetLocation(),12) )
		then
			return true;
		end
	end
	return false;
end


function J.IsAllysTarget(unit)
	local bot = GetBot();
	local allys = bot:GetNearbyHeroes(800,false,BOT_MODE_NONE);
	for _,ally in pairs(allys) do
		if  J.IsValid(ally)
			and ( J.GetProperTarget(ally) == unit 
					or ally:IsFacingLocation(unit:GetLocation(),12) )
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

    return not IsPlayerBot(nUnit:GetPlayerID())

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
	if GetUnitToLocationDistance(bot,loc) > bot:GetCurrentMovementSpeed() * 0.3
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


function J.GetModifierTime(bot,nMoName)
	
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


function J.IsTeamActivityCount(bot,nCount)
	local numPlayer =  GetTeamPlayers(GetTeam());
	for i = 1, #numPlayer
	do
		local member =  GetTeamMember(i);
		if member ~= nil and member:IsAlive()
		then
		    if J.GetAllyCount(member,1600) >= nCount
			then
				return true;
			end
		end
	end
	return false;
end


function J.GetSpecialModeAllies(nMode,nDistance,bot)

	local nAllies = {}
	local numPlayer =  GetTeamPlayers(GetTeam());
	for i = 1, #numPlayer
	do
		local member =  GetTeamMember(i);
		if member ~= nil and member:IsAlive()
		then
		    if member:GetActiveMode() == nMode
				and GetUnitToUnitDistance(member,bot) <= nDistance
			then
				table.insert(nAllies, member);
			end
		end
	end
	return nAllies;
end


function J.GetSpecialModeAlliesCount(nMode)
	local nAllies = J.GetSpecialModeAllies(nMode,99999,GetBot());
	return #nAllies;
end


function J.GetTeamFightLocation(bot)
	
	local targetLocation = nil;
	local numPlayer = GetTeamPlayers(GetTeam());
	
	for i = 1, #numPlayer
	do
		local member =  GetTeamMember(i);
		if member ~= nil and member:IsAlive() 
		   and J.IsInTeamFight(member,1500)
		   and J.GetEnemyCount(member,1300) >= 2
		then
			local nAllies = J.GetSpecialModeAllies(BOT_MODE_ATTACK,1400,member);
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
		   and J.IsInTeamFight(member,1200)
		   and J.GetEnemyCount(member,1400) >= 2
		then			
			nCount = J.GetSpecialModeAlliesCount(BOT_MODE_ATTACK);
			break;
		end
	end
	return nCount;
end


function J.GetCenterOfUnits(nUnits)
	
	if #nUnits == 0 then
		return Vector(0.0,0.0);
	end
	
	local sum = Vector(0.0,0.0);
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
	
	if num == 0 then return Vector(0.0,0.0) end;
	
	return sum/num;

end


function J.GetMostFarmLaneDesire()
	local nTopDesire = GetFarmLaneDesire(LANE_TOP);
	local nMidDesire = GetFarmLaneDesire(LANE_MID);
	local nBotDesire = GetFarmLaneDesire(LANE_BOT);
	
	if nTopDesire > nMidDesire and nTopDesire > nBotDesire
	then
		return LANE_TOP,nTopDesire;
	end
	
	if nBotDesire > nMidDesire and nBotDesire > nTopDesire
	then
		return LANE_BOT,nBotDesire;
	end
	
	return LANE_MID,nMidDesire;
end


function J.GetMostDefendLaneDesire()
	local nTopDesire = GetDefendLaneDesire(LANE_TOP);
	local nMidDesire = GetDefendLaneDesire(LANE_MID);
	local nBotDesire = GetDefendLaneDesire(LANE_BOT);
	
	if nTopDesire > nMidDesire and nTopDesire > nBotDesire
	then
		return LANE_TOP,nTopDesire;
	end
	
	if nBotDesire > nMidDesire and nBotDesire > nTopDesire
	then
		return LANE_BOT,nBotDesire;
	end
	
	return LANE_MID,nMidDesire;
end


function J.GetMostPushLaneDesire()
	local nTopDesire = GetPushLaneDesire(LANE_TOP);
	local nMidDesire = GetPushLaneDesire(LANE_MID);
	local nBotDesire = GetPushLaneDesire(LANE_BOT);
	
	if nTopDesire > nMidDesire and nTopDesire > nBotDesire
	then
		return LANE_TOP,nTopDesire;
	end
	
	if nBotDesire > nMidDesire and nBotDesire > nTopDesire
	then
		return LANE_BOT,nBotDesire;
	end
	
	return LANE_MID,nMidDesire;
end


function J.GetNearestLaneFrontLocation(nUnitLoc,bEnemy,fDeltaFromFront)

	local nTeam = GetTeam();
	if bEnemy then nTeam = GetOpposingTeam(); end
	
	local nTopLoc = GetLaneFrontLocation( nTeam, LANE_TOP, fDeltaFromFront );
	local nMidLoc = GetLaneFrontLocation( nTeam, LANE_MID, fDeltaFromFront );
	local nBotLoc = GetLaneFrontLocation( nTeam, LANE_BOT, fDeltaFromFront );
	
	local nTopDist = J.GetLocationToLocationDistance(nUnitLoc,nTopLoc);
	local nMidDist = J.GetLocationToLocationDistance(nUnitLoc,nMidLoc);
	local nBotDist = J.GetLocationToLocationDistance(nUnitLoc,nBotLoc);
	
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
			or botName == "npc_dota_hero_abaddon"
			or botName == "npc_dota_hero_vengefulspirit"
			or botName == "npc_dota_hero_drow_ranger"
			or botName == "npc_dota_hero_kunkka"
			or botName == "npc_dota_hero_luna"
			or botName == "npc_dota_hero_mars"
			or botName == "npc_dota_hero_medusa"
			or botName == "npc_dota_hero_nevermore"
			or botName == "npc_dota_hero_night_stalker"
			or botName == "npc_dota_hero_omniknight"
			or botName == "npc_dota_hero_phantom_assassin"
			or botName == "npc_dota_hero_queenofpain"
			or botName == "npc_dota_hero_razor"
			or botName == "npc_dota_hero_skeleton_king"
			or botName == "npc_dota_hero_sven"
			or botName == "npc_dota_hero_sniper"
			or botName == "npc_dota_hero_templar_assassin"
			or botName == "npc_dota_hero_terrorblade"		 
			or botName == "npc_dota_hero_viper" 
			or botName == "npc_dota_hero_weaver"
		 
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
			or botName == "npc_dota_hero_omniknight"
			or botName == "npc_dota_hero_silencer"
			or botName == "npc_dota_hero_shadow_shaman"
			or botName == "npc_dota_hero_skywrath_mage"
			or botName == "npc_dota_hero_warlock"		  
			or botName == "npc_dota_hero_zuus" 
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


function J.GetAllyList(bot,nRange)
	if nRange > 1600 then nRange = 1600 end
	local nRealAllies = {};
	local nCandidate = bot:GetNearbyHeroes(nRange,false,BOT_MODE_NONE);
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


function J.GetAllyCount(bot,nRange)
		
	local nRealAllies = J.GetAllyList(bot,nRange);
	
	return #nRealAllies;
	
end


function J.GetEnemyList(bot,nRange)
	if nRange > 1600 then nRange = 1600 end
	local nRealEnemys = {};
	local nCandidate = bot:GetNearbyHeroes(nRange,true,BOT_MODE_NONE);
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


function J.GetEnemyCount(bot,nRange)
		
	local nRealEnemys = J.GetEnemyList(bot,nRange);
	
	return #nRealEnemys;
	
end


function J.ConsiderTarget()

	local npcBot = GetBot();
	if not J.IsRunning(npcBot) 
	   or npcBot:HasModifier("modifier_item_hurricane_pike_range")
	then return  end
	
	local npcTarget = J.GetProperTarget(npcBot);
	if not J.IsValidHero(npcTarget) then return end

	local nAttackRange = npcBot:GetAttackRange() + 69;	
	if nAttackRange > 1600 then nAttackRange = 1600 end
	if nAttackRange < 200  then nAttackRange = 350  end
	
	local nInAttackRangeWeakestEnemyHero = J.GetAttackableWeakestUnit(true, true, nAttackRange, npcBot);

	if  J.IsValidHero(nInAttackRangeWeakestEnemyHero)
		and ( GetUnitToUnitDistance(npcTarget,npcBot) >  nAttackRange or J.HasForbiddenModifier(npcTarget) )		
	then
		npcBot:SetTarget(nInAttackRangeWeakestEnemyHero);
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


function J.IsLocHaveTower(nRange,bEnemy,nLoc)

	local nTeam = GetTeam();
	if bEnemy then nTeam = GetOpposingTeam(); end
	
	for i = 0, 10  
	do
		local tower = GetTower(nTeam, i);
		if tower ~= nil and GetUnitToLocationDistance(tower,nLoc) <= nRange 
		then
			 return true;
		end
	end
	
	return false;

end


function J.GetNearbyLocationToTp(nLoc)
	local nTeam = GetTeam();
	local nFountain = J.GetTeamFountain();
	
	if J.GetLocationToLocationDistance(nLoc,nFountain) <= 2400
	then
		return nLoc;
	end
	
	local targetTower = nil;
	local minDist     = 99999
	for i=0, 10, 1 do
		local tower = GetTower(nTeam, i);
		if tower ~= nil 
		   and GetUnitToLocationDistance(tower,nLoc) < minDist
		then
			 targetTower = tower;
			 minDist     = GetUnitToLocationDistance(tower,nLoc);
		end
	end
	
	local shrines = {
		 SHRINE_JUNGLE_1,
		 SHRINE_JUNGLE_2 
	}
	for _,s in pairs(shrines) do
		local shrine = GetShrine(GetTeam(), s);
		if  shrine ~= nil and shrine:GetHealth()/shrine:GetMaxHealth() > 0.99
		    and GetUnitToLocationDistance(shrine,nLoc) < minDist
		then
			 targetTower = shrine;
			 minDist     = GetUnitToLocationDistance(shrine,nLoc);
		end	
	end	

	if targetTower ~= nil
	then		
		return J.GetLocationTowardDistanceLocation(targetTower,nLoc,600);
	end
	
	return nFountain;
end


function J.IsEnemyFacingUnit(nRange,bot,nDegrees)
	
	local nLoc = bot:GetLocation();
	
	if nRange > 1600 then nRange = 1600; end
	local nEnemyHeroes = bot:GetNearbyHeroes( nRange, true, BOT_MODE_NONE );
	for _,enemy in pairs(nEnemyHeroes)
	do
		if J.IsValid(enemy)
		   and enemy:IsFacingLocation(nLoc,nDegrees)
		then
			return true;
		end
	end

	return false;
end


function J.IsAllyFacingUnit(nRange,bot,nDegrees)
	
	local nLoc = bot:GetLocation();
	local numPlayer = GetTeamPlayers(GetTeam());
	for i = 1, #numPlayer
	do
		local member = GetTeamMember(i);
		if member ~= nil
			and member ~= bot
			and GetUnitToUnitDistance(member,bot) <= nRange
			and member:IsFacingLocation(nLoc,nDegrees)
		then
			return true;
		end
	end

	return false;
end


function J.IsEnemyTargetUnit(nRange,nUnit)
	
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
      
   if GetUnitToUnitDistance(bot,AllyAcient) + 768 < GetUnitToUnitDistance(bot,EnemyAcient)
   then
		return true;
   end
      
   return false;
end


function J.IsInEnemyArea(bot)
   
   local AllyAcient = GetAncient(GetTeam());
   local EnemyAcient = GetAncient(GetOpposingTeam());
      
   if GetUnitToUnitDistance(bot,EnemyAcient) + 1280 < GetUnitToUnitDistance(bot,AllyAcient)
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
function J.HasNotActionLast(nCD,nNumber)
	
	if LastActionTime[nNumber] == nil then LastActionTime[nNumber] = -90; end
	
	if DotaTime() > LastActionTime[nNumber] + nCD
	then
		LastActionTime[nNumber] = DotaTime();
		return true;
	end
	
	return false;

end


function J.GetCastPoint(bot,unit,nPointTime,nProjectSpeed)	
				
	local nDist = GetUnitToUnitDistance(bot,unit);
	
	local nDistTime = 0;
	if nProjectSpeed ~= 0 then nDistTime = nDist/nProjectSpeed; end
	
	return nPointTime + nDistTime;
		
end


function J.CanBreakTeleport(bot,unit,nPointTime,nProjectSpeed)	

	if unit:HasModifier("modifier_teleporting") 
	then
		return J.GetCastPoint(bot,unit,nPointTime,nProjectSpeed) < J.GetModifierTime(unit,"modifier_teleporting")
	end
	
	return true;
end


function J.GetMagicToPhysicalDamage(bot,nUnit,nMagicDamage)

	local realMagicDamage = nUnit:GetActualIncomingDamage(nMagicDamage,DAMAGE_TYPE_MAGICAL);
	
	local basePhysicalDamage = 100 * bot:GetAttackCombatProficiency(nUnit);
	local nTDamage = nUnit:GetActualIncomingDamage(basePhysicalDamage,DAMAGE_TYPE_PHYSICAL)/100;

	return realMagicDamage / nTDamage ;

end



return J

--[[
CanAbilityBeUpgraded( ) : bool
CanBeDisassembled( ) : bool
GetAOERadius( ) : int
GetAbilityDamage( ) : int
GetAutoCastState( ) : bool
GetBehavior( ) : int
GetCastPoint( ) : float
GetCastRange( ) : int
GetCaster( ) : handle
GetChannelTime( ) : float
GetChannelledManaCostPerSecond( ) : int
GetCooldown( ) : float
GetCooldownTimeRemaining( ) : float
GetCurrentCharges( ) : int
GetDamageType( ) : int
GetDuration( ) : float
GetEstimatedDamageToTarget( handle hTarget, float fDuration, int nDamageTypes ) : int
GetHeroLevelRequiredToUpgrade( ) : int
GetInitialCharges( ) : int
GetLevel( ) : int
GetManaCost( ) : int
GetMaxLevel( ) : int
GetName( ) : cstring
GetPowerTreadsStat( ) : int
GetSecondaryCharges( ) : int
GetSpecialValueFloat( cstring pszKey ) : float
GetSpecialValueInt( cstring pszKey ) : int
GetTargetFlags( ) : int
GetTargetTeam( ) : int
GetTargetType( ) : int
GetToggleState( ) : bool
IsActivated( ) : bool
IsChanneling( ) : bool
IsCombineLocked( ) : bool
IsCooldownReady( ) : bool
IsFullyCastable( ) : bool
IsHidden( ) : bool
IsInAbilityPhase( ) : bool
IsItem( ) : bool
IsOwnersManaEnough( ) : bool
IsPassive( ) : bool
IsStealable( ) : bool
IsStolen( ) : bool
IsTalent( ) : bool
IsToggle( ) : bool
IsTrained( ) : bool
IsUltimate( ) : bool
ProcsMagicStick( ) : bool
ToggleAutoCast( ) : void
CDOTA_Bot_Script
ActionImmediate_Buyback( ) : void
ActionImmediate_Chat( cstring pszMessage, bool bAllChat ) : void
ActionImmediate_Courier( handle hCourier, int eAction ) : bool
ActionImmediate_DisassembleItem( handle hItem ) : void
ActionImmediate_Glyph( ) : void
ActionImmediate_LevelAbility( cstring pszAbilityName ) : void
ActionImmediate_Ping( float x, float y, bool bNormalPing ) : void
ActionImmediate_PurchaseItem( cstring pszItemName ) :
ActionImmediate_SellItem( handle hItem ) : void
ActionImmediate_SetItemCombineLock( handle hItem, bool bLocked ) : void
ActionImmediate_SwapItems( int nSlot1, int nSlot2 ) : void
ActionPush_AttackMove( vector location ) : void
ActionPush_AttackUnit( handle hTarget, bool bOnce ) : void
ActionPush_Delay( float fDelay ) : void
ActionPush_DropItem( handle hItem, vector location ) : void
ActionPush_MoveDirectly( vector location ) : void
ActionPush_MovePath( handle hPathTable ) : void
ActionPush_MoveToLocation( vector location ) : void
ActionPush_MoveToUnit( handle hTarget ) : void
ActionPush_PickUpItem( handle hItem ) : void
ActionPush_PickUpRune( int nRune ) : void
ActionPush_UseAbility( handle hAbility ) : void
ActionPush_UseAbilityOnEntity( handle hAbility, handle hTarget ) : void
ActionPush_UseAbilityOnLocation( handle hAbility, vector location ) : void
ActionPush_UseAbilityOnTree( handle hAbility, int iTree ) : void
ActionPush_UseShrine( handle hShrine ) : void
ActionQueue_AttackMove( vector location ) : void
ActionQueue_AttackUnit( handle hTarget, bool bOnce ) : void
ActionQueue_Delay( float fDelay ) : void
ActionQueue_DropItem( handle hItem, vector location ) : void
ActionQueue_MoveDirectly( vector location ) : void
ActionQueue_MovePath( handle hPathTable ) : void
ActionQueue_MoveToLocation( vector location ) : void
ActionQueue_MoveToUnit( handle hTarget ) : void
ActionQueue_PickUpItem( handle hItem ) : void
ActionQueue_PickUpRune( int nRune ) : void
ActionQueue_UseAbility( handle hAbility ) : void
ActionQueue_UseAbilityOnEntity( handle hAbility, handle hTarget ) : void
ActionQueue_UseAbilityOnLocation( handle hAbility, vector location ) : void
ActionQueue_UseAbilityOnTree( handle hAbility, int iTree ) : void
ActionQueue_UseShrine( handle hShrine ) : void
Action_AttackMove( vector location ) : void
Action_AttackUnit( handle hTarget, bool bOnce ) : void
Action_ClearActions( bool bStop ) : void
Action_Delay( float fDelay ) : void
Action_DropItem( handle hItem, vector location ) : void
Action_MoveDirectly( vector location ) : void
Action_MovePath( handle hPathTable ) : void
Action_MoveToLocation( vector location ) : void
Action_MoveToUnit( handle hTarget ) : void
Action_PickUpItem( handle hItem ) : void
Action_PickUpRune( int nRune ) : void
Action_UseAbility( handle hAbility ) : void
Action_UseAbilityOnEntity( handle hAbility, handle hTarget ) : void
Action_UseAbilityOnLocation( handle hAbility, vector location ) : void
Action_UseAbilityOnTree( handle hAbility, int iTree ) : void
Action_UseShrine( handle hShrine ) : void
CanBeSeen( ) : bool
DistanceFromFountain( ) : int
DistanceFromSecretShop( ) : int
DistanceFromSideShop( ) : int
FindAoELocation( bool bEnemies, bool bHeroes, vector vBaseLocation, int nMaxDistanceFromBase, int nRadius, float fTimeInFuture, int nMaxHealth ) : variant
FindItemSlot( cstring pszItemName ) : int
GetAbilityByName( cstring pszAbilityName ) : handle
GetAbilityInSlot( int iAbility ) : handle
GetAbilityPoints( ) : int
GetAbilityTarget( ) : handle
GetAcquisitionRange( ) : int
GetActiveMode( ) : int
GetActiveModeDesire( ) : float
GetActualIncomingDamage( int nDamage, int eDamageType ) : int
GetAnimActivity( ) : int
GetAnimCycle( ) : float
GetArmor( ) : float
GetAssignedLane( ) : int
GetAttackCombatProficiency( handle hTarget ) : float
GetAttackDamage( ) : float
GetAttackPoint( ) : float
GetAttackProjectileSpeed( ) : int
GetAttackRange( ) : int
GetAttackSpeed( ) : float
GetAttackTarget( ) : handle
GetAttributeValue( int nAttribute ) : int
GetBaseDamage( ) : float
GetBaseDamageVariance( ) : float
GetBaseHealthRegen( ) : float
GetBaseManaRegen( ) : float
GetBaseMovementSpeed( ) : int
GetBoundingRadius( ) : float
GetBountyGoldMax( ) : int
GetBountyGoldMin( ) : int
GetBountyXP( ) : int
GetBuybackCooldown( ) : float
GetBuybackCost( ) : int
GetCourierValue( ) : int
GetCurrentActionType( ) : int
GetCurrentActiveAbility( ) : handle
GetCurrentMovementSpeed( ) : int
GetCurrentVisionRange( ) : int
GetDayTimeVisionRange( ) : int
GetDefendCombatProficiency( handle hAttacker ) : float
GetDenies( ) : int
GetDifficulty( ) : int
GetEstimatedDamageToTarget( bool bCurrentlyAvailable, handle hTarget, float fDuration, int nDamageTypes ) : int
GetEvasion( ) : float
GetExtrapolatedLocation( float fDelay ) : vector
GetFacing( ) : int
GetGold( ) : int
GetGroundHeight( ) : int
GetHealth( ) : int
GetHealthRegen( ) : float
GetHealthRegenPerStr( ) : float
GetIncomingTrackingProjectiles( ) : variant
GetItemInSlot( int nSlot ) : handle
GetItemSlotType( int nSlot ) : int
GetLastAttackTime( ) : float
GetLastHits( ) : int
GetLevel( ) : int
GetLocation( ) : vector
GetMagicResist( ) : float
GetMana( ) : int
GetManaRegen( ) : float
GetManaRegenPerInt( ) : float
GetMaxHealth( ) : int
GetMaxMana( ) : int
GetModifierAuxiliaryUnits( int nModifier ) : variant
GetModifierByName( cstring pszModifierName ) : int
GetModifierList( ) : variant
GetModifierName( int nModifier ) : cstring
GetModifierRemainingDuration( int nModifier ) : float
GetModifierStackCount( int nModifier ) : int
GetMostRecentPing( ) : variant
GetMovementDirectionStability( ) : float
GetNearbyBarracks( int nRadius, bool bEnemies ) : variant
GetNearbyCreeps( int nRadius, bool bEnemies ) : variant
GetNearbyFillers( int nRadius, bool bEnemies ) : variant
GetNearbyHeroes( int nRadius, bool bEnemies, int eBotMode ) : variant
GetNearbyLaneCreeps( int nRadius, bool bEnemies ) : variant
GetNearbyNeutralCreeps( int nRadius ) : variant
GetNearbyShrines( int nRadius, bool bEnemies ) : variant
GetNearbyTowers( int nRadius, bool bEnemies ) : variant
GetNearbyTrees( int nRadius ) : variant
GetNetWorth( ) : int
GetNextItemPurchaseValue( ) : int
GetNightTimeVisionRange( ) : int
GetOffensivePower( ) : float
GetPlayerID( ) : int
GetPrimaryAttribute( ) : int
GetQueuedActionType( int nQueuedAction ) : int
GetRawOffensivePower( ) : float
GetRemainingLifespan( ) : float
GetRespawnTime( ) : float
GetSecondsPerAttack( ) : float
GetSlowDuration( bool bCurrentlyAvailable ) : float
GetSpellAmp( ) : float
GetStashValue( ) : int
GetStunDuration( bool bCurrentlyAvailable ) : float
GetTalent( int nLevel, int nSide ) : handle
GetTarget( ) : handle
GetTeam( ) : int
GetUnitName( ) : cstring
GetVelocity( ) : vector
GetXPNeededToLevel( ) : int
HasBlink( bool bCurrentlyAvailable ) : bool
HasBuyback( ) : bool
HasInvisibility( bool bCurrentlyAvailable ) : bool
HasMinistunOnAttack( ) : bool
HasModifier( cstring pszModifierName ) : bool
HasScepter( ) : bool
HasSilence( bool bCurrentlyAvailable ) : bool
IsAlive( ) : bool
IsAncientCreep( ) : bool
IsAttackImmune( ) : bool
IsBlind( ) : bool
IsBlockDisabled( ) : bool
IsBot( ) : bool
IsBuilding( ) : bool
IsCastingAbility( ) : bool
IsChanneling( ) : bool
IsCourier( ) : bool
IsCreep( ) : bool
IsDisarmed( ) : bool
IsDominated( ) : bool
IsEvadeDisabled( ) : bool
IsFacingLocation( vector vLocation, int nDegrees ) : bool
IsFort( ) : bool
IsHero( ) : bool
IsHexed( ) : bool
IsIllusion( ) : bool
IsInvisible( ) : bool
IsInvulnerable( ) : bool
IsMagicImmune( ) : bool
IsMinion( ) : bool
IsMuted( ) : bool
IsNightmared( ) : bool
IsRooted( ) : bool
IsSilenced( ) : bool
IsSpeciallyDeniable( ) : bool
IsStunned( ) : bool
IsTower( ) : bool
IsUnableToMiss( ) : bool
IsUsingAbility( ) : bool
NumModifiers( ) : int
NumQueuedActions( ) : int
SetNextItemPurchaseValue( int nGold ) : void
SetTarget( handle ) : void
TimeSinceDamagedByAnyHero( ) : float
TimeSinceDamagedByCreep( ) : float
TimeSinceDamagedByHero( handle hHero ) : float
TimeSinceDamagedByPlayer( int nPlayerID ) : float
TimeSinceDamagedByTower( ) : float
UsingItemBreaksInvisibility( ) : bool
WasRecentlyDamagedByAnyHero( float fTime ) : bool
WasRecentlyDamagedByCreep( float fTime ) : bool
WasRecentlyDamagedByHero( handle hHero, float fTime ) : bool
WasRecentlyDamagedByPlayer( int nPlayerID, float fTime ) : bool
WasRecentlyDamagedByTower( float fTime ) : bool
CDOTA_TeamCommander
AddAvoidanceZone( vector, float ) : int
AddConditionalAvoidanceZone( vector, handle ) : int
CMBanHero( cstring ) : void
CMPickHero( cstring ) : void
Clamp( float, float, float ) : float
CreateHTTPRequest( cstring ) : handle
CreateRemoteHTTPRequest( cstring ) : handle
DebugDrawCircle( vector, float, int, int, int ) : void
DebugDrawLine( vector, vector, int, int, int ) : void
DebugDrawText( float, float, cstring, int, int, int ) : void
DebugPause( ) : void
DotaTime( ) : float
GameTime( ) : float
GeneratePath( vector, vector, handle, handle ) : int
GetAllTrees( ) : variant
GetAmountAlongLane( int, vector ) : variant
GetAncient( int ) : handle
GetAvoidanceZones( ) : variant
GetBarracks( int, int ) : handle
GetBot( ) : handle
GetBotAbilityByHandle( uint ) : handle
GetBotByHandle( uint ) : handle
GetCMCaptain( ) : int
GetCMPhaseTimeRemaining( ) : float
GetCourier( int ) : handle
GetCourierState( handle ) : int
GetDefendLaneDesire( int ) : float
GetDroppedItemList( ) : variant
GetFarmLaneDesire( int ) : float
GetGameMode( ) : int
GetGameState( ) : int
GetGameStateTimeRemaining( ) : float
GetGlyphCooldown( ) : float
GetHeightLevel( vector ) : int
GetHeroAssists( int ) : int
GetHeroDeaths( int ) : int
GetHeroKills( int ) : int
GetHeroLastSeenInfo( int ) : variant
GetHeroLevel( int ) : int
GetHeroPickState( ) : int
GetIncomingTeleports( ) : variant
GetItemComponents( cstring ) : variant
GetItemCost( cstring ) : int
GetItemStockCount( cstring ) : int
GetLaneFrontAmount( int, int, bool ) : float
GetLaneFrontLocation( int, int, float ) : vector
GetLinearProjectileByHandle( int ) : variant
GetLinearProjectiles( ) : variant
GetLocationAlongLane( int, float ) : vector
GetNeutralSpawners( ) : variant
GetNumCouriers( ) : int
GetOpposingTeam( ) : int
GetPushLaneDesire( int ) : float
GetRoamDesire( ) : float
GetRoamTarget( ) : handle
GetRoshanDesire( ) : float
GetRoshanKillTime( ) : float
GetRuneSpawnLocation( int ) : vector
GetRuneStatus( int ) :
GetRuneTimeSinceSeen( int ) : float
GetRuneType( int ) : int
GetScriptDirectory( ) : cstring
GetSelectedHeroName( int ) : cstring
GetShopLocation( int, int ) : vector
GetShrine( int, int ) : handle
GetShrineCooldown( handle ) : float
GetTeam( ) : int
GetTeamForPlayer( int ) : int
GetTeamMember( int ) : handle
GetTeamPlayers( int ) : variant
GetTimeOfDay( ) : float
GetTower( int, int ) : handle
GetTowerAttackTarget( int, int ) : handle
GetTreeLocation( int ) : vector
GetUnitList( int ) : variant
GetUnitPotentialValue( handle, vector, float ) : int
GetUnitToLocationDistance( handle, vector ) : float
GetUnitToLocationDistanceSqr( handle, vector ) : float
GetUnitToUnitDistance( handle, handle ) : float
GetUnitToUnitDistanceSqr( handle, handle ) : float
GetWorldBounds( ) : variant
InstallCastCallback( int, handle ) : void
InstallChatCallback( handle ) : void
InstallCourierDeathCallback( handle ) : void
InstallDamageCallback( int, handle ) : void
InstallRoshanDeathCallback( handle ) : void
IsCMBannedHero( cstring ) : bool
IsCMPickedHero( int, cstring ) : bool
IsCourierAvailable( ) : bool
IsFlyingCourier( handle ) : bool
IsHeroAlive( int ) : bool
IsInCMBanPhase( ) : bool
IsInCMPickPhase( ) : bool
IsItemPurchasedFromSecretShop( cstring ) : bool
IsItemPurchasedFromSideShop( cstring ) : bool
IsLocationPassable( vector ) : bool
IsLocationVisible( vector ) : bool
IsPlayerBot( int ) : bool
IsPlayerInHeroSelectionControl( int ) : bool
IsRadiusVisible( vector, float ) : bool
IsShrineHealing( handle ) : bool
IsTeamPlayer( int ) : bool
Max( float, float ) : float
Min( float, float ) : float
PointToLineDistance( vector, vector, vector ) : variant
RandomFloat( float, float ) : float
RandomInt( int, int ) : int
RandomVector( float ) : vector
RealTime( ) : float
RemapVal( float, float, float, float, float ) : float
RemapValClamped( float, float, float, float, float ) : float
RemoveAvoidanceZone( int ) : void
RollPercentage( int ) : bool
SelectHero( int, cstring ) : void
SetCMCaptain( int ) : void

句柄handle = h, 坐标矢量vector = v, 布尔值bool = b,  字符串string = s, 
一般的数量normal = n, 特殊的小数float = f, 全局命名空间变量goble = g, 未确定类型的单位unknow = u,
表名以表内容类型....List命名,即 'sBotList' 表示内容为英雄名的线性表,非线性表或表中表table = t,
----------------------------------------------------------------------------------------------------
-- Constants - Bot Modes 常量-机器人模式
----------------------------------------------------------------------------------------------------
BOT_MODE_NONE
	无模式状态
BOT_MODE_LANING
	对线模式
BOT_MODE_ATTACK
	攻击模式
BOT_MODE_ROAM
	游走模式
BOT_MODE_RETREAT
	撤退模式
BOT_MODE_RUNE
	撤退模式
BOT_MODE_SECRET_SHOP
	神秘商店购物模式
BOT_MODE_SIDE_SHOP
	边路商店购物模式
BOT_MODE_PUSH_TOWER_TOP
	推上路塔模式
BOT_MODE_PUSH_TOWER_MID
	推中路塔模式
BOT_MODE_PUSH_TOWER_BOT
	推下路塔模式
BOT_MODE_DEFEND_TOWER_TOP
	防守上路塔模式
BOT_MODE_DEFEND_TOWER_MID
	防守中路塔模式
BOT_MODE_DEFEND_TOWER_BOT
	防守下路塔模式
BOT_MODE_ASSEMBLE
	集合模式
BOT_MODE_TEAM_ROAM
	团队集体游走模式
BOT_MODE_FARM
	打钱发育模式
BOT_MODE_DEFEND_ALLY
	保护队友模式
BOT_MODE_EVASIVE_MANEUVERS
	闪避技能模式
BOT_MODE_ROSHAN
	打肉山模式
BOT_MODE_ITEM
	扔或捡物品模式
BOT_MODE_WARD
	插眼模式
----------------------------------------------------------------------------------------------------
-- Constants - Action Desires 常量-行为欲望值
These can be useful for making sure all action desires are using a common language for talking about their desire.
BOT_ACTION_DESIRE_NONE - 0.0
BOT_ACTION_DESIRE_VERYLOW - 0.1
BOT_ACTION_DESIRE_LOW - 0.25
BOT_ACTION_DESIRE_MODERATE - 0.5
BOT_ACTION_DESIRE_HIGH - 0.75
BOT_ACTION_DESIRE_VERYHIGH - 0.9
BOT_ACTION_DESIRE_ABSOLUTE - 1.0
----------------------------------------------------------------------------------------------------
-- Constants - Mode Desires 常量-模式欲望值
----------------------------------------------------------------------------------------------------
These can be useful for making sure all mode desires as using a common language for talking about their desire.
BOT_MODE_DESIRE_NONE - 0
BOT_MODE_DESIRE_VERYLOW - 0.1
BOT_MODE_DESIRE_LOW - 0.25
BOT_MODE_DESIRE_MODERATE - 0.5
BOT_MODE_DESIRE_HIGH - 0.75
BOT_MODE_DESIRE_VERYHIGH - 0.9
BOT_MODE_DESIRE_ABSOLUTE - 1.0
----------------------------------------------------------------------------------------------------
-- Constants - Damage Types 常量-伤害类型
----------------------------------------------------------------------------------------------------
DAMAGE_TYPE_PHYSICAL
	物理
DAMAGE_TYPE_MAGICAL
	魔法
DAMAGE_TYPE_PURE
	纯粹
DAMAGE_TYPE_ALL
	全伤害类型
----------------------------------------------------------------------------------------------------
-- Constants - Unit Types 常量-单位类型
----------------------------------------------------------------------------------------------------
UNIT_LIST_ALL
	所有单位
UNIT_LIST_ALLIES
	友方单位
UNIT_LIST_ALLIED_HEROES
	友方英雄单位
UNIT_LIST_ALLIED_CREEPS
	友方小兵生物单位
UNIT_LIST_ALLIED_WARDS
	友方守卫单位
UNIT_LIST_ALLIED_BUILDINGS
	友方建筑单位
UNIT_LIST_ENEMIES
	敌方单位
UNIT_LIST_ENEMY_HEROES
	敌方英雄单位
UNIT_LIST_ENEMY_CREEPS
	敌方小兵生物单位
UNIT_LIST_ENEMY_WARDS
	敌方守卫单位
UNIT_LIST_NEUTRAL_CREEPS
	中立野怪单位
UNIT_LIST_ENEMY_BUILDINGS
	敌方建筑单位
----------------------------------------------------------------------------------------------------
-- Constants - Difficulties 常量-游戏难度
----------------------------------------------------------------------------------------------------
DIFFICULTY_INVALID
	无
DIFFICULTY_PASSIVE
	消极
DIFFICULTY_EASY
	容易
DIFFICULTY_MEDIUM
	中等
DIFFICULTY_HARD
	困难
DIFFICULTY_UNFAIR
	疯狂
----------------------------------------------------------------------------------------------------
-- Constants - Attribute Types 常量-英雄三维属性类型
----------------------------------------------------------------------------------------------------
ATTRIBUTE_INVALID
	无效属性
ATTRIBUTE_STRENGTH
	力量属性
ATTRIBUTE_AGILITY
	敏捷属性
ATTRIBUTE_INTELLECT
	智力属性
----------------------------------------------------------------------------------------------------
-- Constants - Item Purchase Results 常量-物品购买结果
----------------------------------------------------------------------------------------------------
PURCHASE_ITEM_SUCCESS
	购买成功
PURCHASE_ITEM_OUT_OF_STOCK
	库存不够
PURCHASE_ITEM_DISALLOWED_ITEM
	失效的物品
PURCHASE_ITEM_INSUFFICIENT_GOLD
	金钱不够
PURCHASE_ITEM_NOT_AT_HOME_SHOP
	此物品不在主商店出售
PURCHASE_ITEM_NOT_AT_SIDE_SHOP
	此物品不在边路商店出售
PURCHASE_ITEM_NOT_AT_SECRET_SHOP
	此物品不在神秘商店出售
PURCHASE_ITEM_INVALID_ITEM_NAME
	无效的物品名
----------------------------------------------------------------------------------------------------
-- Constants - Game Modes 常量-游戏模式
----------------------------------------------------------------------------------------------------
GAMEMODE_NONE
	无游戏模式
GAMEMODE_AP
	全英雄选择
GAMEMODE_CM
	队长模式
GAMEMODE_RD
	随机征召
GAMEMODE_SD
	单一征召
GAMEMODE_AR
	全英雄随机
GAMEMODE_REVERSE_CM
	反队长模式
GAMEMODE_MO
	单中模式
GAMEMODE_CD
	队长征召
GAMEMODE_ABILITY_DRAFT
	技能征召
GAMEMODE_ARDM
	全英雄随机死亡竞赛
GAMEMODE_1V1MID
	中路单挑
GAMEMODE_ALL_DRAFT (aka Ranked All Pick)
	？
----------------------------------------------------------------------------------------------------
-- Constants - Teams 常量-所在团队
----------------------------------------------------------------------------------------------------
TEAM_RADIANT
	天辉
TEAM_DIRE
	夜魇
TEAM_NEUTRAL
	中立
TEAM_NONE
	无团队
----------------------------------------------------------------------------------------------------
-- Constants - Lanes 常量-所在兵线（分路）
----------------------------------------------------------------------------------------------------
LANE_NONE
	无分路
LANE_TOP
	上路（天辉劣势路或夜魇优势路）
LANE_MID
	中路
LANE_BOT
	下路（天辉优势路或夜魇劣势路）
----------------------------------------------------------------------------------------------------
-- Constants - Game States 常量-游戏当前状态
----------------------------------------------------------------------------------------------------
GAME_STATE_INIT
	游戏初始化
GAME_STATE_WAIT_FOR_PLAYERS_TO_LOAD
	等待玩家载入
GAME_STATE_HERO_SELECTION
	英雄选择
GAME_STATE_STRATEGY_TIME
	决策时间
GAME_STATE_PRE_GAME
	准备阶段
GAME_STATE_GAME_IN_PROGRESS
	正在游戏
GAME_STATE_POST_GAME
	赛后阶段
GAME_STATE_DISCONNECT
	失去连接
GAME_STATE_TEAM_SHOWCASE
	？
GAME_STATE_CUSTOM_GAME_SETUP
	？
GAME_STATE_WAIT_FOR_MAP_TO_LOAD
	等待地图载入
GAME_STATE_LAST
	？
----------------------------------------------------------------------------------------------------
-- Constants - Hero Pick States 常量-英雄选择当前状态
----------------------------------------------------------------------------------------------------
HEROPICK_STATE_NONE
	无
HEROPICK_STATE_AP_SELECT
	全英雄选择-英雄选择
HEROPICK_STATE_SD_SELECT
	单一征召-英雄选择
HEROPICK_STATE_CM_INTRO
	队长模式-？
HEROPICK_STATE_CM_CAPTAINPICK
	队长模式-成为队长
HEROPICK_STATE_CM_BAN1
	队长模式-1号BAN位
HEROPICK_STATE_CM_BAN2
	队长模式-2号BAN位
HEROPICK_STATE_CM_BAN3
	队长模式-3号BAN位
HEROPICK_STATE_CM_BAN4
	队长模式-4号BAN位
HEROPICK_STATE_CM_BAN5
	队长模式-5号BAN位
HEROPICK_STATE_CM_BAN6
	队长模式-6号BAN位
HEROPICK_STATE_CM_BAN7
	队长模式-7号BAN位
HEROPICK_STATE_CM_BAN8
	队长模式-8号BAN位
HEROPICK_STATE_CM_BAN9
	队长模式-9号BAN位
HEROPICK_STATE_CM_BAN10
	队长模式-10号BAN位
HEROPICK_STATE_CM_SELECT1
	队长模式-1号选位
HEROPICK_STATE_CM_SELECT2
	队长模式-2号选位
HEROPICK_STATE_CM_SELECT3
	队长模式-3号选位
HEROPICK_STATE_CM_SELECT4
	队长模式-4号选位
HEROPICK_STATE_CM_SELECT5
	队长模式-5号选位
HEROPICK_STATE_CM_SELECT6
	队长模式-6号选位
HEROPICK_STATE_CM_SELECT7
	队长模式-7号选位
HEROPICK_STATE_CM_SELECT8
	队长模式-8号选位
HEROPICK_STATE_CM_SELECT9
	队长模式-9号选位
HEROPICK_STATE_CM_SELECT10
	队长模式-10号选位
HEROPICK_STATE_CM_PICK
	队长模式-英雄选择
HEROPICK_STATE_AR_SELECT
	随机征召-英雄选择
HEROPICK_STATE_MO_SELECT
	单中模式-英雄选择
HEROPICK_STATE_FH_SELECT
	？-英雄选择
HEROPICK_STATE_CD_INTRO
	队长征召-？
HEROPICK_STATE_CD_CAPTAINPICK
	队长征召-成为队长
HEROPICK_STATE_CD_BAN1
	队长征召-1号BAN位
HEROPICK_STATE_CD_BAN2
	队长征召-2号BAN位
HEROPICK_STATE_CD_BAN3
	队长征召-3号BAN位
HEROPICK_STATE_CD_BAN4
	队长征召-4号BAN位
HEROPICK_STATE_CD_BAN5
	队长征召-5号BAN位
HEROPICK_STATE_CD_BAN6
	队长征召-6号BAN位
HEROPICK_STATE_CD_SELECT1
	队长征召-1号选位
HEROPICK_STATE_CD_SELECT2
	队长征召-2号选位
HEROPICK_STATE_CD_SELECT3
	队长征召-3号选位
HEROPICK_STATE_CD_SELECT4
	队长征召-4号选位
HEROPICK_STATE_CD_SELECT5
	队长征召-5号选位
HEROPICK_STATE_CD_SELECT6
	队长征召-6号选位
HEROPICK_STATE_CD_SELECT7
	队长征召-7号选位
HEROPICK_STATE_CD_SELECT8
	队长征召-8号选位
HEROPICK_STATE_CD_SELECT9
	队长征召-9号选位
HEROPICK_STATE_CD_SELECT10
	队长征召-10号选位
HEROPICK_STATE_CD_PICK
	队长征召-英雄选择
HEROPICK_STATE_BD_SELECT
	队长征召-？
HERO_PICK_STATE_ABILITY_DRAFT_SELECT
	技能征召-技能选择
HERO_PICK_STATE_ARDM_SELECT
	死亡随机-英雄选择
HEROPICK_STATE_ALL_DRAFT_SELECT
	？-英雄选择
HERO_PICK_STATE_CUSTOMGAME_SELECT
	自定义游戏-英雄选择
HEROPICK_STATE_SELECT_PENALTY
	英雄选择-惩罚时间
----------------------------------------------------------------------------------------------------
-- Constants - Rune Types 常量-神符类型
----------------------------------------------------------------------------------------------------
RUNE_INVALID (used as return value)
	无效神符（默认返回值）
RUNE_DOUBLEDAMAGE
	双倍伤害
RUNE_HASTE
	极速神符
RUNE_ILLUSION
	幻象神符
RUNE_INVISIBILITY
	隐身神符
RUNE_REGENERATION
	回复神符
RUNE_BOUNTY
	赏金神符
RUNE_ARCANE
	奥术神符
----------------------------------------------------------------------------------------------------
-- Constants - Rune Status 常量-神符状态
----------------------------------------------------------------------------------------------------
RUNE_STATUS_UNKNOWN
	未知状态
RUNE_STATUS_AVAILABLE
	神符可获取
RUNE_STATUS_MISSING
	神符消失
----------------------------------------------------------------------------------------------------
-- Constants - Rune Locations 常量-神符分布位置
----------------------------------------------------------------------------------------------------
RUNE_POWERUP_1
	上路强化神符
RUNE_POWERUP_2
	下路强化神符
RUNE_BOUNTY_1
	天辉下路赏金神符
RUNE_BOUNTY_2
	天辉上路赏金神符
RUNE_BOUNTY_3
	夜魇上路赏金神符
RUNE_BOUNTY_4
	夜魇下路赏金神符
----------------------------------------------------------------------------------------------------
-- Constants - Item Slot Types 常量-物品槽位类型
----------------------------------------------------------------------------------------------------
ITEM_SLOT_TYPE_INVALID
	无效槽位
ITEM_SLOT_TYPE_MAIN
	主物品栏
ITEM_SLOT_TYPE_BACKPACK
	背包
ITEM_SLOT_TYPE_STASH
	储藏室
----------------------------------------------------------------------------------------------------
-- Constants - Action Types 常量-单位动作类型
----------------------------------------------------------------------------------------------------
BOT_ACTION_TYPE_NONE
	无
BOT_ACTION_TYPE_IDLE
	空闲
BOT_ACTION_TYPE_MOVE_TO
	移动
BOT_ACTION_TYPE_MOVE_TO_DIRECTLY
	直接移动
BOT_ACTION_TYPE_ATTACK
	攻击
BOT_ACTION_TYPE_ATTACKMOVE
	移动并攻击
BOT_ACTION_TYPE_USE_ABILITY
	使用技能
BOT_ACTION_TYPE_PICK_UP_RUNE
	拾取神符
BOT_ACTION_TYPE_PICK_UP_ITEM
	拾取物品
BOT_ACTION_TYPE_DROP_ITEM
	丢弃物品
BOT_ACTION_TYPE_SHRINE
	使用圣坛
BOT_ACTION_TYPE_DELAY
	延迟
----------------------------------------------------------------------------------------------------
-- Constants - Courier Actions and States 常量-信使动作和状态
----------------------------------------------------------------------------------------------------
COURIER_ACTION_BURST
	动作-冲刺
COURIER_ACTION_ENEMY_SECRET_SHOP
	动作-前往敌方神秘商店
COURIER_ACTION_RETURN
	动作-返回泉水
COURIER_ACTION_SECRET_SHOP
	动作-前往神秘商店
COURIER_ACTION_SIDE_SHOP
	动作-前往边路商店1
COURIER_ACTION_SIDE_SHOP2
	动作-前往边路商店2
COURIER_ACTION_TAKE_STASH_ITEMS
	动作-拿取储藏室物品
COURIER_ACTION_TAKE_AND_TRANSFER_ITEMS
	动作-拿取并运送物品
COURIER_ACTION_TRANSFER_ITEMS
	动作-运送物品
COURIER_STATE_IDLE - 0
	状态-空闲
COURIER_STATE_AT_BASE - 1
	状态-待在泉水
COURIER_STATE_MOVING - 2
	状态-移动
COURIER_STATE_DELIVERING_ITEMS - 3
	状态-运送物品
COURIER_STATE_RETURNING_TO_BASE - 4
	状态-返回泉水
COURIER_STATE_DEAD
	状态-死亡
----------------------------------------------------------------------------------------------------
-- Constants - Towers 常量-防御塔
----------------------------------------------------------------------------------------------------
TOWER_TOP_1
	上路一塔
TOWER_TOP_2
	上路二塔
TOWER_TOP_3
	上路三塔
TOWER_MID_1
	中路一塔
TOWER_MID_2
	中路二塔
TOWER_MID_3
	中路三塔
TOWER_BOT_1
	下路一塔
TOWER_BOT_2
	下路二塔
TOWER_BOT_3
	下路三塔
TOWER_BASE_1
	基地左边炮塔
TOWER_BASE_2
	基地右边炮塔
----------------------------------------------------------------------------------------------------
-- Constants - Barracks 常量-兵营
----------------------------------------------------------------------------------------------------
BARRACKS_TOP_MELEE
	上路近战兵营
BARRACKS_TOP_RANGED
	上路远程兵营
BARRACKS_MID_MELEE
	中路近战兵营
BARRACKS_MID_RANGED
	中路远程兵营
BARRACKS_BOT_MELEE
	下路近战兵营
BARRACKS_BOT_RANGED
	下路远程兵营
----------------------------------------------------------------------------------------------------
-- Constants - Shrines 常量-圣坛
----------------------------------------------------------------------------------------------------
SHRINE_JUNGLE_1
	上路圣坛
SHRINE_JUNGLE_2
	下路圣坛
----------------------------------------------------------------------------------------------------
-- Constants - Shops 常量-商店
----------------------------------------------------------------------------------------------------
SHOP_HOME
	家里主商店
SHOP_SIDE
	天辉（下路）边路商店
SHOP_SECRET
	天辉（上路）神秘商店
SHOP_SIDE2
	夜魇（上路）边路商店
SHOP_SECRET2
	夜魇（下路）神秘商店
----------------------------------------------------------------------------------------------------
-- Constants - Ability Target Teams 常量-技能指定目标的所在团队
----------------------------------------------------------------------------------------------------
ABILITY_TARGET_TEAM_NONE
	无团队（所有团队？）
ABILITY_TARGET_TEAM_FRIENDLY
	我方团队
ABILITY_TARGET_TEAM_ENEMY
	敌方团队（包括中立团队？）
----------------------------------------------------------------------------------------------------
-- Constants - Ability Target Types 常量-技能指定目标的所属类型
----------------------------------------------------------------------------------------------------
ABILITY_TARGET_TYPE_NONE
	无类型
ABILITY_TARGET_TYPE_HERO
	英雄
ABILITY_TARGET_TYPE_CREEP
	小兵生物
ABILITY_TARGET_TYPE_BUILDING
	建筑
ABILITY_TARGET_TYPE_COURIER
	信使
ABILITY_TARGET_TYPE_OTHER
	其它
ABILITY_TARGET_TYPE_TREE
	树木
ABILITY_TARGET_TYPE_BASIC
	基本类型
ABILITY_TARGET_TYPE_ALL
	全部类型
----------------------------------------------------------------------------------------------------
-- Constants - Ability Target Flags 常量-技能指定目标的特殊标识
----------------------------------------------------------------------------------------------------
ABILITY_TARGET_FLAG_NONE
	无目标单位
ABILITY_TARGET_FLAG_RANGED_ONLY
	仅对远程单位有效
ABILITY_TARGET_FLAG_MELEE_ONLY
	仅对近战单位有效
ABILITY_TARGET_FLAG_DEAD
	对死亡单位有效
ABILITY_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
	对魔法免疫敌方单位有效
ABILITY_TARGET_FLAG_NOT_MAGIC_IMMUNE_ALLIES
	对非魔法免疫友方单位有效
ABILITY_TARGET_FLAG_INVULNERABLE
	对无敌单位有效
ABILITY_TARGET_FLAG_FOW_VISIBLE
	对可见单位有效
ABILITY_TARGET_FLAG_NO_INVIS
	对隐身单位有效
ABILITY_TARGET_FLAG_NOT_ANCIENTS
	对远古单位无效
ABILITY_TARGET_FLAG_PLAYER_CONTROLLED
	对玩家控制的单位有效
ABILITY_TARGET_FLAG_NOT_DOMINATED
	对支配单位无效
ABILITY_TARGET_FLAG_NOT_SUMMONED
	对召唤单位无效
ABILITY_TARGET_FLAG_NOT_ILLUSIONS
	对幻象单位无效
ABILITY_TARGET_FLAG_NOT_ATTACK_IMMUNE
	对攻击免疫单位无效
ABILITY_TARGET_FLAG_MANA_ONLY
	仅对有魔法值的单位有效
ABILITY_TARGET_FLAG_CHECK_DISABLE_HELP
	？
ABILITY_TARGET_FLAG_NOT_CREEP_HERO
	对英雄控制的非英雄单位无效
ABILITY_TARGET_FLAG_OUT_OF_WORLD
	对地图外的单位有效
ABILITY_TARGET_FLAG_NOT_NIGHTMARED
	对梦魇单位无效
ABILITY_TARGET_FLAG_PREFER_ENEMIES
	？
----------------------------------------------------------------------------------------------------
-- Constants - Ability Behavior Bitfields 常量-技能的表现特征
----------------------------------------------------------------------------------------------------
ABILITY_BEHAVIOR_NONE
	无特征
ABILITY_BEHAVIOR_HIDDEN
	隐藏技能
	【示例】祸乱之源的噩梦终止、昆卡标记后的返回、水人变形后的变回原形
ABILITY_BEHAVIOR_PASSIVE
	被动技能
ABILITY_BEHAVIOR_NO_TARGET
	无目标技能
ABILITY_BEHAVIOR_UNIT_TARGET
	指向性技能
ABILITY_BEHAVIOR_POINT
	点技能
ABILITY_BEHAVIOR_AOE
	范围技能
ABILITY_BEHAVIOR_NOT_LEARNABLE
	不可升级的技能
	【示例】幽鬼大招后的空降、末日吃野怪后获得的技能、卡尔切出的10个技能
ABILITY_BEHAVIOR_CHANNELLED
	持续施法技能
	【示例】帕克的相位转移、屠夫的大招肢解
ABILITY_BEHAVIOR_ITEM
	物品技能
ABILITY_BEHAVIOR_TOGGLE
	切换施法开关技能
	【示例】巫医的巫毒疗法、拉席克的脉冲新星
ABILITY_BEHAVIOR_DIRECTIONAL
	直线行径型技能
	【示例】昆卡的幽灵船、米拉娜的月神之箭、痛苦女王的超声冲击波、虚空的时间漫游
ABILITY_BEHAVIOR_IMMEDIATE
	无施法前摇的技能
ABILITY_BEHAVIOR_AUTOCAST
	自动施法开关技能
	【示例】昆卡的潮汐使者、黑鸟的奥术天球、小黑的霜冻之箭
ABILITY_BEHAVIOR_OPTIONAL_UNIT_TARGET
	可选目标单位的技能
ABILITY_BEHAVIOR_OPTIONAL_POINT
	可选施法点的技能
ABILITY_BEHAVIOR_OPTIONAL_NO_TARGET
	可选无（或有）目标的技能
ABILITY_BEHAVIOR_AURA
	光环技能
ABILITY_BEHAVIOR_ATTACK
	自带普通攻击的技能
	【示例】毒龙的毒性攻击、小黑的霜冻之箭
ABILITY_BEHAVIOR_DONT_RESUME_MOVEMENT
	不能恢复移动的技能？
	【示例】编织者的时光倒流、齐天大圣的七十二变及变回本体、滚滚的虚张声势、斧王的狂战士之吼
ABILITY_BEHAVIOR_ROOT_DISABLES
	不能被禁足的技能
	【示例】米拉娜的跳跃、变体精灵的波浪形态
ABILITY_BEHAVIOR_UNRESTRICTED
	不可限制的技能
	【示例】噬魂鬼使用大招后的控制和消化、工程师的集中引爆
ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE
	忽略伪队列的技能？
	【示例】瘟疫法师的幽冥护罩、维萨吉的石像形态、巨牙海民的雪球滚滚、亚巴顿的回光返照、
		祸乱之源的噩梦终止
ABILITY_BEHAVIOR_IGNORE_CHANNEL
	无须持续施法动作的技能
	【示例】巫医的巫毒疗法、拉席克的脉冲新星
ABILITY_BEHAVIOR_DONT_CANCEL_MOVEMENT
	不能取消移动的技能
	【示例】信使（被取消）的加速、信使（自动）升级飞行信使
ABILITY_BEHAVIOR_DONT_ALERT_TARGET
	不能提醒目标的技能
	【示例】（只有）裂魂人的暗影冲刺
ABILITY_BEHAVIOR_DONT_RESUME_ATTACK
	本体不能攻击的技能
	【示例】噬魂鬼的大招感染、黑鸟的星体禁锢、毒狗的崩裂禁锢
ABILITY_BEHAVIOR_NORMAL_WHEN_STOLEN
	被复制窃取后维持原状态效果的技能
	【示例】米波的忽悠（水人复制米波只能忽悠本体）、影魔的魂之挽歌（拉比克窃取后释放是无魂状态）、
		火枪的暗杀、先知的传送等一系列不会获取天赋加成的技能
ABILITY_BEHAVIOR_IGNORE_BACKSWING
	无施法后摇的技能
ABILITY_BEHAVIOR_RUNE_TARGET
	能够以神符为（指向）目标的技能
	【实例】（只有）小小的投掷（注意这里是指向目标，所以屠夫的钩子不算）
ABILITY_BEHAVIOR_DONT_CANCEL_CHANNEL
	不能取消持续施法的技能
	【实例】（只有）神谕者的气运之末？？
ABILITY_BEHAVIOR_VECTOR_TARGETING
	？
ABILITY_BEHAVIOR_LAST_RESORT_POINT
	？
----------------------------------------------------------------------------------------------------
-- Constants - Misc Constants 常量-MISC常数
----------------------------------------------------------------------------------------------------
GLYPH_COOLDOWN
	塔防激活冷却时间
----------------------------------------------------------------------------------------------------
-- Constants - Animation Activities 常量-动画类型
----------------------------------------------------------------------------------------------------
ACTIVITY_IDLE - 1500
	空闲
ACTIVITY_IDLE_RARE - 1501
	空闲10秒
ACTIVITY_RUN - 1502
	移动
ACTIVITY_ATTACK - 1503
	攻击
ACTIVITY_ATTACK2 - 1504
	第二形态攻击
ACTIVITY_ATTACK_EVENT - 1505
	攻击事件
ACTIVITY_DIE - 1506
	死亡
ACTIVITY_FLINCH - 1507
	？
ACTIVITY_FLAIL - 1508
	？
ACTIVITY_DISABLED - 1509
	？
ACTIVITY_CAST_ABILITY_1 - 1510
	使用技能1
ACTIVITY_CAST_ABILITY_2 - 1511
	使用技能2
ACTIVITY_CAST_ABILITY_3 - 1512
	使用技能3
ACTIVITY_CAST_ABILITY_4 - 1513
	使用技能4（通常为大招）
ACTIVITY_CAST_ABILITY_5 - 1514
	使用技能5
ACTIVITY_CAST_ABILITY_6 - 1515
	使用技能6
ACTIVITY_OVERRIDE_ABILITY_1 - 1516
	？
ACTIVITY_OVERRIDE_ABILITY_2 - 1517
	？
ACTIVITY_OVERRIDE_ABILITY_3 - 1518
	？
ACTIVITY_OVERRIDE_ABILITY_4 - 1519
	？
ACTIVITY_CHANNEL_ABILITY_1 - 1520
	？
ACTIVITY_CHANNEL_ABILITY_2 - 1521
	？
ACTIVITY_CHANNEL_ABILITY_3 - 1522
	？
ACTIVITY_CHANNEL_ABILITY_4 - 1523
	？
ACTIVITY_CHANNEL_ABILITY_5 - 1524
	？
ACTIVITY_CHANNEL_ABILITY_6 - 1525
	？
ACTIVITY_CHANNEL_END_ABILITY_1 - 1526
	？
ACTIVITY_CHANNEL_END_ABILITY_2 - 1527
	？
ACTIVITY_CHANNEL_END_ABILITY_3 - 1528
	？
ACTIVITY_CHANNEL_END_ABILITY_4 - 1529
	？
ACTIVITY_CHANNEL_END_ABILITY_5 - 1530
	？
ACTIVITY_CHANNEL_END_ABILITY_6 - 1531
	？
ACTIVITY_CONSTANT_LAYER - 1532
	？
ACTIVITY_CAPTURE - 1533
	？
ACTIVITY_SPAWN - 1534
	重生
ACTIVITY_KILLTAUNT - 1535
	？
ACTIVITY_TAUNT - 1536
	嘲讽
]]