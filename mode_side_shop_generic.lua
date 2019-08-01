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

local npcBot = GetBot();
local X = {}
local BOT_SIDE_SHOP = GetShopLocation(GetTeam(), SHOP_SIDE )
local TOP_SIDE_SHOP = GetShopLocation(GetTeam(), SHOP_SIDE2 )
local closestSideShop = nil;

function GetDesire()
			
	if not X.IsSuitableToBuy() then
		return BOT_MODE_DESIRE_NONE;
	end
	
	local invFull = true;
	
	for i=0,8 do 
		if npcBot:GetItemInSlot(i) == nil then
			invFull = false;
		end	
	end
	
	if invFull then
		return BOT_MODE_DESIRE_NONE
	end
	
	if npcBot.SideShop then
		closestSideShop = X.GetClosestSideShop();
		if X.IsNearbyEnemyClosestToLoc(closestSideShop) == false then
			return BOT_MODE_DESIRE_HIGH
		end
	end

	return BOT_MODE_DESIRE_NONE

end

function Think()
	
	if  npcBot:IsChanneling() 
		or npcBot:NumQueuedActions() > 0
		or npcBot:IsCastingAbility()
		or npcBot:IsUsingAbility()
	then 
		return;
	end
	
	if npcBot:DistanceFromSideShop() > 0 then
		npcBot:Action_MoveToLocation(closestSideShop);
		return
	end	
	
end

function OnStart()

end

function OnEnd()

end

function X.IsNearbyEnemyClosestToLoc(loc)
	local closestDist = GetUnitToLocationDistance(npcBot, loc);
	local closestUnit = npcBot;
	local enemies = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	for _,enemy in pairs(enemies) do
		local dist = GetUnitToLocationDistance(enemy, loc);
		if dist + 200 < closestDist and closestDist > 1200 then
			return true;
		end
	end
	return false;
end

function X.GetClosestSideShop()

	local TSSD = GetUnitToLocationDistance(npcBot, TOP_SIDE_SHOP);
	local BSSD = GetUnitToLocationDistance(npcBot, BOT_SIDE_SHOP);
	
	if TSSD < BSSD then 
		return TOP_SIDE_SHOP;
	else
		return BOT_SIDE_SHOP;
	end	

end

function X.IsSuitableToBuy()
	local mode = npcBot:GetActiveMode();
	if ( ( mode == BOT_MODE_RETREAT and npcBot:GetActiveModeDesire() >= BOT_MODE_DESIRE_HIGH )
		or mode == BOT_MODE_ATTACK
		or mode == BOT_MODE_DEFEND_ALLY
		or mode == BOT_MODE_DEFEND_TOWER_TOP
		or mode == BOT_MODE_DEFEND_TOWER_MID
		or mode == BOT_MODE_DEFEND_TOWER_BOT
		or mode == BOT_MODE_TEAM_ROAM
		) 
	then
		return false;
	end
	return true;
end

-- dota2jmz@163.com QQ:2462331592