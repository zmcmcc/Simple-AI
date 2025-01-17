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
			['t10'] = {0, 10},
		},
		--技能
		['Ability'] = {1,3,2,3,3,6,3,1,1,1,6,2,2,2,6},
		--装备
		['Buy'] = {
			sOutfit,
			'item_headdress',
			'item_pipe',
			'item_shadow_amulet',
			'item_veil_of_discord',
			'item_invis_sword',		
			'item_cyclone', 
			'item_sheepstick',
			'item_silver_edge',
		},
		--出售
		['Sell'] = {
			'item_cyclone',
			'item_magic_wand',
		},
	},{
		--组合说明，不影响游戏
		['info'] = 'By Misunderstand',
		--天赋树
		['Talent'] = {
			['t25'] = {0, 10},
			['t20'] = {10, 0},
			['t15'] = {0, 10},
			['t10'] = {10, 0},
		},
		--技能
		['Ability'] = { 1, 3, 2, 3, 2, 6, 3, 3, 1, 1, 6, 1, 2, 2, 6 },
		--装备
		['Buy'] = {
			"item_tango",
			"item_flask",
			"item_enchanted_mango",
			"item_circlet",
			"item_branches",
			"item_magic_stick",
			"item_tranquil_boots", 
			"item_enchanted_mango",
			"item_double_clarity",
			"item_urn_of_shadows", 
			"item_magic_wand",
			"item_blink",
			"item_glimmer_cape",
			"item_force_staff", 
			"item_spirit_vessel", 
			"item_black_king_bar",
			"item_ultimate_scepter",
			"item_ultimate_scepter_2",
			"item_hurricane_pike",
			"item_travel_boots",
			"item_silver_edge",
			"item_aeon_disk",
			"item_moon_shard",
			"item_travel_boots_2"
		},
		--出售
		['Sell'] = {
			"item_black_king_bar",     
			"item_magic_wand",
					
			"item_travel_boots",  
			"item_tranquil_boots",

			"item_silver_edge",
			"item_blink",

			"item_aeon_disk",
			"item_glimmer_cape"
		},
	},{
		--组合说明，不影响游戏
		['info'] = 'By 铅笔会有猫的w',
		--天赋树
		['Talent'] = {
			['t25'] = {0, 10},
			['t20'] = {0, 10},
			['t15'] = {10, 0},
			['t10'] = {10, 0},
		},
		--技能
		['Ability'] = { 1, 3, 2, 3, 2, 6, 3, 3, 1, 1, 6, 1, 3, 3, 6 },
		--装备
		['Buy'] = {
			"item_tango",
			"item_flask",
			"item_enchanted_mango",
			"item_circlet",
			"item_branches",
			"item_magic_stick",
			"item_tranquil_boots", 
			"item_enchanted_mango",
			"item_double_clarity",
			"item_bracer", 
			"item_magic_wand",
			"item_glimmer_cape",
			"item_force_staff",
			"item_silver_edge",
			"item_black_king_bar",
			"item_ultimate_scepter",
			"item_sheepstick",
			"item_travel_boots",
			"item_hurricane_pike",
			"item_ultimate_scepter_2",
			"item_bloodthorn",
			"item_moon_shard",
			"item_travel_boots_2",
		},
		--出售
		['Sell'] = {
			"item_ultimate_scepter",     
			"item_magic_wand",
					
			"item_travel_boots",  
			"item_tranquil_boots",
					
			"item_sheepstick",  
			"item_glimmer_cape",

			"item_silver_edge",
			"item_bracer"
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
		['t10'] = {0, 10},
	},
	--技能
	['Ability'] = {1,3,2,3,3,6,3,1,1,1,6,2,2,2,6},
	--装备
	['Buy'] = {
		sOutfit,
		'item_headdress',
		'item_pipe',
		'item_shadow_amulet',
		'item_veil_of_discord',
		'item_invis_sword',		
		'item_cyclone', 
		'item_sheepstick',
		'item_silver_edge',
	},
	--出售
	['Sell'] = {
		'item_cyclone',
		'item_magic_wand',
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

local amuletTime = 0
local aetherRange = 0

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )
local talent2 = bot:GetAbilityByName( sTalentList[2] );

local castQDesire, castQLoc = 0
local castWDesire, castWTarget = 0
local castRDesire = 0

local nKeepMana,nMP,nHP,nLV;

function X.SkillsComplement()

	X.ConsiderCombo()
	
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
	
	nKeepMana = 220 
	aetherRange = 0
	nMP = bot:GetMana()/bot:GetMaxMana()
	nHP = bot:GetHealth()/bot:GetMaxHealth()
	nLV = bot:GetLevel()
	local aether = J.IsItemAvailable('item_aether_lens');
	if aether ~= nil then aetherRange = 250 end
	if talent2:IsTrained() then aetherRange = aetherRange + talent2:GetSpecialValueInt('value') end

	
	castQDesire, castQLoc = X.ConsiderQ();
	if ( castQDesire > 0 ) 
	then
		J.SetQueuePtToINT(bot, false)
		
		bot:ActionQueue_UseAbilityOnLocation( abilityQ, castQLoc );
		return;
	end
	
	
	castWDesire, castWTarget = X.ConsiderW();
	if ( castWDesire > 0 ) 
	then
		J.SetQueuePtToINT(bot, false)
	
		bot:ActionQueue_UseAbilityOnEntity( abilityW, castWTarget );
		return;
	end
	
	
	castRDesire = X.ConsiderR();
	if ( castRDesire > 0 ) 
	then
		J.SetQueuePtToINT(bot, false)
	
		bot:ActionQueue_UseAbility( abilityR );
		return;
	end
	
end

function X.ConsiderCombo()
	if  bot:IsAlive()
		and bot:IsChanneling() 
		and not bot:IsInvisible() 
	then
		local nEnemyTowers = bot:GetNearbyTowers(880,true);
		
		if nEnemyTowers[1] ~= nil then return end
	
		local amulet = J.IsItemAvailable('item_shadow_amulet');
		if amulet~=nil and amulet:IsFullyCastable() and amuletTime < DotaTime()- 10
		then
			amuletTime = DotaTime();
			bot:Action_UseAbilityOnEntity(amulet,bot)
			return;
		end					
     
		if not bot:HasModifier('modifier_teleporting') 
		then
			local glimer = J.IsItemAvailable('item_glimmer_cape');
			if glimer ~= nil and glimer:IsFullyCastable() 
			then
				bot:Action_UseAbilityOnEntity(glimer, bot)
				return;			
			end
			
			local invissword = J.IsItemAvailable('item_invis_sword');
			if invissword ~= nil and invissword:IsFullyCastable() 
			then
				bot:Action_UseAbility(invissword)
				return;			
			end
			
			local silveredge = J.IsItemAvailable('item_silver_edge');
			if silveredge ~= nil and silveredge:IsFullyCastable() 
			then
				bot:Action_UseAbility(silveredge)
				return;			
			end
		end
	end
end

function X.ConsiderQ()

	-- Make sure it's castable
	if not abilityQ:IsFullyCastable() then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end
	
	-- Get some of its values
	local nRadius    = abilityQ:GetSpecialValueInt('radius');  
	local nCastRange = abilityQ:GetCastRange() + aetherRange + 32;					
	local nCastPoint = abilityQ:GetCastPoint( );			    
	local nManaCost  = abilityQ:GetManaCost( );					
	local nDamage    = abilityQ:GetSpecialValueInt('nova_damage');		
	local nSkillLV   = abilityQ:GetLevel();                             
	
	local nAllys =  bot:GetNearbyHeroes(1200,false,BOT_MODE_NONE);
		
	local nEnemysHeroesInRange = bot:GetNearbyHeroes(nCastRange + nRadius,true,BOT_MODE_NONE);
	local nEnemysHeroesInBonus = bot:GetNearbyHeroes(nCastRange + nRadius + 150,true,BOT_MODE_NONE);
	local nEnemysHeroesInView = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	local nWeakestEnemyHeroInRange,nWeakestEnemyHeroHealth1 = X.cm_GetWeakestUnit(nEnemysHeroesInRange);
	local nWeakestEnemyHeroInBonus,nWeakestEnemyHeroHealth2 = X.cm_GetWeakestUnit(nEnemysHeroesInBonus);
	
	local nEnemysLaneCreeps1 = bot:GetNearbyLaneCreeps(nCastRange + nRadius,true)
	local nEnemysLaneCreeps2 = bot:GetNearbyLaneCreeps(nCastRange + nRadius + 200,true)
	local nEnemysWeakestLaneCreeps1,nEnemysWeakestLaneCreepsHealth1 = X.cm_GetWeakestUnit(nEnemysLaneCreeps1);
	local nEnemysWeakestLaneCreeps2,nEnemysWeakestLaneCreepsHealth2 = X.cm_GetWeakestUnit(nEnemysLaneCreeps2);
	
	local nTowers = bot:GetNearbyTowers(1000,true)
	
	local nCanKillHeroLocationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius , 0.8, nDamage);
	local nCanHurtHeroLocationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius , 0.8, 0);
	local nCanKillCreepsLocationAoE = bot:FindAoELocation( true, false, bot:GetLocation(),nCastRange + nRadius, nRadius, 0.5, nDamage);
	local nCanHurtCreepsLocationAoE = bot:FindAoELocation( true, false, bot:GetLocation(),nCastRange + nRadius, nRadius, 0.5, 0);
	
	if nCanHurtCreepsLocationAoE == nil
       or  J.GetInLocLaneCreepCount(bot, 1600, nRadius, nCanHurtCreepsLocationAoE.targetloc) <= 2        
	then
	    nCanHurtCreepsLocationAoE.count = 0
	end
	
	--击杀敌人
	if nCanKillHeroLocationAoE.count ~= nil
	   and nCanKillHeroLocationAoE.count >= 1
	then
		if J.IsValid(nWeakestEnemyHeroInBonus) 
		then
		    local nTargetLocation = J.GetCastLocation(bot,nWeakestEnemyHeroInBonus,nCastRange,nRadius);
			if nTargetLocation ~= nil
			then
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation;
			end
		end
	end
	   
	--对线期对两名以上敌人使用
	if bot:GetActiveMode() == BOT_MODE_LANING 
		and #nTowers <= 0 
		and nHP >= 0.4
	then
		if nCanHurtHeroLocationAoE.count >= 2
		   and GetUnitToLocationDistance(bot,nCanHurtHeroLocationAoE.targetloc) <= nCastRange + 50
		then 
			return BOT_ACTION_DESIRE_HIGH, nCanHurtHeroLocationAoE.targetloc;
		end
	end
	
	--撤退时保护自己
	if  bot:GetActiveMode() == BOT_MODE_RETREAT 
		and bot:WasRecentlyDamagedByAnyHero(2.0)
	then
		local nCanHurtHeroLocationAoENearby = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange - 300, nRadius, 0.8, 0);
		if nCanHurtHeroLocationAoENearby.count >= 1 
		then
			return BOT_ACTION_DESIRE_HIGH, nCanHurtHeroLocationAoENearby.targetloc;
		end
	end
	
	--进攻时的逻辑
	if J.IsGoingOnSomeone(bot)
	then
	
		--进攻时对两名以上敌人使用
		if J.IsValid(nWeakestEnemyHeroInBonus)
		   and nCanHurtHeroLocationAoE.count >= 2 
		   and GetUnitToLocationDistance(bot,nCanHurtHeroLocationAoE.targetloc) <= nCastRange
		then
			return BOT_ACTION_DESIRE_HIGH, nCanHurtHeroLocationAoE.targetloc;
		end
		
		--对进攻目标使用
		local npcEnemy = J.GetProperTarget(bot);
		if J.IsValidHero(npcEnemy)
			and J.CanCastOnNonMagicImmune(npcEnemy)
		then
			
			--蓝很多随意用
			if nMP > 0.75 
			   or bot:GetMana() > nKeepMana * 2
			then
				local nTargetLocation = J.GetCastLocation(bot,npcEnemy,nCastRange,nRadius);
				if nTargetLocation ~= nil
				then
					return BOT_ACTION_DESIRE_HIGH, nTargetLocation;
				end
			end
			
			--进攻目标血很少
			if (npcEnemy:GetHealth()/npcEnemy:GetMaxHealth() < 0.4)
               and GetUnitToUnitDistance(npcEnemy,bot) <= nRadius + nCastRange
		    then
			    local nTargetLocation = J.GetCastLocation(bot,npcEnemy,nCastRange,nRadius);
				if nTargetLocation ~= nil
				then
					return BOT_ACTION_DESIRE_HIGH, nTargetLocation;
				end			   
			end
			
		end	
		
		--对最虚弱的敌人使用
		npcEnemy = nWeakestEnemyHeroInRange;
		if  npcEnemy ~= nil and npcEnemy:IsAlive()
			and (npcEnemy:GetHealth()/npcEnemy:GetMaxHealth() < 0.4)
			and GetUnitToUnitDistance(npcEnemy,bot) <= nRadius + nCastRange
		then
			local nTargetLocation = J.GetCastLocation(bot,npcEnemy,nCastRange,nRadius);
			if nTargetLocation ~= nil
			then
				return BOT_ACTION_DESIRE_HIGH, nTargetLocation;
			end			   
		end 
		
		--无敌人时清理兵线
		if 	J.IsValid(nEnemysWeakestLaneCreeps2)
			and nCanHurtCreepsLocationAoE.count >= 5 
			and #nEnemysHeroesInBonus <= 0
			and bot:GetActiveMode() ~= BOT_MODE_ATTACK
			and nSkillLV >= 3
		then
		    return BOT_ACTION_DESIRE_HIGH, nCanHurtCreepsLocationAoE.targetloc;
		end		
	
		--无敌人时收钱
	    if nCanKillCreepsLocationAoE.count >= 3 
			and (J.IsValid(nEnemysWeakestLaneCreeps1) or nLV >= 25)
			and #nEnemysHeroesInBonus <= 0
			and bot:GetActiveMode() ~= BOT_MODE_ATTACK
			and nSkillLV >= 3
		then
		    return BOT_ACTION_DESIRE_HIGH, nCanKillCreepsLocationAoE.targetloc;
		end		
	end
	
	--非撤退的逻辑
	if bot:GetActiveMode() ~= BOT_MODE_RETREAT 
	then
		if  J.IsValid(nWeakestEnemyHeroInBonus)
		then
		
		    if nCanHurtHeroLocationAoE.count >= 3
			   and GetUnitToLocationDistance(bot,nCanHurtHeroLocationAoE.targetloc) <= nCastRange
			then
			    return BOT_ACTION_DESIRE_VERYHIGH, nCanHurtHeroLocationAoE.targetloc;
			end
			
			if nCanHurtHeroLocationAoE.count >= 2 
			   and GetUnitToLocationDistance(bot,nCanHurtHeroLocationAoE.targetloc) <= nCastRange
			   and bot:GetMana() > nKeepMana
			then
			    return BOT_ACTION_DESIRE_HIGH, nCanHurtHeroLocationAoE.targetloc;
			end
			
			if  J.IsValid(nWeakestEnemyHeroInBonus) 
			then
				if nMP > 0.8 
				   or bot:GetMana() > nKeepMana * 2
				then
					local nTargetLocation = J.GetCastLocation(bot,nWeakestEnemyHeroInBonus,nCastRange,nRadius);
					if nTargetLocation ~= nil
					then
						return BOT_ACTION_DESIRE_HIGH, nTargetLocation;
					end
				end
				
				if (nWeakestEnemyHeroInBonus:GetHealth()/nWeakestEnemyHeroInBonus:GetMaxHealth() < 0.4)
				   and GetUnitToUnitDistance(nWeakestEnemyHeroInBonus,bot) <= nRadius + nCastRange
				then
					local nTargetLocation = J.GetCastLocation(bot,nWeakestEnemyHeroInBonus,nCastRange,nRadius);
					if nTargetLocation ~= nil
					then
						return BOT_ACTION_DESIRE_HIGH, nTargetLocation;
					end			   
				end
			end
		end
	end
	
    
	--打钱
	if  J.IsFarming(bot)
		and nSkillLV >= 3
	then
	
		if nCanKillCreepsLocationAoE.count >= 2 
			and J.IsValid(nEnemysWeakestLaneCreeps1)
		then
		    return BOT_ACTION_DESIRE_HIGH, nCanKillCreepsLocationAoE.targetloc;
		end
		
		if nCanHurtCreepsLocationAoE.count >= 4 
			and J.IsValid(nEnemysWeakestLaneCreeps1)
		then
		    return BOT_ACTION_DESIRE_HIGH, nCanHurtCreepsLocationAoE.targetloc;
		end
		
	end
	
	--推进和防守
	if #nAllys <= 2 and nSkillLV >= 3
		and (J.IsPushing(bot) or J.IsDefending(bot)) 
	then
	
		if nCanHurtCreepsLocationAoE.count >= 4 
			and  J.IsValid(nEnemysWeakestLaneCreeps1)
		then
		    return BOT_ACTION_DESIRE_HIGH, nCanHurtCreepsLocationAoE.targetloc;
		end		
	
	    if nCanKillCreepsLocationAoE.count >= 2 
			and J.IsValid(nEnemysWeakestLaneCreeps1)
		then
		    return BOT_ACTION_DESIRE_HIGH, nCanKillCreepsLocationAoE.targetloc;
		end
	end
	
	
	if  bot:GetActiveMode() == BOT_MODE_ROSHAN
		and bot:GetMana() >= 400	
	then
		local npcTarget = bot:GetAttackTarget();
		if  J.IsRoshan(npcTarget)
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation();
		end
	end
	
	--特殊用法之辅助二技能收大野
	local nNeutarlCreeps = bot:GetNearbyNeutralCreeps(nCastRange + nRadius);
	if J.IsValid(nNeutarlCreeps[1])
	then 
	    for _,creep in pairs(nNeutarlCreeps)
		do
			if J.IsValid(creep)
				and creep:HasModifier('modifier_crystal_maiden_frostbite')
				and creep:GetHealth()/creep:GetMaxHealth() > 0.3
				and (  creep:GetUnitName() == 'npc_dota_neutral_dark_troll_warlord'
					or creep:GetUnitName() == 'npc_dota_neutral_satyr_hellcaller'
					or creep:GetUnitName() == 'npc_dota_neutral_polar_furbolg_ursa_warrior' )
			then
				local nTargetLocation = J.GetCastLocation(bot,creep,nCastRange,nRadius);
				if nTargetLocation ~= nil
				then
					return BOT_ACTION_DESIRE_HIGH, nTargetLocation;
				end			
			end
		end
	end
	
	--通用的用法
	if  #nEnemysHeroesInView == 0 
		and not J.IsGoingOnSomeone(bot)
		and nSkillLV > 2
	then
		
		if nCanKillCreepsLocationAoE.count >= 2 
			and (nEnemysWeakestLaneCreeps2 ~= nil or nLV == 25)
		then
		    return BOT_ACTION_DESIRE_HIGH, nCanKillCreepsLocationAoE.targetloc;
		end		
		
		if nCanHurtCreepsLocationAoE.count >= 4
		   and nEnemysWeakestLaneCreeps2 ~= nil
		then
			return BOT_ACTION_DESIRE_HIGH, nCanHurtCreepsLocationAoE.targetloc;
		end
		
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;
	
end

function X.ConsiderW()

	-- Make sure it's castable
	if not abilityW:IsFullyCastable() then 
		return BOT_ACTION_DESIRE_NONE, 0;
	end

	-- Get some of its values
	local nCastRange = abilityW:GetCastRange() +30 +aetherRange;
	local nCastPoint = abilityW:GetCastPoint( );
	local nManaCost  = abilityW:GetManaCost( );
	local nSkillLV   = abilityW:GetLevel();                             
	local nDamage    = (100 + nSkillLV * 50);
	
	local nAllies =  bot:GetNearbyHeroes(1200,false,BOT_MODE_NONE);
	
	local nEnemysHeroesInView = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	if #nEnemysHeroesInView <= 1 and nCastRange < bot:GetAttackRange() then nCastRange = bot:GetAttackRange()+60 end
	local nEnemysHeroesInRange = bot:GetNearbyHeroes(nCastRange,true,BOT_MODE_NONE);
	local nEnemysHeroesInBonus = bot:GetNearbyHeroes(nCastRange + 200,true,BOT_MODE_NONE);
	
	local nWeakestEnemyHeroInRange,nWeakestEnemyHeroHealth1 = X.cm_GetWeakestUnit(nEnemysHeroesInRange);
	local nWeakestEnemyHeroInBonus,nWeakestEnemyHeroHealth2 = X.cm_GetWeakestUnit(nEnemysHeroesInBonus);
	
	local nEnemysCreeps1 = bot:GetNearbyCreeps(nCastRange + 100,true)
	local nEnemysCreeps2 = bot:GetNearbyCreeps(1400,true)
	
	local nEnemysStrongestCreeps1,nEnemysStrongestCreepsHealth1 = X.cm_GetStrongestUnit(nEnemysCreeps1);
	local nEnemysStrongestCreeps2,nEnemysStrongestCreepsHealth2 = X.cm_GetStrongestUnit(nEnemysCreeps2);
	
	local nTowers = bot:GetNearbyTowers(900,true)
	
	--击杀敌人
	if  J.IsValid(nWeakestEnemyHeroInRange)
		and J.CanCastOnTargetAdvanced(nWeakestEnemyHeroInRange)
	then
		if J.WillMagicKillTarget(bot, nWeakestEnemyHeroInRange, nDamage, nCastPoint)
		then
			return BOT_ACTION_DESIRE_HIGH, nWeakestEnemyHeroInRange;
		end
	end	
	
	--打断TP
	for _,npcEnemy in pairs( nEnemysHeroesInBonus)
	do
		if J.IsValid(npcEnemy)
		   and npcEnemy:IsChanneling()
		   and npcEnemy:HasModifier('modifier_teleporting')
		   and J.CanCastOnNonMagicImmune(npcEnemy)
		   and J.CanCastOnTargetAdvanced(npcEnemy)
		then
			return BOT_ACTION_DESIRE_HIGH, npcEnemy
		end
	end
	
	--团战中对最强的敌人使用
	if J.IsInTeamFight(bot, 1200)
	   and  DotaTime() > 6*60
	then
		local npcMostDangerousEnemy = nil;
		local nMostDangerousDamage = 0;
		
		local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( nCastRange, true, BOT_MODE_NONE );
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and J.CanCastOnTargetAdvanced(npcEnemy)
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
	
	--保护自己
	if bot:WasRecentlyDamagedByAnyHero(3.0) 
		and #nEnemysHeroesInRange >= 1
	then
		for _,npcEnemy in pairs( nEnemysHeroesInRange )
		do
			if  J.IsValid(npcEnemy)
			    and J.CanCastOnNonMagicImmune(npcEnemy) 
				and J.CanCastOnTargetAdvanced(npcEnemy)
				and not J.IsDisabled(true, npcEnemy)
                and not npcEnemy:IsDisarmed()				
				and bot:IsFacingLocation(npcEnemy:GetLocation(),45)
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy
			end
		end
	end
	
	--对线期消耗
	if bot:GetActiveMode() == BOT_MODE_LANING and #nTowers == 0
	then
		if( nMP > 0.5 or bot:GetMana()> nKeepMana )
		then
			if J.IsValid(nWeakestEnemyHeroInRange)
			   and not J.IsDisabled(true, nWeakestEnemyHeroInRange) 
			then
				return BOT_ACTION_DESIRE_HIGH,nWeakestEnemyHeroInRange;
			end
		end	
	
		if( nMP > 0.78 or bot:GetMana()> nKeepMana )
		then
			if  J.IsValid(nWeakestEnemyHeroInBonus)
				and nHP > 0.6 
				and #nTowers == 0
				and #nEnemysCreeps2 + #nEnemysHeroesInBonus <= 5
			    and not J.IsDisabled(true, nWeakestEnemyHeroInBonus) 
				and nWeakestEnemyHeroInBonus:GetCurrentMovementSpeed() < bot:GetCurrentMovementSpeed()
			then
				return BOT_ACTION_DESIRE_HIGH,nWeakestEnemyHeroInBonus;
			end			
		end
		
		
		if  J.IsValid(nEnemysHeroesInView[1])
		then
			if  J.GetAllyUnitCountAroundEnemyTarget(nEnemysHeroesInView[1], 350, bot) >= 5
				and not J.IsDisabled(true, nEnemysHeroesInView[1]) 
				and not nEnemysHeroesInView[1]:IsMagicImmune()
				and nHP > 0.7
				and bot:GetMana()> nKeepMana
				and #nEnemysCreeps2 + #nEnemysHeroesInBonus <= 3
				and #nTowers == 0
			then
				return BOT_ACTION_DESIRE_HIGH,nEnemysHeroesInView[1];
			end
		end
		
		if  J.IsValid(nWeakestEnemyHeroInRange)  
		then
			if nWeakestEnemyHeroInRange:GetHealth()/nWeakestEnemyHeroInRange:GetMaxHealth() < 0.5 
			then
				return BOT_ACTION_DESIRE_HIGH,nWeakestEnemyHeroInRange;
			end
		end
	end
	
	--特殊用法之冰冻敌方英雄的随从
	if nEnemysHeroesInRange[1] == nil
		and nEnemysCreeps1[1] ~= nil
	then
		for _,EnemyplayerCreep in pairs(nEnemysCreeps1)
		do 
			if  J.IsValid(EnemyplayerCreep)
			    and EnemyplayerCreep:GetTeam() == GetOpposingTeam()
				and EnemyplayerCreep:GetHealth() > 460
				and not EnemyplayerCreep:IsMagicImmune()
				and not EnemyplayerCreep:IsInvulnerable()
				and (EnemyplayerCreep:IsDominated() or EnemyplayerCreep:IsMinion())
			then
			    return BOT_ACTION_DESIRE_HIGH, EnemyplayerCreep;
			end
		end
	end
	
	--无英雄目标时冰冻小兵打钱
	if bot:GetActiveMode() ~= BOT_MODE_LANING 
		and  bot:GetActiveMode() ~= BOT_MODE_RETREAT
		and  bot:GetActiveMode() ~= BOT_MODE_ATTACK
		and  #nEnemysHeroesInView == 0
		and  #nAllies < 3
		and  nLV >= 5
	then
		
		--先远
		if  J.IsValid(nEnemysStrongestCreeps2)
			and (DotaTime() > 10*60 
			     or (nEnemysStrongestCreeps2:GetUnitName() ~= 'npc_dota_creep_badguys_melee'
                     and nEnemysStrongestCreeps2:GetUnitName() ~= 'npc_dota_creep_badguys_ranged'
                     and nEnemysStrongestCreeps2:GetUnitName() ~= 'npc_dota_creep_goodguys_melee'
                     and nEnemysStrongestCreeps2:GetUnitName() ~= 'npc_dota_creep_goodguys_ranged') )
		then
			if  (nEnemysStrongestCreepsHealth2 > 460 or (nEnemysStrongestCreepsHealth1 > 390 and nMP > 0.45)) 
				and nEnemysStrongestCreepsHealth2 <= 1200
			then
				return BOT_ACTION_DESIRE_LOW, nEnemysStrongestCreeps2;
			end
		end
		
		--再近
		if  J.IsValid(nEnemysStrongestCreeps1)
			and (DotaTime() > 10*60 
			     or (nEnemysStrongestCreeps1:GetUnitName() ~= 'npc_dota_creep_badguys_melee'
                     and nEnemysStrongestCreeps1:GetUnitName() ~= 'npc_dota_creep_badguys_ranged'
                     and nEnemysStrongestCreeps1:GetUnitName() ~= 'npc_dota_creep_goodguys_melee'
                     and nEnemysStrongestCreeps1:GetUnitName() ~= 'npc_dota_creep_goodguys_ranged') )					 
		then
			if (nEnemysStrongestCreepsHealth1 > 410 or (nEnemysStrongestCreepsHealth1 > 360 and nMP > 0.45))   
				and nEnemysStrongestCreepsHealth1 <= 1200  
			then
				return BOT_ACTION_DESIRE_LOW, nEnemysStrongestCreeps1;
			end
		end
		
	end
	
	--进攻
	if J.IsGoingOnSomeone(bot)
	then
	    local npcTarget = J.GetProperTarget(bot);
		if J.IsValidHero(npcTarget) 
			and J.CanCastOnNonMagicImmune(npcTarget) 
			and J.CanCastOnTargetAdvanced(npcTarget)
			and J.IsInRange(npcTarget, bot, nCastRange + 50) 
			and not J.IsDisabled(true, npcTarget)
			and not npcTarget:IsDisarmed()
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end		
	end
	

	--撤退
	if J.IsRetreating(bot) 
	then
		for _,npcEnemy in pairs( nEnemysHeroesInRange )
		do
			if  J.IsValid(npcEnemy)
			    and bot:WasRecentlyDamagedByHero( npcEnemy, 5.0 ) 
				and J.CanCastOnNonMagicImmune(npcEnemy) 
				and J.CanCastOnTargetAdvanced(npcEnemy)
				and not J.IsDisabled(true, npcEnemy) 
				and J.IsInRange(npcEnemy, bot, nCastRange - 80) 
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
	end
	
	
	if  bot:GetActiveMode() == BOT_MODE_ROSHAN 
		and bot:GetMana() >= 400
	then
		local npcTarget = bot:GetAttackTarget();
		if  J.IsRoshan(npcTarget) 
			and not J.IsDisabled(true, npcTarget)
			and not npcTarget:IsDisarmed()
			and J.IsInRange(npcTarget, bot, nCastRange)  
		then
			return BOT_ACTION_DESIRE_HIGH, npcTarget;
		end
	end
	
	
	return BOT_ACTION_DESIRE_NONE, 0;

end

function X.ConsiderR()
	-- Make sure it's castable
	if  not abilityR:IsFullyCastable() 
		or bot:DistanceFromFountain() < 100 
	then 
		return BOT_ACTION_DESIRE_NONE;
	end


	-- Get some of its values
	local nRadius 	 = abilityR:GetAOERadius();                          
	
	local nAllies =  bot:GetNearbyHeroes(1200,false,BOT_MODE_NONE);
	
	local nEnemysHeroesInRange = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE);
	local nWeakestEnemyHeroInRange,nWeakestEnemyHeroHealth1 = X.cm_GetWeakestUnit(nEnemysHeroesInRange);
	
	
	local aoeCanHurtCount = 0
	for _,enemy in pairs (nEnemysHeroesInRange)
	do
		if  J.IsValid(enemy)
			and J.CanCastOnNonMagicImmune(enemy)
		    and ( J.IsDisabled(true, enemy) 
				  or J.IsInRange(bot, enemy, nRadius *0.82 - enemy:GetCurrentMovementSpeed()) )
		then
			aoeCanHurtCount = aoeCanHurtCount + 1
		end
	end
	if bot:GetActiveMode() ~= BOT_MODE_RETREAT 
	   or (bot:GetActiveMode() == BOT_MODE_RETREAT and bot:GetActiveModeDesire() <= 0.85 ) 
	then
		if ( #nEnemysHeroesInRange >= 3 or aoeCanHurtCount >= 2) 
		then
			return BOT_ACTION_DESIRE_HIGH;
		end		
	end	
	
	
	if J.IsGoingOnSomeone(bot)
	then
		local npcTarget = J.GetProperTarget(bot);		
		if J.IsValidHero(npcTarget) 
			and J.CanCastOnNonMagicImmune(npcTarget) 
			and ( J.IsDisabled(true, npcTarget) or J.IsInRange(bot,npcTarget,280) )
			and npcTarget:GetHealth() <= npcTarget:GetActualIncomingDamage(bot:GetOffensivePower() *1.5,DAMAGE_TYPE_MAGICAL)
			and GetUnitToUnitDistance(npcTarget,bot) <= nRadius
			and npcTarget:GetHealth( ) > 400
			and #nAllies <= 2 
		then
			return BOT_ACTION_DESIRE_HIGH
		end
	end
	
	if J.IsRetreating(bot) and nHP > 0.38
	then
		local nEnemysHeroesNearby = bot:GetNearbyHeroes(500,true,BOT_MODE_NONE);
		local nEnemysHeroesFurther = bot:GetNearbyHeroes(1300,true,BOT_MODE_NONE);
		local npcTarget = nEnemysHeroesNearby[1];
		if J.IsValidHero(npcTarget) 
		   and J.CanCastOnNonMagicImmune(npcTarget)
		   and not abilityQ:IsFullyCastable()
		   and not abilityW:IsFullyCastable()
		   and nHP > 0.38 * #nEnemysHeroesFurther
		then
			return BOT_ACTION_DESIRE_HIGH;
		end	
	end	
	
	return BOT_ACTION_DESIRE_NONE;

end

function X.cm_GetWeakestUnit( nEnemyUnits )
	
	local nWeakestUnit = nil;
	local nWeakestUnitLowestHealth = 10000;
	for _,unit in pairs(nEnemyUnits)
	do
		if 	J.CanCastOnNonMagicImmune(unit)
		then
			if unit:GetHealth() < nWeakestUnitLowestHealth
			then
				nWeakestUnitLowestHealth = unit:GetHealth();
				nWeakestUnit = unit;
			end
		end
	end

	return nWeakestUnit,nWeakestUnitLowestHealth;	
end

function X.cm_GetStrongestUnit( nEnemyUnits )
	
	local nStrongestUnit = nil;
	local nStrongestUnitHealth = GetBot():GetAttackDamage();

	for _,unit in pairs(nEnemyUnits)
	do
		if 	unit ~= nil and unit:IsAlive() 
			and not unit:HasModifier('modifier_fountain_glyph') 
			and not unit:IsIllusion()
			and not unit:IsMagicImmune()
			and not unit:IsInvulnerable()
			and unit:GetHealth() <= 1100
			and not unit:IsAncientCreep()
			and unit:GetMagicResist() < 1.05 - unit:GetHealth()/1100
			and not unit:WasRecentlyDamagedByAnyHero(2.5)
			and not J.IsOtherAllysTarget(unit)
			and string.find(unit:GetUnitName(),'siege') == nil 
			and ( nLV < 25 or unit:GetTeam() == TEAM_NEUTRAL )
		then
			if string.find(unit:GetUnitName(),'ranged') ~= nil
				and unit:GetHealth() > GetBot():GetAttackDamage() * 2
		    then
			   return unit,500; 
			end
		
			if unit:GetHealth() > nStrongestUnitHealth
			then
				nStrongestUnitHealth = unit:GetHealth()
				nStrongestUnit = unit;
			end
		end
	end

	return nStrongestUnit,nStrongestUnitHealth	
end

return X
-- dota2jmz@163.com QQ:2462331592
