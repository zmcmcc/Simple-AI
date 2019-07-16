----------------------------------------------------------------------------------------------------
--- The Creation Come From: BOT EXPERIMENT Credit:FURIOUSPUPPY
--- BOT EXPERIMENT Author: Arizona Fauzie 2018.11.21
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=837040016
--- Update by: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
----------------------------------------------------------------------------------------------------
local X = {}
local npcBot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local minion = dofile( GetScriptDirectory()..'/FunLib/Minion')
local sTalentList = J.Skill.GetTalentList(npcBot)
local sAbilityList = J.Skill.GetAbilityList(npcBot)
local sOutfit = J.Skill.GetOutfitName(npcBot)

local tTalentTreeList = {
						['t25'] = {0, 10},
						['t20'] = {0, 10},
						['t15'] = {10, 0},
						['t10'] = {10, 0},
}

local tAllAbilityBuildList = {
						{1,3,1,3,1,6,1,2,2,2,6,2,3,3,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)

X['skills'] = J.Skill.GetSkillList(sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList)

X['items'] = {
				sOutfit,
				"item_yasha_and_kaya",
				"item_ultimate_scepter",
				"item_maelstrom",
				"item_black_king_bar",
				"item_mjollnir",
				"item_octarine_core",
}

X['bDeafaultAbility'] = true
X['bDeafaultItem'] = true

function X.MinionThink(hMinionUnit)

	if minion.IsValidUnit(hMinionUnit) 
	then
		if hMinionUnit:IsIllusion() 
		then 
			minion.IllusionThink(hMinionUnit)	
		end
	end

end

local abilityQ = npcBot:GetAbilityByName( sAbilityList[1] );
local abilityW = npcBot:GetAbilityByName( sAbilityList[2] );
local abilityR = npcBot:GetAbilityByName( sAbilityList[6] );
local talent5 = npcBot:GetAbilityByName( sTalentList[5] );

local castQDesire,castQTarget = 0;
local castWDesire,castWLocation = 0;
local castRDesire,castRTarget = 0;
local castRQDesire,castRQTarget = 0;

local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;
local talentBonusDamage = 0;

function X.SkillsComplement()

	
	if J.CanNotUseAbility(npcBot) or npcBot:IsInvisible() then return end
	
	
	nKeepMana = 400; 
	talentBonusDamage = 0;
	nMP = npcBot:GetMana()/npcBot:GetMaxMana();
	nHP = npcBot:GetHealth()/npcBot:GetMaxHealth();
	nLV = npcBot:GetLevel();
	hEnemyHeroList = npcBot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	
	
	--计算天赋可能带来的变化
	if talent5:IsTrained() then talentBonusDamage = talentBonusDamage + 500 end
	
	
	castRQDesire, castRQTarget = X.ConsiderRQ();
	if ( castRQDesire > 0 )
	then
		print("使用RQ,目标是:"..castRQTarget:GetUnitName());
		J.SetQueuePtToINT(npcBot, false)
		
		npcBot:ActionQueue_UseAbilityOnEntity( abilityR, castRQTarget )
		npcBot:ActionQueue_UseAbilityOnEntity( abilityQ, castRQTarget )
		return;
	
	end
	
	
	castRDesire, castRTarget   = X.ConsiderR();
	if ( castRDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, false)
	
		npcBot:ActionQueue_UseAbilityOnEntity( abilityR, castRTarget )
		return;
	end
	
	castWDesire, castWLocation = X.ConsiderW();
	if ( castWDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(npcBot, false)
	
		npcBot:ActionQueue_UseAbilityOnLocation( abilityW, castWLocation )
		return;
	end
	
	castQDesire, castQTarget   = X.ConsiderQ();
	if ( castQDesire > 0 ) 
	then
	
		npcBot:Action_ClearActions(false);
	
		npcBot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget )
		return;
		
	end


end

function X.ConsiderRQ()

	if not abilityQ:IsFullyCastable() 
	   or not abilityR:IsFullyCastable() 
	   or npcBot:HasScepter()
	then return 0 end
	
	if npcBot:GetMana() < abilityQ:GetManaCost() + abilityR:GetManaCost() then return 0 end
	
	local nCastRange = abilityR:GetCastRange();
	local nAttackRange = npcBot:GetAttackRange() + 50;
	
	local npcTarget = J.GetProperTarget(npcBot)
	
	local nEnemysHerosInCastRange = npcBot:GetNearbyHeroes(nCastRange + 80 ,true,BOT_MODE_NONE);
	local nWeakestEnemyHeroInCastRange = J.GetVulnerableWeakestUnit(true, true, nCastRange + 80, npcBot);
	
	
	if J.IsValid(nEnemysHerosInCastRange[1])
	then
		--当前目标,最近目标和最弱目标
		if(nWeakestEnemyHeroInCastRange ~= nil)
		then           
						
			if J.IsValidHero(npcTarget)                        
			then
				if J.IsInRange(npcTarget, npcBot, nCastRange + 80)   
					and J.CanCastOnMagicImmune(npcTarget)
					and not npcTarget:IsAttackImmune()
				then					
					return BOT_ACTION_DESIRE_HIGH,npcTarget;
				else
					if not nWeakestEnemyHeroInCastRange:IsAttackImmune()
					then
						return BOT_ACTION_DESIRE_HIGH,nWeakestEnemyHeroInCastRange;
					end
				end
			end	
		end
		
		if J.CanCastOnMagicImmune(nEnemysHerosInCastRange[1])
		   and not nEnemysHerosInCastRange[1]:IsAttackImmune()
		then
			return BOT_ACTION_DESIRE_HIGH,nEnemysHerosInCastRange[1];
		end
	end	

	return 0

end

function X.ConsiderQ()

	if not abilityQ:IsFullyCastable() or npcBot:IsDisarmed() then return BOT_ACTION_DESIRE_NONE end
	
	local nAttackRange = npcBot:GetAttackRange() + 30;
	local nAttackDamage = npcBot:GetAttackDamage();
	
	local nTowers = npcBot:GetNearbyTowers(1000,true)
	
	local nEnemysHerosInAttackRange = npcBot:GetNearbyHeroes(nAttackRange,true,BOT_MODE_NONE);

	local nAlleyLaneCreeps = npcBot:GetNearbyLaneCreeps(310,false)
	
	local npcTarget = J.GetProperTarget(npcBot)
	
	
	if  J.IsValidHero(npcTarget) 
		and J.IsValidHero(nEnemysHerosInAttackRange[1])
		and not (#nEnemysHerosInAttackRange == 1 and nEnemysHerosInAttackRange[1] == npcTarget)
		and (npcBot:GetActiveMode() ~= BOT_MODE_RETREAT or npcBot:GetActiveModeDesire( ) < 0.65 )
		and npcBot:GetActiveMode() ~= BOT_MODE_TEAM_ROAM
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
	
	
	if npcBot:GetActiveMode() == BOT_MODE_RETREAT 
		and npcBot:GetActiveModeDesire() > BOT_MODE_DESIRE_MODERATE
	then
		local enemys = npcBot:GetNearbyHeroes(nAttackRange,true,BOT_MODE_NONE)
		if  enemys[1] ~= nil and enemys[1]:IsAlive()
			and npcBot:IsFacingLocation(enemys[1]:GetLocation(),90)
			and not enemys[1]:HasModifier("modifier_viper_poison_attack_slow")
			and not enemys[1]:IsMagicImmune()
			and not enemys[1]:IsInvulnerable()
			and not enemys[1]:IsAttackImmune()
		then
			return BOT_ACTION_DESIRE_HIGH,enemys[1];
		end
	end	
	
	
	if  npcBot:GetActiveMode() == BOT_MODE_ROSHAN  
	then
	    local nAttackTarget = npcBot:GetAttackTarget();
		if  J.IsValid(nAttackTarget) 
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
	
	if npcBot:GetMana() <= 128 and abilityR:GetCooldownTimeRemaining() <= 0.1 then return 0 end
	
	local nRadius    = abilityW:GetSpecialValueInt( "radius" );
	local nCastRange = abilityW:GetCastRange();
	local nCastPoint = abilityW:GetCastPoint();
	local nSkillLV   = abilityW:GetLevel();
	local nManaCost  = abilityW:GetManaCost();
	local nDamage    = abilityW:GetSpecialValueInt("duration") * abilityW:GetSpecialValueInt("damage");
	
	local nEnemysLaneCreepsInSkillRange = npcBot:GetNearbyLaneCreeps(nCastRange + nRadius,true)
	local nEnemysHeroesInSkillRange = npcBot:GetNearbyHeroes(nCastRange + nRadius + 30,true,BOT_MODE_NONE)
	
	local nCanHurtCreepsLocationAoE = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0.8, 0);
	if nCanHurtCreepsLocationAoE == nil
       or  J.GetInLocLaneCreepCount(npcBot, 1600, nRadius, nCanHurtCreepsLocationAoE.targetloc) <= 1        
	then
	     nCanHurtCreepsLocationAoE.count = 0
	end
	local nCanHurtHeroLocationAoE = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange, nRadius-30, 0.8, 0);
	
	local npcTarget = J.GetProperTarget(npcBot)
	
	
	if #nEnemysHeroesInSkillRange >= 2
		and nCanHurtHeroLocationAoE.cout ~= nil
		and nCanHurtHeroLocationAoE.cout >= 2
		and npcBot:GetActiveMode() ~= BOT_MODE_LANING
		and ( npcBot:GetActiveMode() ~= BOT_MODE_RETREAT or npcBot:GetActiveModeDesire() < 0.7 )
    then
		return BOT_ACTION_DESIRE_HIGH,nCanHurtHeroLocationAoE.targetloc;
	end
	
	if J.IsValidHero(npcTarget) 
	   and J.CanCastOnNonMagicImmune(npcTarget) 
	   and not npcTarget:HasModifier("modifier_viper_nethertoxin")
	   and J.IsInRange(npcTarget, npcBot, nCastRange +100)
	   and (nSkillLV >= 3 or npcBot:GetMana() >= nKeepMana)
	then
		local targetFutureLoc = J.GetCorrectLoc(npcTarget, nCastPoint +1.2) 
	    if npcTarget:GetLocation() ~= targetFutureLoc
	    then			
		    return BOT_ACTION_DESIRE_HIGH,targetFutureLoc ;
		end
		
		local castDistance = GetUnitToUnitDistance(npcBot, npcTarget)
		if npcTarget:IsFacingLocation(npcBot:GetLocation(), 45)
		then
			if castDistance > 300	
			then   
			    castDistance = castDistance - 100;
			end
			
		    return BOT_ACTION_DESIRE_HIGH,J.GetUnitTowardDistanceLocation(npcBot,npcTarget,castDistance);
		end		
		
		if npcBot:IsFacingLocation(npcTarget:GetLocation(), 45)
		then
		    if castDistance + 100 <= nCastRange
			then
			    castDistance = castDistance + 200;
			else
			    castDistance = nCastRange+ 100;
			end
			
		    return BOT_ACTION_DESIRE_HIGH, J.GetUnitTowardDistanceLocation(npcBot,npcTarget,castDistance);
		end
		
		return BOT_ACTION_DESIRE_HIGH, npcTarget:GetLocation();
		
	end
	
	
	if ( npcBot:GetActiveMode() == BOT_MODE_RETREAT and not npcBot:IsMagicImmune()) 
	then
		local nCanHurtHeroLocationAoENearby = npcBot:FindAoELocation( true, true, npcBot:GetLocation(), nCastRange - 200, nRadius, 0.8, 0);
		if nCanHurtHeroLocationAoENearby.count >= 1 
			and npcBot:IsFacingLocation(nCanHurtHeroLocationAoENearby.targetloc,60)
		then			
			return BOT_ACTION_DESIRE_HIGH, nCanHurtHeroLocationAoENearby.targetloc;
		end
	end
	
	
	if #hEnemyHeroList == 0
		and nSkillLV >= 2
		and npcBot:GetActiveMode( ) ~= BOT_MODE_ATTACK
		and npcBot:GetActiveMode( ) ~= BOT_MODE_LANING
		and npcBot:GetMana() >= nKeepMana
		and #nEnemysLaneCreepsInSkillRange >= 2
		and (nCanHurtCreepsLocationAoE.count >= 5 - nMP * 2.1)
	then
		local nAllies = npcBot:GetNearbyHeroes(1200,false,BOT_MODE_NONE);
		if J.IsValid(nEnemysLaneCreepsInSkillRange[1]) and #nAllies < 3
		   and not nEnemysLaneCreepsInSkillRange[1]:HasModifier("modifier_viper_nethertoxin")
		then
			return BOT_ACTION_DESIRE_HIGH, nCanHurtCreepsLocationAoE.targetloc;
		end
	end	
	
	if  J.IsFarming(npcBot) 
		and nSkillLV >= 2
		and J.IsAllowedToSpam(npcBot, nManaCost * 0.3)
	then
		if J.IsValid(npcTarget)
		   and npcTarget:GetTeam() == TEAM_NEUTRAL
		   and not npcTarget:HasModifier("modifier_viper_nethertoxin")
		then
			local nAoe = npcBot:FindAoELocation( true, false, npcBot:GetLocation(), nCastRange, nRadius, 0, 0);
			if nAoe.count >= 5 - nMP * 2.5
			    and J.GetNearbyAroundLocationUnitCount(true, false, nRadius, nAoe.targetloc) >= 2
			then
				return BOT_ACTION_DESIRE_HIGH,nAoe.targetloc;
			end
		end
	end
	
	if  npcBot:GetActiveMode() == BOT_MODE_ROSHAN  
	then
	    local nAttackTarget = npcBot:GetAttackTarget();
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
	local nAttackRange = npcBot:GetAttackRange();
	local nDamage = (abilityR:GetLevel() *40 + 20) *5 + talentBonusDamage;
	
	local nEnemysHerosInCastRange = npcBot:GetNearbyHeroes(nCastRange + 80 ,true,BOT_MODE_NONE);
	local nWeakestEnemyHeroInCastRange = J.GetVulnerableWeakestUnit(true, true, nCastRange + 80, npcBot);
	local npcTarget = J.GetProperTarget(npcBot)
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
				if J.IsInRange(npcTarget, npcBot, nCastRange + 80)   
					and J.CanCastOnMagicImmune(npcTarget)
				then					
					castRTarget = npcTarget;
					return BOT_ACTION_DESIRE_HIGH,castRTarget;
				else
					castRTarget = nWeakestEnemyHeroInCastRange;                    
					return BOT_ACTION_DESIRE_HIGH,castRTarget;
				end
			end	
		end
		
		if J.CanCastOnMagicImmune(nEnemysHerosInCastRange[1])
		then
			castRTarget = nEnemysHerosInCastRange[1];   
			return BOT_ACTION_DESIRE_HIGH,castRTarget;
		end
	end	
	
	
	if npcBot:GetActiveMode() == BOT_MODE_ROSHAN and npcBot:HasScepter()
	then
	    local nAttackTarget = npcBot:GetAttackTarget();
		if  nAttackTarget ~= nil and nAttackTarget:IsAlive()
			and nAttackTarget:HasModifier("modifier_viper_poison_attack_slow")
		then
			return BOT_ACTION_DESIRE_HIGH,nAttackTarget;
		end
	end
	
	return BOT_ACTION_DESIRE_NONE	
end

return X
-- dota2jmz@163.com QQ:2462331592.
