----------------------------------------------------------------------------------------------------
--- The Creation Come From: BOT EXPERIMENT Credit:FURIOUSPUPPY
--- BOT EXPERIMENT Author: Arizona Fauzie 2018.11.21
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=837040016
--- Update by: 决明子 Email: dota2jmz@163.com 微博@Dota2_决明子
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1573671599
--- Link:http://steamcommunity.com/sharedfiles/filedetails/?id=1627071163
----------------------------------------------------------------------------------------------------

if GetBot():IsInvulnerable() or not GetBot():IsHero() or not string.find(GetBot():GetUnitName(), "hero") or  GetBot():IsIllusion() then
	return;
end

local role = require( GetScriptDirectory()..'/FunLib/jmz_role')
local Site = require( GetScriptDirectory()..'/FunLib/jmz_site')
local N = require( GetScriptDirectory()..'/AuxiliaryScript/Comicdialogue')
local bot = GetBot();
local X = {}
local AvailableSpots = {};
local nWardCastRange = 500;
local itemWard = nil;
local targetLoc = nil;
local wardCastTime = -90;


bot.lastSwapWardTime = -90;
bot.ward = false;
bot.steal = false;

if Site["RandomIntRoute"] == nil then
	Site["RandomIntRoute"] = RandomInt(1,4)
end
local routelist = {
	{
		Vector(-108.000000, 2271.000000, 0.000000),
		Vector(-1276.000000, 3644.000000, 0.000000),
		Vector(-3148.000000, 3720.000000, 0.000000)
	},
	{
		Vector(-5229.000000, 3687.000000, 0.000000),
		Vector(-2509.000000, 4789.000000, 0.000000),
		Vector(-3148.000000, 3720.000000, 0.000000)
	},
	{
		Vector(-5229.000000, 3687.000000, 0.000000),
		Vector(-1061.000000, 4795.000000, 0.000000),
		Vector(-3148.000000, 3720.000000, 0.000000)
	},
	{
		Vector(1387.000000, -2905.000000, 0.000000),
		Vector(3532.000000, -792.000000, 0.000000),
		Vector(4403.000000, -1604.000000, 0.000000)
	}
}
local route = routelist[Site["RandomIntRoute"]]

local route2list = {
	{
		Vector(3597.000000, 351.000000, 0.000000),
		Vector(4508.000000, -1669.000000, 0.000000),
		Vector(5409.000000, -3787.000000, 0.000000)
	},
	{
		Vector(3597.000000, 351.000000, 0.000000),
		Vector(2186.000000, -3656.000000, 0.000000),
		Vector(3689.000000, -3625.000000, 0.000000)
	},
	{
		Vector(3.000000, 2058.000000, 0.000000),
		Vector(-2745.000000, 282.000000, 0.000000),
		Vector(-4242.000000, 649.000000, 0.000000)
	},
	{
		Vector(3597.000000, 351.000000, 0.000000),
		Vector(2186.000000, -3656.000000, 0.000000),
		Vector(3689.000000, -3625.000000, 0.000000)
	}
}
local route2 = route2list[Site["RandomIntRoute"]]

local vNonStuck = Vector(-2610.000000, 538.000000, 0.000000);


local walkMode = false;
local walkLocation = Vector(0,0);

local nStartTime = RandomInt(1,30);

function GetDesire()
	
	if bot:GetUnitName() == "npc_dota_hero_necrolyte" 
	   and bot:GetLevel() > 10
	   and bot:IsAlive()
	   and not bot:IsChanneling()
	   and not bot:IsCastingAbility()
	   and bot:NumQueuedActions() <= 0
	then
		local cAbilty = bot:GetAbilityByName( "necrolyte_death_pulse" );
		local nEnemys = bot:GetNearbyHeroes(1600,true,BOT_MODE_NONE); 
		if cAbilty ~= nil and #nEnemys == 0
		   and ( cAbilty:IsFullyCastable() or (cAbilty:GetCooldownTimeRemaining() < 3 and bot:GetMana() > 180) )
		then
			local nAoe = bot:FindAoELocation( true, false, bot:GetLocation(),700, 475, 0.5, 0);
			local nLaneCreeps = bot:GetNearbyLaneCreeps(1000,true);
			if nAoe.count >= 3 
				and #nLaneCreeps >= 3
			then
				walkMode = true;
				walkLocation = nAoe.targetloc;
				return BOT_MODE_DESIRE_VERYHIGH;
			end
		end
	end
	
	itemWard = Site.GetItemWard(bot);

	if bot:IsChanneling() 
	   or bot:IsIllusion() 
	   or bot:IsInvulnerable() 
	   or not X.IsSuitableToWard()
	   or not bot:IsAlive()
	then
		return BOT_MODE_DESIRE_NONE;
	end

	if DotaTime() < 0 then
		local enemies = bot:GetNearbyHeroes(500, true, BOT_MODE_NONE)
		if ( (GetTeam() == TEAM_RADIANT and bot:GetAssignedLane() == LANE_TOP) 
		      or (GetTeam() == TEAM_DIRE and bot:GetAssignedLane() == LANE_BOT) 
			  or  role.IsSupport(bot:GetUnitName()) 
			  or ( bot:GetUnitName() == "npc_dota_hero_elder_titan" and DotaTime() > -59 ) 
			  or ( bot:GetUnitName() == 'npc_dota_hero_wisp' and DotaTime() > -59 )
			  ) 
		  and #enemies == 0 
		then
			bot.steal = true;
			return BOT_MODE_DESIRE_ABSOLUTE;
		end
	else	
		bot.steal = false;
	end
	
	if DotaTime() < 60 + nStartTime
	then
		return BOT_MODE_DESIRE_NONE;
	end	
	
	if itemWard ~= nil  then
		
		AvailableSpots = Site.GetAvailableSpot(bot);
		targetLoc, targetDist = Site.GetClosestSpot(bot, AvailableSpots);
		if targetLoc ~= nil and DotaTime() > wardCastTime + 1.0 then
			bot.ward = true;
			return math.floor((RemapValClamped(targetDist, 6000, 0, BOT_MODE_DESIRE_MODERATE, BOT_MODE_DESIRE_VERYHIGH))*20)/20;
		end
	end
	
	return BOT_MODE_DESIRE_NONE;
end

function OnStart()
	if itemWard ~= nil and not walkMode then
		local wardSlot = bot:FindItemSlot(itemWard:GetName());
		if bot:GetItemSlotType(wardSlot) == ITEM_SLOT_TYPE_BACKPACK then
			local leastCostItem = X.FindLeastItemSlot();
			if leastCostItem ~= -1 then
				bot.lastSwapWardTime = DotaTime();
				bot:ActionImmediate_SwapItems( wardSlot, leastCostItem );
				return
			end
			local active = bot:GetItemInSlot(leastCostItem);
			print(active:GetName()..'IsCastable:'..tostring(active:IsFullyCastable()));
		end
	end
end

function OnEnd()
	AvailableSpots = {};
	bot.steal = false;
	itemWard = nil;
	walkMode = false;
end

function Think()

	if GetGameState()~=GAME_STATE_PRE_GAME and GetGameState()~= GAME_STATE_GAME_IN_PROGRESS then
		return;
	end
	

	if walkMode then
		local nCreep = bot:GetNearbyLaneCreeps(1000,true);
		if GetUnitToLocationDistance(bot,walkLocation) <= 20
		then
			if nCreep[1] ~= nil and nCreep[1]:IsAlive()
			then
				bot:Action_AttackUnit(nCreep[1], true);
			end
			if #nCreep == 0 then walkMode = false; end
			return;
		else
			bot:Action_MoveToLocation(walkLocation);
			if #nCreep == 0 then walkMode = false; end
			return;
		end
	end

	
	if bot.ward then
		if targetDist <= nWardCastRange then
			if  DotaTime() > bot.lastSwapWardTime + 6.1 then
				bot:Action_UseAbilityOnLocation(itemWard, targetLoc);
				wardCastTime = DotaTime();	
				return
			else
				if targetLoc == Vector(-2948.000000, 769.000000, 0.000000) then
					bot:Action_MoveToLocation(vNonStuck +RandomVector(300));
					return
				else	
					bot:Action_MoveToLocation(targetLoc +RandomVector(300));
					return
				end
			end
		else
			if targetLoc == Vector(-2948.000000, 769.000000, 0.000000) then
				bot:Action_MoveToLocation(vNonStuck +RandomVector(100));
				return
			else	
				bot:Action_MoveToLocation(targetLoc +RandomVector(100));
				return
			end
		end
	end
	
	if bot.steal == true then
		local stealCount = CountStealingUnit();
		smoke = HasItem('item_smoke_of_deceit');
		local loc = nil;
		
		if smoke ~= nil and chat == false then
			chat = true;
			bot:ActionImmediate_Chat("走起，偷符ヾ(≧▽≦*)o",false);
			return
		end
		
		if smoke ~= nil and smoke:IsFullyCastable() and not bot:HasModifier('modifier_smoke_of_deceit') then
			bot:Action_UseAbility(smoke);
			return
		end
		
		if ComicDialogue == nil then
			ComicDialogue = N.ComicDialogue()
		end
		
		if GetTeam() == TEAM_RADIANT then
			for _,r in pairs(route) do
				if r ~= nil then
					loc = r;
					break;
				end
			end
		else
			for _,r in pairs(route2) do
				if r ~= nil then
					loc = r;
					break;
				end
			end
		end
		
		local allies = CountStealUnitNearLoc(loc, 300);
		
		if ( GetTeam() == TEAM_RADIANT and #route == 1 ) or ( GetTeam() == TEAM_DIRE and #route2 == 1 )  then
			bot:Action_MoveToLocation(loc);
			return
		elseif GetUnitToLocationDistance(bot, loc) <= 300 and allies < stealCount then
			bot:Action_MoveToLocation(loc);
			return	
		elseif GetUnitToLocationDistance(bot, loc) > 300 then
			bot:Action_MoveToLocation(loc);
			return
		else
			if GetTeam() == TEAM_RADIANT then
				table.remove(route,1);
			else
				table.remove(route2,1);
			end
		end
		
	end

end

function CountStealingUnit()
	local count = 0;
	for i,id in pairs(GetTeamPlayers(GetTeam())) do
		local unit = GetTeamMember(i);
		if IsPlayerBot(id) and unit ~= nil and unit.steal == true then
			count = count + 1;
		end
	end
	return count;
end

function  CountStealUnitNearLoc(loc, nRadius)
	local count = 0;
	for i,id in pairs(GetTeamPlayers(GetTeam())) do
		local unit = GetTeamMember(i);
		if unit ~= nil and unit.steal == true and GetUnitToLocationDistance(unit, loc) <= nRadius then
			count = count + 1;
		end
	end
	return count;
end

function HasItem(item_name)
	for i=0,5  do
		local item = bot:GetItemInSlot(i); 
		if item ~= nil and item:GetName() == item_name then
			return item;
		end
	end
	return nil;
end

function IsSafelaneCarry()
	return role.CanBeSafeLaneCarry(bot:GetUnitName()) and ( (GetTeam()==TEAM_DIRE and bot:GetAssignedLane()==LANE_TOP) or (GetTeam()==TEAM_RADIANT and bot:GetAssignedLane()==LANE_BOT)  )	
end

function X.FindLeastItemSlot()
	local minCost = 100000;
	local idx = -1;
	for i=0,5 do
		if  bot:GetItemInSlot(i) ~= nil and bot:GetItemInSlot(i):GetName() ~= "item_aegis"  then
			local _item = bot:GetItemInSlot(i):GetName()
			if( GetItemCost(_item) < minCost ) then
				minCost = GetItemCost(_item);
				idx = i;
			end
		end
	end
	return idx;
end


--check if the condition is suitable for warding
function X.IsSuitableToWard()
	local Enemies = bot:GetNearbyHeroes(1300, true, BOT_MODE_NONE);
	local mode = bot:GetActiveMode();
	if ( ( mode == BOT_MODE_RETREAT and bot:GetActiveModeDesire() >= BOT_MODE_DESIRE_MODERATE )
		or mode == BOT_MODE_ATTACK
		or mode == BOT_MODE_RUNE 
		or mode == BOT_MODE_DEFEND_ALLY
		or mode == BOT_MODE_DEFEND_TOWER_TOP
		or mode == BOT_MODE_DEFEND_TOWER_MID
		or mode == BOT_MODE_DEFEND_TOWER_BOT
		or #Enemies >= 2
		or ( #Enemies >= 1 and X.IsIBecameTheTarget(Enemies) )
		or bot:WasRecentlyDamagedByAnyHero(5.0)
		) 
	then
		return false;
	end
	return true;
end

function X.IsIBecameTheTarget(units)
	for _,u in pairs(units) do
		if u:GetAttackTarget() == bot then
			return true;
		end
	end
	return false;
end

-- dota2jmz@163.com QQ:2462331592
