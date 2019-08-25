----------------------------------------------------------------------------------------------------
--- The Creation Come From: BOT EXPERIMENT Credit:FURIOUSPUPPY
--- BOT EXPERIMENT Author: Arizona Fauzie 2018.11.21
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=837040016
--- Update by: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
----------------------------------------------------------------------------------------------------
local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local ConversionMode = dofile( GetScriptDirectory()..'/AuxiliaryScript/BotlibConversion') --引入技能文件
local Minion = dofile( GetScriptDirectory()..'/FunLib/Minion')
local sTalentList = J.Skill.GetTalentList(bot)
local sAbilityList = J.Skill.GetAbilityList(bot)
local sOutfit = J.Skill.GetOutfitName(bot)

--编组技能、天赋、装备
local tGroupedDataList = {
	{
		--组合说明，不影响游戏
		['info'] = 'By 决明子',
		--天赋树
		['Talent'] = {
			['t25'] = {10, 0},
			['t20'] = {0, 10},
			['t15'] = {10, 0},
			['t10'] = {10, 0},
		},
		--技能
		['Ability'] = {1,3,2,3,1,6,1,1,3,3,6,2,2,2,6},
		--装备
		['Buy'] = {
			sOutfit,
			"item_mekansm",
			"item_urn_of_shadows",
			"item_glimmer_cape",
			"item_rod_of_atos",
			"item_guardian_greaves",
			"item_spirit_vessel",
			"item_ultimate_scepter",
			"item_shivas_guard",
		},
		--出售
		['Sell'] = {
			"item_ultimate_scepter",
			"item_magic_wand",
		},
	},{
		--组合说明，不影响游戏
		['info'] = 'By Misunderstand',
		--天赋树
		['Talent'] = {
			['t25'] = {0, 10},
			['t20'] = {10, 0},
			['t15'] = {10, 0},
			['t10'] = {0, 10},
		},
		--技能
		['Ability'] = { 1, 3, 3, 1, 1, 6, 1, 2, 3, 3, 6, 2, 2, 2, 6 },
		--装备
		['Buy'] = {
			"item_mantle",
			"item_circlet",
			"item_tango",
			"item_enchanted_mango",
			"item_double_branches",
			"item_null_talisman",
			"item_magic_wand",
			"item_power_treads",
			"item_mekansm", 
			"item_holy_locket",
			"item_ultimate_scepter",
			"item_shivas_guard",
			"item_black_king_bar",
			"item_ultimate_scepter_2",
			"item_lotus_orb", 
			"item_pipe", 
			"item_dagon_3",
			"item_heart", 
			"item_travel_boots",
			"item_dagon_5",
			"item_moon_shard",
			"item_travel_boots_2"
		},
		--出售
		['Sell'] = {
			"item_ultimate_scepter",
			"item_null_talisman",
					
			"item_shivas_guard", 
			"item_magic_wand",

			"item_lotus_orb",
			"item_mekansm",

			"item_pipe",
			"item_holy_locket",

			"item_heart", 
			"item_black_king_bar",

			"item_travel_boots",
			"item_power_treads"
		},
	},{
		--组合说明，不影响游戏
		['info'] = 'By 铅笔会有猫的w',
		--天赋树
		['Talent'] = {
			['t25'] = {10, 0},
			['t20'] = {0, 10},
			['t15'] = {10, 0},
			['t10'] = {10, 0},
		},
		--技能
		['Ability'] = { 1, 3, 1, 2, 1, 6, 1, 3, 3, 3, 6, 2, 2, 2, 6 },
		--装备
		['Buy'] = {
			"item_double_tango",
			"item_double_branches",
			"item_magic_stick",
			"item_null_talisman",
			"item_magic_wand",
			"item_arcane_boots",
			"item_mekansm",
			"item_ultimate_scepter",
			"item_shivas_guard",
			"item_octarine_core",
			"item_guardian_greaves",
			"item_radiance",
			"item_sheepstick",
			"item_ultimate_scepter_2",
			"item_heart",
			"item_moon_shard",
		},
		--出售
		['Sell'] = {
			"item_ethereal_blade",
			"item_pipe",
					
			"item_sheepstick",
			"item_magic_wand",

			"item_octarine_core",
			"item_null_talisman",
		},
	},
}
--默认数据
local tDefaultGroupedData = {
	--天赋树
	['Talent'] = {
		['t25'] = {10, 0},
		['t20'] = {0, 10},
		['t15'] = {10, 0},
		['t10'] = {10, 0},
	},
	--技能
	['Ability'] = {1,3,2,3,1,6,1,1,3,3,6,2,2,2,6},
	--装备
	['Buy'] = {
		sOutfit,
		"item_mekansm",
		"item_urn_of_shadows",
		"item_glimmer_cape",
		"item_rod_of_atos",
		"item_guardian_greaves",
		"item_spirit_vessel",
		"item_ultimate_scepter",
		"item_shivas_guard",
	},
	--出售
	['Sell'] = {
		"item_ultimate_scepter",
		"item_magic_wand",
	},
}

--根据组数据生成技能、天赋、装备
local nAbilityBuildList, nTalentBuildList;

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = ConversionMode.Combination(tGroupedDataList, tDefaultGroupedData)

nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList'] = J.SetUserHeroInit(nAbilityBuildList,nTalentBuildList,X['sBuyList'],X['sSellList']);

X['sSkillList'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)


X['bDeafaultAbility'] = true
X['bDeafaultItem'] = true

function X.MinionThink(hMinionUnit)

	if Minion.IsValidUnit(hMinionUnit) 
	then
		Minion.IllusionThink(hMinionUnit)
	end

end

local abilityQ = bot:GetAbilityByName( sAbilityList[1] );
local abilityW = bot:GetAbilityByName( sAbilityList[2] );
local abilityR = bot:GetAbilityByName( sAbilityList[6] );


local castQDesire
local castWDesire
local castWQDesire
local castRDesire,castRTarget

local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;

function X.SkillsComplement()

	
	
	if J.CanNotUseAbility(bot) then return end
	
	
	
	nKeepMana = 400; 
	nLV = bot:GetLevel();
	nMP = bot:GetMana()/bot:GetMaxMana();
	nHP = bot:GetHealth()/bot:GetMaxHealth();
	hEnemyHeroList = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	
	
	
	
	
	castRDesire, castRTarget = X.ConsiderR();
	if ( castRDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, false)
	
		bot:ActionQueue_UseAbilityOnEntity( abilityR, castRTarget )
		return;
	end
	
	castWDesire = X.ConsiderW();
	if ( castWDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, false)
	
		bot:ActionQueue_UseAbility( abilityW )
		return;
	
	end
	
	castQDesire = X.ConsiderQ();
	if ( castQDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, false)
	
		bot:ActionQueue_UseAbility( abilityQ )
		return;
	
	end

end


function X.ConsiderW()

	-- Make sure it's castable
	if ( not abilityW:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end
	
	local nRadius = abilityW:GetSpecialValueInt( "slow_aoe" );
	
	local SadStack = 0;
	local npcModifier = bot:NumModifiers();
	
	for i = 0, npcModifier 
	do
		if bot:GetModifierName(i) == "modifier_necrolyte_death_pulse_counter" then
			SadStack = bot:GetModifierStackCount(i);
			break;
		end
	end
	
	if ( SadStack >= 8 or bot:GetHealthRegen() > 99) 
	    and bot:GetHealth() / bot:GetMaxHealth() < 0.5 
	then
		return BOT_ACTION_DESIRE_LOW;
	end
	
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		if bot:WasRecentlyDamagedByAnyHero( 2.0 ) and #tableNearbyEnemyHeroes > 0  
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end

	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = bot:GetTarget();
		if J.IsValidHero(npcTarget) 
		   and J.IsRunning(npcTarget)
		   and J.IsRunning(bot)
		   and bot:GetAttackTarget() == nil
		   and J.CanCastOnNonMagicImmune(npcTarget)
		   and J.IsInRange(npcTarget, bot, nRadius - 30)
		   and ( J.GetHPR(bot) < 0.25 
		         or ( not J.IsInRange(npcTarget, bot, 430)
					  and bot:IsFacingLocation(npcTarget:GetLocation(),30) 
				      and not npcTarget:IsFacingLocation(bot:GetLocation(),120) ))
		then
			local targetAllies = npcTarget:GetNearbyHeroes(1000, false, BOT_MODE_NONE);
			if #targetAllies == 1 then 
				return BOT_ACTION_DESIRE_MODERATE;
			end
		end
	end
	
	return BOT_ACTION_DESIRE_NONE;
end


function X.ConsiderQ()

	-- Make sure it's castable
	if  not abilityQ:IsFullyCastable() 
		or bot:IsInvisible()
		or ( J.GetHPR(bot) > 0.62 and abilityR:GetCooldownTimeRemaining() < 6 and bot:GetMana() < abilityR:GetManaCost() )
	then 
		return BOT_ACTION_DESIRE_NONE;
	end


	-- Get some of its values
	local nRadius = abilityQ:GetSpecialValueInt( "area_of_effect" );
	local nCastRange = 0;
	local nDamage = abilityQ:GetAbilityDamage();
	local nDamageType = DAMAGE_TYPE_MAGICAL;

	--------------------------------------
	-- Mode based usage
	--------------------------------------

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot) or J.GetHPR(bot) < 0.5
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 2*nRadius, true, BOT_MODE_NONE );
		if ( bot:WasRecentlyDamagedByAnyHero( 2.0 ) and #tableNearbyEnemyHeroes > 0 )
			or (J.GetHPR(bot) < 0.75 and bot:DistanceFromFountain() < 400)
			or J.GetHPR(bot) < J.GetMPR(bot)
			or J.GetHPR(bot) < 0.25
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	if abilityQ:GetLevel() >= 3
	then
		local tableNearbyEnemyCreeps = bot:GetNearbyLaneCreeps( nRadius, true );
		local nCanHurtCount = 0;
		local nCanKillCount = 0;
		for _,creep in pairs(tableNearbyEnemyCreeps)
		do
			if J.IsValid(creep)
				and not creep:HasModifier("modifier_fountain_glyph")				
			then
				nCanHurtCount = nCanHurtCount +1;
				if J.CanKillTarget(creep, nDamage +2, nDamageType)
				then
					nCanKillCount = nCanKillCount +1;
				end
			end		
		end
		
		if  nCanKillCount >= 2
			or (nCanKillCount >= 1 and J.GetMPR(bot) > 0.9)
			or (nCanHurtCount >= 3 and bot:GetActiveMode() ~= BOT_MODE_LANING)
			or (nCanHurtCount >= 3 and nCanKillCount >= 1 and J.IsAllowedToSpam(bot, 190))
			or (nCanHurtCount >= 3 and J.GetMPR(bot) > 0.8 and bot:GetLevel() > 10 and #tableNearbyEnemyCreeps == 3)
			or (nCanHurtCount >= 2 and nCanKillCount >= 1 and bot:GetLevel() > 24 and #tableNearbyEnemyCreeps == 2)
		then
			return BOT_ACTION_DESIRE_HIGH;
		end
		
	end

	if J.IsInTeamFight(bot, 1200)
	then
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );
		local tableNearbyAlliesHeroes = bot:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE );
		local lowHPAllies = 0;
		for _,ally in pairs(tableNearbyAlliesHeroes)
		do
			if J.IsValidHero(ally)
			then
				local allyHealth = ally:GetHealth() / ally:GetMaxHealth();
				if allyHealth < 0.5 then
					lowHPAllies = lowHPAllies + 1;
				end
			end
		end
		
		if #tableNearbyEnemyHeroes >= 2 or lowHPAllies >= 1 then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end
	
	-- If we can heal 3+ allyHero
	local tableNearbyAlliesHeroes = bot:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE );
	if #tableNearbyAlliesHeroes >= 2
	then
		local needHPCount = 0;
		for _,Ally in pairs(tableNearbyAlliesHeroes)
		do
			if J.IsValidHero(Ally)
			   and Ally:GetMaxHealth()- Ally:GetHealth() > 220
			then
			    needHPCount = needHPCount + 1;
				
				if Ally:GetHealth()/Ally:GetMaxHealth() < 0.15 
				then
					return BOT_ACTION_DESIRE_MODERATE;
				end
	
				if needHPCount >= 2 and  Ally:GetHealth()/Ally:GetMaxHealth() < 0.38 
				then
					return BOT_ACTION_DESIRE_MODERATE;
				end
				
				if needHPCount >= 3 
				then
					return BOT_ACTION_DESIRE_MODERATE;
				end
				
			end
		end
	
	end
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = J.GetProperTarget(bot);

		if J.IsValidHero(npcTarget) and J.CanCastOnNonMagicImmune(npcTarget) and J.IsInRange(npcTarget, bot, nRadius)
		then
			return BOT_ACTION_DESIRE_MODERATE;
		end
	end


	return BOT_ACTION_DESIRE_NONE;

end


function X.ConsiderR()

	-- Make sure it's castable
	if not abilityR:IsFullyCastable() then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityR:GetCastRange();
	local nDamagePerHealth = abilityR:GetSpecialValueFloat("damage_per_health");

	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = J.GetProperTarget(bot);
		if J.IsValidHero(npcTarget) 
		   and J.CanCastOnNonMagicImmune(npcTarget) 
		   and J.CanCastOnTargetAdvanced(npcTarget)
		   and not J.IsHaveAegis(npcTarget)
		   and not npcTarget:HasModifier("modifier_arc_warden_tempest_double")
		   and J.IsInRange(npcTarget, bot, nCastRange + 200)
		then
			local EstDamage = X.GetEstDamage(bot,npcTarget,nDamagePerHealth);
			
			if J.CanKillTarget(npcTarget, EstDamage, DAMAGE_TYPE_MAGICAL ) 
			   or ( npcTarget:IsChanneling() and npcTarget:HasModifier("modifier_teleporting") )
			then
				X.ReportDetails(bot,npcTarget,EstDamage,nDamagePerHealth)
				return BOT_ACTION_DESIRE_HIGH, npcTarget;
			end
		end
	end	

	-- If we're in a teamfight, use it on the scariest enemy
	if J.IsInTeamFight(bot, 1200)
	then
		local npcToKill = nil;
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if J.IsValidHero(npcEnemy)
			   and J.CanCastOnNonMagicImmune(npcEnemy)
			   and J.CanCastOnTargetAdvanced(npcEnemy)
			   and not J.IsHaveAegis(npcEnemy) 
			   and not npcEnemy:HasModifier("modifier_arc_warden_tempest_double")
			then
				local EstDamage = X.GetEstDamage(bot,npcEnemy,nDamagePerHealth);
				if J.CanKillTarget(npcEnemy, EstDamage, DAMAGE_TYPE_MAGICAL )
				then
					X.ReportDetails(bot,npcEnemy,EstDamage,nDamagePerHealth)
					npcToKill = npcEnemy;
					break;
				end
			end
		end
		if ( npcToKill ~= nil  )
		then
			return BOT_ACTION_DESIRE_HIGH, npcToKill;
		end
	end
	
	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1200, true, BOT_MODE_NONE );
	for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
	do
		if J.IsValidHero(npcEnemy) 
		   and not J.IsHaveAegis(npcEnemy) 
		   and J.CanCastOnTargetAdvanced(npcEnemy)
		   and not npcEnemy:HasModifier("modifier_arc_warden_tempest_double")
		then
			local EstDamage = X.GetEstDamage(bot,npcEnemy,nDamagePerHealth);
			if J.CanCastOnNonMagicImmune(npcEnemy) and J.CanKillTarget(npcEnemy, EstDamage, DAMAGE_TYPE_MAGICAL )
			then
				X.ReportDetails(bot,npcEnemy,EstDamage,nDamagePerHealth)
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end

	return BOT_ACTION_DESIRE_NONE, 0;
end


function X.GetEstDamage(bot, npcTarget, nDamagePerHealth)

	local targetMaxHealth = npcTarget:GetMaxHealth();
	
	if npcTarget:GetHealth()/ targetMaxHealth > 0.75 
	then
		return targetMaxHealth * 0.3;
	end
	
	local AroundTargetAllyCount = J.GetAroundTargetAllyHeroCount(npcTarget, 650, bot);
	
	local MagicResistReduce = 1 - npcTarget:GetMagicResist();
	if MagicResistReduce  < 0.1 then  MagicResistReduce  = 0.1 end;
	local HealthBack =  npcTarget:GetHealthRegen() *2;
	
	local EstDamage = ( targetMaxHealth - npcTarget:GetHealth() - HealthBack ) * nDamagePerHealth - HealthBack/MagicResistReduce;	
	
	if bot:GetLevel() >= 9 then EstDamage = EstDamage + targetMaxHealth * 0.026; end
	if bot:GetLevel() >= 12 then EstDamage = EstDamage + targetMaxHealth * 0.032; end
	if bot:GetLevel() >= 18 then EstDamage = EstDamage + targetMaxHealth * 0.016; end
	
	if bot:HasScepter() and J.GetHPR(bot) < 0.2 then EstDamage = EstDamage + targetMaxHealth * 0.3; end
		
	if AroundTargetAllyCount >= 2 then EstDamage = EstDamage + targetMaxHealth * 0.08 *(AroundTargetAllyCount - 1); end

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
		and not npcTarget:IsFacingLocation(GetBot():GetLocation(),120)
	then 
		EstDamage = EstDamage * 0.7; 
	end 
	
	if npcTarget:HasModifier("modifier_kunkka_ghost_ship_damage_delay")
	then
		local buffTime = J.GetModifierTime(npcTarget,"modifier_kunkka_ghost_ship_damage_delay");
		if buffTime > 2.0 then EstDamage = EstDamage *0.55; end
	end		
	
	if npcTarget:HasModifier("modifier_templar_assassin_refraction_absorb") then EstDamage = 0; end
	
	return EstDamage;
	
end


local ReportTime = 99999;
function X.ReportDetails(bot,npcTarget,EstDamage,nDamagePerHealth)

	if DotaTime() > ReportTime + 5.0
	then
		local nMessage;
		local nNumber;
		local MagicResist = 1 - npcTarget:GetMagicResist();
		
		ReportTime = DotaTime();
		
		nMessage = "基础伤害值:"
		nNumber  = nDamagePerHealth * ( npcTarget:GetMaxHealth() - npcTarget:GetHealth()) ;
		nNumber  = nNumber * MagicResist;
		bot:ActionImmediate_Chat(nMessage..string.gsub(tostring(nNumber),"npc_dota_",""),true);
		
		nMessage = "计算伤害值:";
		nNumber  = EstDamage * MagicResist;
		bot:ActionImmediate_Chat(nMessage..string.gsub(tostring(nNumber),"npc_dota_",""),true);
		
		-- nMessage = "目标魔法增强率:";
		-- nNumber  = npcTarget:GetSpellAmp();
		-- bot:ActionImmediate_Chat(nMessage..string.gsub(tostring(nNumber),"npc_dota_",""),true);
		
		nMessage = npcTarget:GetUnitName();
		nNumber  = npcTarget:GetHealth();
		bot:ActionImmediate_Chat(string.gsub(tostring(nMessage),"npc_dota_","")..'当前生命值:'..tostring(nNumber),true);

	end

end

return X
-- dota2jmz@163.com QQ:2462331592
