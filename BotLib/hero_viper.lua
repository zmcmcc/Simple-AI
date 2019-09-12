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
			['t25'] = {0, 10},
			['t20'] = {0, 10},
			['t15'] = {10, 0},
			['t10'] = {10, 0},
		},
		--技能
		['Ability'] = {1,3,1,3,1,6,1,2,2,2,6,2,3,3,6},
		--装备
		['Buy'] = {
			sOutfit,
			"item_yasha_and_kaya",
			"item_ultimate_scepter",
			"item_maelstrom",
			"item_black_king_bar",
			"item_mjollnir",
			"item_octarine_core",
		},
		--出售
		['Sell'] = {
			"item_ultimate_scepter",
			"item_urn_of_shadows",
			
			'item_mjollnir',
			'item_magic_wand',
		},
	},{
		--组合说明，不影响游戏
		['info'] = 'By Misunderstand',
		--天赋树
		['Talent'] = {
			['t25'] = {0, 10},
			['t20'] = {10, 0},
			['t15'] = {10, 0},
			['t10'] = {10, 0},
		},
		--技能
		['Ability'] = { 2, 3, 2, 1, 2, 6, 2, 3, 3, 1, 6, 3, 1, 1, 6 },
		--装备
		['Buy'] = {
			"item_double_slippers",
			"item_circlet",
			"item_enchanted_mango",
			"item_tango",
			"item_bottle",
			"item_wraith_band",
			"item_arcane_boots",
			"item_rod_of_atos",
			"item_veil_of_discord",
			"item_guardian_greaves",
			"item_ultimate_scepter",
			"item_yasha_and_kaya",
			"item_octarine_core",
			"item_ultimate_orb",
			"item_ultimate_scepter_2",
			"item_sheepstick",
			"item_moon_shard"
		},
		--出售
		['Sell'] = {
			"item_arcane_boots",     
			"item_slippers",

			"item_veil_of_discord",     
			"item_wraith_band",

			"item_octarine_core", 
			"item_bottle"
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
		['Ability'] = { 1, 3, 1, 2, 1, 6, 2, 1, 2, 2, 6, 3, 3, 3, 6 },
		--装备
		['Buy'] = {
			"item_crown",
			"item_branches",
			"item_double_tango",
			"item_double_flask",				
			"item_boots",
			"item_magic_wand",
			"item_urn_of_shadows",
			"item_arcane_boots",
			"item_rod_of_atos", 
			"item_veil_of_discord", 	
			"item_black_king_bar",
			"item_ultimate_scepter", 
			"item_nullifier", 
			"item_ultimate_scepter_2", 
			"item_octarine_core",
			"item_heavens_halberd",
			"item_sheepstick",			
			"item_travel_boots", 	
			"item_moon_shard",		
			"item_travel_boots_2", 
		},
		--出售
		['Sell'] = {
			"item_travel_boots",     
			"item_arcane_boots",

			"item_sheepstick",   
			"item_rod_of_atos",

			"item_ultimate_scepter",     
			"item_urn_of_shadows",
					
			"item_ultimate_scepter",  
			"item_magic_wand",	     
		},
	},
}
--默认数据
local tDefaultGroupedData = {
	--天赋树
	['Talent'] = {
		['t25'] = {0, 10},
		['t20'] = {0, 10},
		['t15'] = {10, 0},
		['t10'] = {10, 0},
	},
	--技能
	['Ability'] = {1,3,1,3,1,6,1,2,2,2,6,2,3,3,6},
	--装备
	['Buy'] = {
		sOutfit,
		"item_yasha_and_kaya",
		"item_ultimate_scepter",
		"item_maelstrom",
		"item_black_king_bar",
		"item_mjollnir",
		"item_octarine_core",
	},
	--出售
	['Sell'] = {
		"item_ultimate_scepter",
		"item_urn_of_shadows",
		
		'item_mjollnir',
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

local abilityQ = bot:GetAbilityByName( sAbilityList[1] );
local abilityW = bot:GetAbilityByName( sAbilityList[2] );
local abilityR = bot:GetAbilityByName( sAbilityList[6] );
local talent5 = bot:GetAbilityByName( sTalentList[5] );

local castQDesire,castQTarget = 0;
local castWDesire,castWLocation = 0;
local castRDesire,castRTarget = 0;
local castRQDesire,castRQTarget = 0;

local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;
local talentBonusDamage = 0;

local lastRQTime = 0;

function X.SkillsComplement()

	
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end
	
	
	nKeepMana = 400; 
	talentBonusDamage = 0;
	nMP = bot:GetMana()/bot:GetMaxMana();
	nHP = bot:GetHealth()/bot:GetMaxHealth();
	nLV = bot:GetLevel();
	hEnemyHeroList = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	
	
	--计算天赋可能带来的变化
	if talent5:IsTrained() then talentBonusDamage = talentBonusDamage + 500 end
	
	
	castRQDesire, castRQTarget = X.ConsiderRQ();
	if ( castRQDesire > 0 )
	then
		print("使用RQ,目标是:"..J.Chat.GetNormName(castRQTarget));
		lastRQTime = DotaTime();
		
		J.SetQueuePtToINT(bot, true)
		
		bot:ActionQueue_UseAbilityOnEntity( abilityR, castRQTarget )
		bot:ActionQueue_UseAbilityOnEntity( abilityQ, castRQTarget )
		return;
	
	end
	
	
	castRDesire, castRTarget   = X.ConsiderR();
	if ( castRDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, true)
	
		bot:ActionQueue_UseAbilityOnEntity( abilityR, castRTarget )
		return;
	end
	
	castWDesire, castWLocation = X.ConsiderW();
	if ( castWDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, true)
	
		bot:ActionQueue_UseAbilityOnLocation( abilityW, castWLocation )
		return;
	end
	
	castQDesire, castQTarget   = X.ConsiderQ();
	if ( castQDesire > 0 ) 
	then
	
		bot:Action_ClearActions(false);
	
		bot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget )
		return;
		
	end


end

function X.ConsiderRQ()

	if not abilityQ:IsFullyCastable() 
	   or not abilityR:IsFullyCastable() 
	   or bot:HasScepter()
	   or lastRQTime > DotaTime() - 10
	then return 0 end
	
	if bot:GetMana() < abilityQ:GetManaCost() + abilityR:GetManaCost() then return 0 end
	
	local nCastRange = abilityR:GetCastRange();
	local nAttackRange = bot:GetAttackRange() + 50;
	
	local npcTarget = J.GetProperTarget(bot)
	
	local nEnemysHerosInCastRange = bot:GetNearbyHeroes(nCastRange + 80 ,true,BOT_MODE_NONE);
	local nWeakestEnemyHeroInCastRange = J.GetVulnerableWeakestUnit(true, true, nCastRange + 80, bot);
	
	
	if J.IsValid(nEnemysHerosInCastRange[1])
	then
		--当前目标,最近目标和最弱目标
		if(nWeakestEnemyHeroInCastRange ~= nil)
		then           
						
			if J.IsValidHero(npcTarget)                        
			then
				if J.IsInRange(npcTarget, bot, nCastRange + 80)   
					and J.CanCastOnNonMagicImmune(npcTarget)
					and J.CanCastOnTargetAdvanced(npcTarget)
					and not npcTarget:IsAttackImmune()
				then					
					return BOT_ACTION_DESIRE_HIGH,npcTarget;
				else
					if not nWeakestEnemyHeroInCastRange:IsAttackImmune()
					   and not nWeakestEnemyHeroInCastRange:IsMagicImmune()
					   and J.CanCastOnTargetAdvanced(nWeakestEnemyHeroInCastRange)
					then
						return BOT_ACTION_DESIRE_HIGH,nWeakestEnemyHeroInCastRange;
					end
				end
			end	
		end
		
		if J.CanCastOnNonMagicImmune(nEnemysHerosInCastRange[1])
		   and J.CanCastOnTargetAdvanced(nEnemysHerosInCastRange[1])
		   and not nEnemysHerosInCastRange[1]:IsAttackImmune()
		then
			return BOT_ACTION_DESIRE_HIGH,nEnemysHerosInCastRange[1];
		end
	end	

	return 0

end

function X.ConsiderQ()

	if not abilityQ:IsFullyCastable() or bot:IsDisarmed() then return BOT_ACTION_DESIRE_NONE end
	
	local nAttackRange = bot:GetAttackRange() + 30;
	local nAttackDamage = bot:GetAttackDamage();
	
	local nTowers = bot:GetNearbyTowers(1000,true)
	
	local nEnemysHerosInAttackRange = bot:GetNearbyHeroes(nAttackRange,true,BOT_MODE_NONE);

	local nAlleyLaneCreeps = bot:GetNearbyLaneCreeps(310,false)
	
	local npcTarget = J.GetProperTarget(bot)
	
	
	if  J.IsValidHero(npcTarget) 
		and J.IsValidHero(nEnemysHerosInAttackRange[1])
		and not (#nEnemysHerosInAttackRange == 1 and nEnemysHerosInAttackRange[1] == npcTarget)
		and (bot:GetActiveMode() ~= BOT_MODE_RETREAT or bot:GetActiveModeDesire( ) < 0.65 )
		and bot:GetActiveMode() ~= BOT_MODE_TEAM_ROAM
	then
	
		--先对未中毒的敌人使用
		local newTarget = nil 
		local newTargetHealthRate = 0.75
		for _,npcEnemy in pairs(nEnemysHerosInAttackRange)
		do
			if npcEnemy:GetHealth()/npcEnemy:GetMaxHealth() < newTargetHealthRate
			   and not npcEnemy:HasModifier("modifier_viper_poison_attack_slow")
			   and not npcEnemy:HasModifier('modifier_illusion') 
			   and not npcEnemy:IsMagicImmune()
			   and not npcEnemy:IsInvulnerable()
			   and not npcEnemy:IsAttackImmune()
			   and not npcEnemy:GetUnitName() == "npc_dota_hero_meepo"
			then
		       newTarget = npcEnemy
			   newTargetHealthRate = npcEnemy:GetHealth()/npcEnemy:GetMaxHealth()
			end
		end
		if(newTarget ~= nil)
		then
			return BOT_ACTION_DESIRE_HIGH,newTarget;
		end
		
		--再对已中毒buff快没了的使用
		local duringTime = 9.0
		for _,npcEnemy in pairs(nEnemysHerosInAttackRange)
		do		  
			if  npcEnemy:HasModifier("modifier_viper_poison_attack_slow")
				and not npcEnemy:HasModifier('modifier_illusion') 
				and not npcEnemy:IsMagicImmune()
				and not npcEnemy:IsInvulnerable()
				and not npcEnemy:IsAttackImmune() 
			then
				local nBuffTime = J.GetModifierTime(npcEnemy, "modifier_viper_poison_attack_slow")
				if nBuffTime < duringTime
				then
					newTarget = npcEnemy
					duringTime = nBuffTime
				end
		    end
		end
		if(newTarget ~= nil)
		then
			return BOT_ACTION_DESIRE_HIGH,newTarget;
		end
		
		--最后是对血量最少的使用
		local newTargetHealth = 99999
		for _,npcEnemy in pairs(nEnemysHerosInAttackRange)
		do
			if npcEnemy:GetHealth() < newTargetHealth
			   and not npcEnemy:HasModifier('modifier_illusion') 
			   and not npcEnemy:IsMagicImmune()
			   and not npcEnemy:IsInvulnerable()
			   and not npcEnemy:IsAttackImmune() 
			then
		       newTarget = npcEnemy
			   newTargetHealth = npcEnemy:GetHealth()
			end
		end
		if(newTarget ~= nil)
		then
			return BOT_ACTION_DESIRE_HIGH,newTarget;
		end
		
	end
	
	
	if J.IsRetreating(bot)
	then
		local enemys = bot:GetNearbyHeroes(nAttackRange,true,BOT_MODE_NONE)
		if  enemys[1] ~= nil and enemys[1]:IsAlive()
			and bot:IsFacingLocation(enemys[1]:GetLocation(),90)
			and not enemys[1]:HasModifier("modifier_viper_poison_attack_slow")
			and not enemys[1]:IsMagicImmune()
			and not enemys[1]:IsInvulnerable()
			and not enemys[1]:IsAttackImmune()
		then
			return BOT_ACTION_DESIRE_HIGH,enemys[1];
		end
	end	
	
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN  
	then
	    local nAttackTarget = bot:GetAttackTarget();
		if J.IsValid(nAttackTarget) 
			and not nAttackTarget:HasModifier("modifier_viper_poison_attack_slow")			
		then
			castRTarget = nAttackTarget;
			return BOT_ACTION_DESIRE_HIGH,castRTarget;
		end
	end

	
	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderW()

	if not abilityW:IsFullyCastable() then return 0 end
	
	if bot:GetMana() <= 128 and abilityR:GetCooldownTimeRemaining() <= 0.1 then return 0 end
	
	local nRadius    = abilityW:GetSpecialValueInt( "radius" );
	local nCastRange = abilityW:GetCastRange();
	local nCastPoint = abilityW:GetCastPoint();
	local nSkillLV   = abilityW:GetLevel();
	local nManaCost  = abilityW:GetManaCost();
	local nDamage    = abilityW:GetSpecialValueInt("duration") * abilityW:GetSpecialValueInt("damage");
	
	local nEnemysLaneCreepsInSkillRange = bot:GetNearbyLaneCreeps(nCastRange + nRadius,true)
	local nEnemysHeroesInSkillRange = bot:GetNearbyHeroes(nCastRange + nRadius + 30,true,BOT_MODE_NONE)
	
	local nCanHurtCreepsLocationAoE = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0.8, 0);
	if nCanHurtCreepsLocationAoE == nil
       or  J.GetInLocLaneCreepCount(bot, 1600, nRadius, nCanHurtCreepsLocationAoE.targetloc) <= 1        
	then
	     nCanHurtCreepsLocationAoE.count = 0
	end
	local nCanHurtHeroLocationAoE = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange, nRadius-30, 0.8, 0);
	
	local npcTarget = J.GetProperTarget(bot)
	
	
	if #nEnemysHeroesInSkillRange >= 2
		and nCanHurtHeroLocationAoE.cout ~= nil
		and nCanHurtHeroLocationAoE.cout >= 2
		and bot:GetActiveMode() ~= BOT_MODE_LANING
		and ( bot:GetActiveMode() ~= BOT_MODE_RETREAT or bot:GetActiveModeDesire() < 0.7 )
    then
		return BOT_ACTION_DESIRE_HIGH,nCanHurtHeroLocationAoE.targetloc;
	end
	
	if J.IsValidHero(npcTarget) 
	   and J.CanCastOnNonMagicImmune(npcTarget) 
	   and not npcTarget:HasModifier("modifier_viper_nethertoxin")
	   and J.IsInRange(npcTarget, bot, nCastRange +100)
	   and (nSkillLV >= 3 or bot:GetMana() >= nKeepMana)
	then
		local targetFutureLoc = J.GetCorrectLoc(npcTarget, nCastPoint +1.2) 
	    if npcTarget:GetLocation() ~= targetFutureLoc
	    then			
		    return BOT_ACTION_DESIRE_HIGH,targetFutureLoc ;
		end
		
		local castDistance = GetUnitToUnitDistance(bot, npcTarget)
		if npcTarget:IsFacingLocation(bot:GetLocation(), 45)
		then
			if castDistance > 300	
			then   
			    castDistance = castDistance - 100;
			end
			
		    return BOT_ACTION_DESIRE_HIGH,J.GetUnitTowardDistanceLocation(bot,npcTarget,castDistance);
		end		
		
		if bot:IsFacingLocation(npcTarget:GetLocation(), 45)
		then
		    if castDistance + 100 <= nCastRange
			then
			    castDistance = castDistance + 200;
			else
			    castDistance = nCastRange+ 100;
			end
			
		    return BOT_ACTION_DESIRE_HIGH, J.GetUnitTowardDistanceLocation(bot,npcTarget,castDistance);
		end
		
		return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation();
		
	end
	
	
	if ( bot:GetActiveMode() == BOT_MODE_RETREAT and not bot:IsMagicImmune()) 
	then
		local nCanHurtHeroLocationAoENearby = bot:FindAoELocation( true, true, bot:GetLocation(), nCastRange - 200, nRadius, 0.8, 0);
		if nCanHurtHeroLocationAoENearby.count >= 1 
			and bot:IsFacingLocation(nCanHurtHeroLocationAoENearby.targetloc,60)
		then			
			return BOT_ACTION_DESIRE_HIGH, nCanHurtHeroLocationAoENearby.targetloc;
		end
	end
	
	
	if #hEnemyHeroList == 0
		and nSkillLV >= 2
		and bot:GetActiveMode( ) ~= BOT_MODE_ATTACK
		and bot:GetActiveMode( ) ~= BOT_MODE_LANING
		and bot:GetMana() >= nKeepMana
		and #nEnemysLaneCreepsInSkillRange >= 2
		and (nCanHurtCreepsLocationAoE.count >= 5 - nMP * 2.1)
	then
		local nAllies = bot:GetNearbyHeroes(1200,false,BOT_MODE_NONE);
		if J.IsValid(nEnemysLaneCreepsInSkillRange[1]) and #nAllies < 3
		   and not nEnemysLaneCreepsInSkillRange[1]:HasModifier("modifier_viper_nethertoxin")
		then
			return BOT_ACTION_DESIRE_HIGH, nCanHurtCreepsLocationAoE.targetloc;
		end
	end	
	
	if  J.IsFarming(bot) 
		and nSkillLV >= 2
		and J.IsAllowedToSpam(bot, nManaCost * 0.3)
	then
		if J.IsValid(npcTarget)
		   and npcTarget:GetTeam() == TEAM_NEUTRAL
		   and not npcTarget:HasModifier("modifier_viper_nethertoxin")
		then
			local nAoe = bot:FindAoELocation( true, false, bot:GetLocation(), nCastRange, nRadius, 0, 0);
			if nAoe.count >= 5 - nMP * 2.5
			    and J.GetNearbyAroundLocationUnitCount(true, false, nRadius, nAoe.targetloc) >= 2
			then
				return BOT_ACTION_DESIRE_HIGH,nAoe.targetloc;
			end
		end
	end
	
	if  bot:GetActiveMode() == BOT_MODE_ROSHAN  
	then
	    local nAttackTarget = bot:GetAttackTarget();
		if  J.IsValid(nAttackTarget)	
			and not nAttackTarget:HasModifier("modifier_viper_nethertoxin")
		then
			return BOT_ACTION_DESIRE_HIGH,nAttackTarget:GetLocation();
		end
	end
	
	return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderR()

	if not abilityR:IsFullyCastable() then return 0 end
	
	local nCastRange = abilityR:GetCastRange();
	local nAttackRange = bot:GetAttackRange();
	local nDamage = (abilityR:GetLevel() *40 + 20) *5 + talentBonusDamage;
	
	local nEnemysHerosInCastRange = bot:GetNearbyHeroes(nCastRange + 80 ,true,BOT_MODE_NONE);
	local nWeakestEnemyHeroInCastRange = J.GetVulnerableWeakestUnit(true, true, nCastRange + 80, bot);
	local npcTarget = J.GetProperTarget(bot)
	local castRTarget = nil
	
	
	if J.IsValid(nEnemysHerosInCastRange[1])
	then
		--最弱目标和当前目标
		if(nWeakestEnemyHeroInCastRange ~= nil)
		then           
			if nWeakestEnemyHeroInCastRange:GetHealth() < nWeakestEnemyHeroInCastRange:GetActualIncomingDamage(nDamage,DAMAGE_TYPE_MAGICAL)
			then				
				castRTarget = nWeakestEnemyHeroInCastRange;
				return BOT_ACTION_DESIRE_HIGH, castRTarget;
			end
			
			if J.IsValidHero(npcTarget)                        
			then
				if J.IsInRange(npcTarget, bot, nCastRange + 80)   
					and J.CanCastOnMagicImmune(npcTarget)
					and J.CanCastOnTargetAdvanced(npcTarget)
				then					
					castRTarget = npcTarget;
					return BOT_ACTION_DESIRE_HIGH,castRTarget;
				else
					if J.CanCastOnTargetAdvanced(nWeakestEnemyHeroInCastRange)
					then
						castRTarget = nWeakestEnemyHeroInCastRange;                    
						return BOT_ACTION_DESIRE_HIGH,castRTarget;
					end
				end
			end	
		end
		
		if J.CanCastOnMagicImmune(nEnemysHerosInCastRange[1])
		   and J.CanCastOnTargetAdvanced(nEnemysHerosInCastRange[1])
		then
			castRTarget = nEnemysHerosInCastRange[1];   
			return BOT_ACTION_DESIRE_HIGH,castRTarget;
		end
	end	
	
	
	if bot:GetActiveMode() == BOT_MODE_ROSHAN and bot:HasScepter()
	then
	    local nAttackTarget = bot:GetAttackTarget();
		if  nAttackTarget ~= nil and nAttackTarget:IsAlive()
			and nAttackTarget:HasModifier("modifier_viper_poison_attack_slow")
		then
			return BOT_ACTION_DESIRE_HIGH,nAttackTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE	
end

return X
-- dota2jmz@163.com QQ:2462331592
