local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func')
local Minion = dofile( GetScriptDirectory()..'/FunLib/Minion')
local sTalentList = J.Skill.GetTalentList(bot)
local sAbilityList = J.Skill.GetAbilityList(bot)
local sOutfit = J.Skill.GetOutfitName(bot)

local tTalentTreeList = {
						['t25'] = {10, 0},
						['t20'] = {0, 10},
						['t15'] = {10, 0},
						['t10'] = {0, 10},
}

local tAllAbilityBuildList = {
						{2,1,2,1,2,6,2,1,1,3,3,3,3,6,6},
						{1,2,2,3,2,1,2,1,1,6,6,3,3,3,6},
}

local nAbilityBuildList = J.Skill.GetRandomBuild(tAllAbilityBuildList)

local nTalentBuildList = J.Skill.GetTalentBuild(tTalentTreeList)

X['sBuyList'] = {
				sOutfit,
				"item_crimson_guard",
				"item_heavens_halberd",
				"item_lotus_orb",
				"item_assault", 
--				"item_heart",
}

X['sSellList'] = {
	"item_hand_of_midas",
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

local abilityQ = bot:GetAbilityByName( sAbilityList[1] )
local abilityW = bot:GetAbilityByName( sAbilityList[2] )
local abilityR = bot:GetAbilityByName( sAbilityList[6] )


local castQDesire,castQTarget = 0;
local castWDesire,castWTarget = 0;
local castRDesire = 0;

local nKeepMana,nMP,nHP,nLV,hEnemyHeroList;


function X.SkillsComplement()

	
	if J.CanNotUseAbility(bot) or bot:IsInvisible() then return end

	
	
	nKeepMana = 180
	nMP = bot:GetMana()/bot:GetMaxMana();
	nHP = bot:GetHealth()/bot:GetMaxHealth();
	nLV = bot:GetLevel();
	hEnemyHeroList = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE);
	
	
	
	
	castQDesire, castQTarget   = X.ConsiderQ();
	if ( castQDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, true)
		
		bot:ActionQueue_UseAbilityOnEntity( abilityQ, castQTarget )
		return;
	end
	
	castWDesire, castWTarget = X.ConsiderW();
	if ( castWDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, true)
	
		bot:ActionQueue_UseAbilityOnEntity( abilityW, castWTarget )
		return;
	end

	castRDesire = X.ConsiderR();
	if ( castRDesire > 0 ) 
	then
	
		J.SetQueuePtToINT(bot, true)
	
		bot:ActionQueue_UseAbility( abilityR )
		return;
	end
	

end


function X.ConsiderQ()

	-- Make sure it's castable
	if ( not abilityQ:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE, 0; 
	end

	-- Get some of its values
	local nCastRange = abilityQ:GetCastRange();
	local nCastPoint = abilityQ:GetCastPoint( );
	local nManaCost  = abilityQ:GetManaCost( );
	
	local tableNearbyAllyHeroes = bot:GetNearbyHeroes( nCastRange + 600, false, BOT_MODE_NONE );
	local nEnemyHeroes = bot:GetNearbyHeroes( 260, true, BOT_MODE_NONE );
	
	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if J.IsRetreating(bot) and nHP > 0.3
	then
		for _,npcEnemy in pairs( tableNearbyAllyHeroes )
		do
			if J.IsValid(npcEnemy)
				and J.CanCastOnNonMagicImmune(npcEnemy)
				and X.ConsiderQtarget(npcEnemy)
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end  
		end
	end

	if J.IsInTeamFight(bot, 1200) and bot:HasScepter()
	then
		if tableNearbyAllyHeroes ~= nil and #tableNearbyAllyHeroes >= 1 then
			for _,npcEnemy in pairs( tableNearbyAllyHeroes )
			do
				if X.ConsiderQtarget(npcEnemy)
				then
					return BOT_ACTION_DESIRE_LOW, npcEnemy;
				end  
			end
		end
	end
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(bot)
	then
		if tableNearbyAllyHeroes ~= nil and #tableNearbyAllyHeroes >= 1 then
			for _,npcEnemy in pairs( tableNearbyAllyHeroes )
			do
				if X.ConsiderQtarget(npcEnemy)
				then
					return BOT_ACTION_DESIRE_LOW, npcEnemy;
				end  
			end
		end
	end

	if X.ConsiderQtarget(bot) then
		return BOT_ACTION_DESIRE_HIGH, bot;
	end
	
	return BOT_ACTION_DESIRE_NONE, 0;

end


function X.ConsiderW()
	-- 确保技能可以使用
	if not abilityW:IsFullyCastable()
	   or bot:IsRooted()
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
				and nHP > 0.5
				and npcEnemyHP < 0.4
			then
				return BOT_ACTION_DESIRE_HIGH, npcEnemy;
			end
		end
		--魔法充裕，给自己套个套子
		if nMP > 0.7 then
				if nHP >= 0.5
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
						bot:Action_AttackUnit(npcMostDangerousEnemy, false);
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
			and nHP < 0.5
		 then
			return BOT_ACTION_DESIRE_HIGH, bot;
		end
		for _,npcEnemy in pairs( nAlleys )
		do
			npcEnemyHP = npcEnemy:GetHealth()/npcEnemy:GetMaxHealth();--队友血量比
			if  J.IsValid(npcEnemy)
				and J.CanCastOnNonMagicImmune(npcEnemy) 
				and nHP > 0.5
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

function X.ConsiderR()
	if ( not abilityR:IsFullyCastable() ) then 
		return BOT_ACTION_DESIRE_NONE;
	end

	-- Get some of its values
	local nRadius    = abilityR:GetSpecialValueInt( "radius" );
	local nCastPoint = abilityR:GetCastPoint( );
	local nManaCost  = abilityR:GetManaCost( );

	local tableNearbyAllyHeroes = bot:GetNearbyHeroes( nRadius, false, BOT_MODE_NONE );
	local tableNearbyEnemyHeroes = bot:GetNearbyHeroes( 1400, true, BOT_MODE_NONE );

	if #tableNearbyAllyHeroes >= 3 and #tableNearbyEnemyHeroes >= 3 then
		return BOT_ACTION_DESIRE_HIGH;
	end

	return BOT_ACTION_DESIRE_NONE;
end

function X.ConsiderQtarget(target)

	-- Get some of its values
	local nRadius    = 260;
	local tHP		 = target:GetHealth()/target:GetMaxHealth();
	
	local tableNearbyEnemyHeroes = target:GetNearbyHeroes( nRadius, true, BOT_MODE_NONE );

	-- If we're seriously retreating, see if we can land a stun on someone who's damaged us recently
	if #tableNearbyEnemyHeroes > 1
	then
		for _,npcEnemy in pairs( tableNearbyEnemyHeroes )
		do
			if target:WasRecentlyDamagedByHero( npcEnemy, 1.0 ) 
			then
				return true;
			end
		end
	end
	
	-- If We're pushing or defending
	if J.IsPushing(target) or J.IsDefending(target) or J.IsGoingOnSomeone(target)
	then
		local tableNearbyEnemyCreeps = target:GetNearbyLaneCreeps( 260, true );
		if tableNearbyEnemyCreeps ~= nil and #tableNearbyEnemyCreeps >= 3 then
			return true;
		end
	end
	
	if J.IsInTeamFight(target, 260)
	then
		if tableNearbyEnemyHeroes ~= nil and #tableNearbyEnemyHeroes >= 3 then
			return true;
		end
	end
	
	-- If we're going after someone
	if J.IsGoingOnSomeone(target)
	then
		local npcTarget = J.GetProperTarget(target);
		if J.IsValidHero(npcTarget) and J.CanCastOnMagicImmune(npcTarget) and J.IsInRange(npcTarget, target, 200)
		then
			return true;
		end
		
		if J.IsValid(npcTarget)
		   and J.CanCastOnNonMagicImmune(npcTarget) 
		   and J.IsInRange(npcTarget, target, 250) 
		then
			local nCreeps = target:GetNearbyCreeps(260,true);
			if #nCreeps >= 2
			then
				return true;
			end
		end
	end

	-- If mana is too much
	if tHP < 0.6
		and target:DistanceFromFountain() > 1400
	then
		return true;
	end
	
	return false;

end

return X